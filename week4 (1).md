# **Smart Contracts: Coin Guess II**

In this worksheet we will extend our simple coin guessing smart contract from last week to showcase some more advanced features of Solidity. You might find these features useful later when working on your projects.

## Data structures

Until now, we have been using simple variables in our contract. Let’s see some data structures! You might find the documentation useful (<https://docs.soliditylang.org/en/latest/types.html>).

### Question 1

Start by first declaring a **structure** to hold the player selections (P1’s commitment and P2’s guess). Alter your contract so that it uses this struct instead of just plain variables.

### Question 2

Now let’s do something similar for the player addresses. Instead of keeping them in individual variables, let’s use a **mapping** to store them. Again, alter your code so that it uses the mapping instead of just plain addresses.

<details>
<summary>Hint:</summary>
You can use a uint as ket, to represent a player’s numbers (0/1)
</details>

## Contract Reset

Currently the contract can only be used correctly once. If we wanted to have multiple bets, our only option is to deploy multiple contracts. This is very inefficient, so let's fix it.

### Question 3

Create a reset function that sets the variables in the contract to their initial values. Alter the *reveal*, *cancel* and *timeout* functions to call the reset function so that the contract can be reused many times.

## Constructor

A constructor (<https://docs.soliditylang.org/en/latest/contracts.html#constructors>) is a special function which is called once when the contract is deployed. All variables take some initial values (see <https://ethereum.stackexchange.com/a/40571> for more details) but it could be a good idea to initialize some of them using the constructor.

### Question 4

Initialize the values of the player addresses in the constructor.

## Function Overloading

A cool feature of Solidity is function overloading. In our contract the two players can bet, but we call the function that each player uses a different name. As the functions have different input, Solidity allows us to overload the same name thus having multiple function definitions using the same function name. For more details check the documentation (<https://docs.soliditylang.org/en/latest/contracts.html?highlight=constructor#function-overloading>).

### Question 5

Let’s try this by renaming both our makeBet and  takeBet functions into Bet.

## Visibility Specifiers/Modifiers

We have been using visibility specifiers and modifiers in our contract so far, but we haven’t really talked about them. Check out the following link for a brief overview:
<https://docs.soliditylang.org/en/latest/cheatsheet.html?#function-visibility-specifiers>

Now let’s create a few custom modifiers for our functions. We check in multiple places if the players have already played, let’s change our contract to do these checks using modifiers.

### Question 6

Define the modifiers, and add them to our functions (remember to also remove the require statements).

## Events

Now let’s look at events (<https://docs.soliditylang.org/en/latest/contracts.html?#events>). Events allow us to add entries to the transaction’s log on the blockchain. In practice, this allows us to store useful data on the blockchain for a fraction of the cost of normal storage. The downside is that this data is **not accessible from within contracts**, but can only be accessed from outside the blockchain (e.g. from a web application). The main  use of event logs is to let applications that need to be notified of changes in the state of a contract know that something has happened without them having to query contracts manually.

*Aside: For some more technical information on the way storage works on Ethereum see: <https://www.doubloin.com/learn/data-stored-ethereum-blockchain>. And for more information on how events work in the EVM see: <https://medium.com/mycrypto/understanding-event-logs-on-the-ethereum-blockchain-f4ae7ba50378>.* ***These articles are a bit more technical so feel free to skip them, only look at them if you are interested in the inner workings of the EVM.***

### Question 7

Create an event with two fields, the address of the winner and the amount of the bet. Then modify the reveal and timeout functions to emit an event every time a winner is determined.

## Contract-to-contract interactions

There are a few ways to interact with other contracts from within a contract but here we will focus on “dependency-injection” which is the safest and recommended method. In plain English, dependency-injection means that we provide the function definitions of a deployed contract we want to interact with and then we instantiate it within our contract by providing the address on which this contract resides. At that point, we are able to call functions of the second contract from our current contract. For more information check this article (<https://www.zupzup.org/smart-contract-interaction/>).

Let’s see how this works by first defining another contract in a new .sol file. This contract will be responsible for counting the number of times each player won. So, it should contain two public unsigned integers - one for each player's count, and two functions to increase those numbers.

### Question 8

Fill in the gaps to complete the contract:

    // contract used for counting wins for each player
    contract winCount {
        // two variables, one for each player’s count
        [type] wins1 = [initial value];
        [type] wins2 = [initial value];
        // two functions, each one to increase one of the counts
        function win1() public {
            [commands]
        }
        function win2() public {
            [commands]
        }
    }

Deploy this contract and note its address as we will need it later.

### Question 9

Now that we have our second contract, we need to write an “interface” on our original contract to define the available functions. This can be done by adding the following to our solidity file before our main (CoinFlip) contract:

    // "interface" of contract used for counting wins for each player
    contract winCount {
        function win1() public {}
        function win2() public {}
    }

### Question 10

This tells our contract how to interact with this new contract. The next thing we need to do is instantiate it in a variable in our current contract. The type of this variable should be `winCount` (the same as the contract). Define a new variable that will hold a reference to the new contract.

### Question 11

Now instantiate this contract in the constructor by passing as an argument the address.

<details>
<summary>Hint:</summary>
This can be done by calling:

    winCount(address);
</details>

### Question 12

Now the only thing left is to use this contract to keep track of each player's wins. Modify the reveal and timeout functions so that each time a player wins one of the counters in winCount is incremented.

*Congratulations! You have managed to call functions of a contract from a different contract. This can be useful for separating data from logic (like we did here) or even creating contracts that are "upgradable".*

## Bonus: Contract Inheritance

The last thing we are going to look at, is contract inheritance. This allows us to create a new contract by easily modifying a few things in an existing contract. More information regarding inheritance can be found here (<https://docs.soliditylang.org/en/latest/contracts.html?#inheritance>).

We will use inheritance to create a new contract based on CoinFlip, that has a minimum betting amount. The first thing we need to do is alter a few things in the original contract. More specifically, we need to label the functions that new contracts are allowed to modify. We can do this using the `virtual` modifier.

### Bonus Question 13

Label the function Bet in CoinFlip as virtual:

### Bonus Question 14

Now we can go ahead and create a new contract, let’s call it CoinFlipMinBet. Create a new .sol file and import the previous contract file into it (more information about imports can be found in the documentation <https://docs.soliditylang.org/en/latest/path-resolution.html#imports>).

Use the template below for our new contract:

    // Same contract but this time we have a min bet of 1 ether - to demonstrate inheritance
    contract CoinFlipMinBet is CoinFlip {
        // this is how to pass arguments to the base contract's constructor
        // in order to do this, we specify the constructor again with a modifier
        constructor(address adr) CoinFlip(adr) {}
        
        // player1 sets choice by giving a hash (hash = H(choice + nonce))
        function Bet(bytes32 hash) external override player1empty payable {
            [commands]
        }
    }

- Notice the contract declaration (`contract CoinFlipMinBet is CoinFlip`). This tells Solidity that there is inheritance from the CoinFlip contract.
- I have written the constructor for you as it’s a bit tricky to implement. Basically, we use the previous contract’s constructor as a modifier, for more information check the documentation (<https://docs.soliditylang.org/en/latest/contracts.html?#arguments-for-base-constructors>).
- Finally notice how the override modifier is used to label the `Bet` function as a function that is overwritten. This function should match the one label as virtual in the original contract.

### Bonus Question 15

Finally, complete the Bet function so that there is a minimum bet amount of 1 Ether.
