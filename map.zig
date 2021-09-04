
// TODO
// change Map.obsticles

const std = @import("std");

const glob = @import("./glob.zig");
const Display = @import("./display.zig").Display;
const Pix_axis_pos = @import("./display.zig").Pix_axis_pos;
const Pix_pos = @import("./display.zig").Pix_pos;


pub const Pos = struct{
    x: Map_axis_pos,
    y: Map_axis_pos,
};

pub const Map_axis_pos = f32;


pub const Map = struct{
    endx: Map_axis_pos,
    endy: Map_axis_pos,
    obsticles: []struct{// hui
        pos: Pos,
        model: glob.Limb,
    } = undefined,

    pub fn init(s: *@This(), aloc: *std.mem.Allocator, display: *Display) !void {
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

    pub fn move(s: *@This(), phys: *glob.Phys, change: Pos) void {// add map resolution, currently inf
    
        var xi: i8 = 0;
        var yi: i8 = 0;

        for(phys.model) |line, li| {
            for(line) |char, ci| {
                if(s.collision(.{
                                .y=phys.pos.y + change.y + @intToFloat(@TypeOf(phys.pos.y), li),
                                .x=phys.pos.x + change.x + @intToFloat(@TypeOf(phys.pos.x), ci),
                                },
                                char,
                                )) return;
            }
        }

        phys.pos.x += change.x;
        phys.pos.y += change.y;

    }

    fn collision(s: *@This(), pos: Pos, limb: glob.Limb) bool {// TODO change x,y

        if(pos.x < 0 or pos.y < 0) return true;
        if(pos.x >= s.endx or pos.y >= s.endy) return true;

        if(limb == glob.LIMB_NOPHYS) return false; // this is not above as the player model
                                                   // may start with NOPHYS
    
        for(s.obsticles) |ob| {
            if(ob.pos.y == pos.y and ob.pos.x == pos.x) return true;
        }
        return false;
    }

    pub fn draw(s: *@This(), display: *Display) void {
        for(s.obsticles) |ob| {
            display.limb(.{.x=@floatToInt(Pix_axis_pos, ob.pos.x),
                           .y=@floatToInt(Pix_axis_pos, ob.pos.y)}, ob.model);
        }
    }
};

