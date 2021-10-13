pragma solidity >=0.7.0;


contract Auction {
    
    // state variables 
    address payable public beneficiary;
    uint public auctionEndTime; 
    
    // current state of the auction
    address highestBidder;
    uint highestBid;
    bool ended;
    
    // this is going to be used to keep track of the pending withdrawals
    mapping(address => uint) pendingReturns;
    
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount); 
    
    // deployed to beneficiary address and how long the auction will run for
    constructor(uint _biddingTime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime; // from now to the point of when we auctioned something
    } 
    

    // revert(if bidding period is over)
    // if bid is not higher than the highest bid, send money back
    // emit HighestBidIncreased  

    function bid() public payable {
       if(block.timestamp > auctionEndTime) revert('Sorry, the auction has ended!');   
       if (msg.value <= highestBid) revert('The bid is not high enough!'); 
       if(highestBid != 0) {
           pendingReturns[highestBidder] += highestBid;
       }
       highestBidder = msg.sender;
       highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }
    
    // withdraw bids that were overbid
    // function withdrawal() return bids based on the library of keys and values (pendingReturns)
    // if the amount exists, we want to set it to 0 so they can only do one withdrawal
    function withdraw() payable public returns(bool) {
          uint amount = pendingReturns[msg.sender];   
          if(amount > 0) {
              pendingReturns[msg.sender] = 0;     // then pending returns of the msg.sender should be reset
          }
          // to further protect
          if(!payable(msg.sender).send(amount)) { // if not payable of the msg.sender
              pendingReturns[msg.sender] = amount; // pending returns of msg.sender should be equal the amount
          }
          return true;
    }
          
    // ends auction 
    //sends highest bid to beneficiary
    // I can add more conditions like if the block.timestamp is less than the auction end time revert 
    function auctionEnd() public {
        
        if(block.timestamp < auctionEndTime) revert('The auction has not ended yet!');
        if(ended) revert('The aucion is already over!');
        ended = true;
        emit AuctionEnded(highestBidder, highestBid); 
        beneficiary.transfer(highestBid);

    }    
}





