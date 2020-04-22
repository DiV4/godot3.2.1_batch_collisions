tool
extends EditorPlugin

func _ready():
	get_editor_interface().get_selection().connect("selection_changed", self,
			"_on_selection_changed")
	set_process_input(false)

func _on_selection_changed():
	if get_editor_interface().get_selection().get_selected_nodes().size() > 0:
		set_process_input(true)
	else:
		set_process_input(false)

func _input(event):
	if Input.is_key_pressed(KEY_F12):
		print("Running the batch collisions process...")
		batch_col()

func batch_col():
	var nodes = get_editor_interface().get_selection().get_selected_nodes()
	
	for n in nodes:
		if n is MeshInstance:
			if n.get_child_count() == 0:
				n.create_trimesh_collision()
			else:
				n.get_child(0).queue_free()
				n.create_trimesh_collision()
	print("Done!")
