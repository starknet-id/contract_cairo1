#[contract]
mod TokenUri {
    use array::{ArrayTrait, SpanTrait};
    use traits::{Into, TryInto};
    use integer::{
        u256, u256_from_felt252, u256_safe_divmod, u256_as_non_zero, u32_try_from_felt252
    };

    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use zeroable::Zeroable;
    use option::OptionTrait;

    use erc721::business_logic::serde::SpanSerde;

    struct Storage {
        token_uri_base: LegacyMap<felt252, felt252>, 
    }

    #[view]
    fn read_base_token_uri(i: felt252) -> Array<felt252> {
        let value = token_uri_base::read(i);
        if value == 0 {
            return ArrayTrait::new();
        }

        let mut arr = read_base_token_uri(i + 1);
        let value = token_uri_base::read(arr.len().into());
        arr.append(value - 1);
        arr
    }

    #[external]
    fn set_token_uri_base_util(arr: Span<felt252>) {
        let mut arr = arr;
        loop {
            if arr.len() == 0 {
                break ();
            }
            token_uri_base::write(
                arr.len().into() - 1, 1 + *arr.pop_back().expect('error retrieving last element')
            );
        }
    }

    #[view]
    fn append_number_ascii(num: u256, ref arr: Array<felt252>) {
        let (q, r) = u256_safe_divmod(num, u256_as_non_zero(u256_from_felt252(10)));
        let digit = r.low + 48; // ascii

        if q == (u256 { low: 0, high: 0 }) {
            arr.append(digit.into());
            return ();
        }

        let added_len = append_number_ascii(q, ref arr);
        arr.append(digit.into());
    }
}
