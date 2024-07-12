//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

//The ownable contract establishes the owner is the only one who can run
//a certain function by using a modifier.
contract Ownable {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier isOwnable() {
        require(msg.sender == owner, "not owner");
        _;
    }
}

//The main contract for depositing ETH
contract DepositBox is Ownable {
    //Create a mapping of wallet address to a balances variable which tracks
    //the deposit amount
    mapping(address => uint) balances;

    //Create two events that will be for deposits and withdrawals
    event Deposit(address addr, uint amount);
    event Withdraw(address addr, uint amount);

    //Receive deposits with fallback function
    receive() external payable {
        require(msg.value > 0, "invalid amount");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    //Check individual balance of user
    function checkMyBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    //Check the total balance of the contract deposits
    function totalBalance() public view returns (uint) {
        return address(this).balance;
    }

    //Individual withdrawals
    function withdraw() public {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "invalid withdrawal");
    }

    //Total withdrawal of deposits, restricted to the owner
    function withdrawAll() public isOwnable {
        address payable to = payable(msg.sender);
        balances[msg.sender] = 0;
        to.transfer(totalBalance());
    }
}
