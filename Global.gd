extends Node

func _ready() -> void:
	Wwise.register_game_obj(self, self.name)
	Wwise.register_listener(self)
	
	_loadwwisebanks()
	
	if OS.has_feature("editor"):
		Wwise.post_event_id(AK.EVENTS.UI_SHOPPURCHASE, self)

# this just loads the wwise bank IDs so i cna call the events i need, please ignore how long its gonna get lol
func _loadwwisebanks() -> void:
	Wwise.load_bank_id(AK.BANKS.TESTSOUNDBANK)
	Wwise.load_bank_id(AK.BANKS.SFXSOUNDBANK)
