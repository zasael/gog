package main

import "core:fmt"
import "core:mem"
import "vendor:raylib"

// Transform is a 3x3 matrix for 2D transformation, (rotation and translation)
Transform :: raylib.Matrix


Rectangle :: struct {
	pos:  raylib.Vector2,
	size: raylib.Vector2,
}

draw_rectangle :: proc(rectangle: Rectangle, transform: Transform, color: raylib.Color) {
	top_left := raylib.Vector3Transform({rectangle.pos.x, rectangle.pos.y, 0}, transform).xy
	top_right :=
		raylib.Vector3Transform({rectangle.pos.x + rectangle.size.x, rectangle.pos.y, 0}, transform).xy
	bottom_left :=
		raylib.Vector3Transform({rectangle.pos.x, rectangle.pos.y + rectangle.size.y, 0}, transform).xy
	bottom_right :=
		raylib.Vector3Transform({rectangle.pos.x + rectangle.size.x, rectangle.pos.y + rectangle.size.y, 0}, transform).xy

	raylib.DrawTriangle(top_left, bottom_left, top_right, color)
	raylib.DrawTriangle(bottom_right, top_right, bottom_left, color)
}

Triangle :: struct {
	a: raylib.Vector2,
	b: raylib.Vector2,
	c: raylib.Vector2,
}

draw_triangle :: proc(triangle: Triangle, transform: Transform, color: raylib.Color) {
	a := raylib.Vector3Transform({triangle.a.x, triangle.a.y, 0}, transform).xy
	b := raylib.Vector3Transform({triangle.b.x, triangle.b.y, 0}, transform).xy
	c := raylib.Vector3Transform({triangle.c.x, triangle.c.y, 0}, transform).xy

	raylib.DrawTriangle(a, b, c, color)
}

Circle :: struct {
	pos:    raylib.Vector2,
	radius: f32,
}

draw_circle :: proc(circle: Circle, transform: Transform, color: raylib.Color) {
	center := raylib.Vector3Transform({circle.pos.x, circle.pos.y, 0}, transform).xy
	scaling := transform[0, 0]
	radius := circle.radius * scaling
	// TODO: should handle non uniform scaling
	raylib.DrawCircle(i32(center.x), i32(center.y), radius, color)
}

// TODO: add bezier path


Shape :: union {
	Rectangle,
	Triangle,
	Circle,
}

Object :: struct {
	shape:     Shape,
	transform: raylib.Matrix,
	children:  [dynamic]^Object,
	solid:     bool,
	color:     raylib.Color,
}


create_object :: proc(
	shape: Shape,
	transform: Transform,
	color: raylib.Color,
	solid: bool,
	allocator: mem.Allocator,
) -> ^Object {
	object := new(Object, allocator)
	object.shape = shape
	object.transform = transform
	object.children = make([dynamic]^Object, 0, 8, allocator)
	object.solid = solid
	object.color = color
	return object
}

// transform_point :: proc(transform: Transform, point: raylib.Matrix

draw_object :: proc(object: ^Object, parent_transform: raylib.Matrix) {
	if object == nil {
		return
	}

	transform := parent_transform * object.transform

	if object.shape != nil {
		switch shape in object.shape {
		case Rectangle:
			draw_rectangle(shape, transform, object.color)
		case Triangle:
			draw_triangle(shape, transform, object.color)
		case Circle:
			draw_circle(shape, transform, object.color)
		}
	}


	if object.children != nil {
		for child in object.children {
			draw_object(child, transform)
		}
	}
}

check_collision :: proc(first, second: ^Object) -> bool {
	switch firstShape in first.shape {
	case Rectangle:
		switch secondShape in second.shape {
		case Rectangle:
			return raylib.CheckCollisionRecs(
				raylib.Rectangle {
					firstShape.pos.x,
					firstShape.pos.y,
					firstShape.size.x,
					firstShape.size.y,
				},
				raylib.Rectangle {
					secondShape.pos.x,
					secondShape.pos.y,
					secondShape.size.x,
					secondShape.size.y,
				},
			)
		case Triangle:
			return raylib.CheckCollisionRecs(raylib.Rectangle{}, raylib.Rectangle{})
		case Circle:
			return raylib.CheckCollisionCircleRec(
				secondShape.pos,
				secondShape.radius,
				raylib.Rectangle {
					firstShape.pos.x,
					firstShape.pos.y,
					firstShape.size.x,
					firstShape.size.y,
				},
			)
		}
	case Triangle:
		switch secondShape in second.shape {
		case Rectangle:
			return raylib.CheckCollisionRecs(raylib.Rectangle{}, raylib.Rectangle{})
		case Triangle:
			return raylib.CheckCollisionRecs(raylib.Rectangle{}, raylib.Rectangle{})
		case Circle:
			return raylib.CheckCollisionRecs(raylib.Rectangle{}, raylib.Rectangle{})
		}
	case Circle:
		switch secondShape in second.shape {
		case Rectangle:
			return raylib.CheckCollisionCircleRec(
				firstShape.pos,
				firstShape.radius,
				raylib.Rectangle {
					secondShape.pos.x,
					secondShape.pos.y,
					secondShape.size.x,
					secondShape.size.y,
				},
			)
		case Triangle:
			return raylib.CheckCollisionRecs(raylib.Rectangle{}, raylib.Rectangle{})
		case Circle:
			return raylib.CheckCollisionCircles(
				firstShape.pos,
				firstShape.radius,
				secondShape.pos,
				secondShape.radius,
			)
		}
	}
	return false
}
