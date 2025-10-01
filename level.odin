package game

import rl "vendor:raylib"

draw_tilemap :: proc(world: ^Level) {
	for tile in world.solids {
		rl.DrawRectangle(tile.position.x, tile.position.y, tile.size.x, tile.size.y, rl.WHITE)
	}
}

create_world :: proc() -> Level {
	world: Level
	player := Entity {
		position     = {0, 0},
		size         = {16, 20},
		facing_right = true,
	}
	append(&world.entities, player)
	world.player = &world.entities[len(world.entities) - 1]
	world.solid_texture = rl.LoadTexture("assets/ground.png")

	return world
}

cleanup_world :: proc(world: ^Level) {
	rl.UnloadTexture(world.solid_texture)
	delete(world.entities)
	delete(world.solids)
}
