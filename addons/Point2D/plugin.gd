#MIT License

#Copyright (c) 2024 Johnathan Mueller. TnT Gamez LLC

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

@tool
extends EditorPlugin

const POINT_2D: String = "Point2D"

var good_load: bool = false

func _enter_tree() -> void:
	# Preload the script and icon
	var point_2d_script = preload("res://addons/Point2D/scripts/Point2D.gd")
	var point_2d_icon = preload("res://addons/Point2D/assets/icons/point2d_icon.png")

	# Check if resources loaded correctly
	good_load = point_2d_script and point_2d_icon

	if good_load:
		add_custom_type(POINT_2D, "PointLight2D", point_2d_script, point_2d_icon)

func _exit_tree() -> void:
	if good_load:
		remove_custom_type(POINT_2D)
