package game

import "core:math"
import rl "vendor:raylib"

TILE_SIZE :: 8
GRAVITY :: 0.5

editor: Editor

Entity :: struct {
	position:     [2]i32,
	size:         [2]i32,
	remainder:    [2]f32,
	velocity:     rl.Vector2,
	facing_right: bool,
}

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Platformer")

	player_texture := rl.LoadTexture("assets/player.png")

	target := rl.LoadRenderTexture(VIRTUAL_SCREEN_WIDTH, VIRTUAL_SCREEN_HEIGHT)
	source_rec := rl.Rectangle{0, 0, f32(target.texture.width), f32(-target.texture.height)}
	origin := rl.Vector2{0, 0}

	world_space_camera: rl.Camera2D
	screen_space_camera: rl.Camera2D

	world_space_camera.offset = {f32(VIRTUAL_SCREEN_WIDTH / 2), f32(VIRTUAL_SCREEN_HEIGHT / 2)}
	world_space_camera.zoom = 1.0

	rl.SetTargetFPS(TARGET_FPS)
	world := create_world()
	editing := false

	for !rl.WindowShouldClose() {
		delta := rl.GetFrameTime()
		virtual_ratio := f32(rl.GetScreenWidth()) / f32(VIRTUAL_SCREEN_WIDTH)

		dest_rec := rl.Rectangle {
			f32(-virtual_ratio),
			f32(-virtual_ratio),
			f32(rl.GetScreenWidth()) + (virtual_ratio * 2),
			f32(rl.GetScreenHeight()) + (virtual_ratio * 2),
		}

		if rl.IsKeyPressed(.F1) {
			editor.active = !editor.active
		}

		update_player(world.player, &world, delta)

		if !editor.active {
			screen_space_camera.zoom = 1.0
			world_space_camera.target = {
				f32(world.player.position.x + (world.player.size.x / 2)),
				f32(world.player.position.y + (world.player.size.y / 2)),
			}
		}

		update_editor(&editor, &world, &world_space_camera, virtual_ratio)

		rl.BeginTextureMode(target)
		rl.ClearBackground(rl.SKYBLUE)
		rl.BeginMode2D(world_space_camera)

		// Draw player
		draw_player(world.player, player_texture)

		draw_tilemap(&world)
		draw_editor(&editor, &world, &world_space_camera, virtual_ratio)

		rl.EndMode2D()
		rl.EndTextureMode()

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		rl.BeginMode2D(screen_space_camera)
		rl.DrawTexturePro(target.texture, source_rec, dest_rec, origin, 0, rl.WHITE)
		rl.EndMode2D()

		if editor.active {
			rl.DrawText("Editing", 10, 10, 20, rl.WHITE)
		}

		rl.EndDrawing()
	}

	cleanup_world(&world)
	rl.UnloadRenderTexture(target)
	rl.CloseWindow()
}
