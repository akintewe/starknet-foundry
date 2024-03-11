use starknet::{testing::cheatcode, ContractAddress, ClassHash, contract_address_const};

mod events;
mod l1_handler;
mod contract_class;
mod tx_info;
mod fork;
mod storage;

#[derive(Drop, Serde)]
enum CheatTarget {
    All: (),
    One: ContractAddress,
    Multiple: Array<ContractAddress>
}

#[derive(Drop, Serde, PartialEq, Clone)]
enum CheatSpan {
    Indefinite: (),
    Calls: usize,
}

fn test_selector() -> felt252 {
    selector!("TEST_CONTRACT_SELECTOR")
}

fn test_address() -> ContractAddress {
    contract_address_const::<469394814521890341860918960550914>()
}

fn roll(target: CheatTarget, block_number: u64, span: CheatSpan) {
    validate_cheat_span(@span);

    let mut inputs = array![];
    target.serialize(ref inputs);
    span.serialize(ref inputs);
    inputs.append(block_number.into());
    cheatcode::<'start_roll'>(inputs.span());
}

fn start_roll(target: CheatTarget, block_number: u64) {
    roll(target, block_number, CheatSpan::Indefinite);
}

fn stop_roll(target: CheatTarget) {
    let mut inputs = array![];
    target.serialize(ref inputs);
    cheatcode::<'stop_roll'>(inputs.span());
}

fn prank(target: CheatTarget, caller_address: ContractAddress, span: CheatSpan) {
    validate_cheat_span(@span);

    let mut inputs = array![];
    target.serialize(ref inputs);
    span.serialize(ref inputs);
    inputs.append(caller_address.into());
    cheatcode::<'start_prank'>(inputs.span());
}

fn start_prank(target: CheatTarget, caller_address: ContractAddress) {
    prank(target, caller_address, CheatSpan::Indefinite);
}

fn stop_prank(target: CheatTarget) {
    let mut inputs = array![];
    target.serialize(ref inputs);
    cheatcode::<'stop_prank'>(inputs.span());
}

fn warp(target: CheatTarget, block_timestamp: u64, span: CheatSpan) {
    validate_cheat_span(@span);

    let mut inputs = array![];
    target.serialize(ref inputs);
    span.serialize(ref inputs);
    inputs.append(block_timestamp.into());
    cheatcode::<'start_warp'>(inputs.span());
}

fn start_warp(target: CheatTarget, block_timestamp: u64) {
    warp(target, block_timestamp, CheatSpan::Indefinite);
}

fn stop_warp(target: CheatTarget) {
    let mut inputs = array![];
    target.serialize(ref inputs);
    cheatcode::<'stop_warp'>(inputs.span());
}

fn elect(target: CheatTarget, sequencer_address: ContractAddress, span: CheatSpan) {
    validate_cheat_span(@span);

    let mut inputs = array![];
    target.serialize(ref inputs);
    span.serialize(ref inputs);
    inputs.append(sequencer_address.into());
    cheatcode::<'start_elect'>(inputs.span());
}

fn start_elect(target: CheatTarget, sequencer_address: ContractAddress) {
    elect(target, sequencer_address, CheatSpan::Indefinite);
}

fn stop_elect(target: CheatTarget) {
    let mut inputs = array![];
    target.serialize(ref inputs);
    cheatcode::<'stop_elect'>(inputs.span());
}

fn mock_call<T, impl TSerde: core::serde::Serde<T>, impl TDestruct: Destruct<T>>(
    contract_address: ContractAddress, function_selector: felt252, ret_data: T, span: CheatSpan
) {
    let contract_address_felt: felt252 = contract_address.into();
    let mut inputs = array![contract_address_felt, function_selector];

    span.serialize(ref inputs);

    let mut ret_data_arr = ArrayTrait::new();
    ret_data.serialize(ref ret_data_arr);

    ret_data_arr.serialize(ref inputs);

    cheatcode::<'start_mock_call'>(inputs.span());
}

fn start_mock_call<T, impl TSerde: core::serde::Serde<T>, impl TDestruct: Destruct<T>>(
    contract_address: ContractAddress, function_selector: felt252, ret_data: T
) {
    mock_call(contract_address, function_selector, ret_data, CheatSpan::Indefinite);
}

fn stop_mock_call(contract_address: ContractAddress, function_selector: felt252) {
    let contract_address_felt: felt252 = contract_address.into();
    cheatcode::<'stop_mock_call'>(array![contract_address_felt, function_selector].span());
}

fn replace_bytecode(contract: ContractAddress, new_class: ClassHash) {
    cheatcode::<'replace_bytecode'>(array![contract.into(), new_class.into()].span());
}

fn validate_cheat_span(span: @CheatSpan) {
    assert!(span != @CheatSpan::Calls(0), "CheatSpan::Calls must be greater than 0");
}
