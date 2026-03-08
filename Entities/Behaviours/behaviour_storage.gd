class_name Behaviour_Storage extends Behaviour

@export var size := InventoryItemList_float.new()
@export var inventory := InventoryItemList_float.new()


enum DebtMode {
	TAKE_NONE_NO_DEBT,			# If not enough, take nothing, no debt
	TAKE_AVAILABLE_NO_DEBT,		# If not enough, Take only what is available, no debt
	TAKE_FULL_IF_CLEAR,			# If not enough, take what's needed if there's no existing debt
	TAKE_FULL_ALLOW_DEBT,		# If not enough, always take what's needed and increase debt
}
enum OverflowMode {
	DEPOSIT_NONE_NO_OVERFLOW,		# If too much, deposit nothing, no overflow
	DEPOSIT_AVAILABLE_NO_OVERFLOW,	# If too much, deposit only what there's space for, no overflow
	DEPOSIT_ALL_IF_CLEAR,			# If too much, deposit all if there's no existing overflow
	DEPOSIT_ALL_ALLOW_OVERFLOW,		# If too much, deposit all and increase overflow
}


func remove(item:InventoryItem, amount:float, debt_mode:= DebtMode.TAKE_NONE_NO_DEBT) -> TransactionResult:
	if inventory.items[item] >= amount:
		inventory.items[item] -= amount
		return TransactionResult.new(true, 0) #Success, residual
		
	match debt_mode:

		DebtMode.TAKE_NONE_NO_DEBT:
			return TransactionResult.new(false, 0) #Success, residual

		DebtMode.TAKE_AVAILABLE_NO_DEBT:
			var deficit = inventory.items[item] - amount
			inventory.items[item] = 0
			return TransactionResult.new(true, deficit) #Success, residual

		DebtMode.TAKE_FULL_IF_CLEAR:
			if inventory.items[item] > 0:
				var deficit = max(0, inventory.items[item]) - amount
				inventory.items[item] -= amount
				return TransactionResult.new(true, deficit) #Success, residual
			else:
				return TransactionResult.new(false, 0) #Success, residual

		DebtMode.TAKE_FULL_ALLOW_DEBT:
			var deficit = max(0, inventory.items[item]) - amount
			inventory.items[item] -= amount
			return TransactionResult.new(true, deficit) #Success, residual

	return TransactionResult.new(false, 0) #Success,residual


func deposit(item:InventoryItem, amount:float, overflow_mode:= OverflowMode.DEPOSIT_NONE_NO_OVERFLOW) -> TransactionResult:
	if size.items[item] - inventory.items[item]  >= amount:
		inventory.items[item] += amount
		return TransactionResult.new(true, 0) #Success, residual

	match overflow_mode:
		OverflowMode.DEPOSIT_NONE_NO_OVERFLOW:
			return TransactionResult.new(false, 0) #Success,residual
			
		OverflowMode.DEPOSIT_AVAILABLE_NO_OVERFLOW:
			var overflow = size.items[item] - (inventory.items[item] + amount)
			inventory.items[item] = size.items[item]
			return TransactionResult.new(true, overflow) #Success,residual

		OverflowMode.DEPOSIT_ALL_IF_CLEAR:
			if inventory.items[item] < size.items[item]:
				var overflow = size.items[item] - (inventory.items[item] + amount)
				inventory.items[item]+= amount
				return TransactionResult.new(true, overflow) #Success,residual
			else:
				return TransactionResult.new(false, 0) #Success, residual

		OverflowMode.DEPOSIT_ALL_ALLOW_OVERFLOW:
			var overflow = size.items[item] - (min(inventory.items[item], size.items[item]) + amount)
			inventory.items[item]+= amount
			return TransactionResult.new(true, overflow) #Success,residual

	return TransactionResult.new(false, 0) #Success,residual
