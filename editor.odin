package game

import "core:math"
import rl "vendor:raylib"

Editor :: struct {
	active: bool,
}

update_editor :: proc(
	editor: ^Editor,
	world: ^World,
	world_camera: ^rl.Camera2D,
	virtual_ratio: f32,
) {
	if !editor.active {
		return
	}
	mouse_screen := rl.GetMousePosition()

	virtual_mouse := rl.Vector2{mouse_screen.x / virtual_ratio, mouse_screen.y / virtual_ratio}

	mouse_world := rl.GetScreenToWorld2D(virtual_mouse, world_camera^)

	if rl.IsMouseButtonDown(.MIDDLE) {
		delta := rl.GetMouseDelta() * -1.0 / world_camera.zoom / virtual_ratio

		world_camera.target = {
			math.trunc(world_camera.target.x + delta.x),
			math.trunc(world_camera.target.y + delta.y),
		}
	}

	tile_x := int(mouse_world.x / TILE_SIZE)
	tile_y := int(mouse_world.y / TILE_SIZE)

	if tile_x >= 0 &&
	   tile_x < world.tilemap.width &&
	   tile_y >= 0 &&
	   tile_y < world.tilemap.height {

		idx := tile_y * world.tilemap.width + tile_x
		if rl.IsMouseButtonDown(.LEFT) {
			world.tilemap.tiles[idx] = .SOLID
		}
		if rl.IsMouseButtonDown(.RIGHT) {
			world.tilemap.tiles[idx] = .EMPTY
		}
	}
}

draw_editor :: proc(
	editor: ^Editor,
	world: ^World,
	world_camera: ^rl.Camera2D,
	virtual_ratio: f32,
) {
	if !editor.active {
		return
	}
	mouse_screen := rl.GetMousePosition()
	virtual_mouse := rl.Vector2{mouse_screen.x / virtual_ratio, mouse_screen.y / virtual_ratio}
	mouse_world := rl.GetScreenToWorld2D(virtual_mouse, world_camera^)

	tile_x := int(mouse_world.x / TILE_SIZE)
	tile_y := int(mouse_world.y / TILE_SIZE)

	if tile_x >= 0 &&
	   tile_x < world.tilemap.width &&
	   tile_y >= 0 &&
	   tile_y < world.tilemap.height {

		hover_rect := rl.Rectangle {
			x      = f32(tile_x * TILE_SIZE),
			y      = f32(tile_y * TILE_SIZE),
			width  = TILE_SIZE,
			height = TILE_SIZE,
		}

		rl.DrawRectangleLinesEx(hover_rect, 2, rl.YELLOW)
	}

	for entity in world.entities {
		rl.DrawRectangleV(
			{f32(entity.position.x), f32(entity.position.y)},
			f32(entity.size.x),
			{0, 0, 255, 100},
		)
	}
}
