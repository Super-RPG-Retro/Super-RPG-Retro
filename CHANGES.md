v1.2.0 - Nov 14 2023

* For mobile game play, the navigation panel was added to settings system.
* Navigation panel and client panel can both be hidden.
* At world viewport, the unit summary now works with the mobile drag event.
* Player stats were not saved because a call to change scene at builder was made before deferral call to save variable.
* Drag event did not work for settings game scene.
* At settings system the option called hide_stone_walls was renamed to show_stone_walls.
* At settings system the option called hide_chat_features was renamed to show_chat_features.
* At settings system the option called use_large_tiles was removed from code.
* Reorganized and/or renamed most scene, source and singleton files and folders.
* && / || renamed to and / or.
* removed _child_scene_open variable from game.
* game_ui child scenes removed from preload.gd then added to game_ui scene as nodes.
* added furniture and tilemap images to bundles/assets folder.

v1.1.0 - Aug 19 2023

* At the main menu the username can no longer be edited when the game is loaded.
* The username filename was used to hold both spinbox loaded id value and saved id value. two bugs were fixed. 1: deleting a game could stop a game from loading. 2: sometimes a game could not be deleted.
* Incorrect data displayed at statistics panel.