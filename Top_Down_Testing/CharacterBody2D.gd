extends CharacterBody2D

var input_dir
const tile_size = 16
var moving = false
var dialog_started = false
@onready var ray: RayCast2D = $RayCast2D
func _physics_process(delta):
	input_dir = Vector2.ZERO
	if Input.is_action_pressed("ui_down"):
		input_dir = Vector2(0,1)
		move()
	elif Input.is_action_pressed("ui_up"):
		input_dir = Vector2(0,-1)
		move()
	elif Input.is_action_pressed("ui_left"):
		input_dir = Vector2(-1,0)
		move()
	elif Input.is_action_pressed("ui_right"):
		input_dir = Vector2(1,0)
		move()
	#move_and_slide()
func _ready():
	SignalBus._on_dialog_end.connect(_on_dialog_end)

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_Z and event.pressed:
			if ray.is_colliding() and not dialog_started:
				SignalBus._on_dialog_start.emit("Hello World")
				dialog_started = true
				
	
func move():
	if input_dir and not dialog_started:
		ray.target_position = input_dir * (tile_size / 2)
		ray.force_raycast_update()
		if not moving and !ray.is_colliding():
			moving = true
			var tween = create_tween()
			tween.tween_property(self, "position", position + input_dir*tile_size, 0.35)
			tween.tween_callback(move_false)
			
func move_false():
	moving = false

func _on_dialog_end():
	dialog_started = false
