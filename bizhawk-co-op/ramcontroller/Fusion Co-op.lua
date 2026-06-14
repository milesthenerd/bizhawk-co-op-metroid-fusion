-- Writes value to RAM using little endian
function writeRAM(domain, address, size, value)
	memory.usememorydomain(domain)

	-- default size short
	if (size == nil) then
		size = 2
	end

	if (value == nil) then
		return
	end

	if size == 1 then
		memory.writebyte(address, value)
	elseif size == 2 then
		memory.write_u16_le(address, value)
	elseif size == 4 then
		memory.write_u32_le(address, value)
	end
end

-- Reads a value from RAM using little endian
function readRAM(domain, address, size)
	memory.usememorydomain(domain)

	-- default size short
	if (size == nil) then
		size = 2
	end

	if size == 1 then
		return memory.readbyte(address)
	elseif size == 2 then
		return memory.read_u16_le(address)
	elseif size == 4 then
		return memory.read_u32_le(address)
	end
end

function do_tables_match(a, b)
    return table.concat(a) == table.concat(b)
end

function difference(a, b)
    local ret = {}
	for k,v in pairs(a) do
		if(v ~= b[k]) then
			ret[k] = b[k]
		end
	end
    return ret
end

local abilityRAM = readRAM("System Bus", 0x300131A, 4)
local tankRAM = memory.readbyterange(0x2037200, 0xA00)
local mapRAM = memory.readbyterange(0x2037C00, 0x400)
local currMapRAM = memory.readbyterange(0x2034000, 0x800)
local areaID = readRAM("System Bus", 0x300002C, 1)
local bossRAM = readRAM("System Bus", 0x30006BA, 2)
local dataRoomRAM = readRAM("System Bus", 0x300134B, 1)
local destroyedStabilizers = readRAM("System Bus", 0x30006AE, 2)
local destroyedXBarriers = readRAM("System Bus", 0x30006B0, 2)
local destroyedXSuperBarriers = readRAM("System Bus", 0x30006B2, 2)
local destroyedXPowerBarriers = readRAM("System Bus", 0x30006B4, 2)
local destroyedEyedoors = readRAM("System Bus", 0x30006B6, 2)
local destroyedHatch = readRAM("System Bus", 0x30006B8, 1)
local waterFlag = readRAM("System Bus", 0x30006B9, 1)

-- Needed for randovania support, only tracks Sector 3 tank collection otherwise
local metroidCounter = readRAM("System Bus", 0x300003E, 1)

-- Gets the list of the abilities in RAM
function getAbility()
	local ability = {}
	flags = readRAM("System Bus", 0x300131A, 4)

	if(abilityRAM ~= flags) then
		print(flags)
		print(abilityRAM)
		if(math.abs(flags - abilityRAM) ~= 8388608) then ability[0] = flags end
		abilityRAM = flags
		--print("changed")
		--print(ability)
	end
	return ability
end

-- Gets the list of all the event states
function getEvents()
	local events = {}
	local check = do_tables_match(mapRAM, memory.readbyterange(0x2037C00, 0x400))
	local check2 = do_tables_match(currMapRAM, memory.readbyterange(0x2034000, 0x800))

	if(check ~= true or check2 ~= true) then
		--print("bruh map")
		events[0] = difference(mapRAM, memory.readbyterange(0x2037C00, 0x400))
		events[1] = difference(currMapRAM, memory.readbyterange(0x2034000, 0x800))
		events[2] = readRAM("System Bus", 0x300002C, 1)
		--print(events[2])
		mapRAM = memory.readbyterange(0x2037C00, 0x400)
		currMapRAM = memory.readbyterange(0x2034000, 0x800)
		--print(events[0])
	end

	if(bossRAM ~= readRAM("System Bus", 0x30006BA, 2)) then
		events[3] = readRAM("System Bus", 0x30006BA, 2)
		bossRAM = readRAM("System Bus", 0x30006BA, 2)
	end

	if(dataRoomRAM ~= readRAM("System Bus", 0x300134B, 1)) then
		events[4] = readRAM("System Bus", 0x300134B, 1)
		dataRoomRAM = readRAM("System Bus", 0x300134B, 1)
	end

	if(destroyedStabilizers ~= readRAM("System Bus", 0x30006AE, 2)) then
		events[5] = readRAM("System Bus", 0x30006AE, 2)
		destroyedStabilizers = readRAM("System Bus", 0x30006AE, 2)
	end

	if(destroyedXBarriers ~= readRAM("System Bus", 0x30006B0, 2)) then
		events[6] = readRAM("System Bus", 0x30006B0, 2)
		destroyedXBarriers = readRAM("System Bus", 0x30006B0, 2)
	end

	if(destroyedXSuperBarriers ~= readRAM("System Bus", 0x30006B2, 2)) then
		events[7] = readRAM("System Bus", 0x30006B2, 2)
		destroyedXSuperBarriers = readRAM("System Bus", 0x30006B2, 2)
	end

	if(destroyedXPowerBarriers ~= readRAM("System Bus", 0x30006B4, 2)) then
		events[8] = readRAM("System Bus", 0x30006B4, 2)
		destroyedXPowerBarriers = readRAM("System Bus", 0x30006B4, 2)
	end

	if(destroyedEyedoors ~= readRAM("System Bus", 0x30006B6, 2)) then
		events[9] = readRAM("System Bus", 0x30006B6, 2)
		destroyedEyedoors = readRAM("System Bus", 0x30006B6, 2)
	end

	if(destroyedHatch ~= readRAM("System Bus", 0x30006B8, 1)) then
		events[10] = readRAM("System Bus", 0x30006B8, 1)
		destroyedHatch = readRAM("System Bus", 0x30006B8, 1)
	end

	if(waterFlag ~= readRAM("System Bus", 0x30006B9, 1)) then
		events[11] = readRAM("System Bus", 0x30006B9, 1)
		waterFlag = readRAM("System Bus", 0x30006B9, 1)
	end

	if(readRAM("System Bus", 0x3000B87, 1) == 0x67) then
		writeRAM("System Bus", 0x3000B87, 1, 0x69)
		events[12] = readRAM("System Bus", 0x3000B87, 1)
	end

	if(metroidCounter ~= readRAM("System Bus", 0x300003E, 1)) then
		events[13] = readRAM("System Bus", 0x300003E, 1)
		metroidCounter = readRAM("System Bus", 0x300003E, 1)
	end

	return events
