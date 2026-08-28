const Proyecto1 = @import("Proyecto1");
const std = @import("std");
const rl = @import("raylib");

// Dimensiones
const MAP_WIDTH: usize = 16;
const MAP_HEIGHT: usize = 16;
const TILE_SIZE: i32 = 64;

// Estados del juego
const GameState = enum {
    start,
    playing,
    game_over,
    victory,
};

// Trampa y Moneda en el mundo
const Trap = struct {
    x: f32,
    y: f32,
};

const Coin = struct {
    x: f32,
    y: f32,
    collected: bool = false,
};

// 1 Tex_stone 2 Tex_brick 3 Tex_dark
const level_1 = [MAP_HEIGHT][MAP_WIDTH]u8{
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

const level_2 = [MAP_HEIGHT][MAP_WIDTH]u8{
    .{ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 },
    .{ 2, 0, 0, 0, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2 },
    .{ 2, 0, 2, 0, 2, 0, 2, 2, 0, 2, 0, 2, 2, 2, 0, 2 },
    .{ 2, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 2, 0, 2 },
    .{ 2, 0, 2, 2, 2, 0, 2, 0, 0, 0, 0, 2, 0, 2, 0, 2 },
    .{ 2, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 2, 0, 2, 0, 2 },
    .{ 2, 2, 2, 0, 2, 0, 2, 2, 2, 2, 0, 2, 0, 2, 0, 2 },
    .{ 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2 },
    .{ 2, 0, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2 },
    .{ 2, 0, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 2 },
    .{ 2, 0, 2, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 2, 0, 2 },
    .{ 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, 2 },
    .{ 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 0, 2, 0, 2 },
    .{ 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 9, 2 },
    .{ 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2 },
    .{ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 },
};

// Trampas en los mapas
const level_1_traps = [_]Trap{
    .{ .x = 4.5 * 64.0, .y = 4.5 * 64.0 },
    .{ .x = 10.5 * 64.0, .y = 4.5 * 64.0 },
    .{ .x = 4.5 * 64.0, .y = 13.5 * 64.0 },
};

const level_2_traps = [_]Trap{
    .{ .x = 8.5 * 64.0, .y = 4.5 * 64.0 },
    .{ .x = 9.5 * 64.0, .y = 4.5 * 64.0 },
    .{ .x = 10.5 * 64.0, .y = 4.5 * 64.0 },
    .{ .x = 4.5 * 64.0, .y = 10.5 * 64.0 },
};

// Jugador
const Player = struct {
    x: f32,
    y: f32,
    angle: f32,
    walk_timer: f32 = 0.0,
};

pub fn main() !void {
    const screen_width: usize = 940;
    const screen_height: usize = 780;
    const tile_size_f = @as(f32, @floatFromInt(TILE_SIZE));

    const max_map_x = @as(f32, @floatFromInt(MAP_WIDTH)) * tile_size_f;
    const max_map_y = @as(f32, @floatFromInt(MAP_HEIGHT)) * tile_size_f;

    const screen_width_f = @as(f32, @floatFromInt(screen_width));
    const screen_height_f = @as(f32, @floatFromInt(screen_height));

    // FOV y Proyeccion
    const fov: f32 = 75.0 * (std.math.pi / 180.0);
    const half_fov: f32 = fov / 2.0;
    const proj_plane_dist: f32 = (screen_width_f / 2.0) / @tan(half_fov);

    rl.initWindow(@intCast(screen_width), @intCast(screen_height), "Proyecto 1 - Raycaster 3D");
    defer rl.closeWindow();

    // Inicializar dispositivo de audio
    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    // Cargar Musica de Fondo
    const bgm = try rl.loadMusicStream("resources/dungeon.mp3");
    defer rl.unloadMusicStream(bgm);
    rl.setMusicVolume(bgm, 0.5);
    rl.playMusicStream(bgm);

    // Cargar Sonido de Moneda
    const coin_sound = try rl.loadSound("resources/coin.wav");
    defer rl.unloadSound(coin_sound);

    // Cargar Texturas de Paredes
    const tex_stone = try rl.loadTexture("resources/wall_stone.png");
    defer rl.unloadTexture(tex_stone);

    const tex_brick = try rl.loadTexture("resources/wall_brick.png");
    defer rl.unloadTexture(tex_brick);

    const tex_dark = try rl.loadTexture("resources/wall_dark.png");
    defer rl.unloadTexture(tex_dark);

    // Cargar Trampa GIF
    var spike_anim_frames: i32 = 0;
    const spike_image = try rl.loadImageAnim("resources/Spike.gif", &spike_anim_frames);
    defer rl.unloadImage(spike_image);
    const trap_texture = try rl.loadTextureFromImage(spike_image);
    defer rl.unloadTexture(trap_texture);

    // Cargar Moneda GIF
    var coin_anim_frames: i32 = 0;
    const coin_image = try rl.loadImageAnim("resources/Coin.gif", &coin_anim_frames);
    defer rl.unloadImage(coin_image);
    const coin_texture = try rl.loadTextureFromImage(coin_image);
    defer rl.unloadTexture(coin_texture);

    var current_frame_spike: usize = 0;
    var timer_spike: f32 = 0.0;

    var current_frame_coin: usize = 0;
    var timer_coin: f32 = 0.0;

    rl.setTargetFPS(15);

    var game_state = GameState.start;
    var current_level_idx: usize = 1;
    var current_map = level_1;

    // Monedas
    var coins_l1 = [_]Coin{
        .{ .x = 4.5 * 64.0, .y = 1.5 * 64.0 },
        .{ .x = 10.5 * 64.0, .y = 3.5 * 64.0 },
        .{ .x = 3.5 * 64.0, .y = 9.5 * 64.0 },
    };

    var coins_l2 = [_]Coin{
        .{ .x = 1.5 * 64.0, .y = 11.5 * 64.0 },
        .{ .x = 6.5 * 64.0, .y = 1.5 * 64.0 },
        .{ .x = 10.5 * 64.0, .y = 9.5 * 64.0 },
    };

    var player = Player{
        .x = 1.5 * tile_size_f,
        .y = 1.5 * tile_size_f,
        .angle = 0.0,
    };

    var z_buffer: [screen_width]f32 = undefined;
    var door_locked_msg_timer: f32 = 0.0;

    // Game loop
    while (!rl.windowShouldClose()) {
        const dt = rl.getFrameTime();

        // Musica de fondo
        rl.updateMusicStream(bgm);

        // Spike GIF
        timer_spike += dt;
        if (timer_spike >= 0.12) {
            timer_spike = 0.0;
            const total_frames = @as(usize, @intCast(@max(1, spike_anim_frames)));
            current_frame_spike = (current_frame_spike + 1) % total_frames;
            const frame_bytes = @as(usize, @intCast(spike_image.width * spike_image.height * 4));
            const raw_ptr: [*]u8 = @ptrCast(spike_image.data);
            rl.updateTexture(trap_texture, @ptrCast(raw_ptr + (current_frame_spike * frame_bytes)));
        }

        // Coin GIF
        timer_coin += dt;
        if (timer_coin >= 0.10) {
            timer_coin = 0.0;
            const total_frames = @as(usize, @intCast(@max(1, coin_anim_frames)));
            current_frame_coin = (current_frame_coin + 1) % total_frames;
            const frame_bytes = @as(usize, @intCast(coin_image.width * coin_image.height * 4));
            const raw_ptr: [*]u8 = @ptrCast(coin_image.data);
            rl.updateTexture(coin_texture, @ptrCast(raw_ptr + (current_frame_coin * frame_bytes)));
        }

        if (door_locked_msg_timer > 0.0) {
            door_locked_msg_timer -= dt;
        }

        switch (game_state) {
            .start => {
                if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                    game_state = .playing;
                }
            },
            .game_over, .victory => {
                if (rl.isKeyPressed(rl.KeyboardKey.r)) {
                    current_level_idx = 1;
                    current_map = level_1;
                    player.x = 1.5 * tile_size_f;
                    player.y = 1.5 * tile_size_f;
                    player.angle = 0.0;

                    // Reiniciar monedas
                    for (&coins_l1) |*c| c.collected = false;
                    for (&coins_l2) |*c| c.collected = false;

                    game_state = .playing;
                }
            },
            .playing => {
                // Tecla N para saltar nivel
                if (rl.isKeyPressed(rl.KeyboardKey.n)) {
                    if (current_level_idx == 1) {
                        current_level_idx = 2;
                        current_map = level_2;
                        player.x = 1.5 * tile_size_f;
                        player.y = 1.5 * tile_size_f;
                    } else {
                        game_state = .victory;
                    }
                }

                const rotation_speed: f32 = 3.0;
                const move_speed: f32 = 180.0;
                var move_step: f32 = 0.0;

                if (rl.isKeyDown(rl.KeyboardKey.left) or rl.isKeyDown(rl.KeyboardKey.a)) {
                    player.angle -= rotation_speed * dt;
                }
                if (rl.isKeyDown(rl.KeyboardKey.right) or rl.isKeyDown(rl.KeyboardKey.d)) {
                    player.angle += rotation_speed * dt;
                }

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

                    const check_x: usize = @intFromFloat(new_x / tile_size_f);
                    const check_y: usize = @intFromFloat(new_y / tile_size_f);
                    const current_x: usize = @intFromFloat(player.x / tile_size_f);
                    const current_y: usize = @intFromFloat(player.y / tile_size_f);

                    if (check_x < MAP_WIDTH and (current_map[current_y][check_x] == 0 or current_map[current_y][check_x] == 9)) {
                        player.x = new_x;
                    }
                    if (check_y < MAP_HEIGHT and (current_map[check_y][current_x] == 0 or current_map[check_y][current_x] == 9)) {
                        player.y = new_y;
                    }

                    // Recoleccion de monedas
                    const active_coins = if (current_level_idx == 1) coins_l1[0..] else coins_l2[0..];
                    for (active_coins) |*coin| {
                        if (!coin.collected) {
                            const d_coin = @sqrt((player.x - coin.x) * (player.x - coin.x) + (player.y - coin.y) * (player.y - coin.y));
                            if (d_coin < 30.0) {
                                coin.collected = true;
                                rl.playSound(coin_sound); // Reproducir sonido de moneda
                            }
                        }
                    }

                    // Contar cuantas monedas se han recogido
                    var collected_count: usize = 0;
                    for (active_coins) |c| {
                        if (c.collected) collected_count += 1;
                    }
                    const all_coins_collected = (collected_count == active_coins.len);

                    // Llegada a la meta requiere todas las monedas
                    const p_map_x: usize = @intFromFloat(player.x / tile_size_f);
                    const p_map_y: usize = @intFromFloat(player.y / tile_size_f);
                    if (p_map_x < MAP_WIDTH and p_map_y < MAP_HEIGHT and current_map[p_map_y][p_map_x] == 9) {
                        if (all_coins_collected) {
                            if (current_level_idx == 1) {
                                current_level_idx = 2;
                                current_map = level_2;
                                player.x = 1.5 * tile_size_f;
                                player.y = 1.5 * tile_size_f;
                            } else {
                                game_state = .victory;
                            }
                        } else {
                            door_locked_msg_timer = 2.0;
                        }
                    }

                    // Colision con trampas
                    const active_traps = if (current_level_idx == 1) level_1_traps[0..] else level_2_traps[0..];
                    for (active_traps) |trap| {
                        const dist_trap = @sqrt((player.x - trap.x) * (player.x - trap.x) + (player.y - trap.y) * (player.y - trap.y));
                        if (dist_trap < 30.0) {
                            game_state = .game_over;
                        }
                    }
                }
            },
        }

        // Empieza loop
        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);

        if (game_state == .start) {
            rl.drawText("Proyecto 1 - Graficas", 320, 330, 32, rl.Color.gold);
            rl.drawText("Controles: WASD o Flechas.", 360, 390, 18, rl.Color.light_gray);
            rl.drawText("Objetivo: Recoge todas las monedas y encuentra la salida.", 290, 425, 17, rl.Color.yellow);
            rl.drawText("Cuidado con las trampas", 370, 460, 18, rl.Color.red);
            rl.drawText("Presiona ENTER para comenzar", 330, 530, 20, rl.Color.green);
        } else if (game_state == .game_over) {
            rl.drawText("¡Caiste en una trampa!", 330, 380, 32, rl.Color.red);
            rl.drawText("Presiona R para reiniciar el nivel", 350, 460, 20, rl.Color.white);
        } else if (game_state == .victory) {
            rl.drawText("¡HAS ESCAPADO!", 370, 380, 32, rl.Color.gold);
            rl.drawText("¡Recolectaste las monedas y ganaste!", 310, 440, 18, rl.Color.green);
            rl.drawText("Presiona R para jugar de nuevo", 330, 500, 18, rl.Color.white);
        } else if (game_state == .playing) {
            const move_step_dummy: f32 = if (rl.isKeyDown(rl.KeyboardKey.up) or rl.isKeyDown(rl.KeyboardKey.down) or rl.isKeyDown(rl.KeyboardKey.w) or rl.isKeyDown(rl.KeyboardKey.s)) 1.0 else 0.0;
            const head_bob: f32 = if (move_step_dummy != 0.0) @sin(player.walk_timer) * 6.0 else 0.0;

            // Techo y Suelo
            rl.drawRectangle(0, 0, @intCast(screen_width), @intCast(screen_height / 2), rl.Color{ .r = 25, .g = 25, .b = 35, .a = 255 });
            rl.drawRectangle(0, @intCast(screen_height / 2), @intCast(screen_width), @intCast(screen_height / 2), rl.Color{ .r = 20, .g = 20, .b = 20, .a = 255 });

            // Paredes con textura
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

                    if (hit_x < 0.0 or hit_y < 0.0 or hit_x >= max_map_x or hit_y >= max_map_y) break;

                    const map_x: usize = @intFromFloat(hit_x / tile_size_f);
                    const map_y: usize = @intFromFloat(hit_y / tile_size_f);

                    if (map_x >= MAP_WIDTH or map_y >= MAP_HEIGHT) break;
                    if (current_map[map_y][map_x] > 0) {
                        hit_tile = current_map[map_y][map_x];
                        break;
                    }

                    distance += step_size;
                }

                const corrected_dist = distance * @cos(ray_angle - player.angle);
                z_buffer[i] = corrected_dist;

                const wall_height = (tile_size_f / @max(corrected_dist, 0.1)) * proj_plane_dist;
                const wall_top: f32 = (screen_height_f / 2.0) - (wall_height / 2.0) + head_bob;

                const shade_factor: f32 = @max(0.2, 1.0 - (distance / 900.0));
                const shade_val: u8 = @intFromFloat(255.0 * shade_factor);
                const tint_color = rl.Color{ .r = shade_val, .g = shade_val, .b = shade_val, .a = 255 };

                var wall_sub_x = hit_x / tile_size_f;
                wall_sub_x -= @floor(wall_sub_x);
                var wall_sub_y = hit_y / tile_size_f;
                wall_sub_y -= @floor(wall_sub_y);

                const tex_u = if (@min(wall_sub_x, 1.0 - wall_sub_x) < @min(wall_sub_y, 1.0 - wall_sub_y)) wall_sub_y else wall_sub_x;

                var active_tex = tex_stone;
                if (hit_tile == 2) {
                    active_tex = tex_brick;
                } else if (hit_tile == 3) {
                    active_tex = tex_dark;
                }

                if (hit_tile == 9) {
                    rl.drawRectangle(@intCast(i), @intFromFloat(wall_top), 1, @intFromFloat(wall_height), rl.Color.gold);
                } else {
                    const tex_w = @as(f32, @floatFromInt(active_tex.width));
                    const tex_h = @as(f32, @floatFromInt(active_tex.height));

                    const src_rect = rl.Rectangle{
                        .x = @floor(tex_u * tex_w),
                        .y = 0.0,
                        .width = 1.0,
                        .height = tex_h,
                    };
                    const dest_rect = rl.Rectangle{
                        .x = @as(f32, @floatFromInt(i)),
                        .y = wall_top,
                        .width = 1.0,
                        .height = wall_height,
                    };
                    rl.drawTexturePro(active_tex, src_rect, dest_rect, rl.Vector2{ .x = 0, .y = 0 }, 0.0, tint_color);
                }

                ray_angle += delta_angle;
            }

            // Sprites de trampas
            const active_traps = if (current_level_idx == 1) level_1_traps[0..] else level_2_traps[0..];
            for (active_traps) |trap| {
                const dx = trap.x - player.x;
                const dy = trap.y - player.y;
                const dist = @sqrt(dx * dx + dy * dy);
                const sprite_angle = std.math.atan2(dy, dx);
                var diff = sprite_angle - player.angle;

                while (diff < -std.math.pi) diff += 2.0 * std.math.pi;
                while (diff > std.math.pi) diff -= 2.0 * std.math.pi;

                if (diff > -half_fov and diff < half_fov and dist > 10.0) {
                    const corr_dist = dist * @cos(diff);
                    const sprite_scale: f32 = 0.5;
                    const sprite_size = (tile_size_f * sprite_scale / @max(corr_dist, 0.1)) * proj_plane_dist;

                    const sx = (screen_width_f / 2.0) + (diff / half_fov) * (screen_width_f / 2.0) - (sprite_size / 2.0);
                    const sy = (screen_height_f / 2.0) + head_bob + (sprite_size * 0.4);
                    const center_col = @as(i32, @intFromFloat(sx + sprite_size / 2.0));

                    if (center_col >= 0 and center_col < @as(i32, @intCast(screen_width))) {
                        const col_idx: usize = @intCast(center_col);
                        if (corr_dist < z_buffer[col_idx]) {
                            const src_rect = rl.Rectangle{
                                .x = 0,
                                .y = 0,
                                .width = @as(f32, @floatFromInt(trap_texture.width)),
                                .height = @as(f32, @floatFromInt(trap_texture.height)),
                            };
                            const dest_rect = rl.Rectangle{
                                .x = sx,
                                .y = sy,
                                .width = sprite_size,
                                .height = sprite_size * 0.5,
                            };
                            rl.drawTexturePro(trap_texture, src_rect, dest_rect, rl.Vector2{ .x = 0, .y = 0 }, 0.0, rl.Color.white);
                        }
                    }
                }
            }

            // Sprites de monedas
            const active_coins = if (current_level_idx == 1) coins_l1[0..] else coins_l2[0..];
            for (active_coins) |coin| {
                if (!coin.collected) {
                    const dx = coin.x - player.x;
                    const dy = coin.y - player.y;
                    const dist = @sqrt(dx * dx + dy * dy);
                    const sprite_angle = std.math.atan2(dy, dx);
                    var diff = sprite_angle - player.angle;

                    while (diff < -std.math.pi) diff += 2.0 * std.math.pi;
                    while (diff > std.math.pi) diff -= 2.0 * std.math.pi;

                    if (diff > -half_fov and diff < half_fov and dist > 10.0) {
                        const corr_dist = dist * @cos(diff);
                        const sprite_scale: f32 = 0.4;
                        const sprite_size = (tile_size_f * sprite_scale / @max(corr_dist, 0.1)) * proj_plane_dist;

                        const sx = (screen_width_f / 2.0) + (diff / half_fov) * (screen_width_f / 2.0) - (sprite_size / 2.0);
                        const float_offset = @sin(player.walk_timer + @as(f32, @floatFromInt(current_frame_coin))) * 4.0;
                        const sy = (screen_height_f / 2.0) + head_bob - (sprite_size * 0.1) + float_offset;

                        const center_col = @as(i32, @intFromFloat(sx + sprite_size / 2.0));

                        if (center_col >= 0 and center_col < @as(i32, @intCast(screen_width))) {
                            const col_idx: usize = @intCast(center_col);
                            if (corr_dist < z_buffer[col_idx]) {
                                const src_rect = rl.Rectangle{
                                    .x = 0,
                                    .y = 0,
                                    .width = @as(f32, @floatFromInt(coin_texture.width)),
                                    .height = @as(f32, @floatFromInt(coin_texture.height)),
                                };
                                const dest_rect = rl.Rectangle{
                                    .x = sx,
                                    .y = sy,
                                    .width = sprite_size,
                                    .height = sprite_size,
                                };
                                rl.drawTexturePro(coin_texture, src_rect, dest_rect, rl.Vector2{ .x = 0, .y = 0 }, 0.0, rl.Color.white);
                            }
                        }
                    }
                }
            }

            // Minimapa
            const mini_tile: i32 = 8;
            const mini_tile_f: f32 = 8.0;
            const minimap_offset_x: i32 = @as(i32, @intCast(screen_width)) - (@as(i32, @intCast(MAP_WIDTH)) * mini_tile) - 10;
            const minimap_offset_y: i32 = 10;

            rl.drawRectangle(
                minimap_offset_x - 2,
                minimap_offset_y - 2,
                @as(i32, @intCast(MAP_WIDTH)) * mini_tile + 4,
                @as(i32, @intCast(MAP_HEIGHT)) * mini_tile + 4,
                rl.Color{ .r = 0, .g = 0, .b = 0, .a = 160 },
            );

            for (0..MAP_HEIGHT) |y| {
                for (0..MAP_WIDTH) |x| {
                    const cell = current_map[y][x];
                    const block_x = minimap_offset_x + @as(i32, @intCast(x)) * mini_tile;
                    const block_y = minimap_offset_y + @as(i32, @intCast(y)) * mini_tile;

                    if (cell == 1) {
                        rl.drawRectangle(block_x, block_y, mini_tile - 1, mini_tile - 1, rl.Color.gray);
                    } else if (cell == 2) {
                        rl.drawRectangle(block_x, block_y, mini_tile - 1, mini_tile - 1, rl.Color.brown);
                    } else if (cell == 3) {
                        rl.drawRectangle(block_x, block_y, mini_tile - 1, mini_tile - 1, rl.Color.dark_gray);
                    } else if (cell == 9) {
                        rl.drawRectangle(block_x, block_y, mini_tile - 1, mini_tile - 1, rl.Color.gold);
                    }
                }
            }

            // Trampas en minimapa (rojo)
            const player_mini_scale = mini_tile_f / tile_size_f;
            for (active_traps) |trap| {
                const t_mini_x = @as(f32, @floatFromInt(minimap_offset_x)) + (trap.x * player_mini_scale);
                const t_mini_y = @as(f32, @floatFromInt(minimap_offset_y)) + (trap.y * player_mini_scale);
                rl.drawCircle(@intFromFloat(t_mini_x), @intFromFloat(t_mini_y), 2, rl.Color.red);
            }

            // Monedas en minimapa (amarillo)
            for (active_coins) |coin| {
                if (!coin.collected) {
                    const c_mini_x = @as(f32, @floatFromInt(minimap_offset_x)) + (coin.x * player_mini_scale);
                    const c_mini_y = @as(f32, @floatFromInt(minimap_offset_y)) + (coin.y * player_mini_scale);
                    rl.drawCircle(@intFromFloat(c_mini_x), @intFromFloat(c_mini_y), 2, rl.Color.gold);
                }
            }

            // Jugador en minimapa
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

            // Interfaz
            var collected_count: usize = 0;
            for (active_coins) |c| {
                if (c.collected) collected_count += 1;
            }

            if (current_level_idx == 1) {
                rl.drawText("Nivel 1", 10, 35, 14, rl.Color.white);
            } else {
                rl.drawText("Nivel 2", 10, 35, 14, rl.Color.white);
            }

            // Contador de monedas
            var coin_hud_buf: [32]u8 = undefined;
            const coin_hud_text = std.fmt.bufPrintZ(&coin_hud_buf, "Monedas: {d}/{d}", .{ collected_count, active_coins.len }) catch "Monedas";
            rl.drawText(coin_hud_text, 10, 55, 16, rl.Color.gold);

            // Mensaje de puerta cerrada
            if (door_locked_msg_timer > 0.0) {
                rl.drawText("Recoge todas las monedas para salir", 120, 200, 18, rl.Color.yellow);
            }

            rl.drawFPS(10, 10);
        }

        rl.endDrawing();
    }
}
