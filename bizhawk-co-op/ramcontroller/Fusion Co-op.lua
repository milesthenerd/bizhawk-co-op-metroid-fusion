local mf_ram = {}

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

-- Reads a range of values from RAM using little endian
function readRAMRange(domain, address, length)
    memory.usememorydomain(domain)
    return memory.readbyterange(address, length)
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
local tankRAM = readRAMRange("System Bus", 0x2037200, 0xA00)
local mapRAM = readRAMRange("System Bus", 0x2037C00, 0x400)
local currMapRAM = readRAMRange("System Bus", 0x2034000, 0x800)
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

		-- If a positive capacity rise matches a pending shared-reward
		-- credit (the other player already granted us this exact reward via sync),
		-- it's a DUPLICATE physical collect/absorb of the same item. Consume the
		-- credit, revert our local capacity (RAM + newRam so we don't re-gain), and
		-- return true to suppress sending the delta. Otherwise return false.
		local function consumeCredit(kind, curAddr, capAddr, curSize, newCap, prevCap)
			mf_ram.cap_credit = mf_ram.cap_credit or {}
			local rise = newCap - prevCap
			local credit = mf_ram.cap_credit[kind] or 0
			if rise > 0 and credit >= rise then
				mf_ram.cap_credit[kind] = credit - rise
				writeRAM("System Bus", capAddr, 2, prevCap)   -- revert the duplicate max bump
				newRam.ammo[kind .. "Capacity"] = prevCap     -- keep sync state consistent
				local cur = readRAM("System Bus", curAddr, curSize)
				local newCur = math.max(0, math.min(cur - rise, prevCap))
				writeRAM("System Bus", curAddr, curSize, newCur)
				newRam.ammo[kind .. "Count"] = newCur
				return true
			end
			return false
		end

		-- Check energy capacity changes
		if (newRam.ammo.energyCapacity ~= prevRam.ammo.energyCapacity) then
			if not consumeCredit("energy", 0x3001310, 0x3001312, 2, newRam.ammo.energyCapacity, prevRam.ammo.energyCapacity) then
				deltaammo.energyCapacity = newRam.ammo.energyCapacity - prevRam.ammo.energyCapacity
				changed = true			
			end
		end
		-- Check missile capacity changes
		if (newRam.ammo.missileCapacity ~= prevRam.ammo.missileCapacity) then
			if not consumeCredit("missile", 0x3001314, 0x3001316, 2, newRam.ammo.missileCapacity, prevRam.ammo.missileCapacity) then
				deltaammo.missileCapacity = newRam.ammo.missileCapacity - prevRam.ammo.missileCapacity
				changed = true			
			end
		end
		-- Check power capacity changes
		if (newRam.ammo.powerCapacity ~= prevRam.ammo.powerCapacity) then
			if not consumeCredit("power", 0x3001318, 0x3001319, 1, newRam.ammo.powerCapacity, prevRam.ammo.powerCapacity) then
				deltaammo.powerCapacity = newRam.ammo.powerCapacity - prevRam.ammo.powerCapacity
				changed = true			
			end
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
		-- A positive capacity delta is a shared reward the other player earned.
		-- Record a pending credit per type once per player. Skip on fromTank=true
		if not deltaAmmo.fromTank then
			mf_ram.cap_credit = mf_ram.cap_credit or {}
			if (deltaAmmo.energyCapacity or 0) > 0 then
				mf_ram.cap_credit.energy = (mf_ram.cap_credit.energy or 0) + deltaAmmo.energyCapacity
			end
			if (deltaAmmo.missileCapacity or 0) > 0 then
				mf_ram.cap_credit.missile = (mf_ram.cap_credit.missile or 0) + deltaAmmo.missileCapacity
			end
			if (deltaAmmo.powerCapacity or 0) > 0 then
				mf_ram.cap_credit.power = (mf_ram.cap_credit.power or 0) + deltaAmmo.powerCapacity
			end
		end

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

-- Object that exposes the public functions (declared at top of file)

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

	-- Tank collection detection lifecycle:
	--   normal tank:  0x0062 ----------------> 0x0000   (collect)
	--   hidden tank:  0x0065 -> 0x801D -------> 0x0000   (reveal, then collect)
	-- We notify the other player ONLY on actual collection (tile reaches 0x0000),
	-- identified by watching tiles that have held a tank value (0x62-0x6A).
	local TANK_VALS = {
		[0x62] = true,  -- missile tank
		[0x63] = true,  -- energy tank
		[0x64] = true,  -- hidden missile tank
		[0x65] = true,  -- hidden energy tank
		[0x66] = true,  -- underwater missile tank
		[0x67] = true,  -- underwater energy tank
		[0x68] = true,  -- power bomb tank
		[0x69] = true,  -- hidden power bomb tank
		[0x6A] = true,  -- underwater power bomb tank
	}
	do
		local width = readRAM("System Bus", 0x3000088, 2)
		if width and width > 0 then
			local area = readRAM("System Bus", 0x300002C, 1)
			local room = readRAM("System Bus", 0x300002D, 1)
			memory.usememorydomain("System Bus")

			local REGION_TILES = 0x1800
			local same_room = (mf_ram.clip_area == area) and (mf_ram.clip_room == room)
			local armed = (same_room and mf_ram.tank_armed) or {}  -- { [idx] = true }

			local clip = memory.readbyterange(0x2026000, REGION_TILES * 2)
			-- readbyterange may be 0- or 1-indexed depending on BizHawk version;
			-- detect once by probing for a [0] key.
			local b0 = (clip[0] ~= nil) and 0 or 1

			-- Single pass: arm tiles holding a tank value, and detect armed tiles
			-- that have gone empty (collected).
			for idx = 0, REGION_TILES - 1 do
				local p = b0 + idx * 2
				local v = clip[p] + clip[p + 1] * 256
				if TANK_VALS[v] then
					armed[idx] = true
				elseif v == 0 and armed[idx] and same_room then
					local x = idx % width
					local y = math.floor(idx / width)
					message["tank"] = { a = area, r = room, x = x, y = y }
					changed = true
					armed[idx] = nil
				end
			end

			mf_ram.tank_armed = armed
			mf_ram.clip_area = area
			mf_ram.clip_room = room
		end
	end

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
		-- Tag capacity changes that came from a world tank collect using the
		-- "Collecting tank flag" (0x3000026), which is set during world tank
		-- collection and NOT during Core-X absorbs. This stays set for multiple
		-- frames so it's reliable even if the capacity update lags CollectedTank
		-- by a frame. The receiver uses this tag to skip arming a duplicate-absorb
		-- credit — world tanks are handled by tile removal; the credit is only
		-- needed for Core-X rewards where both players can absorb their own copy.
		if readRAM("System Bus", 0x3000026, 1) ~= 0 then
			newAmmo.fromTank = true
		end
		message["m"] = newAmmo
		changed = true
	end

	-- Room ID: 0x300002E is the current room index within the area.
	local cur_pos = {
		x    = readRAM("System Bus", 0x300125A, 2),
		y    = readRAM("System Bus", 0x300125C, 2),
		area = readRAM("System Bus", 0x300002C, 1),
		room = readRAM("System Bus", 0x300002D, 1),  -- current room (not last door)
	}

	local nowf = readRAM("System Bus", 0x3000002, 2)
	local lp = mf_ram.my_last_pos
	local moved = (not lp)
	              or cur_pos.x    ~= lp.x
	              or cur_pos.y    ~= lp.y
	              or cur_pos.area ~= lp.area
	              or cur_pos.room ~= lp.room
	local keepalive = (not mf_ram.my_last_pos_frame)
	                  or ((nowf - mf_ram.my_last_pos_frame) % 65536 >= 45)
	if moved or keepalive then
		message["pos"] = cur_pos
		mf_ram.my_last_pos = cur_pos
		mf_ram.my_last_pos_frame = nowf
		changed = true
	end

	if mf_ram.my_sprite and mf_ram.my_sprite_dirty then
		message["spr"] = mf_ram.my_sprite   -- {rle=..., pal=...}
		mf_ram.my_sprite_dirty = false
		changed = true
	end

	-- Projectile fire sync: DISABLED.
	if mf_ram.PROJ_SYNC then
		pcall(function()
			local cur = snapshotProjActive()
			if mf_ram.proj_injected then
				for slot in pairs(mf_ram.proj_injected) do
					if not cur[slot] then mf_ram.proj_injected[slot] = nil end
				end
			end
			local newly = findNewlyActiveSlots(mf_ram.proj_active_prev)
			mf_ram.proj_active_prev = cur
			if #newly > 0 then
				local fires = {}
				for _, slot in ipairs(newly) do
					if not (mf_ram.proj_injected and mf_ram.proj_injected[slot]) then
						fires[#fires + 1] = base64Encode(projEntryToString(readProjEntry(slot)))
					end
				end
				if #fires > 0 then
					message["fire"] = { e = fires }
					changed = true
				end
			end
		end)
	end

	-- Enemy/boss HP sync: detect HP drops on local enemies this frame (our shots
	-- landing) and broadcast the new HP keyed by Sprite ID, so the boss's health
	-- pool is shared. We compare against last frame's snapshot; any enemy whose HP
	-- decreased gets sent.
	pcall(function()
		local cur = snapshotEnemies()
		local prev = mf_ram.enemy_prev
		-- Suppress ALL enemy sync across a room/area change: the array is reused
		local area = readRAM("System Bus", 0x300002C, 1)
		local room = readRAM("System Bus", 0x300002D, 1)
		local room_changed = (mf_ram.hp_last_room ~= room) or (mf_ram.hp_last_area ~= area)
		mf_ram.hp_last_area, mf_ram.hp_last_room = area, room
		if prev and not room_changed then
			local hits = {}
			for key, e in pairs(cur) do
				local pe = prev[key]
				if pe and pe.id == e.id and e.hp < pe.hp then
					hits[#hits + 1] = { k = e.kind, id = e.id, s = e.slot, hp = e.hp }
				end
			end
			if #hits > 0 then
				message["hp"] = hits
				changed = true
			end

			-- DEATH CLONE: when an entity ENTERS its HP=0 transition this frame
			-- (HP reached 0 while still present), capture its FULL entry — the
			-- complete, game-authored state — and send it. The receiver writes it
			-- over its matching entity.
			local deaths = {}
			for key, e in pairs(cur) do
				local pe = prev[key]
				if pe and pe.id == e.id and pe.hp > 0 and e.hp == 0 then
					if e.kind == "m" then
						deaths[#deaths + 1] = {
							t = "m", id = e.id, s = e.slot,
							d = base64Encode(enemyEntryToString(readEnemyEntry(e.slot))),
						}
					elseif e.kind == "s" then
						deaths[#deaths + 1] = {
							t = "s", id = 0, s = e.slot,
							d = base64Encode(subEntryToString(readSubEntry(e.slot))),
						}
					end
				end
			end
			if #deaths > 0 and #deaths <= 3 then
				message["edie"] = deaths
				changed = true
			end
		end
		mf_ram.enemy_prev = cur
	end)

	-- Core-X dedupe: prevent both players absorbing the same Core-X (which would
	-- duplicate the granted item, e.g. in randomizers).
	pcall(function()
		local area = readRAM("System Bus", 0x300002C, 1)
		local room = readRAM("System Bus", 0x300002D, 1)
		local same_room = (mf_ram.corex_area == area) and (mf_ram.corex_room == room)

		-- Detect a savestate LOAD
		local fc = readRAM("System Bus", 0x3000002, 2)
		local loaded = false
		if mf_ram.corex_fc ~= nil then
			local delta = fc - mf_ram.corex_fc
			if delta < -8 and delta > -65000 then loaded = true end
		end
		mf_ram.corex_fc = fc

		-- Reset the per-room boss lifecycle on a room change OR a savestate load.
		if not same_room or loaded then
			mf_ram.boss_seen = false
			mf_ram.boss_dead = false
			mf_ram.corex_prev = nil
			-- Also drop any pending capacity credits: a reward not duplicated within
			-- its room is left behind
			mf_ram.cap_credit = {}
		end

		memory.usememorydomain("System Bus")
		local corexId = readRAM("System Bus", 0x30006AD, 1)
		local bossId  = readRAM("System Bus", 0x30006AC, 1)

		-- Scan the main array once for presence of the Core-X and the boss sprites.
		local corex_present, boss_present = false, false
		for slot = 0, SD_SLOTS - 1 do
			local base = SD_BASE + slot * SD_STRIDE
			if memory.read_u16_le(base + SD_F_STATUS) ~= 0 then
				local id = memory.readbyte(base + SD_F_SPRID)
				if corexId ~= 0 and id == corexId then corex_present = true end
				if bossId  ~= 0 and id == bossId  then boss_present = true end
			end
		end

		-- Track the boss lifecycle: seen alive, then gone => defeated. The REWARD
		-- Core-X (the one we dedupe) only appears AFTER the boss is defeated. The
		-- FORMATION Core-X appears BEFORE the boss exists, so boss_dead is false
		-- then and we correctly ignore its vanish
		if boss_present then mf_ram.boss_seen = true end
		if mf_ram.boss_seen and not boss_present then mf_ram.boss_dead = true end

		-- Absorption = the Core-X that was present last frame is gone now, same
		-- room, AND the boss has already been defeated (reward core, not formation).
		if mf_ram.corex_prev and not corex_present and same_room and mf_ram.boss_dead
		   and not loaded then
			message["corex"] = { a = area, r = room, id = mf_ram.corex_prev }
			changed = true
		end

		mf_ram.corex_prev = (corex_present and corexId) or nil
		mf_ram.corex_area, mf_ram.corex_room = area, room
	end)

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

	-- Per-player overlay state
	if message["pos"] or message["spr"] then
		local pl = mf_ram.players[their_user]
		if not pl then
			pl = {}
			mf_ram.players[their_user] = pl
		end

		if message["pos"] then
			pl.pos        = message["pos"]
			pl.last_frame = readRAM("System Bus", 0x3000002, 2)  -- arrival frame
		end

		if message["spr"] then
			local spr = message["spr"]
			-- Resolve palette: this message's, else the player's last cached one.
			local argb = pl.argb
			if spr.pal then
				argb = palToARGB(base64Decode(spr.pal))
				pl.argb = argb
			end
			-- Only commit if we have both a bitmap and a palette.
			if spr.rle and argb then
				pl.sprite = {
					buf  = rleDecode(base64Decode(spr.rle)),
					argb = argb,
				}
			end
		end
	end

	-- Projectile fire sync (inbound): DISABLED (see send-side note).
	if mf_ram.PROJ_SYNC and message["fire"] and their_user ~= config.user then
		pcall(function()
			local fire = message["fire"]
			local my_area = readRAM("System Bus", 0x300002C, 1)
			local my_room = readRAM("System Bus", 0x300002D, 1)
			local p = mf_ram.players[their_user]
			local same_room = p and p.pos
			                  and p.pos.area == my_area and p.pos.room == my_room
			if same_room and fire.e then
				local entries = fire.e
				if type(entries) ~= "table" then entries = { entries } end
				for _, enc in pairs(entries) do
					injectProjEntry(projEntryFromString(base64Decode(enc)))
				end
			end
		end)
	end

	-- Enemy/boss HP sync (inbound): apply the other player's damage to our copy
	-- of the matching enemy (matched by Sprite ID), MIN-merging so shared damage
	-- accumulates. Skip our own echoed events; only when in the same room.
	if message["hp"] and their_user ~= config.user then
		pcall(function()
			local my_area = readRAM("System Bus", 0x300002C, 1)
			local my_room = readRAM("System Bus", 0x300002D, 1)
			local p = mf_ram.players[their_user]
			local same_room = p and p.pos
			                  and p.pos.area == my_area and p.pos.room == my_room
			if same_room then
				local hits = message["hp"]
				for _, h in pairs(hits) do
					applyEnemyHP(h.k or "m", tonumber(h.id) or 0,
					             tonumber(h.s) or 0, tonumber(h.hp))
				end
			end
		end)
		end

	-- Death clone (inbound): the other instance sent a full dying-enemy entry.
	-- Write it over our matching enemy so our game runs the exact same death
	if message["edie"] and their_user ~= config.user then
		pcall(function()
			local my_area = readRAM("System Bus", 0x300002C, 1)
			local my_room = readRAM("System Bus", 0x300002D, 1)
			local p = mf_ram.players[their_user]
			local same_room = p and p.pos
			                  and p.pos.area == my_area and p.pos.room == my_room
			if same_room then
				local deaths = message["edie"]
				local done = 0
				for _, d in pairs(deaths) do
					if done < 3 and d.d then
						local t = d.t or "m"
						if t == "s" then
							-- sub-sprite: matched by slot index
							local slot = tonumber(d.s)
							if slot and slot >= 0 and slot < SS_SLOTS then
								memory.usememorydomain("System Bus")
								local base = SS_BASE + slot * SS_STRIDE
								if memory.read_u32_le(base + SS_F_OAM) ~= 0 then
									writeSubEntry(slot, subEntryFromString(base64Decode(d.d)))
									done = done + 1
								end
							end
						else
							-- main array: matched by Sprite ID
							local id = tonumber(d.id) or 0
							local slot = findEnemyByID(id, tonumber(d.s))
							if slot then
								writeEnemyEntry(slot, enemyEntryFromString(base64Decode(d.d)))
								done = done + 1
							end
						end
					end
				end
			end
		end)
	end

	-- Item (tank) removal (inbound): the other player collected a world tank.
	-- Remove the LIVE block in our room so we can't double-collect it. Clearing
	-- the CLIPDATA tile removes collision
	if message["tank"] and their_user ~= config.user then
		pcall(function()
			local my_area = readRAM("System Bus", 0x300002C, 1)
			local my_room = readRAM("System Bus", 0x300002D, 1)
			local t = message["tank"]
			if tonumber(t.a) == my_area and tonumber(t.r) == my_room then
				local width = readRAM("System Bus", 0x3000088, 2)
				if width and width > 0 then
					local x = tonumber(t.x) or 0
					local y = tonumber(t.y) or 0
					if x >= 0 and y >= 0 and x < width then
						local idx = y * width + x
						memory.usememorydomain("System Bus")
						local clip = 0x2026000 + idx * 2
						if memory.read_u16_le(clip) ~= 0 then
							memory.write_u16_le(clip, 0)
							memory.write_u16_le(0x202C000 + idx * 2, 0)
						end
					end
				end
			end
		end)
	end

	-- Core-X dedupe (inbound): the other player absorbed their Core-X. Remove ours.
	if message["corex"] and their_user ~= config.user then
		pcall(function()
			local my_area = readRAM("System Bus", 0x300002C, 1)
			local my_room = readRAM("System Bus", 0x300002D, 1)
			local c = message["corex"]
			if tonumber(c.a) == my_area and tonumber(c.r) == my_room then
				local id = tonumber(c.id) or 0
				if id ~= 0 then
					-- The other player absorbed this Core-X. Despawn our copy so our
					-- player can't also absorb it (varies in efficacy so the capacity credit exists).
					memory.usememorydomain("System Bus")
					for slot = 0, SD_SLOTS - 1 do
						local base = SD_BASE + slot * SD_STRIDE
						if memory.read_u16_le(base + SD_F_STATUS) ~= 0
						   and memory.readbyte(base + SD_F_SPRID) == id then
							memory.write_u16_le(base + SD_F_STATUS, 0)   -- despawn
						end
					end
				end
			end
		end)
	end
end

mf_ram.itemcount = 100
mf_ram.my_last_pos  = nil   -- tracks last sent pos to throttle pos messages
mf_ram.players      = {}    -- players[username] = {pos, sprite, argb, last_frame}
mf_ram.proj_active_prev = nil   -- previous-frame projectile active flags (fire sync)
mf_ram.proj_injected    = {}    -- slots holding injected remote shots (don't re-send)
mf_ram.PROJ_SYNC        = false -- projectile fire sync OFF: injected beams hit the
                                -- engine's per-type on-screen cap and block local
                                -- firing, and add no mechanic (HP sync covers damage)
mf_ram.enemy_prev       = nil   -- previous-frame enemy HP snapshot (HP sync)
mf_ram.corex_prev       = nil   -- Core-X sprite id present last frame (dedupe)
mf_ram.corex_area       = nil
mf_ram.corex_room       = nil
mf_ram.boss_seen        = false -- saw the boss sprite alive this room
mf_ram.boss_dead        = false -- boss was alive then vanished (defeated) this room
mf_ram.corex_fc         = nil   -- last frame counter (detects savestate load)
mf_ram.cap_credit       = {}    -- pending shared-reward capacity credits (dup cancel)

OAM_SIZES = {
    [0] = {{8,8},{16,16},{32,32},{64,64}},
    [1] = {{16,8},{32,8},{32,16},{64,32}},
    [2] = {{8,16},{8,32},{16,32},{32,64}},
}

-- Collect the OAM entries belonging to Samus, given her screen position
-- Palettes Samus is known to use. Adjust if she uses others (check diag output).
SAMUS_PALETTES = { [0]=true, [1]=true, [2]=true, [3]=true, [4]=true, [5]=true }

-- Max tile index for Samus sprites. Her tiles are always low-numbered;
-- high tile indices (256+) belong to environment objects and HUD elements.
SAMUS_TILE_MAX = 256

-- We capture a shot's whole 32-byte entry the frame it spawns and inject it
-- into a free slot on the receiver.
PROJ_BASE     = 0x3000960
PROJ_STRIDE   = 0x20
PROJ_SLOTS    = 16
PROJ_F_STATUS = 0x00

function readProjEntry(slot)
    memory.usememorydomain("System Bus")
    local base  = PROJ_BASE + slot * PROJ_STRIDE
    local bytes = memory.readbyterange(base, PROJ_STRIDE)  -- 0-indexed
    local out = {}
    for i = 0, PROJ_STRIDE - 1 do out[i + 1] = bytes[i] end
    return out
end

function snapshotProjActive()
    memory.usememorydomain("System Bus")
    local t = {}
    for slot = 0, PROJ_SLOTS - 1 do
        t[slot] = memory.readbyte(PROJ_BASE + slot * PROJ_STRIDE + PROJ_F_STATUS) ~= 0
    end
    return t
end

function findNewlyActiveSlots(prev)
    memory.usememorydomain("System Bus")
    local newly = {}
    for slot = 0, PROJ_SLOTS - 1 do
        local st  = memory.readbyte(PROJ_BASE + slot * PROJ_STRIDE + PROJ_F_STATUS)
        local was = prev and prev[slot]
        if st ~= 0 and not was then
            newly[#newly + 1] = slot
        end
    end
    return newly
end

function findFreeProjSlot()
    memory.usememorydomain("System Bus")
    for slot = 0, PROJ_SLOTS - 1 do
        if memory.readbyte(PROJ_BASE + slot * PROJ_STRIDE + PROJ_F_STATUS) == 0 then
            return slot
        end
    end
    return nil
end

-- Inject a 32-byte entry into a free slot. Records the slot in proj_injected so
-- the sender side won't re-broadcast it (which would echo-loop and multiply).
function injectProjEntry(entry)
    local slot = findFreeProjSlot()
    if not slot then return false end
    memory.usememorydomain("System Bus")
    local base = PROJ_BASE + slot * PROJ_STRIDE
    for i = 0, PROJ_STRIDE - 1 do
        memory.writebyte(base + i, entry[i + 1] or 0)
    end
    if mf_ram.proj_injected then mf_ram.proj_injected[slot] = true end
    return true
end

function projEntryToString(entry)
    local chars = {}
    for i = 1, PROJ_STRIDE do chars[i] = string.char((entry[i] or 0) % 256) end
    return table.concat(chars)
end

function projEntryFromString(str)
    local out = {}
    for i = 1, PROJ_STRIDE do out[i] = string.byte(str, i) or 0 end
    return out
end

-- ============================================================================
-- Enemy / boss HP + death sync
-- ============================================================================
-- The SpriteData array (0x3000140) holds all enemies and bosses. Per-entry:
--   +0x00 u16 Status (0 = empty slot)   +0x02 u16 Y   +0x04 u16 X
--   +0x14 u16 Health                    +0x1D u8  Sprite ID (enemy type)
-- We share damage: each frame we detect HP DROPS on local enemies (our shots
-- landing) and send the new HP keyed by Sprite ID. The receiver applies MIN(its
-- HP, received HP) to the matching enemy, so damage from both players stacks and
-- neither side can heal the boss back. When an enemy reaches 0 on either side it
-- dies on both. Enemies are matched by Sprite ID (+0x1D): a boss room has one
-- boss, so this is unambiguous; for regular enemies the (id, slot) pair is used.

SD_BASE     = 0x3000140
SD_STRIDE   = 0x38
SD_SLOTS    = 24
SD_F_STATUS = 0x00
SD_F_HP     = 0x14
SD_F_SPRID  = 0x1D
SD_F_POSE   = 0x24
SD_F_XPOS   = 0x04
SD_F_YPOS   = 0x02

-- Sub-sprite array: parts of composite bosses (e.g. Yakuza) keep their HP here,
-- NOT in the main array. Exactly two fixed slots, 16 bytes each:
--   +0x00 OAM ptr (4)  +0x08 Y  +0x0A X  +0x0C u16 Health  +0x0E/F Work.
-- No Status or Sprite-ID field, so a slot is "active" when its OAM pointer is
-- nonzero, and we match across instances by slot index (0 or 1) — fine because
-- there are only two and they spawn deterministically for a scripted boss.
SS_BASE    = 0x3000784
SS_STRIDE  = 0x10
SS_SLOTS   = 2
SS_F_OAM   = 0x00
SS_F_HP    = 0x0C

HP_DRIFT_MAX = 200
HP_KILL_GATE = 60

-- Snapshot active enemies: returns a table keyed by slot with {hp, id}.
-- Snapshot active enemies from BOTH arrays. Keys are strings so the two arrays
-- don't collide: "m<slot>" for main-array enemies, "s<slot>" for sub-sprites.
function snapshotEnemies()
    memory.usememorydomain("System Bus")
    local t = {}
    -- Main enemy array.
    for slot = 0, SD_SLOTS - 1 do
        local base = SD_BASE + slot * SD_STRIDE
        local st = memory.read_u16_le(base + SD_F_STATUS)
        if st ~= 0 then
            t["m" .. slot] = {
                kind = "m", slot = slot,
                hp = memory.read_u16_le(base + SD_F_HP),
                id = memory.readbyte(base + SD_F_SPRID),
                pose = memory.readbyte(base + SD_F_POSE),
            }
        end
    end
    -- Sub-sprite array (composite-boss parts). Active when OAM pointer != 0.
    for slot = 0, SS_SLOTS - 1 do
        local base = SS_BASE + slot * SS_STRIDE
        if memory.read_u32_le(base + SS_F_OAM) ~= 0 then
            t["s" .. slot] = {
                kind = "s", slot = slot,
                hp = memory.read_u16_le(base + SS_F_HP),
                id = 0,   -- no ID for sub-sprites; matched by slot
                pose = 0,
            }
        end
    end
    return t
end

-- Read a full enemy entry (all SD_STRIDE bytes) as a 1-indexed byte array, for
-- cloning a dying enemy's complete, game-authored death state to the other
-- instance.
function readEnemyEntry(slot)
    memory.usememorydomain("System Bus")
    local base = SD_BASE + slot * SD_STRIDE
    local bytes = memory.readbyterange(base, SD_STRIDE)  -- 0-indexed
    local out = {}
    for i = 0, SD_STRIDE - 1 do out[i + 1] = bytes[i] end
    return out
end

-- Write a full enemy entry over the matched enemy slot, dropping it into the
-- exact death state the owner instance produced.
function writeEnemyEntry(slot, entry)
    memory.usememorydomain("System Bus")
    local base = SD_BASE + slot * SD_STRIDE
    for i = 0, SD_STRIDE - 1 do
        memory.writebyte(base + i, entry[i + 1] or 0)
    end
end

function enemyEntryToString(entry)
    local chars = {}
    for i = 1, SD_STRIDE do chars[i] = string.char((entry[i] or 0) % 256) end
    return table.concat(chars)
end

function enemyEntryFromString(str)
    local out = {}
    for i = 1, SD_STRIDE do out[i] = string.byte(str, i) or 0 end
    return out
end

-- Same full-entry clone helpers for the sub-sprite array (stride SS_STRIDE),
-- so composite-boss parts and the Core-X shell can clone their HP=0 transition
-- (shell crack) across instances. Matched by slot index (sub-sprites have no ID).
function readSubEntry(slot)
    memory.usememorydomain("System Bus")
    local base = SS_BASE + slot * SS_STRIDE
    local bytes = memory.readbyterange(base, SS_STRIDE)
    local out = {}
    for i = 0, SS_STRIDE - 1 do out[i + 1] = bytes[i] end
    return out
end

function writeSubEntry(slot, entry)
    memory.usememorydomain("System Bus")
    local base = SS_BASE + slot * SS_STRIDE
    for i = 0, SS_STRIDE - 1 do
        memory.writebyte(base + i, entry[i + 1] or 0)
    end
end

function subEntryToString(entry)
    local chars = {}
    for i = 1, SS_STRIDE do chars[i] = string.char((entry[i] or 0) % 256) end
    return table.concat(chars)
end

function subEntryFromString(str)
    local out = {}
    for i = 1, SS_STRIDE do out[i] = string.byte(str, i) or 0 end
    return out
end

-- Find an active main-array enemy slot matching a Sprite ID (with slot hint).
function findEnemyByID(id, slot_hint)
    memory.usememorydomain("System Bus")
    if slot_hint then
        local b = SD_BASE + slot_hint * SD_STRIDE
        if memory.read_u16_le(b + SD_F_STATUS) ~= 0
           and memory.readbyte(b + SD_F_SPRID) == id then
            return slot_hint
        end
    end
    for slot = 0, SD_SLOTS - 1 do
        local b = SD_BASE + slot * SD_STRIDE
        if memory.read_u16_le(b + SD_F_STATUS) ~= 0
           and memory.readbyte(b + SD_F_SPRID) == id then
            return slot
        end
    end
    return nil
end

-- Reconcile a received HP value against our local enemy, treating HP sync as a
-- drift-correcting backstop rather than an authority:
--   * remote slightly below local (<= HP_DRIFT_MAX): converge down (honor a hit
--     that didn't register locally).
--   * remote far below local: ignore — the other instance is likely mid phase
--     transition; let our own game get there naturally.
--   * remote >= local: ignore — never raise HP from sync; the game owns heals
--     and phase resets (e.g. Yakuza 0->500).
-- A remote kill (hp == 0) is only honored when our HP is already <= HP_KILL_GATE,
-- so a death signal can't zero a boss that just reset to a new phase.
-- kind "m" = main array (match by Sprite ID); "s" = sub-sprite (match by slot).
function applyEnemyHP(kind, id, slot, hp)
    memory.usememorydomain("System Bus")
    local base
    if kind == "s" then
        if slot < 0 or slot >= SS_SLOTS then return end
        base = SS_BASE + slot * SS_STRIDE
        if memory.read_u32_le(base + SS_F_OAM) == 0 then return end
    else
        local s = findEnemyByID(id, slot)
        if not s then return end
        base = SD_BASE + s * SD_STRIDE
    end
    local hpoff = (kind == "s") and SS_F_HP or SD_F_HP
    local cur = memory.read_u16_le(base + hpoff)
    if hp >= cur then return end                      -- never raise HP (heals win)
    if hp == 0 then
        if cur <= HP_KILL_GATE then                   -- gated kill
            memory.write_u16_le(base + hpoff, 0)
        end
        return
    end
    if (cur - hp) <= HP_DRIFT_MAX then                -- small drift: converge down
        memory.write_u16_le(base + hpoff, hp)
    end
    -- large drop (not a kill): ignore — likely a phase transition in progress.
end

function collectSamusEntries(samus_sx, samus_sy)
    memory.usememorydomain("OAM")
    local entries = {}
    for slot = 0, 127 do
        local base  = slot * 8
        local attr0 = memory.read_u16_le(base)
        local attr1 = memory.read_u16_le(base + 2)
        local attr2 = memory.read_u16_le(base + 4)

        -- Skip OBJ-disabled entries (attr0 bits 9:8 == 10)
        local objMode = bit.band(bit.rshift(attr0, 8), 0x3)
        if objMode ~= 2 then

        -- OAM Y is 8-bit but wraps: values 192-255 mean the sprite starts
        -- above the top of the screen (-64 to -1). Sign-extend for correct math.
        local oam_y = bit.band(attr0, 0xFF)
        if oam_y >= 192 then oam_y = oam_y - 256 end

        local shape = bit.band(bit.rshift(attr0, 14), 0x3)

        -- OAM X is 9-bit signed: values 256-511 mean off the left edge (-256 to -1)
        local oam_x = bit.band(attr1, 0x1FF)
        if oam_x >= 256 then oam_x = oam_x - 512 end

        local hflip = bit.band(bit.rshift(attr1, 12), 0x1)
        local vflip = bit.band(bit.rshift(attr1, 13), 0x1)
        local size  = bit.band(bit.rshift(attr1, 14), 0x3)
        local tile  = bit.band(attr2, 0x3FF)
        local pal   = bit.band(bit.rshift(attr2, 12), 0xF)

        local dims = OAM_SIZES[shape] and OAM_SIZES[shape][size + 1] or {8, 8}
        local w, h = dims[1], dims[2]
        local cx   = oam_x + w / 2
        local cy   = oam_y + h / 2

        -- Proximity: Samus body fits in ~±20px X, ±36px Y from her feet origin.
        -- Shift center check 18px up from her feet to target her torso.
        local near_x  = math.abs(cx - samus_sx) < 24
        local near_y  = math.abs(cy - (samus_sy - 18)) < 40
        -- Palette: reject entries using palettes not associated with Samus.
        local good_pal  = SAMUS_PALETTES[pal]
        -- Tile: Samus tiles are always low-numbered; skip high-tile env objects.
        local good_tile = tile < SAMUS_TILE_MAX
        -- HUD elements sit at oam_y < 8 (very top of screen); exclude them.
        local not_hud   = oam_y >= 8

        if near_x and near_y and good_pal and good_tile and not_hud then
            entries[#entries+1] = {
                x = oam_x, y = oam_y, w = w, h = h,
                tile = tile, pal = pal, hflip = hflip, vflip = vflip
            }
        end

        end -- objMode ~= 2
    end
    return entries
end

function getObjTileStride()
    memory.usememorydomain("System Bus")
    local dispcnt = memory.read_u16_le(0x4000000)
    if bit.band(dispcnt, 0x40) ~= 0 then
        return nil  -- 1D: stride = tilesW (passed per-sprite)
    else
        return 32   -- 2D: stride is always 32 tiles wide
    end
end


SPRITE_W = 64
SPRITE_H = 80
SPRITE_OX = 32   -- origin X within the bitmap (Samus centre column)
SPRITE_OY = 64   -- origin Y within the bitmap (Samus feet row)

-- Rasterize the given OAM entries into a flat indexed bitmap.
-- Returns: pixels (array of palette-packed values), and a palette colour table.
-- Each pixel value encodes (pal * 16 + colIdx); 0 = transparent.
-- origin_sx/sy: Samus's screen position (entries are positioned relative to it).
function rasterizeSamus(entries, origin_sx, origin_sy)
    -- IMPORTANT: call getObjTileStride() FIRST (it switches to System Bus),
    -- then set VRAM domain so tile reads below hit VRAM, not System Bus.
    local stride = getObjTileStride()
    memory.usememorydomain("VRAM")
    local buf = {}                 -- buf[1..W*H], 0 = transparent
    for i = 1, SPRITE_W * SPRITE_H do buf[i] = 0 end

    local ox = math.floor(origin_sx)
    local oy = math.floor(origin_sy)

    for _, e in ipairs(entries) do
        local tilesW = e.w / 8
        local tilesH = e.h / 8
        local rowStride = stride or tilesW
        for ty = 0, tilesH - 1 do
            local srcTy = (e.vflip == 1) and (tilesH - 1 - ty) or ty
            for tx = 0, tilesW - 1 do
                local srcTx = (e.hflip == 1) and (tilesW - 1 - tx) or tx
                local tileNum = e.tile + srcTy * rowStride + srcTx
                if tileNum < SAMUS_TILE_MAX then
                    local tileAddr = 0x10000 + tileNum * 32
                    for py = 0, 7 do
                        local fpy = (e.vflip == 1) and (7 - py) or py
                        for px = 0, 7 do
                            local byteOff = tileAddr + py * 4 + math.floor(px / 2)
                            if byteOff >= 0x10000 and byteOff < 0x18000 then
                                local b = memory.read_u8(byteOff)
                                local colIdx = (px % 2 == 0)
                                               and bit.band(b, 0xF)
                                               or  bit.band(bit.rshift(b, 4), 0xF)
                                if colIdx ~= 0 then
                                    local fpx = (e.hflip == 1) and (7 - px) or px
                                    -- Screen position of this pixel relative to origin
                                    local rel_x = (e.x + tx * 8 + fpx) - ox
                                    local rel_y = (e.y + ty * 8 + fpy) - oy
                                    -- Map into bitmap space
                                    local bx = rel_x + SPRITE_OX
                                    local by = rel_y + SPRITE_OY
                                    if bx >= 0 and bx < SPRITE_W
                                       and by >= 0 and by < SPRITE_H then
                                        local idx = by * SPRITE_W + bx + 1
                                        buf[idx] = e.pal * 16 + colIdx
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return buf
end

local ESC_BYTE = 1                                   -- 0x01: escape marker
local ESC_SUBST = { [10] = 2, [13] = 3, [44] = 4, [58] = 5, [1] = 6 }
local ESC_UNSUBST = {}
for k, v in pairs(ESC_SUBST) do ESC_UNSUBST[v] = k end

function base64Encode(str)
    local out = {}
    for i = 1, #str do
        local b = string.byte(str, i)
        local s = ESC_SUBST[b]
        if s then
            out[#out + 1] = string.char(ESC_BYTE, s)
        else
            out[#out + 1] = string.char(b)
        end
    end
    return "z" .. table.concat(out)
end

function base64Decode(str)
    str = tostring(str)
    if string.sub(str, 1, 1) == "z" then str = string.sub(str, 2) end
    local out = {}
    local n = #str
    local i = 1
    while i <= n do
        local b = string.byte(str, i)
        if b == ESC_BYTE then
            local s = string.byte(str, i + 1)
            out[#out + 1] = string.char(ESC_UNSUBST[s] or s)
            i = i + 2
        else
            out[#out + 1] = string.char(b)
            i = i + 1
        end
    end
    return table.concat(out)
end

function rleEncode(buf)
    local parts = {}
    local n = #buf
    local i = 1
    while i <= n do
        local v = buf[i]
        local run = 1
        while i + run <= n and buf[i + run] == v and run < 255 do
            run = run + 1
        end
        parts[#parts + 1] = string.char(v, run)
        i = i + run
    end
    return table.concat(parts)
end

function rleDecode(str)
    local buf = {}
    local n = #str
    local i = 1
    while i < n do
        local v   = string.byte(str, i)
        local run = string.byte(str, i + 1)
        for _ = 1, run do buf[#buf + 1] = v end
        i = i + 2
    end
    return buf
end

function capturePalettes()
    memory.usememorydomain("System Bus")
    local parts = {}
    for p = 0, 3 do
        for c = 1, 15 do
            local raw = memory.read_u16_le(0x5000200 + (p * 16 + c) * 2)
            parts[#parts + 1] = string.char(bit.band(raw, 0xFF),
                                            bit.band(bit.rshift(raw, 8), 0xFF))
        end
    end
    return table.concat(parts)
end

function palToARGB(str)
    local out = {}
    local idx = 1
    for p = 0, 3 do
        out[p] = {}
        for c = 1, 15 do
            local lo  = string.byte(str, idx)
            local hi  = string.byte(str, idx + 1)
            idx = idx + 2
            if lo and hi then
                local raw = lo + hi * 256
                local r = bit.band(raw, 0x1F) * 8
                local g = bit.band(bit.rshift(raw, 5), 0x1F) * 8
                local b = bit.band(bit.rshift(raw, 10), 0x1F) * 8
                out[p][c] = 0xFF000000 + r * 0x10000 + g * 0x100 + b
            end
        end
    end
    return out
end

function drawBitmap(buf, argb, sx, sy)
    local ox = math.floor(sx) - SPRITE_OX
    local oy = math.floor(sy) - SPRITE_OY
    -- Batch consecutive same-colour pixels in each row into a single drawLine.
    for by = 0, SPRITE_H - 1 do
        local rowBase = by * SPRITE_W
        local y = oy + by
        local bx = 0
        while bx < SPRITE_W do
            local v = buf[rowBase + bx + 1]
            if v and v ~= 0 then
                local p = math.floor(v / 16)
                local c = v % 16
                local color = argb[p] and argb[p][c]
                if color then
                    -- Extend the run while the resolved colour stays identical
                    local run_end = bx
                    while run_end + 1 < SPRITE_W do
                        local nv = buf[rowBase + run_end + 2]
                        if not nv or nv == 0 then break end
                        local np = math.floor(nv / 16)
                        local nc = nv % 16
                        if (argb[np] and argb[np][nc]) ~= color then break end
                        run_end = run_end + 1
                    end
                    if run_end > bx then
                        gui.drawLine(ox + bx, y, ox + run_end, y, color)
                    else
                        gui.drawPixel(ox + bx, y, color)
                    end
                    bx = run_end + 1
                else
                    bx = bx + 1
                end
            else
                bx = bx + 1
            end
        end
    end
end

if mf_ram.frame_handler_id then
    pcall(function() event.unregisterbyid(mf_ram.frame_handler_id) end)
    mf_ram.frame_handler_id = nil
end

-- Pick the background layer that actually acts as the camera this frame and
-- return Samus's screen position under it. We read all four BG scroll registers
-- from the BGPositions table (0x30000C8: BG0 X/Y, +4 BG1, +8 BG2, +C BG3) and
-- choose the layer whose scroll places Samus on-screen.
function selectCameraScreenPos(wx, wy)
    memory.usememorydomain("System Bus")
    local px, py = wx / 4, wy / 4
    local best_sx, best_sy, best_score = nil, nil, -1
    -- BG0..BG3 X scroll at 0x30000C8 + layer*4; Y at +2.
    for layer = 0, 3 do
        local cx = memory.read_u16_le(0x30000C8 + layer * 4)
        local cy = memory.read_u16_le(0x30000CA + layer * 4)
        local sx = (px - cx) % 512; if sx > 256 then sx = sx - 512 end
        local sy = (py - cy) % 512; if sy > 256 then sy = sy - 512 end
        local on = (sx > -32 and sx < 272 and sy > -48 and sy < 200)
        if on then
            -- Closeness to screen centre as a tiebreaker (lower is better),
            -- turned into a higher-is-better score.
            local dxc = math.abs(sx - 120)
            local dyc = math.abs(sy - 80)
            local score = 1000 - (dxc + dyc)
            if score > best_score then
                best_score = score; best_sx = sx; best_sy = sy
            end
        end
    end
    if best_sx then return best_sx, best_sy end
    local cx = memory.read_u16_le(0x30000C8)
    local cy = memory.read_u16_le(0x30000CA)
    local sx = (px - cx) % 512; if sx > 256 then sx = sx - 512 end
    local sy = (py - cy) % 512; if sy > 256 then sy = sy - 512 end
    return sx, sy
end

local function onFrameEnd()
    local wx    = readRAM("System Bus", 0x300125A, 2)
    local wy    = readRAM("System Bus", 0x300125C, 2)
    -- Camera: auto-select the BG layer that tracks Samus (BG0 normally; BG1 in
    -- rooms where an effect steals BG0's scroll).
    local samus_sx, samus_sy = selectCameraScreenPos(wx, wy)

    local my_area = readRAM("System Bus", 0x300002C, 1)
    local my_room = readRAM("System Bus", 0x300002D, 1)

    local my_anim  = readRAM("System Bus", 0x3001266, 1)
    local my_pose  = readRAM("System Bus", 0x3001245, 1)
    local now      = readRAM("System Bus", 0x3000002, 2)  -- frame counter
    local my_dir   = readRAM("System Bus", 0x3001256, 2)
    -- Sprite signature deliberately EXCLUDES the animation frame counter
    -- (0x3001265).
    local my_sig   = my_anim .. ":" .. my_pose .. ":" .. my_dir
    -- ~8 frames keeps the overlay smooth enough without unnecessary load
    local SPRITE_REBUILD_GAP = 8
    local gap_ok   = (not mf_ram.my_built_frame)
                     or ((now - mf_ram.my_built_frame) % 65536 >= SPRITE_REBUILD_GAP)
    if my_sig ~= mf_ram.my_built_sig and gap_ok then
        local p1_entries = collectSamusEntries(samus_sx, samus_sy)
        mf_ram.my_hflip = p1_entries[1] and p1_entries[1].hflip or 0
        if #p1_entries > 0 then
            local buf    = rasterizeSamus(p1_entries, samus_sx, samus_sy)
            local sprite = {
                rle = base64Encode(rleEncode(buf)),
                pal = base64Encode(capturePalettes()),
            }
            mf_ram.my_sprite       = sprite
            mf_ram.my_built_sig    = my_sig
            mf_ram.my_built_frame  = now
            mf_ram.my_sprite_dirty = true
        end
    end

    for user, pl in pairs(mf_ram.players) do
        -- Cull a player whose updates stopped.
        local stale = pl.last_frame
                      and ((now - pl.last_frame) % 65536 > 75)
        if stale then
            mf_ram.players[user] = nil
        elseif pl.pos
           and pl.pos.area == my_area
           and pl.pos.room == my_room
           and pl.sprite
           and pl.sprite.buf
           and pl.sprite.argb then
            -- Screen position relative to P1.
            local world_dx = (pl.pos.x / 4) - (wx / 4)
            local world_dy = (pl.pos.y / 4) - (wy / 4)
            local sx = samus_sx + world_dx
            local sy = samus_sy + world_dy
            drawBitmap(pl.sprite.buf, pl.sprite.argb, sx, sy)
        end
    end
end

mf_ram.frame_handler_id = event.onframeend(onFrameEnd, "mf_coop_frame")

if event.onexit then
    event.onexit(function()
        if mf_ram.frame_handler_id then
            pcall(function() event.unregisterbyid(mf_ram.frame_handler_id) end)
            mf_ram.frame_handler_id = nil
        end
        mf_ram.players = {}
    end, "mf_coop_exit")
end

return mf_ram