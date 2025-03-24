/// User Profile Module
///
/// This module implements a user profile system that allows users to store and manage their preferences.
/// It follows the Move programming language best practices and rules.
///
/// Features:
/// - Store user preferences (text size, mode, system, languages, concepts)
/// - Control privacy settings for each preference
/// - Update preferences
/// - Use capability pattern for sensitive operations
module deploy_addr::user_profile {
    use std::error;
    use std::signer;
    use std::string::{Self, String};
    use std::vector;
    use aptos_framework::object::{Self, Object, ExtendRef};
    use aptos_std::smart_vector::{Self, SmartVector};
    
    /// User has not initialized their profile
    const E_PROFILE_NOT_INITIALIZED: u64 = 1;
    
    /// Invalid text size option
    const E_INVALID_TEXT_SIZE: u64 = 2;
    
    /// Invalid mode option
    const E_INVALID_MODE: u64 = 3;
    
    /// Invalid system option
    const E_INVALID_SYSTEM: u64 = 4;
    
    /// Invalid language
    const E_INVALID_LANGUAGE: u64 = 5;
    
    /// Invalid concept
    const E_INVALID_CONCEPT: u64 = 6;
    
    /// Not authorized to update profile
    const E_NOT_AUTHORIZED: u64 = 7;
    
    /// Text size options
    const TEXT_SIZE_SMALL: u8 = 0;
    const TEXT_SIZE_MEDIUM: u8 = 1;
    const TEXT_SIZE_LARGE: u8 = 2;
    
    /// Mode options
    const MODE_LIGHT: u8 = 0;
    const MODE_DARK: u8 = 1;
    
    /// System options
    const SYSTEM_WINDOWS: u8 = 0;
    const SYSTEM_MAC: u8 = 1;
    const SYSTEM_LINUX: u8 = 2;
    
    /// Language options
    const LANGUAGE_PYTHON: u8 = 0;
    const LANGUAGE_SOLIDITY: u8 = 1;
    const LANGUAGE_TYPESCRIPT: u8 = 2;
    const LANGUAGE_JAVASCRIPT: u8 = 3;
    
    /// Concept collection types
    const CONCEPT_ENCOUNTER: u8 = 0;
    const CONCEPT_CLICK: u8 = 1;
    const CONCEPT_COMPLETE: u8 = 2;
    
    /// Privacy settings
    const PRIVACY_PRIVATE: bool = false;
    const PRIVACY_PUBLIC: bool = true;
    
    /// Seed for object creation
    const PROFILE_SEED: vector<u8> = b"UserProfile";
    
    /// User Profile resource
    /// This is the main resource that stores user preferences
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct UserProfile has key {
        /// Text size preference (small, medium, large)
        text_size: u8,
        /// Text size privacy setting
        text_size_public: bool,
        
        /// Mode preference (light, dark)
        mode: u8,
        /// Mode privacy setting
        mode_public: bool,
        
        /// System preference (windows, mac, linux)
        system: u8,
        /// System privacy setting
        system_public: bool,
        
        /// Languages the user knows
        languages: SmartVector<u8>,
        /// Languages privacy setting
        languages_public: bool,
        
        /// Concepts the user has collected
        concepts_collected: SmartVector<ConceptEntry>,
        /// Concepts privacy setting
        concepts_public: bool
    }
    
    /// Concept Entry
    /// Represents a concept the user has collected
    struct ConceptEntry has store, drop, copy {
        /// Type of concept (encounter, click, complete)
        concept_type: u8,
        /// Name of the concept
        name: String,
        /// Timestamp when the concept was collected
        timestamp: u64
    }
    
    /// Profile Controller
    /// Stores references that control access to the profile
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct ProfileController has key {
        extend_ref: ExtendRef
    }
    
