// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// contract used for counting wins for each player
contract winCount {
    
    uint256 public wins1 = 0;
    uint256 public wins2 = 0;

    function win1() public {
        wins1 ++;
    }

    function win2() public {
        wins2 ++;
    }
}