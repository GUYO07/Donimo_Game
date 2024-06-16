extends Node


var dragging = false
var dragging2 = false
var click_radius = 10 # Size of the sprite.
@onready var camera:Camera3D = $camera_base/camera_socket/Camera3D
#@onready var domino:RigidBody3D = $domino
var drag_offset = Vector3()
var holding = false
var holding2 = false
var ray_lenght = 1000

var predomino = preload("res://Scenes/domino.tscn")
var predomino_script = preload("res://Scenes/domino.gd")

var select_domino= null
var select_box= null
var last_position=null

var donimo_is_rotating = false
var donimo_rotation_direction:int = 0

func _ready():
	camera = get_viewport().get_camera_3d()
	if camera == null:
		print("Camera not found!")
		
func _process(delta:float) -> void:
	domino_rotate(delta)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			
			if holding: 
				holding = false
				return
				
			if holding2: 
				holding2 = false
				return

			var result = ray_calculate(event.position)
			print(result.collider.name)
			
			if result and (result.position - result.collider.global_transform.origin).length() < click_radius :
				
				drag_offset = result.collider.global_transform.origin - result.position
				if result.collider.name.find("domino") != -1:
					dragging = true
					holding = true
				if result.collider.name.find("box") != -1:
					dragging2 = true
					holding2 = true

		if dragging and not holding:
			dragging = false
			if(select_domino != null):
				domino_not_move(select_domino)
				select_domino = null
				
		if dragging2 and not holding2:
			dragging2 = false
			if(select_box != null):
				domino_not_move(select_box)
				select_box = null

#move domino
	if event is InputEventMouseMotion and dragging:

		if(select_domino != null):
			domino_move(select_domino)
			
		var result = ray_calculate(event.position)
		
		if result:
			var new_position = result.position + drag_offset
			new_position.y = 10
			last_position = new_position
			if(select_domino == null):
				if result.collider.name.find("domino") != -1:
					select_domino = result.collider
# move box
	if event is InputEventMouseMotion and dragging2:

		if(select_box != null):
			select_box.global_transform.origin = last_position
			select_box.freeze = true
		
		var result = ray_calculate(event.position)
		
		if result:
			var new_position = result.position + drag_offset
			new_position.y = 8
			last_position = new_position
			if(select_box == null):
				if result.collider.name.find("box") != -1:
					select_box = result.collider

# add domino
	if event.is_action_pressed("add") and dragging:
		var instance = predomino.instantiate()
		instance.position = last_position
		instance.position.y = 0
		instance.rotation = select_domino.rotation
		#instance.set_script(predomino_script)
		$'../.'.add_child(instance)
# rotate domino
	if event.is_action_pressed("d_rotate_L") and dragging:
		donimo_rotation_direction = 1
		donimo_is_rotating = true
	elif event.is_action_pressed("d_rotate_R") and dragging:
		donimo_rotation_direction = -1 
		donimo_is_rotating = true
	elif event.is_action_released("d_rotate_R") or event.is_action_released("d_rotate_L"):
		donimo_is_rotating = false

func ray_calculate(mouse_pos):
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_lenght
	var space = camera.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var result = space.intersect_ray(ray_query)
	
	return result
	
func domino_move(domino):
	domino.global_transform.origin = last_position
	domino.freeze = true
	#select_domino.collision_priority = 0
	domino.collision_layer = 0
	domino.collision_mask = 0
	
func domino_not_move(domino):
	domino.freeze = false
	#select_domino.collision_priority = 1
	domino.collision_layer = 1
	domino.collision_mask = 1
	
func domino_rotate(delta:float) -> void:
	if !donimo_is_rotating:return
	# To rotate
	domino_rotate_left_right(delta,donimo_rotation_direction * 6)
	
func domino_rotate_left_right(delta:float,dir:float) -> void:
	select_domino.rotation.y += dir * 0.2 * delta
	
	
