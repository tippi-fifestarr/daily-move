# User Profile Module

This module implements a user profile system in Move that allows users to store and manage their preferences on the blockchain. It demonstrates several key concepts and best practices in Move programming.

## Features

- **User Preferences Storage**: Store user preferences including text size, mode (light/dark), system (Windows/Mac/Linux), languages, and collected concepts.
- **Privacy Controls**: Each preference has a public/private setting that controls its visibility to other users.
- **Object-based Design**: Uses Aptos Objects for better extensibility and ownership management.
- **Capability Pattern**: Implements the capability pattern for secure access control.
- **Comprehensive API**: Provides functions for initializing, updating, and querying user profiles.

## Implementation Details

### Resources

1. **UserProfile**: The main resource that stores all user preferences.
   - Text size (small, medium, large)
   - Mode (light, dark)
   - System (Windows, Mac, Linux)
   - Languages (Python, Solidity, TypeScript, JavaScript)
   - Concepts collected (encounter, click, complete)
   - Privacy settings for each preference

2. **ProfileController**: Stores references that control access to the profile.
   - ExtendRef: Allows extending the profile with additional functionality.

3. **ConceptEntry**: Represents a concept the user has collected.
   - Concept type (encounter, click, complete)
   - Name
   - Timestamp

## Privacy System

### How On-Chain Privacy Works

While all data on a blockchain is technically public and visible to anyone who examines the chain, this module implements a "privacy by convention" system that applications can respect. Here's how it works:

1. **Privacy Flags**: Each preference in the UserProfile has a corresponding boolean flag (e.g., `text_size_public`, `mode_public`) that indicates whether that preference should be considered public or private.

2. **User Control**: When initializing or updating preferences, users explicitly specify whether each preference should be public or private:
   ```move
   // Make text size public but keep mode private
   update_text_size(user, TEXT_SIZE_MEDIUM, true);  // public
   update_mode(user, MODE_DARK, false);             // private
   ```

3. **Privacy Information in View Functions**: All view functions return both the preference value and its privacy setting as a tuple:
   ```move
   // Returns (u8, bool) where the bool indicates if the preference is public
   public fun get_text_size(user_addr: address): (u8, bool)
   ```

4. **Application Responsibility**: Applications that read user profiles should check the privacy flag before displaying or using the information:
   ```move
   let (text_size, is_public) = user_profile::get_text_size(user_addr);
   if (is_public || is_current_user) {
       // Only use or display the text_size if it's public or if the current user is viewing their own profile
   }
   ```

### Privacy Implementation Guide

To properly respect user privacy in your application:

1. **Reading Profile Data**:
   When reading profile data, always check the privacy flag returned by the view functions:
   ```move
   let (mode, mode_public) = user_profile::get_mode(target_user);
   if (mode_public || target_user == current_user) {
       // Safe to use mode value
   } else {
       // Use a default value or indicate that this information is private
   }
   ```

2. **Frontend Implementation**:
   In your frontend application, implement privacy checks before displaying user data:
   ```javascript
   // Pseudocode for a frontend application
   async function displayUserProfile(targetUserId) {
     const currentUserId = getCurrentUserId();
     const [textSize, isTextSizePublic] = await getUserTextSize(targetUserId);
     
     if (isTextSizePublic || targetUserId === currentUserId) {
       // Display the text size preference
       displayTextSize(textSize);
     } else {
       // Hide this information or show a "private" indicator
       displayPrivateTextSizeIndicator();
     }
     
     // Repeat for other preferences...
   }
   ```

3. **Setting Privacy Preferences**:
   Provide clear UI controls for users to set privacy preferences for each setting:
   ```html
   <!-- Example UI for setting text size with privacy control -->
   <div>
     <label>Text Size:</label>
     <select id="textSizeSelect">
       <option value="0">Small</option>
       <option value="1">Medium</option>
       <option value="2">Large</option>
     </select>
     <label>
       <input type="checkbox" id="textSizePublic"> Make public
     </label>
   </div>
   ```

4. **Indexers and Off-Chain Services**:
   If you're building indexers or off-chain services that process on-chain data, respect the privacy flags:
   ```python
   # Pseudocode for an indexer
   def index_user_profiles():
       for profile in fetch_all_profiles():
           for preference in profile.preferences:
               if preference.is_public:
                   # Index this preference for public search/display
                   index_public_preference(profile.user_id, preference)
               else:
                   # Either don't index or mark as private
                   skip_or_mark_private(profile.user_id, preference)
   ```

### Benefits of This Approach

1. **User Control**: Users have granular control over which aspects of their profile are visible to others.
2. **Flexibility**: Different preferences can have different privacy settings.
3. **Transparency**: The privacy settings are stored on-chain, making them transparent and auditable.
4. **Simplicity**: The implementation is straightforward and easy to understand.

### Limitations

1. **Trust-Based**: This system relies on applications respecting the privacy flags. Malicious applications could ignore them.
2. **On-Chain Visibility**: The data is still technically visible on-chain to anyone who examines the blockchain directly.
3. **No Cryptographic Privacy**: This is not a cryptographic privacy solution (like zero-knowledge proofs).

For truly sensitive information that should never be visible on-chain, consider using off-chain storage solutions with proper encryption instead.

### Key Functions

