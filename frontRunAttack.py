from web3 import Web3
from solcx import compile_files

w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545")) 
# make sure that auto mining is disabled in hardhat config, e.g.:
# networks: {
#     hardhat: {
#        mining: {
#            auto: false,
#            interval: 1000
#        }
#     }
# }
accounts = w3.eth.accounts
w3.eth.default_account = accounts[0]

# compile contract
compile = compile_files(["frontRun.sol"], output_values=["abi", "bin"])
abi = list(compile.values())[0]["abi"]
bin = list(compile.values())[0]["bin"]

# instantiate contract
FreeEth = w3.eth.contract(abi=abi, bytecode=bin)

# deploy contract
tx_hash = FreeEth.constructor().transact()
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
deployedFreeEth = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

# test contract
tx_hash = deployedFreeEth.functions.deposit().transact({ "value": Web3.toWei(1000, "ether") })
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

tx_hash_1 = deployedFreeEth.functions.withdraw().transact({ "from": accounts[1], "gasPrice": w3.eth.gas_price })
tx_hash_2 = deployedFreeEth.functions.withdraw().transact({ "from": accounts[2], "gasPrice": w3.eth.gas_price * 2 })

tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash_1)
print("Account 1 transaction index: ", tx_receipt["transactionIndex"]) # should be 1
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash_2)
print("Account 2 transaction index: ", tx_receipt["transactionIndex"]) # should be 0

print("Account 1 balance: ", w3.eth.get_balance(accounts[1]))
print("Account 2 balance: ", w3.eth.get_balance(accounts[2]))

