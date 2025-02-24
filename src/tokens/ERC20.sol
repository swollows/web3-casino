// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract ERC20 {
    string private name;
    string private symbol;
    string private version;
    address private token_owner;
    bool private is_paused;
    bytes32 constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 DOMAIN_SEPERATOR;

    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint) private nonce;

    constructor (string memory _name, string memory _symbol, string memory _version) {
        name = _name;
        symbol = _symbol;
        version = _version;
        token_owner = msg.sender;
        is_paused = false;
        DOMAIN_SEPERATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            block.chainid,
            address(this)
        ));
    }

    function pause() public {
        require(msg.sender == token_owner, "Only owner can pause token");
        
        if (is_paused) {
            _unpause();
        }
        else {
            _pause();
        }
    }

    function _pause() private {
        is_paused = true;
    }

    function _unpause() private {
        is_paused = false;
    }

    function transfer(address _to, uint256 _value) public {
        require(is_paused == false, "Token is paused");
        balances[_to] += _value;
    }
    
    function approve(address _spender, uint256 _value) public {
        _approve(msg.sender, _spender, _value);
    }

    function _approve(address _owner, address _spender, uint256 _value) public {
        allowances[_owner][_spender] = _value;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return allowances[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public {
        require(is_paused == false, "Token is paused");
        require(allowances[_from][_to] > _value, "Allowance exceeded");
        balances[_from] -= _value;
        balances[_to] += _value;
    }

    function permit(address _owner, address _spender, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) public {
        require(block.timestamp < _deadline, "Permit: Expired");
        bytes32 hash = keccak256(abi.encode(
            PERMIT_TYPEHASH,
            _owner,
            _spender,
            _value,
            nonces(_owner),
            _deadline
        ));
        bytes32 digest = _toTypedDataHash(hash);
        address recoveredAddress = ecrecover(digest, _v, _r, _s);

        require(recoveredAddress == _owner, "INVALID_SIGNER");
        
        _approve(_owner, _spender, _value);
        nonce[_owner]++;
    }

    function _toTypedDataHash(bytes32 _hash) public view returns (bytes32){
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPERATOR,
            _hash
        ));

        return digest;
    }

    function nonces(address _owner) public view returns (uint256) {
        return nonce[_owner];
    }
}