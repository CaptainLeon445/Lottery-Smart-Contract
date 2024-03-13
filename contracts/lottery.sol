// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery{
    address payable[] public players;
    address public owner;
    address payable public winner;
    
    enum State {Open, Closed}
    State public lotteryStatus;

    constructor(){
        owner = msg.sender;
        lotteryStatus = State.Open;
    }

    receive() external payable depositValue lotteryState { 
        players.push(payable (msg.sender));
    }
    
    fallback() external payable { }

    modifier onlyOwner(){
        require(owner == msg.sender, "Only contract owner can have access to this resoure");
        _;
    }

    modifier lotteryState(){
        require(lotteryStatus == State.Open, "Lottery is closed.");
        _;
    }

     modifier depositValue(){
        require(msg.value == 0.1 ether, "You can only send 0.1 ether value.");
        _;
    }

    modifier maxPlayer(){
        require(players.length >= 3, "You can only select winner after at least 3 players have played.");
        _;
    }

    function getPlayers() public onlyOwner view returns (address payable[] memory){
        return players;
    }

    function getBalance() public onlyOwner view returns (uint){
        return address(this).balance;
    }

    function getRandomNumber() public view returns (uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public onlyOwner maxPlayer lotteryState{
        uint randomNumber = getRandomNumber();

        uint index = randomNumber % players.length;
        winner = players[index];

        winner.transfer(getBalance());
        lotteryStatus = State.Closed;
    }

    function resetLottery() public onlyOwner maxPlayer{
        players = new address payable[](0);
        winner = payable (address(0));
        lotteryStatus = State.Open;
    }
} 