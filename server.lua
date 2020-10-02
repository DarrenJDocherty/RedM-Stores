local inventory = {}

local owners = {
    { owner = "steam:110000103effdea", location = "Rhodes" },
	{ owner = "steam:110000103effdea", location = "Saint Denis" },
	{ owner = "steam:110000105da6a87", location = "Emerald Ranch" },
    { owner = "steam:11000010cb9ab82", location = "Valentine" },
    { owner = "steam:11000013ebab4d7", location = "The Brick House" },
    { owner = "steam:110000103effdea", location = "Rhodes Saloon" },
    { owner = "steam:110000103effdea", location = "Saint Denis Saloon" },
    { owner = "steam:1100001025524a4", location = "Native Trade Center" },
    { owner = "steam:1100001025524a4", location = "Native Market" },
	{ owner = "steam:11000010627d653", location = "Doyles Tavern" },
	{ owner = "steam:11000010627d653", location = "Tumbleweed Saloon" },
	{ owner = "steam:110000103effdea", location = "Blackwater Store" },
	{ owner = "steam:110000103effdea", location = "Blackwater Saloon" },
	{ owner = "steam:11000010db9af9b", location = "Tumbleweed Store" },--steam:11000010db9af9b
	{ owner = "steam:110000103effdea", location = "Tumbleweed Saloon" },--steam:11000010db9af9b
}

TriggerEvent("redemrp_inventory:getData",function(call)
    inventory = call
end)

RegisterCommand("zz", function(source)
    --local _source = source
--
    --inventory.addItem(_source, "w_rifle_rollingblock01", 1, GetHashKey("WEAPON_SNIPERRIFLE_ROLLINGBLOCK_EXOTIC"))
end)


RegisterServerEvent("Stores:GetStoreItems")
AddEventHandler("Stores:GetStoreItems", function(location)
    local _source = source

    MySQL.Async.fetchAll("SELECT * FROM stores WHERE location=@location", { ['@location'] = location }, function(data)
       -- print(data, data[1], data[1].stock)
        TriggerClientEvent("Stores:ReturnStoreItems", _source, data)
	end)
end)

RegisterServerEvent("Stores:PurchaseItem")
AddEventHandler("Stores:PurchaseItem", function(location, item, amount)
    local _source = source

    MySQL.Async.fetchAll("SELECT * FROM stores WHERE location=@location AND item=@item", { ['@location'] = location, ['@item'] = item }, function(data)
        local stock = data[1].stock - amount
        local price = data[1].price * amount
        local owner = data[1].owner
        local charid = data[1].charid

        TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
            if user.getMoney() >= price then 
                MySQL.Async.execute("UPDATE stores SET stock=@stock WHERE location=@location AND item=@item", {['@location'] = location, ['@item'] = item, ['@stock'] = stock}, function(count)
                    if count > 0 then 
                        user.removeMoney(price)
                        inventory.addItem(_source, item, amount)
                        PayStoreOwner(owner, charid, price)
                        TriggerEvent("Log", _source, "Buy Item", "User purchased x" .. amount .. " " .. item .. " from the store in " .. location .. ".")
                        TriggerClientEvent("Stores:CloseStoreItemsMenu", _source)
                    end
                end)
            else 
                TriggerClientEvent("redemrp_notification:start", _source, "You don't have enough money!", 3)
            end
        end)
    end)
end)

function PayStoreOwner(owner, charid, price)
    MySQL.Async.fetchAll("SELECT * FROM characters WHERE identifier=@identifier AND characterid=@characterid", {['@identifier'] = owner, ['@characterid'] = charid}, function(result)
        if result[1] then 
            local bank = result[1].bank + price
            MySQL.Async.execute("UPDATE characters SET bank=@bank WHERE identifier=@identifier AND characterid=@characterid", {['@identifier'] = owner, ['@characterid'] = charid, ['@bank'] = bank})
        end
    end)
end

RegisterServerEvent("Stores:StoreItem")
AddEventHandler("Stores:StoreItem", function(item, amount, input, location, price)
    local _source = source
    local owner = GetSteamIdentifier(_source)
    
    local count = inventory.checkItem(_source, item)

    if count >= input then

        MySQL.Async.fetchAll("SELECT stock, owner FROM stores WHERE location=@location AND item=@item", { ['@location'] = location, ['@item'] = item }, function(result)
            if result[1] then
                local stock = input + result[1].stock

                local parameters = {['@location'] = location, ['@item'] = item, ['@stock'] = stock}

                MySQL.Async.execute("UPDATE stores SET stock=@stock WHERE location=@location AND item=@item", parameters, function(count)
                    if count > 0 then 
                        inventory.delItem(_source, item, input)
                        TriggerClientEvent("Stores:CloseMenu", _source)
                        TriggerServerEvent("Log", _source, "Buy Item", "User stored x" .. amount .. " " .. item .. " at the store in " .. location .. ".")
                    end
                end)
            else
                local parameters = {['@owner'] = owner, ['@location'] = location, ['@item'] = item, ['@stock'] = input, ['@price'] = price }
                MySQL.Async.execute("INSERT INTO stores (owner, location, item, stock, price) VALUES (@owner, @location, @item, @stock, @price)", parameters, function(count)
                    if count > 0 then 
                        inventory.delItem(_source, item, input)
                        TriggerClientEvent("Stores:CloseMenu", _source)
                        TriggerServerEvent("Log", _source, "Buy Item", "User stored x" .. amount .. " " .. item .. " at the store in " .. location .. ".")
                    end
                end)
            end
        end)
    else 
        TriggerClientEvent("Stores:CloseMenu", _source)
    end
end)

RegisterServerEvent("Stores:GetInventory")
AddEventHandler("Stores:GetInventory", function(location)
    local _source = source

	TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
		local identifier = user.getIdentifier()
        local charid = user.getSessionVar("charid")
        
        for k, v in pairs(owners) do 
            if v.owner == identifier and v.location == location then 
                MySQL.Async.fetchAll("SELECT * FROM user_inventory WHERE identifier=@identifier AND charid=@charid", { ['@identifier'] = identifier, ['@charid'] = charid }, function(result)
                    if result ~= nil then
                        TriggerClientEvent("Stores:ReturnInventory", _source, result, location)
                    end
                end)
            end
        end
	end)
end)

function GetSteamIdentifier(source)
	local identifier = GetPlayerIdentifiers(source)[1] or false

	if (identifier == false or identifier:sub(1,5) ~= "steam") then
		return false
	end

	return identifier
end