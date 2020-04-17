ESX = nil
local availableJobs = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Original esx_JobWhitelisting EDITED & FIXED by: Human Tree92
ESX.RegisterServerCallback('esx_joblisting:getJobsList', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier2 = GetPlayerIdentifiers(source)[1]
	local identifier = xPlayer.identifier

	MySQL.Async.fetchAll('SELECT name, label FROM jobs WHERE whitelisted = @whitelisted', {
		['@whitelisted'] = false
	}, function(result)
		local availableJobs = {}

		for i=1, #result, 1 do
			table.insert(availableJobs, {
				job = result[i].name,
				label = result[i].label
			})
		end

		getPlayerData(source, function(data)
			if data.leo > -1 then
				table.insert(availableJobs, {
					job = "police",
					label = "Policing/Staff"
				})
			end

			if data.ems > -1 then
				table.insert(availableJobs, {
					job = "ambulance",
					label = "Fire/Rescue"
				})
			end

			if data.tow > -1 then
				table.insert(availableJobs, {
					job = "mechanic",
					label = "Mechanic"
				})
			end

			cb(availableJobs)
		end)
	end)
end)

RegisterServerEvent('esx_joblisting:setJob')
AddEventHandler('esx_joblisting:setJob', function(job)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	function injection()
		print(('esx_joblisting: %s attempted to set a whitelisted job! (lua injector)'):format(xPlayer.identifier))
	end

	MySQL.Async.fetchAll('SELECT whitelisted FROM jobs WHERE name = @name', {
		['@name'] = job
	}, function(result)
		if not result[1].whitelisted then
			xPlayer.setJob(job, 0)
		elseif job == "police" then
			getPlayerData2(xPlayer.identifier, function(data)
				if data.leo then
					xPlayer.setJob(job, data.leo)
				else
					injection()
				end
			end)
		elseif job == "ambulance" then
			getPlayerData2(xPlayer.identifier, function(data)
				if data.ems then
					xPlayer.setJob(job, data.ems)
				else
					injection()
				end
			end)
		elseif job == "mechanic" then
			getPlayerData2(xPlayer.identifier, function(data)
				if data.tow then
					xPlayer.setJob(job, data.tow)
				else
					injection()
				end
			end)
		else
			injection()
		end
	end)
end)

-- getPlayerData
function getPlayerData(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	-- Get Player Info
	local result = MySQL.Sync.fetchAll('SELECT `leo_rank`, `ems_rank`, `tow_rank` FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	})

	local leo = result[1].leo_rank
	local ems = result[1].ems_rank
	local tow = result[1].tow_rank

	local data = {
		leo = leo,
		ems = ems,
		tow = tow
	}

	cb(data)
end

-- getPlayerData2
function getPlayerData2(identifier, cb)
	-- Get Player Info
	local result = MySQL.Sync.fetchAll('SELECT `leo_rank`, `ems_rank`, `tow_rank` FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	})

	local leo = result[1].leo_rank
	local ems = result[1].ems_rank
	local tow = result[1].tow_rank

	local data = {
		leo = leo,
		ems = ems,
		tow = tow
	}

	cb(data)
end
