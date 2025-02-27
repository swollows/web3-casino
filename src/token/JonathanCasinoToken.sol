// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @custom:security-contact jonathan@upside.center
contract JonathanCasinoToken is ERC20, ERC20Burnable, Ownable {
    mapping(address => uint256[]) public playerInvestList;

    address[] private accounts;
    bool public isEmergency = false;

    constructor(address _owner) payable
        ERC20("Jonathan's Casino Token", "JCT")
        Ownable(_owner)
    {
        require(msg.value == 1 ether, "You must send 1 ether to the contract");
        _mint(address(this), msg.value / 10e3);
    }

    modifier stopWhenEmergency() {
        require(!isEmergency, "Contract is paused");
        _;
    }

    modifier onlyWhenEmergency() {
        require(isEmergency && msg.sender == owner(), "Only owner can call this function now");
        _;
    }

    function transfer(address _to, uint256 _amount) public override stopWhenEmergency returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");
        require(balanceOf(owner()) >= _amount, "Insufficient balance");

        return super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public override stopWhenEmergency returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");
        require(balanceOf(_from) >= _amount, "Insufficient balance");
        
        return super.transferFrom(_from, _to, _amount);
    }

    function burn(address _target, uint256 _amount) public stopWhenEmergency onlyOwner {
        require(balanceOf(_target == owner() ? address(this) : _target) >= _amount, "Insufficient balance");

        _burn(_target, _amount);
    }

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20)
    {
        super._update(from, to, value);
    }

    function decimals() public pure override returns (uint8) {
        return 3;
    }

    function deposit(address _from) external payable stopWhenEmergency {
        require(msg.value / 10e3 >= 2000 && msg.value / 10e3 <= 200000, "Invalid ETH range");
        require(balanceOf(_from == owner() ? address(this) : _from) + (msg.value / 10e3) <= 200000, "Total token amount must be lower than 200000");

        accounts.push(_from);

        _mint(_from == owner() ? address(this) : _from, msg.value / 10e3);
    }

    function withdraw(uint256 _amount) public stopWhenEmergency {
        address _from = msg.sender == owner() ? address(this) : msg.sender;

        require(balanceOf(_from) >= _amount, "Insufficient balance");

        _burn(_from, _amount);
        payable(_from).transfer(_amount * 10e3);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account == owner() ? address(this) : account);
    }

    function enableEmergency() public onlyOwner {
        require(!isEmergency, "Emergency is already enabled");

        isEmergency = true;
    }

    function disableEmergency() public onlyOwner {
        require(isEmergency, "Emergency is not enabled");

        isEmergency = false;
    }

    function emergencyWithdraw() public onlyWhenEmergency onlyOwner {
        payable(owner()).call{value: balanceOf(address(this)) * 10e3}("");
        _burn(address(this), balanceOf(address(this)));
    }
}