package platformer

import rl "vendor:raylib"

to_vec2 :: proc(vec2i: [2]int) -> rl.Vector2 {
	return {f32(vec2i.x), f32(vec2i.y)}
}

get_rect :: proc(entity: Entity) -> rl.Rectangle {
	return {f32(entity.position.x), f32(entity.position.y), f32(entity.size.x), f32(entity.size.y)}
}

draw_centered_text :: proc(text: cstring, font_size: i32, color: rl.Color) {
	text_width := rl.MeasureText(text, font_size)
	x_pos := (rl.GetScreenWidth() / 2) - (text_width / 2)
	y_pos := (rl.GetScreenHeight() / 2) - font_size
	rl.DrawText(text, x_pos, y_pos, font_size, color)
}
