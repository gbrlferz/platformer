package game

import rl "vendor:raylib"

MOVE_SPEED :: 3.0
JUMP_FORCE :: -5.5

is_on_ground :: proc(player: ^Entity, world: ^World) -> bool {
	test_pos := player.position
	test_pos.y += 1 // Check one pixel below
	return check_collision(player, world, test_pos)
}

update_player :: proc(player: ^Entity, world: ^World, delta: f32) {
	player.velocity.y += GRAVITY

	// Player input
	if rl.IsKeyDown(.LEFT) {
		player.velocity.x = -MOVE_SPEED
		player.facing_right = false
	} else if rl.IsKeyDown(.RIGHT) {
		player.velocity.x = MOVE_SPEED
		player.facing_right = true
	} else {
		player.velocity.x = 0
	}

	if rl.IsKeyPressed(.SPACE) && is_on_ground(player, world) {
		player.velocity.y = JUMP_FORCE
	}

	move_x(player, player.velocity.x, world)
	move_y(player, world, player.velocity.y)
}

draw_player :: proc(player: ^Entity, texture: rl.Texture) {
	player_source := rl.Rectangle{0, 0, f32(texture.width), f32(texture.height)}
	player_dest := rl.Rectangle {
		f32(player.position.x),
		f32(player.position.y),
		f32(player.size.x),
		f32(player.size.y),
	}

	// Flip sprite horizontally if facing left
	if !player.facing_right {
		player_source.width = -player_source.width
	}

	rl.DrawTexturePro(texture, player_source, player_dest, {0, 0}, 0, rl.WHITE)
}
