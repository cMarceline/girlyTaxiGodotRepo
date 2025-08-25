extends Node

func _ready() -> void:
	Wwise.register_game_obj(self, self.name)
	Wwise.register_listener(self)
	
	if OS.has_feature("editor"):
		Wwise.load_bank_id(AK.BANKS.TESTSOUNDBANK)
		Wwise.post_event_id(AK.EVENTS.PLAYTESTTONE, self)
