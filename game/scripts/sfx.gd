extends Node
## Phát âm thanh nếu có file res://audio/<tên>.ogg (select, merge, spawn, error, coin, unlock).
## Chưa có file thì bỏ qua, không lỗi. Autoload: Sfx


func play(sound: String, pitch: float = 1.0) -> void:
	var path := "res://audio/%s.ogg" % sound
	if not ResourceLoader.exists(path):
		return
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.pitch_scale = pitch
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
