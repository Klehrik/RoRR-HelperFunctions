A collection of helper functions for modding.

To use, paste this line in your code (you can rename the `Helper` table):
```lua
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)
```

---

### Installation Instructions

Follow the instructions [listed here](https://docs.google.com/document/d/1NgLwb8noRLvlV9keNc_GF2aVzjARvUjpND2rxFgxyfw/edit?usp=sharing).


### Credits
* Everybody active in the [Return of Modding server](https://discord.gg/VjS57cszMq).
* Miguelito for several additions.
* iDeathHD for the modloader itself and for helping with client->host chat message sending.

---

### Functions

Instances
```
find_active_instance(index) -> instance or nil

index           The object_index of the instance

Returns the first active instance of the specified
object_index, or nil if none can be found.
```

```
find_active_instance_all(index) -> table, bool

index           The object_index of the instance

Returns:
1. a table of all active instances of the specified object_index
2. true if the table is not empty
```

```
instance_exists(inst) -> bool

inst            The instance to check

Returns true if the instance exists.
```

Specific Instances
```
get_client_player() -> instance or nil

Returns the player instance belonging to
this client, or nil if none can be found.

Edited by Miguelito to work in Trials.
```

```
get_host_player() -> instance or nil

Returns the player instance belonging to
the host, or nil if none can be found.
```

```
get_player_from_name(name) -> instance or nil

name            The name to check for

Returns the player instance with the specified
user_name, or nil if they don't exist.
```

```
get_teleporter() -> instance or nil

Returns the stage teleporter,
or nil if there isn't one.

If there is more than one, the first one
found is returned, and the Divine Teleporter
takes precedence over standard teleporters.
```

```
get_chests() -> table, bool

Returns:
1. a table of all chests on the stage
2. true if the table is not empty
```

```
get_multishops() -> table, bool

Returns:
1. a table of all multishops on the stage
2. true if the table is not empty
```

Misc.
```
ease_in(x, n) -> float

x               The input value
n               The easing power (default 2 (quadratic))

Returns an ease in value for
a given value x between 0 and 1.
```

```
ease_out(x, n) -> float

x               The input value
n               The easing power (default 2 (quadratic))

Returns an ease out value for
a given value x between 0 and 1.
```

```
chance(n) -> bool

n               The chance to succeed (between 0 and 1)

Returns true on success.
```

```
add_chat_message(text) -> void

text            The message to send

Taken from ShareItem mod.
```

```
is_lobby_host() -> bool

Returns true if this game client
is the host of the lobby.

Adapted from code by Miguelito.
```

```
is_singleplayer() -> bool

Returns true if in a singleplayer run.
```

Tables
```
table_merge(...) -> table

...             A variable amount of tables

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
```

```
table_to_string(table) -> string

table           The table to convert

Returns a string encoding of the table.
Supports nested tables.
```

```
string_to_table(string) -> table

string          The string to convert

Returns the table from the encoded string (see table_to_string).
```

Items
```
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
```

```
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
```

```
get_all_items(rarity) -> table

rarity          Item rarity filter (optional)

Returns a table of item data tables (see initialize_item_table).
If given, only returns items of a specified rarity.
```

```
find_item(identifier) -> table or nil

identifier      object_index, localization string
                or "namespace-identifier" string of the item

Returns the item data table (see initialize_item_table)
if it exists, or nil otherwise.
```

Net
```
net_send(id, data, send_to_self) -> void

id              The identifier of the data
data            The data to be sent  (table)
send_to_self    Whether or not to send the data to this client  (default false)

Sends data to other players.
You can queue multiple blocks of data under the same id.

See net_listen for usage example.
```

```
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
```

```
net_has(id) -> bool

id              The identifier of the data

Returns true if there is data
under the specified id.
```