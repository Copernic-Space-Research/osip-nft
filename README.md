# OSIP-NFT

## Overview
This project aims to create a proof-of-concept smart contract to attach open science projects to NFTs to extend them with ownsership, managing and financing tools (like dapps);

## Features
- Attach open science projects to NFTs
- Instant listing of NFTs  

## Prerequisites
- [Node.js](https://nodejs.org/en/)
- [pnpm](https://pnpm.io/)


## Configuration
This project uses Hardhat with Solidity version 0.8.21. The configuration can be found in `hardhat.config.ts`.

## Testing

To run tests, navigate to the project directory and run:

```shell
pnpm test
```

Tests are simple demonstration how to interact with contract via typechain generated artifacts and ethersjs.

It illustrates the flow of user creating project in form of token, and then it is possible to transfer or sell it; Having tokenized project allows users implement vast variety of applications. These contacts can be interacted with from diffrent web pages and many other devices. We tend to use this contracts for marketplce dapp. 

## License
Please see the [LICENSE](LICENSE) file for more details.

---

## Contributing

If you would like to contribute, please submit an issue or fork the repository and submit a pull request.

