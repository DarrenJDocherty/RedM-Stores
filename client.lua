local stores = {
    { location = "Saint Denis", x=2825.719, y=-1318.296, z=46.755 },
    { location = "Rhodes", x=1328.61, y=-1292.92, z=77.02 },
    { location = "Valentine", x=-322.44, y=804.51, z=117.88 },
    { location = "The Brick House", x=-314.21, y=808.54, z=118.98 },
    { location = "Emerald Ranch", x=1420.53, y=379.65, z=90.32 },
    { location = "Rhodes Saloon", x=1341.870, y=-1375.267, z=80.480 },
    { location = "Saint Denis Saloon", x=2637.969, y=-1224.990, z=53.380 },
    { location = "Native Trade Center", x=584.92, y=1694.76, z=187.46 },
    { location = "Native Market", x=-2378.92, y=-2360.86, z=62.18 },
	{ location = "Doyles Tavern", x=2793.99, y=-1168.81, z=47.93 },
	{ location = "Blackwater Saloon", x=-819.01, y=-1315.7, z=43.68 },
	{ location = "Blackwater Store", x=-785.57, y=-1324.09, z=43.88 },
	{ location = "Tumbleweed Store", x=-5487.17, y=-2939.12, z=-0.39 },
	{ location = "Tumbleweed Saloon", x=-5517.63, y=-2907.98, z=-1.75 },
}

local storekeepers = {
    { model="U_F_M_TumGeneralStoreOwner_01", x=2825.21, y=-1319.93, z=46.68, h=321.64}, -- Saint Denis
    { model="U_F_M_TumGeneralStoreOwner_01", x=1330.38, y=-1293.83, z=77.02, h=58.70 }, -- rhodes
    { model="U_F_M_TumGeneralStoreOwner_01", x=-324.67, y=804.18, z=117.88, h=280.88 }, -- valentine
    { model="U_F_M_TumGeneralStoreOwner_01", x=-314.88, y=808.59, z=118.98, h=277.22 }, -- valentine saloon
    { model="U_F_M_TumGeneralStoreOwner_01", x=1420.73, y=381.7, z=90.33, h=166.32 }, -- ranch
    { model="U_M_M_NbxBartender_01", x=2639.895, y=-1225.243, z=53.380, h=84.180 }, -- ranch
    { model="U_M_M_NbxBartender_01", x=1340.220, y=-1374.761, z=80.480, h=258.114}, -- Rhodes saloon
	{ model="U_M_M_NbxBartender_01", x=2792.77, y=-1167.77, z=47.93, h=244.18}, -- Doyles Tavern
	{ model="U_M_M_NbxBartender_01", x=-819.04, y=-1318.33, z=43.68, h=357.39}, -- Blackwater Tavern
	{ model="U_F_M_TumGeneralStoreOwner_01", x=-785.14, y=-1321.76, z=43.88, h=170.96}, -- Blackwater Store
	{ model="U_F_M_TumGeneralStoreOwner_01", x=-5485.98, y=-2937.91, z=-0.4, h=122.21}, -- Tumbleweed Store
	{ model="U_M_M_NbxBartender_01", x=-5518.81, y=-2906.69, z=-1.75, h=214.4}, -- Tumbleweed Saloon
}

RegisterCommand("D", function()
    local heading = GetEntityHeading(PlayerPedId())
    print(heading)
end)

local shopkeeper = {}
local player_inventory = nil
local store_inventory = nil
local store = nil
local open = false
local sound = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        
        
        for _, storekeeper in pairs(storekeepers) do
            if not DoesEntityExist(shopkeeper[_]) then
                RequestModel(GetHashKey(storekeeper.model))

                while not HasModelLoaded(GetHashKey(storekeeper.model)) do
                    Wait(100)
                end

                shopkeeper[_] = CreatePed(storekeeper.model, storekeeper.x, storekeeper.y, storekeeper.z, storekeeper.h, false, true)
                SetPedRandomComponentVariation(shopkeeper[_], 0)
                SetBlockingOfNonTemporaryEvents(shopkeeper[_], true)
                SetEntityInvincible(shopkeeper[_], true)
                SetPedCanBeTargettedByPlayer(shopkeeper[_], GetPlayerPed(), false)
            end
        end
        

        for _, store in pairs(stores) do
            if IsPlayerNearCoords(store.x, store.y, store.z) then
                if not open then 
                    DrawSprite("generic_textures", "help_text_1c", 0.065, 0.08, 0.10, 0.05, 0.0, 1, 1, 1, 200, 1)
                    DrawText("PRESS [SPACE] TO USE VIEW STORE",0.5,0.88)

                    if not sound then
                        PlaySoundFrontend("INFO", "HUD_SHOP_SOUNDSET", 1)
                        sound = true
                    end
                else
                    sound = false
                end

                if IsControlJustPressed(0, 0xD9D0E1C0) then -- SPACE key
                    TriggerServerEvent("Stores:GetStoreItems", store.location)
                    open = true
                end

                if IsControlJustPressed(0, 0x3C0A40F2) then -- F6 key
                    TriggerServerEvent("Stores:GetInventory", store.location)
                    open = true
                end

                if IsControlJustPressed(0, 0x3C0A40F2) then -- F6 key
                    open = false
                end
            end
        end
    end
end)

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str, Citizen.ResultAsLong())
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
	Citizen.InvokeNative(0xADA9255D, 10);
	DisplayText(str, x, y)
end

