package main

import "core:fmt"
import "vendor:raylib"


Player :: struct {
	position: raylib.Vector2,
	radius: f32,
	color: raylib.Color
}

draw_player :: proc(player: Player) {
	raylib.DrawCircleV(player.position, player.radius, player.color)
}

WIDTH :: 1280
HEIGHT :: 720

main :: proc() {
	raylib.SetTargetFPS(60)
	raylib.InitWindow(WIDTH, HEIGHT, "gog & mgog")

	player := Player{
		position = raylib.Vector2{WIDTH/2, HEIGHT/2},
		radius = 40,
		color = raylib.RED,
	}

	for !raylib.WindowShouldClose() {
		// handle mouse events and push to queue
		// handle keyboard events and push to queue
		// read from event queue and modify view hierarchy

		// render view hierarchy

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.BLACK)

		mouse_speed := raylib.GetMouseDelta()

		draw_player(player)
		raylib.DrawFPS(10, 10)
		raylib.DrawText(fmt.caprintf("Mouse speed: %.2f, %.2f", mouse_speed.x, mouse_speed.y), 10, 20, 20, raylib.LIGHTGRAY)
		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
