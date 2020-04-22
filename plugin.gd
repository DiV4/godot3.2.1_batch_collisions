tool
extends EditorPlugin

func _ready():
	get_editor_interface().get_selection().connect("selection_changed", self,
			"_on_selection_changed")
	set_process_input(false)


func _input(event):
	if Input.is_key_pressed(KEY_F11):
		batch_col(true)
	if Input.is_key_pressed(KEY_F12):
		batch_col(false)


func batch_col(convex):
	print("Running the batch collisions process...")
	var nodes = get_editor_interface().get_selection().get_selected_nodes()
	
	for n in nodes:
		if n is MeshInstance:
			# Delete the old colliders, if any.
			if n.get_child_count() != 0:
				for c in n.get_children():
					if c is StaticBody:
						c.queue_free()
			# Create new colliders.
			if convex:
				n.create_convex_collision()
			else:
				n.create_trimesh_collision()
	print("Done!")


func _on_selection_changed():
	if get_editor_interface().get_selection().get_selected_nodes().size() > 0:
		set_process_input(true)
	else:
		set_process_input(false)
