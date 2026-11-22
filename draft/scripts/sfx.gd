extends Node
## Phát âm thanh res://audio/<tên>.wav (tap, tick, clock, pick, stamp, steal). Autoload: Sfx

var muted: bool = false


func play(sound: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if muted:
		return
	var path := "res://audio/%s.wav" % sound
	if not ResourceLoader.exists(path):
		return
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.volume_db = volume_db
	p.pitch_scale = pitch
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
