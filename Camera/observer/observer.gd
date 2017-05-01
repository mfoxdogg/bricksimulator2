
extends Spatial

# Member variables
var r_pos = Vector2()
var _brick = null
var _pos = Vector2(0,0)
var state

const STATE_MENU = 0
const STATE_GRAB = 1
const USE_JOYSTCK_CAMERA = false
const JOYSTICK_CAMERA_SPEED = 5
const JOYSTICK_CAMERA_DEAD_ZONE = 0.2


func direction(vector):
	var v = get_node("Camera").get_global_transform().basis*vector
	v = v.normalized()
	return v


func impulse(event, action):
	if(event.is_action(action) && event.is_pressed() && !event.is_echo()):
		return true
	else:
		return false


func _fixed_process(delta):
#	if(state != STATE_GRAB):
#		return

#	if(Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
#		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var dir = Vector3()
	var cam = get_global_transform()
	var org = get_translation()

	if (Input.is_action_pressed("move_forward")):
		dir += direction(Vector3(0, 0, -1))
	if (Input.is_action_pressed("move_backwards")):
		dir += direction(Vector3(0, 0, 1))
	if (Input.is_action_pressed("move_left")):
		dir += direction(Vector3(-1, 0, 0))
	if (Input.is_action_pressed("move_right")):
		dir += direction(Vector3(1, 0, 0))

	dir = dir.normalized()

	move(dir*10*delta)
	var d = delta*0.1

	var yaw = get_transform().rotated(Vector3(0, 1, 0), d*r_pos.x)
	set_transform(yaw)

	var camera = get_node("Camera")
	var pitch = camera.get_transform().rotated(Vector3(1, 0, 0), d*r_pos.y)
	camera.set_transform(pitch)

	if(USE_JOYSTCK_CAMERA == false):
		r_pos.x = 0.0
		r_pos.y = 0.0


func _input(event):
	if(event.type == InputEvent.MOUSE_MOTION):
		USE_JOYSTCK_CAMERA = false
		r_pos = event.relative_pos

	if(event.type == InputEvent.JOYPAD_MOTION):		
		USE_JOYSTCK_CAMERA = true
		if(event.axis == 1 || event.axis == 3):
			r_pos.y += event.value * JOYSTICK_CAMERA_SPEED
		if(event.axis == 2 || event.axis == 4):
			r_pos.x += event.value * JOYSTICK_CAMERA_SPEED
		
		if((event.value > 0 && event.value < JOYSTICK_CAMERA_DEAD_ZONE) || (event.value < 0 && event.value > -JOYSTICK_CAMERA_DEAD_ZONE)):
			r_pos.x = 0.0 
			r_pos.y = 0.0
			USE_JOYSTCK_CAMERA = false

	if(impulse(event, "ui_cancel")):
		if(Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			#state = STATE_MENU
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			#state = STATE_GRAB
	
	#THROW BRICK
	if (event.type == InputEvent.MOUSE_BUTTON):
		if (event.pressed):
		    #var pos = Vector2(event.x, event.y)

			if(event.button_index == 1):
				_brick = preload("res://props/brick.tscn").instance().get_node("RigidBody").duplicate()
			
			get_parent().get_parent().add_child(_brick)
			
			_brick.set_translation(Vector3(0,5,0))
			_brick.set_rotation_deg(Vector3(0,(180*randf())-45,0))
			_brick.set_linear_velocity(get_node("Camera").get_transform().basis[2].normalized()*20)
			
	       #brick.set_scale(Vector2(0.5,0.5))  



func _ready():
	set_fixed_process(true)
	set_process_input(true)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	state = STATE_MENU
