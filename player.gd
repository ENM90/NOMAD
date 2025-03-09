# player.gd
extends CharacterBody3D

# Nodos
@onready var nek = $nek
@onready var head = $nek/head
@onready var eyes = $nek/head/eyes
@onready var standing_colission_shape = $standing_colission_shape
@onready var crouching_colission_shape = $crouching_colission_shape
@onready var ray_cast_3d = $RayCast3D
@onready var camera_3d = $nek/head/eyes/Camera3D
@onready var animation_player = $nek/head/eyes/AnimationPlayer

# Gravedad dinámica
var gravity: float = 18.8  # Gravedad base
var max_fall_speed: float = 200.0  # Velocidad máxima de caída
var fall_time: float = 0.0  # Tiempo que llevas cayendo
var fall_acceleration: float = 3.0  # Factor de aceleración de la caída

# Física de caída rápida
var ff_active: bool = false
const ff_threshold = -20.0  # Posición en Y para activar la caída rápida
const ff_gravity = 20.0  # Gravedad aumentada para la caída rápida
const ff_max_speed = 500.0  # Velocidad máxima de caída rápida


const jump_velocity = 9.0
var is_jumping: bool = false
var jump_time: float = 0.0

# Velocidades
var current_speed = 8.0
const walking_speed = 8.0
const sprinting_speed = 13.0
const crouching_speed = 5.0

# Estados
var idle_state = preload("res://states/idle-state.gd").new()
var walking_state = preload("res://states/walking-state.gd").new()
var sprinting_state = preload("res://states/sprinting-state.gd").new()
var crouching_state = preload("res://states/crouching-state.gd").new()
var sliding_state = preload("res://states/sliding-state.gd").new()
var jumping_state = preload("res://states/jumping-state.gd").new()
var falling_state = preload("res://states/falling-state.gd").new()
var current_state: Node
var previous_state: Node

# Variables de movimiento
const mouse_sens = 0.20
var crouching_depth = -0.5
var direction = Vector3.ZERO
var acceleration = 10.0  # Aceleración para suavizar el movimiento
var max_air_speed = 100.0  # Velocidad máxima en el aire antes de reducir el control
var air_control = 0.8  # Control en el aire (1 = completo)


var current_state_name: String = "idle"  # Nombre del estado actual

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Asignar el jugador a cada estado
	idle_state.player = self
	walking_state.player = self
	sprinting_state.player = self
	crouching_state.player = self
	sliding_state.player = self
	jumping_state.player = self
	falling_state.player = self
	# Iniciar en el estado IDLE
	change_state(idle_state)

func change_state(new_state: Node) -> void:
	if current_state:
		current_state.exit()
	previous_state = current_state
	current_state = new_state
	current_state.enter()
	current_state_name = _get_state_name(new_state)
	

func _get_state_name(state: Node) -> String:
	if state == idle_state:
		return "idle"
	elif state == walking_state:
		return "walking"
	elif state == sprinting_state:
		return "sprinting"
	elif state == crouching_state:
		return "crouching"
	elif state == sliding_state:
		return "sliding"
	elif state == jumping_state:
		return "jumping"
	elif state == falling_state:
		return "falling"
	else:
		return "unknown"

	
func _input(event):
	if event is InputEventMouseMotion:
		# Rotar el jugador en el eje Y (izquierda/derecha)
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		
		# Rotar la cabeza (cámara) en el eje X (arriba/abajo)
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		
		# Limitar la rotación de la cámara para que no gire demasiado
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	# Calcular la dirección de movimiento basada en la rotación del jugador
	direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

	# Aplicar movimiento horizontal
	if is_on_floor():
		# Movimiento en el suelo
		velocity.x = lerp(velocity.x, direction.x * current_speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, acceleration * delta)
	else:
		# Movimiento en el aire (control reducido)
		velocity.x = lerp(velocity.x, direction.x * current_speed, air_control * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, air_control * delta)

	# Aplicar gravedad normal o caída rápida
	if not is_on_floor():
		if global_transform.origin.y < ff_threshold or velocity.y < -ff_max_speed:
			ff_active = true
		else:
			ff_active = false

		if ff_active:
			# Aplicar gravedad de caída rápida
			velocity.y -= ff_gravity * delta
			velocity.y = clamp(velocity.y, -ff_max_speed, jump_velocity)
		else:
			# Aplicar gravedad normal
			velocity.y -= gravity * delta

	# Manejar el salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		ff_active = false  # Desactivar la caída rápida al saltar

	# Mover al jugador
	# Manejar el estado actual
	if current_state:
		current_state.physics_update(delta)
	move_and_slide()
	
	if Global.debug:
		var horizontal_speed = Vector2(velocity.x, velocity.z).length()
		var vertical_speed = velocity.y
		Global.debug.update_debug_info(horizontal_speed, vertical_speed, current_state_name)
