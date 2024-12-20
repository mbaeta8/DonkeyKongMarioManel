extends RigidBody2D

enum Estados {IDLE, CORRIENDO, SALTANDO, EN_ESCALERA}
var estado_actual:int

const VELOCIDAD_HORIZONTAL:float = 40.0
const VELOCIDAD_ESCALERA:float = 20.0
const POTENCIA_SALTO:float = 50.0

var horizontal:int 
var en_suelo:bool
var tocando_escalera:bool

func _ready():
	estado_actual = Estados.IDLE
	tocando_escalera = false

func _process(_delta):
	if estado_actual != Estados.EN_ESCALERA:
		if not en_suelo:
			estado_actual = Estados.SALTANDO
		elif horizontal != 0:
			estado_actual = Estados.CORRIENDO
		else:
			estado_actual = Estados.IDLE
	
	match estado_actual:
		Estados.IDLE:
			$AnimatedSprite.play("idle")
		Estados.SALTANDO:
			$AnimatedSprite.play("jump")
		Estados.CORRIENDO:
			$AnimatedSprite.play("walk")
		Estados.EN_ESCALERA:
			if linear_velocity.y == 0:
				$AnimatedSprite.stop()
			else:
				$AnimatedSprite.play("stairs")
	
	if en_suelo and estado_actual != Estados.EN_ESCALERA:
		if Input.is_action_pressed("mover_izquierda"):
			horizontal = -1
		elif Input.is_action_pressed("mover_derecha"):
			horizontal = 1
		else:
			horizontal = 0
	
	if horizontal < 0:
		$AnimatedSprite.flip_h = true
	elif horizontal > 0:
		$AnimatedSprite.flip_h = false
	
	if estado_actual == Estados.EN_ESCALERA:
		horizontal = 0
		$Pies.enabled = false
	else:
		$Pies.enabled = true
	
	if $Pies.is_colliding():
		en_suelo = true
	else:
		en_suelo = false
	
	if estado_actual != Estados.EN_ESCALERA:
		
		if Input.is_action_just_pressed("saltar") and en_suelo and estado_actual != Estados.EN_ESCALERA:
			apply_central_impulse(Vector2.UP * POTENCIA_SALTO)
	
func _integrate_forces(state) -> void:
	if estado_actual == Estados.EN_ESCALERA:
		$CollisionShape2D.set_deferred("disabled", true)
		gravity_scale = 0
		if Input.is_action_pressed("saltar"):
			state.linear_velocity.y = -VELOCIDAD_ESCALERA
		elif Input.is_action_pressed("bajar_escalera"):
			state.linear_velocity.y = VELOCIDAD_ESCALERA
		else:
			state.linear_velocity.y = 0
	else:
		gravity_scale = 1
		$CollisionShape2D.set_deferred("disabled", false)
	
	state.set_linear_velocity(Vector2(horizontal * VELOCIDAD_HORIZONTAL, state.linear_velocity.y))


func _on_Cuerpo_area_entered(area):
	if area.name == "Escaleras":
		tocando_escalera = true
		estado_actual = Estados.EN_ESCALERA


func _on_Cuerpo_area_exited(area):
	if area.name == "Escaleras":
		tocando_escalera = false
		if en_suelo:
			estado_actual = Estados.IDLE
		else: 
			estado_actual = Estados.SALTANDO
