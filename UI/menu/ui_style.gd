class_name UiStyle
extends RefCounted

## Palette pulled from the Portal Thief title art: lavender world, dark plum ink,
## thief red, cream/white. Applied from each menu's _ready. Edit these constants
## to re-skin every menu/overlay in one place.

const LAVENDER := Color(0.64, 0.55, 0.82)      # the art's background purple
const PLUM_DEEP := Color(0.18, 0.13, 0.26)     # dark plum (win bg)
const DIM := Color(0.16, 0.11, 0.22, 0.85)     # pause/settings overlay
const VIOLET := Color(0.42, 0.30, 0.60)        # button normal
const RED := Color(0.85, 0.20, 0.17)           # button hover/focus (thief red)
const VIOLET_DARK := Color(0.26, 0.18, 0.38)   # button pressed
const CREAM := Color(0.96, 0.93, 0.95)         # body text
const TITLE := Color(0.90, 0.84, 0.98)         # title text (light lavender)
const INK := Color(0.12, 0.08, 0.18)           # outlines

# Keep these names so paint_bg/paint_dim callers still work.
const BG := PLUM_DEEP


static func _sb(bg: Color, border: Color, border_w := 5, radius := 3) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_border_width_all(border_w)
	s.border_color = border
	s.set_corner_radius_all(radius)
	s.content_margin_left = 28
	s.content_margin_right = 28
	s.content_margin_top = 12
	s.content_margin_bottom = 14
	s.shadow_color = Color(0, 0, 0, 0.5)
	s.shadow_size = 6
	s.shadow_offset = Vector2(0, 5)
	return s


static func button(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", _sb(VIOLET, INK))
	btn.add_theme_stylebox_override("hover", _sb(RED, CREAM))
	btn.add_theme_stylebox_override("pressed", _sb(VIOLET_DARK, INK))
	btn.add_theme_stylebox_override("focus", _sb(RED, CREAM))
	btn.add_theme_stylebox_override("disabled", _sb(VIOLET_DARK, INK))
	btn.add_theme_color_override("font_color", CREAM)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", CREAM)
	btn.add_theme_color_override("font_focus_color", Color.WHITE)
	btn.add_theme_color_override("font_outline_color", INK)
	btn.add_theme_constant_override("outline_size", 6)
	btn.focus_mode = Control.FOCUS_ALL


static func title(label: Label, size := 88) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", TITLE)
	label.add_theme_color_override("font_outline_color", INK)
	label.add_theme_constant_override("outline_size", 16)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	label.add_theme_constant_override("shadow_offset_x", 4)
	label.add_theme_constant_override("shadow_offset_y", 7)


static func subtitle(label: Label, size := 26) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", CREAM)
	label.add_theme_color_override("font_outline_color", INK)
	label.add_theme_constant_override("outline_size", 6)


static func plain(label: Label, size := 28) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", CREAM)
	label.add_theme_color_override("font_outline_color", INK)
	label.add_theme_constant_override("outline_size", 4)


static func paint_bg(rect: ColorRect) -> void:
	if rect:
		rect.color = BG


static func paint_dim(rect: ColorRect) -> void:
	if rect:
		rect.color = DIM
