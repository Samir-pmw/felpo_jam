shader_type canvas_item;

uniform vec4 lightning_color : source_color = vec4(0.97, 0.89, 0.85, 0.65);
uniform float size : hint_range(0.0, 1.0) = 0.005;
uniform float width : hint_range(0.0, 1.0) = 0.4;
uniform float speed = 1.0;
uniform float cycle = 0.17;
uniform float ratio = 3.0;
uniform float time_shift = 0.5;
uniform int strike_count = 5;
uniform float strike_delay = 0.25;
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.9;

float rand(float x) {
    return fract(sin(x) * 100000.0);
}

void fragment() {
    float wave = 0.0;
    float time = TIME * speed;

    for (int i = 0; i < strike_count; i++) {
        float strike_offset = float(i) / float(strike_count);
        float strike_time = floor(time / strike_delay) + strike_offset;
        float strike_phase = mod(time, strike_delay) / strike_delay;

        // Delay the strike based on its offset
        if (strike_phase < strike_offset) {
            continue;
        }

        float bolt = abs(mod(UV.y * cycle + (rand(strike_time) + time_shift) * -1.0, 0.5) - 0.25) - 0.125;
        bolt *= 4.0 * width;

        bolt *= (0.5 - abs(UV.y - 0.5)) * 2.0;

        float strike_position = rand(strike_time * 10.0) - 0.5;
        float lightning = 1.0 - step(size * 0.5, abs(UV.x - 0.5 + strike_position + bolt));
        wave += lightning;
    }

    wave = clamp(wave, 0.0, 1.0);

    // Make strikes blink on and off
    float blink = step(rand(floor(time / strike_delay)) * ratio, 0.5);
    wave *= blink;

    // Create a radial gradient for the glow effect
    float dist = distance(UV, vec2(0.5, 0.5));
    float glow = smoothstep(0.0, glow_intensity, 1.0 - dist);

    vec4 display = lightning_color * vec4(wave);
    display.rgb += glow * lightning_color.rgb * wave;

    COLOR = vec4(display.rgb, display.a * wave);
}
