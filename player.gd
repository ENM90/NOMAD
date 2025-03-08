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
var gravity: float = 7.8  # Gravedad base
var max_fall_speed: float = 200.0  # Velocidad máxima de caída
var fall_time: float = 0.0  # Tiempo que llevas cayendo
var fall_acceleration: float = 3.0  # Factor de aceleración de la caída

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
var air_control = 1.0  # Control en el aire (1 = completo)

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

func _input(event):
	if event is InputEventMouseMotion:
		# Rotar el jugador en el eje Y (izquierda/derecha)
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		
		# Rotar la cabeza (cámara) en el eje X (arriba/abajo)
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		
		# Limitar la rotación de la cámara para que no gire demasiado
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	if event.is_action_pressed("ui_accept") and is_on_floor():
		jump_time = 0.0
		is_jumping = true
		change_state(jumping_state)

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
		# Calcular la dirección de movimiento basada en la cámara
	var forward = -camera_3d.global_transform.basis.z
	var right = camera_3d.global_transform.basis.x
	direction = (forward * input_dir.y + right * input_dir.x).normalized()

	# Aplicar movimiento suavizado
	var target_velocity = direction * current_speed
	if is_on_floor():
		velocity.x = lerp(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, acceleration * delta)
	else:
		# Control completo en el aire hasta alcanzar la velocidad máxima
		var horizontal_speed = Vector2(velocity.x, velocity.z).length()
		if horizontal_speed < max_air_speed:
			velocity.x = lerp(velocity.x, target_velocity.x, air_control * delta)
			velocity.z = lerp(velocity.z, target_velocity.z, air_control * delta)
		else:
			# Reducir el control si se supera la velocidad máxima
			velocity.x = lerp(velocity.x, target_velocity.x, air_control * 0.5 * delta)
			velocity.z = lerp(velocity.z, target_velocity.z, air_control * 0.5 * delta)
	
	
	
	
	if is_jumping:
		jump_time += delta
		
		# Aplicar una aceleración gradual durante el salto
		velocity.y = jump_velocity * (1.0 - jump_time / 0.5)  # Ajusta el 0.5 para cambiar la duración del salto
		
		# Cambiar a falling_state si la velocidad en Y es menor o igual a 0
		if velocity.y <= 0:
			is_jumping = false
			change_state(falling_state)
	else:
	
	
		if not is_on_floor():
		# Incrementar el tiempo de caída
			fall_time += delta
		
		# Calcular la velocidad de caída en función del tiempo
			var target_fall_speed = min(gravity * fall_time * fall_acceleration, max_fall_speed)
		
		# Aplicar la velocidad de caída en el eje Y
			velocity.y = -target_fall_speed
		else:
		# Reiniciar el tiempo de caída cuando tocas el suelo
			fall_time = 0.0
			is_jumping = false
		

	# Manejar el estado actual
	if current_state:
		current_state.physics_update(delta)
	move_and_slide()
