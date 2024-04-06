A collection of helper functions for modding.

To use, paste this line in your code (you can rename the `Helper` table):
```lua
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)
```

---

### Installation Instructions

* Navigate to the folder containing the *Risk of Rain Returns* executable (.exe) file.  (`Steam/steamapps/common/Risk of Rain Returns`)
* Download [`version.dll`](https://github.com/return-of-modding/ReturnOfModding/releases/tag/nightly) from either [Thunderstore](https://thunderstore.io/c/risk-of-rain-returns/p/ReturnOfModding/ReturnOfModding/) or the [unofficial modding GitHub page](https://github.com/return-of-modding/ReturnOfModding/) and place it into the folder.
* Run the game, and a folder called `ReturnOfModding` should be created.
* Close the game, navigate to the new folder, and extract the mod .zip into the `plugins` subfolder.
* Run the game again, and the mod should now be loaded. Enjoy!

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
find_active_instance_all(index) -> table or nil

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
get_chests() -> table or nil

Returns:
1. a table of all chests on the stage
2. true if the table is not empty
```

```
get_multishops() -> table or nil

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
chance(n) -> float

n               The chance to succeed (between 0 and 1)

Returns true on success.
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
```

```
get_all_items(rarity) -> table

rarity          Item rarity filter (optional)

Returns a table of item tables (see initialize_item_table).
If given, only returns items of a specified rarity.
```

```
find_item(identifier) -> table

identifier      object_index or localization string of the item

Returns the item table (see initialize_item_table)
if it exists, or nil otherwise.
```