end

-- Gets the list of ammo values and capacities
function getAmmo()
	return {
		energyCapacity = readRAM("System Bus", 0x3001312, 2),
		missileCapacity = readRAM("System Bus", 0x3001316, 2),
		powerCapacity = readRAM("System Bus", 0x3001319, 1),

		energyCount = readRAM("System Bus", 0x3001310, 2),
		missileCount = readRAM("System Bus", 0x3001314, 2),
		powerCount = readRAM("System Bus", 0x3001318, 1)
	}
end

-- Event to check if a new tank is collected
-- Reverts changes if the tank has been collected already
-- Does not send ammo updates if new tank is found
local prevCollectingTankFlag = 0
function eventTankCollected()
	local tanks = {}
	local check = do_tables_match(tankRAM, memory.readbyterange(0x2037200, 0xA00))

	if(check ~= true) then
		--print("bruh")
		tanks[0] = difference(tankRAM, memory.readbyterange(0x2037200, 0xA00))
		tankRAM = memory.readbyterange(0x2037200, 0xA00)
		--print(tanks[0])
		return tanks
	end
	return false
end

-- Event to check when a new ability is collected
function eventAbilityCollected(prevRam, newRam)
	-- Find changed ability
	-- Only one ability can be collected at a time
	-- Only checks for added abilities, not removed (varia)
	if(newRam.ability[0] ~= nil and prevRam.ability[0] ~= newRam.ability[0]) then
		prevRam.ability = newRam.ability
		--print(newRam.ability)
		return {
			[0] = newRam.ability[0]
		}
	end

	-- No new ability
	return false
end

-- Event to check if any game events have changed
function eventTriggerEvent(prevRam, newRam)
    local changed = false
    for i = 0, 13 do
        if newRam.events[i] ~= nil and prevRam.events[i] ~= newRam.events[i] then
            changed = true
            break
        end
    end

    if not changed then return false end

    prevRam.events = newRam.events
    return newRam.events
end

-- Event to check if any ammo changed
-- Will not have any changes if a tank was collected
function eventAmmoChange(prevRam, newRam)
	local deltaammo = {}
	local changed = false

	if (prevRam.ammo.energyCount > 0) then
		-- If alive, send delta changes. Don't check for capacities (handled in tank event)
		deltaammo.delta = true

		-- Check energy capacity changes
		if (newRam.ammo.energyCapacity ~= prevRam.ammo.energyCapacity) then
			deltaammo.energyCapacity = newRam.ammo.energyCapacity - prevRam.ammo.energyCapacity
			changed = true			
		end
		-- Check missile capacity changes
		if (newRam.ammo.missileCapacity ~= prevRam.ammo.missileCapacity) then
			deltaammo.missileCapacity = newRam.ammo.missileCapacity - prevRam.ammo.missileCapacity
			changed = true			
		end
		-- Check power capacity changes
		if (newRam.ammo.powerCapacity ~= prevRam.ammo.powerCapacity) then
			deltaammo.powerCapacity = newRam.ammo.powerCapacity - prevRam.ammo.powerCapacity
			changed = true			
		end		
		-- Check energy count changes
		if (newRam.ammo.energyCount ~= prevRam.ammo.energyCount) then
			deltaammo.energyCount = newRam.ammo.energyCount - prevRam.ammo.energyCount
			changed = true			
		end
		-- Check missile count changes
		if (newRam.ammo.missileCount ~= prevRam.ammo.missileCount) then
			deltaammo.missileCount = newRam.ammo.missileCount - prevRam.ammo.missileCount
			changed = true			
		end
		-- Check power bomb count changes
		if (newRam.ammo.powerCount ~= prevRam.ammo.powerCount) then
			deltaammo.powerCount = newRam.ammo.powerCount - prevRam.ammo.powerCount
			changed = true			
		end
	else 
		-- Was dead, send override values. Check counts AND capacities
		deltaammo.delta = false
		for ammo, value in pairs(newRam.ammo) do
			if (prevRam.ammo[ammo] ~= value) then
				deltaammo[ammo] = value
				changed = true			
			end
		end		
	end

	if changed then
		-- return any changes
		return deltaammo
	else 
		-- ammo is unchanged
		return false
	end
