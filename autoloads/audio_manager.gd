extends Node

## Central audio. Plays the looping background music (menu + all levels, one
## continuous track) and one-shot sound effects. Everything runs on the Master
## bus, so the settings volume slider controls it all. As an autoload it
## survives scene changes, so the music never stops or restarts between screens.

var _music_player: AudioStreamPlayer

## Music speeds up while inside alarm zones. Counter handles overlapping zones.
const ALARM_MUSIC_PITCH := 2.0
var _alarm_count := 0

const S_ALARM = preload("uid://dnosrnjr4ejm7")
const S_BACK = preload("uid://dm6ayxlhy4sqi")
const S_ADVANCE = preload("uid://cri6ohel3020k")
const S_RUN = preload("uid://cctg67vvkk15n")
const S_DASH = preload("uid://b1rlutl30sopg")
const S_MUSIC = preload("uid://dd26642jn0lna")
const S_PORTAL = preload("uid://sd4adlodp52g")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep sound while the game is paused

	_ensure_buses()

	_music_player = AudioStreamPlayer.new()
	_music_player.stream = S_MUSIC
	_music_player.bus = "Music"
	add_child(_music_player)
	_music_player.play()

	# Buses exist now, so push the saved Music/SFX volumes onto them.
	Game.set_music_volume(Game.music_volume)
	Game.set_sfx_volume(Game.sfx_volume)


func _ensure_buses() -> void:
	# Music and SFX are sub-buses that route into Master.
	for bus_name in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, "Master")


func _sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.bus = "SFX"
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


# --- Named effects ------------------------------------------------------
func portal() -> void:
	_sfx(S_PORTAL)


func advance() -> void:
	_sfx(S_ADVANCE)


func back() -> void:
	_sfx(S_BACK)


func run() -> void:
	_sfx(S_RUN)


func dash() -> void:
	_sfx(S_DASH)


func alarm_siren() -> void:
	_sfx(S_ALARM)


# --- Music tempo (alarm zones) -----------------------------------------
func alarm_enter() -> void:
	_alarm_count += 1
	_apply_music_pitch()


func alarm_exit() -> void:
	_alarm_count = max(0, _alarm_count - 1)
	_apply_music_pitch()


## Called on scene changes so a death/exit inside an alarm can't leave the
## music stuck fast.
func reset_music_speed() -> void:
	_alarm_count = 0
	_apply_music_pitch()


func _apply_music_pitch() -> void:
	if _music_player:
		_music_player.pitch_scale = ALARM_MUSIC_PITCH if _alarm_count > 0 else 1.0
