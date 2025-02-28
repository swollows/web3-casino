// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract ProxyBase is Ownable {
    address implementation = address(0);
    address casinoCounter;
    address JCTToken;

    constructor(address _casinoCounter, address _JCTToken) Ownable(msg.sender) {
        casinoCounter = _casinoCounter;
        JCTToken = _JCTToken;
    }

    function upgradeDelegate(address newDelegateAddress) public virtual;

    fallback() external payable {
        require(implementation != address(0), "Implementation not set");
        require(casinoCounter != address(0), "Casino counter not set");
        require(JCTToken != address(0), "JCT token not set");

        assembly {
            // 0x40 슬롯에 프록시 컨트랙트의 코드 크기를 저장
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            // 컨트랙트 코드를 델리게이트 콜 하여 실행
            let result := delegatecall(
                gas(),
                sload(implementation.slot),
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