// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract ProxyBase is Ownable {
    address implementation = address(0);
    address casinoCounter;
    address jctToken;

    string constant selector = "initialize(address,address,address)";

    bytes initData;

    constructor(address _impl, address _casinoCounter, address _jctToken) Ownable(msg.sender) {
        implementation = _impl;
        casinoCounter = _casinoCounter;
        jctToken = _jctToken;
        initData = abi.encodeWithSignature(selector, _jctToken, _casinoCounter, msg.sender);
    }

    function upgradeDelegate(address newDelegateAddress) public virtual;

    fallback() external payable onlyOwner {
        require(implementation != address(0), "Implementation not set");
        require(casinoCounter != address(0), "Casino counter not set");
        require(jctToken != address(0), "JCT token not set");

        assembly {
            let _target := sload(0)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
    }

    receive() external payable {}
}