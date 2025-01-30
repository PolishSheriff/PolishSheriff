local arivi_ui = exports.arivi_ui
local ESX = ESX
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local TriggerServerEvent = TriggerServerEvent
local TriggerEvent = TriggerEvent
local Wait = Wait
local CreateThread = CreateThread
local LocalPlayer = LocalPlayer
local ox_inventory = exports.ox_inventory
local HasAlreadyEnteredMarker, LastZone = false, nil
local GetGameTimer = GetGameTimer
local CurrentAction, CurrentActionMsg, CurrentActionData = nil, {}, {}
local Blips, NPCOnJob, NPCTargetTowableZone = {}, false, nil
local NPCTargetDeleterZone    = false
local NPCHasSpawnedTowable, NPCLastCancel, NPCHasBeenNextToTowable, NPCTargetDistance = false, GetGameTimer() - 5 * 60000, false, 0
local GetCurrentResourceName = GetCurrentResourceName
local AddTextComponentSubstringPlayerName = AddTextComponentSubstringPlayerName
local IsVehicleModel = IsVehicleModel
local TaskWarpPedIntoVehicle = TaskWarpPedIntoVehicle
local SetVehicleNumberPlateText = SetVehicleNumberPlateText
local SetVehicleHasBeenOwnedByPlayer = SetVehicleHasBeenOwnedByPlayer
local GetClosestObjectOfType = GetClosestObjectOfType
local GetHashKey = GetHashKey
local DoesEntityExist = DoesEntityExist
local GetRandomIntInRange = GetRandomIntInRange
local GetGameTimer = GetGameTimer
local IsControlJustReleased = IsControlJustReleased
local ClearPedTasks = ClearPedTasks
local AddBlipForCoord = AddBlipForCoord
local SetBlipSprite = SetBlipSprite
local SetBlipDisplay = SetBlipDisplay
local SetBlipScale = SetBlipScale
local SetBlipColour = SetBlipColour
local SetBlipAsShortRange = SetBlipAsShortRange
local BeginTextCommandSetBlipName = BeginTextCommandSetBlipName
local RemoveBlip = RemoveBlip
local EndTextCommandSetBlipName = EndTextCommandSetBlipName
local SetVehicleFixed = SetVehicleFixed
local DoesEntityExist = DoesEntityExist
local SetVehicleDeformationFixed = SetVehicleDeformationFixed
local SetVehicleEngineOn = SetVehicleEngineOn
local SetVehicleUndriveable = SetVehicleUndriveable
local SetVehicleEngineHealth = SetVehicleEngineHealth
local GetRandomIntInRange = GetRandomIntInRange
local IsVehicleAlarmSet = IsVehicleAlarmSet
local SetNetworkIdCanMigrate = SetNetworkIdCanMigrate
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local NetworkHasControlOfNetworkId = NetworkHasControlOfNetworkId
local StartVehicleAlarm = StartVehicleAlarm
local NetworkRequestControlOfNetworkId = NetworkRequestControlOfNetworkId
local SetVehicleDoorsLocked = SetVehicleDoorsLocked
local SetVehicleDoorsLockedForAllPlayers = SetVehicleDoorsLockedForAllPlayers
local ClearPedTasks = ClearPedTasks
local SetVehicleDirtLevel = SetVehicleDirtLevel
local SetVehicleFixed = SetVehicleFixed
local haveTargets = false

local libCache = lib.onCache
local cachePed = cache.ped
local cacheCoords = cache.coords
local cacheVehicle = cache.vehicle

libCache('ped', function(ped)
	cachePed = ped
end)

libCache('coords', function(coords)
	cacheCoords = coords
end)

libCache('vehicle', function(vehicle)
	cacheVehicle = vehicle
end)

local function RefreshTargets()
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'mechanik' then
		if haveTargets then return end
		TriggerServerEvent('esx_mechanik:sync:addTargets')
		haveTargets = true
	end
end

local function DeleteTargets()
	TriggerServerEvent('esx_mechanik:sync:addTargets')
	haveTargets = false
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	ESX.PlayerData = playerData

	while not ESX.IsPlayerLoaded() do
        Citizen.Wait(200)
    end
	
	Citizen.CreateThread(function()
		if ESX.PlayerData.job.name == "mechanik" then
			RefreshTargets()
		end
	end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job

	if ESX.PlayerData.job.name == "mechanik" then
		Citizen.CreateThread(function()
			RefreshTargets()
		end)
	else
		Citizen.CreateThread(function()
			DeleteTargets()
		end)
	end
end)

