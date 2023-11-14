# Home page.

Procedurally generated dungeons with a game construction kit. Game inspired by Lufia 2 and legacy of the ancients.

This game is programmed in Godot 4.2 dev1. This game is currently a work in progress.

# [Screenshots](screenshots.md) | [Project Programming](project-programming.md) | [Legal Summary](legal-summary.md)

Join the Super RPG Retro [discord server](https://discord.gg/b8damxvwX8). Get the [source code](https://github.com/Super-RPG-Retro/Super-RPG-Retro), and fork or contribute.

![This image shows a small playable map so that more of the client features are shown.](./images/game_world_small_map.png)
<br/><br/>
This image shows a small playable map so that more of the client features are shown.
<br/><br/><br/><br/>

![This 3D maze is called the library. The player can enter any dungeon from the library.](./images/library_scene.png)
<br/><br/>
This 3D maze is called the library. The player can enter any dungeon from the library.
<br/><br/><br/><br/>

### Summary.

* In-game construction kit, called builder.
* Hundreds of customizable features.
* Every game can have a different "difficulty level" value.
* Client panel has in-game chat and help commands.
* 61 magic. 999 maximum runes can be stacked for any magic item.
* 460 items can be used in inventory. You can add to this list.
* 678 mobs. You can add to this list.
* 99 levels in every dungeon.
* 1 to 8 dungeons.
* 10 player statistics such as str, def and luc.
* 999 is the maximum value of a statistic.
* 999 is the maximum level a player can have.
* 9999 is the maximum value for both HP and MP.
* Dungeon can be procedurally generated by using a seed.
* Set the game to use the same seed. 1000000000 available seeds.
* Enable music globally.
* Enable sound globally.
* Enable wind and water drop sounds.
* Toggle size of the player stats panel.
* Show more of the main map by showing less of the client panel.
* Customize the client panel.
* Show guide images on the map where a rune can be casted.
* Cast the rune at the main map or have instant rune casting.
* Show the dungeon corridor stone walls?
* Try to show only the stone walls that parameter the corridor?
* Remove every one tile wide stone tile that borders the level.
* Higher values can increase the corridor distance between rooms.
* Trigger events based on time. Dungeons can get dark at night.
* Game difficulty. 1: Easy. 5: Extremely difficult.
* On: Mobs chase when they see you: Off: Chase anytime.
* A black map hiding unexplored dungeon areas.
* Mobs are seen in the room when the room door is closed?
* Items are seen in the room when the room door is closed?
* Mobs are dead when they are this many units from their starting position.
* mobs will respawn after these many game turn elapses.
* mobs can run out of the room or stay in the room.
* A black ceiling can be placed overtop of a dungeon room.
* Can use different floor tiles.
* Instant battle or turn based battle system.
* Can show the down ladder when the room ceiling is enabled.
* Option for the player to return to the last level of a dungeon.
* Option to continue a saved game.

# About.

You can configure the game system, game settings, or use the game construction kit called builder. Every feature at game settings will change the difficulty score.

The program has many things fo configure, such as, each dungeon level could have a puzzle room. There are six mob movement type that can be assigned to a mob, such as, avoid player and trace walls. Mobs could be configured to stay in room or follow the player. A room ceiling could be enabled. A random corridor could be hidden. 

The idea is to make a large, challenging game loaded full of events, such as, chat dialogs, many different puzzles, and mob tasks. 

Currently, only two dungeon levels work after game installation. Those levels are used to test game features.

Game play can be configured to look exactly the same every time you play it or the game play can have randomness added to it. You can change the size of the rooms in each dungeon level.

After upgrading the game from Godot 3.2 to 4.2 dev1, some game features do not work as intended. Some features no longer work. Some features such as chat were disabled. After upgrading the game, chat now needs to be rewritten. Minimap is not completely working. An error was discovered in minimap while upgrading to Godot 4.2 dev1 and now that minimap feature needs to be rewritten.

The core of this game came from this video, building a Roguelike from Scratch in Godot, [Dungeon of Recycling](https://www.youtube.com/watch?v=vQ1UGbUlzH4). Most images, such as, mobs and magic, and the game UI design idea, came from [Dungeon Crawl Stone Soup.](https://crawl.develz.org/)

The game has a fair amount of spaghetti code. Some code jumps from scene to scene. Some code blocks are redundant. The code will now be organized using the [DRY, KISS and SOLID principles.](https://godottutorials.com/courses/design-principles/) See also [project Programming](project-programming.md) for more information.