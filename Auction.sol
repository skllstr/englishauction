// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./Token.sol"; // Импортируем токен (предположим, что это ERC20-подобный контракт)

contract EnglishAuction {
    // Владелец аукциона
    address public owner;

    // Текущая максимальная ставка и адрес пользователя
    uint public highestBid;
    address public highestBidder;

    // Время окончания аукциона
    uint public endTime;

    // Минимальный шаг ставки
    uint public increment;

    // Токен, в котором проводим аукцион
    KittyToken public token;

    // Завершён ли аукцион
    bool public ended;

    // События
    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // Модификатор: только владелец
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    // Модификатор: аукцион ещё не завершён
    modifier auctionActive() {
        require(block.timestamp < endTime, "Auction already ended");
        require(!ended, "Auction already ended");
        _;
    }

    constructor(address _tokenAddress, uint _durationSeconds, uint _increment) {
        owner = msg.sender;
        token = KittyToken(_tokenAddress);
        endTime = block.timestamp + _durationSeconds;
        increment = _increment;
    }

    // Функция для ставок
    function bid(uint amount) external auctionActive {
        require(amount >= highestBid + increment, "Bid too low");

        // Перевод токенов от участника на контракт
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Возврат предыдущей ставки (если была)
        if (highestBidder != address(0)) {
            require(token.transfer(highestBidder, highestBid), "Refund failed");
        }

        // Обновляем данные
        highestBid = amount;
        highestBidder = msg.sender;

        emit NewBid(msg.sender, amount);
    }

    // Завершение аукциона
    function endAuction() external onlyOwner {
        require(!ended, "Auction already ended");
        require(block.timestamp >= endTime, "Auction not yet ended");

        ended = true;

        // Перевод выигрыша владельцу
        if (highestBid > 0) {
            require(token.transfer(owner, highestBid), "Payout failed");
        }

        emit AuctionEnded(highestBidder, highestBid);
    }
}
