#[test]
fn test_returns_two() {
    assert(starknetid::business_logic::utils::returns_two() == 2, 'Should return 2');
}
