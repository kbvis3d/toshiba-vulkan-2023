#version 450

#define DISPLAY_3D 0
#define DISPLAY_TEXTURE_FIT 1
#define DISPLAY_QUAD_FIT 2
#define DISPLAY_STRETCH_FIT 3

layout(binding = 0) uniform UniformBufferObject {
    mat4 model;
    mat4 view;
    mat4 proj;
    vec2 windowSize;
    uint displayMode; // 0 - use MVP, 1 - scale the texture, 2 - scale the image quad
} ubo;

layout(location = 0) in vec2 inPosition;
layout(location = 1) in vec3 inColor;
layout(location = 2) in vec2 inTexCoord;

layout(location = 0) out vec3 fragColor;
layout(location = 1) out vec2 fragTexCoord;

void main() {

    fragColor = inColor;

    float aspectRatio = ubo.windowSize.x / ubo.windowSize.y;
    vec2 scale, shift;

    switch(ubo.displayMode){
        case DISPLAY_3D:
            gl_Position = ubo.proj * ubo.view * ubo.model * vec4(inPosition, 0.0, 1.0);
            fragTexCoord = inTexCoord;
            break;
        case DISPLAY_TEXTURE_FIT:
            // Scale vertex position to cover view. 
            // Assumes input geometry is (-0.5,-0.5)->(0.5,0.5)
            // For generality, this should be encoded into the MVP matrix as in the 3D case.
            gl_Position = vec4(2.0 * inPosition, 0.0, 1.0);
            // Scale and shift texture coordinates to correct for window aspect ratio
            if(aspectRatio > 1.0){
                scale = vec2(aspectRatio, 1.0);
                shift = 0.5 * vec2(aspectRatio - 1.0, 0.0);
            }else{
                scale = vec2(1.0, 1.0 / aspectRatio);
                shift = 0.5 * vec2(0.0, 1.0 / aspectRatio - 1.0);
            }
            fragTexCoord = inTexCoord * scale - shift;
            break;
        case DISPLAY_QUAD_FIT:
            scale = aspectRatio > 1.0 ? 
                vec2(1.0 / aspectRatio, 1.0) :
                vec2(1.0, aspectRatio);
            // Scale vertex position to cover view, with aspect ratio correction. 
            // Assumes input geometry is (-0.5,-0.5)->(0.5,0.5)
            // For generality, this should be encoded into the MVP matrix as in the 3D case.
            gl_Position = vec4(2.0 * inPosition * scale, 0.0, 1.0);
            fragTexCoord = inTexCoord;
            break;
        case DISPLAY_STRETCH_FIT:
            // Scale vertex position to cover view (no aspect ratio correction). 
            // Assumes input geometry is (-0.5,-0.5)->(0.5,0.5)
            // For generality, this should be encoded into the MVP matrix as in the 3D case.
            gl_Position = vec4(2.0 * inPosition, 0.0, 1.0);
            fragTexCoord = inTexCoord;
        break;
    }
}
