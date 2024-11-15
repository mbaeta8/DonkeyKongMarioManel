extends AnimatedSprite

onready var pl_barril:PackedScene = preload("res://Barril.tscn")

const TIEMPO_LANZAMIENTO:Vector2 = Vector2(3.0, 6.0)

func _ready():
	randomize()
	$Timer.start(rand_range(TIEMPO_LANZAMIENTO.x,TIEMPO_LANZAMIENTO.y))

func _on_Kong_animation_finished():
	match animation:
		"take_barrel":
			var instancia_barril:RigidBody2D = pl_barril.instance()
			get_parent().add_child(instancia_barril)
			instancia_barril.position = self.global_position
			play("angry")
		"angry":
			$Timer.start(rand_range(TIEMPO_LANZAMIENTO.x,TIEMPO_LANZAMIENTO.y))
			play("idle")


func _on_Timer_timeout():
	play("take_barrel")
