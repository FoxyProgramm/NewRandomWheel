extends Window

func _ready() -> void:
	self.close_requested.connect(hide)
