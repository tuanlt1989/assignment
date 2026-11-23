extends Control
## Màn hình: chọn đội -> phòng draft -> kết quả (+ chia sẻ). UI dựng bằng code.

const UI := preload("res://scripts/ui.gd")
const GLASS := preload("res://scripts/glass.gdshader")
const PICK_DELAY := 0.45
const PAD := 28
const TICKER_LEN := 6
const POS_COLORS := {
	"QB": Color("f59e0b"), "RB": Color("22c55e"), "WR": Color("3b82f6"), "TE": Color("14b8a6"),
	"OT": Color("a78bfa"), "IOL": Color("8b5cf6"), "EDGE": Color("ef4444"), "DL": Color("f97316"),
	"LB": Color("eab308"), "CB": Color("06b6d4"), "S": Color("6366f1"),
}
const POS_NOTES := {
	"QB": ["Accurate from a clean pocket", "Big arm who creates off script"],
	"RB": ["Patient runner with burst", "Three-down back with reliable hands"],
	"WR": ["Crisp route runner", "Vertical threat who wins downfield"],
	"TE": ["Mismatch weapon in the slot", "Inline blocker with soft hands"],
	"OT": ["Smooth pass protector", "Road grader in the run game"],
	"IOL": ["Anchors well against power", "Athletic puller on the move"],
	"EDGE": ["Explosive first step", "Power rusher with long arms"],
	"DL": ["Disruptive interior penetrator", "Two-gap run stuffer"],
	"LB": ["Sideline-to-sideline range", "Downhill thumper against the run"],
	"CB": ["Sticky in man coverage", "Ball hawk in zone"],
	"S": ["Rangy center fielder", "Box safety who tackles well"],
}
const VERDICT_COLORS := {
	"Steal": Color("15803d"), "Solid": Color("64748b"), "Miss": Color("c2410c"), "Bust": Color("dc2626"),
}

var screen: Control
var state: String = ""
var rounds_choice: int = 3
var filter: String = "ALL"
var fast: bool = false
var _timer: float = 0.0

var round_label: Label
var clock_label: Label
var last_label: Label
var picks_label: Label
var skip_btn: Button
var ticker: HBoxContainer
var chips_box: HBoxContainer
var list: VBoxContainer
var sheet: Control
var field: Control


func _ready() -> void:
	var t := Theme.new()
	t.default_font = UI.BOLD
	t.default_font_size = 28
	theme = t
	var bg := ColorRect.new()
	bg.color = UI.BG
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	Draft.pick_made.connect(_on_pick_made)
	_show_team_select()


func _process(delta: float) -> void:
	if state != "room":
		return
	if Draft.is_done():
		_show_results()
		return
	if Draft.is_user_turn():
		return
	if fast:
		while not Draft.is_done() and not Draft.is_user_turn():
			Draft.make_pick(Draft.ai_choose())
		fast = false
		_refresh_room()
		_on_clock_fx()
		return
	_timer += delta
	if _timer >= PICK_DELAY:
		_timer = 0.0
		Draft.make_pick(Draft.ai_choose())


# ================= chọn đội =================

func _show_team_select() -> void:
	state = "select"
	var vb := _page()
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 4)
	vb.add_child(hv)
	hv.add_child(UI.display("Mock Draft GM", 84))
	hv.add_child(UI.label("Pick a team. Draft on your turn. Get graded.", 24, UI.MUTED, true))
	vb.add_child(_segmented(["1 round", "3 rounds", "7 rounds"], [1, 3, 7].find(rounds_choice), func(i: int):
		rounds_choice = [1, 3, 7][i]
		_show_team_select()))
	var quick := UI.outline_button("Quick draft  ·  random team", UI.TEXT, 80, 26)
	quick.pressed.connect(func(): _confirm_team(randi() % Draft.TEAMS.size()))
	vb.add_child(quick)
	var sc := _scroll()
	vb.add_child(sc)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 8)
	sc.add_child(col)
	col.add_child(_section("Teams · by draft slot", 0))
	for i in Draft.base_order:
		var team: int = i
		var b := _row_button(96, Draft.team_color(team))
		var row := _row_box(b)
		row.add_child(_badge(team, 52))
		var tv := VBoxContainer.new()
		tv.add_theme_constant_override("separation", 0)
		tv.mouse_filter = MOUSE_FILTER_IGNORE
		row.add_child(_expand(tv))
		tv.add_child(UI.label(Draft.team_name(team), 27))
		tv.add_child(UI.label("Needs " + ", ".join(Draft.team_needs_preview(team)), 21, UI.MUTED, true))
		row.add_child(UI.pill("#%d" % Draft.first_pick_of(team), UI.TEXT, 20))
		b.add_theme_stylebox_override("pressed", UI.box(Color(Draft.team_color(team), 0.25)))
		b.pressed.connect(func(): _confirm_team(team))
		col.add_child(b)


func _confirm_team(team: int) -> void:
	Draft.new_draft(rounds_choice, team)
	var vb := _sheet(Draft.team_color(team))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 18)
	vb.add_child(hb)
	hb.add_child(_badge(team, 84))
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", -6)
	hb.add_child(_expand(hv))
	hv.add_child(UI.label(Draft.TEAMS[team][0], 23, UI.MUTED, true))
	hv.add_child(UI.display(Draft.TEAMS[team][1], 64))
	vb.add_child(_stats([
		["#%d" % (Draft.next_user_pick() + 1), "First pick"],
		["%d" % rounds_choice, "Rounds"],
		[", ".join(Draft.needs[team]), "Team needs"],
	]))
	var go := UI.button("Start draft", UI.ACCENT, UI.BG, 96, 30)
	go.pressed.connect(func():
		_close_card()
		filter = "ALL"
		fast = false
		_timer = 0.0
		_show_draft_room())
	vb.add_child(go)


# ================= phòng draft =================

