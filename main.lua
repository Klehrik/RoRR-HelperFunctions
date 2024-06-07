-- HelperFunctions v1.0.6
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")

local net_data = {}



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
    find_active_instance_all(index) -> table, bool

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

    Edited by Miguelito to work in Trials.
]]
get_client_player = function()
    -- Using pref_name to identify which player is this client
    -- TODO: Find a better way of checking instead
    local pref_name = ""
    local init = find_active_instance(gm.constants.oInit)
    if init then pref_name = init.pref_name end

    -- Get the player that belongs to this client
    local players = find_active_instance_all(gm.constants.oP)

    -- Return the first player if there is only one player
    if #players == 1 then return players[1] end

    for _, p in ipairs(players) do
        if p.user_name == pref_name then
            return p
        end
    end

    return nil
end


--[[
    get_host_player() -> instance or nil

    Returns the player instance belonging to
    the host, or nil if none can be found.
]]
get_host_player = function()
    -- Get the player that has an m_id of 1.0
    local players = find_active_instance_all(gm.constants.oP)
    for _, p in ipairs(players) do
        if p.m_id == 1.0 then
            return p
        end
    end
    return nil
end


--[[
    get_player_from_name(name) -> instance or nil

    name            The name to check for

    Returns the player instance with the specified
    user_name, or nil if they don't exist.
]]
get_player_from_name = function(name)
    local players = find_active_instance_all(gm.constants.oP)
    for _, p in ipairs(players) do
        if p.user_name == name then
            return p
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
    get_chests() -> table, bool

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
    get_multishops() -> table, bool

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
    chance(n) -> bool

    n               The chance to succeed (between 0 and 1)

    Returns true on success.
]]
chance = function(n)
    return gm.random_range(0, 1) <= n
end


--[[
    add_chat_message(text) -> void

    text            The message to send

    Taken from ShareItem mod.
]]
add_chat_message = function(text)
    gm.chat_add_message(gm["@@NewGMLObject@@"](gm.constants.ChatMessage, text))
end


--[[
    is_lobby_host() -> bool

    Returns true if this game client
    is the host of the lobby.

    Adapted from code by Miguelito.
]]
is_lobby_host = function(m_id)
    local m_id = m_id or 1.0

    local oInit = find_active_instance(gm.constants.oInit)
    if oInit then
        local pref_name = oInit.pref_name
        for i = 1, #gm.CInstance.instances_active do
            local inst = gm.CInstance.instances_active[i]
            if inst.user_name == pref_name then
                if inst.m_id == m_id then return true end
            end
        end
    end
    return false
end


--[[
    is_singleplayer() -> bool

    Returns true if in a singleplayer run.
]]
is_singleplayer = function(m_id)
    return is_lobby_host(0.0)
end


--[[
    table_merge(...) -> table

    ...             A variable amount of tables.

    Returns a new table containing
    the values from input tables.

    Combining two number indexed tables will
    order them in the order that they were inputted.

        e.g.    a = {1, 2, 3}
                b = {4, 5, 6}
                c = Helper.table_merge(a, b)

                log.info(table.concat(c))   ->  "123456"
                log.info(c[5])              ->  5

    When mixing number indexed and string keys, the
    indexed values will come first in order,
    while string keys will come after unordered.
]]
table_merge = function(...)
    local new = {}
    for _, t in ipairs{...} do
        for k, v in pairs(t) do
            if tonumber(k) then
                while new[k] do k = k + 1 end
            end
            new[k] = v
        end
    end
    return new
end


--[[
    table_to_string(table) -> string

    table           The table to convert

    Returns a string encoding of the table.
    Supports nested tables.
]]
table_to_string = function(table_)
    local str = ""
    for i, v in ipairs(table_) do
        if type(v) == "table" then str = str.."[[||"..table_to_string(v).."||]]||"
        else str = str..tostring(v).."||"
        end
    end
    return string.sub(str, 1, -3)
end


--[[
    string_to_table(string) -> table

    string          The string to convert

    Returns the table from the encoded string (see table_to_string).
]]
string_to_table = function(string_)
    local raw = gm.string_split(string_, "||")
    local parsed = {}
    local i = 0
    while i < #raw do
        i = i + 1
        if raw[i] == "[[" then  -- table
            local inner = raw[i + 1].."||"
            local j = i + 2
            local open = 1
            while true do
                if raw[j] == "[[" then open = open + 1
                elseif raw[j] == "]]" then open = open - 1
                end
                if open <= 0 then break end
                inner = inner..raw[j].."||"
                j = j + 1
            end
            table.insert(parsed, string_to_table(string.sub(inner, 1, -3)))
            i = j
        else
            local value = raw[i]
            if tonumber(value) then value = tonumber(value) end
            table.insert(parsed, value)
        end
    end
    return parsed
end


