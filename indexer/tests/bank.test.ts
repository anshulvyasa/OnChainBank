import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { Approval } from "../generated/schema"
import { Approval as ApprovalEvent } from "../generated/Bank/Bank"
import { handleApproval } from "../src/bank"
import { createApprovalEvent } from "./bank-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/subgraphs/developing/creating/unit-testing-framework/#tests-structure

describe("Describe entity assertions", () => {
  beforeAll(() => {
    // Using Anvil Account (0)
    let owner = Address.fromString("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266")
    // Using Anvil Account (1)
    let spender = Address.fromString("0x70997970c51812dc3a010c7d01b50e0d17dc79c8")
    
    let amount = BigInt.fromI32(234)
    let newApprovalEvent = createApprovalEvent(owner, spender, amount)
    handleApproval(newApprovalEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/subgraphs/developing/creating/unit-testing-framework/#write-a-unit-test

  test("Approval created and stored", () => {
    assert.entityCount("Approval", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "Approval",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "owner",
      "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
    )
    assert.fieldEquals(
      "Approval",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "spender",
      "0x70997970c51812dc3a010c7d01b50e0d17dc79c8"
    )
    assert.fieldEquals(
      "Approval",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "amount",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/subgraphs/developing/creating/unit-testing-framework/#asserts
  })
})