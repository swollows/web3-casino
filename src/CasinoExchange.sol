// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./CasinoToken.sol";

// 카지노 이용자간 토큰 교환 컨트랙트
contract CasinoExchange {
    CasinoToken public casinoToken;

    // 토큰 교환 제안 구조체
    struct TokenSwapOffer {
        address proposer;
        uint256 tokenAmount;
        bool isActive;
    }

    // 제안 ID => 토큰 교환 제안
    mapping(uint256 => TokenSwapOffer) public swapOffers;
    uint256 public nextOfferId;

    event OfferCreated(uint256 indexed offerId, address indexed proposer, uint256 amount);
    event OfferCanceled(uint256 indexed offerId);
    event OfferAccepted(uint256 indexed offerId, address indexed acceptor);

    constructor(address _casinoToken) {
        casinoToken = CasinoToken(_casinoToken);
    }

    /**
     * @notice 토큰 교환 제안 생성
     * @param amount 교환하고자 하는 토큰 수량
     */
    function createOffer(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(casinoToken.balanceOf(msg.sender) >= amount, "Insufficient token balance");
        
        // 제안자의 토큰을 이 컨트랙트로 전송
        require(casinoToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        
        swapOffers[nextOfferId] = TokenSwapOffer({
            proposer: msg.sender,
            tokenAmount: amount,
            isActive: true
        });

        emit OfferCreated(nextOfferId, msg.sender, amount);
        nextOfferId++;
    }

    /**
     * @notice 토큰 교환 제안 취소
     * @param offerId 취소할 제안 ID
     */
    function cancelOffer(uint256 offerId) external {
        TokenSwapOffer storage offer = swapOffers[offerId];
        require(offer.isActive, "Offer is not active");
        require(offer.proposer == msg.sender, "Not offer owner");

        offer.isActive = false;
        require(casinoToken.transfer(msg.sender, offer.tokenAmount), "Token return failed");

        emit OfferCanceled(offerId);
    }

    /**
     * @notice 토큰 교환 제안 수락
     * @param offerId 수락할 제안 ID
     */
    function acceptOffer(uint256 offerId) external {
        TokenSwapOffer storage offer = swapOffers[offerId];
        require(offer.isActive, "Offer is not active");
        require(offer.proposer != msg.sender, "Cannot accept own offer");
        require(casinoToken.balanceOf(msg.sender) >= offer.tokenAmount, "Insufficient token balance");

        // 수락자의 토큰을 제안자에게 전송
        require(casinoToken.transferFrom(msg.sender, offer.proposer, offer.tokenAmount), "Token transfer to proposer failed");
        // 제안자의 토큰을 수락자에게 전송
        require(casinoToken.transfer(msg.sender, offer.tokenAmount), "Token transfer to acceptor failed");

        offer.isActive = false;
        emit OfferAccepted(offerId, msg.sender);
    }

    /**
     * @notice 활성화된 제안 조회
     * @param offerId 조회할 제안 ID
     */
    function getOffer(uint256 offerId) external view returns (address proposer, uint256 amount, bool isActive) {
        TokenSwapOffer storage offer = swapOffers[offerId];
        return (offer.proposer, offer.tokenAmount, offer.isActive);
    }
}
