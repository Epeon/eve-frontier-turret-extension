#[allow(unused_use, unused_const, unused_field, unused_variable)]
module turret_extension::turret_extension;

use sui::{bcs, event};
use turret_extension::config::{Self, AdminCap, ExtensionConfig};
use world::{
    character,
    character::Character,
    turret::{Self, OnlineReceipt, ReturnTargetPriorityList, Turret},
    access::OwnerCap,
};

public struct AggressionDetectedEvent has copy, drop { turret_id: ID, attacker_tribe: u32 }

public fun get_target_priority_list(
    turret: &Turret,
    owner_character: &Character,
    config: &ExtensionConfig,
    target_candidate_list: vector<u8>,
    receipt: OnlineReceipt,
): vector<u8> {
    let allowed_tribe = config::get_allowed_tribe(config);
    let owner_tribe = character::tribe(owner_character);
    let owner_item_id = character::key(owner_character).item_id();
    let candidates = turret::unpack_candidate_list(target_candidate_list);
    let mut return_list = vector::empty<ReturnTargetPriorityList>();
    let mut i = 0u64;
    let len = vector::length(&candidates);
    while (i < len) {
        let candidate = vector::borrow(&candidates, i);
        let cand_tribe = turret::character_tribe(candidate);
        let is_aggressor = turret::is_aggressor(candidate);
        let cand_char_id = turret::character_id(candidate);
        let skip = (cand_char_id != 0 && (cand_char_id as u64) == owner_item_id)
            || (cand_tribe == allowed_tribe && !is_aggressor)
            || (cand_tribe == owner_tribe && !is_aggressor);
        if (!skip) {
            let weight = turret::priority_weight(candidate);
            let weight = if (weight == 0) { 1000 } else { weight };
            let weight = if (is_aggressor) { weight + 10000 } else { weight };
            if (is_aggressor) {
                event::emit(AggressionDetectedEvent { turret_id: object::id(turret), attacker_tribe: cand_tribe });
            };
            vector::push_back(&mut return_list, turret::new_return_target_priority_list(turret::item_id(candidate), weight));
        };
        i = i + 1;
    };
    turret::destroy_online_receipt(receipt, config::turret_auth());
    bcs::to_bytes(&return_list)
}



public fun set_mode(config: &mut ExtensionConfig, admin_cap: &AdminCap, new_mode: u8) {
    config::set_mode(config, admin_cap, new_mode);
}

public fun set_allowed_tribe(config: &mut ExtensionConfig, admin_cap: &AdminCap, tribe: u32) {
    config::set_allowed_tribe(config, admin_cap, tribe);
}


public fun authorize(turret: &mut Turret, owner_cap: &OwnerCap<Turret>) {
    turret::authorize_extension<config::TurretAuth>(turret, owner_cap);
}
