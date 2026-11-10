local QBCore, ESX
local framework = Config.Framework
local inventory = Config.Inventory

local function detectFramework()
    if framework ~= 'auto' then return framework end
    if GetResourceState('qb-core') == 'started' then return 'qb' end
    if GetResourceState('es_extended') == 'started' then return 'esx' end
    return 'standalone'
end

local function detectInventory()
    if inventory ~= 'auto' then return inventory end
    if GetResourceState('ox_inventory') == 'started' then return 'ox' end
    if framework == 'qb' or GetResourceState('qb-core') == 'started' then return 'qb' end
    if framework == 'esx' or GetResourceState('es_extended') == 'started' then return 'esx' end
    return 'standalone'
end

framework = detectFramework()
inventory = detectInventory()
if framework == 'qb' then QBCore = exports['qb-core']:GetCoreObject() end
if framework == 'esx' then ESX = exports['es_extended']:getSharedObject() end

local function playerObject(source)
    if framework == 'qb' and QBCore then return QBCore.Functions.GetPlayer(source) end
    if framework == 'esx' and ESX then return ESX.GetPlayerFromId(source) end
end

local function itemCount(source, itemName)
    if inventory == 'ox' then
        return exports.ox_inventory:Search(source, 'count', itemName) or 0
    end
    local player = playerObject(source)
    if not player then return 0 end
    if framework == 'qb' then
        local item = player.Functions.GetItemByName(itemName)
        return item and item.amount or 0
    end
    local item = player.getInventoryItem(itemName)
    return item and item.count or 0
end

local function removeItem(source, itemName, amount)
    if inventory == 'ox' then return exports.ox_inventory:RemoveItem(source, itemName, amount) end
    local player = playerObject(source)
    if not player then return false end
    if framework == 'qb' then return player.Functions.RemoveItem(itemName, amount) end
    if framework == 'esx' then player.removeInventoryItem(itemName, amount) return true end
    return false
end

local function addMoney(source, amount)
    local player = playerObject(source)
    if framework == 'qb' then return player.Functions.AddMoney(Config.Currency, amount, 'pawnshop-sale') end
    if framework == 'esx' then
        if Config.Currency == 'cash' then player.addMoney(amount) else player.addAccount(Config.Currency, amount) end
        return true
    end
    return false
end

local function findItem(itemName)
    for _, item in ipairs(Config.Items) do
        if item.name == itemName then return item end
    end
end

local function nearShop(source)
    local ped = GetPlayerPed(source)
    if ped <= 0 then return false end
    local coords = GetEntityCoords(ped)
    for _, shop in ipairs(Config.Shops) do
        if #(coords - shop.coords) <= Config.InteractionDistance + 1.0 then return true end
    end
    return false
end

RegisterNetEvent('ender_pawnshop:requestCatalog', function()
    TriggerClientEvent('ender_pawnshop:catalog', source, Config.Items)
end)

RegisterNetEvent('ender_pawnshop:sell', function(itemName, amount)
    local source = source
    local item = type(itemName) == 'string' and findItem(itemName)
    amount = math.floor(tonumber(amount) or 0)
    if not item or amount < 1 or amount > 10000 or not nearShop(source) then
        TriggerClientEvent('ender_pawnshop:result', source, false, 'Sale rejected.')
        return
    end
    local available = itemCount(source, item.name)
    if available < amount then
        TriggerClientEvent('ender_pawnshop:result', source, false, ('You only have %d available.'):format(available))
        return
    end
    if not removeItem(source, item.name, amount) or not addMoney(source, item.price * amount) then
        TriggerClientEvent('ender_pawnshop:result', source, false, 'Your inventory or wallet could not be updated.')
        return
    end
    TriggerClientEvent('ender_pawnshop:result', source, true, ('Sold %dx %s for $%s.'):format(amount, item.label, formatMoney(item.price * amount)))
end)

function formatMoney(value)
    local text = tostring(math.floor(value))
    while true do
        local replaced, count = text:gsub('^(-?%d+)(%d%d%d)', '%1,%2')
        text = replaced
        if count == 0 then return text end
    end
end
