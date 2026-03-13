/// Shared configuration object for the turret extension.
/// Stores operating mode and allowed tribe as dynamic fields.
/// Uses the typed witness pattern for authorization.
module turret_extension::config;

use sui::dynamic_field as df;

// === Operating Modes ===
const MODE_WHITELIST: u8  = 1; // Shoot everyone except allowed tribe
const MODE_AGGRESSOR: u8  = 2; // Only shoot confirmed aggressors
const MODE_SENTRY: u8     = 3; // Passive until a friendly is attacked

// === Errors ===
#[error(code = 0)]
const EInvalidMode: vector<u8> = b"Invalid mode: must be 1 (whitelist), 2 (aggressor), or 3 (sentry)";
#[error(code = 1)]
const EInvalidTribe: vector<u8> = b"Invalid tribe ID: must be greater than 1000";

// === Structs ===

/// Shared config object — one per deployed extension.
public struct ExtensionConfig has key {
    id: UID,
}

/// Capability granting admin rights over the config.
/// Transferred to the deployer on publish.
public struct AdminCap has key, store {
    id: UID,
}

/// Typed witness authorizing this extension to call world turret functions.
public struct TurretAuth has drop {}

/// Dynamic field key for operating mode.
public struct ModeKey has copy, drop, store {}

/// Dynamic field key for allowed tribe.
public struct AllowedTribeKey has copy, drop, store {}

// === Init ===
fun init(ctx: &mut TxContext) {
    let admin_cap = AdminCap { id: object::new(ctx) };
    transfer::transfer(admin_cap, ctx.sender());

    let config = ExtensionConfig { id: object::new(ctx) };
    transfer::share_object(config);
}

// === Admin Functions ===

/// Set the operating mode (1=whitelist, 2=aggressor, 3=sentry).
public fun set_mode(
    config: &mut ExtensionConfig,
    _: &AdminCap,
    mode: u8,
) {
    assert!(mode >= 1 && mode <= 3, EInvalidMode);
    if (df::exists_(&config.id, ModeKey {})) {
        let _old: u8 = df::remove(&mut config.id, ModeKey {});
    };
    df::add(&mut config.id, ModeKey {}, mode);
}

/// Set the tribe ID that is always safe regardless of mode.
public fun set_allowed_tribe(
    config: &mut ExtensionConfig,
    _: &AdminCap,
    tribe: u32,
) {
    assert!(tribe > 1000u32, EInvalidTribe);
    if (df::exists_(&config.id, AllowedTribeKey {})) {
        let _old: u32 = df::remove(&mut config.id, AllowedTribeKey {});
    };
    df::add(&mut config.id, AllowedTribeKey {}, tribe);
}

// === View Functions ===

/// Returns the current mode, defaulting to whitelist (1) if not set.
public fun get_mode(config: &ExtensionConfig): u8 {
    if (df::exists_(&config.id, ModeKey {})) {
        *df::borrow(&config.id, ModeKey {})
    } else {
        MODE_WHITELIST
    }
}

/// Returns the allowed tribe ID, defaulting to 0 if not set.
public fun get_allowed_tribe(config: &ExtensionConfig): u32 {
    if (df::exists_(&config.id, AllowedTribeKey {})) {
        *df::borrow(&config.id, AllowedTribeKey {})
    } else {
        0u32
    }
}

/// Returns mode constants for use in other modules.
public fun mode_whitelist(): u8 { MODE_WHITELIST }
public fun mode_aggressor(): u8 { MODE_AGGRESSOR }
public fun mode_sentry(): u8    { MODE_SENTRY }

/// Mint a TurretAuth witness. Restricted to this package.
public(package) fun turret_auth(): TurretAuth { TurretAuth {} }
