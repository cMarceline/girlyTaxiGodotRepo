extends Camera3D


func _process(delta: float) -> void:
	$"..".rotation.y = Global.rStick.x
	$"..".rotation.x = Global.rStick.y
