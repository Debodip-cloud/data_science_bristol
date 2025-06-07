from web3 import Web3
from solcx import compile_files

w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
w3.eth.default_account = w3.eth.accounts[0]

# compile contract
compile = compile_files(["storage.sol"], output_values=["abi", "bin"])
abi = list(compile.values())[0]["abi"]
bin = list(compile.values())[0]["bin"]

Storage = w3.eth.contract(abi=abi, bytecode=bin)
tx_hash = Storage.constructor(1234).transact()
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
storageAddress = tx_receipt.contractAddress
deployedStorage = w3.eth.contract(address=storageAddress, abi=abi)

print(w3.eth.getStorageAt(storageAddress, 0)) # in bytes
print(int.from_bytes(w3.eth.getStorageAt(storageAddress, 0), "big")) # in int