local Zones <const> = {
    {
        job = 'mechanik', -- job name with permissions to tuning (people without can only create projects)
        coords = vec3(893.0, -2127.0, 31.7),  
        size = vec3(46.0, 12.0, 4.8),
        rotation = 355.0,
    }
}

local function CleanPlayer()
	ClearPedBloodDamage(cachePed)
	ResetPedVisibleDamage(cachePed)
	ClearPedLastWeaponDamage(cachePed)
	ResetPedMovementClipset(cachePed, 0)
end

local function SetUniform(grade)
	CleanPlayer()
	
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.Uniforms[grade].male ~= nil then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[grade].male)
			else
				ESX.ShowNotification('Brak ubrań')
			end
		else
			if Config.Uniforms[grade].female ~= nil then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[grade].female)
			else
				ESX.ShowNotification('Brak ubrań')
			end
		end
	end)
end

local function SelectRandomTowable()
	local index = GetRandomIntInRange(1,  #Config.Towables)

	for k,v in pairs(Config.TowZones) do
		if v.Pos.x == Config.Towables[index].x and v.Pos.y == Config.Towables[index].y and v.Pos.z == Config.Towables[index].z then
			return k
		end
	end
end

local function StartNPCJob(currZone)
	NPCOnJob = true

	NPCTargetTowableZone = SelectRandomTowable()
	local zone       = Config.TowZones[NPCTargetTowableZone]

	NPCTargetDistance = (#(vec3(currZone.VehicleDelivery.coords.x,  currZone.VehicleDelivery.coords.y,  currZone.VehicleDelivery.coords.z) - vec3(zone.Pos.x,  zone.Pos.y,  zone.Pos.z)) * 2)

	Blips['NPCTargetTowableZone'] = AddBlipForCoord(zone.Pos.x,  zone.Pos.y,  zone.Pos.z)
	SetBlipRoute(Blips['NPCTargetTowableZone'], true)

	ESX.ShowNotification('Oznaczyłem ci cel na GPS, udaj się tam zapakuj pojazd na pake i udaj się do wyznaczonego punktu zwrotu!')
end

local function StopNPCJob(cancel)
	if Blips['NPCTargetTowableZone'] then
		RemoveBlip(Blips['NPCTargetTowableZone'])
		Blips['NPCTargetTowableZone'] = nil
	end

	if Blips['NPCDelivery'] then
		RemoveBlip(Blips['NPCDelivery'])
		Blips['NPCDelivery'] = nil
	end

	if cancel then
		ESX.ShowNotification('Anulowano')
	else
		TriggerServerEvent('esx_mechanik:onNPCJobMissionCompleted', NPCTargetDistance, ESX.PlayerData.job.name)
	end
	
	NPCOnJob                = false
	NPCTargetTowable        = nil
	NPCTargetTowableZone    = nil
	NPCTargetDistance       = 0
	NPCHasSpawnedTowable    = false
	NPCHasBeenNextToTowable = false
	NPCTargetDeleterZone    = false
end

local function SetVehicleMaxMods(vehicle)
	local t = {
		modEngine       = 3,
		modBrakes       = 2,
		modTransmission = 2,
		modSuspension   = 3,
		modArmor        = 4,
		modXenon        = true,
		modTurbo        = true,
		dirtLevel       = 0
	}

	ESX.Game.SetVehicleProperties(vehicle, t)
end

local function OpenMechanicVehicleSpawner(coords, heading)
	local elements = {
		{label = "Laweta", value = 'flatbed'},
		{label = "Dodge Charger", value = 'lsc_charger18'},
		{label = "Ford Raptor", value = 'lsc_raptor'},
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_vehicle', {
		title    = 'Pojazdy',
		align    = 'center',
		elements = elements
	}, function(data, menu)
		local vehicleProps = data.current.value
		if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
			ESX.Game.SpawnVehicle(data.current.value, coords, heading, function(vehicle)
				ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
				SetVehicleMaxMods(vehicle)
				local plate = "MECH" .. math.random(111,9999)
				SetVehicleNumberPlateText(vehicle, plate)
				TaskWarpPedIntoVehicle(cachePed, vehicle, -1)
				Entity(vehicle).state.fuel = 50
				Citizen.Wait(500)

				local status = IsVehicleEngineOn(vehicle)

				lib.callback('esx_carkeys:ToggleEngine', false, function(data)
					if data then
						if not status then
							if data == "Key" then return ESX.ShowNotification("Znalazłeś kluczyki do pojazdu.") end
							SetVehicleEngineOn(vehicle, true, false, true)
							Entity(vehicle).state.engine = true
							ESX.ShowNotification("Silnik włączony.")
						else
							SetVehicleEngineOn(vehicle, false, false, true)
							Entity(vehicle).state.engine = false
							ESX.ShowNotification("Silnik wyłączony.")
						end
					else
						if status then
							Entity(vehicle).state.engine = false
							SetVehicleEngineOn(vehicle, false, false, true)
							ESX.ShowNotification("Silnik wyłączony.")
						else
							ESX.ShowNotification("Nie posiadasz kluczy do auta.")
						end
					end
				end, not status)
			end)
		else
			ESX.ShowNotification('Miejsce jest zajęte!')
		end
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

local function OpenMechanicActionsMenu()
	local elements = {
		{label = 'Szatnia prywatna', value = 'szatnia_private'},
		{label = 'Ubranie służbowe', value = 'szatnia_menu'},
		{label = 'Schowek', value = 'schowek'},
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mechanic_actions', {
		title    = "LSC",
		align    = 'center',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'szatnia_menu' then
			SetUniform(ESX.PlayerData.job.grade)
		elseif data.current.value == 'szatnia_private' then
			TriggerEvent("arivi_ui:openOutfitMenu")
		elseif data.current.value == 'schowek' then
			ox_inventory:openInventory('stash', {id='mechanik'})
		end

		ESX.UI.Menu.CloseAll()
	end, function(data, menu)
		menu.close()
	end)
end

local function canUse(coords)
	local areas = {
		vec3(890.1128, -2114.7236, 30.4595),
	}
	
	for k,v in pairs(areas) do
		if #(v - coords) < 40.0 then 
			return true
		end	
	end

	return false
end

AddEventHandler('esx_mechanik:hasEnteredMarker', function(zone)
	local vehicle, distance = ESX.Game.GetClosestVehicle({
		x = cacheCoords.x,
		y = cacheCoords.y,
		z = cacheCoords.z
	})

	if zone == 'VehicleDeleter' and cacheVehicle ~= false then
		if distance ~= -1 and distance <= 1.0 then
			CurrentAction     = 'delete_vehicle'
			CurrentActionMsg  = {text = 'Naciśnij', button = 'E', description = 'aby schować pojazd.'}
			CurrentActionData = {vehicle = vehicle}
		end
	elseif zone == 'VehicleDelivery' and cacheVehicle ~= false and NPCOnJob then
		NPCTargetDeleterZone = true

		if distance ~= -1 and distance <= 1.0 then
			CurrentAction     = 'vehicle_delivery'
			CurrentActionMsg  = {text = 'Użyj w menu', button = 'e', description = 'zakładki LSC aby odczepić pojazd'}
			CurrentActionData = {vehicle = vehicle}
		end
	end
end)

AddEventHandler('esx_mechanik:hasExitedMarker', function(zone)
	if zone =='VehicleDelivery' then
		NPCTargetDeleterZone = false
	end

	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

CreateThread(function()
	while ESX.PlayerData.job == nil do
		Wait(100)
	end

	while true do
		Wait(0)
		if ESX.PlayerData.job.name == "mechanik" then
			local sleep = true
			if NPCTargetTowableZone ~= nil and not NPCHasSpawnedTowable then
				sleep = false
				local zone   = Config.TowZones[NPCTargetTowableZone]
				
				if #(cacheCoords - vec3(zone.Pos.x, zone.Pos.y, zone.Pos.z)) < Config.NPCSpawnDistance then
					local model = Config.Vehicles[GetRandomIntInRange(1,  #Config.Vehicles)]
					ESX.Game.SpawnVehicle(model, zone.Pos, 0, function(vehicle)
						SetVehicleHasBeenOwnedByPlayer(vehicle, true)
						SetVehicleUndriveable(vehicle, false)
						SetVehicleEngineOn(vehicle, true, true)
						SetVehicleEngineHealth(vehicle, 200.0)
						NPCTargetTowable = vehicle
						Entity(vehicle).state.fuel = 50
					end)

					NPCHasSpawnedTowable = true
				end
			end

			if NPCTargetTowableZone ~= nil and NPCHasSpawnedTowable and not NPCHasBeenNextToTowable then
				sleep = false
				local zone   = Config.TowZones[NPCTargetTowableZone]
				if(#(cacheCoords - vec3(zone.Pos.x, zone.Pos.y, zone.Pos.z)) < Config.NPCNextToDistance) then
					ESX.ShowNotification('Proszę odholować pojazd')
					NPCHasBeenNextToTowable = true
				end
			end

			if sleep then
				Wait(500)
			end
		else
			Wait(1000)
		end
	end
end)

CreateThread(function()
	for k,v in pairs(Config.Blips) do
		local blip = AddBlipForCoord(v.Pos)

		SetBlipSprite (blip, v.Sprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.7)
		SetBlipColour (blip, v.Color)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(v.Label)
		EndTextCommandSetBlipName(blip)
	end
end)

local letSleep = true

CreateThread(function()
	while true do
		Wait(0)
		letSleep = true
		if ESX.PlayerData.job then
			if Config.Zones[ESX.PlayerData.job.name] then
				for k,v in pairs(Config.Zones.Vehicles) do
					if v.type ~= -1 then
						if #(cacheCoords - v.coords) < Config.DrawDistance then
							if cacheVehicle then
								if v.type == 28 then
									ESX.DrawBigMarker(v.coords)
								elseif v.type == 29 and NPCOnJob then
									ESX.DrawBigMarker(v.coords)
								end
							end
							letSleep = false
						end
					end
				end

				if letSleep then
					Wait(1000)
				end
			else
				Wait(1000)
			end
		else
			Wait(5000)
		end
	end
end)

CreateThread(function()
	while true do
		Wait(500)
		if ESX.PlayerData.job ~= nil then
			if Config.Zones[ESX.PlayerData.job.name] then
				local sleep = true
				local isInMarker  = false
				local currentZone = nil
				
				for k,v in pairs(Config.Zones.Vehicles) do
					if #(cacheCoords - v.coords) < 3.0 then
						sleep = false
						isInMarker  = true
						currentZone = k
					end
				end

				if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
					HasAlreadyEnteredMarker = true
					LastZone                = currentZone
					TriggerEvent('esx_mechanik:hasEnteredMarker', currentZone)
				end

				if not isInMarker and HasAlreadyEnteredMarker then
					HasAlreadyEnteredMarker = false
					TriggerEvent('esx_mechanik:hasExitedMarker', LastZone)
				end
				if sleep then
					Wait(500)
				end
			else
				Wait(2000)
			end
		else
			Wait(2000)
		end
	end
end)

CreateThread(function()
	while ESX.PlayerData.job == nil do
		Wait(100)
	end

	while true do
		if ESX.PlayerData.job ~= nil and Config.Zones[ESX.PlayerData.job.name] then
			local cacheInVehicle = cache.vehicle ~= false
			if not cacheInVehicle then
				local found = false
				for _, prop in ipairs({'prop_roadcone01b','prop_toolchest_02','prop_barrier_work01b'}) do
					local object = GetClosestObjectOfType(cacheCoords.x,  cacheCoords.y,  cacheCoords.z,  2.0,  GetHashKey(prop), false, false, false)
					
					if DoesEntityExist(object) then
						CurrentAction     = 'remove_entity'
						CurrentActionMsg  = {text = 'Naciśnij', button = 'E', description = 'aby usunąć obiekt.'}
						CurrentActionData = {entity = object}
						found = true
						break
					end
				end
				if not found and CurrentAction == 'remove_entity' then
					CurrentAction = nil
				end
				Wait(200)
			else
				Wait(1000)
			end
		else
			Wait(1000)
		end
	end
end)

CreateThread(function()
	while ESX.PlayerData.job == nil do
		Wait(100)
	end

	while true do
		Wait(0)
		if ESX.PlayerData.job.name == "mechanik" then
			if CurrentAction ~= nil then
				arivi_ui:helpNotification(CurrentActionMsg.text, CurrentActionMsg.button, CurrentActionMsg.description)
				if IsControlJustReleased(0, 38) then
					if Config.Zones[ESX.PlayerData.job.name] then
						if CurrentAction == 'delete_vehicle' then
							ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
						elseif CurrentAction == 'remove_entity' then
							ESX.Game.DeleteObject(CurrentActionData.entity)
						end
					end
				end
			else
				Wait(500)
			end
		else
			Wait(1000)
		end
	end
end)

local function lawetaWork()
	if not LocalPlayer.state.IsDead and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == "mechanik" then
		local currZone = Config.Zones.Vehicles

		if NPCOnJob then
			if GetGameTimer() - NPCLastCancel > 5 * 60000 then
				StopNPCJob(true)
				NPCLastCancel = GetGameTimer()
			else
				ESX.ShowNotification('Poczekaj 5 minut')
			end
		else
			if cacheVehicle ~= false and IsVehicleModel(cacheVehicle, `flatbed`) then
				StartNPCJob(currZone)
			else
				ESX.ShowNotification('Musisz być w lawecie!')
			end
		end
	end
end

exports('lawetaWork', lawetaWork)

local ox_target = exports.ox_target
local options = {
	{
		name = 'esx_mechanik:changePos',
		icon = 'fa-solid fa-wand-magic-sparkles',
		label = 'Obróć',
		canInteract = function(entity, distance, coords, name, bone)
			if LocalPlayer.state.IsDead or exports.arivi_paintball:IsInArena(true) or LocalPlayer.state.IsFishing or LocalPlayer.state.IsHandcuffed then
				return false
			end

			if distance > 2 then
				return false
			end

			if cacheVehicle then return false end

			return true
		end,
		onSelect = function (data)
			if DoesEntityExist(data.entity) then
				if arivi_ui:progressBar({
					duration = 5,
					label = 'Obracanie',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'mini@repair',
						clip = 'fixing_a_player'
					},
					prop = {},
				})
				then
					local vehicle = data.entity
					local carCoords = GetEntityRotation(vehicle, 2)

					SetEntityRotation(vehicle, carCoords[1], 0, carCoords[3], 2, true)
					SetVehicleOnGroundProperly(vehicle)
					ClearPedTasks(cachePed)

					ESX.ShowNotification('Pojazd został obrócony!')
				else 
					ESX.ShowNotification('Anulowano.')
				end
			else
				ESX.ShowNotification('W pobliżu nie ma żadnego pojazdu!')
			end
		end
	},
	{
		name = 'esx_mechanik:25fix',
		icon = 'fa-solid fa-wrench',
		label = 'Napraw (+25%)',
		canInteract = function(entity, distance, coords, name, bone)
			if LocalPlayer.state.IsDead or exports.arivi_paintball:IsInArena(true) or LocalPlayer.state.IsFishing or LocalPlayer.state.IsHandcuffed then
				return false
			end

			if distance > 2 then
				return false
			end

			if cacheVehicle then return false end

			local count = ox_inventory:Search('count', 'repairkit')

			if count <= 0 then
				if (not ESX.PlayerData.hiddenjob.name:find("org")) or (not ESX.PlayerData.hiddenjob.name:find("gang")) then
					if not lib.callback.await('arivi_bosshub:getUpgrades', false, 'accces_repairkit') then
						return false
					end
				end
			end

			return true
		end,
		onSelect = function (data)
			if DoesEntityExist(data.entity) then
				TriggerServerEvent('esx_core:komunikat', 'Wykonuje prace naprawcze przy pojeździe i usuwa wszystkie usterki')
				if arivi_ui:progressBar({
					duration = 5,
					label = 'Naprawianie',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'mini@repair',
						clip = 'fixing_a_player'
					},
					prop = {},
				})
				then
					SetVehicleUndriveable(data.entity, false)
					SetVehicleEngineOn(data.entity, true, true)
					SetVehicleEngineHealth(data.entity, GetEntityHealth(data.entity) + 250.0) 
					ClearPedTasks(cachePed)
					ESX.ShowNotification('Pojazd naprawiony +25%.')
					TriggerServerEvent("esx_core:deleteOldItem", 'repairkit')
				else 
					ESX.ShowNotification('Anulowano.')
				end
			else
				ESX.ShowNotification('W pobliżu nie ma żadnego pojazdu!')
			end
		end
	},
	{
		name = 'esx_mechanik:50fix',
		icon = 'fa-solid fa-wrench',
		label = 'Napraw (+50%)',
		canInteract = function(entity, distance, coords, name, bone)
			if LocalPlayer.state.IsDead or exports.arivi_paintball:IsInArena(true) or LocalPlayer.state.IsFishing or LocalPlayer.state.IsHandcuffed then
				return false
			end

			if distance > 2 then
				return false
			end

			if cacheVehicle then return false end

			if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'ambulance' then
				return true
			end

			return false
		end,
		onSelect = function (data)
			if DoesEntityExist(data.entity) then
				TriggerServerEvent('esx_core:komunikat', 'Wykonuje prace naprawcze przy pojeździe i usuwa wszystkie usterki')
				if arivi_ui:progressBar({
					duration = 5,
					label = 'Naprawianie',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'mini@repair',
						clip = 'fixing_a_player'
					},
					prop = {},
				})
				then
					SetVehicleUndriveable(data.entity, false)
					SetVehicleEngineOn(data.entity, true, true)
					SetVehicleEngineHealth(data.entity, GetEntityHealth(data.entity) + 500.0) 
					ClearPedTasks(cachePed)
					ESX.ShowNotification('Pojazd naprawiony +50%.')
				else 
					ESX.ShowNotification('Anulowano.')
				end
			else
				ESX.ShowNotification('W pobliżu nie ma żadnego pojazdu!')
			end
		end
	},
	{
		name = 'esx_mechanik:repair',
		icon = 'fa-solid fa-toolbox',
		label = 'Napraw (100%)',
		canInteract = function(entity, distance, coords, name, bone)
			if LocalPlayer.state.IsDead or exports.arivi_paintball:IsInArena(true) or LocalPlayer.state.IsFishing or LocalPlayer.state.IsHandcuffed then
				return false
			end

			if distance > 2 then
				return false
			end

			if not canUse(cacheCoords) then
				return false
			end

			if ESX.PlayerData.job.name ~= 'mechanik' then 
				return false
			end

			if cacheVehicle then return false end

			return true
		end,
		onSelect = function (data)
			if DoesEntityExist(data.entity) then
				TriggerServerEvent('esx_core:komunikat', 'Wykonuje prace naprawcze przy pojeździe i usuwa wszystkie usterki')
				if arivi_ui:progressBar({
					duration = 5,
					label = 'Naprawianie',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'mini@repair',
						clip = 'fixing_a_player'
					},
					prop = {},
				})
				then 
					TriggerServerEvent("esx_core:deleteOldItem", 'advancedrepairkit')

					SetVehicleFixed(data.entity)
					SetVehicleDeformationFixed(data.entity)
					SetVehicleUndriveable(data.entity, false)
					SetVehicleEngineOn(data.entity, true, true)
					SetVehicleEngineHealth(data.entity, 1000.0) 
					ClearPedTasks(cachePed)

					ESX.ShowNotification('Pojazd naprawiony do 100%.')
				else 
					ESX.ShowNotification('Anulowano.')
				end
			else
				ESX.ShowNotification('W pobliżu nie ma żadnego pojazdu!')
			end
		end
	},
	{
		name = 'esx_mechanik:hijack',
		icon = 'fa-solid fa-screwdriver',
		label = 'Odblokuj',
		canInteract = function(entity, distance, coords, name, bone)
			if LocalPlayer.state.IsDead or exports.arivi_paintball:IsInArena(true) or LocalPlayer.state.IsFishing or LocalPlayer.state.IsHandcuffed then
				return false
			end

			if distance > 2 then
				return false
			end

			local count = ox_inventory:Search('count', 'lockpick')

			if count <= 0 then
				return false
			end

			if cacheVehicle then return false end

			return true
		end,
		onSelect = function (data)
			ESX.UI.Menu.CloseAll()
		
			local vehicle = data.entity
		
			if vehicle and vehicle ~= 0 then		
				if IsVehicleAlarmSet(vehicle) and GetRandomIntInRange(1, 100) <= 33 then
					local id = NetworkGetNetworkIdFromEntity(vehicle)
					SetNetworkIdCanMigrate(id, false)
		
					local tries = 0
					while not NetworkHasControlOfNetworkId(id) and tries < 10 do
						tries = tries + 1
						NetworkRequestControlOfNetworkId(id)
						Citizen.Wait(100)
					end
		
					StartVehicleAlarm(vehicle)
					SetNetworkIdCanMigrate(id, true)
				end
		
				if arivi_ui:progressBar({
					duration = 3,
					label = 'Odblokowywanie...',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'mp_common_heist',
						clip = 'pick_door'
					},
					prop = {},
				})
				then
					if lib.skillCheck({'easy', 'easy', 'medium'}) then
						if arivi_ui:progressBar({
							duration = 3,
							label = 'Odblokowywanie...',
							useWhileDead = false,
							canCancel = true,
							disable = {
								car = true,
								move = true,
								combat = true,
								mouse = false,
							},
							anim = {
								dict = 'mp_common_heist',
								clip = 'pick_door'
							},
							prop = {},
						})
						then
							local id = NetworkGetNetworkIdFromEntity(vehicle)
							SetNetworkIdCanMigrate(id, false)
				
							local tries = 0
							while not NetworkHasControlOfNetworkId(id) and tries < 10 do
								tries = tries + 1
								NetworkRequestControlOfNetworkId(id)
								Citizen.Wait(100)
							end
				
							SetVehicleDoorsLocked(vehicle, 1)
							SetVehicleDoorsLockedForAllPlayers(vehicle, false)
							SetVehicleNeedsToBeHotwired(vehicle, true)
							SetVehicleAlarm(vehicle, false)
	
							if not cacheVehicle ~= false then
								SetVehicleInteriorlight(vehicle, true)
							end
	
							TriggerEvent('esx_carkeys:startVehicle', vehicle)
	
							ESX.ShowNotification('Pojazd otwarty.')
							ClearPedTasks(cachePed)
							TriggerServerEvent("esx_core:onRemoveDurability", 'lockpick')
						else
							ESX.ShowNotification('Anulowano.')
						end
					else
						ESX.ShowNotification('Spierdoliłeś/aś robotę, wstydź się!')
					end
				else 
					ESX.ShowNotification('Anulowano.')
				end
			else
				ESX.ShowNotification('W pobliżu nie ma żadnego pojazdu!')
			end
		end
	},
	{
		name = 'esx_mechanik:clean',
		icon = 'fa-solid fa-hands-bubbles',
		label = 'Umyj',
		canInteract = function(entity, distance, coords, name, bone)
			if LocalPlayer.state.IsDead or exports.arivi_paintball:IsInArena(true) or LocalPlayer.state.IsFishing or LocalPlayer.state.IsHandcuffed then
				return false
			end

			if distance > 2 then
				return false
			end

			local count = ox_inventory:Search('count', 'cleaningkit')

			if count <= 0 then
				return false
			end

			if cacheVehicle then return false end

			return true
		end,
		onSelect = function (data)
			if cacheVehicle then
				ESX.ShowNotification('Nie możesz tego wykonać w środku pojazdu!')
				return
			end
		
			if DoesEntityExist(data.entity) then
				TriggerServerEvent('esx_core:komunikat', 'Starannie czyści powierzchnie pojazdu')
				if arivi_ui:progressBar({
					duration = 5,
					label = 'Mycie...',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'switch@franklin@cleaning_car',
						clip = '001946_01_gc_fras_v2_ig_5_base'
					},
					prop = {},
				})
				then 
					SetVehicleDirtLevel(data.entity, 0)
					ClearPedTasks(cachePed)
		
					ESX.ShowNotification('Pojazd umyty.')
		
					TriggerServerEvent("esx_core:deleteOldItem", 'cleaningkit')
				else 
					ESX.ShowNotification('Anulowano.')
				end
			else
				ESX.ShowNotification('Nie znaleziono pojazdu, utracono przedmiot.')
			end
		end
	},
	{
		name = 'esx_mechanik:holl',
		icon = 'fa-solid fa-gears',
		label = 'Odholuj',
		canInteract = function(entity, distance, coords, name, bone)
			if LocalPlayer.state.IsDead or exports.arivi_paintball:IsInArena(true) or LocalPlayer.state.IsFishing or LocalPlayer.state.IsHandcuffed then
				return false
			end

			if distance > 2 then
				return false
			end

			if ESX.PlayerData.job.name ~= "police" and ESX.PlayerData.job.name ~= "ambulance" and ESX.PlayerData.job.name ~= "mechanik" then
				return false
			end

			if cacheVehicle then return false end

			return true
		end,
		onSelect = function (data)
			if cacheVehicle then
				ESX.ShowNotification('Nie możesz tego wykonać w środku pojazdu!')
				return
			end
		
			if DoesEntityExist(data.entity) then
				if arivi_ui:progressBar({
					duration = 5,
					label = 'Odholowywanie',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'switch@franklin@cleaning_car',
						clip = '001946_01_gc_fras_v2_ig_5_base'
					},
					prop = {},
				})
				then 
					ClearPedTasks(cachePed)
					ESX.Game.DeleteVehicle(data.entity)
		
					ESX.ShowNotification('Pojazd odholowany.')
				else 
					ESX.ShowNotification('Anulowano.')
				end
			else
				ESX.ShowNotification('Nie znaleziono pojazdu, utracono przedmiot.')
			end
		end
	},
}

