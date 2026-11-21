extends Control
## Màn hình: chọn đội -> phòng draft -> kết quả. UI dựng bằng code.

const UI := preload("res://scripts/ui.gd")
const FONT := preload("res://fonts/Roboto-Bold.ttf")
const C_BG := Color("0b1220")
const C_CARD := Color("17223b")
const C_ACCENT := Color("ffb020")
const C_GREEN := Color("22c55e")
const C_BLUE := Color("3b82f6")
const C_RED := Color("ef4444")
const C_MUTED := Color(1, 1, 1, 0.55)
const POS_COLORS := {
	"QB": Color("f59e0b"), "RB": Color("22c55e"), "WR": Color("3b82f6"), "TE": Color("14b8a6"),
	"OT": Color("b7791f"), "IOL": Color("9c4221"), "EDGE": Color("ef4444"), "DL": Color("c53030"),
	"LB": Color("8b5cf6"), "CB": Color("06b6d4"), "S": Color("6366f1"),
}
const PICK_DELAY := 0.4

var screen: Control
var state: String = ""
var rounds_choice: int = 3
var filter: String = "ALL"
var fast: bool = false
var _timer: float = 0.0

var clock_label: Label
var sub_label: Label
var needs_label: Label
var sim_btn: Button
var ticker: VBoxContainer
var list: VBoxContainer
var chips: Dictionary = {}
var sheet: Control


func _ready() -> void:
	var t := Theme.new()
	t.default_font = FONT
	t.default_font_size = 28
	theme = t
	var bg := ColorRect.new()
	bg.color = C_BG
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


# ---------- màn chọn đội ----------

func _show_team_select() -> void:
	state = "select"
	var vb := _page()
	vb.add_child(UI.label("MOCK DRAFT GM", 60, C_ACCENT))
	vb.add_child(UI.label("Pick your franchise. Build through the draft.", 26, C_MUTED))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 12)
	vb.add_child(hb)
	for r in [1, 3, 7]:
		var b := UI.button("%d Round%s" % [r, "" if r == 1 else "s"], C_BLUE if r == rounds_choice else C_CARD,
			Vector2(0, 72), 26)
		b.size_flags_horizontal = SIZE_EXPAND_FILL
		b.pressed.connect(func():
			rounds_choice = r
			_show_team_select())
		hb.add_child(b)
	var sc := _scroll()
	vb.add_child(sc)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	sc.add_child(grid)
	for i in Draft.TEAMS.size():
		var b := UI.button("", C_CARD, Vector2(0, 100))
		b.size_flags_horizontal = SIZE_EXPAND_FILL
		var row := _team_row(i)
		row.set_anchors_preset(PRESET_FULL_RECT)
		row.offset_left = 14
		b.add_child(row)
		b.pressed.connect(func(): _start(i))
		grid.add_child(b)


func _start(team: int) -> void:
	Draft.new_draft(rounds_choice, team)
	filter = "ALL"
	fast = false
	_timer = 0.0
	_show_draft_room()


# ---------- phòng draft ----------

func _show_draft_room() -> void:
	state = "room"
	var vb := _page()
	var head := PanelContainer.new()
	head.add_theme_stylebox_override("panel", UI.box(C_CARD, 24, 18))
	vb.add_child(head)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 14)
	head.add_child(hb)
	hb.add_child(_badge(Draft.user_team, 64))
	var hv := VBoxContainer.new()
	hv.size_flags_horizontal = SIZE_EXPAND_FILL
	hv.add_theme_constant_override("separation", 0)
	hb.add_child(hv)
	clock_label = UI.label("", 32)
	hv.add_child(clock_label)
	sub_label = UI.label("", 22, C_MUTED)
	hv.add_child(sub_label)
	sim_btn = UI.button("Sim to\nmy pick", C_BLUE, Vector2(150, 80), 22)
	sim_btn.size_flags_vertical = SIZE_SHRINK_CENTER
	sim_btn.pressed.connect(func(): fast = true)
	hb.add_child(sim_btn)

	var tk := PanelContainer.new()
	tk.add_theme_stylebox_override("panel", UI.box(Color(1, 1, 1, 0.04), 20, 14))
	vb.add_child(tk)
	ticker = VBoxContainer.new()
	ticker.add_theme_constant_override("separation", 6)
	tk.add_child(ticker)

	needs_label = UI.label("", 22, C_ACCENT)
	vb.add_child(needs_label)

	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 8)
	vb.add_child(flow)
	chips.clear()
	for f in ["ALL"] + Draft.POSITIONS:
		var f_name: String = f
		var b := UI.button(f_name, C_CARD, Vector2(84, 54), 22)
		b.pressed.connect(func():
			filter = f_name
			_style_chips()
			_refresh_list())
		flow.add_child(b)
		chips[f_name] = b
	_style_chips()

	var sc := _scroll()
	vb.add_child(sc)
	list = VBoxContainer.new()
	list.size_flags_horizontal = SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	sc.add_child(list)
	_refresh_room()


