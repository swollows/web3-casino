// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ProxyBase
 * @notice Base contract for the proxy contracts
 */
abstract contract ProxyBase is Ownable {
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    /**
     * @notice Constructor of the ProxyBase contract
     */
    constructor() Ownable(msg.sender) {
    }

    /**
     * @notice Set the implementation
     * @param _impl The address of the implementation
     */
    function setImplementation(address _impl) public onlyOwner {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _impl)
        }
    }

    /**
     * @notice Get the implementation
     * @return The address of the implementation
     */
    function _getImplementation() private view returns (address _impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            _impl := sload(slot)
        }
    }

    /**
     * @notice Fallback function
     */
    fallback() external payable {
        require(casinoCounter != address(0), "Casino counter not set");
        require(JCTToken != address(0), "JCT token not set");

        address _impl = _getImplementation();
        require(_impl != address(0), "Implementation not set");

        assembly {
            // Store the code size of the proxy contract at 0x40 slot
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            // Execute the contract code using delegatecall
            let result := delegatecall(
                gas(),
                _impl,
                ptr,
                calldatasize(),
                0,
                0
            )
            
            // Store the delegatecall result
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            // Handle exceptions or return based on delegatecall result
            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    receive() external payable {}
}