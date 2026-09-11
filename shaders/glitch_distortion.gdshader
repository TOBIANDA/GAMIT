shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float distortion_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float glitch_time : hint_range(0.0, 1000.0) = 0.0;
uniform float color_flash : hint_range(0.0, 1.0) = 0.0;

// Pseudo-random hash
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	
	if (distortion_intensity <= 0.001) {
		COLOR = texture(SCREEN_TEXTURE, uv);
	} else {
		// 1. Horizontal slice block tearing
		float slice_y = floor(uv.y * 32.0);
		float slice_noise = hash(vec2(slice_y, floor(glitch_time * 12.0)));
		if (slice_noise < 0.35 * distortion_intensity) {
			float offset = (hash(vec2(slice_y, glitch_time * 7.0)) - 0.5) * 0.08 * distortion_intensity;
			uv.x += offset;
		}

		// 2. High-frequency micro-slices
		float micro_slice = floor(uv.y * 120.0);
		if (hash(vec2(micro_slice, floor(glitch_time * 24.0))) < 0.25 * distortion_intensity) {
			uv.x += (hash(vec2(micro_slice, glitch_time)) - 0.5) * 0.03 * distortion_intensity;
		}

		// 3. Sine wave warp / reality distortion
		float wave_x = sin(uv.y * 35.0 + glitch_time * 18.0) * 0.015 * distortion_intensity;
		float wave_y = cos(uv.x * 25.0 + glitch_time * 14.0) * 0.010 * distortion_intensity;
		uv.x += wave_x;
		uv.y += wave_y;

		// 4. Chromatic Aberration (RGB Channel Splitting)
		float rgb_split = (0.015 + 0.035 * sin(glitch_time * 20.0)) * distortion_intensity;
		float r = texture(SCREEN_TEXTURE, uv + vec2(rgb_split, 0.0)).r;
		float g = texture(SCREEN_TEXTURE, uv).g;
		float b = texture(SCREEN_TEXTURE, uv - vec2(rgb_split, 0.0)).b;

		// 5. CRT Scanlines & Digital Static
		float scanline = sin(uv.y * 500.0 + glitch_time * 10.0) * 0.12 * distortion_intensity;
		float grain = (hash(uv * 400.0 + fract(glitch_time)) - 0.5) * 0.15 * distortion_intensity;

		vec3 col = vec3(r, g, b) - scanline + grain;

		// 6. Inversion / Flash effect
		if (color_flash > 0.05) {
			col = mix(col, vec3(1.0) - col, color_flash * 0.7);
		}

		// Vignette darkening
		vec2 vig_uv = (uv - 0.5) * 2.0;
		float vig = clamp(1.0 - dot(vig_uv, vig_uv) * 0.35 * distortion_intensity, 0.0, 1.0);
		col *= vig;

		COLOR = vec4(col, 1.0);
	}
}
