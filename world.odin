package game

import rl "vendor:raylib"

World :: struct {
	entities:     [dynamic]Entity,
	tilemap:      Tilemap,
	player:       ^Entity,
	solid_texture: rl.Texture2D,
}

TileType :: enum {
	EMPTY,
	SOLID,
}

Tilemap :: struct {
	width, height: int,
	tiles:         []TileType,
}

draw_tilemap :: proc(world: ^World) {
	for y in 0 ..< world.tilemap.height {
		for x in 0 ..< world.tilemap.width {
			idx := y * world.tilemap.width + x
			tile := world.tilemap.tiles[idx]
			pos := rl.Vector2{f32(x * TILE_SIZE), f32(y * TILE_SIZE)}

			switch tile {
			case .EMPTY:
				break
			case .SOLID:
				rl.DrawRectangleV(pos, {TILE_SIZE, TILE_SIZE}, rl.DARKGRAY)
				rl.DrawTextureV(world.solid_texture, pos, rl.WHITE)
			}
		}
	}
}

create_world :: proc() -> World {
	world: World

	player := Entity {
		position    = {0, 0},
		texture     = rl.LoadTexture("assets/player.png"),
		size        = {16, 20},
		velocity    = {0, 0},
		x_remainder = 0,
		y_remainder = 0,
		facing_right = true,
	}
	append(&world.entities, player)
	world.player = &world.entities[len(world.entities) - 1]

	world.tilemap = Tilemap {
		width  = 40,
		height = 22,
		tiles  = make([]TileType, 40 * 22),
	}

	for x in 0 ..< 40 {
		world.tilemap.tiles[8 * 40 + x] = .SOLID
	}

	world.solid_texture = rl.LoadTexture("assets/ground.png")

	return world
}

cleanup_world :: proc(world: ^World) {
	// Unload textures to prevent memory leaks
	rl.UnloadTexture(world.solid_texture)
	
	// Clean up player texture
	if world.player != nil {
		rl.UnloadTexture(world.player.texture)
	}
	
	// Free dynamic array memory
	delete(world.entities)
	delete(world.tilemap.tiles)
}
