extends Node

# PlatformService — abstraction layer for ads, IAP, and platform-specific features
# MVP uses fake implementations. Swap with real SDK calls when ready for release.

var _ads_service: Node
var _iap_service: Node


func _ready() -> void:
	_create_services()


func _create_services() -> void:
	_ads_service = preload("res://scripts/platform/fake_ads_service.gd").new()
	add_child(_ads_service)
	
	_iap_service = preload("res://scripts/platform/fake_iap_service.gd").new()
	add_child(_iap_service)


# --- Ads ---

func show_rewarded_ad(placement: String = "default") -> bool:
	## Show a rewarded video ad. Returns true if the reward was granted.
	## Placement IDs: "double_earnings", "bonus_coins"
	return await _ads_service.show_rewarded_ad(placement)


func show_interstitial(placement: String = "default") -> void:
	## Show an interstitial ad between screens.
	## Placement IDs: "between_rounds", "main_menu"
	_ads_service.show_interstitial(placement)


# --- IAP ---

func purchase_item(product_id: String) -> bool:
	## Purchase a product. Returns true if purchase succeeded.
	## Product IDs: "remove_ads", "starter_pack"
	return await _iap_service.purchase(product_id)


func is_remove_ads_owned() -> bool:
	## Check if the user has purchased remove_ads.
	return _iap_service.is_owned("remove_ads")


func is_product_owned(product_id: String) -> bool:
	return _iap_service.is_owned(product_id)


# --- Platform info ---

func is_mobile() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")


func is_desktop() -> bool:
	return not is_mobile()


# --- Haptics stubs (log only on desktop; wire to Android Vibrator service later) ---

func vibrate_short() -> void:
	print("[Haptics] Short vibration (stub)")


func vibrate_success() -> void:
	print("[Haptics] Success vibration (stub)")


func vibrate_error() -> void:
	print("[Haptics] Error vibration (stub)")
