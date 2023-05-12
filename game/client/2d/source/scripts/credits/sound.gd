"""                                 
Copyright (C) 2022-2023 Kal. M. G.

This program is part of Super RPG Retro.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

extends RichTextLabel


func _ready() -> void:
	bbcode_enabled = true
	bbcode_text = "sounds.\n[color=#bbbbff][url=_link]210 sound effects pack[/url][/color] by phoenix1291, [color=#bbbbff][url=_link2]Ultimate 2017 16 bit Mini pack[/url][/color]\nby rubberduck. RPG sound pack from [color=#bbbbff][url=_link3]artisticdude[/url][/color]."
	
	connect("meta_clicked", self, "call")

func _link():
	var _s = OS.shell_open("https://opengameart.org/content/sfx-the-ultimate-2017-16-bit-mini-pack/") 
	

func _link2():
	OS.shell_open("https://opengameart.org/content/100-cc0-sfx/")


func _link3():
	OS.shell_open("https://opengameart.org/content/rpg-sound-pack/")
