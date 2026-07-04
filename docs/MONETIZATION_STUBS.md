# Monetization Stubs

## Architecture

All monetization goes through `PlatformService` (autoload in `scripts/platform/platform_service.gd`).

Game code calls:
- `PlatformService.show_rewarded_ad("double_earnings")` → returns `true` after stub delay
- `PlatformService.show_interstitial("between_rounds")` → logs to console
- `PlatformService.purchase_item("remove_ads")` → logs, marks product as owned
- `PlatformService.is_remove_ads_owned()` → checks memory flag

## Fake Implementations

### FakeAdsService (`scripts/platform/fake_ads_service.gd`)

- `show_rewarded_ad(placement)` — logs the placement, waits 0.3 seconds, returns `true`
- `show_interstitial(placement)` — logs the placement, no delay

### FakeIAPService (`scripts/platform/fake_iap_service.gd`)

- `purchase(product_id)` — logs the purchase, waits 0.3 seconds, adds to `_owned_products` dict, returns `true`
- `is_owned(product_id)` — checks dict
- Products are NOT persisted — reset on restart unless SaveSystem is extended

## Where Real SDK Integration Would Be Added

### AdMob (example)
1. Add Godot AdMob plugin (Android + iOS)
2. Replace `FakeAdsService` with real `AdMobService`
3. `PlatformService` stays the same — only the service class swaps

### Google Play Billing (example)
1. Add Godot Billing plugin (Android only)
2. Replace `FakeIAPService` with real `BillingService`
3. `PlatformService` stays the same

### Flow for Watch Ad x2
1. Player clicks "Watch Ad x2" button
2. ResultsScreen emits `watch_ad_requested`
3. GameManager calls `PlatformService.show_rewarded_ad("double_earnings")`
4. Fake: returns `true` instantly (0.3s delay)
5. Real: would show an actual ad, callback may return `true` (reward) or `false` (skipped)
6. If `true`, round earnings are doubled and displayed
7. UI updates to reflect the doubled amount

## Important
- Game logic remains platform-agnostic
- `PlatformService` can be extended with real providers by editing only the platform/ folder
- No game script outside platform/ imports ad or IAP modules directly
