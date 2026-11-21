extends Control
## Màn hình: chọn đội -> phòng draft -> kết quả. Thiết kế tối giản, một màu nhấn.

const UI := preload("res://scripts/ui.gd")
const PICK_DELAY := 0.45
const PAD := 24
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

var screen: Control
var state: String = ""
var rounds_choice: int = 3
var show_needs: bool = false
var fast: bool = false
var _timer: float = 0.0

var round_label: Label
var picks_label: Label
var clock_label: Label
var last_label: Label
var skip_btn: Button
var tabs_box: Control
var list: VBoxContainer
var sheet: Control


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


# ---------- chọn đội ----------

func _show_team_select() -> void:
	state = "select"
	var vb := _page()
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 6)
	vb.add_child(hv)
	hv.add_child(UI.label("Mock Draft GM", 52))
	var how := UI.label("AI teams pick in order. When you're on the clock, choose your player. Get graded at the end.", 23, UI.MUTED, true)
	how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hv.add_child(how)
	vb.add_child(_segmented(["1 round", "3 rounds", "7 rounds"], [1, 3, 7].find(rounds_choice), func(i: int):
		rounds_choice = [1, 3, 7][i]
		_show_team_select()))
	var sc := _scroll()
	vb.add_child(sc)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 8)
	sc.add_child(col)
	col.add_child(_section("Teams · sorted by first pick"))
	for i in Draft.base_order:
		var team: int = i
		var b := _row_button(92)
		var row := _row_box(b)
		row.add_child(_badge(team, 44))
		var tv := VBoxContainer.new()
		tv.add_theme_constant_override("separation", 0)
		tv.mouse_filter = MOUSE_FILTER_IGNORE
		row.add_child(_expand(tv))
		tv.add_child(UI.label(Draft.team_name(team), 27))
		tv.add_child(UI.label("Needs " + ", ".join(Draft.team_needs_preview(team)), 21, UI.MUTED, true))
		var fp := UI.label("Pick #%d" % Draft.first_pick_of(team), 21, UI.MUTED, true)
		fp.size_flags_vertical = SIZE_SHRINK_CENTER
		row.add_child(fp)
		b.add_theme_stylebox_override("pressed", UI.box(Color(Draft.team_color(team), 0.25)))
		b.pressed.connect(func(): _confirm_team(team))
		col.add_child(b)


func _confirm_team(team: int) -> void:
	Draft.new_draft(rounds_choice, team)
	var vb := _sheet()
	var fp := Draft.next_user_pick() + 1
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 18)
	vb.add_child(hb)
	hb.add_child(_badge(team, 72))
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 0)
	hb.add_child(_expand(hv))
	hv.add_child(UI.label(Draft.TEAMS[team][0], 23, UI.MUTED, true))
	hv.add_child(UI.label(Draft.TEAMS[team][1], 38))
	var nd: Array = Draft.needs[team]
	vb.add_child(_stats([
		["#%d" % fp, "First pick of 32"],
		["%d" % rounds_choice, "Rounds"],
		[", ".join(nd), "Team needs"],
	]))
	var go := UI.button("Start draft", UI.ACCENT, UI.BG, 96, 30)
	go.pressed.connect(func():
		_close_card()
		show_needs = false
		fast = false
		_timer = 0.0
		_show_draft_room())
	vb.add_child(go)


# ---------- phòng draft ----------

