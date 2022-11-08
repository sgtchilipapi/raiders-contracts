import { BigInt } from "@graphprotocol/graph-ts"
import {
  Characters,
  Approval,
  ApprovalForAll,
  CharacterMinted,
  CharacterUpdated,
  OwnershipTransferred,
  Transfer
} from "../generated/Characters/Characters"
import { Owner, Minter, Character } from "../generated/schema"

export function handleApproval(event: Approval): void {
}

export function handleApprovalForAll(event: ApprovalForAll): void { }

export function handleCharacterMinted(event: CharacterMinted): void {
  ///Load/create minter
  let minter = Minter.load(event.params.user.toHexString())
  if (!minter) {
    minter = new Minter(event.params.user.toHexString())
    minter.save()
  }

  ///Load/create owner
  let owner = Owner.load(event.params.user.toHexString())
  if (!owner) {
    owner = new Owner(event.params.user.toHexString())
    owner.save()
  }

  ///Create character
  let character = Character.load(event.params.character_id.toHexString())
  if (!character) {
    character = new Character(event.params.character_id.toHexString())
    character.idNum = event.params.character_id.toU32()
    character.owner = event.params.user.toHexString()
    character.minter = event.params.user.toHexString()
    character.character_name = event.params.char_name.toString()
    character.character_class = event.params.character_props.character_class.toU32()
    character.element = event.params.character_props.element.toU32()
    character.str = event.params.character_props.str.toU32()
    character.vit = event.params.character_props.vit.toU32()
    character.dex = event.params.character_props.dex.toU32()
    character.talent = event.params.character_props.talent.toU32()
    character.mood = event.params.character_props.mood.toU32()
    character.exp = event.params.character_props.exp.toU32()
  }

  character.save()
}

export function handleCharacterUpdated(event: CharacterUpdated): void {
  ///Load character
  let character = Character.load(event.params.character_id.toHexString())
  if (character) {
    character.character_name = event.params.char_name.toString()
    character.str = event.params.character_props.str.toU32()
    character.vit = event.params.character_props.vit.toU32()
    character.dex = event.params.character_props.dex.toU32()
    character.mood = event.params.character_props.mood.toU32()
    character.exp = event.params.character_props.exp.toU32()
  }

  character!.save()
}

export function handleOwnershipTransferred(event: OwnershipTransferred): void { }

export function handleTransfer(event: Transfer): void {
  ///Load/create owner
  let owner = Owner.load(event.params.to.toHexString())
  if (!owner) {
    owner = new Owner(event.params.to.toHexString())
    owner.save()
  }

  ///Load character
  let character = Character.load(event.params.tokenId.toHexString())
  if (character) {
    character.owner = event.params.to.toHexString()
    character!.save()
  }
}
