package main

import "core:fmt"
import "vendor:raylib"

// Transform is a 3x3 matrix for 2D transformation, (rotation and translation)
Transform :: raylib.Matrix


Rectangle :: struct {
	pos:  raylib.Vector2,
	size: raylib.Vector2,
}

draw_rectangle :: proc(rectangle: Rectangle, transform: Transform) {
	top_left := raylib.Vector3Transform({rectangle.pos.x, rectangle.pos.y, 0}, transform).xy
	top_right :=
		raylib.Vector3Transform({rectangle.pos.x + rectangle.size.x, rectangle.pos.y, 0}, transform).xy
	bottom_left :=
		raylib.Vector3Transform({rectangle.pos.x, rectangle.pos.y + rectangle.size.y, 0}, transform).xy
	bottom_right :=
		raylib.Vector3Transform({rectangle.pos.x + rectangle.size.y, rectangle.pos.y + rectangle.size.y, 0}, transform).xy

	raylib.DrawTriangle(top_left, bottom_left, top_right, raylib.RED)
	raylib.DrawTriangle(bottom_right, top_right, bottom_left, raylib.RED)
}

Triangle :: struct {
	a: raylib.Vector2,
	b: raylib.Vector2,
	c: raylib.Vector2,
}

draw_triangle :: proc(triangle: Triangle, transform: Transform) {
	a := raylib.Vector3Transform({triangle.a.x, triangle.a.y, 0}, transform).xy
	b := raylib.Vector3Transform({triangle.b.x, triangle.b.y, 0}, transform).xy
	c := raylib.Vector3Transform({triangle.c.x, triangle.c.y, 0}, transform).xy

	raylib.DrawTriangle(a, b, c, raylib.RED)
}

Circle :: struct {
	pos:    raylib.Vector2,
	radius: f32,
}

draw_circle :: proc(circle: Circle, transform: Transform) {
	center := raylib.Vector3Transform({circle.pos.x, circle.pos.y, 0}, transform).xy
	scaling := raylib.MatrixToFloatV(transform)[0]
	radius := circle.radius * scaling
	// TODO: should handle non uniform scaling
	raylib.DrawCircle(i32(center.x), i32(center.y), circle.radius, raylib.RED)
}

// TODO: add bezier path


Shape :: union {
	Rectangle,
	Triangle,
	Circle,
}

Object :: struct {
	id:        int,
	shape:     Shape,
	transform: raylib.Matrix,
	children:  [dynamic]^Object,
	parent:    ^Object,
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
			draw_rectangle(shape, transform)
		case Triangle:
			draw_triangle(shape, transform)
		case Circle:
			draw_circle(shape, transform)
		}
	}


	if object.children != nil {
		for child in object.children {
			draw_object(child, transform)
		}
	}
}
