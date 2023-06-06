#[abi]
trait INFT {
    // returns a json url describing how the token should be displayed
    fn get_uri(inft_id: felt252) -> Array<felt252>;

    // returns the starknet_id owner of the token
    fn get_inft_owner(inft_id: felt252) -> starknet::ContractAddress;
}