func _show_draft_room() -> void:
	state = "room"
	var vb := _page()
	var team_row := HBoxContainer.new()
	team_row.add_theme_constant_override("separation", 12)
	vb.add_child(team_row)
	team_row.add_child(_badge(Draft.user_team, 40))
	team_row.add_child(_expand(UI.label(Draft.team_name(Draft.user_team), 24)))
	picks_label = UI.label("", 22, UI.MUTED, true)
	picks_label.size_flags_vertical = SIZE_SHRINK_CENTER
	team_row.add_child(picks_label)
	var head := HBoxContainer.new()
	vb.add_child(head)
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 2)
	head.add_child(_expand(hv))
	round_label = UI.label("", 22, UI.MUTED, true)
	hv.add_child(round_label)
	clock_label = UI.label("", 42)
	hv.add_child(clock_label)
	skip_btn = UI.button("Skip ›", Color(0, 0, 0, 0), UI.ACCENT, 64, 26)
	skip_btn.size_flags_vertical = SIZE_SHRINK_CENTER
	skip_btn.pressed.connect(func(): fast = true)
	head.add_child(skip_btn)
	last_label = UI.label("", 22, UI.MUTED, true)
	last_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	vb.add_child(last_label)
	tabs_box = VBoxContainer.new()
	vb.add_child(tabs_box)
	var cm := MarginContainer.new()
	cm.add_theme_constant_override("margin_left", 20)
	cm.add_theme_constant_override("margin_right", 20)
	cm.add_theme_constant_override("margin_bottom", -10)
	vb.add_child(cm)
	var cols := HBoxContainer.new()
	cm.add_child(cols)
	cols.add_child(_expand(_section("Player", 0)))
	cols.add_child(_section("Grade", 0))
	var sc := _scroll()
	vb.add_child(sc)
	list = VBoxContainer.new()
	list.size_flags_horizontal = SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	sc.add_child(list)
	_refresh_room()


func _refresh_room() -> void:
	if state != "room":
		return
	var p := Draft.current
	if not Draft.is_done():
		round_label.text = "Pick %d  ·  Round %d" % [p % Draft.PICKS_PER_ROUND + 1, p / Draft.PICKS_PER_ROUND + 1]
	picks_label.text = "Your picks %d/%d" % [Draft.team_picks(Draft.user_team).size(), Draft.rounds]
	if Draft.is_user_turn():
		clock_label.text = "You're on the clock"
		clock_label.add_theme_color_override("font_color", UI.ACCENT)
		skip_btn.visible = false
	elif not Draft.is_done():
		clock_label.text = "%s picking…" % Draft.TEAMS[Draft.team_on_clock()][1]
		clock_label.add_theme_color_override("font_color", UI.TEXT)
		skip_btn.visible = Draft.next_user_pick() >= 0
	if Draft.picks.is_empty():
		last_label.text = "The draft is about to begin."
	else:
		var e: Dictionary = Draft.picks[-1]
		last_label.text = "Last pick: %s took %s, %s" % [Draft.TEAMS[e.team][1], e.player.name, e.player.pos]

	var nd: Array = Draft.needs[Draft.user_team]
	for c in tabs_box.get_children():
		c.queue_free()
	var needs_txt := "Team needs" + ("" if nd.is_empty() else "  ·  %d" % nd.size())
	tabs_box.add_child(_segmented(["All players", needs_txt], 1 if show_needs else 0, func(i: int):
		show_needs = i == 1
		_refresh_room()))
	_refresh_list()


func _refresh_list() -> void:
	for c in list.get_children():
		c.queue_free()
	var nd: Array = Draft.needs[Draft.user_team]
	var shown := 0
	var pool: Array = Draft.available.duplicate()
	pool.sort_custom(func(a, b): return a.grade > b.grade)
	for p in pool:
		if show_needs and p.pos not in nd:
			continue
		list.add_child(_player_row(p, p.pos in nd))
		shown += 1
		if shown >= 40:
			break
	if shown == 0:
		list.add_child(UI.label("No players left at your needs.", 24, UI.MUTED, true))


