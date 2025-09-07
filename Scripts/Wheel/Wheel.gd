extends Node2D

#@export_tool_button("Redraw") var redraw = queue_redraw

const circumference:float = PI*2.0
var wheel_radius:float = 500

var polygon_step:float = 0.1

var parts:Array[Part] = []

func calculate_parts() -> void:
	var full_weight:float = 0
	for part in parts:
		full_weight += part.weight 
	for part in parts:
		part.weight_linear = part.weight / full_weight
	
	var current_position:float = 0
	for part in parts:
		var result:Array[Vector2] = [Vector2.ZERO]
		var current_step:float = 0
		var part_size:float = part.weight_linear * circumference
		while current_step < part_size:
			result.append( Vector2( sin(current_position + current_step), cos(current_position + current_step) )*wheel_radius )
			current_step += polygon_step
		current_position += part_size
		result.append( Vector2( sin(current_position), cos(current_position) )*wheel_radius )
		part.points = result
	
	queue_redraw()

func random_colors_redraw() -> void:
	var time_to_change:float = 0.6
	var time_for_part:float = time_to_change / float( parts.size() )
	for part in parts:
		var tween := create_tween()
		tween.tween_property(part, "color", Color(randf_range(0.3, 1.0), randf_range(0.3, 1.0), randf_range(0.3, 1.0)), time_to_change).set_trans(Tween.TRANS_QUAD)
		await get_tree().create_timer(time_for_part).timeout
		
func hue_redraw(color:Color, step:float) -> void:
	print('redraw')
	var time_to_change:float = 0.6
	var time_for_part:float = time_to_change / float( parts.size() )
	var step_for_part:float = step / float( parts.size() )
	print("Color: ", color)
	print("Step: ", step)
	for part in parts:
		var tween := create_tween()
		color.h += step_for_part
		tween.tween_property(part, "color", color, time_to_change).set_trans(Tween.TRANS_QUAD)
		await get_tree().create_timer(time_for_part).timeout

func create_beauty_part() -> Part:
	var new_part = Global.create_part()
	new_part.weight_changed.connect(calculate_parts)
	new_part.weight = 0.001
	parts.append(new_part)
	var tween := create_tween()
	tween.tween_property(new_part, "weight", 1, 0.6).set_trans(Tween.TRANS_CUBIC)
	return new_part

func remove_beauty_part(part:Part, last_one:bool = false) -> void:
	if last_one:
		if parts.size() == 1: return
		for i in range(parts.size()-1, 0, -1):
			if parts[i].on_delete: continue
			part = parts[i]
			part.on_delete = true
			break

	var tween := create_tween()
	tween.tween_property(part, "weight", 0.001, 0.6).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	parts.erase(part)
	part.weight_changed.disconnect(calculate_parts)
	Global.remove_part(part)
	calculate_parts()

func change_beauty_weight(part:Part, weight:float) -> void:
	if part.tween and part.tween.is_running(): part.tween.kill()
	part.tween = create_tween()
	part.tween.tween_property(part, "weight", weight, 0.6).set_trans(Tween.TRANS_QUAD)
	

#func _ready() -> void:
	#calculate_parts()

func _draw() -> void:
	for part in parts:
		if part.points.size() < 3: continue
		draw_colored_polygon(part.points, part.color)
