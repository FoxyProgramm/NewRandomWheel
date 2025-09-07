class_name Part extends Resource

signal weight_changed

@export var id:int
@export var name:String
@export var weight:float :
	set(value):
		weight = value
		weight_changed.emit()
@export var weight_linear:float
@export var color:Color :
	set(value):
		color = value
		weight_changed.emit()

var points:PackedVector2Array

var on_delete:bool = false

var weight_tween:Tween
var color_tween:Tween
