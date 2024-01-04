//! The Stem plot

const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const RGB = @import("../svg/util/rgb.zig").RGB;
const Range = @import("../util/range.zig").Range;

const Plot = @import("Plot.zig");
const FigureInfo = @import("FigureInfo.zig");

const Shape = @import("../util/shape.zig").Shape;

const Stem = @This();

/// The style of the stem plot
pub const Style = struct {
    /// The title of the plot
    title: ?[]const u8 = null,
    /// The color of the line
    color: RGB = 0x0000FF,
    /// The width of the line
    width: f32 = 2.0,
    /// The shape of the end of the stem
    shape: Shape = .circle,
    /// The radius of the shape at the end of the stem
    radius: f32 = 4.0,
};

/// The x-axis values of the stem plot
x: ?[]const f32 = null,
/// The y-axis values of the stem plot
y: []const f32,
/// The style of the stem plot
style: Style = .{},

/// Returns the range of the x values of the stem plot
pub fn get_x_range(impl: *const anyopaque) Range(f32) {
    const self: *const Stem = @ptrCast(@alignCast(impl));
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

/// Returns the range of the y values of the stem plot
pub fn get_y_range(impl: *const anyopaque) Range(f32) {
    const self: *const Stem = @ptrCast(@alignCast(impl));
    const min_max = std.mem.minMax(f32, self.y);
    return Range(f32) {
        .min = min_max.@"0",
        .max = min_max.@"1",
    };
}

/// Draws the stem plot (converts to SVG)
pub fn draw(impl: *const anyopaque, allocator: Allocator, svg: *SVG, info: FigureInfo) !void {
    const self: *const Stem = @ptrCast(@alignCast(impl));

    const y_base = info.get_base_y();
    if (self.x) |x_| {
        for(x_, self.y) |x, y| {
            if (!info.x_range.contains(x)) continue;
            if (!info.y_range.contains(y)) continue;

            const y1 = info.compute_y(y);
            const x1 = info.compute_x(x);

            try svg.addLine(
                .{ 
                    .x1 = .{ .pixel = x1 }, 
                    .y1 = .{ .pixel = y_base }, 
                    .x2 = .{ .pixel = x1 }, 
                    .y2 = . { .pixel = y1 },
                    .stroke = self.style.color,
                    .stroke_width = . { .pixel = self.style.width },
                },
            );

            try self.style.shape.write_to(allocator, svg, x1, y1, self.style.radius, self.style.color);
        }
    } else {
        for (self.y, 0..) |y, x| {
            if (!info.x_range.contains(@floatFromInt(x))) continue;
            if (!info.y_range.contains(y)) continue;

            const y1 = info.compute_y(y);
            const x1 = info.compute_x(@floatFromInt(x));

            try svg.addLine(
                .{ 
                    .x1 = .{ .pixel = x1 }, 
                    .y1 = .{ .pixel = y_base }, 
                    .x2 = .{ .pixel = x1 }, 
                    .y2 = . { .pixel = y1 },
                    .stroke = self.style.color,
                    .stroke_width = . { .pixel = self.style.width },
                },
            );

            try self.style.shape.write_to(allocator, svg, x1, y1, self.style.radius, self.style.color);
        }
    }
}

/// Convert the Stem Plot to a Plot (its interface)
pub fn interface(self: *const Stem) Plot {
    return Plot.init(
        @as(*const anyopaque, self),
        self.style.title,
        self.style.color,
        &get_x_range,
        &get_y_range,
        &draw
    );
}