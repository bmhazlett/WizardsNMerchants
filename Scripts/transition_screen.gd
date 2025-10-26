extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		SignalBus._on_transition_finshed.emit()
		animation_player.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		color_rect.visible = false
	
func transition():
	color_rect.visible = true
	animation_player.play("fade_to_black")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
