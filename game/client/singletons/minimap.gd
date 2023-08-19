extends Node
var _random_value : int = 0

# when this value is false, this var is used to set random values. 

# At both main map and minimap, there are local copies of this var. then a local copy has a value of false, the main map instance is running the code. at that time, this var is set to false so that some kind of random value can be created abd that var used.
var _at_minimap : bool = false


# then this value is true, this var is used to set a value to the minimap _at_minimap var.
var _main_map_init : bool = false


func _ready():
	_random_value = randi_range(1, 2)
	

func _random_create():
	if _at_minimap == false:
		_random_value = randi_range(1, 2)
