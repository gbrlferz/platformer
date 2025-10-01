package game

import "core:math"
import rl "vendor:raylib"


update_editor :: proc(
	editor: ^Editor,
	world: ^Level,
	world_camera: ^rl.Camera2D,
	virtual_ratio: f32,
) {
	if !editor.active {return}
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

	mouse_tile := [2]i32 {
		i32(math.floor(mouse_world.x / 18) * 18),
		i32(math.floor(mouse_world.y / 18) * 18),
	}

	default_solid := Solid {
		position = {mouse_tile.x, mouse_tile.y},
		size     = {18, 18},
	}

	if rl.IsMouseButtonDown(.LEFT) {
		for solid in world.solids {
			if solid.position == mouse_tile {
				return
			}
		}
		append(&world.solids, default_solid)
	}
	if rl.IsMouseButtonDown(.RIGHT) {
		for &solid, i in world.solids {
			if solid.position == mouse_tile {
				unordered_remove(&world.solids, i)
			}
		}
	}
}

draw_editor :: proc(
	editor: ^Editor,
	world: ^Level,
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

	for entity in world.entities {
		rl.DrawRectangle(
			entity.position.x,
			entity.position.y,
			entity.size.x,
			entity.size.y,
			{0, 0, 255, 100},
		)
	}
}