func _show_draft_room() -> void:
	state = "room"
	var vb := _page()
	vb.add_theme_constant_override("separation", 14)
	# header có màu đội
	var tp := _team_panel(Draft.team_color(Draft.user_team), 32, 18)
	vb.add_child(tp[0])
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 2)
	tp[1].add_child(hv)
	var tr := HBoxContainer.new()
	tr.add_theme_constant_override("separation", 12)
	hv.add_child(tr)
	tr.add_child(_badge(Draft.user_team, 40))
	tr.add_child(_expand(UI.label(Draft.team_name(Draft.user_team), 24)))
	picks_label = UI.label("", 22, UI.MUTED, true)
	picks_label.size_flags_vertical = SIZE_SHRINK_CENTER
	tr.add_child(picks_label)
	var cr := HBoxContainer.new()
	hv.add_child(cr)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", -4)
	cr.add_child(_expand(cv))
	round_label = UI.label("", 22, UI.MUTED, true)
	cv.add_child(round_label)
	clock_label = UI.display("", 58)
	cv.add_child(clock_label)
	skip_btn = UI.button("Skip ›", Color(0, 0, 0, 0), UI.ACCENT, 64, 26)
	skip_btn.size_flags_vertical = SIZE_SHRINK_CENTER
	skip_btn.pressed.connect(func(): fast = true)
	cr.add_child(skip_btn)
	# dải lượt chọn sắp tới
	field = _field_card(250)
	vb.add_child(field)
	ticker = HBoxContainer.new()
	ticker.add_theme_constant_override("separation", 8)
	vb.add_child(ticker)
	last_label = UI.label("", 22, UI.MUTED, true)
	last_label.visible = false
	# chip lọc vị trí
	var cs := ScrollContainer.new()
	cs.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	cs.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	cs.custom_minimum_size = Vector2(0, 60)
	vb.add_child(cs)
	chips_box = HBoxContainer.new()
	chips_box.add_theme_constant_override("separation", 8)
	cs.add_child(chips_box)
	_edge_fade(cs, true)
	# tiêu đề cột
	var cm := MarginContainer.new()
	cm.add_theme_constant_override("margin_left", 20)
	cm.add_theme_constant_override("margin_right", 20)
	vb.add_child(cm)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 14)
	cm.add_child(cols)
	cols.add_child(_expand(_section("Player", 0)))
	cols.add_child(_section("Scout grade", 0))
	var sc := _scroll()
	vb.add_child(sc)
	list = VBoxContainer.new()
	list.size_flags_horizontal = SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 10)
	sc.add_child(list)
	_refresh_room()


func _refresh_room() -> void:
	if state != "room":
		return
	var p := Draft.current
	picks_label.text = "Your picks %d/%d" % [Draft.team_picks(Draft.user_team).size(), Draft.rounds]
	if not Draft.is_done():
		round_label.text = "Pick %d  ·  Round %d" % [p + 1, p / Draft.PICKS_PER_ROUND + 1]
		var nx := Draft.next_user_pick()
		if not Draft.is_user_turn() and nx >= 0:
			round_label.text += "  ·  You pick in %d" % (nx - p)
	if Draft.is_user_turn():
		clock_label.text = "YOU'RE ON THE CLOCK"
		clock_label.add_theme_color_override("font_color", UI.ACCENT)
		skip_btn.visible = false
	elif not Draft.is_done():
		clock_label.text = "%s ON THE CLOCK" % Draft.TEAMS[Draft.team_on_clock()][1].to_upper()
		clock_label.add_theme_color_override("font_color", UI.TEXT)
		skip_btn.visible = Draft.next_user_pick() >= 0
	if Draft.picks.is_empty():
		last_label.text = "The draft is about to begin."
	else:
		var e: Dictionary = Draft.picks[-1]
		last_label.text = "Last pick: %s took %s, %s" % [Draft.TEAMS[e.team][1], e.player.name, e.player.pos]
	_refresh_ticker()
	_refresh_chips()
	_refresh_list()


## Thanh tiến trình các vòng: xong = xanh, đang chạy = viền vàng, chưa tới = xám.
func _refresh_ticker() -> void:
	for c in ticker.get_children():
		c.queue_free()
	if is_instance_valid(field):
		field.queue_redraw()
	var cur_round := mini(Draft.current / Draft.PICKS_PER_ROUND, Draft.rounds - 1)
	for r in Draft.rounds:
		if r > 0:
			var line := ColorRect.new()
			line.color = UI.ACCENT if r <= cur_round else Color(UI.INK, 0.12)
			line.custom_minimum_size = Vector2(0, 3)
			ticker.add_child(_expand(line))
		var step := VBoxContainer.new()
		step.add_theme_constant_override("separation", 2)
		ticker.add_child(step)
		var dot := PanelContainer.new()
		var done := r < cur_round
		var now := r == cur_round
		var sb := UI.box(UI.ACCENT if done else (UI.CARD if now else Color(UI.INK, 0.06)), 20, 0)
		if now:
			sb.set_border_width_all(3)
			sb.border_color = UI.GOLD
		dot.add_theme_stylebox_override("panel", sb)
		dot.custom_minimum_size = Vector2(40, 40)
		dot.size_flags_horizontal = SIZE_SHRINK_CENTER
		var n := UI.label("%d" % (r + 1), 20, UI.BG if done else (UI.TEXT if now else UI.MUTED))
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		n.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		dot.add_child(n)
		step.add_child(dot)
		if Draft.rounds <= 4:
			var l := UI.label("ROUND %d" % (r + 1), 15, UI.TEXT if now else UI.MUTED)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			step.add_child(l)


## Sân cỏ với áo đấu xếp theo đội hình: vị trí đã chọn = áo màu đội + họ cầu thủ,
## vị trí đang cần = áo viền vàng, còn lại = áo mờ.
const FORMATION := [
	["WR", 0.1, 0.15], ["OT", 0.3, 0.15], ["IOL", 0.5, 0.15], ["TE", 0.7, 0.15], ["WR", 0.9, 0.15],
	["QB", 0.38, 0.37], ["RB", 0.62, 0.37],
	["EDGE", 0.14, 0.62], ["DL", 0.38, 0.62], ["LB", 0.62, 0.62], ["EDGE", 0.86, 0.62],
	["CB", 0.2, 0.84], ["S", 0.5, 0.84], ["CB", 0.8, 0.84],
]


