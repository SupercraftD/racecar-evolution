class_name Car extends CharacterBody2D

func _ready():
	$RedyellowcarRemovebgPreview.texture = [
		preload("res://assets/bluegreencar-removebg-preview.png"),
		preload("res://assets/blueyellowcar-removebg-preview.png"),
		preload("res://assets/graycar-removebg-preview.png"),
		preload("res://assets/greenyellowcar-removebg-preview.png"),
		preload("res://assets/redyellowcar-removebg-preview.png")
	].pick_random()
	
	for x in range(len(checkpoints.get_children())):
		passed_checkpts.append(false)


const SPEED = 1.0
const friction = 0.5

var throttle = 0.0

const max_throttle = 6
const direction_steps = 8

var direction = 0.0

var passed_checkpts = []

func gather_inputs():
	var inputs = []
	for ray : RayCast2D in $Rays.get_children():
		if not ray.is_colliding():
			inputs.append(1)
		else:
			inputs.append(global_position.distance_squared_to(ray.get_collision_point()) / ray.target_position.length_squared())
	
	inputs.append(throttle / max_throttle)
	inputs.append(direction / 360)
	
	return inputs

var throttle_weights = [
	0.0,
	0.0,
	0.0,
	0.0,
	0.0,
	0.0,
	0.0
]

var direction_weights = [
	0.0,
	0.0,
	0.0,
	0.0,
	0.0,
	0.0,
	0.0
]

func do_dot(a1, a2):
	var total = 0
	for i in range(len(a1)):
		total += a1[i] * a2[i]
	return total

func use_brain():
	var i = gather_inputs()
	var t = tanh(do_dot(i, throttle_weights))
	throttle += t
	throttle = clampf(throttle, -max_throttle, max_throttle)
	
	var d = tanh(do_dot(i, direction_weights))
	direction += d * direction_steps
	direction = wrapf(direction, 0.0, 360.0)

var checkpoints = null

var last_checkpt = -1
var passed_checkpt = false
var dead = false

var laps = 0
var bestlap = INF
var time = 0
var time_since_progress = 0

func _physics_process(delta):
	time+=delta
	time_since_progress += delta
	if time_since_progress >= 3 and not dead:
		if laps>0:
			print("failed but shouldve lapped")
		dead=true

	if dead:return
	use_brain()
	
	velocity = velocity.move_toward(Vector2.ZERO, friction)
	velocity += (Vector2(0,-1) * SPEED * throttle).rotated(deg_to_rad(direction))
	velocity = velocity.limit_length(SPEED*max_throttle)
	
	if velocity != Vector2.ZERO:
		global_rotation = velocity.angle() + PI/2
	
	var next_checkpt_index = (last_checkpt + 1) % checkpoints.get_child_count()
	var target_checkpt = checkpoints.get_child(next_checkpt_index)
	
	if global_position.distance_squared_to(target_checkpt.global_position) < 40000: # 100^2
		passed_checkpts[next_checkpt_index] = true
		last_checkpt = next_checkpt_index
		time_since_progress = 0
		
		# Check if this was the final checkpoint required to complete the lap
		if next_checkpt_index == 0 and passed_checkpts[1]:
			laps += 1
			print("lapped! Total laps: ", laps)
			
			if time < bestlap or bestlap == 0:
				bestlap = time
			time = 0
			
			# Reset checkpoint array for the next lap
			for i in range(passed_checkpts.size()):
				passed_checkpts[i] = false
	
	var col = move_and_collide(velocity)
	if col:
		dead = true
		
