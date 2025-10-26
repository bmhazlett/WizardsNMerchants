extends Node

# Name: Amount
var collection = {"Wolf": 3, "Witch": 3, "Fulmen": 3, "Fortify Potion": 3, "Index": 3, "Snake": 3, "BannerMan": 3, "Sword": 3, "Shield": 3, "Squire": 3, "Fox": 3, "Wyrm": 3, "Owl": 3, "Rallier": 3, "Arcane Channeler": 3, "Crafty Cutpurse": 3}


var deck1 = {"Wolf": 3, "Owl": 3, "Fortify Potion": 3, "Squire": 3, "Snake": 3, "BannerMan": 3, "Sword": 3, "Shield": 3, "Witch": 1}
var deck1_class = "Knight"
var deck2 = {}
var deck2_class = "Rogue"
var deck3 = {}
var deck3_class = "Mage"
var curr_deck = deck1
var curr_deck_name = 'deck1'
var curr_class = deck1_class

var first_opp_deck = {"Wolf": 3, "Bear": 3, "Fortify Potion": 3, "Snake": 3, "Squire": 3, "BannerMan": 3, "Sword": 3, "Shield": 3, "Witch": 1}

var second_opp_deck = {"Witch": 3, "Crafty Cutpurse": 3, "Fortify Potion": 3, "Back ALley Bully": 3, "Disarm": 3, "Fox": 3, "Snake": 3, "Wolf": 3, "Turtle": 1}

var third_opp_deck = {"Wolf": 3, "Bear": 3, "Fulmen": 3, "Gather Knowledge": 3, "Index": 3, "Sword": 3, "Wyrm": 3, "Turtle": 3, "Fulmen Flash": 1}

# [{Name, Class, Cards}]
var player_decks = [{"Name": "Deck1", "Class": "Knight", "Cards": {"Wolf": 3, "Owl": 3, "Fortify Potion": 3, "Squire": 3, "Snake": 3, "BannerMan": 3, "Sword": 3, "Shield": 3, "Witch": 1}},
					{"Name": "Deck2", "Class": "Rogue", "Cards": {"Wolf": 3, "Owl": 3, "Fortify Potion": 3, "Fox": 3, "Snake": 3, "BannerMan": 3, "Sword": 3, "Shield": 3, "Witch": 1}}]

# Index of player_decks
var player_deck_index = 0

func _get_curr_deck_size():
	var size = 0
	for card in curr_deck:
		size += curr_deck[card]
	return size
	
