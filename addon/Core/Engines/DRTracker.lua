local UnitGUID, GetTime = UnitGUID, GetTime

ni.drtracker = {
	resettime = 18,
	units = {},
	get = function(unit, type)
		-- ni.drtracker.get("target", "Fears")
		-- returns 1, 0.5, 0.25 or 0
		-- 1 -> full duration
		-- 0.5 -> half duration
		-- 0.25 -> quarter duration
		-- 0 -> immune
		if ni.tables.dr.types[type] == nil then
			ni.debug.log("DR type not supported, check https://nhub.app")
			return -1
		end

		unit = UnitGUID(unit)

		if unit == nil then
			return -1
		end

		if ni.drtracker.units[unit] == nil then
			return 1
		end

		if ni.drtracker.units[unit][type] then
			return ni.drtracker.units[unit][type].diminished
		end

		return 1
	end,
	nextdr = function(currentdr)
		if (currentdr == 1) then
			return 0.50
		elseif (currentdr == 0.50) then
			return 0.25
		end

		return 0
	end,
	gained = function(spellID, destName, destGUID, isEnemy, isPlayer)
		local drCat = ni.tables.dr.spells[spellID]
		isPlayer = ni.unit.isplayer(destGUID)
		isPlayer = true

		if not isPlayer and not ni.tables.dr.pve[drCat] then
			return
		end

		local cat = ni.tables.dr.refs[drCat]
		local time = GetTime()

		if not ni.drtracker.units[destGUID] then
			ni.drtracker.units[destGUID] = {}
		end

		if not ni.drtracker.units[destGUID][cat] then
			ni.drtracker.units[destGUID][cat] = {reset = time + ni.drtracker.resettime, diminished = 0.5}
		else
			ni.drtracker.units[destGUID][cat].reset = time + ni.drtracker.resettime
			ni.drtracker.units[destGUID][cat].diminished = ni.drtracker.nextdr(ni.drtracker.units[destGUID][cat].diminished)
		end

	end,
	faded = function(spellID, destName, destGUID, isEnemy, isPlayer)
		local drCat = ni.tables.dr.spells[spellID]
		isPlayer = ni.unit.isplayer(destGUID)
		isPlayer = true

		if (not isPlayer and not ni.tables.dr.pve[drCat]) then
			return
		end

		local cat = ni.tables.dr.refs[drCat]
		local time = GetTime()

		if not ni.drtracker.units[destGUID] then
			ni.drtracker.units[destGUID] = {}
		end

		if not ni.drtracker.units[destGUID][cat] then
			ni.drtracker.units[destGUID][cat] = {reset = 0, diminished = 1}
		end

		ni.drtracker.units[destGUID][cat].reset = time + ni.drtracker.resettime
	end,
	wipe = function(unit)
		if ni.drtracker.units[unit] then
			ni.drtracker.units[unit] = nil
		end
	end,
	wipeall = function()
		for k, v in pairs(ni.drtracker.units) do
			ni.drtracker.units[k] = nil
		end
	end,
	updateresettime = function()
		for k, v in pairs(ni.drtracker.units) do
			for x, y in pairs(v) do
				if y.reset <= GetTime() then
					ni.drtracker.units[k][x].reset = 0
					ni.drtracker.units[k][x].diminished = 1
				end
			end
		end
	end
}