RegisterCommand("subtitle", function()
    local msg = "indra is gay"
    local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", msg, Citizen.ResultAsLong())
    Citizen.InvokeNative(0xFA233F8FE190514C, str)
    Citizen.InvokeNative(0xE9990552DEC71600)
    local a = Citizen.InvokeNative(0xDFF0D417277B41F8, Citizen.ResultAsInteger())
end)
--[[
function DrawText(text, x, y, r, g, b, a, scaleX, scaleY)
    local string = CreateVarString(10, "LITERAL_STRING", text)
    SetTextColor(227,227,227,255)
    SetTextFontForCurrentCommand(0) -- 6rdr, 9, very clean 20 also nice, 24 is handwritten, 28 another handwritten
    SetTextScale(0.35, 0.35)
    DisplayText(string, x, y)
end

function DrawTextl(text,x,y)
    SetTextScale(0.35,0.35)
    SetTextColor(255,255,255,255)--r,g,b,a
    SetTextCentre(true)--true,false
    SetTextDropshadow(1,0,0,0,200)--distance,r,g,b,a
    SetTextFontForCurrentCommand(0)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end]]

Citizen.CreateThread(function()
    WarMenu.CreateMenu('StoreItems', 'Store')
    WarMenu.SetSubTitle('StoreItems', 'PURCHASE ITEMS')
    WarMenu.SetMenuX('StoreItems', 0.04)
    WarMenu.SetMenuMaxOptionCountOnScreen('StoreItems', 15)
    
    while true do
        Citizen.Wait(0)

        if WarMenu.IsMenuOpened('StoreItems') then
            for k, v in pairs(store_inventory) do 
                if store_inventory[k].stock > 0 then
                    if WarMenu.Button(store_inventory[k].item, tostring("$" .. store_inventory[k].price), tostring("Stock: " .. store_inventory[k].stock)) then
                        Purchase(store_inventory[k].location, store_inventory[k].item, store_inventory[k].stock)
                    end
                end
            end

            WarMenu.Display()
        end

        if WarMenu.IsMenuAboutToBeClosed() then 
            store_inventory = {}
        end
    end
end)

RegisterNetEvent("Stores:CloseStoreItemsMenu")
AddEventHandler("Stores:CloseStoreItemsMenu", function()
    WarMenu.CloseMenu('StoreItems')
end)

RegisterNetEvent("Stores:ReturnStoreItems")
AddEventHandler("Stores:ReturnStoreItems", function(data)
    store_inventory = data
    Wait(1000)
    WarMenu.OpenMenu('StoreItems')
end)

function Purchase(location, item, stock)
    AddTextEntry("FMMC_KEY_TIP8", "Amount:")
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 4)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end
	
    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end
	
    if (GetOnscreenKeyboardResult()) then
        local amount = math.floor(tonumber(GetOnscreenKeyboardResult()))

        if (amount > 0) and (amount <= stock) then 
            TriggerServerEvent("Stores:PurchaseItem", location, item, amount)
        else 
            TriggerEvent("redemrp_notification:start", 'Invalid input!', 3)
        end
    end
end

RegisterNetEvent("Stores:CloseMenu")
AddEventHandler("Stores:CloseMenu", function()
    WarMenu.CloseMenu('StoreMenu')
end)

RegisterNetEvent("Stores:ReturnInventory")
AddEventHandler("Stores:ReturnInventory", function(data, location)
    player_inventory = json.decode(data[1].items)
    store = location

    Wait(1000)
    
    WarMenu.OpenMenu('StoreMenu')
end)

Citizen.CreateThread(function()
    WarMenu.CreateMenu('StoreMenu', "Store")
    WarMenu.SetSubTitle('StoreMenu', 'ADD TO STORE')
    WarMenu.SetMenuX('StoreMenu', 0.04)
    WarMenu.SetMenuMaxOptionCountOnScreen('StoreMenu', 15)

    while true do
        Citizen.Wait(0)

        if WarMenu.IsMenuOpened('StoreMenu') then
            for item, amount in pairs(player_inventory ) do 
				if type(amount) == "number" then 
					if amount > 0 then
						if WarMenu.Button(item, tostring(amount)) then
							Store(item, amount)
						end
					end
				end
            end

            WarMenu.Display()
        end

        if WarMenu.IsMenuAboutToBeClosed() then 
            player_inventory = {}
        end
    end
end)

function Store(item, amount)
	AddTextEntry("FMMC_KEY_TIP8", "Amount to store:")
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 4)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end

    while (UpdateOnscreenKeyboard() == 1) do
        Wait(0)
        if (GetOnscreenKeyboardResult()) then
            local input = math.floor(tonumber(GetOnscreenKeyboardResult()))
    
            if (input <= amount) and (input > 0) then 
                Price(item, amount, input)
                
                break
            else 
                TriggerEvent("redemrp_notification:start", 'You do not have enough to store!', 3)
                break
            end
        end
    end
	
    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end
end

function Price(item, amount, input)
	AddTextEntry("FMMC_KEY_TIP8", "Item Price:")
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 4)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end
	
    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end
	
    if (GetOnscreenKeyboardResult()) then
        local price = (tonumber(GetOnscreenKeyboardResult()))

        if price >= 1 then 
            TriggerServerEvent("Stores:StoreItem", item, amount, input, store, price)
        else 
            TriggerEvent("redemrp_notification:start", 'Must be $1 or more!', 3, 'error')
        end
    end
end

function IsPlayerNearCoords(x, y, z)
    local playerx, playery, playerz = table.unpack(GetEntityCoords(GetPlayerPed(), 0))
    local distance = GetDistanceBetweenCoords(playerx, playery, playerz, x, y, z, true)

    if distance < 1 then
        return true
    end
end

function DrawText(text,x,y)
	local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(0.44,0.44)
    SetTextColor(255,255,255,255)--r,g,b,a
    SetTextCentre(true)--true,false
    SetTextDropshadow(1,0,0,0,255)--distance,r,g,b,a
    SetTextFontForCurrentCommand(0)
	Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end