func _field_card(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	c.mouse_filter = MOUSE_FILTER_IGNORE
	c.draw.connect(func(): _draw_field(c))
	return c


func _draw_field(c: Control) -> void:
	var w := c.size.x
	var h := c.size.y
	var field_box := UI.box(Color("2f7a46"), 24, 0)
	c.draw_style_box(field_box, Rect2(Vector2.ZERO, c.size))
	for i in 6:
		if i % 2 == 0:
			c.draw_rect(Rect2(Vector2(w * i / 6.0, 0), Vector2(w / 6.0, h)), Color(1, 1, 1, 0.05))
	c.draw_line(Vector2(16, h * 0.5), Vector2(w - 16, h * 0.5), Color(1, 1, 1, 0.35), 2.0)
	# cầu thủ của bạn theo vị trí
	var mine := {}
	for e in Draft.team_picks(Draft.user_team):
		var pos: String = e.player.pos
		if not mine.has(pos):
			mine[pos] = []
		mine[pos].append(e.player.name.get_slice(" ", 1))
	var used := {}
	var needs: Array = Draft.needs[Draft.user_team]
	var team_col := Draft.team_color(Draft.user_team)
	var jw := minf(w * 0.055, h * 0.1)
	for slot in FORMATION:
		var pos: String = slot[0]
		var ctr := Vector2(w * float(slot[1]), h * float(slot[2]))
		var k: int = used.get(pos, 0)
		used[pos] = k + 1
		var names: Array = mine.get(pos, [])
		var filled := k < names.size()
		var col := team_col if filled else Color(1, 1, 1, 0.22)
		_draw_jersey(c, ctr, jw, col, pos in needs and not filled)
		var txt: String = names[k] if filled else pos
		var fs := int(clampf(h * 0.06, 13.0, 18.0))
		c.draw_string(UI.BOLD, ctr + Vector2(-60, jw * 0.75 + fs), txt, HORIZONTAL_ALIGNMENT_CENTER, 120, fs,
			Color.WHITE if filled else Color(1, 1, 1, 0.75))


func _draw_jersey(c: Control, ctr: Vector2, s: float, col: Color, need: bool) -> void:
	var pts := PackedVector2Array()
	for p in [[-0.28, -0.5], [-0.1, -0.5], [0.0, -0.4], [0.1, -0.5], [0.28, -0.5], [0.5, -0.28],
			[0.38, -0.1], [0.28, -0.18], [0.28, 0.5], [-0.28, 0.5], [-0.28, -0.18], [-0.38, -0.1], [-0.5, -0.28]]:
		pts.append(ctr + Vector2(p[0], p[1]) * s * 1.4)
	c.draw_colored_polygon(pts, col)
	if need:
		var loop := pts.duplicate()
		loop.append(pts[0])
		c.draw_polyline(loop, UI.GOLD, 3.0, true)


func _refresh_chips() -> void:
	for c in chips_box.get_children():
		c.queue_free()
	var nd: Array = Draft.needs[Draft.user_team]
	var opts: Array = ["ALL", "NEEDS"] + Draft.POSITIONS
	for o in opts:
		var key: String = o
		var on := key == filter
		var txt := "All" if key == "ALL" else ("Needs · %d" % nd.size() if key == "NEEDS" else key)
		var col: Color = POS_COLORS.get(key, UI.TEXT)
		var b := UI.button(txt, col if on else Color(UI.INK, 0.06), UI.BG if on else UI.TEXT, 56, 22)
		UI.style(b, col if on else Color(UI.INK, 0.06), UI.BG if on else UI.TEXT, 28)
		b.custom_minimum_size.x = 76
		b.pressed.connect(func():
			filter = key
			_refresh_chips()
			_refresh_list())
		chips_box.add_child(b)


func _refresh_list() -> void:
	for c in list.get_children():
		c.queue_free()
	var nd: Array = Draft.needs[Draft.user_team]
	var pool: Array = Draft.available.duplicate()
	pool.sort_custom(func(a, b): return a.grade > b.grade)
	var shown := 0
	for p in pool:
		if filter == "NEEDS" and p.pos not in nd:
			continue
		if filter != "ALL" and filter != "NEEDS" and p.pos != filter:
			continue
		shown += 1
		list.add_child(_featured_row(p, p.pos in nd) if shown == 1 else _player_row(p, shown, p.pos in nd))
		if shown >= 40:
			break
	if shown == 0:
		list.add_child(UI.label("No players left here.", 24, UI.MUTED, true))


func _player_row(p: Dictionary, idx: int, need: bool) -> Button:
	var b := _row_button(96)
	var row := _row_box(b)
	var info := VBoxContainer.new()
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_theme_constant_override("separation", 2)
	info.mouse_filter = MOUSE_FILTER_IGNORE
	row.add_child(_expand(info))
	info.add_child(UI.label(p.name, 28))
	var meta := HBoxContainer.new()
	meta.add_theme_constant_override("separation", 10)
	meta.mouse_filter = MOUSE_FILTER_IGNORE
	info.add_child(meta)
	meta.add_child(_pos_pill(p.pos, 17))
	meta.add_child(UI.label(p.college, 21, UI.MUTED, true))
	if need:
		meta.add_child(UI.pill("NEED", UI.INFO, 16, true))
	var g := UI.label("%.1f" % p.grade, 32)
	g.size_flags_vertical = SIZE_SHRINK_CENTER
	row.add_child(g)
	b.pressed.connect(func(): _open_card(p))
	return b


## Dòng nổi bật cho cầu thủ tốt nhất còn lại: to hơn, bo góc lớn, tên kiểu display.
func _featured_row(p: Dictionary, need: bool) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 124)
	b.focus_mode = FOCUS_NONE
	b.size_flags_horizontal = SIZE_EXPAND_FILL
	UI.style(b, Color("eaf2ec"), UI.TEXT, 28)
	var nsb: StyleBoxFlat = b.get_theme_stylebox("normal").duplicate()
	nsb.set_border_width_all(1)
	nsb.border_color = Color(POS_COLORS[p.pos], 0.5)
	b.add_theme_stylebox_override("normal", nsb)
	b.button_down.connect(UI.click)
	var row := _row_box(b)
	row.offset_left = 24
	row.offset_right = -24
	var info := VBoxContainer.new()
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_theme_constant_override("separation", 0)
	info.mouse_filter = MOUSE_FILTER_IGNORE
	row.add_child(_expand(info))
	info.add_child(UI.label("BEST AVAILABLE", 17, Color(POS_COLORS[p.pos], 0.95)))
	info.add_child(UI.display(p.name, 46))
	var meta := HBoxContainer.new()
	meta.add_theme_constant_override("separation", 10)
	meta.mouse_filter = MOUSE_FILTER_IGNORE
	info.add_child(meta)
	meta.add_child(_pos_pill(p.pos, 17))
	meta.add_child(UI.label(p.college, 21, UI.MUTED, true))
	if need:
		meta.add_child(UI.pill("NEED", UI.INFO, 16, true))
	var g := UI.display("%.1f" % p.grade, 64)
	g.size_flags_vertical = SIZE_SHRINK_CENTER
	row.add_child(g)
	b.pressed.connect(func(): _open_card(p))
	return b


