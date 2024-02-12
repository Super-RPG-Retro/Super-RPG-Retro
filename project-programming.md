---
title: Project Programming.
description: This page explains how Super RPG Retro is constructed and gives tips and advice that may improve one's programming skills.
---

# Project Programming.

This page explains how Super RPG Retro is constructed and gives tips and advice that may improve one's programming skills.

# [Screenshots](screenshots.md) | [Project Programming](project-programming.md) | [Legal Summary](legal-summary.md)

Join the Super RPG Retro [discord server](https://discord.gg/b8damxvwX8). Get the [source code](https://github.com/Super-RPG-Retro/Super-RPG-Retro), and fork or contribute.

## Notes.
If the game crashes, search for the word TODO in the .gd files and then read those comments.

Turning off the Vsync option might speed up the execution of code at the _process function.

Remember to import all sound files with the loop option unchecked.

Have no more than 200 lines of code in a class.

Have no more than one page of text for a function.

HTML5 needs a mouse click on screen before the main menu music plays. it is a browser security issue that will not change.

When importing a 3d gridmap, enable detect 3d filter and mipmaps. 3d blocks that you use to draw on the map are stored in the gridmap.tscn file.

## Source code.

### Assert

assert (Var := #)

* The game will stop if this code evaluates to false.

* The assert keyword only works in the debug mode.

### Loop Statement Tips.

```gd
for "/" in string:
for _i in array:
for name in dictionary:
```

### Optimism Code.

A good practice to increase the performance of your code:

```gd
var data := []
```

Notice the variable is inferred. Do not use this.

```gd
var data :array = []
```

You might notice that large arrays will take 2 time longer to process in godot 4.2 dev 1 when using a data type.

### Filters.

Sound loops? select the ogg file at the godot filesystem tab, then click the import tab. Remove the loop option, then press the re-import button.

### Print statement.

When printing something to console, remember to add a hint to your code so you know where the print statement is located.

### Projects File paths.

> #### From Godot documentations.
>
> Godot considers that a project exists in any folder that contains a project.godot text file, even if the file is empty. The folder that contains this file is your project's root folder.
>
> You can access any file relative to it by writing paths starting with res://, which stands for resources.
>
> To store persistent data files, like the player's save or settings, you want to use user:// instead of res:// as your path's prefix. This is because when the game is running, the project's file system will likely be read-only.
>
> The location of the user://folder depends on what is configured in the Project Settings:

user:// = /Users/your_name/AppData/Roaming/Godot/app_userdata/Super RPG Retro client/

res:// = /Super-RPG-Retro-main/game/client/

### Windows Installation.

#### Directories.

Builder system files are files that can be edited. Those files are copied and then saved in binary format at the title scene. The system files are used for the admin to create features, while the binary files are for in-game playing.

The first time running the game, the saved_data directory at user://saved_data/ is created. That directory has all the user's saved game configurations in it.

The system directory at res://bundles/builder/ is where you can add more items. The custom.json file at that folder should not be removed as it is used within the game. After adding another json feature from within a json file, do a search and replace, inserting that feature to the remaining json files.

When the game loads, at the title scene, the game will look for the builder_magic_#.txt and builder_dictionaires_#.txt files at user://saved_data/. where # is a game id value. Those files hold all the .json data from all file data at res://bundles/builder/. If that builder_dictionaires.txt file does not exist then at res://bundles/builder/objects/system/, all files within the images and data directories will be copied then saved in binary format to the following directories...

When you run the game, at the title scene, a check will be made at the user://saved_data/ for configuration files. if no configuration files are found, then the game will copy files from...

res://bundles/builder/objects/system/images to res://bundles/builder/objects/images/#

res://bundles/builder/objects/system/data to res://bundles/builder/objects/data/#

res://bundles/builder/magic/system/data to res://bundles/builder/magic/data/#

Therefore, after you clone the game or unzip it to your game directory, verify that no game_id directories exist in these directories...

res://bundles/builder/objects/images/

res://bundles/builder/objects/data/

res://bundles/builder/magic/data/

Failing to delete the above subdirectories will crash the game because no configuration files exist at user://saved_data/, and no files will be created at user://saved_data/ because the game_id folders exist. This manual deletion of files will soon be an automatic feature.

### Virtual Functions.

#### _process

This function updates at the fastest possible rate. This function is not reliable because it prefers speed over consistency.

#### _physical_process

Frames are updated at a consistent rate . Use control nodes and game logic here. Synced to the physics.

#### _init

_init is the class constructor. It can have parameters if the new function is used. It cannot have perimeters if the instance is used because the script will not load for the instance of the class.

### SOLID Design Principle.
---
This is an easy to understand version of the solid design principle. This may not be 100% accurate.

   - #### Single Responsibility.
      A class should only have one responsibility.

   - #### Open/Close.
      Child classes, modules and functions should allow for modification without changing something from its parent.

   - #### Liskov Substitution.
      A function from a subclass must have the same type as a function from a base class. A child function must be 100% compatible with its parent function.

   - #### Interface Segregation.
      Programmers should not be forced to depend upon classes/functions they do not use. A class should use every function from its inherited class.

   - #### Dependency Inversion.
      High level classes should not depend on low level classes. A class should not care what is inside a function of another class.

## JSON.
---
### Magic.

   - #### Strength.

      This value is added to the players current str. That new value is the casted str of the magic.

   - #### Defense

      This value is added to the players current def. That new value is the casted def of the magic.

   - #### Dice

      The bonus dice roll is added to both magic str and magic def values. Example; 1D10 = 1 dice with 10 sides.

   - #### Abbreviation

      This is used at room commands to buy magic, cast magic or get help for magic.

   - #### Elements

      Air, Earth, Fire and Water.

   - #### Turns

      1 to 20. Magic works for this amount of player turns.

   - #### Range

      Magic will occupy 0-5 units from the player's position.

   - #### Location

      - ##### Caster

         Magic is casted only on the caster.

      - ##### Grid

         Magic is casted on all units that surround the caster.

      - ##### Cardinal

         Magic is casted on all units that are in straight lines from the caster.

      - ##### Ordinal

         Magic is casted on all units that are in angles from the caster.

   - #### Animation

      This value refers to the Sprite file the magic users.

   - #### Group

      The group of self, support and attack are used to organize magic for display purposes only.

   - #### Gold

      The amount of gold needed to purchase one of these magic spells.

   - #### Level

      The player's experience level needed to cast a spell.

   - #### MP

      The magic points needed to cast a spell.

   - #### Description

      Informative text explaining what the magic does.

   - #### Units

      Every unit the magic occupies when casted.

### Things

   - #### Spell poison

      Hit Points slowly drain and attacks weaken. 

   - #### Spell slow

      Increases the time between attacks.

   - #### Spell sleep

      Exempt from acting and defense severely drops. 

   - #### Spell chaos

      The character attacks an ally or enemy at random. Their accuracy is also reduced. 

   - #### Spell blind

      Lowers hit rate of all actions. 

   - #### Spell lock

      Unable to use techniques. 

   - #### Spell stop

      Unable to act.

   - #### Seen at dungeon

      A comma separated numerical list of dungeons that this thing will exist at.

   - #### Seen at dungeon level

      A comma separated numerical list of dungeon levels that this thing will exist at.

   - #### Movement type

      How does this thing move around the room?

   - #### Charisma

      Presence, Charm, Social.

   - #### Class

      Currently not used.

   - #### Constitution

      Stamina, Endurance, Vitality, Recovery.

   - #### Defense

      Resistance, Fortitude, Resilience.

   - #### Description

      Write a brief description for this thing.

   - #### Dexterity

      Agility, Reflexes, Quickness.

   - #### Enabled

      Does this thing exist in the game?

   - #### Task amount

      The value needed before a task can be completed?

   - #### Task gold

      The gold received after completing the task.

   - #### HP

      The current player's hit point health value.

   - #### HP Max

      The player's maximum hit point value.

   - #### Intelligent

      Intellect, Mind, Knowledge.

   - #### Luck

      Fate, Chance.

   - #### MP

      The current player's mana point, magic casting, value.

   - #### MP Max

      The player's maximum mana point value.

   - #### Perception

      Alertness, Awareness, Cautiousness.

   - #### Strength

      Body, Might, Brawn, Power.

   - #### Willpower

      Sanity, Personality, Ego, Resolve.

   - #### Wisdom

      Spirit, Wits, Psyche, Sense.

   - #### HP given

      The experience points given to player after this thing is defeated.

   - #### Purchase price

      How much does this thing cost in store. 0 equals not listed in store.

   - #### Selling price

      How much can you sell this thing in store. 0 equals not for sale.

   - #### Drop gold

      How much gold does this thing give once defeated.

   - #### Is artifact

      Is this an artifact with special powers?

   - #### Healing power

      How much does 1 potion heal this thing for? In magnitudes of 10. A value of 10 = 100%

   - #### Healing potions

      How many healing potions does this thing have?

   - #### Equiptable

      Can a player equip this thing?

   - #### Stack amount

      The maximum amount of this thing a player can have?

## Builder.

All dungeon levels are procedurally generated. However, dungeon levels will have the same layout if their room size and room number amount match.

At builder, most configuration files are saved using a game id as part of that filename. game_id can have a value of 1 to 8. You can have 8 different games to play. Currently, only the first game id is used.

Everytime you add another magic item or feature to a .json file at res://bundles/builder/objects/system/ folder, until a better practice is implemented, you will need to delete all files of that id number from the user://saved_data/ and at res://bundles/builder/ the directory with that id number so that the correct data can be created at title scene.

## Play.

### Potion Scene

Everywhere replace all potion data with the following then delete any old unused potion data then merge the new potion data scene and script into the HUD scene and script.

   - #### NPC remaining

      * +1 at spawn
      * -1 at destroy

   - #### Secret remaining
      * +1  for a hidden corridor.
      * -1  for a secret tile.

   - #### Turns remaining
      Turns remaining refers to the total moves required to get to the next down ladder. Turns will be set to "n/a" when going up ladder or when option is disabled for level.

   - #### Item remaining
      * +1 for each NPC item dropped.
      * -1 for each item collected.

   - #### Event remaining
      * +1 for locked door.
      * -1 for puzzle room, etc.

### How Enemies respawns

Enemies will never respawn if the player is outside of the room. Enemies will only respawn when the player is in that room, and only after so many game turns have passed. You can set the game turns variable at Settings._game.respawn_turn_elapses. Enemies will disappear if they are too far from their starting position.

## Settings System

page updated at Feb 11 2024