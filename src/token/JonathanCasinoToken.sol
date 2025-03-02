// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title JonathanCasinoToken
 * @notice ERC20 token for Jonathan's Casino
 */
/// @custom:security-contact jonathan@upside.center
contract JonathanCasinoToken is ERC20, ERC20Burnable, Ownable {
    bool public isEmergency = false;

    /**
     * @notice Constructor of the JonathanCasinoToken contract
     * @param _owner The owner of the contract
     */
    constructor(address _owner) payable
        ERC20("Jonathan's Casino Token", "JCT")
        Ownable(_owner)
    {
        require(msg.value == 1 ether, "You must send 1 ether to the contract");
        _mint(address(this), msg.value / 10e3);
    }

    /**
     * @notice Modifier to stop the contract when emergency is enabled
     */
    modifier stopWhenEmergency() {
        require(!isEmergency, "Contract is paused");
        _;
    }

    /**
     * @notice Modifier to only allow the owner to call the function when emergency is enabled
     */
    modifier onlyWhenEmergency() {
        require(isEmergency && msg.sender == owner(), "Only owner can call this function now");
        _;
    }

    /**
     * @notice Transfer function
     * @param _to The address to transfer the tokens to
     * @param _amount The amount of tokens to transfer
     * @return bool True if the transfer was successful
     */
    function transfer(address _to, uint256 _amount) public override stopWhenEmergency returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");
        require(balanceOf(owner()) >= _amount, "Insufficient balance");

        return super.transfer(_to, _amount);
    }

    /**
     * @notice TransferFrom function
     * @param _from The address to transfer the tokens from
     * @param _to The address to transfer the tokens to
     * @param _amount The amount of tokens to transfer
     * @return bool True if the transfer was successful
     */
    function transferFrom(address _from, address _to, uint256 _amount) public override stopWhenEmergency returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");
        require(balanceOf(_from) >= _amount, "Insufficient balance");
        
        return super.transferFrom(_from, _to, _amount);
    }

    /**
     * @notice ApproveFrom function
     * @param _owner The address to approve the tokens from
     * @param _spender The address to approve the tokens to
     * @param _amount The amount of tokens to approve
     */
    function approveFrom(address _owner, address _spender, uint256 _amount) public stopWhenEmergency {
        require(_owner != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");
        require(balanceOf(_owner) >= _amount, "Insufficient balance");

        _approve(_owner, _spender, _amount);
    }

    /**
     * @notice Burn function
     * @param _target The address to burn the tokens from
     * @param _amount The amount of tokens to burn
     */
    function burn(address _target, uint256 _amount) public stopWhenEmergency onlyOwner {
        require(balanceOf(_target == owner() ? address(this) : _target) >= _amount, "Insufficient balance");

        _burn(_target, _amount);
    }

    /**
     * @notice Update function
     * @param _from The address to update the tokens from
     * @param _to The address to update the tokens to
     * @param _value The amount of tokens to update
     */
    function _update(address _from, address _to, uint256 _value)
        internal
        override(ERC20)
    {
        super._update(_from, _to, _value);
    }

    /**
     * @notice Decimals function
     * @return uint8 The number of decimals
     */
    function decimals() public pure override returns (uint8) {
        return 3;
    }

    /**
     * @notice Deposit function
     * @dev Only the owner can deposit tokens
     */
    function deposit() external payable stopWhenEmergency {
        address dest = msg.sender == owner() ? address(this) : msg.sender;

        require(msg.value / 10e3 >= 2000 && msg.value / 10e3 <= 200000, "Invalid ETH range");
        require(balanceOf(dest) + (msg.value / 10e3) <= 200000, "Total token amount must be lower than 200000");

        _mint(dest, msg.value / 10e3);
    }

    /**
     * @notice Withdraw function
     * @param _amount The amount of tokens to withdraw
     */
    function withdraw(uint256 _amount) public stopWhenEmergency {
        address _from = msg.sender == owner() ? address(this) : msg.sender;

        require(balanceOf(_from) >= _amount, "Insufficient balance");

        _burn(_from, _amount);
        payable(_from).transfer(_amount * 10e3);
    }

    /**
     * @notice BalanceOf function
     * @param _account The address to check the balance of
     * @return uint256 The balance of the address
     */
    function balanceOf(address _account) public view override returns (uint256) {
        return super.balanceOf(_account == owner() ? address(this) : _account);
    }

    /**
     * @notice Enable emergency function
     * @dev Only the owner can enable emergency
     */
    function enableEmergency() public onlyOwner {
        require(!isEmergency, "Emergency is already enabled");

        isEmergency = true;
    }

    /**
     * @notice Disable emergency function
     * @dev Only the owner can disable emergency
     */
    function disableEmergency() public onlyOwner {
        require(isEmergency, "Emergency is not enabled");

        isEmergency = false;
    }

    /**
     * @notice Emergency withdraw function
     * @dev Only the owner can withdraw the tokens when emergency is enabled
     */
    function emergencyWithdraw() public onlyWhenEmergency onlyOwner {
        payable(owner()).call{value: balanceOf(address(this)) * 10e3}("");
        _burn(address(this), balanceOf(address(this)));
    }
}