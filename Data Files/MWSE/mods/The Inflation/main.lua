local config = require("The Inflation.config").config
local netWorth = require("The Inflation.config").netWorth

local function getPlayerNetWorth()
	local worth = 0

	if config.netWorthCaluclation == netWorth.goldOnly then
		worth = tes3.getPlayerGold()

	elseif config.netWorthCaluclation == netWorth.equippedItems then
		for _, stack in pairs(tes3.player.object.equipment) do
			local item = stack.object
            worth = worth + item.value
        end
	elseif config.netWorthCaluclation == netWorth.wholeInventory then
		for _, itemStack in pairs(tes3.player.object.inventory) do
			local item = itemStack.object
            worth = worth + item.value * itemStack.count
		end
	end

	if config.spellsAffectNetWorth then	
		for _, spell in pairs(tes3.player.object.spells.iterator) do
			if spell.castType == tes3.spellType.spell then
				worth = worth + spell.value
			end
		end
	end

	return worth
end

local function changeGenericPrice(e)
	local pw = getPlayerNetWorth()
	local mod = math.max(1, math.log(pw / e.basePrice, config.base))
	mod = mod ^ config.genericExp

	e.price = e.price * mod
end

local function changeSpellPrice(e)
	local pw = getPlayerNetWorth()
	local mod = math.max(1, math.log(pw / e.basePrice, config.base))
	mod = mod ^ config.spellExp

	e.price = e.price * mod
end

local function changeTrainingPrice(e)
	local pw = getPlayerNetWorth()
	local mod = math.max(1, math.log(pw, e.basePrice * 10))
	mod = mod ^ config.trainingExp

	e.price = e.price * mod
end

local function changeBarterPrice(e)
	local mod

	if e.buying then
		local pw = getPlayerNetWorth()
		mod = math.max(1, math.log(pw, e.basePrice * 10))
		mod = mod ^ config.barterExp

	else
		mod = 1
	end

	e.price = e.price * mod
end

event.register("initialized", function()
	event.register("calcRepairPrice", changeGenericPrice)
	event.register("calcTravelPrice", changeGenericPrice)
	event.register("calcSpellPrice", changeSpellPrice)

	event.register("calcTrainingPrice", changeTrainingPrice)
	event.register("calcBarterPrice", changeBarterPrice)
end)
event.register("modConfigReady", function()
	require("The Inflation.mcm")
end)