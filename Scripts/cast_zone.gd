extends Area2D

var zone = true
var units_in_zone = []
var workers_in_zone = []
var count_units = 0
var count_workers = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.area_entered.connect(_on_area_entered)
	self.area_exited.connect(_on_area_exited)
	SignalBus._on_card_casted.connect(_on_card_casted)
	SignalBus._on_card_destroyed.connect(_on_card_destroyed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	SignalBus._on_zone_area_entered.emit(self, area)

func _on_area_exited(area):
	SignalBus._on_zone_area_exited.emit(self, area)

func update_card_locs():
	var i = 0
	var player_worker = 0
	var player_unit = 0
	var opponent_worker = 0
	var opponent_unit = 0
	var worker_offset = 40
	var width = $CollisionShape2D.shape.get_rect().size.x * self.scale.x
	var height = $CollisionShape2D.shape.get_rect().size.y * self.scale.y
	var worker_start_x = self.position.x - width / 2
	var row_len = 3
	while i < len(units_in_zone):
		if units_in_zone[i].location == 'play':
			if units_in_zone[i].opponent:
				units_in_zone[i].position = Vector2(self.position.x + (opponent_unit * 80) - 150, self.position.y + 10)
				opponent_unit += 1
			else:
				units_in_zone[i].position = Vector2(self.position.x + (player_unit * 80) - 150, self.position.y + 72)
				player_unit += 1
		i += 1

	i = 0
	while i < len(workers_in_zone):
		if workers_in_zone[i].location == 'play':
			if workers_in_zone[i].opponent:
				if opponent_worker < row_len:
					workers_in_zone[i].position = Vector2(worker_start_x + (opponent_worker % row_len * worker_offset), self.position.y - worker_offset / 2)
				else:
					workers_in_zone[i].position = Vector2(worker_start_x + (opponent_worker % row_len * worker_offset), self.position.y + worker_offset / 2)
				opponent_worker += 1
			else:
				if player_worker < row_len:
					workers_in_zone[i].position = Vector2(worker_start_x + (player_worker % row_len * worker_offset), self.position.y + 64 - worker_offset / 2)
				else:
					workers_in_zone[i].position = Vector2(worker_start_x + (player_worker % row_len * worker_offset), self.position.y + 64 + worker_offset / 2)
				player_worker += 1
		i += 1


func _on_card_casted(area, zone):
	if zone == self:
		if area.card_id == 'Worker':
			workers_in_zone.append(area)
			count_workers += 1
		elif area.type == 'Unit':
			units_in_zone.append(area)
			count_units += 1
		update_card_locs()

func _on_card_destroyed(card):
	var i = 0
	while i < len(workers_in_zone):
		if workers_in_zone[i] == card:
			count_workers -= 1
			workers_in_zone.remove_at(i)
			break
		i += 1
	i = 0
	while i < len(units_in_zone):
		if units_in_zone[i] == card:
			units_in_zone.remove_at(i)
			count_units -= 1
			break
		i += 1
	await get_tree().create_timer(1).timeout 
	update_card_locs()
