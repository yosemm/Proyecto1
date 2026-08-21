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

    var player = Player{
        .x = 2.5 * @as(f32, @floatFromInt(TILE_SIZE)),
        .y = 4.5 * @as(f32, @floatFromInt(TILE_SIZE)),
        .angle = 0.0,
    };

    // Game loop
    while (!rl.windowShouldClose()) {
        const dt = rl.getFrameTime();
        const rotation_speed: f32 = 3.0;
        const move_speed: f32 = 150.0;
        var move_step: f32 = 0.0;

        // Angulo vista
        if (rl.isKeyDown(rl.KeyboardKey.left) or rl.isKeyDown(rl.KeyboardKey.a)) {
            player.angle -= rotation_speed * dt;
        }
        if (rl.isKeyDown(rl.KeyboardKey.right) or rl.isKeyDown(rl.KeyboardKey.d)) {
            player.angle += rotation_speed * dt;
        }

        // Movimiento
        if (rl.isKeyDown(rl.KeyboardKey.up) or rl.isKeyDown(rl.KeyboardKey.w)) {
            move_step += move_speed * dt;
        }
        if (rl.isKeyDown(rl.KeyboardKey.down) or rl.isKeyDown(rl.KeyboardKey.s)) {
            move_step -= move_speed * dt;
        }

        if (move_step != 0.0) {
            const new_x = player.x + @cos(player.angle) * move_step;
            const new_y = player.y + @sin(player.angle) * move_step;

            const tile_size_f = @as(f32, @floatFromInt(TILE_SIZE));

            // Posicion a la que va
            const check_x: usize = @intFromFloat(new_x / tile_size_f);
            const check_y: usize = @intFromFloat(new_y / tile_size_f);
            // Posicion actual
            const current_x: usize = @intFromFloat(player.x / tile_size_f);
            const current_y: usize = @intFromFloat(player.y / tile_size_f);

            // Eje X
            if (check_x < MAP_WIDTH and world_map[current_y][check_x] == 0) {
                player.x = new_x;
            }
            // Eje Y
            if (check_y < MAP_HEIGHT and world_map[check_y][current_x] == 0) {
                player.y = new_y;
            }
        }

        // Empieza loop
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
