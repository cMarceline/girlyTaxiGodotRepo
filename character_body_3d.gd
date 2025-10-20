extends RigidBody3D

const gs: float = 9.8

# Velocity shit ig
var myVelocity : Vector3 
var goalVelocity : Vector3
var myGrav : float
var mySpeed : float

# State Machine for states
enum States {DRIVING, FLYING, FALLING, FLOATING}
var myState: States

var collisionArray : Array[RayCast3D]

var lean : float :
	get : return Input.get_action_raw_strength("leanR") - Input.get_action_raw_strength("leanL")

func _ready() : 
	if 1 == 0 : return

func _process(_delta: float) -> void:
	if 1 == 0 : return

# Integrate forces happens on the step before physics processing
# Mostly used for collisionArray
func _integrate_forces(state):
	# Delete collisions and Clear Array
	for n in collisionArray.size() :
		collisionArray[n].queue_free()
	collisionArray.clear()
	# Create the Collision Array
	for n in state.get_contact_count() :
		var contactPos = state.get_contact_collider_position(n) - self.position
		collisionArray.append(_newRaycast(contactPos*1.1))
		collisionArray[n].global_rotation = Vector3.ZERO


func _physics_process(delta: float) -> void:
	_steerHandler(delta)
	_stateChecker()
	
	# Align world to bestNormal
	var surfaceNormal = _bestNormal(transform.basis.y)
	if collisionArray.size() > 0 :
		myState = States.DRIVING
	
	# Apply Gravity when Falling
	if myState == States.FALLING :
		myGrav += gs * delta * 10
	else : 
		myGrav = 0.2
	myVelocity.y = -myGrav
	
	# Freeze in Float
	if myState == States.FLOATING :
		linear_velocity = Vector3.ZERO
		return
		
	# Debug Braking
	if Input.is_action_pressed("Brake"):
		myVelocity = Vector3.ZERO
		
	# Acceleration when Not Floating
	if Input.is_action_pressed("Accelerate") && myState != States.FLOATING:
		myVelocity += Vector3(0.0,0.0,5.0 * delta)
		
	# Applying Friction
	elif myState == States.DRIVING :
		myVelocity.z -= delta / 2 * myVelocity.z
		
	goalVelocity = (
		transform.basis.x * myVelocity.x +
		transform.basis.y * myVelocity.y + 
		transform.basis.z * myVelocity.z
	)

	linear_velocity = goalVelocity #linear_velocity.lerp(goalVelocity,delta)
	# Lerp into the forward velocity
	# Get the normal vector of a collision

# Finds the normal most aligned with the car by checking the collisionArray
func _bestNormal( inVector : Vector3 ) : 
	var bestNormal : Vector3 = Vector3.ZERO
	for n in collisionArray.size() : 
		collisionArray[n].force_raycast_update()
		var normal = collisionArray[n].get_collision_normal()
		var normalDot = normal.dot(inVector)
		var bestNormDot = bestNormal.dot(inVector)
		if normalDot >  bestNormDot : 
			bestNormal = normal
	return bestNormal

func _lockOn( inputVector : Vector3 ) : 
	# Ensure bestNormal is normalized
	inputVector = inputVector.normalized()
	# Choose a forward direction (your cart’s current forward, usually -Z)
	var forward = -global_transform.basis.z
	# Make forward orthogonal to the new up vector
	forward = (forward - inputVector * (forward.dot(inputVector))).normalized()
	# Compute the right vector with cross product
	var right = forward.cross(inputVector).normalized()
	# Build the new basis
	var new_basis = Basis()
	new_basis.x = right
	new_basis.y = inputVector
	new_basis.z = -forward
	# Apply to rigid body (snaps instantly)
	global_transform.basis = new_basis

func _newRaycast( pos : Vector3 ) :
	var newRaycast = RayCast3D.new()
	newRaycast.target_position = pos
	self.add_child(newRaycast)
	newRaycast.force_raycast_update()
	return newRaycast

func _steerHandler(delta) : 
	# Stick Steering
	transform = transform.rotated_local(Vector3(0,1,0),Global.lStick.x * delta)
	if myState == States.FLOATING :
		transform = transform.rotated_local(Vector3(1,0,0),Global.rStick.y * delta)
		transform = transform.rotated_local(Vector3(0,0,1),lean * delta)

func _stateChecker():
	if Input.is_action_pressed("Free"): myState = States.FLOATING
	elif $collisionChecker.is_colliding() : myState = States.DRIVING
	elif Input.is_action_pressed("Boost"): myState = States.FLYING
	else : myState = States.FALLING
