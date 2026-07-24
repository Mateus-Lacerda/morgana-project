extends RefCounted
class_name OrbIcon

## Miniaturas das orbes pra usar em menus/pergaminhos — sem PNG, é a própria
## forma (Polygon2D) que a orbe usa em jogo, só que pequena. Ver scenes/orbs/*.tscn.
const SHAPES := {
	&"orb_combo": {
		"polygon_flat": [8.0, 0.0, 5.6, 5.6, 0.0, 8.0, -5.6, 5.6, -8.0, 0.0, -5.6, -5.6, 0.0, -8.0, 5.6, -5.6],
		"color": Color(0.75, 0.9, 1, 0.95),
		"glow_color": Color(0.6, 0.85, 1, 0.35),
		"radius": 8.0,
	},
	&"orb_blade": {
		"polygon_flat": [
			8.0, 0.0, 10.666667, 2.0, 7.3333335, 3.3333335, 9.333334, 6.0, 5.6, 5.6,
			7.3333335, 9.333334, 3.3333335, 7.3333335, 2.0, 10.666667, 0.0, 8.0,
			-2.6666667, 10.666667, -3.3333335, 7.3333335, -6.666667, 9.333334, -5.6, 5.6,
			-9.333334, 7.3333335, -7.3333335, 3.3333335, -11.333334, 2.6666667, -8.0, 0.0,
			-11.333334, -2.6666667, -7.3333335, -3.3333335, -9.333334, -7.3333335, -5.6, -5.6,
			-6.666667, -10.0, -3.3333335, -7.3333335, -2.6666667, -11.333334, 0.0, -8.0,
			2.6666667, -10.666667, 3.3333335, -7.3333335, 6.666667, -9.333334, 5.6, -5.6,
			9.333334, -6.666667, 7.3333335, -3.3333335, 12.0, -3.3333335,
		],
		"color": Color(1, 0.15, 0.15, 0.95),
		"glow_color": Color(1, 0.2, 0.2, 0.35),
		"radius": 12.0,
	},
	&"orb_explosive": {
		"polygon_flat": [8.0, 0.0, 5.6, 5.6, 0.0, 8.0, -5.6, 5.6, -8.0, 0.0, -5.6, -5.6, 0.0, -8.0, 5.6, -5.6],
		"color": Color(1, 0.4, 0.05, 0.95),
		"glow_color": Color(1, 0.55, 0.1, 0.35),
		"radius": 8.0,
	},
}

static func _to_polygon(flat: Array) -> PackedVector2Array:
	var points := PackedVector2Array()
	var i := 0
	while i < flat.size():
		points.append(Vector2(flat[i], flat[i + 1]))
		i += 2
	return points

## Monta um Control quadrado de `diameter` px com a orbe desenhada por
## Polygon2D puro (mesma forma/cor da orbe real) — sem textura nenhuma.
static func build(kind_id: StringName, diameter: float) -> Control:
	var shape: Dictionary = SHAPES.get(kind_id, {})
	if shape.is_empty():
		return Control.new()

	var container := Control.new()
	container.custom_minimum_size = Vector2(diameter, diameter)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var pivot := Node2D.new()
	pivot.position = Vector2(diameter, diameter) / 2.0
	var mult: float = (diameter / 2.0) / float(shape.radius)
	pivot.scale = Vector2(mult, mult)
	container.add_child(pivot)

	var polygon := _to_polygon(shape.polygon_flat)

	var glow := Polygon2D.new()
	glow.polygon = polygon
	glow.color = shape.glow_color
	glow.scale = Vector2(1.8, 1.8)
	pivot.add_child(glow)

	var orb := Polygon2D.new()
	orb.polygon = polygon
	orb.color = shape.color
	pivot.add_child(orb)

	return container
