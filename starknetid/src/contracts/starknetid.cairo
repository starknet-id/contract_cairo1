#[contract]
mod StarknetId {
    use array::ArrayTrait;
    use traits::{Into, TryInto};
    use option::OptionTrait;
    use integer::{u256, u256_from_felt252};
    use zeroable::Zeroable;

    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::contract_address::ContractAddressZeroable;

    use starknetid::business_logic::storage::Store;
    use erc721::contracts::erc721::ERC721;
    use token_uri::contracts::token_uri::TokenUri;

    // Dispatchers
    use starknetid::business_logic::inft::INFTDispatcher;
    use starknetid::business_logic::inft::INFTDispatcherTrait;

    struct Storage {
        starknet_id_data: LegacyMap::<(felt252, felt252, ContractAddress), felt252>,
        user_data: LegacyMap::<(felt252, felt252), felt252>,
        verifier_data: LegacyMap::<(felt252, felt252, ContractAddress), felt252>,
        inft_equipped_by: LegacyMap::<(ContractAddress, felt252), ContractAddress>,
    }

    //
    // Events
    //

    #[event]
    fn UserDataUpdate(starknet_id: felt252, field: felt252, data: felt252, ) {}

    #[event]
    fn ExtendedUserDataUpdate(starknet_id: felt252, field: felt252, data: Array<felt252>, ) {}

    #[event]
    fn VerifierDataUpdate(
        starknet_id: felt252, field: felt252, data: felt252, verifier: ContractAddress, 
    ) {}

    #[event]
    fn ExtendedVerifierDataUpdate(
        starknet_id: felt252, author: ContractAddress, field: felt252, data: Array<felt252>, 
    ) {}

    #[event]
    fn on_inft_equipped(
        inft_contract: ContractAddress, inft_id: felt252, starknet_id: ContractAddress, 
    ) {}

    //
    // Initializer
    //

    #[external]
    fn initializer(uri_base: Span<felt252>) {
        // todo: add proxy when available on OZ
        // proxy_admin: ContractAddress,
        // Proxy.initializer(proxy_admin);
        ERC721::initializer('Starknet.id', 'ID');
        TokenUri::set_token_uri_base_util(uri_base);
    }

    //
    // Getters
    //

    #[view]
    fn name() -> felt252 {
        ERC721::name()
    }

    #[view]
    fn symbol() -> felt252 {
        ERC721::symbol()
    }

    #[view]
    fn balanceOf(owner: ContractAddress) -> u256 {
        ERC721::balance_of(owner)
    }

    #[view]
    fn owner_of(starknet_id: felt252) -> ContractAddress {
        ERC721::owner_of(u256_from_felt252(starknet_id))
    }

    #[view]
    fn ownerOf(starknet_id: u256) -> ContractAddress {
        ERC721::owner_of(starknet_id)
    }

    #[view]
    fn getApproved(starknet_id: u256) -> ContractAddress {
        ERC721::get_approved(starknet_id)
    }

    #[view]
    fn isApprovedForAll(owner: ContractAddress, operator: ContractAddress) -> bool {
        ERC721::is_approved_for_all(owner, operator)
    }

    #[view]
    fn tokenURI(token_id: u256) -> Array<felt252> {
        let mut arr = TokenUri::read_base_token_uri(0);
        TokenUri::append_number_ascii(token_id, ref arr);
        arr
    }

    // #[view]
    // fn supportsInterface(interface_id: u32) -> felt252 {
    //     ERC721::supports_interface(interface_id)
    // }

    //
    // STARKNET ID specific
    //

    #[view]
    fn get_user_data(starknet_id: felt252, field: felt252, ) -> felt252 {
        user_data::read((starknet_id, field))
    }

    #[view]
    fn get_extended_user_data(
        starknet_id: felt252, field: felt252, length: felt252, 
    ) -> Array<felt252> {
        let mut params = ArrayTrait::new();
        params.append(starknet_id);
        params.append(field);
        return Store::get(
            Store::USER_DATA_ADDR,
            params,
            0_u8,
            length.try_into().expect('error converting felt to usize')
        );
    }

    #[view]
    fn get_unbounded_user_data(starknet_id: felt252, field: felt252) -> Array<felt252> {
        let mut params = ArrayTrait::new();
        params.append(starknet_id);
        params.append(field);
        return Store::get_unbounded_data(Store::USER_DATA_ADDR, params, 0_u8);
    }

    #[view]
    fn get_verifier_data(
        starknet_id: felt252, field: felt252, address: ContractAddress
    ) -> felt252 {
        verifier_data::read((starknet_id, field, address))
    }

    #[view]
    fn get_extended_verifier_data(
        starknet_id: felt252, field: felt252, length: felt252, address: ContractAddress
    ) -> Array<felt252> {
        let mut params = ArrayTrait::new();
        params.append(starknet_id);
        params.append(field);
        params.append(address.into());
        return Store::get(
            Store::VERIFIER_DATA_ADDR,
            params,
            0_u8,
            length.try_into().expect('error converting felt to usize')
        );
    }

