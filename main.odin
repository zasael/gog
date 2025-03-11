package main

import "core:fmt"
import "core:math"
import "core:mem"
import "vendor:raylib"

WIDTH :: 1280
HEIGHT :: 720
WALL_THICKNESS :: 10

add_child :: proc(parent, child: ^Object) {
	append(&parent.children, child)
}

create_room :: proc(
	x, y, width, height: f32,
	wall_color: raylib.Color,
	floor_color: raylib.Color,
	allocator: mem.Allocator,
) -> ^Object {
	// Create room container
	room_transform := raylib.MatrixTranslate(x, y, 0)
	room := create_object(
		Rectangle{pos = {0, 0}, size = {width, height}},
		room_transform,
		floor_color,
		allocator,
	)

	// Left wall
	left_wall := Rectangle {
		pos  = {0, 0},
		size = {WALL_THICKNESS, height},
	}
	left_wall_obj := create_object(left_wall, raylib.Matrix(1), wall_color, allocator)
	add_child(room, left_wall_obj)

	// Right wall
	right_wall := Rectangle {
		pos  = {width - WALL_THICKNESS, 0},
		size = {WALL_THICKNESS, height},
	}
	right_wall_obj := create_object(right_wall, raylib.Matrix(1), wall_color, allocator)
	add_child(room, right_wall_obj)

	// Top wall
	top_wall := Rectangle {
		pos  = {0, 0},
		size = {width, WALL_THICKNESS},
	}
	top_wall_obj := create_object(top_wall, raylib.Matrix(1), wall_color, allocator)
	add_child(room, top_wall_obj)

	// Bottom wall
	bottom_wall := Rectangle {
		pos  = {0, height - WALL_THICKNESS},
		size = {width, WALL_THICKNESS},
	}
	bottom_wall_obj := create_object(bottom_wall, raylib.Matrix(1), wall_color, allocator)
	add_child(room, bottom_wall_obj)

	return room
}

// Create a door by removing part of a wall
create_door :: proc(
	room: ^Object,
	wall_position: string,
	door_pos, door_size: f32,
	wall_color: raylib.Color,
	allocator: mem.Allocator,
) {
	room_transform := room.transform
	room_rectangle := (room.shape).(Rectangle)
	width := room_rectangle.size.x
	height := room_rectangle.size.y

	// Remove the existing wall
	for i := 0; i < len(room.children); i += 1 {
		child := room.children[i]
		wall_rect := (child.shape).(Rectangle)

		if wall_position == "left" && wall_rect.pos.x == 0 && wall_rect.size.x == WALL_THICKNESS ||
		   wall_position == "right" && wall_rect.pos.x > width - WALL_THICKNESS - 1 ||
		   wall_position == "top" && wall_rect.pos.y == 0 && wall_rect.size.y == WALL_THICKNESS ||
		   wall_position == "bottom" && wall_rect.pos.y > height - WALL_THICKNESS - 1 {
			ordered_remove(&room.children, i)
			i -= 1
		}
	}

	// Add back wall segments with a gap for the door
	if wall_position == "left" {
		// Top segment
		top_wall := Rectangle {
			pos  = {0, 0},
			size = {WALL_THICKNESS, door_pos},
		}
		if door_pos > 0 {
			top_wall_obj := create_object(top_wall, raylib.Matrix(1), wall_color, allocator)
			add_child(room, top_wall_obj)
		}

		// Bottom segment
		bottom_wall := Rectangle {
			pos  = {0, door_pos + door_size},
			size = {WALL_THICKNESS, height - (door_pos + door_size)},
		}
		if bottom_wall.size.y > 0 {
			bottom_wall_obj := create_object(bottom_wall, raylib.Matrix(1), wall_color, allocator)
			add_child(room, bottom_wall_obj)
		}
	} else if wall_position == "right" {
		// Top segment
		top_wall := Rectangle {
			pos  = {width - WALL_THICKNESS, 0},
			size = {WALL_THICKNESS, door_pos},
		}
		if door_pos > 0 {
			top_wall_obj := create_object(top_wall, raylib.Matrix(1), wall_color, allocator)
			add_child(room, top_wall_obj)
		}

		// Bottom segment
		bottom_wall := Rectangle {
			pos  = {width - WALL_THICKNESS, door_pos + door_size},
			size = {WALL_THICKNESS, height - (door_pos + door_size)},
		}
		if bottom_wall.size.y > 0 {
			bottom_wall_obj := create_object(bottom_wall, raylib.Matrix(1), wall_color, allocator)
			add_child(room, bottom_wall_obj)
		}
	} else if wall_position == "top" {
		// Left segment
		left_wall := Rectangle {
			pos  = {0, 0},
			size = {door_pos, WALL_THICKNESS},
		}
		if door_pos > 0 {
			left_wall_obj := create_object(left_wall, raylib.Matrix(1), wall_color, allocator)
			add_child(room, left_wall_obj)
		}

		// Right segment
		right_wall := Rectangle {
			pos  = {door_pos + door_size, 0},
			size = {width - (door_pos + door_size), WALL_THICKNESS},
		}
		if right_wall.size.x > 0 {
			right_wall_obj := create_object(right_wall, raylib.Matrix(1), wall_color, allocator)
			add_child(room, right_wall_obj)
		}
	} else if wall_position == "bottom" {
		// Left segment
		left_wall := Rectangle {
			pos  = {0, height - WALL_THICKNESS},
			size = {door_pos, WALL_THICKNESS},
		}
		if door_pos > 0 {
			left_wall_obj := create_object(left_wall, raylib.Matrix(1), wall_color, allocator)
			add_child(room, left_wall_obj)
		}

		// Right segment
		right_wall := Rectangle {
			pos  = {door_pos + door_size, height - WALL_THICKNESS},
			size = {width - (door_pos + door_size), WALL_THICKNESS},
		}
		if right_wall.size.x > 0 {
			right_wall_obj := create_object(right_wall, raylib.Matrix(1), wall_color, allocator)
			add_child(room, right_wall_obj)
		}
	}
}

