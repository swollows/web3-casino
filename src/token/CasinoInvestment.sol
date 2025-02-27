// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./JonathanCasinoToken.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

// Casino Token Exchange Contract
contract CasinoInvestment is Ownable {
    JonathanCasinoToken public JCTToken;

    bytes4 constant DEPOSIT_INVEST_TO_PLAYER_SELECTOR = bytes4(keccak256("depositInvestToPlayer(uint256,address)"));

    struct InvestCall {
        address target;
        bytes callData;
    }

    struct Investments {
        uint256 id;
        string title;
        address creator;
        uint256 amount;
        uint256 endTime;
    }

    event CallExecuted(address indexed target, bool success, bytes data);

    Investments[] public investStack;

    mapping(address => Investments[]) public playerInvestList;

    constructor(address payable _JCTToken, address _owner) Ownable(_owner) {
        JCTToken = JonathanCasinoToken(_JCTToken);
    }
    
    function createInvest(string memory _title, uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(investStack.length < 100, "Investment limit reached");
        require(JCTToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");

        investStack.push(Investments({
            id: investStack.length + 1,
            title: _title,
            creator: msg.sender,
            amount: _amount,
            endTime: block.timestamp + 1 days
        }));
    }

    function depositInvestToPlayer(Investments memory _investment) public {
        require(_investment.id > 0, "Investment not found");

        JCTToken.transferFrom(_investment.creator, msg.sender, _investment.amount);
    }

    function getInvestsListInfo() public view returns (Investments[] memory) {
        return investStack;
    }

    function getPlayerInvestList(address _player) public view returns (Investments[] memory) {
        return playerInvestList[_player];
    }

    function multiCall(InvestCall[] memory _calls) external {
        for (uint256 i = 0; i < _calls.length; i++) {
            (bool success, bytes memory data) = _calls[i].target.call(_calls[i].callData);

            // Emit an event with the result of the call
            emit CallExecuted(_calls[i].target, success, data);

            // If the call failed, revert the transaction
            require(success, "Call failed");
        }
    }
}