    #[view]
    fn get_unbounded_verifier_data(
        starknet_id: felt252, field: felt252, address: ContractAddress
    ) -> Array<felt252> {
        let mut params = ArrayTrait::new();
        params.append(starknet_id);
        params.append(field);
        params.append(address.into());
        return Store::get_unbounded_data(Store::VERIFIER_DATA_ADDR, params, 0_u8);
    }

    #[view]
    fn get_equipped_starknet_id(
        inft_contract: ContractAddress, inft_id: felt252, 
    ) -> ContractAddress {
        inft_equipped_by::read((inft_contract, inft_id))
    }

    //
    // Setters
    //

    #[external]
    fn approve(to: ContractAddress, starknet_id: u256, ) {
        ERC721::approve(to, starknet_id)
    }

    #[external]
    fn setApprovalForAll(operator: ContractAddress, approved: bool, ) {
        ERC721::set_approval_for_all(operator, approved)
    }

    #[external]
    fn transferFrom(_from: ContractAddress, to: ContractAddress, starknet_id: u256, ) {
        ERC721::transfer_from(_from, to, starknet_id)
    }

    #[external]
    fn safeTransferFrom(
        _from: ContractAddress, to: ContractAddress, starknet_id: u256, data: Span<felt252>, 
    ) {
        ERC721::safe_transfer_from(_from, to, starknet_id, data)
    }

    //
    // NFT specific
    //

    #[external]
    fn mint(starknet_id: felt252) {
        let to = get_caller_address();
        assert(!starknet_id.is_zero(), 'starknet_id must be non-zero');
        // todo: assert_nn(starknet_id);  starknet_id < 2**128
        ERC721::_mint(to, u256_from_felt252(starknet_id));
    }

    //
    // STARKNET ID specific
    //

    #[external]
    fn set_user_data(starknet_id: felt252, field: felt252, data: felt252) {
        let owner = ERC721::owner_of(u256_from_felt252(starknet_id));
        let caller = get_caller_address();
        assert(owner == caller, 'caller is not owner');
        UserDataUpdate(starknet_id, field, data);
        user_data::write((starknet_id, field), data);
    }

    #[external]
    fn set_extended_user_data(starknet_id: felt252, field: felt252, data: Array<felt252>) {
        let owner = ERC721::owner_of(u256_from_felt252(starknet_id));
        let caller = get_caller_address();
        assert(owner == caller, 'caller is not owner');

        let mut params = ArrayTrait::new();
        params.append(starknet_id);
        params.append(field);
        Store::set(Store::USER_DATA_ADDR, params, 0_u8, data.span());
        ExtendedUserDataUpdate(starknet_id, field, data);
    }

    #[external]
    fn set_verifier_data(starknet_id: felt252, field: felt252, data: felt252) {
        let address = get_caller_address();
        VerifierDataUpdate(starknet_id, field, data, address);
        verifier_data::write((starknet_id, field, address), data);
    }

    #[external]
    fn set_extended_verifier_data(starknet_id: felt252, field: felt252, data: Array<felt252>) {
        let author = get_caller_address();

        let mut params = ArrayTrait::new();
        params.append(starknet_id);
        params.append(field);
        params.append(author.into());
        Store::set(Store::VERIFIER_DATA_ADDR, params, 0_u8, data.span());

        ExtendedVerifierDataUpdate(starknet_id, author, field, data);
    }

    #[external]
    fn equip(inft_contract: ContractAddress, inft_id: felt252, ) {
        // ensure caller controls the starknet_id owning this iNFT
        let starknet_id_owner = INFTDispatcher {
            contract_address: inft_contract
        }.get_inft_owner(inft_id);
        let owner = ERC721::owner_of(u256_from_felt252(starknet_id_owner.into()));
        let caller = get_caller_address();
        assert(owner == caller, 'caller is not owner');

        // update who equips this iNFT
        inft_equipped_by::write((inft_contract, inft_id), starknet_id_owner);

        // emit event
        on_inft_equipped(inft_contract, inft_id, starknet_id_owner);
    }

    #[external]
    fn unequip(inft_contract: ContractAddress, inft_id: felt252, ) {
        // ensure caller controls the starknet_id owning this iNFT
        let starknet_id_owner = INFTDispatcher {
            contract_address: inft_contract
        }.get_inft_owner(inft_id);
        let owner = ERC721::owner_of(u256_from_felt252(starknet_id_owner.into()));
        let caller = get_caller_address();
        assert(owner == caller, 'caller is not owner');

        // update who equips this iNFT
        inft_equipped_by::write((inft_contract, inft_id), ContractAddressZeroable::zero());

        // emit event
        on_inft_equipped(inft_contract, inft_id, ContractAddressZeroable::zero());
    }
}
