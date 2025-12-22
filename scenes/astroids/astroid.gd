extends RigidBody3D


func take_damage():
	get_parent_node_3d().queue_free()
