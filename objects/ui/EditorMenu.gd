extends Control

func fileSelected(path: String) -> void:
	var mapLoader = get_tree().current_scene.get_node("MapLoader")
	mapLoader.map_path = path

func loadMapPressed() -> void:
	$FileDialog.show()
