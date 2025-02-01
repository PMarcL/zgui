const gui = @import("gui.zig");
const backend_sdl3 = @import("backend_sdl3.zig");

pub fn initWithGPUInitInfo(
    window: *const anyopaque, // SDL_Window
    init_info: InitInfo,
) void {
    backend_sdl3.initGPU(window);

    if (!ImGui_ImplSDLGPU3_Init(&init_info)) {
        unreachable;
    }
}

pub fn init(
    window: *const anyopaque,
    device: *const anyopaque,
    color_target_format: c_uint,
    msaa_samples: c_int,
) void {
    initWithGPUInitInfo(window, .{
        .device = device,
        .color_target_format = color_target_format,
        .msaa_samples = msaa_samples,
    });
}

pub fn deinit() void {
    backend_sdl3.deinit();
    ImGui_ImplSDLGPU3_Shutdown();
}

pub fn newFrame() void {
    ImGui_ImplSDLGPU3_NewFrame();
    backend_sdl3.newFrame();

    // TODO: The following is not in the example here:
    // https://github.com/ocornut/imgui/blob/master/examples/example_sdl3_sdlgpu3/main.cpp
    // But, the SDL2 opengl version of newFrame does this:
    // gui.io.setDisplaySize(fb_width, fb_height);
    // gui.io.setDisplayFramebufferScale(1.0, 1.0);

    gui.newFrame();
}

pub fn draw(
    command_buffer: *const anyopaque, // SDL_GPUCommandBuffer
    render_pass: *const anyopaque, // SDL_GPURenderPass
    pipeline: ?*const anyopaque, // SDL_GPUGraphicsPipeline
) void {
    gui.render();
    ImGui_ImplSDLGPU3_PrepareDrawData(gui.getDrawData(), command_buffer);
    ImGui_ImplSDLGPU3_RenderDrawData(
        gui.getDrawData(),
        command_buffer,
        render_pass,
        pipeline,
    );
}

pub const InitInfo = extern struct {
    device: *const anyopaque, // SDL_GPUDevice
    color_target_format: c_uint, // SDL_GPUTextureFormat
    msaa_samples: c_int, // SDL_GPUSampleCount
};

extern fn ImGui_ImplSDLGPU3_Init(info: *const anyopaque) bool;
extern fn ImGui_ImplSDLGPU3_Shutdown() void;
extern fn ImGui_ImplSDLGPU3_NewFrame() void;
extern fn ImGui_ImplSDLGPU3_PrepareDrawData(
    draw_data: *const anyopaque,
    command_buffer: *const anyopaque, // SDL_GPUCommandBuffer
) void;
extern fn ImGui_ImplSDLGPU3_RenderDrawData(
    draw_data: *const anyopaque,
    command_buffer: *const anyopaque, // SDL_GPUCommandBuffer
    render_pass: *const anyopaque, // SDL_GPURenderPass
    pipeline: ?*const anyopaque, // SDL_GPUGraphicsPipeline
) void;
