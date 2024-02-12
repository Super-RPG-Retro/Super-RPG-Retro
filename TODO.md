# Things to do.

Text will have an "X" beside it when task is completed.

# [Screenshots](screenshots.md) | [Project Programming](project-programming.md) | [Legal Summary](legal-summary.md)

## Source code.

- [] Update Builder images

Remove any white space padding from all magic image files. Images must be in the same image dimension that the Builder item images are in.

- [] Use one theme

Make all seem only use one scene file, named "1". That default theme will use different shades of blue. Next, make theme "2", using shades of a different color. Next, make an option here at Setting System to change themes.

- [] Show Side Panel

Create a side panel container as the parent of side panel nodes, such as, mini map and stats panel, so that all side panel container children nodes can be easily hidden. Next, when the side panel container is hidden, resize the width of the main map viewport and the client panel, such as, LineEdit and RichEdit nodes to fill the available client application space. Next, create a setting at Settings Game to show/hide the side panel container for both the 2D scene and 3D scene.

- [] Room Ceilings

Instead of using the tile map for room ceilings, use sprite nodes. Resize each 32x32 black Sprite to the width and height of the room minus 64 pixels in size then position sprite at 32x32 pixels bottom-right side of top-left corner of room. You might need to change the sprite's Zorder to show ladder above ceiling.

- [] Put enemy pathfinder into own class.

- [] Rewrite client chat and server chat files.

- [] Redo mini map feature.

- [] Exit button not working at main menu in android.

- [] Remove all scene jumps everywhere.

- [] Make trigger singleton.

- [] Put all game sounds into Singleton saves file.

- [] Put all game signals into signalton signals file.

- [] Add infer data type to every function perimeter.

- [] In all code, directories and file names, replace the word title with the word main menu then replace the word boot_splash with the word title.

- [] More things at the title scene should use the progress bar class.

- [] Life cycle functions will be organized from top to bottom, mirroring the order they are first called.

- _init()
- _enter tree()
- _ready()
- _input()
- _physics_process()
- _process()
- _exit_tree()

- [] Rename words method and methods to words function and functions at both software and website.

- [] Make an input class for all input types.

- [] Add class names to all sub game_UI files.

- [] At FileSystem.gd:
* Unsafe: var2string - string2var
* Safe: var2bytes - bytes2var

- [] Move each spell into its own class.

- [] the control node should only be used as the parent of ui nodes.

- [] create a folder named data_type at singleton folder then remove the leading "_" from all Super RPG Retro made variable and functions, moving them to data_type sub folder of strings, integers, floats, boolean, nulls, enums and dictionaries.

- [] do dry principle.

- [] do kiss principle.

- [] do solid principle.

- [] game needs better enemy graphics.

- [] fix spaghetti code.

- [] make documentation comments in all class files.

## JSON.

- [] Rename json.d variable to something more readable.

- [] Is json.d variable saved and loaded at title scene?

- [] Remove dictionary key named "field" inside JSON magic files at bundles/builder/magic folder.

- [] Inside all JSON magic files at bundles/builder/magic folder, the dictionary value of the key "turns" should be greater than 1 for field spells and a value of 1 for everything else.

- [] Rename the word element "ice" to element "water" inside all JSON magic files at bundles/builder/magic folder and at JSON.gd singleton.

- [] The dictionary value of key "group" should be named "support" for JSON magic file named "mud" at bundles/builder/magic folder.

- [] Every magic spell must use one of the four elements of air, earth, fire and water. Do not use the word "none".

- Do the following in order...

   - [] Rename bundles/builder/objects... "enemy" subfolders to NPCs_used. Rename enemy1 subfolders to NPCs_unused1. Rename enemy2 subfolders to NPCs_unused2.

   - [] Rename all words enemy and enemies to words NPC and NPCs at both software and website. 

   - [] Everywhere rename bundles/builder/objects to bundles/builder/items. Next move the NPCs folder out of bundles/builder/items putting them into bundles/builder/NPCs then at FileSystem.gd function that D variable at json.gd Singleton calls, make sure the NPCs files are also loaded into the file name variable.

   - [] Everywhere rename res://bundles/builder/items/data/ to res://bundles/builder/items/encrypted/data/ and rename res://bundles/builder/items/images/ to res://bundles/builder/items/encrypted/images/.

- [] Everywhere rename file "file-names" to "file_names".

