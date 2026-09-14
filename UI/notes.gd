class_name Notes
extends CanvasLayer

var buttons: Array

@onready var grid: GridContainer = $MarginContainer/GridContainer
@onready var note_text: RichTextLabel = $Note/VBoxContainer/ColorRect/MarginContainer/NoteText
@onready var note: MarginContainer = $Note


func _ready() -> void:
	set_visible(false)
	note.set_visible(false)
	buttons = grid.get_children()
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_button_pressed.bind(i))
	Events.collected.connect(_on_collected)


func reset_buttons() -> void:
	for button: Button in buttons:
		button.set_disabled(true)


func _on_button_pressed(idx: int) -> void:
	grid.set_visible(false)
	var new_text: String = ""
	match idx:
		0: new_text = "Sweetheart, if you've triggered an alarm, don't worry. It's just a new security system I've installed with the help of this neighbor. He told me he make this systems himself and he pack them with a lot of non-gov functionalities!"
		1: new_text = "Honey, be careful! The neighbor at position [3,2,6] broke into our home asking for sweet food. He smelled awful and I don't know how he entered without me opening the entrance portal. I yelled at him and after he ran out I fleed to my mom's."
		2: new_text = "Xarly, this guy is awesome and he understand us! His home shares wall with my bedroom, so he's from the inner side of the building and doesn't have sunlight either. He gave me this hacked system to create fully fake holograms. Think about how we can cheat with that in the lower levels."
		3: new_text = "POLICE REPORT: \nThis weirdo who lives up doesn't stop making noise late in the night and there's a leak that smells rotten because of him in my kitchen. Also, I believe he touched something about my high standing security system. He's obsessed with that."
	note_text.text = new_text
	note.set_visible(true)


func _on_collected(idx: int) -> void:
	buttons[idx].set_disabled(false)


func _on_back_button_pressed() -> void:
	grid.set_visible(true)
	note.set_visible(false)
