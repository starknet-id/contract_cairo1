#[contract]
mod DummyINFT {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use zeroable::Zeroable;
    use option::OptionTrait;
    use array::SpanTrait;
    use traits::Into;

    use erc721::business_logic::serde::SpanSerde;

    struct Storage {
        owner: LegacyMap<felt252, felt252>, 
    }

    #[view]
    fn get_uri(inft_id: felt252) -> Array<felt252> {
        return ArrayTrait::new();
    }

    #[view]
    fn get_inft_owner(inft_id: felt252) -> felt252 {
        owner::read(inft_id)
    }

    // you can mint it on any starknet_id as long as it is not already minted
    #[external]
    fn mint(inft_id: felt252, starknet_id: felt252) {
        let starknet_id_owner = owner::read(inft_id);
        assert(starknet_id_owner.is_zero(), 'caller is not owner');
        owner::write(inft_id, starknet_id);
    }
}