func _open_card(p: Dictionary) -> void:
	var vb := _sheet()
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 0)
	vb.add_child(hv)
	var nh := HBoxContainer.new()
	nh.add_theme_constant_override("separation", 12)
	hv.add_child(nh)
	nh.add_child(UI.display(p.name, 58))
	nh.add_child(_pos_pill(p.pos, 20))
	if p.pos in Draft.needs[Draft.user_team]:
		nh.add_child(UI.pill("FILLS NEED", UI.INFO, 18, true))
	else:
		nh.add_child(UI.label("Doesn't fill a need", 20, UI.MUTED, true))
	hv.add_child(UI.label("%s  ·  Age %d  ·  #%d %s in class" % [p.college, p.age, Draft.pos_rank(p), p.pos], 23, UI.MUTED, true))
	vb.add_child(_stats([["%.1f" % p.grade, "Scout grade"], [_height(p.ht), "Height"], ["%d lb" % p.wt, "Weight"], ["%.2f" % p.forty, "40 yd"]]))
	# thanh kỹ năng
	var bars := VBoxContainer.new()
	bars.add_theme_constant_override("separation", 10)
	vb.add_child(bars)
	for tr in Draft.traits(p):
		var tv: int = tr[1]
		bars.add_child(_trait_bar(tr[0], tv, UI.GOOD if tv >= 75 else (Color("2563eb") if tv >= 60 else Color("94a3b8"))))
	var rep := _scout_report(p)
	var sg := GridContainer.new()
	sg.columns = 2
	sg.add_theme_constant_override("h_separation", 16)
	sg.add_theme_constant_override("v_separation", 6)
	vb.add_child(sg)
	for kv in [["STRENGTH", rep[0]], ["CONCERN", rep[1]], ["OUTLOOK", rep[2]]]:
		var k := UI.label(kv[0], 17, UI.MUTED)
		k.custom_minimum_size = Vector2(130, 0)
		sg.add_child(k)
		var v := UI.label(kv[1], 23, UI.TEXT, true)
		v.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.size_flags_horizontal = SIZE_EXPAND_FILL
		sg.add_child(v)
	var bh := HBoxContainer.new()
	bh.add_theme_constant_override("separation", 12)
	vb.add_child(bh)
	var back := UI.button("Back", Color(UI.INK, 0.08), UI.TEXT, 96, 28)
	back.size_flags_horizontal = SIZE_EXPAND_FILL
	back.size_flags_stretch_ratio = 0.45
	back.pressed.connect(_close_card)
	bh.add_child(back)
	var can := Draft.is_user_turn()
	var draft_btn := UI.button("Draft %s" % p.name.get_slice(" ", 1) if can else "Not your pick yet", UI.ACCENT, UI.BG, 96, 30)
	draft_btn.disabled = not can
	draft_btn.size_flags_horizontal = SIZE_EXPAND_FILL
	draft_btn.pressed.connect(func():
		_close_card()
		Draft.make_pick(p)
		_toast("You drafted %s" % p.name))
	bh.add_child(draft_btn)


func _trait_bar(trait_name: String, val: int, col: Color) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	var l := UI.label(trait_name, 21, UI.MUTED, true)
	l.custom_minimum_size = Vector2(150, 0)
	h.add_child(l)
	var bar := Control.new()
	bar.custom_minimum_size = Vector2(0, 12)
	bar.size_flags_horizontal = SIZE_EXPAND_FILL
	bar.size_flags_vertical = SIZE_SHRINK_CENTER
	var frac := float(val) / 99.0
	bar.draw.connect(func():
		bar.draw_rect(Rect2(Vector2.ZERO, bar.size), Color(UI.INK, 0.08))
		bar.draw_rect(Rect2(Vector2.ZERO, Vector2(bar.size.x * frac, bar.size.y)), col))
	h.add_child(bar)
	var v := UI.label("%d" % val, 22)
	v.custom_minimum_size = Vector2(40, 0)
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.add_child(v)
	return h


func _on_pick_made(_pick: int, team: int, player: Dictionary) -> void:
	if fast or state != "room":
		return
	Sfx.play("pick" if team == Draft.user_team else "tick", 0.0 if team == Draft.user_team else -14.0)
	if is_instance_valid(sheet) and team != Draft.user_team:
		_close_card()
		_toast("%s was just taken" % player.name)
	_refresh_room()
	if Draft.is_user_turn():
		_on_clock_fx()


func _on_clock_fx() -> void:
	if not Draft.is_user_turn():
		return
	Sfx.play("clock", -4.0)
	clock_label.pivot_offset = Vector2(0, clock_label.size.y / 2.0)
	var tw := clock_label.create_tween()
	tw.tween_property(clock_label, "scale", Vector2(1.05, 1.05), 0.12)
	tw.tween_property(clock_label, "scale", Vector2.ONE, 0.18)
	Input.vibrate_handheld(40)


# ================= kết quả =================

