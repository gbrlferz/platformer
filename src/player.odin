package platformer

import "core:math"
import rl "vendor:raylib"

PLAYER_MAX_SPEED :: 3.0
PLAYER_ACCELERATION :: 50
PLAYER_JUMP_FORCE :: -5.0
PLAYER_FRICTION :: 0.7
PLAYER_COYOTE_TIME :: 0.1

Player :: struct {
	using entity:      Entity,
	sprite:            rl.Texture2D,
	state:             PlayerState,
	last_state:        PlayerState,
	frame_counter:     f32,
	frame:             int,
	facing:            f32,
	coyote_timer:      f32,
	jump_buffer_timer: f32,
}

PlayerState :: enum {
	IDLE,
	RUN,
	JUMP,
	FALL,
}

init_player :: proc() -> Player {
	return Player {
		size = {12, 18},
		sprite = rl.LoadTexture("../assets/tilemap-characters.png"),
		facing = 1,
		active = true,
	}
}

update_player :: proc(using game_state: ^GameState, dt: f32) {
	grounded := is_on_ground(&player, &world)

	if !grounded {
		player.velocity.y += GRAVITY * dt
		player.coyote_timer -= dt
	} else {
		player.coyote_timer = PLAYER_COYOTE_TIME
	}

	if rl.IsKeyDown(.LEFT) {
		player.velocity.x -= PLAYER_ACCELERATION * dt
		player.facing = -1
	} else if rl.IsKeyDown(.RIGHT) {
		player.velocity.x += PLAYER_ACCELERATION * dt
		player.facing = 1
	} else {
		player.velocity.x *= PLAYER_FRICTION
		if math.abs(player.velocity.x) < 0.1 {
			player.velocity.x = 0
		}
	}

	player.velocity.x = math.clamp(player.velocity.x, -PLAYER_MAX_SPEED, PLAYER_MAX_SPEED)
	player.jump_buffer_timer = math.max(player.jump_buffer_timer - dt, 0)

	if rl.IsKeyPressed(.Z) {
		player.jump_buffer_timer = 0.1
	}

	if player.jump_buffer_timer > 0 && (grounded || player.coyote_timer > 0) {
		player.velocity.y = PLAYER_JUMP_FORCE
		player.coyote_timer = 0
		player.jump_buffer_timer = 0
		rl.PlaySound(jump_sound)
	}

	player_rising := !grounded && player.velocity.y < 0
	if rl.IsKeyReleased(.Z) && player_rising {
		player.velocity.y = 1.0
	}

	tile_hit_x := move_x(&player, player.velocity.x, &world)
	tile_hit_y := move_y(&player, &world, player.velocity.y)

	if tile_hit_y == HAZARD_ID {
		player.active = false
	}

	if !grounded {
		if player.velocity.y < 0 {
			player.state = .JUMP
		} else {
			player.state = .FALL
		}
	} else {
		if math.abs(player.velocity.x) > 0 && grounded {
			player.state = .RUN
		} else {
			player.state = .IDLE
		}
	}

	if player.state != player.last_state {
		player.frame = 0
		player.last_state = player.state
	}

	for &entity in entities {
		if !entity.active {continue}
		if rl.CheckCollisionRecs(get_rect(player), get_rect(entity)) {
			entity.active = false
			rl.PlaySound(coin_sound)
			score += 1
		}
	}
}

draw_player :: proc(using player: ^Player, animations: map[PlayerState][]rl.Rectangle) {
	source_rect := animations[state][frame]

	if facing == 1 {
		source_rect.width *= -1
	}

	offset_x := -size.x / 2
	offset_y := size.y - int(source_rect.height)

	dest_rect := rl.Rectangle {
		f32(position.x + offset_x),
		f32(position.y + offset_y),
		abs(source_rect.width),
		abs(source_rect.height),
	}

	rl.DrawTexturePro(sprite, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)

	// DEBUG
	// rl.DrawRectangleRec(get_rect(player), {255, 0, 0, 180})
}