    /// Initialize a new user profile
    /// This is an entry function that can be called directly in a transaction
    public entry fun initialize_profile(
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
        // Validate inputs
        validate_text_size(text_size);
        validate_mode(mode);
        validate_system(system);
        
        // Create the profile object
        let constructor_ref = object::create_named_object(caller, PROFILE_SEED);
        let extend_ref = object::generate_extend_ref(&constructor_ref);
        
        // Disable transfer of profile object
        let transfer_ref = object::generate_transfer_ref(&constructor_ref);
        object::disable_ungated_transfer(&transfer_ref);
        
        // Create the profile signer
        let profile_signer = object::generate_signer(&constructor_ref);
        
        // Initialize languages with default values (python, solidity, typescript, javascript)
        let languages = smart_vector::new();
        smart_vector::push_back(&mut languages, LANGUAGE_PYTHON);
        smart_vector::push_back(&mut languages, LANGUAGE_SOLIDITY);
        smart_vector::push_back(&mut languages, LANGUAGE_TYPESCRIPT);
        smart_vector::push_back(&mut languages, LANGUAGE_JAVASCRIPT);
        
        // Move the profile to the object
        move_to(&profile_signer, UserProfile {
            text_size,
            text_size_public,
            mode,
            mode_public,
            system,
            system_public,
            languages,
            languages_public,
            concepts_collected: smart_vector::new(),
            concepts_public
        });
        
        // Move the controller to the object
        move_to(&profile_signer, ProfileController {
            extend_ref
        });
    }
    
    /// Update text size preference
    public entry fun update_text_size(
        caller: &signer,
        text_size: u8,
        is_public: bool
    ) acquires UserProfile {
        validate_text_size(text_size);
        
        let profile_obj = get_profile_object(caller);
        let profile = borrow_mut_profile(profile_obj);
        
        profile.text_size = text_size;
        profile.text_size_public = is_public;
    }
    
    /// Update mode preference
    public entry fun update_mode(
        caller: &signer,
        mode: u8,
        is_public: bool
    ) acquires UserProfile {
        validate_mode(mode);
        
        let profile_obj = get_profile_object(caller);
        let profile = borrow_mut_profile(profile_obj);
        
        profile.mode = mode;
        profile.mode_public = is_public;
    }
    
    /// Update system preference
    public entry fun update_system(
        caller: &signer,
        system: u8,
        is_public: bool
    ) acquires UserProfile {
        validate_system(system);
        
        let profile_obj = get_profile_object(caller);
        let profile = borrow_mut_profile(profile_obj);
        
        profile.system = system;
        profile.system_public = is_public;
    }
    
    /// Add a language to the user's profile
    public entry fun add_language(
        caller: &signer,
        language: u8,
        is_public: bool
    ) acquires UserProfile {
        validate_language(language);
        
        let profile_obj = get_profile_object(caller);
        let profile = borrow_mut_profile(profile_obj);
        
        // Check if language already exists
        let i = 0;
        let len = smart_vector::length(&profile.languages);
        let exists = false;
        
        while (i < len) {
            if (*smart_vector::borrow(&profile.languages, i) == language) {
                exists = true;
                break
            };
            i = i + 1;
        };
        
        // Add language if it doesn't exist
        if (!exists) {
            smart_vector::push_back(&mut profile.languages, language);
        };
        
        // Update privacy setting
        profile.languages_public = is_public;
    }
    
    /// Remove a language from the user's profile
    public entry fun remove_language(
        caller: &signer,
        language: u8
    ) acquires UserProfile {
        validate_language(language);
        
        let profile_obj = get_profile_object(caller);
        let profile = borrow_mut_profile(profile_obj);
        
        // Find and remove the language
        let i = 0;
        let len = smart_vector::length(&profile.languages);
        
        while (i < len) {
            if (*smart_vector::borrow(&profile.languages, i) == language) {
                smart_vector::remove(&mut profile.languages, i);
                break
            };
            i = i + 1;
        };
    }
    
