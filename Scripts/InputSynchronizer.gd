extends MultiplayerSynchronizer

@export var jumping := false

# Synchronized property.
@export var direction := Vector2()

func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


@rpc("call_local")
func jump():
	jumping = true


func _process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	if Input.is_action_just_pressed("player_jump"):
		jump.rpc()
