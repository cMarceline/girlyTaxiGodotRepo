extends RigidBody3D

var gs: int = 9.8

var myVelocity : Vector3 
var goalVelocity : Vector3

var myGrav : float
var mySpeed : float
var currentVelocity : Vector3

enum States {DRIVING, FLYING, FALLING, FLOATING}
var state: States

func _process(delta: float) -> void:
	_stateChecker()
	
	#print(state)

func _physics_process(delta: float) -> void:
	# Gives scales for all the various input Directions
	var steer = Input.get_action_raw_strength("SteerL") - Input.get_action_raw_strength("SteerR")
	var steerU = Input.get_action_raw_strength("SteerU") - Input.get_action_raw_strength("SteerD")
	var lean = Input.get_action_raw_strength("leanR") - Input.get_action_raw_strength("leanL")
	_steerHandler(steer, steerU, lean, delta)
	
	# Apply Gravity when Falling
	if state == States.FALLING :
		myGrav += gs * delta * 10
	else : 
		myGrav = 0.2
	myVelocity.y = -myGrav
	
	# Freeze in Float
	if state == States.FLOATING :
		linear_velocity = Vector3.ZERO
		return

	# Debug Braking
	if Input.is_action_pressed("Brake"):
		myVelocity = Vector3.ZERO
		#return
		#print("Braking")

	# Acceleration when Not Floating
	if Input.is_action_pressed("Accelerate") && state != States.FLOATING:
		myVelocity += Vector3(0,0,100 * delta)
	
	# Applying Friction
	elif state == States.DRIVING :
		myVelocity.z -= delta / 2 * myVelocity.z

	var goalVelocity : Vector3 = (
		transform.basis.x * myVelocity.x +
		transform.basis.y * myVelocity.y + 
		transform.basis.z * myVelocity.z
	)
	
	linear_velocity = goalVelocity #linear_velocity.lerp(goalVelocity,delta)
	# Lerp into the forward velocity
	# Get the normal vector of a collision

	#print(myVelocity.z)
	#print(linear_velocity)

func _integrate_forces(state):
	var contact_point = state.get_contact_collider_position(0) - self.position
	print(contact_point)



func _steerHandler(steer, steerU, lean, delta) : 
	# Stick Steering
	transform = transform.rotated_local(Vector3(0,1,0),steer * delta)
	if state == States.FLOATING :
		transform = transform.rotated_local(Vector3(1,0,0),steerU * delta)
		transform = transform.rotated_local(Vector3(0,0,1),lean * delta)

func _stateChecker():
	if Input.is_action_pressed("Free"): state = States.FLOATING
	elif $collisionChecker.is_colliding() : state = States.DRIVING
	elif Input.is_action_pressed("Boost"): state = States.FLYING
	else : state=States.FALLING
