extends Node

var names:Array[String] = ["Pen", "Pineapple", "Apple", "SerGAY", "Lonselot", "Aboba", "Kampukter", "Rubilnik", "Volna", "Horse", "Pam pam pam", "REDISKAAA!!"]

var free_indexes:Array[int] = []
var currect_idx:int = 0

func create_part() -> Part:
	var result := Part.new()
	if free_indexes.size() > 0:
		result.id = free_indexes.pop_front()
	else :
		result.id = currect_idx
		currect_idx += 1
	result.name = names.pick_random()
	result.weight = 1
	result.color = Color(randf_range(0.3, 1.0), randf_range(0.3, 1.0), randf_range(0.3, 1.0))
	return result

func remove_part(part:Part) -> void:
	free_indexes.append(part.id)
