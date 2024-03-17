#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 resolution;
uniform sampler2D uTexture;
uniform float noiseInput;
uniform float brightnessInput;
uniform float contrastInput;
uniform float vignetteRadius;
uniform float saturation;
uniform vec3 overlayColor;
uniform float overlayColorIntensity;

out vec4 fragColor;

float random2D(vec2 st){
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

vec3 generateContrast(vec3 color, float contrast){
    return color * (contrastInput + 1.0);
}

vec3 generateBrightness(vec3 color, float brightness){
    return color + brightness;
}

vec3 applyVignette(vec3 color, vec2 positions)
{
    vec2 position = positions - vec2(0.5);           
    float dist = length(position);

    float radius = vignetteRadius+0.7;
    float softness = 0.4;
    float vignette = smoothstep(radius, radius - softness, dist);

    color = color - (1.0 - vignette);

    return color;
}

vec3 applyNoise(vec3 color, vec2 position){
    float noise = (random2D(position) - 0.5) * noiseInput;
    return color + noise;
}

vec3 applyClarity(vec2 position, vec3 color){
    vec2 xy = vec2(position.x,1.0-position.y);
	
	float clarity = (3.0*sin( 0.0 ));
	
    vec3 col1 = color;
    vec3 col2 = color;
	
    if (clarity > 0.0) {
		return vec3( (col1 + col2)/2.0);
    } else {
    	return vec3( col1 * 2.0 - col2 );
    }
}

vec3 applySaturation(vec3 color, float sat)
{
	// Increase or decrease theese values to adjust r, g and b color channels seperately
	const float AvgLumR = 0.5;
	const float AvgLumG = 0.5;
	const float AvgLumB = 0.5;
	
	const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);
	
	vec3 AvgLumin  = vec3(AvgLumR, AvgLumG, AvgLumB);

	vec3 intensity = vec3(dot(color, LumCoeff));
	vec3 satColor  = mix(intensity, color, sat);
	
	return satColor;
}

void main(){

    vec2 position = FlutterFragCoord().xy / resolution.xy;
    

    float dx = 1.0 / position.x;
    float dy = 1.0 / position.y;

    vec4 finalImages = texture(uTexture, position + vec2( -1.0 * dx , 0.0 * dy));
    
    // Overlay color
    vec4 overlayColorAlpha = vec4(overlayColor, 1.0);
    finalImages = mix(overlayColorAlpha, finalImages, 1-overlayColorIntensity);


    vec3 finalImage = applyNoise(finalImages.rgb, position);
    
    // Apply Contrast
	finalImage = generateContrast(finalImage, contrastInput);
    
    // Apply Brightness
    finalImage =  generateBrightness(finalImage, brightnessInput);

    // Apply Vignette
    finalImage = applyVignette(finalImage, position);

    // finalImage = applyClarity(position, finalImage);
    finalImage = applySaturation(finalImage, saturation);

    fragColor = vec4(vec3(finalImage), 1.0);
}
