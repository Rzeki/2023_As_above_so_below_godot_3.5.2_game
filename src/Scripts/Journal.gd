extends Control

onready var pages = [$Evidence_and_Monsters, $Monster_info, $Menu]
onready var menu = $Menu
onready var evidence_and_monsters = $Evidence_and_Monsters
onready var sfx_player = get_node("Journal_sfx")

var sfx_page_turn = preload("res://assets/Music/page_turn.mp3")
var sfx_open = preload("res://assets/Music/open_journal.mp3")
var sfx_close = preload("res://assets/Music/journal_close.mp3")
var sfx_scribble = preload("res://assets/Music/scribble_journal.mp3")

var selected_monster
var monster
var player
var active_page
var selected_evidence = []
var menu_quotes = [
	"Alive yet?", 
	"What are you starring at?",
	"Feeling like you're beeing watched?", 
	"Don't look behind you", 
	"Did you hear that?", 
	"Abyss returns even the boldest gaze", 
	"Don't panic",
	"Why me?",
	"Too dark..."
	]



func _ready():
	randomize()
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("Monster"):
		monster = tree.get_nodes_in_group("Monster")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	active_page = 0
	var df = DynamicFont.new()
	var font = preload("res://assets/Fonts/Minecraft.ttf")
	df.size = 20
	df.font_data = font
	
	for e in monster.Evidences.keys():
		var btn = Button.new()
		btn.text = e
		btn.name = e
		btn.flat = true
		btn.focus_mode = 0
		btn.self_modulate = Color(0,0,0,1)
		btn.set("custom_fonts/font", df)
		btn.connect("pressed", self, "_button_pressed_evidence", [btn])
		$Evidence_and_Monsters/Evidence_grid.add_child(btn)
	
	for m in monster.Monsters.keys():
		var btn = Button.new()
		btn.text = m
		btn.name = m
		btn.flat = true
		btn.focus_mode = 0
		btn.self_modulate = Color(0,0,0,1)
		btn.set("custom_fonts/font", df)
		var btn2 = btn.duplicate()
		btn2.focus_mode = 0
		btn.connect("pressed", self, "_button_pressed_monster", [btn])
		btn2.connect("pressed", self, "_button_pressed_info", [btn2])
		$Evidence_and_Monsters/Monster_grid.add_child(btn)
		$Monster_info/Monster_grid.add_child(btn2)
	
func _physics_process(_delta: float) -> void:
	if !(monster and player):
		return
	
	pages[active_page].visible = monster.state != monster.States.ANGRY
	$Previous_page.visible = monster.state != monster.States.ANGRY
	$Next_page.visible = monster.state != monster.States.ANGRY
	$Youshouldrun.visible = monster.state == monster.States.ANGRY


func _on_Previous_page_pressed() -> void:
	$Journal_sfx.stream = sfx_page_turn
	$Journal_sfx.play()
	pages[active_page].visible = false
	active_page = posmod(active_page - 1, pages.size())


func _on_Next_page_pressed() -> void:
	$Journal_sfx.stream = sfx_page_turn
	$Journal_sfx.play()
	pages[active_page].visible = false
	active_page = 0 if active_page + 1 >= pages.size() else active_page + 1

func _button_pressed_monster(button: Button):
	if selected_monster != null:
		$Evidence_and_Monsters/Monster_grid.get_child(monster.Monsters.keys().find(selected_monster)).self_modulate.r = 0
	selected_monster = button.text
	button.self_modulate.r = 1
	
func _button_pressed_evidence(button: Button):
	if button.self_modulate.r == 1:
		button.self_modulate.r = 0
		selected_evidence.remove(selected_evidence.find(button,0))
	else:
		button.self_modulate.r = 1
		selected_evidence.append(button)
	for b in $Evidence_and_Monsters/Monster_grid.get_children():
			b.self_modulate.a = 1
	for btn in selected_evidence:
		for mon in monster.Monsters:
			if !monster.Monster_evidences[monster.Monsters[mon]].has(monster.Evidences[btn.text]):
				$Evidence_and_Monsters/Monster_grid.get_child(monster.Monsters[mon]).self_modulate.a = 0.5
			
	

func _button_pressed_info(button: Button):
	$Monster_info/M_name.bbcode_text = "[center]" + button.text + "[/center]"
	#MONSTER DESCRIPTION


func _on_Continue_pressed() -> void:
	self.visible = false


func _on_Restart_pressed() -> void:
	get_tree().change_scene("res://src/World.tscn")


func _on_Exit_pressed() -> void:
	get_tree().change_scene("res://src/Main_menu.tscn")


func _on_Menu_visibility_changed() -> void:
	$Menu/RichTextLabel.bbcode_text = "[center]" + menu_quotes[randi()%menu_quotes.size()] + "[/center]"
