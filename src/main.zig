const Proyecto1 = @import("Proyecto1");
const std = @import("std");
const rl = @import("raylib");

// Dimensiones
const MAP_WIDTH: usize = 8;
const MAP_HEIGHT: usize = 8;
const TILE_SIZE: i32 = 64;

// Mapa
const world_map = [MAP_HEIGHT][MAP_WIDTH]u8{
    .{ 1, 1, 1, 1, 1, 1, 1, 1 },
    .{ 1, 0, 0, 0, 0, 0, 0, 1 },
    .{ 1, 0, 1, 1, 0, 1, 0, 1 },
    .{ 1, 0, 1, 0, 0, 1, 0, 1 },
    .{ 1, 0, 0, 0, 0, 0, 0, 1 },
    .{ 1, 0, 1, 0, 0, 1, 0, 1 },
    .{ 1, 0, 0, 0, 0, 0, 0, 1 },
    .{ 1, 1, 1, 1, 1, 1, 1, 1 },
};

// Jugador
const Player = struct {
    x: f32,
    y: f32,
    angle: f32,
};

pub fn main() !void {
    const screen_width = MAP_WIDTH * @as(usize, @intCast(TILE_SIZE));
    const screen_height = MAP_HEIGHT * @as(usize, @intCast(TILE_SIZE));

    rl.initWindow(@intCast(screen_width), @intCast(screen_height), "Proyecto 1");
    defer rl.closeWindow();

    rl.setTargetFPS(15);

    const player = Player{
        .x = 2.5 * @as(f32, @floatFromInt(TILE_SIZE)),
        .y = 4.5 * @as(f32, @floatFromInt(TILE_SIZE)),
        .angle = 0.0,
    };

    // Game loop
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);
        for (0..MAP_HEIGHT) |y| {
            for (0..MAP_WIDTH) |x| {
                const screen_x: i32 = @intCast(x * @as(usize, @intCast(TILE_SIZE)));
                const screen_y: i32 = @intCast(y * @as(usize, @intCast(TILE_SIZE)));

                if (world_map[y][x] == 1) {
                    rl.drawRectangle(screen_x, screen_y, TILE_SIZE - 1, TILE_SIZE - 1, rl.Color.gray);
                } else {
                    rl.drawRectangle(screen_x, screen_y, TILE_SIZE - 1, TILE_SIZE - 1, rl.Color.dark_gray);
                }
            }
        }
        rl.drawCircle(@intFromFloat(player.x), @intFromFloat(player.y), 8, rl.Color.yellow);

        // Linea de vision
        const line_length: f32 = 25.0;
        const line_end_x = player.x + @cos(player.angle) * line_length;
        const line_end_y = player.y + @sin(player.angle) * line_length;

        rl.drawLine(@intFromFloat(player.x), @intFromFloat(player.y), @intFromFloat(line_end_x), @intFromFloat(line_end_y), rl.Color.red);

        rl.endDrawing();
    }
}