- [] Everywhere rename At_dungeon_from and At_dungeon_to to Seen at_dungeon. Also, everywhere rename At_level_from and At_level_to to Seen_at_dungeon_level. Next, create a LineEdit node that restricts text input to only allow commas and 0-9 characters for these renamed JSON fields.

## Builder.

- [] Hidden tiles

At level menu, make a setting to hide every tile for a level. Only NPCs and dropped items are displayed on map.

- [] Level menu floor tiles

Static floor tile to use? Use a ItemList node here.

Use a random floor tile? Use a CheckButton node here.

Floor color to use? Use a ItemList note here.

Enable or disable the following option will do the reverse for the above floor options.

Special tile to use? Use an ItemList node here.

Example: from tile menu at builder...

* Water

   Select an item needed for player to use water.

Grayscale the "dungeon crawl Stone soup" floor tiles then set them to the RGB mode.

Room tile menu should have same settings as floor tile menu, excluding the special tile setting. Make an option for a different colored tile used for the walls of every room.

- [] If builder_magic.txt or builder_dictionaries.txt do not exist then recreate them if the corresponding folder at Bundles/Builder exists.

- [] At Builder story event, make a RichEdit node with word wrap disabled. Separate each RichEdit line using the enter key. At the beginning of each line must be "/l####". It's an image command. "/i0000" means no image to display in the dialog box when playing the game. "/i0001" is the first image in the image list. That image list must also be displayed at this story event.

- [] Excluding the next event scene and its script files, rename event_number to parent_container and event_enabled to is_enabled then make dungeon_number, level_number, is_enabled and child_container children of parent_container. Make all other settings as child of child_container.

- [] Verify that all events, including next event, do not have the unneeded variables dungeon_number and level_number.

- [] Create a goto_parent_container variable at the child_container at every scene where the next event exists. At the scene where an event at the next event is selected, when playing the game, this variable will be used to display that selected event.

- [] Excluding the event at builder_level.gd, add non-solid Furniture items randomly beside wall units only.

- [] Do not make ladders solid at build_level.gd.

- [] For builder, do @export_category(" ")

- [] Add export variables to all Builder non-Singleton files then select those exported variables at the node panel, assigning the nodes to them.

- [] Complete this dungeon level in how many turns?

- [] Every dungeon level should have an option to use a static seed at the level menu.

## Play.

- [] Player movement

Player should move to the selected target after user clicks on the main map. However, player must break out of movement when NPC demands action.

- [] Grid containers

Put the magic scene and inventory scene each into a grid container.

- [] z key

The "z" key should be used to access a ladder when player is standing on it.

- [] Open close doors

Just in case the main map is large and the client panel hidden, make a pop-up, similar to the Fantasy Star 1 game. Pressing the "x" button on the keyboard should pop up the action menu with the selectable menu items name of stats, magic, items, search and save showing.

- [] Put player movement in function _unhandled_input.

- [] Put all UI nodes into function _gui_input.

- [] Move day/night time variable into _physics_process then use delta time on that variable.

- [] improve the code at inventory scene.

- [] improve the code at magic scene.

- [] improve the battle system.

## Settings System.

- [] Language setting

This is an example code for a language preference setting.

1. Create "language" folder inside of game/client folder.

2. Example code for english.gd. at language folder.

```
Class name LanguageEnglish

var data := [ "word", "List" ]
```

3. Create a language singleton. Example code for language.gd.

```
# this is a data array from a language file.
var data = null

# a language file.
var english = LanguageEnglish.new()

Func ready():
   match language_value:
      1:
         data = english.data
```

- [] Border decoration

Create a border decoration setting to be shown at the Play game_ui scene. Resize the application window by 32x32 pixels. Put the game_ui scene in a margin container with a 16x16 pixel padding. Image should display a hollow square box with the border decoration 16 pixels wide and named 2.jpg. The first image, the default image, should be transparent.

- [] Volume

Need settings to adjust the volume levels for the music, sound and ambient .ogg files.

No TODOs here yet.

## Settings Game.

- [] Should events be used if enabled at builder?

- [] Limit the amount of saves made in a game?

- [] Enable respawnable enemies ingame if enabled at Builder?

- [] Enable dungeon level secrets? This must be enabled for a hidden corridor to work.

- [] The amount of player turns needed for system to remove items on a dungeon level tile?

- [] When assigning difficulty level values for settings game, only use numbers 1 2 4 8 and 16. The value 1 is a setting that has little impact of increased gameplay difficulty. Total the difficulty values the settings game use then make a secret word for every value from 1 to that total.

page updated at Feb 11 2024