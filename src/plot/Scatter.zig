//! The Scatter Plot

const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const RGB = @import("../svg/util/rgb.zig").RGB;
const Range = @import("../util/range.zig").Range;

const Shape = @import("../util/shape.zig").Shape;

const Plot = @import("Plot.zig");
const FigureInfo = @import("FigureInfo.zig");

const Scatter = @This();

/// The style of the scatter plot
pub const Style = struct {
    /// The title of the plot
    title: ?[]const u8 = null,
    /// The color of the line
    color: RGB = 0x0000FF,
    /// The width of the line
    radius: f32 = 2.0,
    /// The shape of the points
    shape: Shape = .circle,
};

/// The x-axis value of the scatter plot
x: ?[]const f32 = null,
/// The y-axis value of the scatter plot
y: []const f32,
/// The style of the scatter plot
style: Style = .{},

/// Returns the range of the x values of the line plot
fn getXRange(impl: *const anyopaque) Range(f32) {
    const self: *const Scatter = @ptrCast(@alignCast(impl));
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
fn getYRange(impl: *const anyopaque) Range(f32) {
    const self: *const Scatter = @ptrCast(@alignCast(impl));
    const min_max = std.mem.minMax(f32, self.y);
    return Range(f32) {
        .min = min_max.@"0",
        .max = min_max.@"1",
    };
}

/// Draw the scatter plot (converts to SVG).
fn draw(impl: *const anyopaque, allocator: Allocator, svg: *SVG, info: FigureInfo) !void {
    const self: *const Scatter = @ptrCast(@alignCast(impl));

    if (self.x) |x_| {
        for(x_, self.y) |x, y| {
            if (!info.x_range.contains(x)) continue;
            if (!info.y_range.contains(y)) continue;

            const x1 = info.computeX(x);
            const y1 = info.computeY(y);
            
            try self.style.shape.writeTo(allocator, svg, x1, y1, self.style.radius, self.style.color);
        }
    } else {
        for (self.y, 0..) |y, x| {
            if (!info.x_range.contains(@floatFromInt(x))) continue;
            if (!info.y_range.contains(y)) continue;

            const x1 = info.computeX(@floatFromInt(x));
            const y1 = info.computeY(y);

            try self.style.shape.writeTo(allocator, svg, x1, y1, self.style.radius, self.style.color);
        }
    }
}

/// Converts the Scatter Plot to a Plot (its interface)
pub fn interface(self: *const Scatter) Plot {
    return Plot.init(
        @as(*const anyopaque, self),
        self.style.title,
        self.style.color,
        &getXRange,
        &getYRange,
        &draw
    );
}