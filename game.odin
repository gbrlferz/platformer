package mushrun

import "ldtk"
import rl "vendor:raylib"

TILE_SIZE :: 18
GRAVITY :: 20
CAMERA_SMOOTH_SPEED :: 8.0
init_game_state :: proc(level_path: string, level_index: int) -> GameState {
	game_state := GameState {
		player = init_player(),
		tileset = rl.LoadTexture("assets/tilemap.png"),
		camera = {offset = {VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2}, zoom = 1},
		animations = make(map[PlayerState][]rl.Rectangle),
		jump_sound = rl.LoadSound("assets/sounds/jump.wav"),
		coin_sound = rl.LoadSound("assets/sounds/coin.wav"),
	}

	game_state.animations[.RUN] = make([]rl.Rectangle, 2)
	game_state.animations[.RUN][0] = {0, 0, 24, 24}
	game_state.animations[.RUN][1] = {24, 0, 24, 24}

	game_state.animations[.IDLE] = make([]rl.Rectangle, 1)
	game_state.animations[.IDLE][0] = {0, 0, 24, 24}

	game_state.animations[.JUMP] = make([]rl.Rectangle, 1)
	game_state.animations[.JUMP][0] = {0, 0, 24, 24}

	game_state.animations[.FALL] = make([]rl.Rectangle, 1)
	game_state.animations[.FALL][0] = {0, 0, 24, 24}

	if project, ok := ldtk.load_from_file(level_path).?; ok {
		level := project.levels[level_index]
		game_state.level_amount = len(project.levels)
		for layer in level.layer_instances {
			switch layer.type {
			case .IntGrid:
				game_state.world.width = layer.c_width
				game_state.world.height = layer.c_height
				game_state.world.collision_map = make(
					[]u8,
					game_state.world.width * game_state.world.height,
				)

				for value, idx in layer.int_grid_csv {
					game_state.world.collision_map[idx] = u8(value)
				}

				// Get tileset tile textures
				game_state.tile_data = make([]Tile, len(layer.auto_layer_tiles))
				multiplier := TILE_SIZE / layer.grid_size

				for tile, idx in layer.auto_layer_tiles {
					game_state.tile_data[idx] = {
						dest   = {f32(tile.px.x * multiplier), f32(tile.px.y * multiplier)},
						src    = {f32(tile.src.x), f32(tile.src.y)},
						flip_x = bool(tile.f & 1),
						flip_y = bool(tile.f & 2),
					}
				}
			case .AutoLayer:
			case .Entities:
				for entity in layer.entity_instances {
					switch entity.identifier {
					case "Player":
						game_state.player.position = {entity.px.x, entity.px.y}
						game_state.camera.target = {f32(entity.px.x), f32(entity.px.y)}
					case "Diamond":
						coin := Entity {
							position = {entity.px.x, entity.px.y},
							size     = {entity.width, entity.height},
							active   = true,
						}
						append(&game_state.entities, coin)
					case "Goal":
						game_state.goal_rect = {
							f32(entity.px.x),
							f32(entity.px.y),
							f32(entity.width),
							f32(entity.height),
						}
					}
				}
			case .Tiles:
			}
		}
	}
	return game_state
}

update_game :: proc(
	using game_state: ^GameState,
	current_mode: ^Mode,
	current_level: ^int,
	best_time: ^f32,
	dt: f32,
) {

	update_player(game_state, dt)
	game_state.timer += dt
	game_state.player.frame_counter += dt

	if game_state.player.frame_counter >= 1.0 / 12.0 {
		game_state.player.frame_counter = 0
		game_state.player.frame =
			(game_state.player.frame + 1) % len(game_state.animations[game_state.player.state])
	}

	clamped_player_pos := rl.Vector2Clamp(
		to_vec2(game_state.player.position),
		{0, 0},
		{f32(game_state.world.width * TILE_SIZE), f32(game_state.world.height * TILE_SIZE)},
	)

	game_state.player.position = {int(clamped_player_pos.x), int(clamped_player_pos.y)}

	update_camera(game_state, dt)
}

draw_game :: proc(using game_state: ^GameState, target_texture: rl.RenderTexture2D) {
	rl.BeginTextureMode(target_texture)
	rl.ClearBackground(rl.SKYBLUE)
	rl.BeginMode2D(camera)

	for tile in tile_data {
		source_rect := rl.Rectangle{tile.src.x, tile.src.y, TILE_SIZE, TILE_SIZE}
		if tile.flip_x {source_rect.width *= -1}
		if tile.flip_y {source_rect.height *= -1}
		dest_rect := rl.Rectangle{tile.dest.x, tile.dest.y, TILE_SIZE, TILE_SIZE}
		rl.DrawTexturePro(tileset, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)
	}

	for entity in entities {
		if !entity.active {continue}
		source := rl.Rectangle{7 * TILE_SIZE, 3 * TILE_SIZE, TILE_SIZE, TILE_SIZE}
		dest := rl.Rectangle {
			f32(entity.position.x),
			f32(entity.position.y),
			f32(entity.size.x),
			f32(entity.size.y),
		}
		rl.DrawTexturePro(tileset, source, dest, {0, 0}, 0, rl.WHITE)
	}

	draw_player(&player, animations)

	// Draw goal
	rl.DrawTexturePro(
		game_state.tileset,
		{11 * TILE_SIZE, 5 * TILE_SIZE, TILE_SIZE, TILE_SIZE},
		game_state.goal_rect,
		{0, 0},
		0,
		rl.WHITE,
	)

	rl.EndMode2D()
	rl.EndTextureMode()
}