func _player_row(p: Dictionary, need: bool) -> Button:
	var b := _row_button(84)
	var row := _row_box(b)
	var info := VBoxContainer.new()
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_theme_constant_override("separation", 0)
	info.mouse_filter = MOUSE_FILTER_IGNORE
	row.add_child(_expand(info))
	info.add_child(UI.label(p.name, 28))
	var meta := HBoxContainer.new()
	meta.add_theme_constant_override("separation", 10)
	meta.mouse_filter = MOUSE_FILTER_IGNORE
	info.add_child(meta)
	meta.add_child(UI.label("%s  ·  %s" % [p.pos, p.college], 22, UI.MUTED, true))
	if need:
		meta.add_child(UI.pill("NEED", UI.INFO, 16, true))
	var g := UI.label("%.1f" % p.grade, 30)
	g.size_flags_vertical = SIZE_SHRINK_CENTER
	row.add_child(g)
	b.pressed.connect(func(): _open_card(p))
	return b


func _open_card(p: Dictionary) -> void:
	var vb := _sheet()
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 2)
	vb.add_child(hv)
	var nh := HBoxContainer.new()
	nh.add_theme_constant_override("separation", 14)
	hv.add_child(nh)
	nh.add_child(UI.label(p.name, 40))
	if p.pos in Draft.needs[Draft.user_team]:
		nh.add_child(UI.pill("Fills a need", UI.INFO, 18, true))
	hv.add_child(UI.label("%s  ·  %s  ·  Age %d  ·  Board #%d" % [p.pos, p.college, p.age, _board_rank(p)], 23, UI.MUTED, true))
	vb.add_child(_stats([["%.1f" % p.grade, "Grade"], [_height(p.ht), "Height"], ["%d lb" % p.wt, "Weight"], ["%.2f" % p.forty, "40 yd"]]))
	var rep := UI.label(_scout_report(p), 24, UI.TEXT, true)
	rep.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(rep)
	var can := Draft.is_user_turn()
	var draft_btn := UI.button("Draft %s" % p.name if can else "Not your pick yet", UI.ACCENT, UI.BG, 96, 30)
	draft_btn.disabled = not can
	draft_btn.pressed.connect(func():
		_close_card()
		Draft.make_pick(p)
		_toast("You drafted %s" % p.name))
	vb.add_child(draft_btn)


## Bottom sheet chung: nền mờ 70%, tay kéo, chạm ngoài để đóng.
func _sheet() -> VBoxContainer:
	_close_card()
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(PRESET_FULL_RECT)
	dim.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			_close_card())
	add_child(dim)
	sheet = dim
	var panel := PanelContainer.new()
	panel.set_anchors_preset(PRESET_BOTTOM_WIDE)
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var pb := UI.box(UI.CARD, 28, 28)
	pb.corner_radius_bottom_left = 0
	pb.corner_radius_bottom_right = 0
	pb.content_margin_top = 16
	pb.content_margin_bottom = 36
	panel.add_theme_stylebox_override("panel", pb)
	dim.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 20)
	panel.add_child(vb)
	var handle := Panel.new()
	handle.custom_minimum_size = Vector2(56, 6)
	handle.size_flags_horizontal = SIZE_SHRINK_CENTER
	handle.add_theme_stylebox_override("panel", UI.box(Color(1, 1, 1, 0.2), 3, 0))
	vb.add_child(handle)
	dim.modulate.a = 0.0
	dim.create_tween().tween_property(dim, "modulate:a", 1.0, 0.15)
	return vb


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


func _close_card() -> void:
	if is_instance_valid(sheet):
		sheet.queue_free()
	sheet = null


func _on_pick_made(_pick: int, team: int, player: Dictionary) -> void:
	if fast or state != "room":
		return
	if is_instance_valid(sheet) and team != Draft.user_team:
		_close_card()
		_toast("%s was just taken" % player.name)
	_refresh_room()
	if Draft.is_user_turn():
		_on_clock_fx()


func _on_clock_fx() -> void:
	if not Draft.is_user_turn():
		return
	clock_label.pivot_offset = Vector2(0, clock_label.size.y / 2.0)
	var tw := clock_label.create_tween()
	tw.tween_property(clock_label, "scale", Vector2(1.05, 1.05), 0.12)
	tw.tween_property(clock_label, "scale", Vector2.ONE, 0.18)
	Input.vibrate_handheld(40)


