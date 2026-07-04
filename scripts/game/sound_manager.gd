extends Node

# SoundManager — generates and plays simple placeholder sounds
# Uses AudioStreamWAV generated at runtime — no external audio files needed.
# Autoload registered by Game.tscn.

var _correct_player: AudioStreamPlayer
var _wrong_player: AudioStreamPlayer
var _coin_player: AudioStreamPlayer


func _ready() -> void:
	_setup_players()


func _setup_players() -> void:
	_correct_player = _make_player(_generate_tone(523.25, 0.08))   # C5 — short pleasant beep
	_wrong_player = _make_player(_generate_tone(220.0, 0.12))      # A3 — lower buzz
	_coin_player = _make_player(_generate_tone(784.0, 0.06))       # G5 — short bright ping
	add_child(_correct_player)
	add_child(_wrong_player)
	add_child(_coin_player)


func _make_player(stream: AudioStream) -> AudioStreamPlayer:
	var p: AudioStreamPlayer = AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = -6.0
	return p


func play_correct() -> void:
	_correct_player.play()


func play_wrong() -> void:
	_wrong_player.play()


func play_coin() -> void:
	_coin_player.play()


func _generate_tone(freq: float, duration: float) -> AudioStreamWAV:
	# Generate a simple sine wave as a WAV stream
	var sample_rate: int = 22050
	var sample_count: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)  # 16-bit = 2 bytes
	
	for i in range(sample_count):
		var envelope: float = 1.0
		if i < sample_count * 0.05:  # 5% attack
			envelope = float(i) / (sample_count * 0.05)
		elif i > sample_count * 0.7:  # 30% release
			envelope = float(sample_count - i) / (sample_count * 0.3)
		
		var sample: float = sin(2.0 * PI * freq * i / sample_rate) * envelope * 0.25
		var int_sample: int = int(clampf(sample * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, int_sample)
	
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	return wav
