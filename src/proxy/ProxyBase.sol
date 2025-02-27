// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract ProxyBase is Ownable {
    address implementation = address(0);
    address casinoCounter;
    address JCTToken;

    string constant selector = "initialize(address,address,address)";

    bytes initData;

    constructor(address _casinoCounter, address _JCTToken) Ownable(msg.sender) {
        casinoCounter = _casinoCounter;
        JCTToken = _JCTToken;
        initData = abi.encodeWithSignature(selector, _JCTToken, _casinoCounter);
    }

    function upgradeDelegate(address newDelegateAddress) public virtual;

    fallback() external payable onlyOwner {
        require(implementation != address(0), "Implementation not set");
        require(casinoCounter != address(0), "Casino counter not set");
        require(JCTToken != address(0), "JCT token not set");

        address(implementation).delegatecall(initData);
    }

    receive() external payable {}
}