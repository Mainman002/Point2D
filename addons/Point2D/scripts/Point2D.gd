@tool
extends PointLight2D
class_name Point2D

## Point light using a gradient texture & colors for scene lighting[br]
##
## This custom tool script is used to generate a complete 2D point light setup[br]
##
## [br][b]Features Include:[/b][br]
## * Adjust light settings in an organized inspector layout[br]
## * Select gradient shape for linear, circle, and square[br]
## * Color presets to quickly select gradient colors[br]
## * Invert gradient colors[br]
##
## [br][b]Made by:[br]
## * TnT Gamez LLC[br]
## * Johnathan Mueller
##

## Sets the point light gradient shape
enum SHAPE{
	CIRCLE, ## Circle
	SQUARE, ## Square
	LINEAR, ## Gradient Square
	}

## Preset interpolation names
enum INTERPOLATION{
	CONSTANT, ## No interpolation
	LINEAR, ## Gradient colors use simple blending
	CUBIC, ## Gradient colors blend together more smoothly
	}

## Preset color names
enum COLOR_PRESETS{
	COOL, ## Blue gradient
	DAY, ## White gradient
	WARM, ## Tan gradient
	HOT, ## Red gradient
	}

## Preset used to set gradient colors[br]
## [0]: [color=skyblue]Cool[/color][br]
## [1]: [color=white]Day[/color][br]
## [2]: [color=tan]Warm[/color][br]
## [3]: [color=orange]Hot[/color][br]
const _color_presets:Array = [
	## Cool
	[
		Color(0.74, 0.83, 0.93, 0.8), ## Color Fade Center
		Color(0, 0, 0.19, 0.39), ## Color Fade Edge
			[ ## Fade Offsets
				0, ## Fade Center
				0.36 ## Fade Edge
			]
	],
	## Day
	[
		Color(1, 1, 1, 0.67), ## Color Fade Center
		Color(0.16, 0.16, 0.16, 0.37), ## Color Fade Edge
			[ ## Fade Offsets
				0, ## Fade Center
				0.36 ## Fade Edge
			]
	],
	## Warm
	[
		Color(1, 0.82, 0.59, 0.68), ## Color Fade Center
		Color(0.54, 0.2, 0, 0.16), ## Color Fade Edge
			[ ## Fade Offsets
				0, ## Fade Center
				0.36 ## Fade Edge
			]
	],
	## Hot
	[
		Color(1, 0.62, 0, 0.7), ## Color Fade Center
		Color(0.64, 0.04, 0, 0.26), ## Color Fade Edge
			[ ## Fade Offsets
				0, ## Fade Center
				0.36 ## Fade Edge
			]
	],
]

## Temp variable to keep track of gradient variables
var _gradient:Gradient

## Category for variables that reset / adjust other variables
@export_category("Tools")

## Resets all variables to default
## [br][color=yellow]!! Warning !![/color][br]
## [color=yellow]This will reset all variables to default[/color]
@export var reset:bool = false :
	set(_val):
		_reset_variables()
		reset = false
	get(): return reset

## Attempts to keep all variables the same but refreshes light values
@export var regenerate:bool = false :
	set(_val):
		_update_all()
		regenerate = false
	get(): return regenerate

## Category for adjusting light related variables
@export_category("Lighting")

## Enable / disable light
@export var enable_light:bool = true :
	set(_val):
		enable_light = _val
		enabled = _val
	get(): return enable_light

## Enable / disable shadows
@export var enable_shadow:bool = false :
	set(_val):
		shadow_enabled = _val
		enable_shadow = _val
	get(): return enable_shadow

## Set algorithm used to interpolate colors in the gradient
@export var _interpolation : INTERPOLATION = INTERPOLATION.CUBIC :
	set(_val):
		_interpolation = _val
		_update_all()
	get(): return _interpolation

## Set light brightness
@export_range(0, 16) var light_brightness:float = 4.0 :
	set(_val):
		light_brightness = _val
		energy = _val
	get(): return light_brightness

## Category for color variables
@export_category("Color")

## Swaps gradient colors
@export var invert_colors:bool = false :
	set(_val):
		invert_colors = _val
		_update_all()
	get(): return invert_colors

## Set gradient colors to a color preset
@export var _color_preset : COLOR_PRESETS = COLOR_PRESETS.DAY :
	set(_val):
		_color_preset = _val
		if _gradient && _gradient:
			point_color = _color_presets[_color_preset][0]
			edge_color = _color_presets[_color_preset][1]
			_gradient.colors = [point_color, edge_color, Color(0,0,0,0)]
		_update_all()
	get(): return _color_preset

## Color used for the center point of the gradient
@export var point_color:Color = Color.WHITE :
	set(_val):
		point_color = _val
		_update_all()
	get(): return point_color

## Color used for the outside edge of the gradient
@export var edge_color:Color = Color(0,0,0,0.391) :
	set(_val):
		edge_color = _val
		_update_all()
	get(): return edge_color

