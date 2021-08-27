
// TODO
// change Map.obsticles

const std = @import("std");

const glob = @import("./glob.zig");
const Display = @import("./display.zig").Display;


pub const Pos = struct{
    x: Axis_pos,
    y: Axis_pos,
};

const Axis_pos = i8;


pub const Map = struct{
    endx: Axis_pos,
    endy: Axis_pos,
    obsticles: []struct{// hui
        pos: Pos,
        model: glob.Limb,
    } = undefined,

    pub fn init(s: *@This(), aloc: *std.mem.Allocator) !void {
        s.obsticles = try aloc.alloc(@TypeOf(s.obsticles[0]), 0);
        defer aloc.free(s.obsticles);
    }

    pub fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        aloc.free(s.obsticles);
    }

    pub fn add_obsticle(s: *@This(), aloc: *std.mem.Allocator, pos: Pos, model: glob.Limb) !void {
        if(model == glob.LIMB_NOPHYS) return;
        s.obsticles = try aloc.realloc(s.obsticles, s.obsticles.len+1);
        s.obsticles[s.obsticles.len-1] = .{.pos=pos, .model=model};
    }

    pub fn move(s: *@This(), phys: *glob.Phys, y: i8, x: i8) void {// add map resolution, currently inf
    
        var xi: i8 = 0;
        var yi: i8 = 0;

        for(phys.model) |line, li| {
            for(line) |char, ci| {
                if(s.collision(
                                phys.pos.y+y+@intCast(i8, li),
                                phys.pos.x+x+@intCast(i8, ci),
                                char,
                                )) return;
            }
        }

        phys.pos.x += x;
        phys.pos.y += y;

    }

    fn collision(s: *@This(), y: i8, x: i8, limb: glob.Limb) bool {

        if(x < 0 or y < 0) return true;
        if(x >= s.endx or y >= s.endy) return true;

        if(limb == glob.LIMB_NOPHYS) return false; // this is not above as the player model
                                                   // may start with NOPHYS
    
        for(s.obsticles) |ob| {
            if(ob.pos.y == y and ob.pos.x == x) return true;
        }
        return false;
    }

    pub fn draw(s: *@This(), display: *Display) void {
        for(s.obsticles) |ob| {
            display.limb(@intCast(usize, ob.pos.y), @intCast(usize, ob.pos.x), ob.model);
        }
    }
};