end


-- This sets a tank to be collected and give the appropriate ammo
-- Does not trigger for tanks that have already been collected
function setTankCollected(prevRAM, newTank)
	--print("what")
	--print(newTank[0])
	for k,v in pairs(newTank[0]) do
		writeRAM("System Bus", 0x2037200 + k, 1, v)
	end

	tankRAM = memory.readbyterange(0x2037200, 0xA00)
	prevRAM.tanks = tankRAM
	-- Return changes
	return prevRAM
end

-- Set an ability to be collected
function setAbilityCollected(prevAbility, newAbility)
	--print(newAbility)
	prevAbility = newAbility
	writeRAM("System Bus", 0x300131A, 4, newAbility[0])
	writeRAM("System Bus", 0x300001C, 1, readRAM("System Bus", 0x300131D))
	return prevAbility
end

function removeTankFromRoom()
	-- TODO
end

function removeAbilityFromRoom()
	-- TODO
end

-- Set a game event state to new state
function setEvent(prevEvent, newEvent)
	-- for each even change...
	--print("what")
	--print(newEvent[0])
	if(newEvent[0] ~= nil) then
		for k,v in pairs(newEvent[0]) do
			writeRAM("System Bus", 0x2037C00 + k, 1, v)
		end
		mapRAM = memory.readbyterange(0x2037C00, 0x400)
	end

	--print(readRAM("System Bus", 0x300002C, 1))
	--print(newEvent[2])
	if(newEvent[1] ~= nil and newEvent[2] ~= nil and readRAM("System Bus", 0x300002C, 1) == newEvent[2]) then
		--print("no???")
		for k,v in pairs(newEvent[1]) do
			writeRAM("System Bus", 0x2034000 + k, 1, v)
		end
		currMapRAM = memory.readbyterange(0x2034000, 0x800)
	end

	if(newEvent[3] ~= nil) then
		writeRAM("System Bus", 0x30006BA, 2, newEvent[3])
		bossRAM = readRAM("System Bus", 0x30006BA, 2)
	end

	if(newEvent[4] ~= nil) then
		writeRAM("System Bus", 0x300134B, 1, newEvent[4])
		dataRoomRAM = readRAM("System Bus", 0x300134B, 1)
	end

	if(newEvent[5] ~= nil) then
		writeRAM("System Bus", 0x30006AE, 2, newEvent[5])
		destroyedStabilizers = readRAM("System Bus", 0x30006AE, 2)
	end

	if(newEvent[6] ~= nil) then
		writeRAM("System Bus", 0x30006B0, 2, newEvent[6])
		destroyedXBarriers = readRAM("System Bus", 0x30006B0, 2)
	end

	if(newEvent[7] ~= nil) then
		writeRAM("System Bus", 0x30006B2, 2, newEvent[7])
		destroyedXSuperBarriers = readRAM("System Bus", 0x30006B2, 2)
	end

	if(newEvent[8] ~= nil) then
		writeRAM("System Bus", 0x30006B4, 2, newEvent[8])
		destroyedXPowerBarriers = readRAM("System Bus", 0x30006B4, 2)
	end

	if(newEvent[9] ~= nil) then
		writeRAM("System Bus", 0x30006B6, 2, newEvent[9])
		destroyedEyedoors = readRAM("System Bus", 0x30006B6, 2)
	end

	if(newEvent[10] ~= nil) then
		writeRAM("System Bus", 0x30006B8, 1, newEvent[10])
		destroyedHatch = readRAM("System Bus", 0x30006B8, 1)
	end

	if(newEvent[11] ~= nil) then
		writeRAM("System Bus", 0x30006B9, 1, newEvent[11])
		waterFlag = readRAM("System Bus", 0x30006B9, 1)
	end

	if(newEvent[12] ~= nil) then
		writeRAM("System Bus", 0x3000B87, 1, newEvent[12])
	end

	if(newEvent[13] ~= nil) then
		writeRAM("System Bus", 0x300003E, 1, newEvent[13])
		metroidCounter = readRAM("System Bus", 0x300003E, 1)
	end

	prevEvent = newEvent
	-- Return changes
	return prevEvent