    /// Add a concept to the user's collection
    public entry fun add_concept(
        caller: &signer,
        concept_type: u8,
        name: String,
        is_public: bool
    ) acquires UserProfile {
        validate_concept(concept_type);
        
        let profile_obj = get_profile_object(caller);
        let profile = borrow_mut_profile(profile_obj);
        
        // Create concept entry
        let concept = ConceptEntry {
            concept_type,
            name,
            timestamp: aptos_framework::timestamp::now_seconds()
        };
        
        // Add concept to collection
        smart_vector::push_back(&mut profile.concepts_collected, concept);
        
        // Update privacy setting
        profile.concepts_public = is_public;
    }
    
    /// Get the user's profile object
    public fun get_profile_object(user: &signer): Object<UserProfile> {
        let user_addr = signer::address_of(user);
        let profile_addr = object::create_object_address(&user_addr, PROFILE_SEED);
        object::address_to_object<UserProfile>(profile_addr)
    }
    
    /// Check if a user has initialized their profile
    public fun has_profile(user_addr: address): bool {
        let profile_addr = object::create_object_address(&user_addr, PROFILE_SEED);
        exists<UserProfile>(profile_addr)
    }
    
    /// Get text size (public view function)
    #[view]
    public fun get_text_size(user_addr: address): (u8, bool) acquires UserProfile {
        let profile_addr = object::create_object_address(&user_addr, PROFILE_SEED);
        assert!(exists<UserProfile>(profile_addr), error::not_found(E_PROFILE_NOT_INITIALIZED));
        
        let profile = borrow_profile_by_address(profile_addr);
        (profile.text_size, profile.text_size_public)
    }
    
    /// Get mode (public view function)
    #[view]
    public fun get_mode(user_addr: address): (u8, bool) acquires UserProfile {
        let profile_addr = object::create_object_address(&user_addr, PROFILE_SEED);
        assert!(exists<UserProfile>(profile_addr), error::not_found(E_PROFILE_NOT_INITIALIZED));
        
        let profile = borrow_profile_by_address(profile_addr);
        (profile.mode, profile.mode_public)
    }
    
    /// Get system (public view function)
    #[view]
    public fun get_system(user_addr: address): (u8, bool) acquires UserProfile {
        let profile_addr = object::create_object_address(&user_addr, PROFILE_SEED);
        assert!(exists<UserProfile>(profile_addr), error::not_found(E_PROFILE_NOT_INITIALIZED));
        
        let profile = borrow_profile_by_address(profile_addr);
        (profile.system, profile.system_public)
    }
    
    /// Get languages (public view function)
    #[view]
    public fun get_languages(user_addr: address): (vector<u8>, bool) acquires UserProfile {
        let profile_addr = object::create_object_address(&user_addr, PROFILE_SEED);
        assert!(exists<UserProfile>(profile_addr), error::not_found(E_PROFILE_NOT_INITIALIZED));
        
        let profile = borrow_profile_by_address(profile_addr);
        
        // Convert SmartVector to regular vector for return
        let languages = vector::empty<u8>();
        let i = 0;
        let len = smart_vector::length(&profile.languages);
        
        while (i < len) {
            vector::push_back(&mut languages, *smart_vector::borrow(&profile.languages, i));
            i = i + 1;
        };
        
        (languages, profile.languages_public)
    }
    
    /// Get concepts (public view function)
    #[view]
    public fun get_concepts(user_addr: address): (vector<ConceptEntry>, bool) acquires UserProfile {
        let profile_addr = object::create_object_address(&user_addr, PROFILE_SEED);
        assert!(exists<UserProfile>(profile_addr), error::not_found(E_PROFILE_NOT_INITIALIZED));
        
        let profile = borrow_profile_by_address(profile_addr);
        
        // Convert SmartVector to regular vector for return
        let concepts = vector::empty<ConceptEntry>();
        let i = 0;
        let len = smart_vector::length(&profile.concepts_collected);
        
        while (i < len) {
            vector::push_back(&mut concepts, *smart_vector::borrow(&profile.concepts_collected, i));
            i = i + 1;
        };
        
        (concepts, profile.concepts_public)
    }
    
