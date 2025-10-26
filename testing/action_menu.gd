extends VBoxContainer

var OPTIONS = ['ATTACK', 'BLOCK']
var card
var attack_button = preload("res://testing/attack_button.tscn")
var block_button = preload("res://testing/block_button.tscn")
var ability_button = preload("res://testing/ability_button.tscn")

var menu = true
# Called when the node enters the scene tree for the first time.
func _ready():
	for opt in OPTIONS:
		print(opt)
		var instance
		if 'Attack' in opt:
			instance = attack_button.instantiate()
		elif 'Block' in opt:
			instance = block_button.instantiate()
		elif 'Ability' in opt:
			instance = ability_button.instantiate()
		instance.text = opt
		add_child(instance)
	await get_tree().create_timer(.1).timeout
	SignalBus._on_destroy_menu.connect(_on_destroy_menu)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _button_pressed():
	print("Hello world!")
	# SignalBus._on_chose_attack.emit(card)
	self.queue_free()

func _on_destroy_menu():
	get_parent().menu_up = false
	UiVariables.mouse_busy = false
	self.queue_free()
	
