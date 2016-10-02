local settings = {
	axeActivatorSide = "top",
	axeRechargerDirection = "south",
	meInterfaceSide = "right",
	meExtractDirection = "west",
	sonicSensorSide = "left",
	plantingPosition = {
		Y = 1,
		X = -1,
		Z = -1
	},
	boneMealStack = {
		id = 351,
		dmg = 15,
		qty = 1
	},
	saplingID = 2137,
	boneMealCraftingQuantity = 63,
	activatorPeripheralType = "tile_thermalexpansion_device_activator_name",
	meInterfacePeripheralType = "me_interface",
	sensorPeripheralType = "sensor"
}

function mainLoop()
	print("SaplingFarm started.")
	init()
	
	while true do
		checkBoneMealSupply()
		local stack = getLowestQuantityStack()
		if stack ~= nil then
			print("Transferring sapling to planter activator")
			transferStackToActivator(stack)
			waitUntilBlockType("UNKNOWN")
			
			print("Transferring bone meal to planter activator")
			transferStackToActivator(settings.boneMealStack)
			waitUntilBlockType("SOLID")
			
			print("Chopping tree")
			chopTree()
			
			print("Recharging axe")
			rechargeAxe()
		else
			print("Warning: No saplings were found in storage, waiting 5 minutes...")
			sleep(5 * 60)
		end
	end
end

function init()
	redstone.setOutput(settings.axeActivatorSide, false)
	validatePeripheralType(settings.axeActivatorSide, settings.activatorPeripheralType)
	validatePeripheralType(settings.meInterfaceSide, settings.meInterfacePeripheralType)
	validatePeripheralType(settings.sonicSensorSide, settings.sensorPeripheralType)
	if getCurrentBlockType() ~= nil then
		error("Block at sapling planting location, cannot start")
	end
end

function getLowestQuantityStack()
	local me = peripheral.wrap(settings.meInterfaceSide)
	local selectedStack = {}
	local lowestQuantity = -1
	for _, v in pairs(me.getAvailableItems()) do
		if v["id"] == settings.saplingID then
			if lowestQuantity == -1 or v["qty"] < lowestQuantity then
				lowestQuantity = v["qty"]
				selectedStack = {
					id = v["id"],
					dmg = v["dmg"],
					qty = 1
				}
			end
		end
	end
	
	if lowestQuantity ~= -1 then
		return selectedStack
	end
end

function checkBoneMealSupply()
	local me = peripheral.wrap(settings.meInterfaceSide)
	local quantity = getAEQuantity(me, settings.boneMealStack.id, settings.boneMealStack.dmg)
	if quantity == 0 then
		print("Bone meal supply depleted, crafting more...")
		craftAEItem(me, settings.boneMealStack.id, settings.boneMealStack.dmg, settings.boneMealCraftingQuantity, true)
	end
end

function transferStackToActivator(stack)
	local me = peripheral.wrap(settings.meInterfaceSide)
	local itemsExtracted = me.extractItem(stack, settings.meExtractDirection)
	if itemsExtracted ~= 1 then
		error("Unexpected result extracting stack ("..itemsExtracted..")")
	end
end

function chopTree()
	redstonePulse(settings.axeActivatorSide)
	waitWhileBlockType("SOLID")
	print("Block has disappeared, tree seems to have been chopped")
end

function rechargeAxe()
	local axeActivator = peripheral.wrap(settings.axeActivatorSide)
	if axeActivator.pushItem(settings.axeRechargerDirection, 1) ~= 1 then
		print("Warning: Failed to push the axe into the charger")
	end
	
	print("Waiting for the axe to reappear in slot 1 of the activator...")
	while axeActivator.getStackInSlot(1) == nil do
		sleep(1)
	end
end

function getCurrentBlockType()
	return getBlockType(settings.sonicSensorSide, settings.plantingPosition)
end

function waitUntilBlockType(blockType)
	print("Waiting for block type "..blockType.." to appear...")
	while getCurrentBlockType() ~= blockType do
		sleep(1)
	end
end

function waitWhileBlockType(blockType)
	print("Waiting for block type "..blockType.." to disappear...")
	while getCurrentBlockType() == blockType do
		sleep(1)
	end
end

-- Generic functions

function getAEQuantity(peripheral, id, dmg)
	local quantity = 0
	for _, v in pairs(peripheral.getAvailableItems()) do
		if v.id == id and v.dmg == dmg then
			quantity = v.qty
		end
	end
	
	return quantity
end

function craftAEItem(peripheral, id, dmg, quantity, wait)
	local currentQuantity = getAEQuantity(peripheral, id, dmg)
	local stack = {
		id = id,
		dmg = dmg,
		qty = quantity
	}
	
	peripheral.requestCrafting(stack)
	if wait then
		local targetQuantity = currentQuantity + quantity
		while currentQuantity < targetQuantity do
			sleep(1)
			currentQuantity = getAEQuantity(peripheral, id, dmg)
		end
	end
end

function getBlockType(sensorSide, position)
	os.loadAPI("ocs/apis/sensor")
	local s = sensor.wrap(sensorSide)
	for _, v in pairs(s.getTargets()) do
		if samePosition(v.Position, position) then
			return v.Type
		end
	end
end

function samePosition(pos1, pos2)
	return pos1.X == pos2.X and pos1.Y == pos2.Y and pos1.Z == pos2.Z
end

function validatePeripheralType(side, expectedType)
	local actualType = peripheral.getType(side)
	if actualType ~= expectedType then
		error("Unexpected peripheral type on side '"..side.."': '"..actualType.."' (expected '"..expectedType.."')")
	end
end

function redstonePulse(side)
	redstone.setOutput(side, true)
	sleep(1)
	redstone.setOutput(side, false)
end

mainLoop()
