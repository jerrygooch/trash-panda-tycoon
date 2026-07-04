extends Node

# Tuning — central configuration for all tunable game constants
# Autoload. Access via Tuning.CONSTANT_NAME from any script.
# Change values here to tune gameplay; no need to hunt through files.

# --- Round ---
const ROUND_DURATION: float = 30.0

# --- Spawning ---
const BASE_SPAWN_INTERVAL: float = 1.8
const MIN_SPAWN_INTERVAL: float = 0.5
const SPAWN_RATE_EFFECT: float = 0.15  # seconds faster per level

# --- Scoring ---
const TRASH_VALUE_EFFECT: int = 1  # extra coin per level
const BASE_PENALTY_MISS: int = 1   # mess increment per missed item
const BASE_PENALTY_WRONG: int = 1  # mess increment per wrong sort

# --- Mess ---
const BASE_MESS_CAPACITY: int = 5
const MESS_CAPACITY_EFFECT: int = 2  # extra capacity per level

# --- Combo ---
const COMBO_MILESTONE: int = 5
const COMBO_BONUS: int = 4  # base bonus coins at each milestone

# --- Performance ---
const MAX_ACTIVE_ITEMS: int = 30

# --- Offline ---
const OFFLINE_RATE_PER_LEVEL: float = 0.5  # coins per minute
const OFFLINE_MAX_MINUTES: float = 120.0

# --- Early-game tuning (rounds 1-3) ---
const EARLY_MESS_EXTRA: int = 2      # extra mess capacity for first 3 rounds
const EARLY_SPAWN_BONUS: float = 0.3  # extra seconds on spawn interval

# --- Missions ---
const MISSION_COUNT: int = 5
const MISSION_SORT_25_REWARD: int = 100
const MISSION_COMBO_10_REWARD: int = 150
const MISSION_COINS_500_REWARD: int = 200
const MISSION_ROUNDS_3_REWARD: int = 75
const MISSION_UPGRADE_1_REWARD: int = 100

# --- Daily reward ---
const DAILY_REWARD_AMOUNT: int = 50

# --- Upgrades ---
const UPGRADE_COST_MULTIPLIER: float = 1.8
const UPGRADE_COST_BASE: int = 50
