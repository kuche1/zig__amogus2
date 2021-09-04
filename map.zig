
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


const PHYSICS_RESOLUTION: Map_axis_pos = 0.1;


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

    pub fn move(s: *@This(), phys: *glob.Phys, change: Pos) bool {

        if(@fabs(change.x) > PHYSICS_RESOLUTION) {
            var sign: @TypeOf(change.x) = undefined;
            if(change.x > 0) sign = 1
            else sign = -1;
            
            if(s.move(phys, .{.x=sign*PHYSICS_RESOLUTION, .y=change.y}))
                return s.move(phys, .{.x=sign * (@fabs(change.x) - PHYSICS_RESOLUTION), .y=change.y});
            return false;
        }

        if(@fabs(change.y) > PHYSICS_RESOLUTION) {
            var sign: @TypeOf(change.y) = undefined;
            if(change.y > 0) sign = 1
            else sign = -1;
            
            if(s.move(phys, .{.y=sign*PHYSICS_RESOLUTION, .x=change.x}))
                return s.move(phys, .{.y=sign * (@fabs(change.y) - PHYSICS_RESOLUTION), .x=change.x});
            return false;
        }

        var xi: i8 = 0;
        var yi: i8 = 0;

        for(phys.model) |line, li| {
            for(line) |char, ci| {
                if(s.collision(.{
                                .y=phys.pos.y + change.y + @intToFloat(@TypeOf(phys.pos.y), li),
                                .x=phys.pos.x + change.x + @intToFloat(@TypeOf(phys.pos.x), ci),
                                },
                                char,
                                )) return false;
            }
        }

        phys.pos.x += change.x;
        phys.pos.y += change.y;

        return true;

    }

    fn collision(s: *@This(), pos: Pos, limb: glob.Limb) bool {

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

