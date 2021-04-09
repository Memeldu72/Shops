-- 
-- Fuck you dumper :)
--  By Memel#0001
-- 

local MemelServerEvent = TriggerServerEvent
Config = nil 

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

local openedMenu = false
local mainMenu = RageUI.CreateMenu("Vendeur", "Menu")
local subMenu = RageUI.CreateSubMenu(mainMenu, "Nourriture", "Menu")
local subMenu2 = RageUI.CreateSubMenu(mainMenu, "Boisson", "Menu")
mainMenu.Closed = function() openedMenu = false FreezeEntityPosition(PlayerPedId(), false) end

local lastPos = nil

function OpenMenu()
    if openedMenu then 
        openedMenu = false 
        return 
    else
        openedMenu = true 
        MemelServerEvent("Memel:addDumper")
        FreezeEntityPosition(PlayerPedId(), true)
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while openedMenu and Config == nil do 
                Wait(500)
                MemelServerEvent("Memel:addDumper")
            end 
        end)
        Citizen.CreateThread(function()
            while openedMenu do 
                RageUI.IsVisible(mainMenu, function()
                    RageUI.Button("~p~Nourriture", nil, {RightLabel = "→→"}, true, {}, subMenu)
                    RageUI.Button("~b~Boissons", nil, {RightLabel = "→→"}, true, {}, subMenu2)
                end)
                RageUI.IsVisible(subMenu, function()                 
                    if #Config.Categories.Nourriture ~= 0 then 
                        RageUI.Separator("↓ Liste des Nourritures ↓")
                        for k, v in pairs(Config.Categories.Nourriture) do 
                            RageUI.Button(v.label, nil, {RightLabel = "~g~"..ESX.Math.GroupDigits(v.price).."$"}, true, {
                                onSelected = function()
                                    MemelServerEvent("Memel:BuyBouffe", lastPos, v.name, v.label, v.price)
                                end, 
                            })
                        end 
                    else
                        RageUI.Separator("")
                        RageUI.Separator("~r~Il n'y as pas de Nourritures")
                        RageUI.Separator("")
                    end       
                end)
                RageUI.IsVisible(subMenu2, function()
                    if #Config.Categories.Boissons ~= 0 then 
                        RageUI.Separator("↓ Liste des Boissons ↓")
                        for k, v in pairs(Config.Categories.Boissons) do 
                            RageUI.Button(v.label, nil, {RightLabel = "~g~"..ESX.Math.GroupDigits(v.price).."$"}, true, {
                                onSelected = function()
                                    MemelServerEvent("Memel:BuyBouffe", lastPos, v.name, v.label, v.price)
                                end, 
                            })
                        end                     
                    else
                        RageUI.Separator("")
                        RageUI.Separator("~r~Il n'y as pas de Boissons")
                        RageUI.Separator("")
                    end                     
                end)
                Wait(1.0)
            end
        end)
    end
end


---- Position Menu ----
Citizen.CreateThread(function()  
    while Config == nil do 
        Wait(500)
        MemelServerEvent("Memel:addDumper")
    end 
    for k, v in pairs(Config.Position.Shops) do 
        -- Blips
        local blips = AddBlipForCoord(v.pos)
        SetBlipSprite(blips, 59)
        SetBlipColour(blips, 2)
        SetBlipScale(blips, 1.0)
        SetBlipDisplay(blips, 4)
        SetBlipAsShortRange(blips, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Boutique")
        EndTextCommandSetBlipName(blips)

        -- Peds 
        while not HasModelLoaded(v.pedModel) do
            RequestModel(v.pedModel)
            Wait(1)
        end
        Ped = CreatePed(2, GetHashKey(v.pedModel), v.pedPos, v.heading, 0, 0)
        FreezeEntityPosition(Ped, 1)
        TaskStartScenarioInPlace(Ped, v.pedModel, 0, false)
        SetEntityInvincible(Ped, true)
        SetBlockingOfNonTemporaryEvents(Ped, 1)
    end
    while true do 
        local myCoords = GetEntityCoords(PlayerPedId())
        local nofps = false

        if not openedMenu then 
            for k, v in pairs(Config.Position.Shops) do 
                if #(myCoords - v.pos) < 1.0 then 
                    nofps = true
                    Visual.Subtitle("Appuyer sur ~b~[E]~s~ pour parler au ~b~vendeur", 1) 
                    if IsControlJustPressed(0, 38) then 
                        lastPos = GetEntityCoords(PlayerPedId())                 
                        OpenMenu()
                    end 
                elseif #(myCoords - v.pos) < 5.0 then 
                    nofps = true 
                    DrawMarker(22, v.pos, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.3, 0.3, 0.3, 255, 0, 0 , 255, true, true, p19, true)     
                end 
            end 
        end
        if nofps then 
            Wait(1)
        else 
            Wait(1500)
        end 
    end
end)

RegisterNetEvent("Memel:Anti-Dump")
AddEventHandler("Memel:Anti-Dump", function(dumper)
    Config = dumper
end)