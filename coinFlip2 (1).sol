// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// demonstrate imports fromm different files or locations online:
// https://docs.soliditylang.org/en/latest/path-resolution.html#imports
import "./coinFlip.sol";

// Same contract but this time we have a min bet of 1 ether - to demonstrate inheritance
contract CoinFlipMinBet is CoinFlip {

    // this is how to pass arguments to the base contract's constructor
    // in order to do this, we specify the constructor again with a modifier
    constructor(address adr) CoinFlip(adr) {}

    // player1 sets choice by giving a hash (hash = H(choice + nonce))
    function Bet(bytes32 hash) external override player1empty payable {
        // check if bet >= 1 ether
        require(msg.value >= 1 ether);

        // get address of player 1
        players[0] = payable(msg.sender);
        // save player1 selection
        sel.p1selection = hash;
        // store the bet amount
        bet = msg.value;
    }
}
