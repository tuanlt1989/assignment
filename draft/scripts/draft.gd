extends Node
## Trạng thái draft: đội, cầu thủ (hư cấu), thứ tự chọn, AI chọn, chấm điểm. Autoload: Draft

signal pick_made(pick_no: int, team: int, player: Dictionary)

const PICKS_PER_ROUND := 32
const POSITIONS := ["QB", "RB", "WR", "TE", "OT", "IOL", "EDGE", "DL", "LB", "CB", "S"]
const POS_WEIGHT := [6, 8, 14, 7, 9, 10, 11, 10, 9, 12, 9]
const POS_VALUE := {
	"QB": 1.12, "RB": 0.94, "WR": 1.03, "TE": 0.96, "OT": 1.05, "IOL": 0.97,
	"EDGE": 1.06, "DL": 1.02, "LB": 0.96, "CB": 1.04, "S": 0.98,
}
## [chiều cao inch, cân nặng lbs, 40-yard dash]
const POS_BODY := {
	"QB": [75, 220, 4.80], "RB": [70, 210, 4.50], "WR": [73, 195, 4.45], "TE": [77, 250, 4.70],
	"OT": [78, 315, 5.20], "IOL": [76, 310, 5.25], "EDGE": [76, 255, 4.65], "DL": [75, 300, 5.00],
	"LB": [74, 235, 4.62], "CB": [71, 190, 4.42], "S": [72, 205, 4.50],
}
const TEAMS := [
	["Austin", "Outlaws", "AUS"], ["Portland", "Lumberjacks", "POR"], ["San Antonio", "Comets", "SAT"],
	["Orlando", "Flamingos", "ORL"], ["Salt Lake", "Summit", "SLC"], ["Oklahoma City", "Twisters", "OKC"],
	["Memphis", "Blues", "MEM"], ["Louisville", "Thoroughbreds", "LOU"], ["Omaha", "Stampede", "OMA"],
	["Sacramento", "Prospectors", "SAC"], ["Columbus", "Foxes", "COL"], ["Raleigh", "Oaks", "RAL"],
	["Albuquerque", "Roadrunners", "ABQ"], ["Tucson", "Scorpions", "TUC"], ["Boise", "Peaks", "BOI"],
	["Honolulu", "Waves", "HNL"], ["Anchorage", "Grizzlies", "ANC"], ["Richmond", "Ironclads", "RIC"],
	["Hartford", "Hawks", "HFD"], ["Milwaukee", "Brewmasters", "MIL"], ["St. Louis", "Arches", "STL"],
	["Birmingham", "Forge", "BHM"], ["Fresno", "Raptors", "FRE"], ["El Paso", "Coyotes", "ELP"],
	["Wichita", "Windmills", "WIC"], ["Des Moines", "Pioneers", "DSM"], ["Rochester", "Lynx", "ROC"],
	["Charleston", "Pelicans", "CHS"], ["Savannah", "Ghosts", "SAV"], ["Reno", "Jackpots", "RNO"],
	["Tulsa", "Mustangs", "TUL"], ["Baton Rouge", "Bayou Kings", "BTR"],
]
const FIRST := [
	"Jalen", "Marcus", "Tyler", "Caleb", "Darius", "Jaxon", "Isaiah", "Trey", "Malik", "Brock",
	"Cole", "Deshawn", "Garrett", "Xavier", "Kendrick", "Bryce", "Javon", "Austin", "Tre", "Mason",
	"Dante", "Logan", "Andre", "Zion", "Carson", "Terrell", "Hunter", "Jamal", "Drew", "Elijah",
	"Kobe", "Nolan", "Roman", "Tavion", "Quinn", "Devin", "Shane", "Myles", "Cameron", "Josiah",
]
const LAST := [
	"Carter", "Brooks", "Hayes", "Mitchell", "Coleman", "Price", "Bennett", "Holloway", "Reed",
	"Whitfield", "Sanders", "Graves", "Patterson", "Dawson", "Fletcher", "McAllister", "Booker",
	"Ellison", "Vaughn", "Harlan", "Pruitt", "Stokes", "Tillman", "Wade", "Oakley", "Rhodes",
	"Lockett", "Barlow", "Kincaid", "Mercer", "Spencer", "Dorsey", "Gaines", "Hollis", "Lacey",
	"Maddox", "Norwood", "Pierce", "Quarles", "Ridley", "Sutton", "Talley", "Underwood", "Winslow",
]
const COLLEGES := [
	"Lakeshore St.", "Pine Valley", "Coastal Tech", "Red Mesa", "Northern Plains", "Bluegrass",
	"Gulf Coast", "Granite", "Prairie A&M", "Sierra", "Harbor City", "Ozark St.", "Cascade",
	"Delta", "Summit", "Ironwood", "Magnolia", "Canyon St.", "Bayou Tech", "Great Lakes",
]

var rounds: int = 3
var user_team: int = 0
var order: Array[int] = []
var prospects: Array = []
var available: Array = []
var picks: Array = []
var needs: Array = []
var current: int = 0
var rng := RandomNumberGenerator.new()
var base_order: Array[int] = []


func _ready() -> void:
	shuffle_order()


## Xáo thứ tự chọn trước, để màn chọn đội hiện được lượt của từng đội.
func shuffle_order() -> void:
	base_order.clear()
	for i in TEAMS.size():
		base_order.append(i)
	base_order.shuffle()


func first_pick_of(team: int) -> int:
	return base_order.find(team) + 1


