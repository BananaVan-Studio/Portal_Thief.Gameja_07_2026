extends Node

## Central audio. Plays the looping background music (menu + all levels, one
## continuous track) and one-shot sound effects. Everything runs on the Master
## bus, so the settings volume slider controls it all. As an autoload it
## survives scene changes, so the music never stops or restarts between screens.

var _music_player: AudioStreamPlayer

## Music speeds up while inside alarm zones. Counter handles overlapping zones.
const ALARM_MUSIC_PITCH := 2.0
var _alarm_count := 0

var s_portal: AudioStream
var s_advance: AudioStream
var s_back: AudioStream
var s_run: AudioStream
var s_dash: AudioStream
var s_alarm: AudioStream
var s_music: AudioStream


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep sound while the game is paused

	_ensure_buses()

	s_portal = load("res://audio/portal.wav")
	s_advance = load("res://audio/boton_avanzar_en_menu.wav")
	s_back = load("res://audio/boton_atras_en_menu.wav")
	s_run = load("res://audio/correr.mp3")
	s_dash = load("res://audio/dash.wav")
	s_alarm = load("res://audio/alarm.wav")
	s_music = load("res://audio/musica.mp3")

	# Loop the music track (mp3 defaults to no loop).
	if s_music is AudioStreamMP3:
		s_music.loop = true

	_music_player = AudioStreamPlayer.new()
	_music_player.stream = s_music
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
	_sfx(s_portal)


func advance() -> void:
	_sfx(s_advance)


func back() -> void:
	_sfx(s_back)


func run() -> void:
	_sfx(s_run)


func dash() -> void:
	_sfx(s_dash)


func alarm_siren() -> void:
	_sfx(s_alarm)


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