func _style_chips() -> void:
	for k in chips:
		var col: Color = POS_COLORS.get(k, C_BLUE) if k == filter else C_CARD
		UI.style(chips[k], col)


func _refresh_room() -> void:
	if state != "room":
		return
	var p := Draft.current
	if Draft.is_user_turn():
		clock_label.text = "YOU'RE ON THE CLOCK"
		clock_label.add_theme_color_override("font_color", C_ACCENT)
		sub_label.text = "Pick %s  •  #%d overall  •  tap a player" % [Draft.pick_label(p), p + 1]
		sim_btn.disabled = true
	elif not Draft.is_done():
		var t := Draft.team_on_clock()
		clock_label.text = "Pick %s  •  %s" % [Draft.pick_label(p), Draft.team_name(t)]
		clock_label.add_theme_color_override("font_color", Color.WHITE)
		var nx := Draft.next_user_pick()
		sub_label.text = ("Your next pick: %s  (%d away)" % [Draft.pick_label(nx), nx - p]) if nx >= 0 else "Your draft is complete"
		sim_btn.disabled = false
	var nd: Array = Draft.needs[Draft.user_team]
	needs_label.text = "TEAM NEEDS:  " + (", ".join(nd) if not nd.is_empty() else "All filled")

	for c in ticker.get_children():
		c.queue_free()
	var recent := Draft.picks.slice(maxi(0, Draft.picks.size() - 4))
	recent.reverse()
	if recent.is_empty():
		ticker.add_child(UI.label("The draft is about to begin...", 22, C_MUTED))
	for e in recent:
		var pl: Dictionary = e.player
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.add_child(UI.label(Draft.pick_label(e.pick), 22, C_MUTED))
		var ab := UI.label(Draft.team_abbr(e.team), 22, Draft.team_color(e.team))
		ab.custom_minimum_size = Vector2(60, 0)
		row.add_child(ab)
		row.add_child(_pos_chip(pl.pos, 18))
		var nm := UI.label(pl.name, 22, C_ACCENT if e.team == Draft.user_team else Color.WHITE)
		row.add_child(nm)
		ticker.add_child(row)
	_refresh_list()


func _refresh_list() -> void:
	for c in list.get_children():
		c.queue_free()
	var shown := 0
	for p in Draft.available:
		if filter != "ALL" and p.pos != filter:
			continue
		list.add_child(_player_row(p, shown == 0))
		shown += 1
		if shown >= 50:
			break


