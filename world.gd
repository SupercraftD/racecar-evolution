extends Node2D

var car = preload("res://car.tscn")
var seedcar : Car = null

var gen_size = 15
var mutation_rate = 0.2
var mutation_magnitude = 0.75
var cars = []

var gen = 0

# Called when the node enters the scene tree for the first time.
func run():
	for i in range(gen_size):
		var cari = car.instantiate() as Car
		for x in range(len(cari.direction_weights)):
			cari.direction_weights[x] = randf_range(-1,1)
			cari.throttle_weights[x] = randf_range(-1,1)
		cari.checkpoints = $checkpoints
		cari.global_position = $start.global_position
		cars.append(cari)
		add_child(cari)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	
	$Camera2D.position += Input.get_vector("left","right","up","down") * 10
	$CanvasLayer/Label2.text = "Time left: "+str(snappedf($Timer.time_left,0.01))
	
	if Input.is_action_just_pressed("zoomin"):
		$Camera2D.zoom += Vector2(0.2,0.2)
	elif Input.is_action_just_pressed("zoomout"):
		$Camera2D.zoom -= Vector2(0.2,0.2)
	
	for body in $Area2D.get_overlapping_bodies():
		if body is Car:
			body.passed_checkpt = true
	
	var alldead = true
	var mostfit : Car = null
	for car : Car in cars:
		if not car.dead:
			alldead=false
			break
		
		if mostfit==null:
			mostfit = car
		elif car.passed_checkpt:
			if not mostfit.passed_checkpt:
				mostfit = car
			elif car.last_checkpt > mostfit.last_checkpt:
				mostfit = car
	
	if alldead:
		$CanvasLayer/Button.disabled = false
		seedcar = mostfit
		
		if $CanvasLayer/CheckBox.button_pressed:
			_on_button_pressed()

func _on_button_pressed():
	$CanvasLayer/Button.disabled = true
	if gen==0:
		run()
	else:
		
		var stweights = seedcar.throttle_weights.duplicate()
		var sdweights = seedcar.direction_weights.duplicate()
		
		while len(cars)>0:
			cars.pop_front().queue_free()
		
		cars.append(car.instantiate())
		cars[0].throttle_weights = stweights
		cars[0].direction_weights = sdweights
		cars[0].checkpoints = $checkpoints
		cars[0].global_position = $start.global_position
		add_child(cars[0])
		
		for i in range(gen_size-1):
			var cari = car.instantiate() as Car
			
			cari.direction_weights = sdweights.duplicate()
			cari.throttle_weights = stweights.duplicate()
			
			for x in range(len(cari.direction_weights)):
				if randf_range(0,1) < mutation_rate:
					cari.direction_weights[x] += randf_range(-mutation_magnitude,mutation_magnitude)
			for x in range(len(cari.throttle_weights)):
				if randf_range(0,1) < mutation_rate:
					cari.throttle_weights[x] += randf_range(-mutation_magnitude,mutation_magnitude)
			
			cari.checkpoints = $checkpoints
			cari.global_position = $start.global_position + Vector2(randf_range(-10,10),0)
			cars.append(cari)
			add_child(cari)
	
	$Timer.start(10)
	gen+=1
	$CanvasLayer/Label.text = "Gen: "+str(gen)


func _on_timer_timeout():
	$CanvasLayer/Button.disabled = false
	var mostfit : Car = null
	for car : Car in cars:
		
		if mostfit==null:
			mostfit = car
		elif car.laps > 0:
			if mostfit.laps == 0:
				mostfit = car
			elif car.bestlap < mostfit.bestlap:
				mostfit = car
			$CanvasLayer/Label3.text = "Best lap: "+str(mostfit.bestlap)
		elif car.passed_checkpt:
			if not mostfit.passed_checkpt:
				mostfit = car
			elif car.last_checkpt > mostfit.last_checkpt:
				mostfit = car
	
	seedcar = mostfit


func _on_button_2_pressed():
	while len(cars)>0:
		cars.pop_front().queue_free()
	run()
	gen=0

func _on_option_button_item_selected(index):
	Engine.time_scale = [
		0.25, 0.5, 0.75, 1, 2, 4, 8, 16
	][index]
	Engine.physics_ticks_per_second = int(60 * Engine.time_scale)
	Engine.max_physics_steps_per_frame = max(8, int(8 * Engine.time_scale))
