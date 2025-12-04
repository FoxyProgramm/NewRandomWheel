class_name PartController extends Control

signal request_to_delete

var linked_part:Part

@onready var weight_box:SpinBox          = $MC/HFC/WeightBlock/Weight
@onready var color_box:ColorPickerButton = $MC/HFC/ColorBlock/Color
@onready var label_name:LineEdit         = $MC/HFC/HBoxContainer/LineEdit

func _ready() -> void:
	if linked_part:
		$MC/HFC/DeleteButton.pressed.connect(request_to_delete.emit)
		label_name.text_changed.connect(func(text:String):
			linked_part.name = text
		)
		color_box.color = linked_part.color
		label_name.text = linked_part.name
		weight_box.value_changed.connect(func(value:float):
			if linked_part.weight_tween and linked_part.weight_tween.is_running(): linked_part.weight_tween.kill()
			linked_part.weight_tween = create_tween()
			linked_part.weight_tween.tween_property(linked_part, "weight", value, 0.6).set_trans(Tween.TRANS_QUAD)
			)
		color_box.color_changed.connect(ch_color_smooth)

func ch_color_smooth(color:Color) -> void:
	if linked_part.color_tween and linked_part.color_tween.is_running(): linked_part.color_tween.kill()
	linked_part.color_tween = create_tween()
	linked_part.color_tween.tween_property(linked_part, 'color', color, 0.6).set_trans(Tween.TRANS_QUAD)