- **initialize_profile**: Creates a new user profile with the specified preferences.
- **update_text_size**, **update_mode**, **update_system**: Update individual preferences.
- **add_language**, **remove_language**: Manage the user's language preferences.
- **add_concept**: Add a new concept to the user's collection.
- **get_text_size**, **get_mode**, **get_system**, **get_languages**, **get_concepts**: View functions to query profile data.

## Move Rules Demonstrated

1. **Resource Rule**: The UserProfile is a resource that cannot be copied or implicitly discarded.
2. **Ownership Rule**: Each profile has exactly one owner.
3. **Access Control Rule**: Functions are carefully designed as public or private based on security considerations.
4. **Entry Function Rule**: Entry functions are used for operations that can be called directly in transactions.
5. **Abort Rule**: Descriptive error codes with doc comments are used for clear error messages.
6. **Capability Rule**: The ProfileController implements the capability pattern to control access.
7. **Module Isolation Rule**: The module encapsulates its resources and controls how they can be modified.
8. **Type Safety Rule**: Strong typing ensures operations are only performed on compatible types.
9. **Gas Optimization Rule**: SmartVector is used for efficient storage of collections.
10. **Error Handling Rule**: assert! with descriptive error codes is used for runtime checks.
11. **Documentation Rule**: Doc comments are used throughout for clear documentation.

## Usage Examples

See the `examples.move` file for practical examples of how to use this module:

1. Initializing a profile with default settings
2. Initializing a profile with custom settings
3. Updating preferences
4. Adding concepts to a collection
5. Managing languages

## Complete Deployment Guide for First-Time Users

This guide will walk you through the entire process of deploying and interacting with the User Profile module, from setting up your environment to viewing your profile on-chain.

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

You should see a response like `aptos 4.6.1` or similar.

### 2. Create and Fund a Devnet Account

Initialize a new account on the Aptos devnet:

```bash
mkdir user-profile-demo
cd user-profile-demo
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
5. Verify that your account has been created and funded with test tokens (you should see 1 APT)

### 4. Clone the Repository

Clone this repository to get the User Profile module code:

```bash
git clone https://github.com/tippi-fifestarr/daily-move.git
cd daily-move
```

### 5. Compile the Module

Before publishing, it's a good practice to compile the module to check for any errors:

```bash
aptos move compile --package-dir snippets/user-profile --named-addresses deploy_addr=default
```

You should see a success message if the compilation is successful.

### 6. Run the Tests

Run the tests to ensure everything is working correctly:

```bash
aptos move test --package-dir snippets/user-profile --named-addresses deploy_addr=default
```

All tests should pass before proceeding to deployment.

### 7. Publish the Module

Now you can publish the module to the Aptos blockchain:

```bash
aptos move publish --package-dir snippets/user-profile --named-addresses deploy_addr=default
```

When prompted about gas fees, type 'y' to confirm. You should see a success message with the transaction details.

### 8. Verify the Module Deployment

1. Go to the [Aptos Explorer](https://explorer.aptoslabs.com/?network=devnet)
2. Search for your account address
3. Click on the "Modules" tab
4. You should see the "user_profile" and "user_profile_examples" modules listed

### 9. Initialize Your Profile

Initialize your profile with default settings (medium text size, dark mode, mac system):

```bash
aptos move run --function-id 'default::user_profile_examples::initialize_default_profile'
```

When prompted about gas fees, type 'y' to confirm.

### 10. Initialize with Custom Settings

Alternatively, you can initialize your profile with custom settings:

```bash
aptos move run --function-id 'default::user_profile_examples::initialize_custom_profile' \
  --args 'u8:2' 'u8:1' 'u8:1' 'bool:true' 'bool:false' 'bool:true' 'bool:true' 'bool:false'
```

This initializes a profile with:
- Large text size (2) - public
- Dark mode (1) - private
- Mac system (1) - public
- Languages - public
- Concepts - private

### 11. Update Your Preferences

Update your text size, mode, and system preferences:

```bash
aptos move run --function-id 'default::user_profile_examples::update_preferences' \
  --args 'u8:1' 'u8:0' 'u8:2' 'bool:true' 'bool:true' 'bool:false'
```

This updates your preferences to:
- Medium text size (1) - public
- Light mode (0) - public
- Linux system (2) - private

### 12. Add a Concept

Add a concept to your collection:

```bash
aptos move run --function-id 'default::user_profile_examples::collect_concept' \
  --args 'u8:0' 'vector<u8>:blockchain' 'bool:true'
```

This adds the concept "blockchain" as an "encounter" type (0) with public visibility.

### 13. Manage Languages

Add and remove languages:

```bash
aptos move run --function-id 'default::user_profile_examples::manage_languages' \
  --args 'u8:0' 'u8:3' 'bool:true'
```

This adds Python (0) and removes JavaScript (3), with public visibility for languages.

### 14. View Your Profile on the Explorer

1. Go to the [Aptos Explorer](https://explorer.aptoslabs.com/?network=devnet)
2. Search for your account address
3. Click on the "Resources" tab
4. Look for resources with the "UserProfile" type
5. You can see your stored preferences and their privacy settings

### Troubleshooting

If you encounter any issues during deployment or interaction:

1. **Compilation Errors**: Make sure you're using the correct package directory and named addresses.
2. **Transaction Failures**: Check that you have enough APT for gas fees.
3. **Function Not Found**: Verify that you're using the correct function ID and that the module is properly published.
4. **Invalid Arguments**: Ensure you're passing the correct argument types and values.

For more help, join the [Aptos Discord](https://discord.gg/aptoslabs) community.
