pragma solidity ^0.4.24;

contract SportBet {
    
    struct Bet {
        uint id;
        string description;
        address user1;
        address user2;
        uint amount;
        bool user1Transfer;
        bool user2Transfer;
        bool canceled;
        bool finished;
        uint betBalance;
    }
    
    address public judge;
    mapping (uint => Bet) public bets;
    
    constructor () public {
        judge = msg.sender;
    }
    
    modifier onlyJudge {
        require(msg.sender == judge);
        _;
    }
    
    function createBet (uint _id, string _description, address _user2) public payable {
        Bet memory _bet = Bet({
            id: _id,
            description: _description,
            user1: msg.sender,
            user2: _user2,
            amount: msg.value,
            user1Transfer: true,
            user2Transfer: false,
            canceled: false,
            finished: false,
            betBalance: msg.value
        });
        bets[_id] = _bet;
    }
    
    function acceptBet (uint _id) public payable {
        Bet storage _bet = bets[_id];
        require(_bet.user2 == msg.sender && !_bet.finished);
        require(_bet.amount == msg.value && !_bet.canceled);
        _bet.user2Transfer = true;
        _bet.betBalance = _bet.betBalance + msg.value;
    }
    
    function cancelBet (uint _id) public {
        Bet storage _bet = bets[_id];
        require(msg.sender == _bet.user1 && !_bet.user2Transfer);
        require(!_bet.canceled && !_bet.finished);
        _bet.canceled = true;
        _bet.user1.transfer(_bet.amount);
    }
    
    function finishBet (uint _id, address _winner) public onlyJudge {
        Bet storage _bet = bets[_id];
        require(!!_bet.user2Transfer && !_bet.finished);
        uint amount = _bet.amount * 2;
        _winner.transfer(_bet.amount);
        _bet.betBalance = _bet.betBalance - amount;
        _bet.finished = true;
    }
    
}