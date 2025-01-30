ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent("custom:giveLoot")
AddEventHandler("custom:giveLoot", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end

    local money = math.random(1000, 5000)
    xPlayer.addMoney(money)

    local items = {"diamond", "goldwatch", "rolex", "dirty_money"}
    local itemChance = math.random(1, 10)
    
    if itemChance > 7 then
        local chosenItem = items[math.random(#items)]
        xPlayer.addInventoryItem(chosenItem, 1)
    end
end)