--[[
    initialize_item_table() -> void

    Initializes a table of item data tables.

    Called internally by the item
    functions below, but can be
    reinitialized anytime.

    Each item data table contains:
    .id             The object_index of the item
    .localization   The localization string of the item (i.e., "item.crowbar.name")
    .name           The name of the item in the current language
    .rarity         The rarity (tier) of the item  (number)
                    * This also corresponds to the .rarities enum at the top
                    * White (Common) is indexed from 1 here, while in-game it is tier 0
                    * "notier" (tier 8) items may be missing object_indexes
    .class_id       The index within the class_item/class_equipment arrays
    .namespace      The namespace that the item resides in (vanilla uses "ror")
    .identifier     The internal identifier that the item uses (i.e., "crowbar")
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
            rarity = rarity,
            class_id = i,
            namespace = item[1],
            identifier = item[2]
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
            rarity = rarity,
            class_id = i,
            namespace = equip[1],
            identifier = equip[2]
        }
        table.insert(items[rarity], data)
        table.insert(items_all, data)
    end
end


--[[
    get_all_items(rarity) -> table

    rarity          Item rarity filter (optional)

    Returns a table of item data tables (see initialize_item_table).
    If given, only returns items of a specified rarity.
]]
get_all_items = function(rarity)
    if not items then initialize_item_table() end
    if not rarity then return items_all end
    return items[rarity]
end


--[[
    find_item(identifier) -> table or nil

    identifier      object_index, localization string
                    or "namespace-identifier" string of the item

    Returns the item data table (see initialize_item_table)
    if it exists, or nil otherwise.
]]
find_item = function(identifier)
    if not items then initialize_item_table() end
    local _type = type(identifier)
    for i = 1, #items_all do
        local item = items_all[i]
        if _type == "number" and item.id == identifier then return item end
        if _type == "string" and item.localization == identifier then return item end
        if _type == "string" and item.namespace.."-"..item.identifier == identifier then return item end
    end
    return nil
end


--[[
    net_send(id, data, send_to_self) -> void

    id              The identifier of the data
    data            The data to be sent  (table)
    send_to_self    Whether or not to send the data to this client  (default false)

    Sends data to other players.
    You can queue multiple blocks of data under the same id.

    See net_listen for usage example.
]]
net_send = function(id, data, send_to_self)
    local my_player = gm.variable_global_get("my_player")
    local message = "[HelperFunctionsNET]"..id.."|||"..table_to_string(data)
    
    if send_to_self then gm.chat_add_user_message(my_player, message) end
    my_player:net_send_instance_message(4, message)
end


--[[
    net_listen(id) -> table or nil

    id              The identifier of the data to listen for

    Returns the first table of data that was sent under
    the specified id (net_send), and removes it from the queue
    (i.e., each net_send is read once using net_listen, in order of FIFO).

    The returned table contains:
    sender          The name of the player the data was sent from  (string)
    data            The table of data that was sent


    E.g.,
    Helper.net_send("set_damage", {1000}, true)
    Helper.net_send("set_damage", {2000}, true)
    Helper.net_send("tp_up", {100}, true)

    In __input_system_tick hook:
    local player = Helper.get_client_player()

    while Helper.net_has("set_damage") do
        local listener = Helper.net_listen("set_damage")
        player.damage = listener.data[1]    -- .data is a table
        player.damage_base = player.damage
    end

    local listener = Helper.net_listen("tp_up")
    if listener then
        player.y = player.y - listener.data[1]
    end


    The example above will:
    * Set all players' damage to 1000
    * Set all players' damage to 2000
    * Teleport all players upwards by 100 pixels
]]
net_listen = function(id)
    if net_data[id] then
        local data = net_data[id][1]
        table.remove(net_data[id], 1)
        if #net_data[id] <= 0 then net_data[id] = nil end
        return data
    end
    return nil
end


--[[
    net_has(id) -> bool

    id              The identifier of the data

    Returns true if there is data
    under the specified id.
]]
net_has = function(id)
    return net_data[id] ~= nil
end



-- ========== Hooks ==========

gm.pre_script_hook(gm.constants.__input_system_tick, function(self, other, result, args)
    -- Scan the 15 most recent chat messages and check if they have net_send ids
    local oInit = find_active_instance(gm.constants.oInit)
    if oInit and gm.ds_list_size(oInit.chat_messages) > 0 then
        for n = math.min(gm.ds_list_size(oInit.chat_messages) - 1, 15), 0, -1 do
            local message = gm.ds_list_find_value(oInit.chat_messages, n)

            if string.sub(message.text, 1, 20) == "[HelperFunctionsNET]" then
                local data = gm.string_split(string.sub(message.text, 21, #message.text), "|||")
                if not net_data[data[1]] then net_data[data[1]] = {} end
                table.insert(net_data[data[1]], {
                    sender  = message.name,
                    data    = string_to_table(data[2])
                })

                gm.ds_list_delete(oInit.chat_messages, n)
                oInit.chat_alpha = 0.0
            end
        end
    end
end)