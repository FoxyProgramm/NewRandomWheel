extends Control

func _ready() -> void:
	%TopBarSettingsButton.pressed.connect(
		func() :
			$Settings.show()
	)
	
	%AddPart.pressed.connect( %Wheel.create_beauty_part )
	%RemovePart.pressed.connect( %Wheel.remove_beauty_part.bind(null, true) )
	
	%FunctionHUERedraw.pressed.connect(func ():
		%Wheel.hue_redraw(%FunctionHUEColor.color, %FunctionHUEStep.value)
		)
	%FunctionsRandomizeColors.pressed.connect( %Wheel.random_colors_redraw )
	
	var functions_popup:PopupMenu = %TopBarFunctionsButton.get_popup()
	for child:Window in $Functions.get_children():
		functions_popup.add_item(child.title)
	functions_popup.id_pressed.connect(func(idx:int):
		$Functions.get_child(idx).show()
		)
