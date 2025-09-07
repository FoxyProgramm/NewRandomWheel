extends Control

var part_controller_scene:PackedScene = load("res://Scenes/PartController.tscn")
var time_to_change_color:float = 0.6

func _ready() -> void:
	%TopBarSettingsButton.pressed.connect(
		func() :
			$Settings.show()
	)
	
	%AddPart.pressed.connect(func():
		var new_part:Part = %Wheel.create_beauty_part()
		var new_part_controller := part_controller_scene.instantiate()
		new_part_controller.linked_part = new_part
		%PartsContainer.add_child(new_part_controller)
		new_part_controller.request_to_delete.connect(func():
			%Wheel.remove_beauty_part(new_part_controller.linked_part)
			new_part_controller.queue_free()
			)
	)
	
	%FunctionHUERedraw.pressed.connect(func ():
		#%Wheel.hue_redraw(%FunctionHUEColor.color, %FunctionHUEStep.value)
		var wait_step: float = time_to_change_color / float( %Wheel.parts.size() )
		var hue_step:float = %FunctionHUEStep.value / float( %Wheel.parts.size() )
		var init_color :Color= %FunctionHUEColor.color
		for child:Control in %PartsContainer.get_children():
			if child is PartController:
				child.color_box.color = init_color
				child.ch_color_smooth(init_color)
				init_color.h += hue_step
				await get_tree().create_timer(wait_step).timeout
		)

	%FunctionsRandomizeColors.pressed.connect(func():
		var wait_step: float = time_to_change_color / float( %Wheel.parts.size() )
		for child:Control in %PartsContainer.get_children():
			if child is PartController:
				var init_color:=Color(randf_range(0.3, 1.0), randf_range(0.3, 1.0), randf_range(0.3, 1.0))
				child.color_box.color = init_color
				child.ch_color_smooth(init_color)
				await get_tree().create_timer(wait_step).timeout
	)
	
	var functions_popup:PopupMenu = %TopBarFunctionsButton.get_popup()
	for child:Window in $Functions.get_children():
		functions_popup.add_item(child.title)
	functions_popup.id_pressed.connect(func(idx:int): $Functions.get_child(idx).show() )
