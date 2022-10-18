extends Node2D

var move_speed = 100
export (NodePath) var patrol_path
var patrol_points
var patrol_index = 0
var velocity = Vector2.ZERO
export(float) var min_time_to_stop
export(float) var max_time_to_stop
var time_to_stop
var is_stopped = false
var mouse_in = false
var start_time = 0
var end_time = 0
var draw_points = PoolVector2Array()

func _ready():
	randomize()
	time_to_stop = get_time_to_stop()
	$Timer.start(time_to_stop)
	if patrol_path:
		patrol_points = $Path2D.curve.get_baked_points()
	for point in $Path2D.curve.get_point_count():
		var new_point = $Path2D.curve.get_point_position(point)
		draw_points.append(Vector2(new_point))
	$Line2D.points = draw_points


func _physics_process(delta):
	if !patrol_path:
		return
	if is_stopped:
		if Input.is_action_just_pressed("mouse_click") and mouse_in:
			start_ball()
		return
	var target = patrol_points[patrol_index]
	if $KinematicBody2D.position.distance_to(target) < 1:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		target = patrol_points[patrol_index]
	velocity = (target - $KinematicBody2D.position).normalized() * move_speed
	velocity = $KinematicBody2D.move_and_slide(velocity)


func _on_Timer_timeout():
	start_time = OS.get_ticks_msec()
	is_stopped = true
	velocity = 0


func get_time_to_stop():
	return rand_range(min_time_to_stop, max_time_to_stop)


func _on_KinematicBody2D_mouse_entered():
	mouse_in = true


func _on_KinematicBody2D_mouse_exited():
	mouse_in = false


func start_ball():
	end_time = OS.get_ticks_msec()
	Autoload.moving_ball_stopped += (end_time - start_time)
	is_stopped = false
	time_to_stop = get_time_to_stop()
	$Timer.start(time_to_stop)

func time_up():
	if is_stopped:
		end_time = OS.get_ticks_msec()
		Autoload.moving_ball_stopped += (end_time - start_time)
