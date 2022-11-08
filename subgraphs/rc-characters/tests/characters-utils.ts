import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  Approval,
  ApprovalForAll,
  CharacterMinted,
  CharacterUpdated,
  OwnershipTransferred,
  Transfer
} from "../generated/Characters/Characters"

export function createApprovalEvent(
  owner: Address,
  approved: Address,
  tokenId: BigInt
): Approval {
  let approvalEvent = changetype<Approval>(newMockEvent())

  approvalEvent.parameters = new Array()

  approvalEvent.parameters.push(
    new ethereum.EventParam("owner", ethereum.Value.fromAddress(owner))
  )
  approvalEvent.parameters.push(
    new ethereum.EventParam("approved", ethereum.Value.fromAddress(approved))
  )
  approvalEvent.parameters.push(
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromUnsignedBigInt(tokenId)
    )
  )

  return approvalEvent
}

export function createApprovalForAllEvent(
  owner: Address,
  operator: Address,
  approved: boolean
): ApprovalForAll {
  let approvalForAllEvent = changetype<ApprovalForAll>(newMockEvent())

  approvalForAllEvent.parameters = new Array()

  approvalForAllEvent.parameters.push(
    new ethereum.EventParam("owner", ethereum.Value.fromAddress(owner))
  )
  approvalForAllEvent.parameters.push(
    new ethereum.EventParam("operator", ethereum.Value.fromAddress(operator))
  )
  approvalForAllEvent.parameters.push(
    new ethereum.EventParam("approved", ethereum.Value.fromBoolean(approved))
  )

  return approvalForAllEvent
}

export function createCharacterMintedEvent(
  character_id: BigInt,
  character_props: ethereum.Tuple
): CharacterMinted {
  let characterMintedEvent = changetype<CharacterMinted>(newMockEvent())

  characterMintedEvent.parameters = new Array()

  characterMintedEvent.parameters.push(
    new ethereum.EventParam(
      "character_id",
      ethereum.Value.fromUnsignedBigInt(character_id)
    )
  )
  characterMintedEvent.parameters.push(
    new ethereum.EventParam(
      "character_props",
      ethereum.Value.fromTuple(character_props)
    )
  )

  return characterMintedEvent
}

export function createCharacterUpdatedEvent(
  character_id: BigInt,
  character_props: ethereum.Tuple
): CharacterUpdated {
  let characterUpdatedEvent = changetype<CharacterUpdated>(newMockEvent())

  characterUpdatedEvent.parameters = new Array()

  characterUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "character_id",
      ethereum.Value.fromUnsignedBigInt(character_id)
    )
  )
  characterUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "character_props",
      ethereum.Value.fromTuple(character_props)
    )
  )

  return characterUpdatedEvent
}

export function createOwnershipTransferredEvent(
  previousOwner: Address,
  newOwner: Address
): OwnershipTransferred {
  let ownershipTransferredEvent = changetype<OwnershipTransferred>(
    newMockEvent()
  )

  ownershipTransferredEvent.parameters = new Array()

  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam(
      "previousOwner",
      ethereum.Value.fromAddress(previousOwner)
    )
  )
  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )

  return ownershipTransferredEvent
}

export function createTransferEvent(
  from: Address,
  to: Address,
  tokenId: BigInt
): Transfer {
  let transferEvent = changetype<Transfer>(newMockEvent())

  transferEvent.parameters = new Array()

  transferEvent.parameters.push(
    new ethereum.EventParam("from", ethereum.Value.fromAddress(from))
  )
  transferEvent.parameters.push(
    new ethereum.EventParam("to", ethereum.Value.fromAddress(to))
  )
  transferEvent.parameters.push(
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromUnsignedBigInt(tokenId)
    )
  )

  return transferEvent
}
