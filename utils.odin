package game

import "core:math"

round :: proc(val: f32) -> f32 {
	return math.floor(val + 0.5)
}
