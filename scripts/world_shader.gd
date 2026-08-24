extends CanvasLayer

# ── Progressive World Desaturation & Glitch Shader (Sesuai GDD) ─────────────
# Seiring bertambahnya bukti dan fase kasus, warna dunia memudar secara bertahap
# dari normal (berwarna) -> desaturated -> monokrom dingin misterius.

@onready var color_rect: ColorRect = $ColorRect
var shader_material: ShaderMaterial
var current_desat: float = 0.0
var target_desat: float = 0.0

const SHADER_CODE = """
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float desaturation : hint_range(0.0, 1.0) = 0.0;
uniform float cold_tint_strength : hint_range(0.0, 1.0) = 0.35;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.25;

void fragment() {
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // 1. Grayscale luminance (ITU-R BT.709)
    float gray = dot(screen_color.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 gray_color = vec3(gray);
    
    // 2. Cold blue/purple tint for Afterlife atmosphere
    vec3 cold_tint = gray_color * vec3(0.85, 0.90, 1.15);
    vec3 blend_gray = mix(gray_color, cold_tint, cold_tint_strength * desaturation);
    
    // 3. Lerp original color to desaturated cold color
    vec3 final_rgb = mix(screen_color.rgb, blend_gray, desaturation);
    
    // 4. Subtle Vignette
    vec2 uv = SCREEN_UV * (1.0 - SCREEN_UV.yx);
    float vig = uv.x * uv.y * 15.0;
    vig = clamp(pow(vig, vignette_strength * (0.5 + desaturation * 0.5)), 0.0, 1.0);
    final_rgb *= (0.7 + 0.3 * vig);
    
    COLOR = vec4(final_rgb, 1.0);
}
"""

func _ready() -> void:
	layer = 1 # Di bawah HUD (layer 2) tapi di atas Node2D Game
	
	if not is_instance_valid(color_rect):
		color_rect = ColorRect.new()
		color_rect.name = "ColorRect"
		color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(color_rect)
		
	var shader = Shader.new()
	shader.code = SHADER_CODE
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	color_rect.material = shader_material

	# Hubungkan sinyal ke InvestigationManager jika tersedia
	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if is_instance_valid(inv_mgr):
		inv_mgr.desaturation_updated.connect(_on_desaturation_updated)
		target_desat = inv_mgr.desaturation_level

func _process(delta: float) -> void:
	current_desat = move_toward(current_desat, target_desat, delta * 0.8)
	if is_instance_valid(shader_material):
		shader_material.set_shader_parameter("desaturation", current_desat)

func _on_desaturation_updated(amount: float) -> void:
	target_desat = amount

func set_desaturation_instant(amount: float) -> void:
	target_desat = amount
	current_desat = amount
	if is_instance_valid(shader_material):
		shader_material.set_shader_parameter("desaturation", current_desat)
