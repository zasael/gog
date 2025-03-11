package main

import "core:fmt"
import "core:math"
import "vendor:raylib"

WIDTH :: 1280
HEIGHT :: 720

main :: proc() {
	raylib.SetTargetFPS(60)
	raylib.InitWindow(WIDTH, HEIGHT, "gog & mgog")

	root := create_object(shape = nil, transform = raylib.Matrix(1))
	player := create_object(
		shape = Circle{pos = {0, 0}, radius = 10},
		transform = raylib.Matrix(1),
	)
	append(&root.children, &player)

	for !raylib.WindowShouldClose() {
		// handle mouse events and push to queue
		// handle keyboard events and push to queue
		// read from event queue and modify view hierarchy

		// render view hierarchy

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.BLACK)

		mouse_speed := raylib.GetMouseDelta()
		mouse_wheel := raylib.GetMouseWheelMove()

		draw_object(
			&root,
			/*raylib.MatrixRotateZ(math.PI/2) **/
			raylib.MatrixTranslate(WIDTH/2, HEIGHT/2, 0),
		)

		// raylib.DrawFPS(10, 10)
		raylib.DrawText(fmt.caprintf("Mouse speed: %.2f, %.2f", mouse_speed.x, mouse_speed.y), 10, 20, 20, raylib.LIGHTGRAY)
		raylib.DrawText(fmt.caprintf("Mouse wheel: %.2f", mouse_wheel), 10, 40, 20, raylib.LIGHTGRAY)
		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
