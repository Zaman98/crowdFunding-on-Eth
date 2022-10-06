/ SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract crowdFunding{
    uint public deadline; // => timestamp
    address payable admin;
    uint public goal;
    uint public NoOfContributors;
    uint public minContribution;
    uint public raisedAmount;
    mapping(address => uint) public funders;

    struct Request{
        string description;
        address payable recipient;
        uint amount;
        bool completed;
        uint NoOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests;
    uint public NoOfRequests;

    event goalReached(string _goalreached);

    constructor(uint _goal, uint _minContribution, uint _deadline){
        admin = payable(msg.sender);
        //startBlock = block.number;
        goal = _goal;
        minContribution = _minContribution;
        deadline = block.timestamp + _deadline; 
    }

    function fund() public payable{
        require(block.timestamp < deadline, "deadline has passed");
        require(msg.value >= minContribution, "please send at least the minimun amount");
        
        if( funders[msg.sender] ==0){
        NoOfContributors++;
        }
        funders[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    receive()external payable{
        fund();
    } 

    function returnBalance() public view returns(uint){
        return address(this).balance;
    }

    function getRefund() public{
        require(block.timestamp > deadline && raisedAmount < goal, "the campaign has not yet crossed the deadline");
        require(funders[msg.sender] > 0);
        uint value = funders[msg.sender];
        funders[msg.sender] = 0;
        payable(msg.sender).transfer(value);
    }

    function createRequest(string memory _description, uint _value, address payable _recipient) public {
        require(msg.sender == admin, "only admin is allowed to use this function");
        Request storage newRequest = requests[NoOfRequests];
        NoOfRequests++;

        newRequest.description = _description;
        newRequest.amount = _value;
        newRequest.recipient = _recipient;
        newRequest.completed = false;
        newRequest.NoOfVoters = 0;
    }

    function voteRequest(uint _requestIndex) public{
        require(funders[msg.sender] > 0, "only contributors can vote");
        Request storage thisRequest = requests[_requestIndex];

        require(thisRequest.voters[msg.sender] == false, "you have already voted on this request");
        thisRequest.voters[msg.sender] == true;
        thisRequest.NoOfVoters++;
    }

    function makePayment(uint _requestIndex) public {
        require(msg.sender == admin, "only owner can make the payment");
        require(raisedAmount >= goal, "you have not yet reached the goal");
        Request storage thisRequest = requests[_requestIndex];
        //require(thisRequest.completed = false, "you have already made this payment earlier");
        require(thisRequest.NoOfVoters > (NoOfContributors/2), "the majority has not yet voted in favour of the request");
        payable(thisRequest.recipient).transfer(thisRequest.amount);
        thisRequest.completed = true;
    }
}
