use array::ArrayTrait;
use result::ResultTrait;

use starknet::ContractAddress;
use starknet::contract_address_const;

use token_uri::contracts::token_uri::TokenUri;

use cheatcodes::RevertedTransactionTrait;
use protostar_print::PrintTrait;

#[test]
#[available_gas(2000000)]
fn test_set_verifier_data() {
    // deploy starknetid contract otherwhise we cannot use start_prank
    let contract_address = deploy_contract('token_uri', @ArrayTrait::new()).unwrap();
    start_prank(123, contract_address).unwrap();

    let uri_base = build_token_uri_arr();
    invoke(contract_address, 'set_token_uri_base_util', @uri_base).unwrap();

    let mut param = ArrayTrait::new();
    param.append(0);
    let arr = call(contract_address, 'read_base_token_uri', @param).unwrap();
    // let arr = TokenUri::read_base_token_uri(0);

    assert(arr.len() == 38, 'should be equal');
    assert(*arr.at(0) == 104, 'should be equal');

    // let token_id = 256;
    // mint(token_id);
    // let (len_uri, uri) = tokenURI(Uint256(token_id, 0));
    // assert 38 = len_uri;
    // assert uri[0] = 104;
    // assert uri[42] = 48 + 2;
    // assert uri[43] = 48 + 5;
    // assert uri[44] = 48 + 6;

    stop_prank(123).unwrap();
// # valid case
// let (isValidData) = verifier_data.read(token_id, type, contract_address_const::<123>());
// assert isValidData = data;

// let contract_address = deploy_contract('starknetid', @ArrayTrait::new()).unwrap();

// let result_before = call(contract_address, 'get_balance', @ArrayTrait::new()).unwrap();
// assert(*result_before.at(0_u32) == 0, 'Invalid balance');

// let mut invoke_calldata = ArrayTrait::new();
// invoke_calldata.append(42);
// invoke(contract_address, 'increase_balance', @invoke_calldata).unwrap();

// let result_after = call(contract_address, 'get_balance', @ArrayTrait::new()).unwrap();
// assert(*result_after.at(0_u32) == 42, 'Invalid balance');
}

fn build_token_uri_arr() -> Array<felt252> {
    let mut arr = ArrayTrait::new();
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