func _player_row(p: Dictionary, top: bool) -> Button:
	var b := UI.button("", C_CARD, Vector2(0, 96))
	b.size_flags_horizontal = SIZE_EXPAND_FILL
	if p.pos in Draft.needs[Draft.user_team]:
		var sb: StyleBoxFlat = b.get_theme_stylebox("normal").duplicate()
		sb.border_width_left = 6
		sb.border_color = C_ACCENT
		b.add_theme_stylebox_override("normal", sb)
	var row := HBoxContainer.new()
	row.set_anchors_preset(PRESET_FULL_RECT)
	row.offset_left = 16
	row.offset_right = -16
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = MOUSE_FILTER_IGNORE
	b.add_child(row)
	var rk := UI.label("#%d" % p.rank, 24, C_MUTED)
	rk.custom_minimum_size = Vector2(66, 0)
	rk.size_flags_vertical = SIZE_SHRINK_CENTER
	row.add_child(rk)
	var chip := _pos_chip(p.pos, 20)
	chip.size_flags_vertical = SIZE_SHRINK_CENTER
	row.add_child(chip)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_theme_constant_override("separation", -2)
	info.mouse_filter = MOUSE_FILTER_IGNORE
	row.add_child(info)
	info.add_child(UI.label(p.name, 28))
	var tag := "  •  BEST AVAILABLE" if top else ""
	info.add_child(UI.label("%s  •  %s %dlb%s" % [p.college, _height(p.ht), p.wt, tag], 19, C_MUTED))
	var gr := UI.label("%.1f" % p.grade, 32, _grade_color(p.grade))
	gr.size_flags_vertical = SIZE_SHRINK_CENTER
	row.add_child(gr)
	b.pressed.connect(func(): _open_card(p))
	return b


func _open_card(p: Dictionary) -> void:
	_close_card()
	sheet = ColorRect.new()
	(sheet as ColorRect).color = Color(0, 0, 0, 0.6)
	sheet.set_anchors_preset(PRESET_FULL_RECT)
	add_child(sheet)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(PRESET_BOTTOM_WIDE)
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var pb := UI.box(Color("1c2a47"), 32, 28)
	pb.corner_radius_bottom_left = 0
	pb.corner_radius_bottom_right = 0
	panel.add_theme_stylebox_override("panel", pb)
	sheet.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	panel.add_child(vb)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 14)
	vb.add_child(top)
	top.add_child(_pos_chip(p.pos, 26))
	top.add_child(UI.label(p.name, 40))
	vb.add_child(UI.label("%s  •  Age %d  •  Consensus #%d" % [p.college, p.age, p.rank], 22, C_MUTED))
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 12)
	vb.add_child(grid)
	for kv in [["GRADE", "%.1f" % p.grade], ["HEIGHT", _height(p.ht)], ["WEIGHT", "%d" % p.wt], ["40 YD", "%.2f" % p.forty]]:
		var cell := PanelContainer.new()
		cell.size_flags_horizontal = SIZE_EXPAND_FILL
		cell.add_theme_stylebox_override("panel", UI.box(Color(1, 1, 1, 0.06), 16, 12))
		var cv := VBoxContainer.new()
		cell.add_child(cv)
		var k := UI.label(kv[0], 18, C_MUTED)
		k.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cv.add_child(k)
		var v := UI.label(kv[1], 32)
		v.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cv.add_child(v)
		grid.add_child(cell)
	var rep := UI.label(_scout_report(p), 24, Color(1, 1, 1, 0.85))
	rep.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(rep)
	var can := Draft.is_user_turn()
	var draft_btn := UI.button("DRAFT %s" % p.name.to_upper() if can else "Wait for your pick", C_GREEN, Vector2(0, 100), 30)
	draft_btn.disabled = not can
	draft_btn.pressed.connect(func():
		_close_card()
		Draft.make_pick(p)
		_toast("%s selects %s!" % [Draft.team_abbr(Draft.user_team), p.name]))
	vb.add_child(draft_btn)
	var close := UI.button("Close", C_CARD, Vector2(0, 80), 26)
	close.pressed.connect(_close_card)
	vb.add_child(close)
	sheet.modulate.a = 0.0
	sheet.create_tween().tween_property(sheet, "modulate:a", 1.0, 0.15)


func _close_card() -> void:
	if is_instance_valid(sheet):
		sheet.queue_free()
	sheet = null


func _on_pick_made(_pick: int, team: int, player: Dictionary) -> void:
	if fast or state != "room":
		return
	if is_instance_valid(sheet) and team != Draft.user_team:
		_close_card()
		_toast("%s was just taken by %s" % [player.name, Draft.team_abbr(team)])
	_refresh_room()
	if Draft.is_user_turn():
		_on_clock_fx()


