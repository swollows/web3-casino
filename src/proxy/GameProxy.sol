// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./ProxyBase.sol";

contract BlackjackProxy is ProxyBase {
    function upgradeDelegate(address newDelegateAddress) public override {
        require(msg.sender == owner(), "Only owner can upgrade Blackjack contract");
        delegate = newDelegateAddress;
    }
}

contract CoinTossProxy is ProxyBase {
    function upgradeDelegate(address newDelegateAddress) public override {
        require(msg.sender == owner(), "Only owner can upgrade CoinToss contract");
        delegate = newDelegateAddress;
    }
}

contract RouletteProxy is ProxyBase {
    function upgradeDelegate(address newDelegateAddress) public override {
        require(msg.sender == owner(), "Only owner can upgrade Roulette contract");
        delegate = newDelegateAddress;
    }
}
