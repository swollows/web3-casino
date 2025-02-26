// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./JonathanCasinoToken.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

// Casino Token Exchange Contract
contract CasinoInvestment is Ownable {
    JonathanCasinoToken public JCTToken;

    struct Investments {
        string title;
        address creator;
        uint256 amount;
        uint256 endTime;
    }

    Investments[] public investStack;

    mapping(address => Investments[]) public playerInvestList;

    constructor(address _JCTToken) Ownable(msg.sender) {
        JCTToken = JonathanCasinoToken(_JCTToken);
    }
    
    function createInvest(string memory _title, uint256 _amount) public {
        investStack.push(Investments({
            title: _title,
            creator: msg.sender,
            amount: _amount,
            endTime: block.timestamp + 1 days
        }));
    }

    function getInvestsList() public view returns (Investments[] memory) {
        return investStack;
    }

    function getPlayerInvestList(address _player) public view returns (Investments[] memory) {
        return playerInvestList[_player];
    }
}