extends Node

const BOOST_SOUND = preload("res://audio/booster_1.wav")
const WARP_SOUND = preload("res://audio/spaceEngine_000.ogg")
const LASER_SOUND = preload("res://audio/laserRetro_004.ogg")
const BARREL_ROLL_SOUND = preload("res://audio/phaserUp3.ogg")
const COLLECT_SOUND = preload("res://audio/pepSound3.ogg")
const TIOLET_SOUND = preload("res://audio/Toilet.ogg")
const HIGH_DOWN_SOUND = preload("res://audio/highDown.ogg")
const HIGH_UP_SOUND = preload("res://audio/highUp.ogg")
const PEP_SOUND_1 = preload("res://audio/pepSound1.ogg")
const PEP_SOUND_2 = preload("res://audio/pepSound2.ogg")
const PEP_SOUND_3 = preload("res://audio/pepSound3.ogg")
const PEP_SOUND_4 = preload("res://audio/pepSound4.ogg")
const PEP_SOUND_5 = preload("res://audio/pepSound5.ogg")
const PHASER_UP_SOUND_1 = preload("res://audio/phaserUp1.ogg")
const PHASER_UP_SOUND_2 = preload("res://audio/phaserUp2.ogg")
const PHASER_UP_SOUND_3 = preload("res://audio/phaserUp3.ogg")
const TWO_TONE_SOUND_1 = preload("res://audio/twoTone1.ogg")
const TWO_TONE_SOUND_2 = preload("res://audio/twoTone2.ogg")
const KEY_SOUND = preload("res://audio/tone1.ogg")
const ERROR_SOUND = preload("res://audio/phaserDown3.ogg")
const SUCCESS_SOUND = preload("res://audio/powerUp7.ogg")


const MISSION_FAILED_AUDIO = preload("res://audio/capcom/Mission failed.mp3")
const MISSION_COMPLETE_AUDIO = preload("res://audio/capcom/Mission complete.mp3")
const ENABLE_LANDING_BOOSTERS = preload("res://audio/capcom/enable_landing_boosters.mp3")
const TURN_ON_LANDING_LIGHTS = preload("res://audio/capcom/turn_on_landing_lights.mp3")
const LAND_ROCKET_SHIP = preload("res://audio/capcom/land_rocket_ship.mp3")



func play_sound(sound: Resource):
	# Create a new 3D player node
	var player = AudioStreamPlayer.new()
	
	# Set the sound stream
	player.stream = sound
	
	# Add the player to the scene tree
	get_tree().root.add_child(player)
	
	# max volume is 0 db
	player.volume_db = 0.0
	
	# Start playback
	player.play()
	
	# Connect the signal that fires when the sound is finished
	# This automatically removes the temporary node to clean up memory.
	player.finished.connect(player.queue_free)
	
