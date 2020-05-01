tool
extends EditorPlugin

var batch_collision_button : MenuButton = preload("res://addons/batch_collisions/BatchCollisionButton.tscn").instance()

func _enter_tree():
	get_editor_interface().get_selection().connect("selection_changed", self, "_on_EditorSelection_selection_changed")
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, batch_collision_button)
	batch_collision_button.icon = get_editor_interface().get_base_control().theme.get_icon("StaticBody", "EditorIcons")
	batch_collision_button.get_popup().connect("id_pressed", self, "_on_BatchCollisionButton_id_pressed")
	batch_collision_button.show()


func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, batch_collision_button)
	batch_collision_button.queue_free()


func _on_BatchCollisionButton_id_pressed(id):
	generate_collision_siblings(get_editor_interface().get_selection().get_selected_nodes(), id == 0)


func _on_EditorSelection_selection_changed():
	batch_collision_button.hide()
	for selected_node in get_editor_interface().get_selection().get_selected_nodes():
		if selected_node is MeshInstance:
			batch_collision_button.show()


func generate_collision_siblings(nodes : Array, convex : bool) -> void:
	var undo_redo = get_undo_redo()
	undo_redo.create_action("Create %s Static Bodies" % ("Convex" if convex else "Trimesh"))
	for node in nodes:
		if node is MeshInstance:
			var collision_shape := CollisionShape.new()
			collision_shape.shape = node.mesh.create_convex_shape() if convex else node.mesh.create_trimesh_shape()
			var static_body := StaticBody.new()
			static_body.add_child(collision_shape)
			var owner := get_editor_interface().get_edited_scene_root()
			var old_static_body = node.get_node_or_null("StaticBody")
			var old_collision_shape = node.get_node_or_null("StaticBody/CollisionShape")
			
			if old_static_body:
				undo_redo.add_do_method(node, "remove_child", old_static_body)
			undo_redo.add_do_method(node, "add_child", static_body)
			undo_redo.add_do_method(static_body, "set_owner", owner)
			undo_redo.add_do_method(collision_shape, "set_owner", owner)
			undo_redo.add_do_reference(static_body)
			
			undo_redo.add_undo_method(node, "remove_child", static_body)
			if old_static_body:
				undo_redo.add_undo_method(node, "add_child", old_static_body)
				undo_redo.add_undo_method(old_static_body, "set_owner", owner)
			if old_collision_shape:
#				undo_redo.add_undo_method(node, "add_child", old_collision_shape)
				undo_redo.add_undo_method(old_collision_shape, "set_owner", owner)
	undo_redo.commit_action()
