extends RigidBody3D

const gs: int = 9.8

# Velocity shit ig
var myVelocity : Vector3 
var goalVelocity : Vector3
var myGrav : float
var mySpeed : float

# State Machine for states
enum States {DRIVING, FLYING, FALLING, FLOATING}
var state: States

var collisionArray : Array[RayCast3D]

# Steering Input Variables
var steer : float :
	get : return Input.get_action_raw_strength("SteerL") - Input.get_action_raw_strength("SteerR")
var steerU : float :
	get : return Input.get_action_raw_strength("SteerU") - Input.get_action_raw_strength("SteerD")
var lean : float :
	get : return Input.get_action_raw_strength("leanR") - Input.get_action_raw_strength("leanL")

func _ready() : 
	if 1 == 0 : return

func _process(delta: float) -> void:
	if 1 == 0 : return

# Integrate forces happens on the step before physics processing
# Mostly used for collisionArray
func _integrate_forces(state):
	# Delete collisions and Clear Array
	for n in collisionArray.size() :
		collisionArray[n].queue_free()
	collisionArray.clear()
	# Create the collision Array
	for n in state.get_contact_count() :
		var contactPos = state.get_contact_collider_position(n) - self.position
		collisionArray.append(_newRaycast(contactPos*1.1))
		collisionArray[n].global_rotation = Vector3.ZERO


func _physics_process(delta: float) -> void:
	_steerHandler(delta)
	_stateChecker()
	
	# Find the collision normals that best aligns with cars rotation
	var bestNormal : Vector3 = Vector3.ZERO
	for n in collisionArray.size() : 
		collisionArray[n].force_raycast_update()
		var normal = collisionArray[n].get_collision_normal()
		var normalDot = normal.dot(transform.basis.y)
		if normalDot > bestNormal.dot(transform.basis.y) : 
			bestNormal = normal
	# Align world to bestNormal
	if bestNormal != Vector3.ZERO : 
		print(bestNormal)
	
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

func _newRaycast( pos : Vector3 ) :
	var newRaycast = RayCast3D.new()
	newRaycast.target_position = pos
	self.add_child(newRaycast)
	newRaycast.force_raycast_update()
	return newRaycast

func _steerHandler(delta) : 
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
