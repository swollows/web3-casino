// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/Script.sol";

abstract contract ProxyBase is Ownable {
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    address casinoCounter;
    address JCTToken;

    constructor() Ownable(msg.sender) {
    }

    function setCasinoCounter(address _casinoCounter) public onlyOwner {
        casinoCounter = _casinoCounter;
    }

    function setJCTToken(address _JCTToken) public onlyOwner {
        JCTToken = _JCTToken;
    }

    function setImplementation(address _impl) public onlyOwner {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _impl)
        }
    }

    function _getImplementation() private view returns (address _impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            _impl := sload(slot)
        }
    }

    fallback() external payable {
        require(casinoCounter != address(0), "Casino counter not set");
        require(JCTToken != address(0), "JCT token not set");

        address _impl = _getImplementation();
        require(_impl != address(0), "Implementation not set");

        console.log("Implementation:", _impl);

        assembly {
            // 0x40 슬롯에 프록시 컨트랙트의 코드 크기를 저장
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            // 컨트랙트 코드를 델리게이트 콜 하여 실행
            let result := delegatecall(
                gas(),
                _impl,
                ptr,
                calldatasize(),
                0,
                0
            )
            
            // 델리게이트 콜 결과를 저장
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            // 델리게이트 콜 결과에 따라 예외 처리 또는 반환
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