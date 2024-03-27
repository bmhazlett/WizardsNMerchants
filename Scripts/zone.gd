extends Area2D

var zone = true

# Called when the node enters the scene tree for the first time.
func _ready():
	self.area_entered.connect(_on_area_entered)
	self.area_exited.connect(_on_area_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	SignalBus._on_zone_area_entered.emit(area)

func _on_area_exited(area):
	SignalBus._on_zone_area_exited.emit(area)
	
