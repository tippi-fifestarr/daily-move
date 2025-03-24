/// Examples for using the User Profile module
///
/// This module provides examples of how to use the user_profile module
/// to create and manage user profiles.
module deploy_addr::user_profile_examples {
    use std::string;
    use deploy_addr::user_profile;
    
    /// Example of initializing a user profile with default settings
    public entry fun initialize_default_profile(caller: &signer) {
        // Initialize with medium text size, dark mode, mac system
        // All settings are private by default
        user_profile::initialize_profile(
            caller,
            1, // TEXT_SIZE_MEDIUM
            1, // MODE_DARK
            1, // SYSTEM_MAC
            false, // text_size_public - private
            false, // mode_public - private
            false, // system_public - private
            false, // languages_public - private
            false  // concepts_public - private
        );
    }
    
    /// Example of initializing a user profile with custom settings
    public entry fun initialize_custom_profile(
        caller: &signer,
        text_size: u8,
        mode: u8,
        system: u8,
        text_size_public: bool,
        mode_public: bool,
        system_public: bool,
        languages_public: bool,
        concepts_public: bool
    ) {
        user_profile::initialize_profile(
            caller,
            text_size,
            mode,
            system,
            text_size_public,
            mode_public,
            system_public,
            languages_public,
            concepts_public
        );
    }
    
    /// Example of updating user preferences
    public entry fun update_preferences(
        caller: &signer,
        text_size: u8,
        mode: u8,
        system: u8,
        text_size_public: bool,
        mode_public: bool,
        system_public: bool
    ) {
        // Update text size
        user_profile::update_text_size(caller, text_size, text_size_public);
        
        // Update mode
        user_profile::update_mode(caller, mode, mode_public);
        
        // Update system
        user_profile::update_system(caller, system, system_public);
    }
    
    /// Example of adding a concept to the user's collection
    public entry fun collect_concept(
        caller: &signer,
        concept_type: u8,
        concept_name: vector<u8>,
        is_public: bool
    ) {
        // Convert bytes to string
        let name = string::utf8(concept_name);
        
        // Add concept to collection
        user_profile::add_concept(caller, concept_type, name, is_public);
    }
    
    /// Example of adding and removing languages
    public entry fun manage_languages(
        caller: &signer,
        add_language: u8,
        remove_language: u8,
        is_public: bool
    ) {
        // Add a language
        user_profile::add_language(caller, add_language, is_public);
        
        // Remove a language
        user_profile::remove_language(caller, remove_language);
    }
}