func new_draft(num_rounds: int, team: int) -> void:
	rng.randomize()
	rounds = num_rounds
	user_team = team
	order.clear()
	for r in rounds:
		order.append_array(base_order)
	needs.clear()
	for i in TEAMS.size():
		var n: Array = []
		while n.size() < 3:
			var p: String = POSITIONS.pick_random()
			if p not in n:
				n.append(p)
		needs.append(n)
	_generate(rounds * PICKS_PER_ROUND + 64)
	picks.clear()
	current = 0


func _generate(count: int) -> void:
	prospects.clear()
	var total_w := 0
	for w in POS_WEIGHT:
		total_w += w
	var used := {}
	for i in count:
		var pos := _weighted_pos(total_w)
		var ovr := 48.0 + 38.0 * pow(rng.randf(), 2.0)
		var pot := minf(99.0, ovr + rng.randf_range(0.0, 16.0))
		var grade := clampf(ovr * 0.55 + pot * 0.45 + rng.randfn(0.0, 4.0), 40.0, 99.0)
		var body: Array = POS_BODY[pos]
		var nm := ""
		for attempt in 20:
			nm = "%s %s" % [FIRST[rng.randi() % FIRST.size()], LAST[rng.randi() % LAST.size()]]
			if not used.has(nm):
				break
		used[nm] = true
		prospects.append({
			"id": i, "name": nm, "pos": pos, "college": COLLEGES[rng.randi() % COLLEGES.size()],
			"ovr": int(ovr), "pot": int(pot), "grade": snappedf(grade, 0.1),
			"consensus": grade + rng.randfn(0.0, 2.5),
			"ht": int(body[0]) + rng.randi_range(-2, 2), "wt": int(body[1]) + rng.randi_range(-15, 15),
			"forty": snappedf(float(body[2]) + rng.randf_range(-0.12, 0.12), 0.01),
			"age": rng.randi_range(21, 23),
		})
	prospects.sort_custom(func(a, b): return a.consensus > b.consensus)
	for i in prospects.size():
		prospects[i]["rank"] = i + 1
	available = prospects.duplicate()


func _weighted_pos(total_w: int) -> String:
	var r := rng.randi_range(1, total_w)
	for i in POSITIONS.size():
		r -= POS_WEIGHT[i]
		if r <= 0:
			return POSITIONS[i]
	return POSITIONS[0]


func is_done() -> bool:
	return current >= order.size()


func team_on_clock() -> int:
	return -1 if is_done() else order[current]


func is_user_turn() -> bool:
	return not is_done() and order[current] == user_team


func pick_label(p: int) -> String:
	return "%d.%02d" % [p / PICKS_PER_ROUND + 1, p % PICKS_PER_ROUND + 1]


func next_user_pick() -> int:
	for p in range(current, order.size()):
		if order[p] == user_team:
			return p
	return -1


func make_pick(player: Dictionary) -> void:
	var t := team_on_clock()
	available.erase(player)
	var n: Array = needs[t]
	n.erase(player.pos)
	picks.append({"pick": current, "team": t, "player": player})
	var p := current
	current += 1
	pick_made.emit(p, t, player)


## AI: điểm = grade x giá trị vị trí + thưởng nếu đúng nhu cầu + ngẫu nhiên.
func ai_choose() -> Dictionary:
	var t := team_on_clock()
	var best: Dictionary = available[0]
	var best_s := -INF
	for i in mini(24, available.size()):
		var p: Dictionary = available[i]
		var s: float = p.grade * POS_VALUE[p.pos] + (5.0 if p.pos in needs[t] else 0.0) + rng.randfn(0.0, 2.2)
		if s > best_s:
			best_s = s
			best = p
	return best


func team_picks(t: int) -> Array:
	return picks.filter(func(e): return e.team == t)


## Chấm điểm: giá trị so với vị trí pick + chất lượng so với mặt bằng tại pick đó.
func team_grade(t: int) -> Dictionary:
	var ps := team_picks(t)
	if ps.is_empty():
		return {"letter": "-", "score": 0.0}
	var s := 0.0
	for e in ps:
		var pl: Dictionary = e.player
		var expected := float(e.pick + 1)
		s += clampf((expected - pl.rank) / maxf(8.0, expected * 0.35), -2.0, 2.0)
		var ref: Dictionary = prospects[mini(e.pick, prospects.size() - 1)]
		s += (pl.grade - ref.grade) / 6.0
	s /= ps.size()
	var cuts := [[1.2, "A+"], [0.9, "A"], [0.6, "A-"], [0.35, "B+"], [0.1, "B"], [-0.15, "B-"],
		[-0.4, "C+"], [-0.7, "C"], [-1.0, "D"]]
	for c in cuts:
		if s >= c[0]:
			return {"letter": c[1], "score": s}
	return {"letter": "F", "score": s}


## Chỉ số thật (lộ diện sau draft).
func true_rating(p: Dictionary) -> float:
	return snappedf(p.ovr * 0.55 + p.pot * 0.45, 0.1)


## So sánh chỉ số thật với điểm scout lúc draft.
func verdict(p: Dictionary) -> String:
	var d: float = true_rating(p) - p.grade
	if d >= 3.0:
		return "Steal"
	if d >= -3.0:
		return "Solid"
	if d >= -6.0:
		return "Disappointment"
	return "Bust"


func team_name(t: int) -> String:
	return "%s %s" % [TEAMS[t][0], TEAMS[t][1]]


func team_abbr(t: int) -> String:
	return TEAMS[t][2]


func team_color(t: int) -> Color:
	return Color.from_hsv(fmod(t * 0.618034, 1.0), 0.62, 0.88)
