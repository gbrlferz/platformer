package game

import "core:math"
import rl "vendor:raylib"

TILE_SIZE :: 8
GRAVITY :: 0.5

editor: Editor

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Platformer")
	defer rl.CloseWindow()
	rl.SetTargetFPS(TARGET_FPS)

	game: GameScreen

	renderer := init_renderer(GAME_WIDTH, GAME_HEIGHT)
	defer cleanup_renderer(&renderer)
	renderer.world_camera.offset = {f32(GAME_WIDTH / 2), f32(GAME_HEIGHT / 2)}
	renderer.world_camera.zoom = 1.0

	player_texture := rl.LoadTexture("assets/player.png")
	world := create_world()
	defer cleanup_world(&world)

	for !rl.WindowShouldClose() {
		delta := rl.GetFrameTime()
		virtual_ratio := f32(rl.GetScreenWidth()) / f32(GAME_WIDTH)

		handle_window_resizing(&renderer)

		if rl.IsKeyPressed(.F1) {
			if game == .GAME {
				game = .EDITING
				editor.active = true
			} else {
				game = .GAME
				editor.active = false
			}
		}

		switch game {
		case .TITLE:

		case .GAME:
			update_player(world.player, &world, delta)
			renderer.screen_camera.zoom = 1.0
			renderer.world_camera.target = {
				f32(world.player.position.x + (world.player.size.x / 2)),
				f32(world.player.position.y + (world.player.size.y / 2)),
			}
		case .EDITING:
			update_editor(&editor, &world, &renderer.world_camera, virtual_ratio)
		}

		begin_world_rendering(&renderer)

		rl.ClearBackground(rl.SKYBLUE)
		draw_player(world.player, player_texture)
		draw_tilemap(&world)
		draw_editor(&editor, &world, &renderer.world_camera, virtual_ratio)

		end_world_rendering(&renderer)

		rl.BeginDrawing()

		rl.ClearBackground(rl.BLACK)
		draw_to_screen(&renderer)

		switch game {
		case .TITLE:
			if rl.GuiButton({24, 24, 120, 30}, "Play") {
				game = .GAME
			}
		case .GAME:
		case .EDITING:
			rl.DrawText("Editing", 10, 10, 20, rl.WHITE)
		}

		rl.EndDrawing()
	}
}

handle_window_resizing :: proc(renderer: ^Renderer) {
	if rl.IsWindowResized() {
		cleanup_renderer(renderer)
		renderer := init_renderer(GAME_WIDTH, GAME_HEIGHT)
		rl.SetMouseScale(
			f32(GAME_WIDTH) / f32(rl.GetScreenWidth()),
			f32(GAME_HEIGHT) / f32(rl.GetScreenHeight()),
		)
	}
}
