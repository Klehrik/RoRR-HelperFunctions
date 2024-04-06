-- HelperFunctions v1.0.0
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")



-- ========== Data ==========

hfuncs = true

items = nil
items_all = nil
rarities = {
    white = 1,
    green = 2,
    red = 3,
    equipment = 4,
    boss = 5,
    purple = 6,
    food = 7,
    notier = 8
}



-- ========== Functions ==========

--[[
    find_active_instance(index) -> instance or nil

    index           The object_index of the instance

    Returns the first active instance of the specified
    object_index, or nil if none can be found.
]]
find_active_instance = function(index)
    local inst = gm.instance_find(index, 0)
    if not instance_exists(inst) then return nil end
    return inst
end


--[[
    find_active_instance_all(index) -> table or nil

    index           The object_index of the instance

    Returns:
    1. a table of all active instances of the specified object_index
    2. true if the table is not empty
]]
find_active_instance_all = function(index)
    local insts = {}
    for i = 0, gm.instance_number(index) - 1 do
        table.insert(insts, gm.instance_find(index, i))
    end
    return insts, #insts > 0
end


--[[
    instance_exists(inst) -> bool

    inst            The instance to check

    Returns true if the instance exists.
]]
instance_exists = function(inst)
    return gm.instance_exists(inst) == 1.0
end


--[[
    get_client_player() -> instance or nil

    Returns the player instance belonging to
    this client, or nil if none can be found.
]]
get_client_player = function()
    -- Using pref_name to identify which player is this client
    -- TODO: Find a better way of checking instead
    local pref_name = ""
    local init = find_active_instance(gm.constants.oInit)
    if init then pref_name = init.pref_name end

    -- Get the player that belongs to this client
    local players = find_active_instance_all(gm.constants.oP)
    for i = 1, #players do
        if players[i] then
            if players[i].user_name == pref_name then
                return players[i]
            end
        end
    end

    return nil
end


--[[
    get_teleporter() -> instance or nil

    Returns the stage teleporter,
    or nil if there isn't one.

    If there is more than one, the first one
    found is returned, and the Divine Teleporter
    takes precedence over standard teleporters.
]]
get_teleporter = function()
    local tp = find_active_instance(gm.constants.oTeleporter)
    local tpe = find_active_instance(gm.constants.oTeleporterEpic)
    if tpe then return tpe end
    if tp then return tp end
    return nil
end


--[[
    get_chests() -> table or nil

    Returns:
    1. a table of all chests on the stage
    2. true if the table is not empty
]]
get_chests = function()
    local chests = {}
    local types = {
        gm.constants.oChest1, gm.constants.oChest2, gm.constants.oChest5,
        gm.constants.oChestHealing1, gm.constants.oChestDamage1, gm.constants.oChestUtility1,
        gm.constants.oChestHealing2, gm.constants.oChestDamage2, gm.constants.oChestUtility2,
        gm.constants.oGunchest
    }
    for i = 1, #types do
        local c = find_active_instance_all(types[i])
        for j = 1, #c do table.insert(chests, c[j]) end
    end
    return chests, #chests > 0
end


--[[
    get_multishops() -> table or nil

    Returns:
    1. a table of all multishops on the stage
    2. true if the table is not empty
]]
get_multishops = function()
    local shops = {}
    local types = {gm.constants.oShop1, gm.constants.oShop2}
    for i = 1, #types do
        local s = find_active_instance_all(types[i])
        for j = 1, #s do table.insert(shops, s[j]) end
    end
    return shops, #shops > 0
end


--[[
    ease_in(x, n) -> float

    x               The input value
    n               The easing power (default 2 (quadratic))

    Returns an ease in value for
    a given value x between 0 and 1.
]]
ease_in = function(x, n)
    local n = n or 2
    return gm.power(x, n)
end


--[[
    ease_out(x, n) -> float

    x               The input value
    n               The easing power (default 2 (quadratic))

    Returns an ease out value for
    a given value x between 0 and 1.
]]
ease_out = function(x, n)
    local n = n or 2
    return 1 - gm.power(1 - x, n)
end


--[[
    chance(n) -> float

    n               The chance to succeed (between 0 and 1)

    Returns true on success.
]]
chance = function(n)
    return gm.random_range(0, 1) <= n
end


--[[
    initialize_item_table() -> void

    Called internally by the item
    functions below, but can be
    reinitialized anytime.

    Each item table contains:
    .id             The object_index of the item
    .localization   The localization string of the item (i.e., "item.crowbar.name")
    .name           The name of the item in the current language
    .rarity         The rarity of the item  (number)
                    * This also corresponds to the .rarities enum at the top
                    * White (Common) is indexed from 1 here, while in-game it is tier 0
]]
initialize_item_table = function()
    items = {}
    items_all = {}
    local lang_map = gm.variable_global_get("_language_map")
    local class_item = gm.variable_global_get("class_item")
    for i = 1, #class_item do
        local item = class_item[i]
        local rarity = item[7] + 1
        if not items[rarity] then items[rarity] = {} end
        local data = {
            id = item[9],
            localization = item[3], 
            name = gm.ds_map_find_value(lang_map, item[3]),
            rarity = rarity
        }
        table.insert(items[rarity], data)
        table.insert(items_all, data)
    end
    local equips = gm.variable_global_get("class_equipment")
    for i = 1, #equips do
        local equip = equips[i]
        local rarity = equip[7] + 1
        if not items[rarity] then items[rarity] = {} end
        local data = {
            id = equip[9],
            localization = equip[3],
            name = gm.ds_map_find_value(lang_map, equip[3]),
            rarity = rarity
        }
        table.insert(items[rarity], data)
        table.insert(items_all, data)
    end
end


--[[
    get_all_items(rarity) -> table

    rarity          Item rarity filter (optional)

    Returns a table of item tables (see initialize_item_table).
    If given, only returns items of a specified rarity.
]]
get_all_items = function(rarity)
    if not items then initialize_item_table() end
    if not rarity then return items_all end
    return items[rarity]
end


--[[
    find_item(identifier) -> table

    identifier      object_index or localization string of the item

    Returns the item table (see initialize_item_table)
    if it exists, or nil otherwise.
]]
find_item = function(identifier)
    if not items then initialize_item_table() end
    local _type = type(identifier)
    for i = 1, #items do
        local rarity = items[i]
        for j = 1, #rarity do
            local item = rarity[j]
            if _type == "number" and item.id == identifier then return item end
            if _type == "string" and item.localization == identifier then return item end
        end
    end
    return nil
end