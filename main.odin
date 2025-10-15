package mushrun

import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

VIRTUAL_WIDTH :: 320
VIRTUAL_HEIGHT :: 180

GameState :: struct {
	camera:       rl.Camera2D,
	world:        World,
	player:       Player,
	jump_sound:   rl.Sound,
	coin_sound:   rl.Sound,
	entities:     [dynamic]Entity,
	animations:   map[PlayerState][]rl.Rectangle,
	goal_rect:    rl.Rectangle,
	tileset:      rl.Texture2D,
	tile_data:    []Tile,
	score:        int,
	timer:        f32,
	level_amount: int,
}

Mode :: enum {
	TITLE,
	GAMEPLAY,
	LEVEL_COMPLETE,
	TRANSITION,
}

main :: proc() {
	rl.InitWindow(1280, 720, "raylib LDtk loader")
	rl.InitAudioDevice()
	rl.SetTargetFPS(60)

	current_level := 0
	game_state := init_game_state("platformer.ldtk", current_level)
	current_mode: Mode = .TITLE
	next_mode: Mode
	best_time: f32 = 500.0

	target_texture := rl.LoadRenderTexture(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
	transition_timer: f32

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		switch current_mode {
		case .TITLE:
			if rl.IsKeyPressed(.ENTER) {
				transition_to(&current_mode, &next_mode, .GAMEPLAY)
				game_state = init_game_state("platformer.ldtk", current_level)
			}

			rl.BeginDrawing()

			rl.ClearBackground(rl.SKYBLUE)
			draw_centered_text("Press enter to start", 40, rl.WHITE)

			rl.EndDrawing()
		case .GAMEPLAY:
			update_game(&game_state, &current_mode, &current_level, &best_time, dt)

			goal_reached := rl.CheckCollisionRecs(
				get_rect(game_state.player),
				game_state.goal_rect,
			)

			if goal_reached {
				transition_to(&current_mode, &next_mode, .LEVEL_COMPLETE)
				if current_level < game_state.level_amount - 1 {
					current_level += 1
				} else {
					current_level = 0
				}

				if game_state.timer < best_time {
					best_time = game_state.timer
				}
			}

			if rl.IsKeyPressed(.R) {
				transition_to(&current_mode, &next_mode, .GAMEPLAY)
				game_state = init_game_state("platformer.ldtk", current_level)
			}

			if game_state.player.active == false {
				transition_to(&current_mode, &next_mode, .TITLE)
			}

			rl.BeginDrawing()

			rl.ClearBackground(rl.BLACK)
			draw_game(&game_state, target_texture)
			source_rect := rl.Rectangle {
				0,
				0,
				f32(target_texture.texture.width),
				-f32(target_texture.texture.height),
			}
			dest_rect := rl.Rectangle{0, 0, 1280, 720}

			rl.DrawTexturePro(target_texture.texture, source_rect, dest_rect, {0, 0}, 0, rl.WHITE)

			time_text := rl.TextFormat("Time: %.2f", game_state.timer)
			time_text_size := rl.MeasureText(time_text, 30)
			rl.DrawText(time_text, rl.GetScreenWidth() - time_text_size - 10, 10, 30, rl.WHITE)

			score_text := rl.TextFormat("Score: %i", game_state.score)
			rl.DrawText(score_text, 10, 10, 30, rl.WHITE)

			rl.EndDrawing()
		case .LEVEL_COMPLETE:
			if rl.IsKeyPressed(.ENTER) {
				transition_to(&current_mode, &next_mode, .TITLE)
			}
			rl.BeginDrawing()
			rl.ClearBackground(rl.SKYBLUE)

			time_text := rl.TextFormat(
				"You Win! Final Time: %.2f\nBest Time: %.2f",
				game_state.timer,
				best_time,
			)

			draw_centered_text(time_text, 40, rl.WHITE)

			rl.EndDrawing()
		case .TRANSITION:
			transition_timer += dt

			if transition_timer > 0.3 {
				current_mode = next_mode
				transition_timer = 0
			}

			rl.BeginDrawing()
			rl.ClearBackground(rl.BLACK)
			rl.EndDrawing()
		}
	}

	rl.UnloadSound(game_state.coin_sound)
	rl.UnloadSound(game_state.jump_sound)
	rl.UnloadTexture(game_state.tileset)
	rl.UnloadRenderTexture(target_texture)

	rl.CloseAudioDevice()
	rl.CloseWindow()
}

update_camera :: proc(using game_state: ^GameState, dt: f32) {
	camera.target = linalg.lerp(camera.target, to_vec2(player.position), CAMERA_SMOOTH_SPEED * dt)

	camera.target.x = clamp(
		camera.target.x,
		f32(camera.offset.x / camera.zoom),
		f32(world.width * TILE_SIZE) - camera.offset.x / camera.zoom,
	)

	camera.target.y = clamp(
		camera.target.y,
		f32(camera.offset.y / camera.zoom),
		f32(world.height * TILE_SIZE) - camera.offset.y / camera.zoom,
	)

	camera.target = {math.round(camera.target.x), math.round(camera.target.y)}
}

transition_to :: proc(current_mode: ^Mode, next_mode: ^Mode, destination: Mode) {
	current_mode^ = .TRANSITION
	next_mode^ = destination
}
