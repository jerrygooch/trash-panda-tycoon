extends Node

# SoundManager — procedural sounds with volume control

var _correct_player: AudioStreamPlayer
var _wrong_player: AudioStreamPlayer
var _coin_player: AudioStreamPlayer
var _combo_player: AudioStreamPlayer
var _tap_player: AudioStreamPlayer


func _ready() -> void:
	_setup_players()


func _setup_players() -> void:
	_correct_player = _make_player(_generate_tone(523.25, 0.08))
	_wrong_player = _make_player(_generate_tone(220.0, 0.12))
	_coin_player = _make_player(_generate_tone(784.0, 0.06))
	_combo_player = _make_player(_generate_tone(1046.5, 0.15))   # C6 bright chime
	_tap_player = _make_player(_generate_tone(440.0, 0.04))      # A4 short click
	add_child(_correct_player)
	add_child(_wrong_player)
	add_child(_coin_player)
	add_child(_combo_player)
	add_child(_tap_player)


func _make_player(stream: AudioStream) -> AudioStreamPlayer:
	var p: AudioStreamPlayer = AudioStreamPlayer.new()
	p.stream = stream
	return p


func _sync_volume() -> void:
	var db: float = -6.0
	if GameState and GameState.settings.has("sfx_enabled") and not GameState.settings.sfx_enabled:
		db = -80.0
	for p in [_correct_player, _wrong_player, _coin_player, _combo_player, _tap_player]:
		p.volume_db = db


func play_correct() -> void: _sync_volume(); _correct_player.play()
func play_wrong() -> void: _sync_volume(); _wrong_player.play()
func play_coin() -> void: _sync_volume(); _coin_player.play()
func play_combo() -> void: _sync_volume(); _combo_player.play()
func play_tap() -> void: _sync_volume(); _tap_player.play()


func _generate_tone(freq: float, duration: float) -> AudioStreamWAV:
	var sr: int = 22050
	var n: int = int(sr * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(n * 2)
	for i in range(n):
		var env: float = 1.0
		if i < n * 0.05: env = float(i) / (n * 0.05)
		elif i > n * 0.7: env = float(n - i) / (n * 0.3)
		var s: float = sin(2.0 * PI * freq * i / sr) * env * 0.25
		data.encode_s16(i * 2, int(clampf(s * 32767.0, -32768.0, 32767.0)))
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.data = data; wav.format = AudioStreamWAV.FORMAT_16_BITS; wav.mix_rate = sr
	return wav