func _show_results() -> void:
	state = "results"
	_close_card()
	var g := Draft.team_grade(Draft.user_team)
	var lt: String = g.letter
	var vb := _page()
	vb.add_theme_constant_override("separation", 14)
	var mine := Draft.team_picks(Draft.user_team)
	# hero: nền pha màu đội
	var hp := _team_panel(Draft.team_color(Draft.user_team), 40, 20)
	vb.add_child(hp[0])
	var gh := HBoxContainer.new()
	gh.add_theme_constant_override("separation", 22)
	hp[1].add_child(gh)
	var letter := UI.display(lt, 150, _tier_color(lt))
	gh.add_child(letter)
	var gv := VBoxContainer.new()
	gv.alignment = BoxContainer.ALIGNMENT_CENTER
	gv.add_theme_constant_override("separation", 2)
	gh.add_child(_expand(gv))
	gv.add_child(UI.display(Draft.TEAMS[Draft.user_team][1], 44))
	gv.add_child(UI.label("Class ranked #%d of 32" % _league_rank(Draft.user_team), 23, UI.MUTED, true))
	var why := UI.label(_grade_reason(), 23, UI.TEXT, true)
	why.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	gv.add_child(why)
	_stamp(letter)

	var sc := _scroll()
	vb.add_child(sc)
	var lv := VBoxContainer.new()
	lv.size_flags_horizontal = SIZE_EXPAND_FILL
	lv.add_theme_constant_override("separation", 8)
	sc.add_child(lv)
	lv.add_child(_field_card(280))
	lv.add_child(_section("Your class", 12))
	var note := UI.label("Scout grade is the pre-draft board; true rating is revealed now. Scouting is noisy: nearly half of prospects land 3+ points off their grade.", 19, UI.MUTED, true)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lv.add_child(note)
	var delay := 0.5
	for e in mine:
		lv.add_child(_class_row(e, delay))
		delay += 0.08
	# mồi Pro (chưa mở bán)
	var pro := PanelContainer.new()
	var psb := UI.box(Color(UI.INK, 0.05), 20, 18)
	psb.set_border_width_all(1)
	psb.border_color = Color(UI.INK, 0.15)
	pro.add_theme_stylebox_override("panel", psb)
	lv.add_child(pro)
	var ph := HBoxContainer.new()
	ph.add_theme_constant_override("separation", 14)
	pro.add_child(ph)
	ph.add_child(UI.pill("PRO", UI.TEXT, 18, true))
	var pt := UI.label("See every team's full class and the picks that would have earned you an A.", 21, UI.TEXT, true)
	pt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ph.add_child(_expand(pt))
	var on_list := _pro_interest()
	var unlock := UI.button("On the list" if on_list else "Notify me", Color(UI.INK, 0.08), UI.TEXT, 56, 22)
	unlock.custom_minimum_size.x = 150
	unlock.disabled = on_list
	unlock.size_flags_vertical = SIZE_SHRINK_CENTER
	unlock.pressed.connect(func():
		_set_pro_interest()
		unlock.text = "On the list"
		unlock.disabled = true
		_toast("We'll let you know when Pro launches"))
	ph.add_child(unlock)
	lv.add_child(_section("League leaderboard", 20))
	var ranked := _ranked_teams()
	for t in ranked.slice(0, 3):
		lv.add_child(_board_row(t, ranked))
	# dòng của bạn luôn hiện (ghim ngoài vùng cuộn)
	if ranked.find(Draft.user_team) >= 3:
		vb.add_child(_board_row(Draft.user_team, ranked))
	# hành động
	var share := UI.button("Share grade", UI.ACCENT, UI.BG, 96, 30)
	share.pressed.connect(_open_share)
	vb.add_child(share)
	var bh := HBoxContainer.new()
	bh.add_theme_constant_override("separation", 12)
	vb.add_child(bh)
	var same := UI.outline_button("Same team", UI.TEXT, 72, 24)
	same.size_flags_horizontal = SIZE_EXPAND_FILL
	same.pressed.connect(func():
		Draft.shuffle_order()
		Draft.new_draft(Draft.rounds, Draft.user_team)
		filter = "ALL"
		fast = false
		_timer = 0.0
		_show_draft_room())
	bh.add_child(same)
	var again := UI.outline_button("New draft", UI.TEXT, 72, 24)
	again.size_flags_horizontal = SIZE_EXPAND_FILL
	again.pressed.connect(func():
		Draft.shuffle_order()
		_show_team_select())
	bh.add_child(again)


func _board_row(t: int, ranked: Array) -> PanelContainer:
	var mine_row: bool = t == Draft.user_team
	var tc := PanelContainer.new()
	var tsb := UI.box(UI.CARD, 14, 14)
	if mine_row:
		tsb.set_border_width_all(2)
		tsb.border_color = Draft.team_color(t)
	tc.add_theme_stylebox_override("panel", tsb)
	var th := HBoxContainer.new()
	th.add_theme_constant_override("separation", 14)
	tc.add_child(th)
	th.add_child(UI.label("#%d" % (ranked.find(t) + 1), 22, UI.MUTED, true))
	th.add_child(_badge(t, 36))
	th.add_child(_expand(UI.label(("You · " + Draft.team_name(t)) if mine_row else Draft.team_name(t), 23)))
	var tl: String = Draft.team_grade(t).letter
	th.add_child(UI.label(tl, 26, _tier_color(tl)))
	return tc