    /// Get text size name from code
    public fun get_text_size_name(text_size: u8): String {
        if (text_size == TEXT_SIZE_SMALL) {
            string::utf8(b"small")
        } else if (text_size == TEXT_SIZE_MEDIUM) {
            string::utf8(b"medium")
        } else if (text_size == TEXT_SIZE_LARGE) {
            string::utf8(b"large")
        } else {
            string::utf8(b"unknown")
        }
    }
    
    /// Get mode name from code
    public fun get_mode_name(mode: u8): String {
        if (mode == MODE_LIGHT) {
            string::utf8(b"light")
        } else if (mode == MODE_DARK) {
            string::utf8(b"dark")
        } else {
            string::utf8(b"unknown")
        }
    }
    
    /// Get system name from code
    public fun get_system_name(system: u8): String {
        if (system == SYSTEM_WINDOWS) {
            string::utf8(b"windows")
        } else if (system == SYSTEM_MAC) {
            string::utf8(b"mac")
        } else if (system == SYSTEM_LINUX) {
            string::utf8(b"linux")
        } else {
            string::utf8(b"unknown")
        }
    }
    
    /// Get language name from code
    public fun get_language_name(language: u8): String {
        if (language == LANGUAGE_PYTHON) {
            string::utf8(b"python")
        } else if (language == LANGUAGE_SOLIDITY) {
            string::utf8(b"solidity")
        } else if (language == LANGUAGE_TYPESCRIPT) {
            string::utf8(b"typescript")
        } else if (language == LANGUAGE_JAVASCRIPT) {
            string::utf8(b"javascript")
        } else {
            string::utf8(b"unknown")
        }
    }
    
    /// Get concept type name from code
    public fun get_concept_type_name(concept_type: u8): String {
        if (concept_type == CONCEPT_ENCOUNTER) {
            string::utf8(b"encounter")
        } else if (concept_type == CONCEPT_CLICK) {
            string::utf8(b"click")
        } else if (concept_type == CONCEPT_COMPLETE) {
            string::utf8(b"complete")
        } else {
            string::utf8(b"unknown")
        }
    }
    
    /// Validate text size
    fun validate_text_size(text_size: u8) {
        assert!(
            text_size == TEXT_SIZE_SMALL || 
            text_size == TEXT_SIZE_MEDIUM || 
            text_size == TEXT_SIZE_LARGE,
            error::invalid_argument(E_INVALID_TEXT_SIZE)
        );
    }
    
    /// Validate mode
    fun validate_mode(mode: u8) {
        assert!(
            mode == MODE_LIGHT || 
            mode == MODE_DARK,
            error::invalid_argument(E_INVALID_MODE)
        );
    }
    
    /// Validate system
    fun validate_system(system: u8) {
        assert!(
            system == SYSTEM_WINDOWS || 
            system == SYSTEM_MAC || 
            system == SYSTEM_LINUX,
            error::invalid_argument(E_INVALID_SYSTEM)
        );
    }
    
    /// Validate language
    fun validate_language(language: u8) {
        assert!(
            language == LANGUAGE_PYTHON || 
            language == LANGUAGE_SOLIDITY || 
            language == LANGUAGE_TYPESCRIPT || 
            language == LANGUAGE_JAVASCRIPT,
            error::invalid_argument(E_INVALID_LANGUAGE)
        );
    }
    
    /// Validate concept
    fun validate_concept(concept_type: u8) {
        assert!(
            concept_type == CONCEPT_ENCOUNTER || 
            concept_type == CONCEPT_CLICK || 
            concept_type == CONCEPT_COMPLETE,
            error::invalid_argument(E_INVALID_CONCEPT)
        );
    }
    
    /// Borrow a mutable reference to the profile
    fun borrow_mut_profile(profile_obj: Object<UserProfile>): &mut UserProfile {
        let profile_addr = object::object_address(profile_obj);
        borrow_global_mut<UserProfile>(profile_addr)
    }
    
    /// Borrow a reference to the profile by address
    fun borrow_profile_by_address(profile_addr: address): &UserProfile {
        borrow_global<UserProfile>(profile_addr)
    }
}
