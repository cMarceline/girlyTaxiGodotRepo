extends RigidBody3D

var gs: int = 9.8

var myVelocity : Vector3 

var myGrav : float
var mySpeed : float

enum States {DRIVING, FLYING, FALLING, FLOATING}
var state: States

func _process(delta: float) -> void:
	_stateChecker()
	
	#print(state)

func _physics_process(delta: float) -> void:
	#Rotate around down
	var steer = Input.get_action_raw_strength("SteerL") - Input.get_action_raw_strength("SteerR")
	var steerU = Input.get_action_raw_strength("SteerU") - Input.get_action_raw_strength("SteerD")
	var lean = Input.get_action_raw_strength("leanR") - Input.get_action_raw_strength("leanL")

	transform = transform.rotated_local(Vector3(0,1,0),steer * delta)

	if state == States.FALLING :
		myGrav += gs * delta * 10
		myVelocity.y = -myGrav
	else : 
		myGrav = 0.2

	if state == States.FLOATING :
		transform = transform.rotated_local(Vector3(1,0,0),steerU * delta)
		transform = transform.rotated_local(Vector3(0,0,1),lean * delta)
		linear_velocity = Vector3.ZERO
		return

	if Input.is_action_pressed("Brake"):
		linear_velocity = Vector3.ZERO
		return
		#print("Braking")

	if Input.is_action_pressed("Accelerate") && state != States.FLOATING:
		myVelocity += Vector3(0,0,100 * delta)

	elif state == States.DRIVING :
		myVelocity.z /= 1 + (0.2 * delta)
		myVelocity.z -= clamp(myVelocity.z * 0.2*delta,0,myVelocity.z)

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
	var contact_point = state.get_contact_collider_position(0) #- self.position  linear_velocity
	print(contact_point)



func _steerHandler() : 
	print("yep")

func _stateChecker():
	if Input.is_action_pressed("Free"): state = States.FLOATING
	elif $collisionChecker.is_colliding() : state = States.DRIVING
	elif Input.is_action_pressed("Boost"): state = States.FLYING
	else : state=States.FALLING
