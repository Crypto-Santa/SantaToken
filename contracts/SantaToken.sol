pragma solidity ^0.4.18;
import "./PausableToken.sol";

contract SantaToken is PausableToken {
    string public constant symbol = "SANTA";
    string public constant name = "Santa token";
    uint8 public constant decimals = 18;

    bool public paused = true;
    bool public mintingFinished = false;
    bool public recallFinished = false;
    bool public rollbackFinished = false;

    event Mint(address indexed to, uint256 amount);
    event Recall(address indexed to, uint256 amount);
    event Rollback(address indexed to);

    event MintFinished();
    event RecallFinished();
    event RollbackFinished();

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier canRecall() {
        require(!recallFinished);
        _;
    }

    modifier canRollback() {
        require(!rollbackFinished);
        _;
    }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    function recall(address _from, uint _prc) onlyOwner canRecall public returns (bool) {
        require(_prc >= 0);
        require(_prc <= 100);

        uint256 recallAmount = balances[_from].mul(_prc).div(100);
        balances[_from] = balances[_from].sub(recallAmount);
        balances[owner] = balances[owner].add(recallAmount);
        Recall(_from, recallAmount);
        Transfer(_from, owner, recallAmount);
        return true;
    }

    function rollback(address _from) onlyOwner canRollback public returns (bool) {
        recall(_from, 100);
        Rollback(_from);
        return true;
    }

    //
    // Finalization
    //

    function finishMinting() onlyOwner public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

    function finishRecall() onlyOwner public returns (bool) {
        recallFinished = true;
        RecallFinished();
        return true;
    }

    function finishRollback() onlyOwner public returns (bool) {
        rollbackFinished = true;
        RollbackFinished();
        return true;
    }

}
