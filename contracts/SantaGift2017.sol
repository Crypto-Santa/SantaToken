pragma solidity ^0.4.18;

import './SantaToken.sol';
import './SafeMath.sol';
import './Ownable.sol';

contract SantaGift2017 is Ownable {
    using SafeMath for uint256;

    uint public constant airdropSize = 12 ether;
    bool public isFinalized = false;

    address[] public airdropers;
    address[] public bids;

    mapping (address => bool) receivedBid;
    mapping (address => bool) receivedAirdrop;

    SantaToken public token;

    modifier notFinished() {
        require(!isFinalized);
        _;
    }

    event Finalized();

    function SantaGift2017() public {
        token = new SantaToken();
    }

    function finalize() onlyOwner notFinished external {
        creditAll();
        Finalized();
        isFinalized = true;
        token.transferOwnership(owner);
    }

    function bid() notFinished external returns (bool) {
        require(!receivedBid[msg.sender]);
        bids.push(msg.sender);
        receivedBid[msg.sender] = true;
    }

    function bidWithdraw() notFinished external returns (bool) {
        require(receivedBid[msg.sender]);
        receivedBid[msg.sender] = false;
        for (uint256 i = 0; i < bids.length; i++) {
            if (bids[i] == msg.sender) {
                bids[i] = bids[bids.length-1];
                bids.length--;
                return true;
            }
        }
    }

    function rollback(address _from) onlyOwner public returns (bool) {
        token.rollback(_from);
        return true;
    }

    function credit(address _to) onlyOwner notFinished public returns (bool) {
        require(!receivedAirdrop[_to]);

        airdropers.push(_to);
        uint256 amountToCredit = min(_to.balance, airdropSize);
        token.mint(_to, amountToCredit);
        receivedAirdrop[_to] = true;
        return true;
    }

    function creditAll() onlyOwner notFinished internal returns (bool) {
        for (uint256 i = 0; i < bids.length; i=i.add(1)) {
            if (!receivedAirdrop[bids[i]]) {
                credit(bids[i]);
            }
        }
        return true;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
      }

    function totalBids() external constant returns (uint256) {
        return bids.length;
    }

    function totalAirdropers() external constant returns (uint256) {
        return airdropers.length;
    }

    function issuedAirdropTokens() external constant returns (uint256) {
        return token.totalSupply();
    }

    function listAirdropers() external constant returns (address[]) {
        return airdropers;
    }

    function() payable public {
        revert();
    }
}
