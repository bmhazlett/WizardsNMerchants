extends Node2D

var turn = 'Player';
var phase_index = 0;
var phases = ['Worker', 'Draw', 'Assign', 'Gather', 'Main', 'End']
var worker_card = preload("res://Cards/WorkerCard.tscn")
var unit_card = preload("res://Cards/UnitCard.tscn")
var start = 0;
var player_workers = []
var opponent_workers = []
var opponent = false
var action_queue = []
var queue_processing = false
var max_number_of_workers = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.pressed.connect(_on_button_press);
	SignalBus._on_action_sent_to_queue.connect(_on_action_sent_to_queue)
	SignalBus._on_phase_change.connect(_on_change_phase)
	SignalBus._on_game_end.connect(_on_game_end)
	StaticEffects._set_default()
	$WinLose.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var text_turn = ''
	if turn == 'Opponent':
		text_turn = 'Opp'
	else:
		text_turn = 'Play'
	$Label.text = text_turn + ':' + phases[phase_index]
	if !start:
		for i in range(4):
			draw_phase(1)
		turn = 'Opponent'
		for i in range(4):
			draw_phase(1)
		turn = 'Player'
		worker_phase()
		start = 1
	if len(action_queue) > 0 and !queue_processing:
		queue_processing = true
		print("Actions to Do: ", action_queue)
		_process_action(action_queue.pop_front())

func _on_game_end(winner):
	if winner == "player":
		GameVariables.player_money += 10
		if GameVariables.opponent == "1":
			GameVariables.opp_one_win = true
		elif GameVariables.opponent == "2":
			GameVariables.opp_two_win = true
		elif GameVariables.opponent == "3":
			GameVariables.opp_three_win = true
		$WinLose.text = "You Win! and Get 10$"
		$WinLose.visible = true
	else:
		$WinLose.text = "You Lose!"
		$WinLose.visible = true
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
	UiVariables.player_gold = 0
	UiVariables.player_arcane = 0
	UiVariables.player_gold_opponent = 0
	UiVariables.player_arcane_opponent = 0


func assign_phase():
	print('Assign')

func draw_phase(start):
	var draw_scene = preload('res://Abilities/Draw.tscn')
	var draw_instance = draw_scene.instantiate()
	get_parent().add_child(draw_instance)
	draw_instance.execute([1])
	draw_instance.queue_free()
	if not start:
		self._on_change_phase()

func worker_phase():
	if turn == 'Opponent' and len(opponent_workers) == max_number_of_workers:
		self._on_change_phase()
		return
	elif turn == 'Player' and len(player_workers) == max_number_of_workers:
		self._on_change_phase()
		return
	var instance = worker_card.instantiate()
	instance.card_id = 'Worker'
	var zone = get_parent().get_node('CastZone')
	if turn == 'Opponent':
		instance.opponent = true
		zone = get_parent().get_node('CastZone_Opponent')
	instance.location = 'play'
	instance.draggable = false
	get_parent().add_child(instance)
	if turn == 'Player':
		player_workers.append(instance)
	else:
		opponent_workers.append(instance)
	SignalBus._on_card_casted.emit(instance, zone)
	self._on_change_phase()

func end_phase():
	self._on_change_phase()

func gather_phase():
	var workers = player_workers
	if turn == 'Opponent':
		workers = opponent_workers

	var i = 0;
	while i < len(workers):
		var worker_card = workers[i]
		if worker_card.card_mode == 'Merchant':
			if worker_card.opponent:
				UiVariables.player_gold_opponent += 1
			else:
				UiVariables.player_gold += 1
		if worker_card.card_mode == 'Wizard':
			if worker_card.opponent:
				UiVariables.player_arcane_opponent += 1
			else:
				UiVariables.player_arcane += 1
		i += 1
	self._on_change_phase()

func _on_button_press():
	if turn == 'Player':
		self._on_change_phase()
	else:
		print("HEY ITS NOT YOUR TURN")
		#self._on_change_phase()

func _on_change_phase():
	if phase_index == len(phases) - 1:
		opponent = !opponent
		if turn == 'Player':
			turn = 'Opponent'
			$ButtonSprite.get_material().set_shader_parameter("onoff", 1.0)
		else:
			turn = 'Player'
			$ButtonSprite.get_material().set_shader_parameter("onoff", 0.0)
		SignalBus._on_turn_changed.emit()
	phase_index = (phase_index + 1) % len(phases)
	if phases[phase_index] == 'Worker':
		worker_phase()
	elif phases[phase_index] == 'Draw':
		draw_phase(0)
	elif phases[phase_index] == 'Assign':
		assign_phase()
	elif phases[phase_index] == 'Gather':
		gather_phase()
	elif phases[phase_index] == 'End':
		end_phase()
	
func _on_action_sent_to_queue(action):
	action_queue.append(action)

func _process_action(action):
	if len(action) < 2:
		queue_processing = false
		return
	# An Action must have the name, the input, and the related object
	var action_to_do = action[0]
	var action_input = action[1]
	var action_scene = load("res://Abilities/" + action_to_do + ".tscn")
	var action_instance = action_scene.instantiate()
	get_parent().add_child(action_instance)
	action_instance.execute(action_input)
	action_instance._free()
	queue_processing = false

func remove_worker(type, amount):
	var workers = player_workers
	if turn == 'Opponent':
		workers = opponent_workers
	var num_removed = 0
	var i = 0
	while i < len(workers) and num_removed < amount:
		if workers[i].card_mode == type:
			workers[i].queue_free()
			workers.remove_at(i)
			i = 0
			num_removed += 1
		i += 1
		
