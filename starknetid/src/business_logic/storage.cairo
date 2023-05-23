mod Store {
    use array::{ArrayTrait, SpanTrait};
    use option::OptionTrait;
    use traits::Into;
    use starknet::SyscallResultTrait;
    use starknet::StorageBaseAddress;

    const USER_DATA_ADDR : felt252 = 1043580099640415304067929596039389735845630832049981224284932480360577081706;
    const VERIFIER_DATA_ADDR : felt252 = 304878986635684253299743444353489138340069571156984851619649640349195152192;

    fn compute_base_address(fn_name: felt252, params: Array<felt252>) -> StorageBaseAddress {
        let mut _params = params;
        let mut tmp: felt252 = hash::LegacyHash::hash(fn_name, _params.pop_front().expect('error computing hash'));
        loop {
            if _params.len() == 0 {
                break();
            }
            let hash = hash::LegacyHash::hash(tmp, _params.pop_front().expect('error computing hash'));
            let tmp = hash;
        };
        starknet::storage_base_address_from_felt252(tmp)
    }

    #[view]
    fn get(fn_name: felt252, params: Array<felt252>, offset: u8, length: usize) -> Array<felt252> {
        let address_domain = 0;
        let base = compute_base_address(fn_name, params);
        let mut value = ArrayTrait::new();
        _get(address_domain, base, ref value, offset, length);
        value
    }

    fn _get(
        address_domain: u32,
        base: starknet::StorageBaseAddress,
        ref value: Array<felt252>,
        offset: u8,
        length: usize
    ) {
        if length == offset.into() {
            return ();
        }

        value.append(
            starknet::storage_read_syscall(
                address_domain, starknet::storage_address_from_base_and_offset(base, offset)
            ).unwrap_syscall()
        );

        return _get(address_domain, base, ref value, offset + 1, length);
    }

    #[view]
    fn get_unbounded_data(fn_name: felt252, params: Array<felt252>, offset: u8) -> Array<felt252> {
        let address_domain = 0;
        let base = compute_base_address(fn_name, params);
        let mut value = ArrayTrait::new();
        _get_unbounded_data(address_domain, base, ref value, offset);
        value
    }

    fn _get_unbounded_data(
        address_domain: u32,
        base: starknet::StorageBaseAddress,
        ref value: Array<felt252>,
        offset: u8,
    ) {
        let to_add = starknet::storage_read_syscall(address_domain, starknet::storage_address_from_base_and_offset(base, offset)).unwrap_syscall();
        if to_add == 0 {
            return ();
        }
        value.append(to_add);
        return _get_unbounded_data(address_domain, base, ref value, offset + 1);
    }

    #[external]
    fn set(fn_name: felt252, params: Array<felt252>, offset: u8, value: Span<felt252>) {
        let address_domain = 0;
        let base = compute_base_address(fn_name, params);
        _set(address_domain, base, value, offset: offset);
    }

    fn _set(
        address_domain: u32,
        base: starknet::StorageBaseAddress,
        mut value: Span<felt252>,
        offset: u8
    ) {
        match value.pop_front() {
            Option::Some(v) => {
                starknet::storage_write_syscall(
                    address_domain, starknet::storage_address_from_base_and_offset(base, offset), *v
                );
                _set(address_domain, base, value, offset + 1);
            },
            Option::None(_) => {},
        }
    }
}
