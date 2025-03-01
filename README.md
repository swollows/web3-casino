## Jonathan's Web3 Casino

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test <TESTCASE_NUMBER>
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
# For Anvil
$ source .env && forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL_FOR_LOCAL --private-key $PRIVATE_KEY_FOR_LOCAL

# For Base Sepolia Testnet
$ forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL_FOR_BASE_SEPOLIA --private-key $PRIVATE_KEY_FOR_BASE --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv

```