func _class_row(e: Dictionary, delay: float) -> PanelContainer:
	var pl: Dictionary = e.player
	var tr := Draft.true_rating(pl)
	var vd := Draft.verdict(pl)
	var vcol: Color = VERDICT_COLORS[vd]
	var card := PanelContainer.new()
	var csb := UI.box(UI.CARD, 16, 16)
	if vd == "Steal" or vd == "Bust":
		csb.border_width_left = 6
		csb.border_color = vcol
	card.add_theme_stylebox_override("panel", csb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	card.add_child(row)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 2)
	row.add_child(_expand(info))
	var nr := HBoxContainer.new()
	nr.add_theme_constant_override("separation", 10)
	info.add_child(nr)
	nr.add_child(UI.label(pl.name, 26))
	nr.add_child(_pos_pill(pl.pos, 16))
	var ml := UI.label("", 21, UI.MUTED, true)
	info.add_child(ml)
	var base_txt := "Pick %d  ·  Scout %.1f → True " % [e.pick + 1, pl.grade]
	ml.text = base_txt + "…"
	var vv := VBoxContainer.new()
	vv.alignment = BoxContainer.ALIGNMENT_CENTER
	vv.add_theme_constant_override("separation", 4)
	row.add_child(vv)
	var pill := UI.pill(vd.to_upper(), vcol, 17, false, true)
	pill.size_flags_horizontal = SIZE_SHRINK_END
	vv.add_child(pill)
	var dl := UI.label("%+.1f" % (tr - pl.grade), 20, vcol, true)
	dl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vv.add_child(dl)
	# lộ diện lần lượt + số chạy
	card.modulate.a = 0.0
	var tw := card.create_tween()
	tw.tween_interval(delay)
	tw.tween_property(card, "modulate:a", 1.0, 0.25)
	tw.tween_method(func(v: float): ml.text = base_txt + "%.1f" % v, pl.grade, tr, 0.6).set_ease(Tween.EASE_OUT)
	if vd == "Steal":
		tw.tween_callback(func():
			Sfx.play("steal", -4.0)
			Input.vibrate_handheld(30))
	return card


func _stamp(letter: Label) -> void:
	letter.pivot_offset = Vector2(50, 100)
	letter.scale = Vector2(2.2, 2.2)
	letter.modulate.a = 0.0
	var st := letter.create_tween().set_parallel()
	st.tween_property(letter, "modulate:a", 1.0, 0.18)
	st.tween_property(letter, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	st.chain().tween_callback(func():
		Sfx.play("stamp")
		Input.vibrate_handheld(35))
	st.chain().tween_property(letter, "scale", Vector2(1.06, 1.06), 0.06)
	st.chain().tween_property(letter, "scale", Vector2.ONE, 0.1)


# ================= chia sẻ =================

func _share_text() -> String:
	var g := Draft.team_grade(Draft.user_team)
	var lines: Array[String] = []
	lines.append("I drafted for the %s and got a %s (class #%d of 32) in Mock Draft GM." % [
		Draft.team_name(Draft.user_team), g.letter, _league_rank(Draft.user_team)])
	for e in Draft.team_picks(Draft.user_team):
		lines.append("#%d %s, %s — %s" % [e.pick + 1, e.player.name, e.player.pos, Draft.verdict(e.player)])
	return "\n".join(lines)


func _open_share() -> void:
	var vb := _sheet()
	vb.add_child(UI.display("Share your grade", 52))
	# thẻ xem trước
	var card := PanelContainer.new()
	var col := Draft.team_color(Draft.user_team)
	var csb := UI.box(Color("123d27"), 24, 30)
	csb.set_border_width_all(3)
	csb.border_color = UI.GOLD
	card.add_theme_stylebox_override("panel", csb)
	vb.add_child(card)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 6)
	card.add_child(cv)
	cv.add_child(UI.display("Mock Draft GM  ·  Football Draft", 28, UI.GOLD))
	var gr := HBoxContainer.new()
	gr.add_theme_constant_override("separation", 20)
	cv.add_child(gr)
	gr.add_child(_badge(Draft.user_team, 96))
	var lt: String = Draft.team_grade(Draft.user_team).letter
	gr.add_child(UI.display(lt, 150, Color.WHITE))
	cv.add_child(UI.display(Draft.team_name(Draft.user_team), 44, UI.GOLD))
	cv.add_child(UI.label("Class ranked #%d of 32  ·  Can you beat my draft?" % _league_rank(Draft.user_team), 22, Color(1, 1, 1, 0.7), true))
	for e in Draft.team_picks(Draft.user_team).slice(0, 4):
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", 10)
		cv.add_child(r)
		r.add_child(UI.label("#%d" % (e.pick + 1), 21, Color(1, 1, 1, 0.6), true))
		r.add_child(_expand(UI.label(e.player.name, 23, Color.WHITE)))
		var vd := Draft.verdict(e.player)
		r.add_child(UI.pill(vd.to_upper(), VERDICT_COLORS[vd], 16, false, true))
	var bh := HBoxContainer.new()
	bh.add_theme_constant_override("separation", 12)
	vb.add_child(bh)
	var copy := UI.button("Copy", Color(UI.INK, 0.08), UI.TEXT, 88, 26)
	copy.size_flags_horizontal = SIZE_EXPAND_FILL
	copy.size_flags_stretch_ratio = 0.5
	copy.pressed.connect(func():
		DisplayServer.clipboard_set(_share_text())
		_toast("Copied to clipboard"))
	bh.add_child(copy)
	var post := UI.button("Post on X", UI.ACCENT, UI.BG, 88, 28)
	post.size_flags_horizontal = SIZE_EXPAND_FILL
	post.pressed.connect(func(): OS.shell_open("https://x.com/intent/post?text=" + _share_text().uri_encode()))
	bh.add_child(post)


# ================= tiện ích =================

func _page() -> VBoxContainer:
	if is_instance_valid(screen):
		screen.queue_free()
	var m := MarginContainer.new()
	m.set_anchors_preset(PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", PAD)
	m.add_theme_constant_override("margin_right", PAD)
	m.add_theme_constant_override("margin_top", 32)
	m.add_theme_constant_override("margin_bottom", 28)
	add_child(m)
	screen = m
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 18)
	m.add_child(vb)
	return vb


