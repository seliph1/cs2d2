extends Popup


func YesPressed() -> void:
	get_tree().quit()

func NoPressed() -> void:
	self.hide()
