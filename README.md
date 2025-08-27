# Raffle Smart Contract

Verified Contract address on Etherscan Sepolia Testnet
```
0x3622232e377ADBdA9df4f5Da9010E87737186Dc3
```

A decentralized raffle system built with Foundry for Ethereum blockchain development. This project demonstrates smart contract development best practices using Solidity and the Foundry toolkit.

## About

This project implements a raffle smart contract system on the Ethereum blockchain, providing a transparent and decentralized way to conduct fair lottery-style drawings. Built with **Foundry**, this project leverages modern Ethereum development tools for testing, deployment, and interaction.

## Features

- **Decentralized Raffle System**: Fair and transparent lottery mechanism
- **Smart Contract Security**: Built with Solidity best practices
- **Comprehensive Testing**: Full test suite using Forge
- **Gas Optimization**: Efficient contract design for minimal gas consumption
- **Local Development**: Easy testing with Anvil local node


## Tech Stack

- **Solidity** (98.7%) - Smart contract programming language
- **Foundry** - Development framework and toolkit
- **Forge** - Testing framework
- **Cast** - Command-line tool for blockchain interaction
- **Anvil** - Local Ethereum node for development


## Prerequisites

Before you begin, ensure you have the following installed:

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/)


## Installation

1. **Clone the repository**

```bash
git clone https://github.com/Satya-Sherkar/Raffle.git
cd Raffle
```

2. **Install dependencies**

```bash
forge install
```


## Usage

### Build the Project

Compile all smart contracts:

```bash
forge build
```


### Run Tests

Execute the test suite:

```bash
forge test
```

For verbose output:

```bash
forge test -vvv
```


### Code Formatting

Format Solidity code:

```bash
forge fmt
```


### Gas Analysis

Generate gas usage snapshots:

```bash
forge snapshot
```


### Local Development

Start a local Ethereum node:

```bash
anvil
```


### Deployment

Deploy to a network (replace with your details):

```bash
forge script script/DeployRaffle.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
```


### Blockchain Interaction

Use Cast for various blockchain operations:

```bash
cast <subcommand>
```


## Project Structure

```
Raffle/
├── src/                    # Smart contracts
├── script/                 # Deployment scripts
├── test/                   # Test files
├── lib/                    # Dependencies
├── Makefile               # Build automation
└── foundry.toml           # Foundry configuration
```


## Smart Contract Architecture

The raffle system typically includes:

- **Entry Management**: Handle participant entries
- **Random Number Generation**: Secure randomness for winner selection
- **Prize Distribution**: Automated prize distribution to winners
- **Administrative Controls**: Contract management functions


## Testing

This project includes comprehensive tests covering:

- Contract deployment
- Entry functionality
- Winner selection logic
- Edge cases and error handling
- Gas optimization verification

Run specific tests:

```bash
forge test --match-test testFunctionName
```


## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Security Considerations

- Always audit smart contracts before mainnet deployment
- Use established patterns for random number generation
- Implement proper access controls
- Consider reentrancy protection where applicable


## Getting Help

- **Foundry Documentation**: https://book.getfoundry.sh/
- **Foundry Help**: Run `forge --help`, `anvil --help`, or `cast --help`
- **Issues**: Open an issue in this repository for project-specific questions


## License

This project is open source. Please check the repository for license details.

***

**Built with ❤️ using Foundry**