ox_target:addGlobalVehicle(options)

local mechanikTargets = {}

RegisterNetEvent('esx_mechanik:sync:removeTargets', function ()
	Citizen.CreateThread(function ()
		if haveTargets then haveTargets = false end
		
		if #mechanikTargets > 0 then
			for i = 1, #mechanikTargets do
				ox_target:removeZone(mechanikTargets[i])
			end
		end
		
		mechanikTargets = {}
	end)
end)

RegisterNetEvent('esx_mechanik:sync:addTargetsCL', function ()
	if ESX.IsPlayerLoaded() then
		if ESX.PlayerData.job.name == "mechanik" then
			Citizen.CreateThread(function ()
				for k, v in pairs(Config.Zones[ESX.PlayerData.job.name]) do
					mechanikTargets[#mechanikTargets + 1] = ox_target:addBoxZone({
						coords = vec3(v.coords.x, v.coords.y, v.coords.z),
						size = v.size,
						rotation = v.rotation,
						debug = false,
						options = {
							{
								name = 'esx_mechanik:targets'..k,
								icon = v.icon,
								label = v.label,
								canInteract = function(entity, distance, coords, name)
									if LocalPlayer.state.IsDead then return false end
									if LocalPlayer.state.IsHandcuffed then return false end
									if distance > 1.50 then return false end
	
									if ESX.PlayerData.job.name == 'mechanik' then
										return true
									else 
										return false
									end
								end,
								onSelect = function ()
									ESX.UI.Menu.CloseAll()
	
									if tostring(k) == 'BossMenu' then
										if ESX.PlayerData.job.grade >= 7 then
											TriggerServerEvent('qf_society:openbosshub', 'fraction', false, true)
										else
											ESX.ShowNotification("Nie posiadasz dostępu!")
										end
									elseif tostring(k) == 'MechanicActions' then
										OpenMechanicActionsMenu()
									elseif tostring(k) == 'VehicleSpawner' then
										OpenMechanicVehicleSpawner(vec3(862.5353, -2123.9702, 30.5423), 354.7389)
									end
								end
							}
						}
					})
				end
			end)
		end
	end
