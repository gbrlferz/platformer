package game

import "core:math"
import rl "vendor:raylib"

move_x :: proc(using entity: ^Entity, amount: f32, world: ^Level) {
	remainder.x += amount
	move := i32(remainder.x)

	if move != 0 {
		remainder.x -= f32(move)
		sign := i32(math.sign(f32(move)))

		for move != 0 {
			test_pos := position
			test_pos.x += sign

			if !check_collision(entity, world, test_pos) {
				entity.position.x += sign
				move -= sign
			} else {
				break
			}
		}
	}
}

move_y :: proc(using entity: ^Entity, world: ^Level, amount: f32) {
	remainder.y += amount
	move := i32(remainder.y)

	if move != 0 {
		remainder.y -= f32(move)
		sign := i32(math.sign(f32(move)))

		for move != 0 {
			test_pos := position
			test_pos.y += sign

			if !check_collision(entity, world, test_pos) {
				entity.position.y += sign
				move -= sign
			} else {
				break
			}
		}
	}
}

check_collision :: proc(entity: ^Entity, world: ^Level, pos: [2]i32) -> bool {
	test_box := rl.Rectangle{f32(pos.x), f32(pos.y), f32(entity.size.x), f32(entity.size.y)}


	for solid in world.solids {
		// tile_rect := rl.Rectangle{f32(x * TILE_SIZE), f32(y * TILE_SIZE), TILE_SIZE, TILE_SIZE}
		tile_rect := rl.Rectangle {
			f32(solid.position.x),
			f32(solid.position.y),
			f32(solid.size.x),
			f32(solid.size.y),
		}

		if rl.CheckCollisionRecs(test_box, tile_rect) {
			return true
		}
	}

	// for y in 0 ..< world.tilemap.height {
	// 	for x in 0 ..< world.tilemap.width {
	// 		idx := y * world.tilemap.width + x
	// 		if world.tilemap.tiles[idx] == .SOLID {
	//
	// 			tile_rect := rl.Rectangle {
	// 				f32(x * TILE_SIZE),
	// 				f32(y * TILE_SIZE),
	// 				TILE_SIZE,
	// 				TILE_SIZE,
	// 			}
	//
	// 			if rl.CheckCollisionRecs(test_box, tile_rect) {
	// 				return true
	// 			}
	// 		}
	// 	}
	// }

	return false
}
