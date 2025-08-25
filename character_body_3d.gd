extends RigidBody3D

var gs: int = -9.8
var myVelocity : Vector3 

enum States {DRIVING, FLYING, FALLING, FLOATING}
var state: States

func _process(delta: float) -> void:
	_stateChecker()
	#print(state)

func _physics_process(delta: float) -> void:
	#Rotate around down
	var steer = Input.get_action_raw_strength("SteerL") - Input.get_action_raw_strength("SteerR")
	transform = transform.rotated_local(Vector3(0,1,0),steer * delta)

	if state == States.FALLING :
		myVelocity += Vector3(0,gs*delta,0)

	if Input.is_action_pressed("Accelerate") && state != States.FLOATING:
		myVelocity += Vector3(0,0,100 * delta)

	linear_velocity = (
		transform.basis.x * myVelocity.x + 
		transform.basis.y * myVelocity.y + 
		transform.basis.z * myVelocity.z
	)
	# Lerp into the forward velocity
	# Get the normal vector of a collision

	var steerU = Input.get_action_raw_strength("SteerU") - Input.get_action_raw_strength("SteerD")
	var lean = Input.get_action_raw_strength("leanL") - Input.get_action_raw_strength("leanR")
	if state == States.FLOATING :
		transform = transform.rotated_local(Vector3(1,0,0),steerU * delta)
		transform = transform.rotated_local(Vector3(0,0,1),lean * delta)
		linear_velocity = Vector3.ZERO


	if Input.is_action_pressed("Brake"):
		linear_velocity = Vector3.ZERO
		print("Braking")

	print(linear_velocity)

func _stateChecker():
	if Input.is_action_pressed("Free"): state = States.FLOATING
	elif $collisionChecker.is_colliding() : state = States.DRIVING
	elif Input.is_action_pressed("Boost"): state = States.FLYING
	else : state=States.FALLING
