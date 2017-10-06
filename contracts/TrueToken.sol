/*
* TrueToken Smart Contract (c) by TrueMining
*
* TrueToken Smart Contract is licensed under a
* Creative Commons Attribution-NonCommercial 4.0 International License.
* You should have received a copy of the license along with this work.
* If not, see <https://creativecommons.org/licenses/by-nc/4.0/legalcode>
*/

pragma solidity ^0.4.11;

import '../zeppelin-solidity/contracts/token/ERC20.sol';
import '../zeppelin-solidity/contracts/math/SafeMath.sol';
import '../zeppelin-solidity/contracts/ownership/Ownable.sol';

contract TRT is ERC20, Ownable {
    using SafeMath for uint256;

    string public name = 'TrueToken';

    string public symbol;

    uint8 public decimals = 0;

    // time in seconds unixtime format
    uint public expired;

    uint256 public totalSupply;

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;

    /* Events of mint/burn tokens */
    event Burn(address indexed from, uint256 value);

    event Mint(address indexed to, uint256 value);

    function TRT(string _symbol, uint256 _totalSupply, uint _expired) {
        symbol = _symbol;
        expired = _expired;
        totalSupply = _totalSupply;
        balances[owner] = totalSupply;
    }

    /* Prevents accidental sending of Ether */
    function() payable {
        revert();
    }

    modifier isEnabled() {
        require(now < expired);
        _;
    }

    modifier isExpired() {
        require(now >= expired || msg.sender == owner);
        _;
    }

    function balanceOf(address _owner) constant returns (uint256 balance){
        return balances[_owner];
    }

    function soldTokens() constant returns (uint256 tokens) {
        return totalSupply.sub(balances[owner]);
    }

    function transfer(address _to, uint256 _value) isEnabled returns (bool ok){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) isEnabled returns (bool ok) {
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
    * @dev Destruction of the token after contract expired
    * @param _value The amount of tokens to burn
    * @return A boolean that indicates if the operation was successful.
    */
    function burn(uint256 _value) isExpired returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        return true;
    }

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _value The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _value) onlyOwner isEnabled returns (bool) {
        totalSupply = totalSupply.add(_value);
        balances[_to] = balances[_to].add(_value);
        Mint(_to, _value);
        return true;
    }
}