# ---------- kết quả ----------

func _show_results() -> void:
	state = "results"
	_close_card()
	var g := Draft.team_grade(Draft.user_team)
	var vb := _page()
	var gh := HBoxContainer.new()
	gh.add_theme_constant_override("separation", 24)
	vb.add_child(gh)
	var lt: String = g.letter
	var letter := UI.label(lt, 128, _tier_color(lt))
	gh.add_child(letter)
	var gv := VBoxContainer.new()
	gv.alignment = BoxContainer.ALIGNMENT_BEGIN
	gv.add_theme_constant_override("separation", 2)
	var gtop := Control.new()
	gtop.custom_minimum_size = Vector2(0, 30)
	gv.add_child(gtop)
	gh.add_child(gv)
	gv.add_child(UI.label(Draft.team_name(Draft.user_team), 30))
	gv.add_child(UI.label("Ranked #%d of 32 classes" % _league_rank(Draft.user_team), 23, UI.MUTED, true))
	letter.pivot_offset = Vector2(40, 80)
	letter.scale = Vector2(0.3, 0.3)
	letter.modulate.a = 0.0
	letter.create_tween().tween_property(letter, "modulate:a", 1.0, 0.3)
	letter.create_tween().tween_property(letter, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var mine := Draft.team_picks(Draft.user_team)
	var sc := _scroll()
	vb.add_child(sc)
	var lv := VBoxContainer.new()
	lv.size_flags_horizontal = SIZE_EXPAND_FILL
	lv.add_theme_constant_override("separation", 8)
	sc.add_child(lv)
	var best: Dictionary = mine[0]
	for e in mine:
		if Draft.true_rating(e.player) - e.player.grade >= Draft.true_rating(best.player) - best.player.grade:
			best = e
	var bp: Dictionary = best.player
	var worst: Dictionary = mine[0]
	for e in mine:
		if Draft.true_rating(e.player) - e.player.grade < Draft.true_rating(worst.player) - worst.player.grade:
			worst = e
	var wp: Dictionary = worst.player
	var story_title := "EVERY PICK HELD ITS GRADE"
	var story_line := "Your board was spot on."
	var story_col := UI.MUTED
	if Draft.true_rating(bp) - bp.grade >= 3.0:
		story_title = "STEAL OF YOUR DRAFT"
		story_line = "%s  ·  %.1f → %.1f  (pick %d)" % [bp.name, bp.grade, Draft.true_rating(bp), best.pick + 1]
		story_col = UI.GOOD
	elif Draft.true_rating(wp) - wp.grade <= -3.0:
		story_title = "TOUGHEST MISS"
		story_line = "%s  ·  %.1f → %.1f  (pick %d)" % [wp.name, wp.grade, Draft.true_rating(wp), worst.pick + 1]
		story_col = UI.BAD
	var bc := PanelContainer.new()
	var bsb := UI.box(UI.CARD, 14, 18)
	bsb.border_width_left = 6
	bsb.border_color = story_col
	bc.add_theme_stylebox_override("panel", bsb)
	lv.add_child(bc)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 2)
	bc.add_child(sv)
	sv.add_child(UI.label(story_title, 18, story_col))
	sv.add_child(UI.label(story_line, 26))
	lv.add_child(_section("Your class · true ratings", 32))
	var delay := 0.5
	for e in mine:
		var pl: Dictionary = e.player
		var tr := Draft.true_rating(pl)
		var vd := Draft.verdict(pl)
		var vcol: Color = {"Steal": UI.GOOD, "Solid": UI.MUTED, "Miss": UI.WARN, "Bust": UI.BAD}[vd]
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", UI.box(UI.CARD, 16, 16))
		lv.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		card.add_child(row)
		var info := VBoxContainer.new()
		info.add_theme_constant_override("separation", 0)
		row.add_child(_expand(info))
		info.add_child(UI.label(pl.name, 27))
		info.add_child(UI.label("Pick %d  ·  %s  ·  Graded %.1f → True %.1f" % [e.pick + 1, pl.pos, pl.grade, tr], 21, UI.MUTED, true))
		var vv := VBoxContainer.new()
		vv.alignment = BoxContainer.ALIGNMENT_CENTER
		vv.add_theme_constant_override("separation", 4)
		row.add_child(vv)
		var pill := UI.pill(vd, vcol, 18)
		pill.size_flags_horizontal = SIZE_SHRINK_END
		vv.add_child(pill)
		var dl := UI.label("%+.1f" % (tr - pl.grade), 20, vcol, true)
		dl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		vv.add_child(dl)
		# lộ diện lần lượt
		card.modulate.a = 0.0
		var tw := card.create_tween()
		tw.tween_interval(delay)
		tw.tween_property(card, "modulate:a", 1.0, 0.25)
		if vd == "Steal":
			tw.tween_callback(func(): Input.vibrate_handheld(30))
		delay += 0.08
	lv.add_child(_section("League leaderboard", 32))
	var ranked := _ranked_teams()
	var show: Array = ranked.slice(0, 3)
	if Draft.user_team not in show:
		show.append(Draft.user_team)
	for t in show:
		var mine_row: bool = t == Draft.user_team
		if mine_row and ranked.find(t) > 3:
			var dots := UI.label("···", 24, UI.MUTED)
			dots.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lv.add_child(dots)
		var tc := PanelContainer.new()
		var tsb := UI.box(UI.CARD, 14, 16)
		if mine_row:
			tsb.set_border_width_all(2)
			tsb.border_color = Draft.team_color(t)
		tc.add_theme_stylebox_override("panel", tsb)
		lv.add_child(tc)
		var th := HBoxContainer.new()
		th.add_theme_constant_override("separation", 14)
		tc.add_child(th)
		th.add_child(UI.label("#%d" % (ranked.find(t) + 1), 22, UI.MUTED, true))
		th.add_child(_badge(t, 36))
		th.add_child(_expand(UI.label(("You · " + Draft.TEAMS[t][1]) if mine_row else Draft.team_name(t), 23)))
		var tl: String = Draft.team_grade(t).letter
		th.add_child(UI.label(tl, 26, _tier_color(tl)))
	var same := UI.button("Same team again", Color(0, 0, 0, 0), UI.MUTED, 56, 24)
	same.pressed.connect(func():
		Draft.shuffle_order()
		Draft.new_draft(Draft.rounds, Draft.user_team)
		show_needs = false
		fast = false
		_timer = 0.0
		_show_draft_room())
	vb.add_child(same)
	var again := UI.button("New draft", UI.ACCENT, UI.BG, 96, 30)
	again.pressed.connect(func():
		Draft.shuffle_order()
		_show_team_select())
	vb.add_child(again)


