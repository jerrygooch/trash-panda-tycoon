extends Control

# HUD — displays coins, timer, mess meter, round number during gameplay

@onready var _coins_label: Label = %CoinsLabel
@onready var _timer_label: Label = %TimerLabel
@onready var _mess_bar: ProgressBar = %MessBar
@onready var _mess_label: Label = %MessLabel
@onready var _round_label: Label = %RoundLabel


func update_display(coins: int, time_left: int, mess: int, max_mess: int, round_num: int) -> void:
	_coins_label.text = "\U0001FA99 " + str(coins)
	
	var mins: int = time_left / 60
	var secs: int = time_left % 60
	_timer_label.text = "\U000023F1 %02d:%02d" % [mins, secs]
	
	_mess_bar.max_value = max_mess
	_mess_bar.value = mess
	
	# Color the mess bar
	if mess >= max_mess:
		_mess_bar.modulate = Color.RED
	elif mess >= max_mess * 0.7:
		_mess_bar.modulate = Color.ORANGE
	else:
		_mess_bar.modulate = Color.GREEN
	
	_mess_label.text = "Mess: %d / %d" % [mess, max_mess]
	_round_label.text = "Round %d" % round_num