end)

Citizen.CreateThread(function ()
	if ESX.PlayerLoaded then
		if ESX.PlayerData.job.name == "mechanik" then
			Citizen.CreateThread(function()
				RefreshTargets()
			end)
		else
			Citizen.CreateThread(function()
				DeleteTargets()
			end)
		end
	end
end)

local function OnFlatbedUse()
	if IsVehicleModel(cacheVehicle, 'flatbed') then
		if CurrentlyTowedVehicle == nil then
			local targetVehicle = lib.getClosestVehicle(cacheCoords, 5, false)
			if targetVehicle then
				if cacheVehicle ~= targetVehicle then
					local offset = {
						['flatbed'] = {x = 0.0, y = -3.5, z = 1.0},
					}

					AttachEntityToEntity(targetVehicle, cacheVehicle, GetEntityBoneIndexByName(cacheVehicle, 'bodyshell'), offset['flatbed'].x, offset['flatbed'].y, offset['flatbed'].z, 0, 0, 0, 1, 1, 0, 1, 0, 1)
					CurrentlyTowedVehicle = targetVehicle

					if NPCOnJob then
						if NPCTargetTowable == targetVehicle then
							ESX.ShowNotification('Zostaw pojazd we wskazanym punkcie.')
							if Blips['NPCTargetTowableZone'] ~= nil then
								RemoveBlip(Blips['NPCTargetTowableZone'])
								Blips['NPCTargetTowableZone'] = nil
							end

							Blips['NPCDelivery'] = AddBlipForCoord(Config.Zones.Vehicles.VehicleDelivery.coords.x, Config.Zones.Vehicles.VehicleDelivery.coords.y, Config.Zones.Vehicles.VehicleDelivery.coords.z)

							SetBlipRoute(Blips['NPCDelivery'], true)
						end
					end
				else
					ESX.ShowNotification('Nie możesz podpiąć własnej lawety!')
				end
			else
				ESX.ShowNotification('Brak pojazdu do podpięcia!')
			end
		else
			DetachEntity(CurrentlyTowedVehicle, true, true)
			local vehiclesCoords = GetOffsetFromEntityInWorldCoords(cacheVehicle, 0.0, -12.0, 0.0)
			SetEntityCoords(CurrentlyTowedVehicle, vehiclesCoords["x"], vehiclesCoords["y"], vehiclesCoords["z"], 1, 0, 0, 1)

			SetVehicleOnGroundProperly(CurrentlyTowedVehicle)
			if NPCOnJob then
				if CurrentlyTowedVehicle == NPCTargetTowable then
					local scope = function()
						SetVehicleHasBeenOwnedByPlayer(NPCTargetTowable, false)
						ESX.Game.DeleteVehicle(NPCTargetTowable)
						StopNPCJob(false)
					end

					if NPCTargetDeleterZone then
						scope()
					else
						ESX.ShowNotification('Nie jesteś w punkcie zrzutu pojazdów!')
					end
				elseif NPCTargetDeleterZone then
					ESX.ShowNotification('To nie jest właściwy pojazd!')
				end
			end

			CurrentlyTowedVehicle = nil
			ESX.ShowNotification('Zdjęto pojazd z lawety!')
		end
	else
		ESX.ShowNotification('Nie możesz teraz tego zrobić!')
	end
end

exports('OnFlatbedUse', OnFlatbedUse)