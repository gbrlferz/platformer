package game

import rl "vendor:raylib"

Entity :: struct {
	position:     [2]i32,
	size:         [2]i32,
	remainder:    [2]f32,
	velocity:     rl.Vector2,
	facing_right: bool,
}

Solid :: struct {
	position: [2]i32,
	size:     [2]i32,
}

GameScreen :: enum {
	TITLE,
	GAME,
	EDITING,
}

Editor :: struct {
	active: bool,
}

Level :: struct {
	player:        ^Entity,
	entities:      [dynamic]Entity,
	solids:        [dynamic]Solid,
	solid_texture: rl.Texture2D,
}