func _on_clock_fx() -> void:
	if not Draft.is_user_turn():
		return
	clock_label.pivot_offset = clock_label.size / 2.0
	var tw := clock_label.create_tween().set_loops(3)
	tw.tween_property(clock_label, "scale", Vector2(1.06, 1.06), 0.15)
	tw.tween_property(clock_label, "scale", Vector2.ONE, 0.15)
	Input.vibrate_handheld(40)


# ---------- kết quả ----------

func _show_results() -> void:
	state = "results"
	_close_card()
	var g := Draft.team_grade(Draft.user_team)
	var vb := _page()
	var title := UI.label("DRAFT COMPLETE", 46, C_ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)
	var gp := PanelContainer.new()
	gp.add_theme_stylebox_override("panel", UI.box(C_CARD, 28, 20))
	vb.add_child(gp)
	var gh := HBoxContainer.new()
	gh.add_theme_constant_override("separation", 24)
	gp.add_child(gh)
	var letter := UI.label(g.letter, 120, _letter_color(g.letter))
	gh.add_child(letter)
	var gv := VBoxContainer.new()
	gv.alignment = BoxContainer.ALIGNMENT_CENTER
	gh.add_child(gv)
	gv.add_child(UI.label(Draft.team_name(Draft.user_team), 30))
	gv.add_child(UI.label("Draft grade  •  League rank #%d of 32" % _league_rank(Draft.user_team), 22, C_MUTED))
	letter.pivot_offset = Vector2(40, 70)
	letter.scale = Vector2(0.2, 0.2)
	letter.create_tween().tween_property(letter, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	vb.add_child(UI.label("YOUR CLASS  —  TRUE RATINGS REVEALED", 22, C_MUTED))
	var sc := _scroll()
	vb.add_child(sc)
	var lv := VBoxContainer.new()
	lv.size_flags_horizontal = SIZE_EXPAND_FILL
	lv.add_theme_constant_override("separation", 8)
	sc.add_child(lv)
	for e in Draft.team_picks(Draft.user_team):
		var pl: Dictionary = e.player
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", UI.box(C_CARD, 20, 14))
		lv.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		card.add_child(row)
		row.add_child(UI.label(Draft.pick_label(e.pick), 22, C_MUTED))
		row.add_child(_pos_chip(pl.pos, 18))
		var nv := VBoxContainer.new()
		nv.size_flags_horizontal = SIZE_EXPAND_FILL
		nv.add_theme_constant_override("separation", -2)
		row.add_child(nv)
		nv.add_child(UI.label(pl.name, 26))
		nv.add_child(UI.label("OVR %d  •  POT %d  •  scout grade %.1f" % [pl.ovr, pl.pot, pl.grade], 19, C_MUTED))
		var vd := Draft.verdict(pl)
		var vcol := C_GREEN if vd == "STEAL" else (C_RED if vd == "BUST RISK" else C_BLUE)
		var chip := PanelContainer.new()
		chip.add_theme_stylebox_override("panel", UI.box(vcol, 12, 8))
		chip.size_flags_vertical = SIZE_SHRINK_CENTER
		chip.add_child(UI.label(vd, 18))
		row.add_child(chip)

	var best := _top_teams(3)
	var bl := "TOP CLASSES:  " + "   ".join(best.map(func(t): return "%s %s" % [Draft.team_abbr(t), Draft.team_grade(t).letter]))
	vb.add_child(UI.label(bl, 22, C_MUTED))
	var again := UI.button("NEW DRAFT", C_GREEN, Vector2(0, 100), 32)
	again.pressed.connect(_show_team_select)
	vb.add_child(again)


func _top_teams(n: int) -> Array:
	var ts: Array = range(Draft.TEAMS.size())
	ts.sort_custom(func(a, b): return Draft.team_grade(a).score > Draft.team_grade(b).score)
	return ts.slice(0, n)


func _league_rank(t: int) -> int:
	return _top_teams(Draft.TEAMS.size()).find(t) + 1


# ---------- tiện ích ----------

func _page() -> VBoxContainer:
	if is_instance_valid(screen):
		screen.queue_free()
	var m := MarginContainer.new()
	m.set_anchors_preset(PRESET_FULL_RECT)
	for k in ["margin_left", "margin_right"]:
		m.add_theme_constant_override(k, 20)
	m.add_theme_constant_override("margin_top", 36)
	m.add_theme_constant_override("margin_bottom", 24)
	add_child(m)
	screen = m
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	m.add_child(vb)
	return vb


func _scroll() -> ScrollContainer:
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	return sc


func _team_row(t: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = MOUSE_FILTER_IGNORE
	row.add_child(_badge(t, 60))
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", -4)
	v.mouse_filter = MOUSE_FILTER_IGNORE
	row.add_child(v)
	v.add_child(UI.label(Draft.TEAMS[t][0], 20, C_MUTED))
	v.add_child(UI.label(Draft.TEAMS[t][1], 26))
	return row


func _badge(t: int, d: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(d, d)
	c.size_flags_vertical = SIZE_SHRINK_CENTER
	c.mouse_filter = MOUSE_FILTER_IGNORE
	var col := Draft.team_color(t)
	var ab := Draft.team_abbr(t)
	c.draw.connect(func():
		var r := d / 2.0
		c.draw_circle(Vector2(r, r + 3), r, col.darkened(0.5))
		c.draw_circle(Vector2(r, r), r, col)
		c.draw_arc(Vector2(r, r), r * 0.82, 0, TAU, 40, Color(1, 1, 1, 0.35), 2.0, true)
		var fs := int(d * 0.3)
		c.draw_string(FONT, Vector2(0, r + fs * 0.36), ab, HORIZONTAL_ALIGNMENT_CENTER, d, fs, Color.WHITE))
	return c


func _pos_chip(pos: String, fs: int) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(fs * 3.2, 0)
	chip.add_theme_stylebox_override("panel", UI.box(POS_COLORS.get(pos, C_BLUE), 10, 6))
	chip.mouse_filter = MOUSE_FILTER_IGNORE
	var l := UI.label(pos, fs)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chip.add_child(l)
	return chip


func _toast(msg: String) -> void:
	var l := UI.label(msg, 28, Color.WHITE)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_stylebox_override("normal", UI.box(Color(0, 0, 0, 0.8), 20, 16))
	add_child(l)
	l.size = Vector2(size.x - 80, 0)
	l.position = Vector2(40, size.y * 0.42)
	var tw := l.create_tween()
	tw.tween_interval(1.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.3)
	tw.tween_callback(l.queue_free)


func _height(inches: int) -> String:
	return "%d'%d\"" % [inches / 12, inches % 12]


func _grade_color(g: float) -> Color:
	if g >= 80.0:
		return C_GREEN
	if g >= 70.0:
		return Color("a3e635")
	if g >= 62.0:
		return C_ACCENT
	return Color(1, 1, 1, 0.6)


func _letter_color(l: String) -> Color:
	if l.begins_with("A"):
		return C_GREEN
	if l.begins_with("B"):
		return Color("a3e635")
	if l.begins_with("C"):
		return C_ACCENT
	return C_RED


func _scout_report(p: Dictionary) -> String:
	var body: Array = Draft.POS_BODY[p.pos]
	var parts: Array[String] = []
	var fd: float = p.forty - float(body[2])
	if fd <= -0.06:
		parts.append("Elite long speed for the position")
	elif fd >= 0.06:
		parts.append("Lacks top-end speed")
	if p.ht - int(body[0]) >= 2:
		parts.append("prototypical length")
	elif p.ht - int(body[0]) <= -2:
		parts.append("undersized frame")
	if p.grade >= 80.0:
		parts.append("Day 1 starter with Pro Bowl upside")
	elif p.grade >= 70.0:
		parts.append("projects as a quality starter")
	elif p.grade >= 62.0:
		parts.append("developmental prospect with traits")
	else:
		parts.append("depth and special teams contributor")
	return ". ".join(parts.map(func(x: String): return x[0].to_upper() + x.substr(1))) + "."
