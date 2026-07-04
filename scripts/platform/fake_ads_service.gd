extends Node

# FakeAdsService — stub that logs ad events and instantly rewards
# Replace with real SDK: AdMob, Unity Ads, AppLovin, etc.

signal rewarded_ad_completed(placement: String)
signal rewarded_ad_failed(placement: String, error: String)


func show_rewarded_ad(placement: String) -> bool:
	print("[FakeAds] Showing rewarded ad for placement: ", placement)
	print("[FakeAds] Waiting fake delay...")
	
	# Simulate a tiny network delay
	await get_tree().create_timer(0.3).timeout
	
	print("[FakeAds] Ad completed — granting reward for placement: ", placement)
	rewarded_ad_completed.emit(placement)
	return true


func show_interstitial(placement: String) -> void:
	print("[FakeAds] Showing interstitial ad for placement: ", placement)
	print("[FakeAds] Interstitial dismissed — placement: ", placement)