## Bottom sheet chung: nền mờ 70%, tay kéo, chạm ngoài để đóng. tint = viền màu đội phía trên.
func _sheet(tint: Color = Color(0, 0, 0, 0)) -> VBoxContainer:
	_close_card()
	var dim := ColorRect.new()
	dim.color = Color(UI.INK, 1)
	var gm := ShaderMaterial.new()
	gm.shader = GLASS
	dim.material = gm
	dim.set_anchors_preset(PRESET_FULL_RECT)
	dim.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			_close_card())
	dim.z_index = 5
	add_child(dim)
	sheet = dim
	var panel := PanelContainer.new()
	panel.set_anchors_preset(PRESET_BOTTOM_WIDE)
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var pb := UI.box(UI.CARD, 32, 0)
	pb.corner_radius_bottom_left = 0
	pb.corner_radius_bottom_right = 0
	pb.shadow_size = 0
	if tint.a > 0:
		pb.border_width_top = 4
		pb.border_color = tint
		panel.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
		var g := Gradient.new()
		g.set_color(0, Color(tint, 0.30))
		g.set_color(1, Color(tint, 0.0))
		var gt := GradientTexture2D.new()
		gt.gradient = g
		gt.fill_from = Vector2(0, 0)
		gt.fill_to = Vector2(0.6, 1)
		var tex := TextureRect.new()
		tex.texture = gt
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_SCALE
		tex.mouse_filter = MOUSE_FILTER_IGNORE
		panel.add_child(tex)
	panel.add_theme_stylebox_override("panel", pb)
	dim.add_child(panel)
	var pm := MarginContainer.new()
	pm.add_theme_constant_override("margin_left", 28)
	pm.add_theme_constant_override("margin_right", 28)
	pm.add_theme_constant_override("margin_top", 16)
	pm.add_theme_constant_override("margin_bottom", 36)
	panel.add_child(pm)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 20)
	pm.add_child(vb)
	var handle := Panel.new()
	handle.custom_minimum_size = Vector2(56, 6)
	handle.size_flags_horizontal = SIZE_SHRINK_CENTER
	handle.add_theme_stylebox_override("panel", UI.box(Color(UI.INK, 0.2), 3, 0))
	vb.add_child(handle)
	dim.modulate.a = 0.0
	dim.create_tween().tween_property(dim, "modulate:a", 1.0, 0.15)
	# trượt lên kiểu lò xo sau khi bố cục xong
	get_tree().process_frame.connect(func():
		if not is_instance_valid(panel):
			return
		var y := panel.position.y
		panel.position.y = y + 220.0
		panel.create_tween().tween_property(panel, "position:y", y, 0.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT), CONNECT_ONE_SHOT)
	return vb


func _close_card() -> void:
	if is_instance_valid(sheet):
		sheet.queue_free()
	sheet = null


func _stats(items: Array) -> HBoxContainer:
	var grid := HBoxContainer.new()
	grid.add_theme_constant_override("separation", 12)
	for kv in items:
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 0)
		grid.add_child(_expand(cell))
		var v := UI.label(kv[0], 30)
		v.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cell.add_child(v)
		cell.add_child(UI.label(kv[1], 20, UI.MUTED, true))
	return grid


func _segmented(options: Array, selected: int, on_select: Callable) -> PanelContainer:
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", UI.box(UI.CARD, 16, 6))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 6)
	pc.add_child(hb)
	for i in options.size():
		var idx: int = i
		var on := idx == selected
		var b := UI.button(options[idx], UI.ACCENT if on else Color(0, 0, 0, 0), UI.BG if on else UI.MUTED, 60, 22)
		b.size_flags_horizontal = SIZE_EXPAND_FILL
		b.clip_text = true
		b.pressed.connect(func(): on_select.call(idx))
		hb.add_child(b)
	return pc


func _row_button(h: float, edge: Color = Color(0, 0, 0, 0)) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, h)
	b.focus_mode = FOCUS_NONE
	b.size_flags_horizontal = SIZE_EXPAND_FILL
	UI.style(b, UI.CARD, UI.TEXT)
	b.button_down.connect(UI.click)
	if edge.a > 0:
		b.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
		var stripe := ColorRect.new()
		stripe.color = edge
		stripe.mouse_filter = MOUSE_FILTER_IGNORE
		stripe.anchor_bottom = 1.0
		stripe.offset_right = 6
		b.add_child(stripe)
	return b


func _row_box(b: Button) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.set_anchors_preset(PRESET_FULL_RECT)
	row.offset_left = 20
	row.offset_right = -20
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = MOUSE_FILTER_IGNORE
	b.add_child(row)
	return row


func _expand(c: Control) -> Control:
	c.size_flags_horizontal = SIZE_EXPAND_FILL
	c.size_flags_vertical = SIZE_SHRINK_CENTER
	return c


func _scroll() -> ScrollContainer:
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_edge_fade(sc, false)
	return sc


## Mờ dần ở mép cuối của vùng cuộn (đáy, hoặc mép phải nếu horizontal).
func _edge_fade(sc: ScrollContainer, horizontal: bool) -> void:
	var g := Gradient.new()
	g.set_color(0, Color(UI.BG, 0.0))
	g.set_color(1, UI.BG)
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(1, 0) if horizontal else Vector2(0, 1)
	var fade := TextureRect.new()
	fade.texture = gt
	fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	fade.mouse_filter = MOUSE_FILTER_IGNORE
	fade.top_level = true
	fade.z_index = 1
	sc.add_child(fade)
	var place := func():
		if horizontal:
			fade.global_position = sc.global_position + Vector2(sc.size.x - 40, 0)
			fade.size = Vector2(40, sc.size.y)
		else:
			fade.global_position = sc.global_position + Vector2(0, sc.size.y - 64)
			fade.size = Vector2(sc.size.x, 64)
	sc.resized.connect(place)
	sc.item_rect_changed.connect(place)


