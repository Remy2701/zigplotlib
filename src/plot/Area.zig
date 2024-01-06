//! The Area plot

const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const RGB = @import("../svg/util/rgb.zig").RGB;
const Range = @import("../util/range.zig").Range;

const Plot = @import("Plot.zig");
const FigureInfo = @import("FigureInfo.zig");

const Area = @This();

/// The Style of the Area plot
pub const Style = struct {
    /// The title of the plot
    title: ?[]const u8 = null,
    /// The color of the area
    color: RGB = 0x0000FF,
    /// The opacity of the area
    opacity: f32 = 0.5,
    /// The width of the line
    width: f32 = 2.0,
};

/// The x-axis values of the area plot
x: ?[]const f32 = null,
/// The y-axis values of the area plot
y: []const f32,
/// The style of the area plot
style: Style = .{},

/// Returns the range of the x values of the line plot
fn getXRange(impl: *const anyopaque) Range(f32) {
    const self: *const Area = @ptrCast(@alignCast(impl));
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
    const self: *const Area = @ptrCast(@alignCast(impl));
    const min_max = std.mem.minMax(f32, self.y);
    return Range(f32) {
        .min = min_max.@"0",
        .max = min_max.@"1",
    };
}

/// The draw function for the area plot (converts the plot to SVG)
fn draw(impl: *const anyopaque, allocator: Allocator, svg: *SVG, info: FigureInfo) !void {
    const self: *const Area = @ptrCast(@alignCast(impl));

    if (self.x) |x_| {
        var points = std.ArrayList(f32).init(allocator);
        try points.appendSlice(&[_]f32 {info.computeX(x_[0]), info.getBaseY()});
        var last_x: ?f32 = null;
        for (x_, self.y) |x, y| {
            if (!info.x_range.contains(x)) continue;
            if (!info.y_range.contains(y)) continue;

            if (last_x) |last_x_| {
                if (x > last_x_) last_x = x;
            } else last_x = x;

            const x2 = info.computeX(x);
            const y2 = info.computeY(y);

            try points.append(x2);
            try points.append(y2);
        }

        if (last_x) |last_x_| try points.appendSlice(&[_]f32 {info.computeX(last_x_), info.getBaseY()});
        try svg.addPolyline(.{
            .points = try points.toOwnedSlice(),
            .fill = self.style.color,
            .fill_opacity = self.style.opacity,
            .stroke = self.style.color,
            .stroke_width = .{ .pixel = self.style.width },
        });
    } else {
        var points = std.ArrayList(f32).init(allocator);
        try points.appendSlice(&[_]f32 {info.computeX(0.0), info.getBaseY()});
        var last_x: ?f32 = null;
        for (self.y, 0..) |y, x| {
            if (!info.x_range.contains(@floatFromInt(x))) continue;
            if (!info.y_range.contains(y)) continue;

            if (last_x) |last_x_| {
                if (@as(f32, @floatFromInt(x)) > last_x_) last_x = @floatFromInt(x);
            } else last_x = @floatFromInt(x);

            const x2 = info.computeX(@floatFromInt(x));
            const y2 = info.computeY(y);

            try points.append(x2);
            try points.append(y2);
        }

        if (last_x) |last_x_| try points.appendSlice(&[_]f32 {info.computeX(last_x_), info.getBaseY()});
        try svg.addPolyline(.{
            .points = try points.toOwnedSlice(),
            .fill = self.style.color,
            .fill_opacity = self.style.opacity,
            .stroke = self.style.color,
            .stroke_width = .{ .pixel = self.style.width },
        });
    }
}

/// Converts the area plot to a plot (its interface)
pub fn interface(self: *const Area) Plot {
    return Plot.init(
        @as(*const anyopaque, self),
        self.style.title,
        self.style.color,
        &getXRange,
        &getYRange,
        &draw
    );
}