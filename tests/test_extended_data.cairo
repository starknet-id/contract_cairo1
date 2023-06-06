use array::ArrayTrait;
use result::ResultTrait;
use traits::{Into, TryInto};

use starknet::ContractAddress;
use starknet::contract_address_const;

use starknetid::contracts::starknetid::StarknetId;
use starknetid::business_logic::storage::Store;

use cheatcodes::RevertedTransactionTrait;
use protostar_print::PrintTrait;

#[test]
#[available_gas(2000000)]
fn test_verifier_extended_data() {
    // deploy starknetid contract otherwhise we cannot use start_prank
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

    // should set the avatar of specified token_id to [ 12345, 6789 ]
    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(token_id);
    invoke_calldata.append('avatar');
    invoke_calldata.append(2);
    invoke_calldata.append(12345);
    invoke_calldata.append(6789);
    match invoke(contract_address, 'set_extended_verifier_data', @invoke_calldata) {
        Result::Ok(x) => 'set_extended_verifier_data OK'.print(),
        Result::Err(x) => {
            'reverted'.print();
            x.panic_data.print();
        }
    }

    // should retrieve it by specifying the array length
    let mut params = ArrayTrait::new();
    params.append(token_id);
    params.append('avatar');
    params.append(2);
    params.append(123);
    let extended_verifier_data = call(contract_address, 'get_extended_verifier_data', @params)
        .unwrap();
    assert(extended_verifier_data.len() == 3, 'wrong len');
    assert(*extended_verifier_data.at(1) == 12345, 'error in 1st value');
    assert(*extended_verifier_data.at(2) == 6789, 'error in 2nd value');

    // should retrieve it without specifying the length (stops at 0)
    let mut params = ArrayTrait::new();
    params.append(token_id);
    params.append('avatar');
    params.append(123);
    let unbounded_verifier_data = call(contract_address, 'get_unbounded_verifier_data', @params)
        .unwrap();
    assert(unbounded_verifier_data.len() == 3, 'wrong len');
    assert(*unbounded_verifier_data.at(1) == 12345, 'error in 1st value');
    assert(*unbounded_verifier_data.at(2) == 6789, 'error in 2nd value');

    // Should retrieve nothing
    let mut params = ArrayTrait::new();
    params.append(token_id);
    params.append('yolo');
    params.append(123);
    let data = call(contract_address, 'get_unbounded_verifier_data', @params).unwrap();
    assert(*data.at(0) == 0, 'should return empty array');

    // Should retrieve an array of specified size full of 0
    let mut params = ArrayTrait::new();
    params.append(token_id);
    params.append('yolo');
    params.append(3);
    params.append(123);
    let extended_verifier_data = call(contract_address, 'get_extended_verifier_data', @params)
        .unwrap();
    assert(extended_verifier_data.len() == 4, 'len should be 4');
    assert(*extended_verifier_data.at(1) == 0, 'array should be full of 0');
    assert(*extended_verifier_data.at(2) == 0, 'array should be full of 0');
    assert(*extended_verifier_data.at(3) == 0, 'array should be full of 0');

    // Should not return any verifier data
    let mut params = ArrayTrait::new();
    params.append(token_id);
    params.append('avatar');
    let data = call(contract_address, 'get_unbounded_user_data', @params).unwrap();
    assert(*data.at(0) == 0, 'should return empty array 2');

    stop_prank(123).unwrap();
}

#[test]
#[available_gas(2000000)]
fn test_user_extended_data() {
    // deploy starknetid contract otherwhise we cannot use start_prank
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

    // should set the avatar of specified token_id to [ 12345, 6789 ]
    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(token_id);
    invoke_calldata.append('avatar');
    invoke_calldata.append(2);
    invoke_calldata.append(12345);
    invoke_calldata.append(6789);
    match invoke(contract_address, 'set_extended_user_data', @invoke_calldata) {
        Result::Ok(x) => 'set_extended_user_data OK'.print(),
        Result::Err(x) => {
            'reverted'.print();
            x.panic_data.print();
        }
    }

    // should retrieve it by specifying the array length
    let mut params = ArrayTrait::new();
    params.append(token_id);
    params.append('avatar');
    params.append(2);
    let extended_user_data = call(contract_address, 'get_extended_user_data', @params).unwrap();
    assert(extended_user_data.len() == 3, 'wrong len');
    assert(*extended_user_data.at(1) == 12345, 'error in 1st value');
    assert(*extended_user_data.at(2) == 6789, 'error in 2nd value');

    // should retrieve it without specifying the length (stops at 0)
    let mut params = ArrayTrait::new();
    params.append(token_id);
    params.append('avatar');
    let unbounded_user_data = call(contract_address, 'get_unbounded_user_data', @params).unwrap();
    assert(unbounded_user_data.len() == 3, 'wrong len');
    assert(*unbounded_user_data.at(1) == 12345, 'error in 1st value');
    assert(*unbounded_user_data.at(2) == 6789, 'error in 2nd value');

    // Should retrieve nothing
    let mut params = ArrayTrait::new();
    params.append(token_id);
    params.append('yolo');
    let data = call(contract_address, 'get_unbounded_user_data', @params).unwrap();
    assert(*data.at(0) == 0, 'should return empty array');

    // Should retrieve an array of specified size full of 0
    let mut params = ArrayTrait::new();
    params.append(token_id);
    params.append('yolo');
    params.append(3);
    let extended_user_data = call(contract_address, 'get_extended_user_data', @params).unwrap();
    assert(extended_user_data.len() == 4, 'len should be 4');
    assert(*extended_user_data.at(1) == 0, 'array should be full of 0');
    assert(*extended_user_data.at(2) == 0, 'array should be full of 0');
    assert(*extended_user_data.at(3) == 0, 'array should be full of 0');

    // Should not return any verifier data
    let mut params = ArrayTrait::new();
    params.append(token_id);
    params.append('avatar');
    params.append(123);
    let data = call(contract_address, 'get_unbounded_verifier_data', @params).unwrap();
    assert(*data.at(0) == 0, 'should return empty array 2');

    stop_prank(123).unwrap();
}
