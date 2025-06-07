// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Auction {

    uint256 public currentPrice;
    address public currentBest;
    address public owner;
    uint256 public end;
    mapping(address => uint256) public balances;
    
    constructor(uint256 startingPrice, uint256 duration) {
        owner = msg.sender;
        currentPrice = startingPrice;
        end = block.number + duration;
    }

    function bid() public payable {
        require(msg.value > currentPrice, "Bid higher");
        require(block.number <= end, "Auction has ended");

        balances[currentBest] += currentPrice;

        currentBest = msg.sender;
        currentPrice = msg.value;
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Transfer failed");
    }

    function claim() public {
        require(msg.sender == currentBest, "Only winner");
        require(block.number > end, "Wait until the end");

        address payable previousOwner = payable(owner);
        owner = msg.sender;

        (bool success, ) = previousOwner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}