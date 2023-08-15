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
	text = "Game Art.\n[color=#bbbbff][url=_link]dungeon crawl stone soup[/url][/color]. Originally programmed by Linley Henzell.\nSome art from [color=#bbbbff][url=_link2]kenney[/url][/color]."
	
	connect("meta_clicked", Callable(self, "call"))

func _link():
	OS.shell_open("https://crawl.develz.org/") 

func _link2():
	OS.shell_open("https://www.kenney.nl/") 

