package game

import rl "vendor:raylib"

GAME_WIDTH :: 320
GAME_HEIGHT :: 180

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720
TARGET_FPS :: 60

Renderer :: struct {
	virtual_width:       i32,
	virtual_height:      i32,
	virtual_ratio:       f32,
	world_camera:  rl.Camera2D,
	screen_camera: rl.Camera2D,
	target:              rl.RenderTexture2D,
	source_rec:          rl.Rectangle,
	dest_rec:            rl.Rectangle,
	origin:              rl.Vector2,
}

init_renderer :: proc(virtual_width, virtual_height: i32) -> Renderer {
	virtual_ratio := f32(rl.GetScreenWidth()) / f32(virtual_width)

	target := rl.LoadRenderTexture(virtual_width, virtual_height)

	source_rec := rl.Rectangle{0, 0, f32(target.texture.width), f32(-target.texture.height)}

	dest_rec := rl.Rectangle {
		-virtual_ratio,
		-virtual_ratio,
		f32(rl.GetScreenWidth()) + (virtual_ratio * 2),
		f32(rl.GetScreenHeight()) + (virtual_ratio * 2),
	}

	return Renderer {
		virtual_width = virtual_width,
		virtual_height = virtual_height,
		virtual_ratio = virtual_ratio,
		world_camera = {zoom = 1},
		screen_camera = {zoom = 1},
		target = target,
		source_rec = source_rec,
		dest_rec = dest_rec,
		origin = {0, 0},
	}
}

begin_world_rendering :: proc(using renderer: ^Renderer) {
	rl.BeginTextureMode(target)
	rl.BeginMode2D(world_camera)
}

end_world_rendering :: proc(using renderer: ^Renderer) {
	rl.EndMode2D()
	rl.EndTextureMode()
}

draw_to_screen :: proc(using renderer: ^Renderer) {
	rl.BeginMode2D(screen_camera)
	rl.DrawTexturePro(target.texture, source_rec, dest_rec, origin, 0, rl.WHITE)
	rl.EndMode2D()
}

cleanup_renderer :: proc(using renderer: ^Renderer) {
	rl.UnloadRenderTexture(target)
}

get_virtual_mouse_position :: proc(renderer: ^Renderer) -> rl.Vector2 {
	screen_mouse := rl.GetMousePosition()

	return {
		screen_mouse.x * f32(renderer.virtual_width) / f32(rl.GetScreenWidth()),
		screen_mouse.y * f32(renderer.virtual_height) / f32(rl.GetScreenHeight()),
	}
}
