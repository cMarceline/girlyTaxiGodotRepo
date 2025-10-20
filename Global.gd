extends Node


var lStick : Vector2 :
	get : return Vector2(
		Input.get_action_raw_strength("SteerL") - Input.get_action_raw_strength("SteerR"),
		Input.get_action_raw_strength("SteerU") - Input.get_action_raw_strength("SteerD")
	)

var rStick : Vector2 :
	get : return Vector2(
		Input.get_action_raw_strength("camL") - Input.get_action_raw_strength("camR"),
		Input.get_action_raw_strength("camU") - Input.get_action_raw_strength("camD")
	)


func _ready() -> void:
	Wwise.register_game_obj(self, self.name)
	Wwise.register_listener(self)
	
	_loadwwisebanks()
	
	if OS.has_feature("editor"):
		Wwise.post_event_id(AK.EVENTS.PLAYTESTTONE, self)
		print(OS.get_processor_name())
		print(RenderingServer.get_video_adapter_name())

# this just loads the wwise bank IDs so i can call the events i need
func _loadwwisebanks() -> void:
	Wwise.load_bank_id(AK.BANKS.TESTSOUNDBANK) # can probably delete this at some point
	Wwise.load_bank_id(AK.BANKS.SFXSOUNDBANK)
	Wwise.load_bank_id(AK.BANKS.MUSICSOUNDBANK)
	Wwise.load_bank_id(AK.BANKS.DIALOGUESOUNDBANK)
