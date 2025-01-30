local TriggerClientEvent = TriggerClientEvent
local RegisterServerEvent = RegisterServerEvent
local AddEventHandler = AddEventHandler
local ESX = ESX

local GetCurrentResourceName = GetCurrentResourceName
local ox_inventory = exports.ox_inventory
local esx_core = exports.esx_core

RegisterServerEvent('esx_mechanik:onNPCJobMissionCompleted')
AddEventHandler('esx_mechanik:onNPCJobMissionCompleted', function(distance, job)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if job ~= 'mechanik' then return end
	if xPlayer.job.name ~= 'mechanik' then return end

	local societyAccount
	local randomMnoznik = math.random(10, 15)
	local total = math.floor((distance * randomMnoznik) / 10)
	
	TriggerEvent('esx_addonaccount:getSharedAccount', job, function(account)
		societyAccount = account
	end)
	
	local mathRandom = math.random(1, 100)
	local random = math.random(1, 10)

	if mathRandom <= 25 then
		xPlayer.addInventoryItem('scrapmetal', random)
		xPlayer.showNotification('Otrzymano '.. random .. 'x złomu')
	end

	local result = MySQL.single.await('SELECT rankMechanicCourses FROM users WHERE identifier = ?', {xPlayer.identifier})

	if result ~= nil then
		if result.rankMechanicCourses then
			MySQL.update.await('UPDATE users SET rankMechanicCourses = ? WHERE identifier = ?', {result.rankMechanicCourses + 1, xPlayer.identifier})
		end
	end

	if societyAccount then
		local playerMoney  = math.floor(total / 100 * 25)
		local societyMoney = math.floor(total / 100 * 25)
		xPlayer.addMoney(playerMoney)
		societyAccount.addMoney(societyMoney)
		xPlayer.showNotification("Zarobiłeś $".. playerMoney)
		esx_core:SendLog(xPlayer.source, 'Wykonał kurs na Lawecie o długości `'..distance..'km` i zarobił `'..playerMoney..'$` natomiast firma LSC zarobiła na jego kursie `'..societyMoney..'`', 'mechanik_laweta')
	else
		xPlayer.addMoney(total)
		xPlayer.showNotification("Zarobiłeś $".. total)
		esx_core:SendLog(xPlayer.source, 'Wykonał kurs na Lawecie o długości `'..distance..'km` i zarobił `'..total..'$`', 'mechanik_laweta')
	end
end)

local stashes = {
    {
		id = 'mechanik',
		label = 'LSC Mechanik #1',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = {["mechanik"] = 1}
	},
}

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
		for i=1, #stashes do
			local stash = stashes[i]
			ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner, stash.groups)
		end
    end
end)

RegisterServerEvent('esx_mechanik:sync:addTargets', function ()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	if xPlayer.job.name == "mechanik" then
		TriggerClientEvent('esx_mechanik:sync:removeTargets', src)
		TriggerClientEvent('esx_mechanik:sync:addTargetsCL', src)
	else
		TriggerClientEvent('esx_mechanik:sync:removeTargets', src)
	end
end)