"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

# enum and anything related to enum are here.
extends Node

# you can refer to these tiles by name to get a TILE INDEX, not tile x and y values.
enum Tile {Wall, Door, Floor, Ladder_down, Ladder_up, Stone, Floor_rooms, Ceiling}
var _tile_name = ["Wall", "Door", "Floor", "Ladder_down", "Ladder_up", "Stone", "Floor_rooms", "Ceiling"]

enum Tile_Overlay {Ceiling}

# used when selecting either a magic rune or inventory item.
enum ALPHABET {a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z}

enum Select_items {Event_prize, Event_hunting_tasks, Event_inventory, Event_story}

# the movement type of an object, such as mobs. for example, does to mobs move towards player, move opposite of player, etc.
enum Movement_type {Target_player, Stationary, Avoid_player, Run_away_from_player, Random_movement, Trace_walls}

# at builder "dictionary new" if selecting new weapon at the builder dictionary menu, this weapon enum will be set to a var.
enum Builder_dictionary {mobs, mobs1, mobs2, weapon, armor, book, gold, scroll, ring, food, wand, amulet}

# each scene uses one of these values as a scene id, to determine where player is at.
enum Scene {Main_Menu, High_scores, Settings_system, Settings_game, Builder, Game_UI, Game_help, Rune_buying}

# client commands, using the "/" key at input_client.
enum Trigger_commands {Nothing, Debug, Host_connect_disconnect, Game_help, Wait_a_turn, Client_panel_toggle_size, Unit_description}

# when someone drops an item, this enum is used to selected an item from the available list. see random drop item at reference constructor at game.scene
enum selected {Paper, Potion}

enum Puzzle_sounds {Puzzle_block_move, Puzzle_failed, Puzzle_success}

enum Mobs_movement_type {Target_player, Stationary, Opposite_direction_of_player, Run_away_from_player, Random_movement, Trace_walls}
