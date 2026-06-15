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

	-- Per-player overlay state, keyed by username so any number of remote
	-- players can be tracked and drawn (not just one). The framework relays
	-- every client's messages to all others, so we receive everyone's data.
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
end

mf_ram.itemcount = 100
mf_ram.my_last_pos  = nil   -- tracks last sent pos to throttle pos messages
mf_ram.players      = {}    -- players[username] = {pos, sprite, argb, last_frame}

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

local function onFrameEnd()
    local wx    = readRAM("System Bus", 0x300125A, 2)
    local wy    = readRAM("System Bus", 0x300125C, 2)
    -- Use BG0 scroll registers (0x30000C8/CA)
    local cam_x = readRAM("System Bus", 0x30000C8, 2)
    local cam_y = readRAM("System Bus", 0x30000CA, 2)
    -- BG0 scroll wraps within 512px; world coords keep climbing. Normalise the
    -- difference into a single wrap window so P1's on-screen position is always
    -- valid even when world and scroll are in different 512px windows.
    local samus_sx = ((wx / 4) - cam_x) % 512
    local samus_sy = ((wy / 4) - cam_y) % 512
    if samus_sx > 256 then samus_sx = samus_sx - 512 end
    if samus_sy > 256 then samus_sy = samus_sy - 512 end

    local my_area = readRAM("System Bus", 0x300002C, 1)
    local my_room = readRAM("System Bus", 0x300002D, 1)

    local my_anim  = readRAM("System Bus", 0x3001266, 1)
    local my_pose  = readRAM("System Bus", 0x3001245, 1)
    local my_ctr   = readRAM("System Bus", 0x3001265, 1)  -- animation frame counter
    local now      = readRAM("System Bus", 0x3000002, 2)  -- frame counter
    local my_dir   = readRAM("System Bus", 0x3001256, 2)
    local my_sig   = my_anim .. ":" .. my_pose .. ":" .. my_ctr .. ":" .. my_dir
    local gap_ok   = (not mf_ram.my_built_frame)
                     or ((now - mf_ram.my_built_frame) % 65536 >= 4)
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
        local stale = pl.last_frame
                      and ((now - pl.last_frame) % 65536 > 120)  -- ~2s at 60fps
        if stale then
            mf_ram.players[user] = nil
        elseif pl.pos
           and pl.pos.area == my_area
           and pl.pos.room == my_room
           and pl.sprite
           and pl.sprite.buf
           and pl.sprite.argb then
            -- Screen position relative to P1 (avoids BG0 scroll wraparound).
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