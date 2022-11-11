import { BigInt } from "@graphprotocol/graph-ts"
import {
  Equipments,
  Approval,
  ApprovalForAll,
  EquipmentMinted,
  OwnershipTransferred,
  Transfer
} from "../generated/Equipments/Equipments"
import { Owner, Minter, Equipment } from "../generated/schema"

export function handleApproval(event: Approval): void {}

export function handleApprovalForAll(event: ApprovalForAll): void {}

export function handleEquipmentMinted(event: EquipmentMinted): void {
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

  ///Create equipment
  let equipment = Equipment.load(event.params.equipment_id.toHexString())
  if (!equipment) {
    equipment = new Equipment(event.params.equipment_id.toHexString())
    equipment.idNum = event.params.equipment_id.toU32()
    equipment.owner = event.params.user.toHexString()
    equipment.minter = event.params.user.toHexString()
    equipment.equipment_type = event.params.equipment_props.equipment_type.toU32()
    equipment.rarity = event.params.equipment_props.rarity.toU32()
    equipment.dominant_stat = event.params.equipment_props.dominant_stat.toU32()
    equipment.extremity = event.params.equipment_props.extremity.toU32()
    equipment.atk = event.params.equipment_stats.atk.toU32()
    equipment.def = event.params.equipment_stats.def.toU32()
    equipment.eva = event.params.equipment_stats.eva.toU32()
    equipment.hp = event.params.equipment_stats.hp.toU32()
    equipment.pen = event.params.equipment_stats.pen.toU32()
    equipment.crit = event.params.equipment_stats.crit.toU32()
    equipment.luk = event.params.equipment_stats.luck.toU32()
    equipment.res = event.params.equipment_stats.energy_restoration.toU32()
  }

  equipment.save()
}

export function handleOwnershipTransferred(event: OwnershipTransferred): void {}

export function handleTransfer(event: Transfer): void {
  ///Load/create owner
  let owner = Owner.load(event.params.to.toHexString())
  if (!owner) {
    owner = new Owner(event.params.to.toHexString())
    owner.save()
  }

  ///Load equipment
  let equipment = Equipment.load(event.params.tokenId.toHexString())
  if (equipment) {
    equipment.owner = event.params.to.toHexString()
    equipment.save()
  }
}
