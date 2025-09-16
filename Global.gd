extends Node

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
