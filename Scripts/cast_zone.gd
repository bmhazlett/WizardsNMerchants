extends Area2D

var zone = true
var cards_in_zone = []

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
	SignalBus._on_zone_area_entered.emit(self)

func _on_area_exited(area):
	SignalBus._on_zone_area_exited.emit(self)

func _on_card_casted(area, zone):
	if zone == self:
		cards_in_zone.append(area)
		var i = 0
		while i < len(cards_in_zone):
			if cards_in_zone[i].location == 'zone':
				cards_in_zone[i].position = Vector2(self.position.x + (i * 120) - 350, self.position.y)
			i += 1

func _on_card_destroyed(card):
	var i = 0
	while i < len(cards_in_zone):
		if cards_in_zone[i] == card:
			cards_in_zone.remove_at(i)
			break
		i += 1
	i = 0
	while i < len(cards_in_zone):
		if cards_in_zone[i].location == 'zone':
			cards_in_zone[i].position = Vector2(self.position.x + (i * 120) - 350, self.position.y)
		i += 1
