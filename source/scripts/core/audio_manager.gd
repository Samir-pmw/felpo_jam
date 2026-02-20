extends Node

var sfx_click = preload("res://assets/audio/sfx_batida_satisfatoria.wav")
var sfx_paint = preload("res://assets/audio/sfx_paint.ogg")

func play_click():
	var asp = AudioStreamPlayer.new()
	add_child(asp)
	asp.stream = sfx_click
	asp.bus = "Master" 
	asp.play()
	asp.finished.connect(asp.queue_free)

func play_tinta():
	var asp = AudioStreamPlayer.new()
	add_child(asp)
	asp.stream = sfx_paint
	asp.bus = "Master"
	asp.volume_db = -8  # um pouco mais baixo que o click
	asp.play()
	asp.finished.connect(asp.queue_free)