## Category for shape related variables
@export_category("Shape")

## Set texture gradient shape
@export var _shape : SHAPE = SHAPE.CIRCLE :
	set(_val):
		_shape = _val
		_update_all()
	get(): return _shape

## Adjust radius (texture scale) of light
@export_range(0.05, 6) var light_distance:float = 1.5 :
	set(_val):
		light_distance = _val
		texture_scale = _val
	get(): return light_distance

## Set texture gradient center point offset
@export_range(0, 0.641) var fade_center:float = 0.0 :
	set(_val):
		fade_center = _val
		if fade_edge && fade_center > fade_edge: fade_edge = _val + 0.01
		if _gradient && _gradient:
			_gradient.set_offset(0, _val)
	get(): return fade_center

## Set texture gradient edge offset
@export_range(0, 0.641) var fade_edge:float = 0.641 :
	set(_val):
		fade_edge = _val
		if fade_center && fade_edge < fade_center: fade_center = _val - 0.01
		if _gradient && _gradient:
			_gradient.set_offset(1, _val)
	get(): return fade_edge

## Category for Z index / layer variables
@export_category("Layers")

## Minimum layer for light to effect
@export_range(-1, 512, 1) var _min_layers:int = 0 :
	set(_val):
		_min_layers = _val
		range_layer_min = _min_layers
	get(): return _min_layers

## Maximum layer for light to effect
@export_range(-1, 512, 1) var _max_layers:int = 0 :
	set(_val):
		_max_layers = _val
		range_layer_max = _max_layers
	get(): return _max_layers


## Run on scene load
func _ready() -> void:
	if Engine.is_editor_hint():
		_update_all()


## Resets all variables to default values
func _reset_variables() -> void:
	enable_light = true
	enabled = enable_light
	enable_shadow = false
	shadow_enabled = enable_shadow
	light_brightness = 4.0
	invert_colors = false
	point_color = Color.WHITE
	edge_color = Color(0,0,0, 0.391)
	_color_preset = COLOR_PRESETS.DAY
	light_distance = 1.5
	fade_center = 0.0
	fade_edge = 0.641
	_shape = SHAPE.CIRCLE
	_min_layers = 0
	_max_layers = 0
	if Engine.is_editor_hint(): notify_property_list_changed()


## Change gradient interpolation mode
func _interpolation_change() -> void:
	if texture && _gradient:
		match _interpolation:
			INTERPOLATION.CONSTANT:
				_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
			INTERPOLATION.LINEAR:
				_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
			INTERPOLATION.CUBIC:
				_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC


## change gradient texture shape
func _shape_change() -> void:
	if texture:
		match _shape:
			SHAPE.CIRCLE:
				texture.fill = GradientTexture2D.FILL_RADIAL
				texture.fill_from = Vector2(0.5,0.5)
				texture.fill_to = Vector2(1,0)
			SHAPE.SQUARE:
				texture.fill = GradientTexture2D.FILL_SQUARE
				texture.fill_from = Vector2(0.5,0.5)
				texture.fill_to = Vector2(1,0)
			SHAPE.LINEAR:
				texture.fill = GradientTexture2D.FILL_LINEAR
				texture.fill_from = Vector2(0.0,0.0)
				texture.fill_to = Vector2(2,0)


## Update all point light variables
func _update_all() -> void:
	if texture: texture = texture.duplicate(true)

	if not texture:
		texture = GradientTexture2D.new()
		texture.resource_local_to_scene = false
	if not _gradient:
		_gradient = Gradient.new()
		texture.gradient = Gradient.new()
		texture.width = 256
		texture.height = 256

	_gradient.offsets = [
		0,
		0.5,
		0.7
	]

	_gradient.colors = [
		Color(0.78, 0.78, 0.78, 0.65,),
		Color(0.18, 0.18, 0.18, 0.38,),
		Color(0, 0, 0, 0,)
	]

	texture.gradient = _gradient
	texture.gradient.resource_local_to_scene = false

	if texture && _gradient && texture.gradient:
		if fade_center && fade_edge < fade_center: fade_center = fade_edge - 0.02
		elif fade_edge && fade_center > fade_edge: fade_edge = fade_center + 0.02

		match invert_colors:
			false:
				_gradient.set_color(0, point_color)
				_gradient.set_color(1, edge_color)
			true:
				_gradient.set_color(1, point_color)
				_gradient.set_color(0, edge_color)

		_gradient.set_color(2, Color(0,0,0,0))
		_gradient.set_offset(0, fade_center)
		_gradient.set_offset(1, fade_edge)
		_gradient.set_offset(2, 0.7)

	_shape_change()
	_interpolation_change()
	shadow_enabled = enable_shadow
	energy = light_brightness
	if Engine.is_editor_hint(): notify_property_list_changed()
