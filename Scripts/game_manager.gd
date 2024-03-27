extends Node2D

var turn = 'Player';
var phase_index = 0;
var phases = ['Worker', 'Draw', 'Assign', 'Gather', 'Main', 'End']
var card = preload("res://Scenes/card.tscn")
var start = 0;
var player_workers = []
var opponent_workers = []


# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.pressed.connect(_on_change_phase);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = turn + ':' + phases[phase_index]
	if !start:
		for i in range(4):
			draw_phase(1)
		turn = 'Opponent'
		for i in range(4):
			draw_phase(1)
		turn = 'Player'
			
		worker_phase()
		start = 1

func assign_phase():
	print('assign')

func draw_phase(start):
	var instance = card.instantiate()
	var size = CardDB.CARD_DB.size()
	var random_key = CardDB.CARD_DB.keys()[randi() % size]
	instance.card_id  = random_key
	if turn == 'Opponent':
		instance.opponent = true
	get_parent().add_child(instance)
	if not start:
		$Button.pressed.emit()

func worker_phase():
	if turn == 'Opponent' and len(opponent_workers) == 5:
		return
	elif turn == 'Player' and len(player_workers) == 5:
		return
	var instance = card.instantiate()
	instance.card_id = 'Worker'
	var zone = get_parent().get_node('CastZone_Worker')
	if turn == 'Opponent':
		instance.opponent = true
		zone = get_parent().get_node('CastZone_Worker_Opponent')
	instance.location = 'zone'
	instance.draggable = false
	instance.action = 'cast'
	get_parent().add_child(instance)
	if turn == 'Player':
		player_workers.append(instance)
	else:
		opponent_workers.append(instance)
	SignalBus._on_card_casted.emit(instance, zone)
	$Button.pressed.emit()

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
	$Button.pressed.emit()

func _on_change_phase():
	print(phases[phase_index])
	if phase_index == len(phases) - 1:
		if turn == 'Player':
			turn = 'Opponent'
		else:
			turn = 'Player'
	phase_index = (phase_index + 1) % len(phases)
	if phases[phase_index] == 'Worker':
		worker_phase()
	elif phases[phase_index] == 'Draw':
		draw_phase(0)
	elif phases[phase_index] == 'Assign':
		assign_phase()
	elif phases[phase_index] == 'Gather':
		gather_phase()
	
