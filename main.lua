-- HelperFunctions
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")

local net_data = {}
local net_received = false



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
    spawn_crate(x, y, rarity, [items]) -> instance

    x               The x position of the crate
    y               The y position of the crate
    rarity          The rarity of the crate (see the .rarities enum); available: white, green, red, equipment, boss
    items           An array of class_item IDs (defaults to all items of the rarity)

    Spawns a command crate on the
    ground below the given position.
    In MP, spawning as host will
    sync spawning with clients.
    [!] Do not spawn as client.

    The contents of the crate can be
    replaced with an array of class_item IDs.

    Returns the created instance.


    Example:
    -- Spawns a green crate containing a Fire Shield and Red Whip
    Helper.spawn_crate(player.x, player.y, Helper.rarities.green, {gm.item_find("ror-fireShield"), gm.item_find("ror-redWhip")})
]]
spawn_crate = function(x, y, rarity, items)
    local lang_map = gm.variable_global_get("_language_map")
    local class_item = gm.variable_global_get("class_item")

    local sprites = {gm.constants.sCommandCrateCommon, gm.constants.sCommandCrateUncommon, gm.constants.sCommandCrateRare, gm.constants.sCommandCrateEquipment, gm.constants.sCommandCrateBoss}
    local sprites_use = {gm.constants.sCommandCrateCommonUse, gm.constants.sCommandCrateUncommonUse, gm.constants.sCommandCrateRareUse, gm.constants.sCommandCrateEquipmentUse, gm.constants.sCommandCrateBossUse}
    local isi = {6.0, 8.0, 10.0, 14.0, 12.0}
    local isii = {5.0, 7.0, 9.0, 13.0, 11.0}

    -- Move downwards until on the ground
    while not gm.position_meeting(x, y, gm.constants.pBlockStatic) and y < gm.variable_global_get("room_height") do y = y + 1 end

    -- Taken from Scrappers mod
    local c = gm.instance_create_depth(x, y, 0, gm.constants.oCustomObject_pInteractableCrate)

    -- Most of the following are necessary,
    -- and are not set from creating the instance directly (via gm.instance_create)
    c.active = 0.0
    c.owner = -4.0
    c.activator = -4.0
    c.buy_button_visible = 0.0
    c.can_activate_frame = 0.0
    c.mouse_x_last = 0.0
    c.mouse_y_last = 0.0
    c.last_move_was_mouse = false
    c.using_mouse = false
    c.last_activated_frame = -1.0
    c.cam_rect_x1 = x - 100
    c.cam_rect_y1 = y - 100
    c.cam_rect_x2 = x + 100
    c.cam_rect_y2 = y + 100
    c.contents = nil
    c.inventory = 74.0 + (rarity * 2.0)
    c.flash = 0.0
    c.interact_scroll_index = isi[rarity]
    c.interact_scroll_index_inactive = isii[rarity]
    c.surf_text_cost_large = -1.0
    c.surf_text_cost_small = -1.0
    c.translation_key = "interactable.pInteractableCrate"
    c.text = gm.ds_map_find_value(lang_map, c.translation_key..".text")
    c.spawned = true
    c.cost = 0.0
    c.cost_color = 8114927.0
    c.cost_type = 0.0
    c.selection = 0.0
    c.select_cd = 0.0
    c.sprite_index = sprites[rarity]
    c.sprite_death = sprites_use[rarity]
    c.fade_alpha = 0.0
    c.col_index = rarity - 1.0
    c.m_id = gm.set_m_id(true)  -- I have no idea what the argument is supposed to be, but this works
    c.my_player = -4.0
    c.__custom_id = rarity - 1.0
    c.__object_index = 799.0 + rarity
    c.image_speed = 0.06
    c.tier = rarity - 1.0

    -- Replace default crate items with custom set
    if items then
        c.contents = gm.array_create()
        for _, i in ipairs(items) do
            gm.array_push(c.contents, class_item[i + 1][9])
        end
    end

    -- [Host]  Send spawn data to clients
    if is_lobby_host() then net_send("HelperFunctions.spawn_crate", {x, y, rarity, items}) end

    return c
end


