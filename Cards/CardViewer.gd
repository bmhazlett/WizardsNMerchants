extends TextureRect

var card_id = 'Witch';
var curr_area = null
var card_name = ''
var cost = ''
var ability = ''
var card_class = ''
var type =  ''
var attack = ''
var hp = ''
var art = ''
var rarity = ''
var deck

# Called when the node enters the scene tree for the first time.
func _ready():
	print("IM READY IM READY")
	card_name = CardDB.CARD_DB[card_id]['Name']
	cost = CardDB.CARD_DB[card_id]['Cost']
	ability = CardDB.CARD_DB[card_id]['Ability']
	card_class = CardDB.CARD_DB[card_id]['Class']
	type =  CardDB.CARD_DB[card_id]['Type']
	attack = int(CardDB.CARD_DB[card_id]['Attack'])
	rarity = str(CardDB.CARD_DB[card_id]['Rarity'])
	hp = int(CardDB.CARD_DB[card_id]['HP'])
	art = CardDB.CARD_DB[card_id]['Art']

	var card_img = str("res://")
	if self.deck:
		var card_base = str("res://Sprites/New_Card_Back.png")
		$Control/Cost.visible = false
		$Control/Name.visible = false
		$Control/Ability.visible = false
		$Control/Type.visible = false
		$Control/Class.visible = false
		$Control/Attack.visible = false
		$Control/HP.visible = false
		$Image.visible = false
		$Control/Rarity.visible = false
		$Base.texture = load(card_base)

	card_img = str("res://", art)
	if card_img != 'res://':
		$Image.texture = load(card_img)

	$Control/Name.text = card_name
	$Control/Cost.text = cost
	$Control/Ability.text = ability
	$Control/Class.text = card_class
	$Control/Type.text = type
	$Control/Attack.text = str(attack)
	$Control/Rarity.text = str(rarity)

	if hp == 0:
		$Control/HP.text = ''
	else:
		$Control/HP.text = str(hp)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
