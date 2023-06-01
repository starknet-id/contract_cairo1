use array::ArrayTrait;
use result::ResultTrait;
use traits::{Into, TryInto};

use starknet::ContractAddress;
use starknet::contract_address_const;

use starknetid::contracts::starknetid::StarknetId;

use cheatcodes::RevertedTransactionTrait;
use protostar_print::PrintTrait;

#[test]
#[available_gas(2000000)]
fn test_set_verifier_data() {
    // deploy starknetid contract otherwhise we cannot use start_prank
    let contract_address = deploy_contract('starknetid', @ArrayTrait::new()).unwrap();
    start_prank(123, contract_address).unwrap();

    let token_id = 1;
    let _type = 19256242726728292; // # Discord
    let data = 58596348113441803209962597; // # 0xBenaparte

    // Should set verifier data
    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(token_id);
    invoke_calldata.append(_type);
    invoke_calldata.append(data);
    invoke(contract_address, 'set_verifier_data', @invoke_calldata).unwrap();

    // Should return the correct data
    let mut calldata = ArrayTrait::new();
    calldata.append(token_id);
    calldata.append(_type);
    calldata.append(123);
    let result = call(contract_address, 'get_verifier_data', @calldata).unwrap();
    assert(*result.at(0_u32) == data, 'Invalid data');

    // Should return 0 if no data is set
    let token_id_2 = 2;
    let type_2 = 'Twitter';
    let data_2 = 'Thomas';
    let mut calldata = ArrayTrait::new();
    calldata.append(token_id_2);
    calldata.append(type_2);
    calldata.append(123);
    let result = call(contract_address, 'get_verifier_data', @calldata).unwrap();
    assert(*result.at(0_u32) == 0, 'Should return 0');

    stop_prank(123).unwrap();
}

#[test]
#[available_gas(2000000)]
fn test_mint() {
    // deploy starknetid contract
    let contract_address = deploy_contract('starknetid', @ArrayTrait::new()).unwrap();
    start_prank(123, contract_address).unwrap();

    let token_id = 1;

    // Should mint a new starknetid for account 123
    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(token_id);
    match invoke(contract_address, 'mint', @invoke_calldata) {
        Result::Ok(x) => 'minted successfully'.print(),
        Result::Err(x) => {
            'reverted'.print();
            x.panic_data.print();
        }
    }

    let mut calldata = ArrayTrait::new();
    calldata.append(token_id);
    let result = call(contract_address, 'owner_of', @calldata).unwrap();
    assert(*result.at(0_u32) == 123, 'Invalid owner');

    stop_prank(123).unwrap();
}

#[test]
#[available_gas(2000000)]
fn test_set_user_data() {
    // deploy starknetid contract
    let contract_address = deploy_contract('starknetid', @ArrayTrait::new()).unwrap();
    start_prank(123, contract_address).unwrap();

    let token_id = 1;

    // Should mint a new starknetid for account 123
    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(token_id);
    match invoke(contract_address, 'mint', @invoke_calldata) {
        Result::Ok(x) => 'minted successfully'.print(),
        Result::Err(x) => {
            'reverted'.print();
            x.panic_data.print();
        }
    }

    let _type = 19256242726728292; // # Discord
    let data = 58596348113441803209962597; // # 0xBenaparte

    // Should set verifier data
    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(token_id);
    invoke_calldata.append(_type);
    invoke_calldata.append(data);
    match invoke(contract_address, 'set_user_data', @invoke_calldata) {
        Result::Ok(x) => 'set_user_data successfully'.print(),
        Result::Err(x) => {
            'reverted'.print();
            x.panic_data.print();
        }
    }

    // Should return the correct user_data
    let mut calldata = ArrayTrait::new();
    calldata.append(token_id);
    calldata.append(_type);
    let identity_data = call(contract_address, 'get_user_data', @calldata).unwrap();
    assert(*identity_data.at(0_u32) == data, 'Invalid data');

    // Should return 0 if no data is set
    let type_2 = 'Twitter';
    let mut calldata = ArrayTrait::new();
    calldata.append(token_id);
    calldata.append(type_2);
    let identity_data = call(contract_address, 'get_user_data', @calldata).unwrap();
    assert(*identity_data.at(0_u32) == 0, 'Should return 0');

    stop_prank(123).unwrap();
}

#[test]
#[available_gas(2000000)]
fn test_uri() {
    // deploy starknetid contract
    let contract_address = deploy_contract('starknetid', @ArrayTrait::new()).unwrap();
    start_prank(123, contract_address).unwrap();

    // Should initialize with the correct uri
    let mut arr = ArrayTrait::new();
    let mut invoke_calldata = build_token_uri_arr(arr);
    match invoke(contract_address, 'initializer', @invoke_calldata) {
        Result::Ok(x) => 'initialized successfully'.print(),
        Result::Err(x) => {
            'reverted'.print();
            x.panic_data.print();
        }
    }

    // Mint a new starknet_id for account 123
    let token_id = 256;
    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(token_id);
    match invoke(contract_address, 'mint', @invoke_calldata) {
        Result::Ok(x) => 'minted starknetid successfully'.print(),
        Result::Err(x) => {
            'reverted'.print();
            x.panic_data.print();
        }
    }

    // Should fetch the correct uri for starknetid 256
    let mut calldata = ArrayTrait::new();
    calldata.append(token_id);
    calldata.append(0);
    let uri = call(contract_address, 'tokenURI', @calldata).unwrap();

    assert(*uri.at(0_u32) == 38, 'Invalid uri len');
    assert(*uri.at(36_u32) == 48 + 2, 'Invalid uri char');
    assert(*uri.at(37_u32) == 48 + 5, 'Invalid uri char');
    assert(*uri.at(38_u32) == 48 + 6, 'Invalid uri char');

    stop_prank(123).unwrap();
}

fn build_token_uri_arr(mut arr: Array<felt252>) -> Array<felt252> {
    arr.append(35); // we need to add the array len
    arr.append(104);
    arr.append(116);
    arr.append(116);
    arr.append(112);
    arr.append(115);
    arr.append(58);
    arr.append(47);
    arr.append(47);
    arr.append(105);
    arr.append(110);
    arr.append(100);
    arr.append(101);
    arr.append(120);
    arr.append(101);
    arr.append(114);
    arr.append(46);
    arr.append(115);
    arr.append(116);
    arr.append(97);
    arr.append(114);
    arr.append(107);
    arr.append(110);
    arr.append(101);
    arr.append(116);
    arr.append(46);
    arr.append(105);
    arr.append(100);
    arr.append(47);
    arr.append(117);
    arr.append(114);
    arr.append(105);
    arr.append(63);
    arr.append(105);
    arr.append(100);
    arr.append(61);
    arr
}
