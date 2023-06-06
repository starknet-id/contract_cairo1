use array::ArrayTrait;
use result::ResultTrait;
use cheatcodes::RevertedTransactionTrait;
use protostar_print::PrintTrait;

#[test]
#[available_gas(2000000)]
fn test_equipping() {
    // deploy starknetid contract
    let contract_address = deploy_contract('starknetid', @ArrayTrait::new()).unwrap();
    start_prank(123, contract_address).unwrap();

    // deploy inft dummy contract
    let dummy_inft_address = deploy_contract('dummy_inft', @ArrayTrait::new()).unwrap();

    let starknet_id = 1;
    // Should mint a starknet id for address 123
    let mut mint_calldata = ArrayTrait::new();
    mint_calldata.append(starknet_id);
    invoke(contract_address, 'mint', @mint_calldata).unwrap();

    let inft_id = 2;
    // Should mint a dummy nft for starknet_id 1
    let mut inft_calldata = ArrayTrait::new();
    inft_calldata.append(inft_id);
    inft_calldata.append(starknet_id);
    invoke(dummy_inft_address, 'mint', @inft_calldata).unwrap();

    let mut owner_calldata = ArrayTrait::new();
    owner_calldata.append(inft_id);
    let owner = call(dummy_inft_address, 'get_inft_owner', @owner_calldata).unwrap();
    assert(*owner.at(0) == starknet_id, 'Invalid owner');

    // Should return 0 if inft is not equipped
    let mut calldata = ArrayTrait::new();
    calldata.append(dummy_inft_address);
    calldata.append(inft_id);
    let equipped = call(contract_address, 'get_equipped_starknet_id', @calldata).unwrap();
    assert(*equipped.at(0) == 0, 'should not be equipped');

    // Should equip the inft = 2 to starknet_id = 1
    invoke(contract_address, 'equip', @calldata).unwrap();
    let equipped = call(contract_address, 'get_equipped_starknet_id', @calldata).unwrap();
    assert(*equipped.at(0) == starknet_id, 'should not be equipped');

    // Should unequip inft_id = 2 from starknet_id = 1
    invoke(contract_address, 'unequip', @calldata).unwrap();
    let equipped = call(contract_address, 'get_equipped_starknet_id', @calldata).unwrap();
    assert(*equipped.at(0) == 0, 'should not be equipped');

    stop_prank(123).unwrap();
}