## Tiêu đề mục: chữ hoa, cách trên 24px / dưới 12px (trừ separation của VBox).
func _section(text: String, top: int = 24) -> Label:
	var l := UI.label(text.to_upper(), 18, UI.MUTED)
	var sb := StyleBoxEmpty.new()
	sb.content_margin_top = maxi(0, top - 8)
	sb.content_margin_bottom = 4
	l.add_theme_stylebox_override("normal", sb)
	return l


func _tier_color(l: String) -> Color:
	if l.begins_with("A"):
		return UI.GOOD
	if l.begins_with("B"):
		return UI.TEXT
	if l.begins_with("C"):
		return Color("c9b48a")
	return UI.BAD


func _ranked_teams() -> Array:
	var ts: Array = range(Draft.TEAMS.size())
	ts.sort_custom(func(a, b): return Draft.team_grade(a).score > Draft.team_grade(b).score)
	return ts


func _league_rank(t: int) -> int:
	return _ranked_teams().find(t) + 1


func _board_rank(p: Dictionary) -> int:
	var n := 1
	for q in Draft.available:
		if q.grade > p.grade:
			n += 1
	return n


# ---------- tiện ích ----------

func _page() -> VBoxContainer:
	if is_instance_valid(screen):
		screen.queue_free()
	var m := MarginContainer.new()
	m.set_anchors_preset(PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", PAD)
	m.add_theme_constant_override("margin_right", PAD)
	m.add_theme_constant_override("margin_top", 36)
	m.add_theme_constant_override("margin_bottom", 28)
	add_child(m)
	screen = m
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 20)
	m.add_child(vb)
	return vb


