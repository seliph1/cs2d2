shader_type canvas_item;
render_mode unshaded;

uniform vec4 color : source_color;
uniform float angle : hint_range(0,360);
uniform float max_dist : hint_range(0,1000) = 100;
uniform sampler2D gradientTexture;
uniform float blur_strength : hint_range(0, 10) = 2.0;

vec4 get_gradient_color(float position) {
    return texture(gradientTexture, vec2(position, 0.5));
}

void fragment() {
    float ang_rad = angle * 3.1416 / 360.0;
    vec2 dir = vec2(sin(ang_rad), cos(ang_rad));

    float total_weight = 0.0;
    float alpha = 0.0;

    // Gaussian-like blur
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 offset = vec2(float(x), float(y)) * blur_strength * SCREEN_PIXEL_SIZE;
            vec2 uv = SCREEN_UV + offset;
            float weight = exp(-0.5 * (float(x*x + y*y) / (blur_strength * blur_strength)));

            // Calculate shadow for this sample
            vec2 at = screen_uv_to_sdf(uv);
            float accum = 0.0;
            while(accum < max_dist) {
                float d = texture_sdf(at);
                accum += d;
                if (d < 0.01) {
                    break;
                }
                at += d * dir;
            }
            float sample_alpha = 1.0 - min(1.0, accum / max_dist);

            alpha += sample_alpha * weight;
            total_weight += weight;
        }
    }

    alpha /= total_weight; // Normalize

    // Apply gradient
    alpha = get_gradient_color(alpha).r;

    COLOR = vec4(color.rgb, alpha * color.a);
}