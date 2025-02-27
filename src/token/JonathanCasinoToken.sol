// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @custom:security-contact jonathan@upside.center
contract JonathanCasinoToken is ERC20, ERC20Permit, ERC20Pausable, ERC20Burnable, Ownable {
    mapping(address => uint256[]) public playerInvestList;

    constructor(address _owner) payable
        ERC20("Jonathan's Casino Token", "JCT")
        Ownable(_owner)
        ERC20Permit("Jonathan's Casino Token")
    {
        require(msg.value == 1 ether, "You must send 1 ether to the contract");
        _mint(address(this), msg.value / (10 ** decimals()));
    }

    function decimals() public pure override returns (uint8) {
        return 3;
    }

    function mint(address to, uint256 amount) public
    {
        require(msg.sender == address(this), "Only the contract can mint");
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    function withdraw() external {
        require(balanceOf(msg.sender) > 0, "You must have a balance to withdraw");

        _burn(msg.sender, balanceOf(msg.sender));
        payable(msg.sender).transfer(balanceOf(msg.sender) * (10 ** decimals()));
    }

    function getBalance() external view returns (uint256) {
        address target;

        if (msg.sender == owner())
            target = address(this);
        else
            target = msg.sender;
        
        return balanceOf(target);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    receive() external payable whenNotPaused {
        require(msg.value >= 2000 * (10 ** decimals()), "You must send at least 2000 * 10e3 wei to the contract");
        require(msg.value <= 200000 * (10 ** decimals()), "You must send at most 200000 * 10e3 wei to the contract");
        require(balanceOf(msg.sender) <= msg.value / (10 ** decimals()), "You must have enough balance to deposit");

        _mint(msg.sender, msg.value / (10 ** decimals()));
    }

    // The following functions are overrides required by Solidity.
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}