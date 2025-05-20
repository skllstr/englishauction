// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./Token.sol";

contract EnglishAuction {
    address public owner;
    GruzdevToken public rewardToken;

    uint public endTime;
    uint public increment;
    bool public ended;

    uint public highestBid;
    address payable public highestBidder;

    uint public prizeAmount;

    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint bidAmount, uint prizeAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier auctionActive() {
        require(block.timestamp < endTime, "Auction ended");
        require(!ended, "Already finalized");
        _;
    }

    constructor(
        address _tokenAddress,
        uint _durationSeconds,
        uint _increment,
        uint _prizeAmount
    ) {
        owner = msg.sender;
        rewardToken = GruzdevToken(_tokenAddress);
        endTime = block.timestamp + _durationSeconds;
        increment = _increment;
        prizeAmount = _prizeAmount;
    }

    function remainingTime() external view returns (uint) {
        if (block.timestamp >= endTime) {
            return 0;
        } else {
            return endTime - block.timestamp;
        }
    }

    function bid() external payable auctionActive {
        require(msg.value >= highestBid + increment, "Bid too low");
        // Возвращаем предыдущему лидеру его средства
        if (highestBidder != address(0)) {
            highestBidder.transfer(highestBid);
        }
        highestBid = msg.value;
        highestBidder = payable(msg.sender);

        emit NewBid(msg.sender, msg.value);
    }

    function endAuction() external onlyOwner {
        require(!ended, "Already ended");
        require(block.timestamp >= endTime, "Too early to end");

        ended = true;

        // Победителю приз
        if (highestBidder != address(0)) {
            require(
                rewardToken.transferFrom(owner, highestBidder, prizeAmount),
                "Token transfer to winner failed"
            );
            // Владелец получает ETH
            payable(owner).transfer(highestBid);
        } else {
            // Если никто не делал ставки — владелец может вернуть себе токены вручную
        }

        emit AuctionEnded(highestBidder, highestBid, prizeAmount);
    }
}
