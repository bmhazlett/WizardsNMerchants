extends Node2D

# key to target mapping
# Key is source object, target is list of tuple structured as (action, input, target)
var select_to_target_map
var ACTION_INDEX = 0
var INPUT_INDEX = 1
var TARGET_INDEX = 2
var source
var line = false
var curr_line = null
var target_line = preload("res://Scenes/target_line.tscn")
var action

# Called when the node enters the scene tree for the first time.
func _ready():
	self.select_to_target_map = {}
	SignalBus._on_card_selected.connect(_on_card_selected)
	SignalBus._on_card_targeted.connect(_on_card_targeted)
	SignalBus._on_card_successfully_targeted.connect(_on_card_successfully_targeted)
	SignalBus._on_card_deselected.connect(_on_card_deselected)
	if line:
		curr_line = target_line.instantiate()
		get_parent().add_child(curr_line)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_card_selected(card, action, action_input):
	if card in self.select_to_target_map:
		return
	self.source = card
	self.action = action
	self.select_to_target_map[self.source] = [action, [action_input, self.source]]
	print(self.select_to_target_map)
	
func _on_card_deselected(card):
	_resolve()

func _on_card_targeted(target):
	print("select to target map ", self.select_to_target_map)
	var action_scene = load("res://Abilities/" + self.action + ".tscn")
	var action_instance = action_scene.instantiate()
	get_parent().add_child(action_instance)
	var action_target_encoding = action_instance.TARGET_ENCODING
	# opponent
	# [all, opponents, own] - 0
	# [all, unit, player] - 0
	if !self._is_legal_target(self.source, target, action_target_encoding):
		return
	if !action_instance.is_legal_target(self.source, target):
		return
	if not self.select_to_target_map:
		return
	self.select_to_target_map[self.source][1].append(target)
	# SignalBus._on_card_deselected.emit(target)
	self.curr_line = null
	UiVariables.mouse_busy = false
	SignalBus._on_card_successfully_targeted.emit(self.source, target)

func _on_card_successfully_targeted(source, target):
	if source in self.select_to_target_map:
		print(source)
		SignalBus._on_action_sent_to_queue.emit(self.select_to_target_map[source])
		self.select_to_target_map.erase(source)
		SignalBus._on_card_deselected.emit(source)
		_resolve()

func _resolve():
	self.queue_free()

func _is_legal_target(source, target, encoding):
	var source_type = source.type
	var target_type = target.type
	var source_opp = source.opponent
	var target_opp = target.opponent
	var encoding_owner = encoding[0]
	var encoding_type = encoding[1]
	print("TARGET DETAILS: ", source_type, " ", target_type, " ", source_opp, " ", target_opp, " ", encoding_owner, " ", encoding_type)
	if target_type.to_lower() != encoding_type.to_lower() and encoding_type.to_lower() != 'all':
		return false
	if encoding_owner.to_lower() == 'opponent' and source_opp == target_opp:
		return false
	if encoding_owner.to_lower() == 'own' and source_opp != target_opp:
		return false
	return true

func _free():
	await get_tree().create_timer(1).timeout 
	self.queue_free()
	