end

-- Set ammo counts to new updates
function setAmmo(prevAmmo, deltaAmmo)
	local newAmmo = {}
	if deltaAmmo.delta then
		-- If incremental delta changes, add values to current values
		-- deltas may be negative to subtract
		-- bound the updated values with the capacity and 0
		newAmmo.energyCapacity = math.max(prevAmmo.energyCapacity + 
			(deltaAmmo.energyCapacity or 0), 0)
		newAmmo.missileCapacity = math.max(prevAmmo.missileCapacity + 
			(deltaAmmo.missileCapacity or 0), 0)
		newAmmo.powerCapacity = math.max(prevAmmo.powerCapacity + 
			(deltaAmmo.powerCapacity or 0), 0)

		newAmmo.energyCount = math.max(math.min(prevAmmo.energyCount + 
			(deltaAmmo.energyCount or 0), newAmmo.energyCapacity), 0)
		newAmmo.missileCount = math.max(math.min(prevAmmo.missileCount + 
			(deltaAmmo.missileCount or 0), newAmmo.missileCapacity), 0)
		newAmmo.powerCount = math.max(math.min(prevAmmo.powerCount + 
			(deltaAmmo.powerCount or 0), newAmmo.powerCapacity), 0)
	else
		-- If override changes, set the new value discarding the old value
		for ammo,value in pairs(prevAmmo) do
			newAmmo[ammo] = deltaAmmo[ammo] or value
		end

	end

	-- Update the counts in RAM
	writeRAM("System Bus", 0x3001312, 2, newAmmo.energyCapacity)
	writeRAM("System Bus", 0x3001316, 2, newAmmo.missileCapacity)
	writeRAM("System Bus", 0x3001319, 1, newAmmo.powerCapacity)
	writeRAM("System Bus", 0x3001310, 2, newAmmo.energyCount)
	writeRAM("System Bus", 0x3001314, 2, newAmmo.missileCount)
	writeRAM("System Bus", 0x3001318, 1, newAmmo.powerCount)

	return newAmmo
end

-- Object that exposes the public functions
local mf_ram = {}

-- RAM state from previous frame
local prevRAM = {
	ammo = {
		energyCount = 0,
		energyCapacity = 0,
		missileCount = 0,
		missileCapacity = 0,
		powerCount = 0,
		powerCapacity = 0
	},

	tanks = {},
	ability = {},
	events = {}
}

-- Gets a message to send to the other player of new changes
-- Returns the message as a dictionary object
-- Returns false if no message is to be send
function mf_ram.getMessage()

	-- Gets the current RAM state
	local newRAM = {
		tanks = prevRAM.tanks,
		ability = getAbility(),
		events = getEvents(),
		ammo = getAmmo()
	}

	local message = {}
	local changed = false
	local newTank

	-- Gets the message for a new collected tank
	-- Also updates the states to squelch some changes
	newTank = eventTankCollected()
	if newTank then
		-- Add new changes
		message["t"] = newTank
		changed = true
	end

	-- Gets the message for a new collected ability
	local newAbility = eventAbilityCollected(prevRAM, newRAM)
	if newAbility then
		-- Add new changes
		message["a"] = newAbility
		changed = true
	end

	-- Gets the message for all changed game events
	local newEvent = eventTriggerEvent(prevRAM, newRAM)
	if newEvent then
		-- Add new changes
		message["e"] = newEvent
		changed = true
	end

	-- Gets the message for all updated ammo count/capacity
	local newAmmo = eventAmmoChange(prevRAM, newRAM)
	if newAmmo then
		-- Add new changes
		message["m"] = newAmmo
		changed = true
	end

	-- Update the frame pointer
	prevRAM = newRAM

	if changed then
		-- Send message
		return message
	else 
		-- No updates, no message
		return false
	end
end

-- Process a message from another player and update RAM
function mf_ram.processMessage(their_user, message)
	-- Process new tank collected
	-- Does nothing if tank was already collected
	if message["t"] then
		prevRAM = setTankCollected(prevRAM, message["t"])
	end

	-- Process new ability collected
	if message["a"] then
		prevRAM.ability = setAbilityCollected(prevRAM.ability, message["a"])
	end

	-- process all changed game events
	if message["e"] then
		prevRAM.events = setEvent(prevRAM.events, message["e"])
	end

	-- process all ammo updates
	if message["m"] then
		prevRAM.ammo = setAmmo(prevRAM.ammo, message["m"])
	end
end

mf_ram.itemcount = 100

return mf_ram