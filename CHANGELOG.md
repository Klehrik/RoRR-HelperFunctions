### v1.0.10
* Marked as deprecated on Thunderstore.
* Fixed `chat_add_user_message` hook firing for every message after receiving first Net message.

### v1.0.9
* Added: is_lobby_client
* Added: spawn_crate
* string_to_table now reads nil correctly.
* find_item and get_all_items now return new copies of the item data tables.
    * This is to prevent direct manipulation of the main one, which is shared by all mods.
* Net functionality now intercepts messages instead of scanning chat and deleting.

### v1.0.8
* Added: net_clear

### v1.0.7
* Added: is_singleplayer_or_host
* net_send can now exclude a player.

### v1.0.6
* Added: table_to_string
* Added: string_to_table
* Added: net_send
* Added: net_listen
* Added: net_has
* Added: is_singleplayer
* Added: get_player_from_name

### v1.0.5
* get_client_player works in Trials mode now.

### v1.0.4
* find_item works with "namespace-identifier" strings now.
* Added: get_host_player
* Added: is_lobby_host
* Added: table_merge

### v1.0.3
* Updated manifest dependency.
* Added add_chat_message (from ShareItem).

### v1.0.2
* Added more fields to item data tables.

### v1.0.1
* Edited documentation a bit.

### v1.0.0
* Initial release.