extends Node

var sfx_click = preload("res://assets/audio/sfx_batida_satisfatoria.wav")

func play_click():
	var asp = AudioStreamPlayer.new()
	add_child(asp)
	asp.stream = sfx_click
	asp.bus = "Master" 
	asp.play()
	
	asp.finished.connect(asp.queue_free)
