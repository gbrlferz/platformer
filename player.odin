package game

import rl "vendor:raylib"

MOVE_SPEED :: 3.0
JUMP_FORCE :: -5.5

update_player :: proc(player: ^Entity, world: ^World, delta: f32) {
	player.velocity.y += GRAVITY

	// Player input
	if rl.IsKeyDown(.LEFT) {
		player.velocity.x = -MOVE_SPEED
	} else if rl.IsKeyDown(.RIGHT) {
		player.velocity.x = MOVE_SPEED
	} else {
		player.velocity.x = 0
	}

	if rl.IsKeyPressed(.SPACE) {
		player.velocity.y = JUMP_FORCE
	}

	move_x(player, world, player.velocity.x) // Added world reference
	move_y(player, world, player.velocity.y) // Added world reference
}
