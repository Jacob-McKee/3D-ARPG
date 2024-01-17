extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 6
const mouse_sensitivity = .01

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


@onready var camera = $SpringArm3D
@onready var model = $Knight
@onready var animation_tree = $AnimationTree

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera.rotation.x -= event.relative.y * mouse_sensitivity
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -80, 80)
		camera.rotation.y -= event.relative.x * mouse_sensitivity


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		animation_tree["parameters/Fall/blend_amount"] = lerp(animation_tree["parameters/Fall/blend_amount"], 1.0, 0.2)
	else:
		animation_tree["parameters/Fall/blend_amount"] = lerp(animation_tree["parameters/Fall/blend_amount"], 0.0, 0.2)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3.UP, camera.rotation.y)
	animation_tree["parameters/IdleRunning/blend_amount"] = lerp(animation_tree["parameters/IdleRunning/blend_amount"], direction.length(), 0.1)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, camera.rotation.y, 0.1)
		animation_tree.set("parameters/Running/blend_position", lerp(animation_tree["parameters/Running/blend_position"], input_dir, 0.3))
