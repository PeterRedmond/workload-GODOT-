extends Node


var player_name : String
var age : int
var water_overflow : int = 0
var water_underflow : int = 0
var moving_ball_stopped : int = 0
var lights_on : int = 0
var word_on_screen : int = 0
var number_on_screen : int = 0
var level_number = 0

func restart():
	water_overflow = 0
	water_underflow = 0
	moving_ball_stopped = 0
	lights_on = 0
	word_on_screen = 0
	number_on_screen = 0
