
const std = @import("std");
const echo = std.debug.print;

const Settings = @import("./settings.zig").Settings;

const verson = 0.5;

pub fn main() !void {

    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const aloc = &allocator.allocator;

    var settings = Settings{};

    echo(
        \\Amogus 2 demo 5
        \\== Patch notes ==
        \\executable for linix (lol)
        \\
        ,.{}
    );

    //
    var keyboard = Keyboard{};
    //
    var display = Display{.resx=settings.resx, .resy=settings.resy};
    try display.init(aloc);
    defer display.deinit(aloc);
    //
    var clock = Clock{};
    clock.init(settings.max_fps);
    defer clock.deinit();
    //
    var map = Map{.endy=settings.resy, .endx=settings.resx};
    try map.init(aloc);
    defer map.deinit(aloc);
    try map.add_obsticle(aloc, 5, 6, 'C');
    try map.add_obsticle(aloc, 5, 7, 'U');
    try map.add_obsticle(aloc, 5, 8, 'M');
    //
    var player = Player{};
    try player.init(aloc);
    defer player.deinit(aloc);
    player.spawn(0, 0);
    //

    var running = true;

    while(running){

        display.clear();
        map.draw(&display);
        player.draw(&display);
        try display.draw();


        const dt = clock.tick();


        while(true) {

            const inp = try keyboard.read();

            switch(inp){
                '\n' => break,
                'p' => running = false,
                
                'a' => map.move(&player.phys, 0, -1),
                'd' => map.move(&player.phys, 0, 1),
                'w' => map.move(&player.phys, -1, 0),
                's' => map.move(&player.phys, 1, 0),
                
                else => echo("bruh: {c}\n",.{inp}),
            }

        }

    }

}


const Player = struct{
    phys: Phys = undefined,
    
    fn init(s: *@This(), aloc: *std.mem.Allocator) !void {

        const part1 = [_]u8{'p', 'u', 's', 's', 'y'};
        const part2 = [_]u8{'s', 'l', 'a', 'y', 'e', 'r'};

        const model1 = try aloc.alloc(u8, part1.len);
        errdefer aloc.free(model1);
        for(part1) |item, ind| {
            model1[ind] = item;
        }

        const model2 = try aloc.alloc(u8, part2.len);
        errdefer aloc.free(model2);
        for(part2) |item, ind| {
            model2[ind] = item;
        }

        s.phys.model = try aloc.alloc([]u8, 2);
        errdefer aloc.free(s.phys.model);

        s.phys.model[0] = model1;
        s.phys.model[1] = model2;

    }

    fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        for(s.phys.model) |line| {
            aloc.free(line);
        }
        aloc.free(s.phys.model);
    }

    fn spawn(s: *@This(), x: i8, y: i8) void {
        s.phys.pos.x = x;
        s.phys.pos.y = y;
    }

    fn draw(s: *@This(), display: *Display) void {
        for(s.phys.model) |line, li| {
            for(line) |char, ci| {
                display.pix(
                            @intCast(usize, s.phys.pos.y)+li,
                            @intCast(usize, s.phys.pos.x)+ci, char
                            );
            }
        }
    }

};

const Phys = struct{
    pos: Pos,
    model: Model,
};

const Pos = struct{
    x: i8,
    y: i8,
};

const Model = [][]u8;

const Map = struct{
    endx: u7,
    endy: u7,
    obsticles: []struct{// hui
        y: i8,
        x: i8,
        model: u8,
    } = undefined,

    fn init(s: *@This(), aloc: *std.mem.Allocator) !void {
        s.obsticles = try aloc.alloc(@TypeOf(s.obsticles[0]), 0);
        defer aloc.free(s.obsticles);
    }

    fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        aloc.free(s.obsticles);
    }

    fn add_obsticle(s: *@This(), aloc: *std.mem.Allocator, y: i8, x: i8, model: u8) !void {
        s.obsticles = try aloc.realloc(s.obsticles, s.obsticles.len+1);
        s.obsticles[s.obsticles.len-1] = .{.y=y, .x=x, .model=model};
    }

    fn move(s: *@This(), phys: *Phys, y: i8, x: i8) void {// add map resolution, currently inf
    
        var xi: i8 = 0;
        var yi: i8 = 0;

        for(phys.model) |line, li| {
            for(line) |char, ci| {
                if(s.collision(
                                phys.pos.y+y+@intCast(i8, li),
                                phys.pos.x+x+@intCast(i8, ci)
                                )) return;
            }
        }

        phys.pos.x += x;
        phys.pos.y += y;

    }

    fn collision(s: *@This(), y: i8, x: i8) bool {

        if(x < 0 or y < 0) return true;
        if(x >= s.endx or y >= s.endy) return true;
    
        for(s.obsticles) |ob| {
            if(ob.y == y and ob.x == x) return true;
        }
        return false;
    }

    fn draw(s: *@This(), display: *Display) void {
        for(s.obsticles) |ob| {
            display.pix(@intCast(usize, ob.y), @intCast(usize, ob.x), ob.model);
        }
    }
};

const Keyboard = struct{
    fn read(s: *@This()) !u8 {
        const stdin = std.io.getStdIn().reader();
        return stdin.readByte();
    }
};

const Display = struct{
    resx: u8,
    resy: u8,
    buf: [][]u8 = undefined,

    fn init(s: *@This(), aloc: *std.mem.Allocator) !void {

        s.buf = try aloc.alloc([]u8, s.resy);
        errdefer aloc.free(s.buf);

        for(s.buf) |_, y| {
            s.buf[y] = try aloc.alloc(u8, s.resx);
            errdefer {
                for(buf[0..y]) |item| {
                    aloc.free(item);
                }
            }
        }

    }

    fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        for(s.buf) |line| {
            aloc.free(line);
        }
        aloc.free(s.buf);
    }

    fn pix(s: *@This(), y: usize, x: usize, v: u8) void {
        s.buf[y][x] = v;
    }

    fn clear(s: *@This()) void {
        for(s.buf) |line, y| {
            for(line) |_, x| {
                s.pix(y, x, ' ');
            }
        }
    }

    fn draw(s: *@This()) !void {

        var ind: u8 = 0;
        echo(" ", .{});
        while(ind < s.resx){
            echo("-", .{});//try print("-", .{});
            ind += 1;
        }
        echo("\n", .{});//try print("\n", .{});

        for(s.buf)|line|{
            echo("|", .{});
            for(line)|pixel|{
                echo("{c}", .{pixel});//try print("{c}", .{pixel});
            }
            echo("|\n",.{});//try print("|\n",.{});
        }

        ind = 0;
        echo(" ", .{});
        while(ind < s.resx){
            echo("-", .{});//try print("-", .{});
            ind += 1;
        }
        echo("\n", .{});//try print("\n", .{});

    }

};

const Clock = struct{

    min_dt: i128 = undefined,
    time: i128 = undefined,

    fn init(s: *@This(), max_fps: u64) void {
        s.min_dt = @divFloor(std.time.ns_per_s, max_fps);
        s.time = std.time.nanoTimestamp();
    }

    fn deinit(s: *@This()) void {
        // empty
    }

    fn tick(s: *@This()) i128 {

        const time = std.time.nanoTimestamp();
        const dt = time - s.time;
        s.time = time;

        const dt_diff = s.min_dt - dt;
        if(dt_diff > 0){
            std.time.sleep(@intCast(u64, dt_diff));
        }

        return dt;

    }

};