create_map :: proc(allocator: mem.Allocator) -> ^Object {
	root := create_object(nil, raylib.Matrix(1), raylib.BLACK, allocator)

	room_width := 200
	room_height := 150
	door_size := 50
	wall_color := raylib.DARKGRAY

	// Create room layout

	// Room 1 (Top Left)
	room1 := create_room(
		50,
		50,
		f32(room_width),
		f32(room_height),
		wall_color,
		raylib.GRAY,
		allocator,
	)
	add_child(root, room1)

	// Room 2 (Top Right)
	room2 := create_room(
		300,
		50,
		f32(room_width),
		f32(room_height),
		wall_color,
		raylib.GRAY,
		allocator,
	)
	add_child(root, room2)

	// Room 3 (Bottom Left)
	room3 := create_room(
		50,
		250,
		f32(room_width),
		f32(room_height),
		wall_color,
		raylib.GRAY,
		allocator,
	)
	add_child(root, room3)

	// Room 4 (Bottom Right)
	room4 := create_room(
		300,
		250,
		f32(room_width),
		f32(room_height),
		wall_color,
		raylib.GRAY,
		allocator,
	)
	add_child(root, room4)

	// Room 5 (Center)
	room5 := create_room(
		550,
		150,
		f32(room_width),
		f32(room_height),
		wall_color,
		raylib.GRAY,
		allocator,
	)
	add_child(root, room5)

	// Add doors between rooms

	// Door between Room 1 and Room 2
	create_door(room1, "right", 50, f32(door_size), wall_color, allocator)
	create_door(room2, "left", 50, f32(door_size), wall_color, allocator)

	// Door between Room 1 and Room 3
	create_door(room1, "bottom", 75, f32(door_size), wall_color, allocator)
	create_door(room3, "top", 75, f32(door_size), wall_color, allocator)

	// Door between Room 2 and Room 4
	create_door(room2, "bottom", 75, f32(door_size), wall_color, allocator)
	create_door(room4, "top", 75, f32(door_size), wall_color, allocator)

	// Door between Room 3 and Room 4
	create_door(room3, "right", 50, f32(door_size), wall_color, allocator)
	create_door(room4, "left", 50, f32(door_size), wall_color, allocator)

	// Door between Room 2 and Room 5
	create_door(room2, "right", 50, f32(door_size), wall_color, allocator)
	create_door(room5, "left", 50, f32(door_size), wall_color, allocator)

	return root
}

create_player :: proc(allocator: mem.Allocator) -> ^Object {
	player_shape := Circle {
		pos    = {0, 0},
		radius = 10,
	}
	player := create_object(player_shape, raylib.Matrix(1), raylib.BLUE, allocator)
	return player
}

main :: proc() {
	raylib.SetTargetFPS(60)
	raylib.InitWindow(WIDTH, HEIGHT, "gog & mgog")
	raylib.HideCursor()

	arena: mem.Arena
	mem.arena_init(&arena, make([]byte, 4 * 1024 * 1024))
	allocator := mem.arena_allocator(&arena)
	root := create_object(nil, raylib.Matrix(1), raylib.BLACK, allocator)
	map_object := create_map(allocator)
	player := create_player(allocator)

	add_child(root, map_object)
	add_child(root, player)

	zoom: f32 = 1
	speed: f32 = 3
	angle: f32 = 0
	screen_center := raylib.Vector2 {
		WIDTH / 2,
		HEIGHT / 2,
	}
	virtual_mouse_position := screen_center
	position: raylib.Vector2 = {0, 0}

	for !raylib.WindowShouldClose() {
		// handle mouse events and push to queue
		// handle keyboard events and push to queue
		// read from event queue and modify view hierarchy

		// render view hierarchy

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.BLACK)

		mouse_position := raylib.GetMousePosition()

		virtual_mouse_position += mouse_position - screen_center
		raylib.SetMousePosition(i32(screen_center.x), i32(screen_center.y))
		if mouse_position.x != 0 {
			angle = f32(virtual_mouse_position.x) * -0.008
		}

		mouse_wheel := raylib.GetMouseWheelMove()

		if mouse_wheel != 0 {
			zoom *= f32(math.exp_f32(0.01 * mouse_wheel))
		}

		if raylib.IsKeyDown(.W) {
			position.x += speed * math.sin_f32(angle)
			position.y += speed * math.cos_f32(angle)
		}
		if raylib.IsKeyDown(.S) {
			position.x -= speed * math.sin_f32(angle)
			position.y -= speed * math.cos_f32(angle)
		}
		if raylib.IsKeyDown(.A) {
			position.y += speed * math.sin_f32(angle)
			position.x += speed * math.cos_f32(angle)
		}
		if raylib.IsKeyDown(.D) {
			position.y -= speed * math.sin_f32(angle)
			position.x -= speed * math.cos_f32(angle)
		}

		map_object.transform =
			raylib.MatrixRotateZ(angle) * raylib.MatrixTranslate(position.x, position.y, 0)

		if raylib.IsKeyDown(.LEFT_SHIFT) {
			speed = 7
		} else {
			speed = 4
		}


		draw_object(
			root,
			raylib.MatrixTranslate(WIDTH / 2, HEIGHT / 2, 0) * raylib.MatrixScale(zoom, zoom, 1),
		)

		raylib.DrawFPS(10, 10)
		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