func _segmented(options: Array, selected: int, on_select: Callable) -> PanelContainer:
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", UI.box(UI.CARD, 16, 6))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 6)
	pc.add_child(hb)
	for i in options.size():
		var idx: int = i
		var on := idx == selected
		var b := UI.button(options[idx], UI.TEXT if on else Color(0, 0, 0, 0), UI.BG if on else UI.MUTED, 60, 22)
		b.size_flags_horizontal = SIZE_EXPAND_FILL
		b.clip_text = true
		b.pressed.connect(func(): on_select.call(idx))
		hb.add_child(b)
	return pc


func _row_button(h: float) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, h)
	b.focus_mode = FOCUS_NONE
	b.size_flags_horizontal = SIZE_EXPAND_FILL
	UI.style(b, UI.CARD, UI.TEXT)
	return b


func _row_box(b: Button) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.set_anchors_preset(PRESET_FULL_RECT)
	row.offset_left = 20
	row.offset_right = -20
	row.add_theme_constant_override("separation", 16)
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
	return sc


func _badge(t: int, d: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(d, d)
	c.size_flags_vertical = SIZE_SHRINK_CENTER
	c.mouse_filter = MOUSE_FILTER_IGNORE
	var col := Draft.team_color(t).darkened(0.25)
	var ab := Draft.team_abbr(t)
	c.draw.connect(func():
		var r := d / 2.0
		c.draw_circle(Vector2(r, r), r, col)
		var fs := int(d * 0.3)
		c.draw_string(UI.BOLD, Vector2(0, r + fs * 0.36), ab, HORIZONTAL_ALIGNMENT_CENTER, d, fs, Color.WHITE))
	return c


func _toast(msg: String) -> void:
	var l := UI.label(msg, 26)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_stylebox_override("normal", UI.box(Color("1f2a40"), 16, 18))
	add_child(l)
	l.size = Vector2(size.x - 2 * PAD, 0)
	l.position = Vector2(PAD, size.y - 140)
	var tw := l.create_tween()
	tw.tween_interval(1.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.3)
	tw.tween_callback(l.queue_free)


func _height(inches: int) -> String:
	return "%d'%d\"" % [inches / 12, inches % 12]


func _scout_report(p: Dictionary) -> String:
	var body: Array = Draft.POS_BODY[p.pos]
	var parts: Array[String] = []
	var fd: float = p.forty - float(body[2])
	if fd <= -0.06:
		parts.append("Elite speed for the position")
	elif fd >= 0.06:
		parts.append("Lacks top-end speed")
	if p.ht - int(body[0]) >= 2:
		parts.append("Prototypical length")
	elif p.ht - int(body[0]) <= -2:
		parts.append("Undersized frame")
	var notes: Array = POS_NOTES[p.pos]
	parts.append(notes[int(p.id) % notes.size()])
	if p.grade >= 80.0:
		parts.append("Day\u00a01 starter with Pro\u00a0Bowl upside")
	elif p.grade >= 70.0:
		parts.append("Projects as a quality starter")
	elif p.grade >= 62.0:
		parts.append("Developmental prospect with traits")
	else:
		parts.append("Depth and special teams contributor")
	return ". ".join(parts) + "."
