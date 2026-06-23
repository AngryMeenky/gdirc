@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("IRC", "Node", preload("res://addons/gdirc/Irc.gd"), preload("res://addons/gdirc/gdirc.png"))


func _exit_tree():
	remove_custom_type("IRC")
