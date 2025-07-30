package game

import "core:math"
import rl "vendor:raylib"

move_x :: proc(entity: ^Entity, world: ^World, amount: f32) {
	entity.x_remainder += amount
	move := i32(round(entity.x_remainder))

	if move != 0 {
		entity.x_remainder -= f32(move)
		sign := i32(math.sign(f32(move)))

		for move != 0 {
			test_pos := entity.position
			test_pos.x += f32(sign)

			if !check_collision(entity, world, test_pos) {
				entity.position.x += f32(sign)
				move -= sign
			} else {
				// Collision callback?
				break
			}
		}
	}
}

move_y :: proc(entity: ^Entity, world: ^World, amount: f32) {
	entity.y_remainder += amount
	move := i32(round(entity.y_remainder))

	if move != 0 {
		entity.y_remainder -= f32(move)
		sign := i32(math.sign(f32(move)))

		for move != 0 {
			test_pos := entity.position
			test_pos.y += f32(sign)

			if !check_collision(entity, world, test_pos) {
				entity.position.y += f32(sign)
				move -= sign
			} else {
				entity.velocity.y = 0
				break
			}
		}
	}
}

check_collision :: proc(entity: ^Entity, world: ^World, pos: rl.Vector2) -> bool {
	test_box := rl.Rectangle{pos.x, pos.y, entity.size.x, entity.size.y}

	for y in 0 ..< world.tilemap.height {
		for x in 0 ..< world.tilemap.width {
			idx := y * world.tilemap.width + x
			if world.tilemap.tiles[idx] == .SOLID {

				tile_rect := rl.Rectangle {
					f32(x * TILE_SIZE),
					f32(y * TILE_SIZE),
					TILE_SIZE,
					TILE_SIZE,
				}

				if rl.CheckCollisionRecs(test_box, tile_rect) {
					return true
				}
			}
		}
	}

	return false
}
