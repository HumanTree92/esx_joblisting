local CurrentActionData = {}
local HasAlreadyEnteredMarker, IsInMainMenu = false, false
local LastZone, CurrentAction, CurrentActionMsg
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

-- Show Job Menu
function ShowJobListingMenu()
	IsInMainMenu = true
	ESX.TriggerServerCallback('esx_joblisting:getJobsList', function(jobs)
		local elements = {}

		for i=1, #jobs, 1 do
			table.insert(elements, {
				label = jobs[i].label,
				job   = jobs[i].job
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'joblisting', {
			title = _U('job_center'),
			align = GetConvar('esx_MenuAlign', 'top-left'),
			elements = elements
		}, function(data, menu)
			TriggerServerEvent('esx_joblisting:setJob', data.current.job)
			ESX.ShowNotification(_U('new_job'))
			IsInMainMenu = false
			menu.close()
		end, function(data, menu)
			IsInMainMenu = false
			menu.close()
			CurrentAction = 'job_menu'
			CurrentActionData = {}
		end)

	end)
end

-- Entered Marker
AddEventHandler('esx_joblisting:hasEnteredMarker', function(zone)
	if zone == 'JobLocs' then
		CurrentAction = 'job_menu'
		CurrentActionMsg = _U('job_menu')
		CurrentActionData = {}
	end
end)

-- Exited Marker
AddEventHandler('esx_joblisting:hasExitedMarker', function(zone)
	if not IsInMainMenu or IsInMainMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

-- Resource Stop
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if IsInMainMenu then
			ESX.UI.Menu.CloseAll()
		end
	end
end)

-- Enter / Exit marker events & Draw Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone = false, true

		for k,v in pairs(Config.Locations) do
			for i=1, #v.JobE, 1 do
				local distance = #(playerCoords - v.JobE[i])

				if distance < Config.DrawDistance then
					letSleep = false

					if Config.Marker.Type ~= -1 then
						DrawMarker(Config.Marker.Type, v.JobE[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, 100, false, true, 2, false, nil, nil, false)
					end

					if distance < Config.Marker.x then
						isInMarker, currentZone = true, 'JobLocs'
					end
				end
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker, LastZone = true, currentZone
			LastZone = currentZone
			TriggerEvent('esx_joblisting:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_joblisting:hasExitedMarker', LastZone)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end	
end)

-- Create blips
Citizen.CreateThread(function()
	for i=1, #Config.Zones, 1 do
		local blip = AddBlipForCoord(Config.Zones[i])

		SetBlipSprite (blip, 407)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 1.2)
		SetBlipColour (blip, 27)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName(_U('job_center'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Menu Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'job_menu' then
					ShowJobListingMenu()
				end

				CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)
