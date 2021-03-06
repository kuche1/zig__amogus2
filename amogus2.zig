
// TODO
// networking
// keypress keyrelease
// custom skins
// custom maps
// rework map
// custom maps
// replace glob
// add non-en_US support
// separate model from hitbox?

const version = 0.9;

const std = @import("std");
const print = std.io.getStdOut().writer().print;
const echo = std.debug.print;

const glob = @import("./glob.zig");
const Keyboard = @import("./keyboard.zig").Keyboard;
//
const Display = @import("./display.zig").Display;
const Pix_axis_pos = @import("./display.zig").Pix_axis_pos;
//
const Clock = @import("./clock.zig").Clock;
const Map = @import("./map.zig").Map;
const Player = @import("./player.zig").Player;

const Settings = @import("./settings.zig").Settings;


pub fn main() !void {

    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const aloc = &allocator.allocator;

    try print(
        \\Amogus 3 demo v{}
        \\== Patch notes ==
        \\idk
        \\max speed increased to infinite
        \\collision broken
        \\
        ,.{version}
    );

    //
    var keyboard = Keyboard{};
    try keyboard.init();
    defer keyboard.deinit();
    //
    var settings = Settings{};
    try settings.init();
    defer settings.deinit();
    //
    var display = Display{};
    try display.init(aloc);
    defer display.deinit(aloc);
    //
    var clock = Clock{};
    clock.init(settings.max_fps);
    defer clock.deinit();
    //
    var map = Map{.endy=settings.map_sizey, .endx=settings.map_sizex};
    try map.init(aloc, &display);
    defer map.deinit(aloc);
    try map.add_obsticle(aloc, .{.y=5, .x=10}, 'S');
    try map.add_obsticle(aloc, .{.y=5, .x=11}, 'U');
    try map.add_obsticle(aloc, .{.y=5, .x=12}, 'S');
    //
    var player = Player{};
    try player.init(aloc);
    defer player.deinit(aloc);
    player.spawn(.{.x=0, .y=0});
    //

    var running = true;

    while(running){

        try display.clear(aloc, &map);
        map.draw(&display);
        player.draw(&display);
        try display.draw(.{.x=@floatToInt(Pix_axis_pos, map.endx)+1, 
                           .y=@floatToInt(Pix_axis_pos, map.endy)+1});


        const dt = clock.tick();


        while(true) {

            const inp = keyboard.char() catch break;

            if(inp == settings.key.quit) running = false
            else if(inp == settings.key.move_left)  player.move_left()
            else if(inp == settings.key.move_right) player.move_right()
            else if(inp == settings.key.move_up)    player.move_up()
            else if(inp == settings.key.move_down)  player.move_down()
            ;

        }

        player.commit_movement(dt, &map);

    }

}
