extends Control

signal winner_screen_clicked

var part_controller_scene:PackedScene = load("res://Scenes/PartController.tscn")
var time_to_change_color:float = 0.6

func _ready() -> void:
	
	if !DirAccess.dir_exists_absolute("user://saves/"):
		DirAccess.make_dir_absolute("user://saves")
	
	%TopSavePreset.get_popup().id_pressed.connect(func(id:int):
		var file := FileAccess.open("user://saves/save_"+str(id)+".sv", FileAccess.WRITE)
		if file and file.is_open():
			var data:Array[Dictionary] = []
			for part:Part in %Wheel.parts:
				data.append({
					"name": part.name,
					"weight": part.weight,
					"color": part.color.to_html(false)
				})
			file.store_string(JSON.stringify(data))
			file.close()
		else :
			print('ERROR 15')
	)
	
	%TopLoadPreset.get_popup().id_pressed.connect(func(id:int):
		var file = FileAccess.open("user://saves/save_"+str(id)+".sv", FileAccess.READ)
		if file and file.is_open():
			var data_string = file.get_as_text()
			file.close()
			var data = JSON.parse_string(data_string)
			if data is Array:
				if %PartsContainer.get_child_count() > 0:
					for PartCtrl in %PartsContainer.get_children():
						if ! (PartCtrl is PartController): continue
						%Wheel.remove_beauty_part(PartCtrl.linked_part)
						PartCtrl.queue_free()
				for row in data :
					#%Wheel.create_beauty_part(row.name, row.weight, row.color)
					add_part(row.name, row.weight, row.color)
					await get_tree().create_timer(0.05).timeout
			else :
				print("ERROR 16")
				print(data)
		else :
			print("ERROR 15")
	)
	
	%TopBarSettingsButton.pressed.connect(
		func() :
			$Settings.show()
	)
	
	%AddPart.pressed.connect(add_part)
	
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
	
	$WinnerScreen.gui_input.connect(func(e:InputEvent):
		if e is InputEventMouseButton and e.pressed:
			winner_screen_clicked.emit()
	)
	
	%StartWheel.pressed.connect(func():
		var win_score:float = randf()
		var current_score:float = 0.0
		var winner:Part
		for part:Part in %Wheel.parts:
			if win_score >= current_score and win_score <= (current_score + part.weight_linear):
				winner = part
				break
			current_score += part.weight_linear
		%Wheel.rotation -= PI*4*%SettingWheelRotationTime.value
		%WinnerText.material.set('shader_parameter/y_offset', 48)
		%ActualWinner.material.set('shader_parameter/y_offset', 64)
		%ActualWinner.text = '4a6=F#O31oaF4'
		var wheel_tween:Tween = create_tween()
		wheel_tween.tween_property(%Wheel, 'rotation', (win_score*PI*2)-(PI/2), %SettingWheelRotationTime.value).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.tween_callback($WinnerScreen.show)
		wheel_tween.tween_property($WinnerScreen/BG, 'color', Color(0,0,0,0.5), 0.7).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.tween_property(%WinnerText, 'modulate', Color.WHITE, 0.7).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.parallel().tween_property(%WinnerText.material, 'shader_parameter/y_offset', 24, 0.5).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.tween_interval(0.2)
		wheel_tween.tween_property(%ActualWinner, 'text', winner.name, 1.0).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.parallel().tween_property(%ActualWinner, 'modulate', Color.WHITE, 1.0).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.parallel().tween_property(%WinnerText.material, 'shader_parameter/y_offset', 0, 1.3).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.parallel().tween_property(%ActualWinner.material, 'shader_parameter/y_offset', 0, 1.3).set_trans(Tween.TRANS_CUBIC)
		await wheel_tween.finished
		await winner_screen_clicked
		wheel_tween = create_tween()
		wheel_tween.tween_property(%WinnerText.material, 'shader_parameter/y_offset', -32, 0.5).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.parallel().tween_property(%ActualWinner.material, 'shader_parameter/y_offset', -48, 0.5).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.parallel().tween_property(%WinnerText, 'modulate', Color(0,0,0,0), 0.5).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.parallel().tween_property(%ActualWinner, 'modulate', Color(0,0,0,0), 0.5).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.tween_interval(0.2)
		wheel_tween.tween_property($WinnerScreen/BG, 'color', Color(0,0,0,0), 0.7).set_trans(Tween.TRANS_CUBIC)
		wheel_tween.tween_callback($WinnerScreen.hide)
	)

func add_part(name_:String = '', weight_:float = 1.0, color_:Color = Color.TRANSPARENT) -> void:
	var new_part:Part = %Wheel.create_beauty_part(name_, weight_, color_)
	var new_part_controller := part_controller_scene.instantiate()
	new_part_controller.linked_part = new_part
	%PartsContainer.add_child(new_part_controller)
	new_part_controller.request_to_delete.connect(func():
		%Wheel.remove_beauty_part(new_part_controller.linked_part)
		new_part_controller.queue_free()
	)
