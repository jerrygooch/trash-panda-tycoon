# Trash Panda Tycoon — Game Design Document

## Concept

Trash Panda Tycoon is a hypercasual/idle mobile game. The player runs a raccoon trash empire. Items slide down a conveyor belt. The player drags/swipes items into the correct bins. Correct sorting gives coins. Wrong sorting fills a mess meter. Coins buy upgrades. Rounds are 30 seconds.

The game targets short play sessions with a clear core loop:

**Clear action → instant reward → number goes up → upgrade → faster chaos**

## Core Loop

1. Items spawn at the top of a conveyor belt and move downward
2. Player drags items into one of three bins: Food, Metal, Plastic
3. Correct bin → +coins + positive feedback
4. Wrong bin → +mess + negative feedback
5. Item reaches bottom unsorted → +mess + removed
6. After 30 seconds or mess meter full → round ends
7. Results screen shows stats
8. Player starts next round or buys upgrades

## Game Elements

### Trash Items (6 types)

| Item | Category | Base Value |
|------|----------|-----------|
| Banana Peel | Food | 1 |
| Pizza Slice | Food | 2 |
| Soda Can | Metal | 2 |
| Tin Can | Metal | 1 |
| Plastic Bottle | Plastic | 2 |
| Plastic Bag | Plastic | 1 |

### Bins (3 types)

- Food (green)
- Metal (gray)
- Plastic (blue)

Each bin accepts its category. Wrong bin = mess increase.

### Mess Meter

- Starts at 0
- Increases by 1 per wrong sort or missed item
- Base capacity: 5
- Upgradeable via Mess Capacity upgrade
- When full → round ends immediately

### Upgrades

| Upgrade | Max Level | Base Cost | Effect |
|---------|-----------|-----------|--------|
| Trash Value | 10 | 50 | +1 coin per sort per level |
| Spawn Rate | 10 | 75 | -0.15s spawn interval per level (min 0.4s) |
| Mess Capacity | 10 | 100 | +2 max mess per level |
| Offline Earnings | 10 | 200 | Placeholder (no runtime effect) |

## Monetization (MVP stubs)

- **Rewarded ad "Watch Ad x2":** Doubles round earnings, fake stub returns success
- **Interstitial ad:** Between rounds, logs to console only
- **IAP "Remove Ads":** Logs to console, flag stored in save
- No real SDKs, no real ads, no real IAP in MVP

## Future Ideas

- More trash types (paper, glass, e-waste)
- Bin upgrades (faster sorting, auto-sort)
- Leaderboards
- Daily challenges
- Raccoon mascot customisation
- Multi-row conveyor
- Combo bonuses for consecutive correct sorts ✅ (implemented)
- Offline earnings (basic implementation — cap, claim message, save/load timestamp)
