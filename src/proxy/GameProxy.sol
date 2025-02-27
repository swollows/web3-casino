// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./ProxyBase.sol";

contract BlackjackProxy is ProxyBase {
    constructor(address _impl, address _casinoCounter, address _jctToken)
     ProxyBase(_impl, _casinoCounter, _jctToken)
     {}

    function upgradeDelegate(address newDelegateAddress) public override onlyOwner {
        require(msg.sender == owner(), "Only owner can upgrade Blackjack contract");
        implementation = newDelegateAddress;
    }
}

contract CoinTossProxy is ProxyBase {
    constructor(address _impl, address _casinoCounter, address _jctToken)
     ProxyBase(_impl, _casinoCounter, _jctToken) 
    {}

    function upgradeDelegate(address newDelegateAddress) public override onlyOwner {
        require(msg.sender == owner(), "Only owner can upgrade CoinToss contract");
        implementation = newDelegateAddress;
    }
}

contract RouletteProxy is ProxyBase {
    constructor(address _impl, address _casinoCounter, address _jctToken)
     ProxyBase(_impl, _casinoCounter, _jctToken) 
     {}

    function upgradeDelegate(address newDelegateAddress) public override onlyOwner {
        require(msg.sender == owner(), "Only owner can upgrade Roulette contract");
        implementation = newDelegateAddress;
    }
}