## Thẻ có lớp màu đội: nền navy + gradient màu đội 28%→0% + viền trên, được cắt theo góc bo.
func _team_panel(col: Color, radius: int, margin: int) -> Array:
	var pc := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UI.CARD
	sb.set_corner_radius_all(radius)
	sb.border_width_top = 3
	sb.border_color = col
	sb.anti_aliasing = true
	pc.add_theme_stylebox_override("panel", sb)
	pc.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	var g := Gradient.new()
	g.set_color(0, Color(col, 0.30))
	g.set_color(1, Color(col, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0.9, 1)
	var tex := TextureRect.new()
	tex.texture = gt
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	tex.mouse_filter = MOUSE_FILTER_IGNORE
	pc.add_child(tex)
	var m := MarginContainer.new()
	for k in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		m.add_theme_constant_override(k, margin)
	pc.add_child(m)
	return [pc, m]


## Tiêu đề mục: chữ hoa, cách trên `top` px.
func _section(text: String, top: int = 24) -> Label:
	var l := UI.label(text.to_upper(), 18, UI.MUTED)
	var sb := StyleBoxEmpty.new()
	sb.content_margin_top = maxi(0, top - 8)
	sb.content_margin_bottom = 4
	l.add_theme_stylebox_override("normal", sb)
	return l


func _pos_pill(pos: String, fs: int) -> PanelContainer:
	return UI.pill(pos, POS_COLORS.get(pos, UI.TEXT), fs)


## Logo đội dạng khiên: màu đội, dải sáng phía trên, chữ viết tắt font thể thao.
func _badge(t: int, d: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(d, d)
	c.size_flags_vertical = SIZE_SHRINK_CENTER
	c.mouse_filter = MOUSE_FILTER_IGNORE
	var col := Draft.team_color(t).darkened(0.2)
	var ab := Draft.team_abbr(t)
	c.draw.connect(func():
		var w := d * 0.86
		var x0 := (d - w) / 2.0
		var pts := PackedVector2Array([
			Vector2(x0, d * 0.06), Vector2(x0 + w, d * 0.06), Vector2(x0 + w, d * 0.55),
			Vector2(d / 2.0, d * 0.97), Vector2(x0, d * 0.55)])
		c.draw_colored_polygon(pts, col.darkened(0.45))
		var inner := PackedVector2Array()
		for p in pts:
			inner.append(Vector2(d / 2.0, d * 0.48) + (p - Vector2(d / 2.0, d * 0.48)) * 0.86)
		c.draw_colored_polygon(inner, col)
		c.draw_rect(Rect2(x0 + w * 0.07, d * 0.11, w * 0.86, d * 0.1), col.lightened(0.25))
		var fs := int(d * 0.38)
		c.draw_string(UI.DISPLAY, Vector2(0, d * 0.62), ab, HORIZONTAL_ALIGNMENT_CENTER, d, fs, Color.WHITE))
	return c


func _toast(msg: String) -> void:
	var l := UI.label(msg, 26)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_stylebox_override("normal", UI.box(UI.INK, 16, 18))
	l.add_theme_color_override("font_color", UI.BG)
	l.z_index = 6
	add_child(l)
	l.size = Vector2(size.x - 2 * PAD, 0)
	l.position = Vector2(PAD, size.y - 140)
	var tw := l.create_tween()
	tw.tween_interval(1.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.3)
	tw.tween_callback(l.queue_free)


func _tint(c: Color, amount: float) -> Color:
	return UI.CARD.lerp(c, amount)


func _height(inches: int) -> String:
	return "%d'%d\"" % [inches / 12, inches % 12]


## Một dòng giải thích vì sao ra điểm này: giá trị so với bảng xếp hạng + kết quả thật.
func _grade_reason() -> String:
	var mine := Draft.team_picks(Draft.user_team)
	var value := 0
	var reach := 0
	var counts := {"Steal": 0, "Solid": 0, "Miss": 0, "Bust": 0}
	for e in mine:
		var d: int = e.pick + 1 - int(e.player.rank)
		if d >= 5:
			value += 1
		elif d <= -5:
			reach += 1
		counts[Draft.verdict(e.player)] += 1
	var parts: Array[String] = []
	if value > 0:
		parts.append("Value on %d pick%s" % [value, "" if value == 1 else "s"])
	if reach > 0:
		parts.append("reached on %d" % reach if value > 0 else "Reached on %d pick%s" % [reach, "" if reach == 1 else "s"])
	if parts.is_empty():
		parts.append("Picked on the board")
	var bits: Array[String] = []
	for k in ["Steal", "Solid", "Miss", "Bust"]:
		var n: int = counts[k]
		if n > 0:
			var word: String = k.to_lower()
			if n > 1 and k != "Solid":
				word += "es" if k == "Miss" else "s"
			bits.append("%d %s" % [n, word])
	return "%s\n%s" % [", ".join(parts), " · ".join(bits)]


func _pro_interest() -> bool:
	var cf := ConfigFile.new()
	return cf.load("user://prefs.cfg") == OK and bool(cf.get_value("pro", "notify", false))


func _set_pro_interest() -> void:
	var cf := ConfigFile.new()
	cf.load("user://prefs.cfg")
	cf.set_value("pro", "notify", true)
	cf.save("user://prefs.cfg")


func _tier_color(l: String) -> Color:
	if l.begins_with("A"):
		return UI.GOOD
	if l.begins_with("B"):
		return Color("2563eb")
	if l.begins_with("C"):
		return Color("b7791f")
	return UI.BAD


func _ranked_teams() -> Array:
	var ts: Array = range(Draft.TEAMS.size())
	ts.sort_custom(func(a, b): return Draft.team_grade(a).score > Draft.team_grade(b).score)
	return ts


func _league_rank(t: int) -> int:
	return _ranked_teams().find(t) + 1


## Trả về [điểm mạnh, điểm yếu, triển vọng].
func _scout_report(p: Dictionary) -> Array:
	var body: Array = Draft.POS_BODY[p.pos]
	var notes: Array = POS_NOTES[p.pos]
	var strength: String = notes[int(p.id) % notes.size()]
	var concern := "No major red flags"
	var fd: float = p.forty - float(body[2])
	if fd <= -0.06:
		strength += ", elite speed"
	elif fd >= 0.06:
		concern = "Lacks top-end speed"
	if p.ht - int(body[0]) >= 2:
		strength += ", prototypical length"
	elif p.ht - int(body[0]) <= -2:
		concern = "Undersized frame" if concern == "No major red flags" else concern + ", undersized"
	var outlook := "Depth and special teams contributor"
	if p.grade >= 80.0:
		outlook = "Day 1 starter with Pro Bowl upside"
	elif p.grade >= 70.0:
		outlook = "Projects as a quality starter"
	elif p.grade >= 62.0:
		outlook = "Developmental prospect with traits"
	return [strength, concern, outlook]
