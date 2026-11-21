extends Node
## Chỗ cắm IAP + quảng cáo rewarded. Hiện là STUB chạy giả lập để test vòng chơi.
## Khi tích hợp thật: Google Play Billing (plugin GodotGooglePlayBilling) và AdMob/AppLovin.
## Autoload: Monetization

signal ad_rewarded(reward_coins: int)
signal purchase_completed(product_id: String)

const PRODUCTS := {
	"starter_pack": {"price": "4.99", "coins": 2000},
	"coin_pack_m": {"price": "9.99", "coins": 5000},
	"coin_pack_l": {"price": "19.99", "coins": 12000},
	"coin_pack_xl": {"price": "49.99", "coins": 35000},
	"remove_ads": {"price": "6.99", "coins": 0},
}

var ads_removed: bool = false


func show_rewarded_ad() -> void:
	# TODO: thay bằng SDK quảng cáo thật. Hiện cấp thưởng ngay để test.
	var reward := 100 + GameState.income_per_second() * 30
	GameState.add_coins(reward)
	ad_rewarded.emit(reward)


func purchase(product_id: String) -> void:
	# TODO: thay bằng Google Play Billing. Hiện giả lập mua thành công.
	if not PRODUCTS.has(product_id):
		push_warning("Unknown product: %s" % product_id)
		return
	var p: Dictionary = PRODUCTS[product_id]
	if p.coins > 0:
		GameState.add_coins(p.coins)
	if product_id == "remove_ads":
		ads_removed = true
	purchase_completed.emit(product_id)
