ESX = exports["es_extended"]:getSharedObject() -- Pobranie ESX

local coords = vector3(1412.8574, -728.8727, 67.6377)
local requiredItems = {"lockpick", "weapon_crowbar", "weapon_pistol"}

exports.ox_target:addBoxZone({
    coords = coords,
    size = vec3(2, 2, 2),
    rotation = 0,
    debug = false,
    options = {
        {
            name = "rob_container",
            event = "custom:robContainer",
            icon = "fas fa-box-open",
            label = "Obrabuj kontener",
            canInteract = function(entity, distance, coords)
                return distance < 2.0
            end
        }
    }
})

RegisterNetEvent("custom:robContainer", function()
    local playerPed = PlayerPedId()
    local hasItem = false
    
    for _, item in ipairs(requiredItems) do
        if exports.ox_inventory:Search('count', item) > 0 then
            hasItem = true
            break
        end
    end
    
    if hasItem then
        TriggerEvent("mtracker:show")
        TriggerEvent("mtracker:start", 4, 30, function(success)
            TriggerEvent("mhacking:hide")
            if success then
                TriggerServerEvent("custom:giveLoot")
                ESX.ShowNotification("Udało się! Otrzymałeś nagrodę.")
            else
                ESX.ShowNotification("Nie udało się! Spróbuj ponownie.")
            end
        end)
    else
        ESX.ShowNotification("Potrzebujesz: lockpick, crowbar lub pistolet!")
    end
end)
