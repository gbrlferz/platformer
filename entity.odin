package mushrun

import "core:math"
import rl "vendor:raylib"

EMPTY_ID :: 0
SOLID_ID :: 1
HAZARD_ID :: 2

Entity :: struct {
	position:  [2]int,
	size:      [2]int,
	remainder: [2]f32,
	velocity:  [2]f32,
	active:    bool,
}

move_x :: proc(using entity: ^Entity, amount: f32, world: ^World) -> int {
	remainder.x += amount
	move := int(remainder.x)

	if move != 0 {
		remainder.x -= f32(move)
		sign := int(math.sign(f32(move)))

		for move != 0 {
			test_pos := position
			test_pos.x += sign
			collision := check_collision(entity, world, test_pos)
			if collision == EMPTY_ID {
				entity.position.x += sign
				move -= sign
			} else {
				return collision
			}
		}
	}
	return 0
}

move_y :: proc(using entity: ^Entity, world: ^World, amount: f32) -> int {
	remainder.y += amount
	move := int(remainder.y)

	if move != 0 {
		remainder.y -= f32(move)
		sign := int(math.sign(f32(move)))

		for move != 0 {
			test_pos := position
			test_pos.y += sign
			collision := check_collision(entity, world, test_pos)
			if collision == EMPTY_ID {
				entity.position.y += sign
				move -= sign
			} else {
				if sign < 0 { 	// If entity collides with something above it, set y velocity to 0
					entity.velocity.y = 0
				}
				return collision
			}
		}
	}
	return 0
}

check_collision :: proc(entity: ^Entity, world: ^World, pos: [2]int) -> int {
	test_box := rl.Rectangle{f32(pos.x), f32(pos.y), f32(entity.size.x), f32(entity.size.y)}

	left_tile: int = int(test_box.x) / TILE_SIZE
	top_tile: int = int(test_box.y) / TILE_SIZE
	right_tile: int = (int(test_box.x) + entity.size.x - 1) / TILE_SIZE
	bottom_tile: int = (int(test_box.y) + entity.size.y - 1) / TILE_SIZE

	for y in top_tile ..= bottom_tile {
		for x in left_tile ..= right_tile {
			if x >= 0 && x < world.width && y >= 0 && y < world.height {
				index := y * world.width + x
				if world.collision_map[index] != 0 {
					return int(world.collision_map[index])
				}
			}
		}
	}

	return 0
}

is_on_ground :: proc(player: ^Entity, world: ^World) -> bool {
	test_pos := player.position
	test_pos.y += 1
	return check_collision(player, world, test_pos) == 1
}
