//! The Line plot

const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const RGB = @import("../svg/util/rgb.zig").RGB;
const Range = @import("../util/range.zig").Range;

const Plot = @import("Plot.zig");
const FigureInfo = @import("FigureInfo.zig");

const Line = @This();

/// The style of the line plot
pub const Style = struct {
    /// The color of the line
    color: RGB = 0x0000FF,
    /// The width of the line
    width: f32 = 2.0,
};

/// The x-axis values of the line plot
x: ?[]const f32 = null,
/// The y-axis values of the line plot
y: []const f32,
/// The style of the line plot
style: Style = .{},

/// Returns the range of the x values of the line plot
pub fn get_x_range(impl: *const anyopaque) Range(f32) {
    const self: *const Line = @ptrCast(@alignCast(impl));
    if (self.x) |x| {
        const min_max = std.mem.minMax(f32, x);
        return Range(f32) {
            .min = min_max.@"0",
            .max = min_max.@"1",
        };
    } else {
        return Range(f32) {
            .min = 0.0,
            .max = @floatFromInt(self.y.len - 1),
        };
    }
}

/// Returns the range of the y values of the line plot
pub fn get_y_range(impl: *const anyopaque) Range(f32) {
    const self: *const Line = @ptrCast(@alignCast(impl));
    const min_max = std.mem.minMax(f32, self.y);
    return Range(f32) {
        .min = min_max.@"0",
        .max = min_max.@"1",
    };
}

/// Draws the line plot (converts to SVG)
pub fn draw(impl: *const anyopaque, allocator: Allocator, svg: *SVG, info: FigureInfo) !void {
    const self: *const Line = @ptrCast(@alignCast(impl));
    _ = allocator;

    if (self.x) |x_| {
        var previous: ?f32 = null;
        var previous_x: ?f32 = null;
        for(x_, self.y) |x, y| {
            if (previous == null) {
                previous = y;
                previous_x = x;
                continue; // Skipping the 1st iteration
            }

            const x1 = info.compute_x(previous_x.?);
            const y1 = info.compute_y(previous.?);
            const x2 = info.compute_x(x);
            const y2 = info.compute_y(y);

            try svg.addLine(
                .{ 
                    .x1 = .{ .pixel = x1 }, 
                    .y1 = .{ .pixel = y1 }, 
                    .x2 = .{ .pixel = x2 }, 
                    .y2 = . { .pixel = y2 },
                    .stroke = self.style.color,
                    .stroke_width = . { .pixel = self.style.width },
                },
            );

            previous = y;
            previous_x = x;
        }
    } else {
        var previous: ?f32 = null;
        var previous_x: ?f32 = null;
        for (self.y, 0..) |y, x| {
            if (previous == null) {
                previous = y;
                previous_x = @floatFromInt(x);
                continue; // Skipping the 1st iteration
            }

            const x1 = info.compute_x(previous_x.?);
            const y1 = info.compute_y(previous.?);
            const x2 = info.compute_x(@floatFromInt(x));
            const y2 = info.compute_y(y);

            try svg.addLine(
                .{ 
                    .x1 = .{ .pixel = x1 }, 
                    .y1 = .{ .pixel = y1 }, 
                    .x2 = .{ .pixel = x2 }, 
                    .y2 = . { .pixel = y2 },
                    .stroke = self.style.color,
                    .stroke_width = . { .pixel = self.style.width },
                },
            );

            previous = y;
            previous_x = @floatFromInt(x);
        }
    }
}

/// Convert the Line Plot to a Plot (its interface)
pub fn interface(self: *const Line) Plot {
    return Plot.init(
        @as(*const anyopaque, self),
        &get_x_range,
        &get_y_range,
        &draw
    );
}