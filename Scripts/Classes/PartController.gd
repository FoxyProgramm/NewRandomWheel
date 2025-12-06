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

func appear(with_anim) -> void:
	if with_anim:
		create_tween().tween_property(self, 'modulate', Color.WHITE, 0.4).set_trans(Tween.TRANS_CUBIC)
	else :
		self.modulate = Color.WHITE

func ch_color_smooth(color:Color) -> void:
	if linked_part.color_tween and linked_part.color_tween.is_running(): linked_part.color_tween.kill()
	linked_part.color_tween = create_tween()
	linked_part.color_tween.tween_property(linked_part, 'color', color, 0.6).set_trans(Tween.TRANS_QUAD)

func die(with_anim:bool) -> void:
	if with_anim:
		$Blank.show()
		var actual_size = self.size
		self.custom_minimum_size = actual_size
		var tween := create_tween()
		tween.tween_property(self, 'modulate', Color.TRANSPARENT, 0.4).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback($MC.hide)
		tween.tween_property(self, 'custom_minimum_size', Vector2(0,0), 0.3).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
	call_deferred('queue_free')
