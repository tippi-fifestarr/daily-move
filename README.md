# Daily Move: Learning Move Programming Step by Step

This repository contains a collection of Move code snippets created by @gregnazario, designed to help you learn Move programming piece by piece. Each snippet demonstrates best practices and common patterns in Move development.

## Getting Started with Move Development

This guide will walk you through setting up your environment, creating an account, and deploying Move modules to the Aptos blockchain.

### 1. Setup Your Environment

#### Install the Aptos CLI

First, you need to install the Aptos CLI:

**macOS (using Homebrew):**
```bash
brew install aptos
```

**Using cargo (Rust package manager):**
```bash
cargo install --git https://github.com/aptos-labs/aptos-core.git aptos
```

**Using the pre-built binaries:**
Visit the [Aptos CLI releases page](https://github.com/aptos-labs/aptos-core/releases) and download the appropriate binary for your system.

Verify the installation:
```bash
aptos --version
```

### 2. Create and Fund a Devnet Account

Initialize a new account on the Aptos devnet:

```bash
aptos init
```

Follow the prompts, accepting the defaults by pressing Enter. This will:
- Connect to the devnet network
- Create a new account with a private key
- Fund the account with test tokens

You should see a success message with your account address:
```
Aptos CLI is now set up for account 0x9ec1cfa30b885a5c9d595f32f3381ec16d208734913b587be9e210f60be9f9ba as profile default!
```

### 3. Verify Your Account on the Explorer

1. Copy your account address from the success message
2. Go to the [Aptos Explorer](https://explorer.aptoslabs.com/?network=devnet)
3. Make sure you're on the "Devnet" network (check the top right corner)
4. Paste your address in the search bar
5. Verify that your account has been created and funded with test tokens

### 4. Deploy a Move Module

You can deploy any of the snippets in this repository. Here's how to deploy a specific snippet:

```bash
aptos move publish --named-addresses deploy_addr=default --package-dir snippets/[SNIPPET_DIRECTORY]
```

For example, to deploy the user-profile snippet:

```bash
aptos move publish --named-addresses deploy_addr=default --package-dir snippets/user-profile
```

When prompted about gas fees, type 'y' to confirm.

### 5. Interact with Your Module

After deployment, you can interact with your module using the Aptos CLI:

```bash
aptos move run --function-id 'default::[MODULE_NAME]::[FUNCTION_NAME]' --args '[ARG_TYPE]:[ARG_VALUE]'
```

For example, to initialize a user profile:

```bash
aptos move run --function-id 'default::user_profile_examples::initialize_default_profile'
```

### 6. View Your Module on the Explorer

1. Go to the [Aptos Explorer](https://explorer.aptoslabs.com/?network=devnet)
2. Search for your account address
3. Click on the "Modules" tab to see your deployed modules
4. Click on a module to view its code and resources

## Available Snippets

This repository contains various snippets demonstrating different aspects of Move programming:

- **user-profile**: A user profile system with privacy controls
- **composable-nfts**: Demonstrates composable NFT implementation
- **controlled-mint**: Shows controlled minting of tokens
- **data-structures**: Implementations of various data structures in Move
- **error-codes**: Demonstrates proper error handling in Move
- **objects**: Shows how to work with objects in Move
- **struct-capabilities**: Demonstrates the capability pattern for access control
- And many more!

Each snippet directory contains its own README with specific instructions and explanations.

## Learning Path

If you're new to Move, we recommend exploring the snippets in this order:

1. error-codes: Learn about proper error handling
2. objects: Understand the object model in Move
3. private-vs-public: Learn about function visibility and security implications
4. struct-capabilities: Understand the capability pattern for access control
5. user-profile: See a complete example combining multiple concepts

## Additional Resources

- [Move Book](https://move-language.github.io/move/): Comprehensive guide to the Move language
- [Aptos Developer Documentation](https://aptos.dev/): Official Aptos developer resources
- [Aptos Explorer](https://explorer.aptoslabs.com/): Explore the Aptos blockchain
- [Aptos Discord](https://discord.gg/aptoslabs): Join the community for support

## Contributing

Feel free to contribute your own snippets or improvements to existing ones by submitting a pull request!