--[[
    ease_in(x, [n]) -> float

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
    ease_out(x, [n]) -> float

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
    is the host of a multiplayer lobby.

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
    is_lobby_client() -> bool

    Returns true if this game client
    is a client of a multiplayer lobby.
]]
is_lobby_client = function()
    return not is_singleplayer_or_host()
end


--[[
    is_singleplayer() -> bool

    Returns true if in a singleplayer run.
]]
is_singleplayer = function()
    return is_lobby_host(0.0)
end


--[[
    is_singleplayer_or_host() -> bool

    Returns true if in a singleplayer run,
    or if this game client is the host of the lobby.
]]
is_singleplayer_or_host = function()
    return is_singleplayer() or is_lobby_host()
end


--[[
    table_merge(...) -> table

    ...             A variable amount of tables.

    Returns a new table containing
    the values from input tables.

    Combining two number indexed tables will
    order them in the order that they were inputted.

        e.g.    a = {1, 3, 5}
                b = {2, 4, 6}
                c = Helper.table_merge(a, b)

                log.info(table.concat(c))   ->  "135246"
                log.info(c[5])              ->  4

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
            if tonumber(value) then value = tonumber(value)
            elseif value == "nil" then value = nil
            end
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
            class_id = gm.item_find(item[1].."-"..item[2]),
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
            class_id = gm.equipment_find(equip[1].."-"..equip[2]),
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

    Returns a copy of the table of item data tables (see initialize_item_table).
    If given, only returns items of a specified rarity.
]]
get_all_items = function(rarity)
    if not items then initialize_item_table() end
    if not rarity then return table_merge(items_all) end
    return table_merge(items[rarity])
end


--[[
    find_item(identifier) -> table or nil

    identifier      object_index, localization string
                    or "namespace-identifier" string of the item

    Returns a copy of the item data table (see initialize_item_table)
    if it exists, or nil otherwise.
]]
find_item = function(identifier)
    if not items then initialize_item_table() end
    local _type = type(identifier)
    for i = 1, #items_all do
        local item = items_all[i]
        if _type == "number" and item.id == identifier then return table_merge(item) end
        if _type == "string" and item.localization == identifier then return table_merge(item) end
        if _type == "string" and item.namespace.."-"..item.identifier == identifier then return table_merge(item) end
    end
    return nil
end


--[[
    net_send(id, data, [send_to_self], [exclude]) -> void

    id              The identifier of the data
    data            The data to be sent  (table)
    send_to_self    Whether or not to send the data to this client  (default false)
    exclude         The player to exclude  (by user_name, optional)
                    * This is useful if the host receives data from a client,
                      and wants to send the data to all other clients.

    Sends data to other players.
    You can queue multiple blocks of data under the same id.

    See net_listen for usage example.
]]
net_send = function(id, data, send_to_self, exclude)
    local my_player = gm.variable_global_get("my_player")
    local message = "[HelperFunctionsNET]"..id.."|||"..table_to_string(data)
    
    if exclude then message = message.."|||"..exclude end
    
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


--[[
    net_clear(id) -> bool

    id              The identifier of the data

    Clears all the data
    under the specified id.
]]
net_clear = function(id)
    net_data[id] = nil
end



-- ========== Hooks ==========

gm.pre_script_hook(gm.constants.__input_system_tick, function(self, other, result, args)
    -- [Client]  Spawn crate
    while net_has("HelperFunctions.spawn_crate") do
        local data = net_listen("HelperFunctions.spawn_crate").data
        spawn_crate(data[1], data[2], data[3], data[4])
    end
end)


-- Net functionality
gm.pre_script_hook(104659.0, function(self, other, result, args)
    net_received = true
end)

gm.pre_script_hook(gm.constants.chat_add_user_message, function(self, other, result, args)
    if net_received then
        net_received = false

        local player = args[1].value.user_name
        local text = args[2].value

        if string.sub(text, 1, 20) == "[HelperFunctionsNET]" then
            local data = gm.string_split(string.sub(text, 21, #text), "|||")

            if (not data[3]) or (data[3] ~= gm.variable_global_get("my_player").user_name) then
                if not net_data[data[1]] then net_data[data[1]] = {} end
                table.insert(net_data[data[1]], {
                    sender  = player,
                    data    = string_to_table(data[2])
                })
            end

            return false
        end
    end
end)