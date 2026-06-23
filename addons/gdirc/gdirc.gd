@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("IRC", "Node", preload("res://addons/gdirc/Irc.gd"), preload("res://addons/gdirc/gdirc.png"))


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("IRC")
