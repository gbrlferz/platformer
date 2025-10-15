package mushrun

import rl "vendor:raylib"

World :: struct {
	collision_map: []u8,
	width:         int,
	height:        int,
}

Tile :: struct {
	src:    rl.Vector2,
	dest:   rl.Vector2,
	flip_x: bool,
	flip_y: bool,
}
