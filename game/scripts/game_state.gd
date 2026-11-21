extends Node
## Trạng thái game + lưu/đọc local + thu nhập offline.
## Autoload: GameState

signal coins_changed(coins: int)
signal board_changed
signal new_species(level: int)

const SAVE_PATH := "user://save.json"
const COLS := 5
const ROWS := 6
const MAX_LEVEL := 10
const SPAWN_COST := 10
const MAX_OFFLINE_SECONDS := 4 * 3600

var coins: int = 50
var board: Array = []  # độ dài COLS*ROWS, 0 = ô trống, >0 = cấp vật phẩm
var last_seen: int = 0
var best_level: int = 1


func _ready() -> void:
	board.resize(COLS * ROWS)
	board.fill(0)
	load_game()


## Vàng mỗi giây (idle): tổng cấp^2 của các vật phẩm trên bàn.
func income_per_second() -> int:
	var total := 0
	for lv in board:
		total += lv * lv
	return total


func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)


## Trả về chỉ số ô vừa thả, hoặc -1 nếu thiếu vàng/hết chỗ.
func spawn_item() -> int:
	if coins < SPAWN_COST:
		return -1
	var empty: Array[int] = []
	for i in board.size():
		if board[i] == 0:
			empty.append(i)
	if empty.is_empty():
		return -1
	coins -= SPAWN_COST
	var idx: int = empty.pick_random()
	board[idx] = 1
	coins_changed.emit(coins)
	board_changed.emit()
	save_game()
	return idx


## Ghép ô a vào ô b nếu cùng cấp và chưa tối đa.
func try_merge(a: int, b: int) -> bool:
	if a == b or board[a] == 0 or board[a] != board[b] or board[a] >= MAX_LEVEL:
		return false
	board[b] += 1
	board[a] = 0
	if board[b] > best_level:
		best_level = board[b]
		new_species.emit(best_level)
	board_changed.emit()
	save_game()
	return true


## Di chuyển vật phẩm sang ô trống.
func move_item(a: int, b: int) -> bool:
	if a == b or board[a] == 0 or board[b] != 0:
		return false
	board[b] = board[a]
	board[a] = 0
	board_changed.emit()
	save_game()
	return true


func save_game() -> void:
	last_seen = int(Time.get_unix_time_from_system())
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"coins": coins, "board": board, "last_seen": last_seen, "best_level": best_level}))


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	coins = int(data.get("coins", coins))
	var saved: Array = data.get("board", [])
	if saved.size() == board.size():
		for i in saved.size():
			board[i] = int(saved[i])
	last_seen = int(data.get("last_seen", 0))
	best_level = int(data.get("best_level", 1))


## Trả về số vàng kiếm được khi offline (đã cộng vào coins).
func claim_offline_earnings() -> int:
	if last_seen == 0:
		return 0
	var elapsed := clampi(int(Time.get_unix_time_from_system()) - last_seen, 0, MAX_OFFLINE_SECONDS)
	var earned := elapsed * income_per_second()
	if earned > 0:
		add_coins(earned)
	save_game()
	return earned


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
