extends Node

## Music speeds up while inside alarm zones. Counter handles overlapping zones.
const ALARM_MUSIC_PITCH := 1.5

const S_ALARM = preload("uid://dnosrnjr4ejm7")
const S_BACK = preload("uid://dm6ayxlhy4sqi")
const S_ADVANCE = preload("uid://cri6ohel3020k")
const S_RUN = preload("uid://cctg67vvkk15n")
const S_DASH = preload("uid://b1rlutl30sopg")
const S_MUSIC = preload("uid://dd26642jn0lna")
const S_PORTAL = preload("uid://sd4adlodp52g")

## Central audio. Plays the looping background music (menu + all levels, one
## continuous track) and one-shot sound effects. Everything runs on the Master
## bus, so the settings volume slider controls it all. As an autoload it
## survives scene changes, so the music never stops or restarts between screens.

var _music_player: AudioStreamPlayer
var _alarm_count := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # keep sound while the game is paused

	_ensure_buses()

	_music_player = AudioStreamPlayer.new()
	_music_player.stream = S_MUSIC
	_music_player.bus = "Music"
	add_child(_music_player)
	_music_player.play()

	# Buses exist now, so push the saved Music/SFX volumes onto them.
	Game.set_music_volume(Game.music_volume)
	Game.set_sfx_volume(Game.sfx_volume)


# --- Named effects ------------------------------------------------------
func portal() -> void:
	_sfx(S_PORTAL, 10)


func advance() -> void:
	_sfx(S_ADVANCE, 15)


func back() -> void:
	_sfx(S_BACK, 15)


func run() -> void:
	_sfx(S_RUN, 5)


func dash() -> void:
	_sfx(S_DASH, 5)


func alarm_siren() -> void:
	_sfx(S_ALARM, -25)


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


func _ensure_buses() -> void:
	# Music and SFX are sub-buses that route into Master.
	for bus_name in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, "Master")


func _sfx(stream: AudioStream, intensity: float = 0) -> void:
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	if intensity:
		p.volume_db = intensity
	p.stream = stream
	p.bus = "SFX"
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


func _apply_music_pitch() -> void:
	if _music_player:
		_music_player.pitch_scale = ALARM_MUSIC_PITCH if _alarm_count > 0 else 1.0
