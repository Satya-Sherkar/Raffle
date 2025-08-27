-include .env

.PHONY: all test deploy

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

deploy-sepolia:
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $(SEPOLIA_RPC_URL) --account account1 --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv