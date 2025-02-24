// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./ERC20.sol";

contract CasinoToken is ERC20 {
    constructor(string memory _name, string memory _symbol, string memory _version) 
        ERC20(_name, _symbol, _version)
    {}
}
