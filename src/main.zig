const Proyecto1 = @import("Proyecto1");
const std = @import("std");
const rl = @import("raylib");

// Dimensiones
const MAP_WIDTH: usize = 16;
const MAP_HEIGHT: usize = 16;
const TILE_SIZE: i32 = 64;

// Mapa (1: Piedra, 2: Ladrillo Azul, 3: Madera, 9: Salida/Meta)
const world_map = [MAP_HEIGHT][MAP_WIDTH]u8{
    .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    .{ 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    .{ 1, 0, 1, 1, 0, 0, 1, 0, 2, 2, 2, 2, 2, 0, 0, 1 },
    .{ 1, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 1 },
    .{ 1, 0, 1, 0, 0, 1, 1, 0, 2, 0, 0, 0, 2, 0, 0, 1 },
    .{ 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 1 },
    .{ 1, 1, 1, 0, 1, 1, 1, 0, 2, 2, 0, 2, 2, 0, 0, 1 },
    .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    .{ 1, 0, 3, 3, 3, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1 },
    .{ 1, 0, 3, 0, 3, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1 },
    .{ 1, 0, 3, 0, 3, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1 },
    .{ 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    .{ 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1 },
    .{ 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 9, 1 },
    .{ 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1 },
    .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
};

// Jugador
const Player = struct {
    x: f32,
    y: f32,
    angle: f32,
    walk_timer: f32 = 0.0,
};

pub fn main() !void {
    const screen_width: usize = 640;
    const screen_height: usize = 480;
    const tile_size_f = @as(f32, @floatFromInt(TILE_SIZE));

    const max_map_x = @as(f32, @floatFromInt(MAP_WIDTH)) * tile_size_f;
    const max_map_y = @as(f32, @floatFromInt(MAP_HEIGHT)) * tile_size_f;

    const screen_width_f = @as(f32, @floatFromInt(screen_width));
    const screen_height_f = @as(f32, @floatFromInt(screen_height));

    // FOV y Proyeccion
    const fov: f32 = 75.0 * (std.math.pi / 180.0);
    const half_fov: f32 = fov / 2.0;
    const proj_plane_dist: f32 = (screen_width_f / 2.0) / @tan(half_fov);

    rl.initWindow(@intCast(screen_width), @intCast(screen_height), "Proyecto 1");
    defer rl.closeWindow();

    rl.setTargetFPS(15);

    var player = Player{
        .x = 1.5 * tile_size_f,
        .y = 1.5 * tile_size_f,
        .angle = 0.0,
    };

    // Game loop
    while (!rl.windowShouldClose()) {
        const dt = rl.getFrameTime();
        const rotation_speed: f32 = 3.0;
        const move_speed: f32 = 180.0;
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
            player.walk_timer += dt * 10.0;

            const new_x = player.x + @cos(player.angle) * move_step;
            const new_y = player.y + @sin(player.angle) * move_step;

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

        // Cabeceo
        const head_bob: f32 = if (move_step != 0.0)
            @sin(player.walk_timer) * 6.0
        else
            0.0;

        // Empieza loop
        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);

        // Techo y Suelo
        rl.drawRectangle(0, 0, @intCast(screen_width), @intCast(screen_height / 2), rl.Color{ .r = 45, .g = 45, .b = 65, .a = 255 });
        rl.drawRectangle(0, @intCast(screen_height / 2), @intCast(screen_width), @intCast(screen_height / 2), rl.Color{ .r = 35, .g = 35, .b = 35, .a = 255 });

        // Raycasting 3D
        const delta_angle = fov / screen_width_f;
        var ray_angle = player.angle - half_fov;

        for (0..screen_width) |i| {
            const cos_angle = @cos(ray_angle);
            const sin_angle = @sin(ray_angle);

            var distance: f32 = 0.0;
            const max_distance: f32 = 1200.0;
            const step_size: f32 = 1.0;

            var hit_x: f32 = player.x;
            var hit_y: f32 = player.y;
            var hit_tile: u8 = 0;

            while (distance < max_distance) {
                hit_x = player.x + cos_angle * distance;
                hit_y = player.y + sin_angle * distance;

                if (hit_x < 0.0 or hit_y < 0.0 or hit_x >= max_map_x or hit_y >= max_map_y) {
                    break;
                }

                const map_x: usize = @intFromFloat(hit_x / tile_size_f);
                const map_y: usize = @intFromFloat(hit_y / tile_size_f);

                if (map_x >= MAP_WIDTH or map_y >= MAP_HEIGHT) {
                    break;
                }
                if (world_map[map_y][map_x] > 0) {
                    hit_tile = world_map[map_y][map_x];
                    break;
                }

                distance += step_size;
            }

            // Correccion ojo de pez
            const corrected_dist = distance * @cos(ray_angle - player.angle);

            // Altura y posicion en pantalla
            const wall_height = (tile_size_f / @max(corrected_dist, 0.1)) * proj_plane_dist;
            const wall_top: f32 = (screen_height_f / 2.0) - (wall_height / 2.0) + head_bob;

            // Factor de sombreado por distancia
            const shade_factor: f32 = @max(0.15, 1.0 - (distance / 1000.0));

            // Color base segun tipo de pared
            var base_r: f32 = 180.0;
            var base_g: f32 = 180.0;
            var base_b: f32 = 180.0;

            if (hit_tile == 2) {
                base_r = 70.0;
                base_g = 110.0;
                base_b = 200.0;
            } else if (hit_tile == 3) {
                base_r = 180.0;
                base_g = 110.0;
                base_b = 50.0;
            } else if (hit_tile == 9) {
                base_r = 240.0;
                base_g = 200.0;
                base_b = 40.0;
            }

            const wall_color = rl.Color{
                .r = @intFromFloat(base_r * shade_factor),
                .g = @intFromFloat(base_g * shade_factor),
                .b = @intFromFloat(base_b * shade_factor),
                .a = 255,
            };

            rl.drawRectangle(
                @intCast(i),
                @intFromFloat(wall_top),
                1,
                @intFromFloat(wall_height),
                wall_color,
            );

            ray_angle += delta_angle;
        }

        // Minimapa en esquina superior derecha
        const mini_tile: i32 = 8;
        const mini_tile_f: f32 = 8.0;
        const minimap_offset_x: i32 = @as(i32, @intCast(screen_width)) - (@as(i32, @intCast(MAP_WIDTH)) * mini_tile) - 10;
        const minimap_offset_y: i32 = 10;

        // Fondo del minimapa
        rl.drawRectangle(
            minimap_offset_x - 2,
            minimap_offset_y - 2,
            @as(i32, @intCast(MAP_WIDTH)) * mini_tile + 4,
            @as(i32, @intCast(MAP_HEIGHT)) * mini_tile + 4,
            rl.Color{ .r = 0, .g = 0, .b = 0, .a = 160 },
        );

        // Bloques del minimapa
        for (0..MAP_HEIGHT) |y| {
            for (0..MAP_WIDTH) |x| {
                const cell = world_map[y][x];
                const block_x = minimap_offset_x + @as(i32, @intCast(x)) * mini_tile;
                const block_y = minimap_offset_y + @as(i32, @intCast(y)) * mini_tile;

                if (cell == 1) {
                    rl.drawRectangle(block_x, block_y, mini_tile - 1, mini_tile - 1, rl.Color.gray);
                } else if (cell == 2) {
                    rl.drawRectangle(block_x, block_y, mini_tile - 1, mini_tile - 1, rl.Color.blue);
                } else if (cell == 3) {
                    rl.drawRectangle(block_x, block_y, mini_tile - 1, mini_tile - 1, rl.Color.brown);
                } else if (cell == 9) {
                    rl.drawRectangle(block_x, block_y, mini_tile - 1, mini_tile - 1, rl.Color.gold);
                }
            }
        }

        // Posicion y linea de vista del jugador en minimapa
        const player_mini_scale = mini_tile_f / tile_size_f;
        const player_mini_x = @as(f32, @floatFromInt(minimap_offset_x)) + (player.x * player_mini_scale);
        const player_mini_y = @as(f32, @floatFromInt(minimap_offset_y)) + (player.y * player_mini_scale);

        rl.drawCircle(@intFromFloat(player_mini_x), @intFromFloat(player_mini_y), 3, rl.Color.yellow);
        rl.drawLine(
            @intFromFloat(player_mini_x),
            @intFromFloat(player_mini_y),
            @intFromFloat(player_mini_x + @cos(player.angle) * 8.0),
            @intFromFloat(player_mini_y + @sin(player.angle) * 8.0),
            rl.Color.red,
        );

        // FPS
        rl.drawFPS(10, 10);

        rl.endDrawing();
    }
}
