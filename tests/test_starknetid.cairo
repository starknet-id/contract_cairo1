use array::ArrayTrait;
use result::ResultTrait;

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
