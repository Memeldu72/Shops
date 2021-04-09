local MemelSecure = TriggerEvent

ESX = nil 
MemelSecure('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
    MemelSecure("Memel:addDumper")
end)

RegisterServerEvent("Memel:BuyBouffe")
AddEventHandler("Memel:BuyBouffe", function(abcdef, name, label, price) 
	local xPlayer = ESX.GetPlayerFromId(source)
    if #(GetEntityCoords(GetPlayerPed(source)) - abcdef) > 1.5 then print("Le joueur : "..GetPlayerName(source).." vient de se faire détecter") return  DropPlayer(source, "\n\nCheat (Give Item)\nProtection by Memel#0001") end
	if xPlayer.getMoney() >= price then
	    xPlayer.removeMoney(price)
    	xPlayer.addInventoryItem(name, 1) 
        TriggerClientEvent('esx:showNotification', source, "Vous avez bien acheté ~b~1x "..label.."~s~ pour ~g~"..price.."$~s~ !")
     else 
        TriggerClientEvent('esx:showNotification', source, "Pas assez ~r~d'argent sur vous")    
    end
end)  

RegisterServerEvent("Memel:addDumper")
AddEventHandler("Memel:addDumper", function()
    local _src = source
    --print("Dumper envoyé !")
    TriggerClientEvent("Memel:Anti-Dump", _src, Config)
end)