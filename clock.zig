
const std = @import("std");

pub const Clock = struct{

    min_dt: i128 = undefined,
    time: i128 = undefined,

    pub fn init(s: *@This(), max_fps: u64) void {
        s.min_dt = @divFloor(std.time.ns_per_s, max_fps);
        s.time = std.time.nanoTimestamp();
    }

    pub fn deinit(s: *@This()) void {
        // empty
    }

    pub fn tick(s: *@This()) i128 {

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
