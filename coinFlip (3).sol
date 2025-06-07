// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Key concepts introduced:
// - using a second contract from within a contract
//   https://www.zupzup.org/smart-contract-interaction/
// - datatypes: structures, mappings
//   https://docs.soliditylang.org/en/latest/types.html
// - events
//   https://docs.soliditylang.org/en/latest/contracts.html?#events
// - vis specifiers/modifiers: payable, public, external, pure, custom etc
//   https://docs.soliditylang.org/en/latest/cheatsheet.html?#function-visibility-specifiers
// - off chain function calls (calls vs transactions)
//   https://ethereum.stackexchange.com/questions/765/what-is-the-difference-between-a-transaction-and-a-call
// - using cryptographic hash for commitments
//   https://crypto.stackexchange.com/questions/6790/commitment-scheme-using-hash-functions
// - function overloading
//   https://docs.soliditylang.org/en/latest/contracts.html?#function-overloading
// - contract inheritance
//   https://docs.soliditylang.org/en/latest/contracts.html?#inheritance

// "interface" of contract used for counting wins for each player
contract winCount {
    function win1() public {}
    function win2() public {}
}


// second (main) contract for coinfip that uses the first contract
contract CoinFlip {

    // link to second contract
    winCount counts;

    // structure for player selections
    struct selections {
        bytes32 p1selection;
        bool p2selection;
    }
    selections public sel; // "instantiate" the struct

    // mapping from integers to addresses
    mapping(uint => address payable) public players;

    uint256 public bet;
    uint256 public expiration = 2**256-1; // set to max

    // event to notify listeners of the end of the game
    // it would be a good idea to show how to listen to events on the front-end using web3
    event gameEnds(
        address winner,
        uint256 amount
    );

    // modifiers to check if players have already played (i.e. address not zero)
    modifier player1empty() {
        require(players[0] == payable(0x0));
        _;
    }

    modifier player2empty() {
        require(players[1] == payable(0x0));
        _;
    }

    // constructor function used to initialize values
    constructor(address adr) {
        // set player addresses to zero - this is not necessary
        players[0] = payable(0x0);
        players[1] = payable(0x0);
        // set counts by linking to counter contract
        counts = winCount(adr);
    }

    // get the hash only using solidity - Warning: don't run this on chain as your choice will be visible!
    // this is using the "pure" modifier as it doesn't read or write to storage
    function getHash(bool choice, uint256 nonce) external pure returns (bytes32) {
        return keccak256(abi.encode(choice, nonce));
    }

    // player1 sets choice by giving a hash (hash = H(choice + nonce))
    // note the virtual keyword which allows this function to be overwritten (inheritance)
    function Bet(bytes32 hash) external virtual player1empty payable {
        // check if bet > 0
        require(msg.value > 0);

        // get address of player 1
        players[0] = payable(msg.sender);
        // save player1 selection
        sel.p1selection = hash;
        // store the bet amount
        bet = msg.value;
    }

    // player2 sets choice
    // notice how we overload the function here:
    // the same function name but with different arguments calls a different function
    function Bet(bool choice) external player2empty payable {
        // check if player 1 made their choice
        require(players[0] != payable(0x0));
        // check if the bet is same as player 1
        require(msg.value == bet);

        // save address of player 2
        players[1] = payable(msg.sender);
        // save player 2 choice
        sel.p2selection = choice;
        // set expiration date
        expiration = block.timestamp + 24 seconds;
    }

    function reset() internal {
        // reset contract variables for repeated bets
        bet = 0;
        players[0] = payable(0x0);
        players[1] = payable(0x0);
        expiration = 2**256-1;
    }

    // find out who won, player1 provides choice(0/1) and nonce(32 byte unsigned int) that match stored hash
    // note that the address of player doesn't need to be checked here, as only player should know the correct nonce
    function reveal(bool choice, uint256 nonce) external {
        // check if H(choice + nonce) is equal to stored hash
        require(keccak256(abi.encode(choice, nonce)) == sel.p1selection);
        // check if second player played
        require(players[1] != address(0x0));
        // check if the bet hasn't expired
        require(block.timestamp < expiration);

        // players made the same choice => 2 wins
        if (sel.p2selection == choice) {
            // player2 gets ether
            players[1].transfer(address(this).balance);
            // update wins
            counts.win2();
            // emit event
            emit gameEnds(players[1], bet);
        }
        // players made different choices => 1 wins
        else {
            // player1 gets ether
            players[0].transfer(address(this).balance);
            // update wins
            counts.win1();
            // emit event
            emit gameEnds(players[0], bet);
        }

        // reset values
        reset();
    }

    // player 1 can cancel bet if player2 hasn't played yet
    function cancel() external {
        // check if it is player1
        require(msg.sender == players[0]);
        // check if player2 hasn't played yet
        require(players[1] == address(0x0));

        // player1 gets bet back
        players[0].transfer(address(this).balance);

        // reset values
        reset();
    }

    // if player1 doesn't reveal their choice before the bet expires, player2 can timeout and win
    function timeout() external {
        // check if it has expired
        require(block.timestamp >= expiration);

        // player2 gets both bets
        players[1].transfer(address(this).balance);

        // update wins
        counts.win2();

        // emit event
        emit gameEnds(players[1], bet);

        // reset values
        reset();
    }
}
