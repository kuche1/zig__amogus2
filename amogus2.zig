
const std = @import("std");
const echo = std.debug.print;

//pub const io_mode = .evented;

const MAX_FPS = 5;

pub fn main() !void {

    echo(
        \\Amogus 2 demo 4
        \\== Patch notes ==
        \\Max FPS is now {}
        \\increased number of player polygons
        \\moved CUM
        \\closing amogus is now possible
        \\
        ,.{MAX_FPS}
    );

    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const aloc = &allocator.allocator;

    var resx: u5 = 16;
    var resy: u5 = 9;


    var keyboard = Keyboard{};
    //
    var display = Display{.resx=resx, .resy=resy};
    try display.init(aloc);
    defer display.deinit(aloc);
    //
    var clock = Clock{.min_dt=@divFloor(std.time.ns_per_s, MAX_FPS)};
    clock.init();
    defer clock.deinit();
    //
    var map = Map{.endy=resy, .endx=resx};
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
                
                'a' => map.move(&player.pos, &player.model, 0, -1),
                'd' => map.move(&player.pos, &player.model, 0, 1),
                'w' => map.move(&player.pos, &player.model, -1, 0),
                's' => map.move(&player.pos, &player.model, 1, 0),
                
                else => echo("bruh: {c}\n",.{inp}),
            }

        }

    }

}


const Player = struct{
    pos: Pos = undefined,
    model: Model = undefined,

    fn init(s: *@This(), aloc: *std.mem.Allocator) !void {

        //const model = @embedFile("./models/player");

        //if(model[model.len] != 0) unreachable;
        //if(model[model.len -1] != '\n') unreachable;

        //const fixed = model[0..model.len -1];

        //const fixed = "pussy";

        //s.model = try aloc.alloc(u8, fixed.len);
        //errdefer aloc.free(s.model);

        //for(fixed) |char, i| {
        //    s.model[i] = char;
        //}
        
        //s.rect.lx = @intCast(@TypeOf(s.rect.lx), s.model.len);
        //s.rect.ly = 1;

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

        s.model = try aloc.alloc([]u8, 2);
        errdefer aloc.free(s.model);

        s.model[0] = model1;
        s.model[1] = model2;

    }

    fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        for(s.model) |line| {
            aloc.free(line);
        }
        aloc.free(s.model);
    }

    fn spawn(s: *@This(), x: i8, y: i8) void {
        s.pos.x = x;
        s.pos.y = y;
    }

    fn draw(s: *@This(), display: *Display) void {
        //for(s.model) |char, i| {
            //unreachable;
            //display.pix(@intCast(usize, s.rect.y), @intCast(usize, s.rect.x) + i, char);
        //}
        for(s.model) |line, li| {
            for(line) |char, ci| {
                display.pix(@intCast(usize, s.pos.y)+li, @intCast(usize, s.pos.x)+ci, char);
            }
        }
    }

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

    fn move(s: *@This(), pos: *Pos, model: *Model, y: i8, x: i8) void {// add map resolution, currently inf
    
        var xi: i8 = 0;
        var yi: i8 = 0;


        //while(yi < rect.ly) : (yi += 1) {
        //    while(xi < rect.lx) : (xi += 1) {
        //        if(s.collision(rect.y+y+yi, rect.x+x+xi)) return;
        //    }
        //}

        for(model.*) |line, li| {
            for(line) |char, ci| {
                if(s.collision(pos.y+y+@intCast(i8, li), pos.x+x+@intCast(i8, ci))) return;
            }
        }

        pos.x += x;
        pos.y += y;

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

    min_dt: i128,
    time: i128 = undefined,

    fn init(s: *@This()) void {
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

