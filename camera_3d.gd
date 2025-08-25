extends Camera3D

func _process(delta: float) -> void:
	$"..".rotation.y = Input.get_action_raw_strength("camL") - Input.get_action_raw_strength("camR")
	$"..".rotation.x = Input.get_action_raw_strength("camU") - Input.get_action_raw_strength("camD")
