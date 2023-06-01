use array::ArrayTrait;
use result::ResultTrait;
use traits::Into;
use integer::u256_from_felt252;

use starknet::ContractAddress;
use starknet::contract_address_const;

use token_uri::contracts::token_uri::TokenUri;

use cheatcodes::RevertedTransactionTrait;
use protostar_print::PrintTrait;

#[test]
#[available_gas(2000000)]
fn test_set_token_uri_base_util() {
    // Deploy token_uri contract
    let contract_address = deploy_contract('token_uri', @ArrayTrait::new()).unwrap();
    start_prank(123, contract_address).unwrap();

    // Should set token uri base
    // Build calldata and serialize span into array
    let mut arr = ArrayTrait::new();
    let mut uri_base = build_token_uri_arr(arr);
    match invoke(contract_address, 'set_token_uri_base_util', @uri_base) {
        Result::Ok(x) => 'set uri successfully'.print(),
        Result::Err(x) => {
            'reverted'.print();
            x.panic_data.print();
        }
    }

    let mut param = ArrayTrait::new();
    param.append(0);
    let arr = call(contract_address, 'read_base_token_uri', @param).unwrap();

    assert(arr.len() == 36, 'len should be 36');
    assert(*arr.at(1) == 104, '1st val should be 104');
    assert(*arr.at(arr.len() - 1) == 61, 'last val should be 61');

    stop_prank(123).unwrap();
}

#[test]
#[available_gas(2000000)]
fn test_append_number_ascii() {
    // Should append ascii characters 123450 to uri
    let number = u256_from_felt252(123450);
    let mut arr = ArrayTrait::new();
    arr.append(1234567898765);
    TokenUri::append_number_ascii(number, ref arr);

    assert(arr.len().into() == 7, 'len should be 7');
    assert(*arr.at(0) == 1234567898765, '1st val should be 1234567898765');
    assert(*arr.at(1) == 48 + 1, '2nd val should be 49');
    assert(*arr.at(2) == 48 + 2, '3rd val should be 50');
    assert(*arr.at(3) == 48 + 3, '4th val should be 51');
    assert(*arr.at(4) == 48 + 4, '5th val should be 52');
    assert(*arr.at(5) == 48 + 5, '6th val should be 53');
    assert(*arr.at(6) == 48 + 0, '7th val should be 48');
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
