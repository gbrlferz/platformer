package game

import "core:math"
import rl "vendor:raylib"

TILE_SIZE :: 8
GRAVITY :: 0.5

editor: Editor

Entity :: struct {
	position:                 rl.Vector2,
	size:                     rl.Vector2,
	velocity:                 rl.Vector2,
	texture:                  rl.Texture2D,
	x_remainder, y_remainder: f32,
}

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Celeste-style Physics")

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

		if rl.IsKeyPressed(.F2) {
			editor.active = !editor.active
		}

		update_player(world.player, &world, delta)

		if !editor.active {
			screen_space_camera.zoom = 1.0
			world_space_camera.target = world.player.position + world.player.size * 0.5
		}

		update_editor(&editor, &world, &world_space_camera, virtual_ratio)

		rl.BeginTextureMode(target)
		rl.ClearBackground(rl.SKYBLUE)
		rl.BeginMode2D(world_space_camera)

		// Draw player
		rl.DrawTextureV(world.player.texture, world.player.position, rl.WHITE)

		draw_tilemap(&world)
		draw_editor(&editor, &world, &world_space_camera, virtual_ratio)

		rl.EndMode2D()
		rl.EndTextureMode()

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		rl.BeginMode2D(screen_space_camera)
		rl.DrawTexturePro(target.texture, source_rec, dest_rec, origin, 0, rl.WHITE)
		rl.EndMode2D()

		rl.DrawFPS(10, 10)

		if editor.active {
			rl.DrawText("Editing", 10, 10, 20, rl.WHITE)
		}

		rl.EndDrawing()
	}
	
	// Cleanup resources before closing
	cleanup_world(&world)
	rl.UnloadRenderTexture(target)
	rl.CloseWindow()
}
