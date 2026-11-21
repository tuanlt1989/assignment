extends Control
## Màn hình chính: bàn ghép 5x6, nút sinh vật phẩm, thưởng quảng cáo. UI dựng bằng code.

const COLORS := [
	Color("2d3a4a"), Color("7fd1ff"), Color("5fe3c0"), Color("a8e063"), Color("ffe066"),
	Color("ffb347"), Color("ff7f6e"), Color("ff6fb5"), Color("c58bff"), Color("8c9bff"), Color("ffffff"),
]

var coins_label: Label
var income_label: Label
var toast_label: Label
var spawn_btn: Button
var cells: Array[Button] = []
var selected: int = -1
var _tick: float = 0.0


func _ready() -> void:
	_build_ui()
	GameState.coins_changed.connect(_refresh_hud)
	GameState.board_changed.connect(_refresh_board)
	Monetization.ad_rewarded.connect(func(r): _toast("+%d vàng (quảng cáo)" % r))
	var earned := GameState.claim_offline_earnings()
	if earned > 0:
		_toast("Khi bạn vắng mặt: +%d vàng" % earned)
	_refresh_hud(GameState.coins)
	_refresh_board()


func _process(delta: float) -> void:
	_tick += delta
	if _tick >= 1.0:
		_tick -= 1.0
		var inc := GameState.income_per_second()
		if inc > 0:
			GameState.add_coins(inc)


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("16202b")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 24
	root.offset_right = -24
	root.offset_top = 48
	root.offset_bottom = -24
	root.add_theme_constant_override("separation", 16)
	add_child(root)

	coins_label = Label.new()
	coins_label.add_theme_font_size_override("font_size", 48)
	root.add_child(coins_label)

	income_label = Label.new()
	income_label.add_theme_font_size_override("font_size", 24)
	root.add_child(income_label)

	toast_label = Label.new()
	toast_label.add_theme_font_size_override("font_size", 24)
	toast_label.modulate = Color("ffe066")
	root.add_child(toast_label)

	var grid := GridContainer.new()
	grid.columns = GameState.COLS
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(grid)
	for i in GameState.COLS * GameState.ROWS:
		var b := Button.new()
		b.custom_minimum_size = Vector2(120, 120)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 40)
		b.pressed.connect(_on_cell_pressed.bind(i))
		grid.add_child(b)
		cells.append(b)

	spawn_btn = Button.new()
	spawn_btn.custom_minimum_size = Vector2(0, 96)
	spawn_btn.add_theme_font_size_override("font_size", 32)
	spawn_btn.text = "Thêm vật phẩm (%d vàng)" % GameState.SPAWN_COST
	spawn_btn.pressed.connect(_on_spawn)
	root.add_child(spawn_btn)

	var ad_btn := Button.new()
	ad_btn.custom_minimum_size = Vector2(0, 96)
	ad_btn.add_theme_font_size_override("font_size", 32)
	ad_btn.text = "Xem quảng cáo nhận thưởng"
	ad_btn.pressed.connect(Monetization.show_rewarded_ad)
	root.add_child(ad_btn)

	var shop_btn := Button.new()
	shop_btn.custom_minimum_size = Vector2(0, 96)
	shop_btn.add_theme_font_size_override("font_size", 32)
	shop_btn.text = "Gói khởi đầu 4,99$ (giả lập)"
	shop_btn.pressed.connect(func(): Monetization.purchase("starter_pack"))
	root.add_child(shop_btn)


func _refresh_hud(coins: int) -> void:
	coins_label.text = "Vàng: %d" % coins
	income_label.text = "+%d / giây" % GameState.income_per_second()


func _refresh_board() -> void:
	for i in cells.size():
		var lv: int = GameState.board[i]
		var b := cells[i]
		b.text = "" if lv == 0 else str(lv)
		var sb := StyleBoxFlat.new()
		sb.bg_color = COLORS[lv]
		sb.set_corner_radius_all(16)
		if i == selected:
			sb.set_border_width_all(6)
			sb.border_color = Color.WHITE
		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_stylebox_override("hover", sb)
		b.add_theme_stylebox_override("pressed", sb)
		b.add_theme_color_override("font_color", Color("16202b") if lv > 0 else Color.WHITE)
	_refresh_hud(GameState.coins)


func _on_cell_pressed(i: int) -> void:
	if selected == -1:
		if GameState.board[i] > 0:
			selected = i
	elif selected == i:
		selected = -1
	else:
		if not GameState.try_merge(selected, i):
			# không ghép được: chuyển lựa chọn sang ô mới nếu có vật phẩm
			selected = i if GameState.board[i] > 0 else -1
		else:
			selected = -1
	_refresh_board()


func _on_spawn() -> void:
	if not GameState.spawn_item():
		_toast("Không đủ vàng hoặc bàn đã đầy")


func _toast(msg: String) -> void:
	toast_label.text = msg
	var t := create_tween()
	t.tween_interval(2.5)
	t.tween_callback(func(): toast_label.text = "")
