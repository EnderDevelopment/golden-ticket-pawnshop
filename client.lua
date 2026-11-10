local open = false
local catalog = {}

local function notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

local function openShop()
    if open then return end
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', shopName = Config.Shops[1].label, items = catalog })
end

local function closeShop()
    open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNetEvent('ender_pawnshop:catalog', function(items)
    catalog = items
end)

RegisterNetEvent('ender_pawnshop:result', function(success, message)
    SendNUIMessage({ action = 'saleResult', success = success, message = message })
    if success then TriggerServerEvent('ender_pawnshop:requestCatalog') end
end)

RegisterNUICallback('close', function(_, cb) closeShop() cb({ ok = true }) end)
RegisterNUICallback('sell', function(data, cb)
    TriggerServerEvent('ender_pawnshop:sell', data.name, data.amount)
    cb({ ok = true })
end)

CreateThread(function()
    TriggerServerEvent('ender_pawnshop:requestCatalog')
    for _, shop in ipairs(Config.Shops) do
        if Config.UseBlips and shop.blip ~= false then
            local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
            SetBlipSprite(blip, Config.Blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.Blip.scale)
            SetBlipColour(blip, Config.Blip.colour)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Config.Blip.name)
            EndTextCommandSetBlipName(blip)
        end
    end
    while true do
        local wait = 1000
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        for _, shop in ipairs(Config.Shops) do
            local distance = #(coords - shop.coords)
            if distance < Config.MarkerDistance then
                wait = 0
                DrawMarker(2, shop.coords.x, shop.coords.y, shop.coords.z + 0.2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.22, 0.22, 0.22, 239, 180, 78, 210, false, true, 2, false, nil, nil, false)
                if distance <= Config.InteractionDistance then
                    BeginTextCommandDisplayHelp('STRING')
                    AddTextComponentSubstringPlayerName('Press ~INPUT_CONTEXT~ to open the pawnshop')
                    EndTextCommandDisplayHelp(0, false, true, -1)
                    if IsControlJustReleased(0, 38) then openShop() end
                end
            end
        end
        Wait(wait)
    end
end)

CreateThread(function()
    while true do
        if open and IsControlJustReleased(0, 322) then closeShop() end
        Wait(0)
    end
end)
