extends Sprite

onready var caption = $caption
onready var editor = $editor


func open_editor():
	editor.text = caption.text
	editor.visible = true
	editor.grab_focus()
	g.editor.edit_text = true

func hide_editor():
	editor.text = ""
	editor.visible = false
	g.editor.edit_text = false

func set_text(text: String):
	caption.text = text

func enter_text():
	set_text(editor.text)
	hide_editor()

# warning-ignore:unused_argument
func _on_editor_text_entered(new_text):
	enter_text()

func _on_editor_focus_exited():
	hide_editor()
