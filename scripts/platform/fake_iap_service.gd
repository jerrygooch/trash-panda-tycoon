extends Node

# FakeIAPService — stub that logs purchases and stores owned flags in memory
# Replace with real SDK: Google Play Billing, Apple StoreKit, etc.

var _owned_products: Dictionary = {}


func purchase(product_id: String) -> bool:
	print("[FakeIAP] Starting purchase for product: ", product_id)
	
	# Simulate a tiny network delay
	await get_tree().create_timer(0.3).timeout
	
	print("[FakeIAP] Purchase completed for product: ", product_id)
	_owned_products[product_id] = true
	return true


func is_owned(product_id: String) -> bool:
	return _owned_products.get(product_id, false)


func restore_purchases() -> void:
	print("[FakeIAP] Restore purchases requested — all owned products preserved")
