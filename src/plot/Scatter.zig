//! The Scatter Plot

const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const RGB = @import("../svg/util/rgb.zig").RGB;
const Range = @import("../util/range.zig").Range;

const polyshape = @import("../util/polyshape.zig");

const Plot = @import("Plot.zig");
const FigureInfo = @import("FigureInfo.zig");

const Scatter = @This();

/// The style of the scatter plot
pub const Style = struct {
    /// The color of the line
    color: RGB = 0x0000FF,
    /// The width of the line
    radius: f32 = 2.0,
    /// The shape of the points
    shape: enum {
        circle,
        circle_outline,
        square,
        square_outline,
        triangle,
        triangle_outline,
        rhombus,
        rhombus_outline,
        plus,
        plus_outline,
        cross,
        cross_outline,
    } = .circle,
};

/// The x-axis value of the scatter plot
x: ?[]const f32 = null,
/// The y-axis value of the scatter plot
y: []const f32,
/// The style of the scatter plot
style: Style = .{},

/// Returns the range of the x values of the line plot
pub fn get_x_range(impl: *const anyopaque) Range(f32) {
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
pub fn get_y_range(impl: *const anyopaque) Range(f32) {
    const self: *const Scatter = @ptrCast(@alignCast(impl));
    const min_max = std.mem.minMax(f32, self.y);
    return Range(f32) {
        .min = min_max.@"0",
        .max = min_max.@"1",
    };
}

/// [Utility] Adds a point to the SVG (based on the style and the given x and y coordinates)
fn add_point(self: *const Scatter, allocator: Allocator, svg: *SVG, x: f32, y: f32) !void {
    switch (self.style.shape) {
        .circle => try svg.addCircle(.{ 
            .center_x = .{ .pixel = x }, 
            .center_y = .{ .pixel = y }, 
            .radius = .{ .pixel = self.style.radius },
            .fill = self.style.color,
        }),
        .circle_outline => try svg.addCircle(.{ 
            .center_x = .{ .pixel = x }, 
            .center_y = .{ .pixel = y }, 
            .radius = .{ .pixel = self.style.radius },
            .fill = null,
            .stroke = self.style.color,
            .stroke_width = .{ .pixel = self.style.radius / 4 }
        }),
        .square => try svg.addRect(.{
            .x = .{ .pixel = x - self.style.radius },
            .y = .{ .pixel = y - self.style.radius },
            .width = .{ .pixel = self.style.radius * 2 },
            .height = .{ .pixel = self.style.radius * 2 },
            .fill = self.style.color
        }),
        .square_outline => try svg.addRect(.{
            .x = .{ .pixel = x - self.style.radius },
            .y = .{ .pixel = y - self.style.radius },
            .width = .{ .pixel = self.style.radius * 2 },
            .height = .{ .pixel = self.style.radius * 2 },
            .fill = null,
            .stroke = self.style.color,
            .stroke_width = .{ .pixel = self.style.radius / 4 }
        }),
        .triangle => {
            const points = try polyshape.triangle(allocator, x, y, self.style.radius);
            try svg.addPolyline(.{
                .points = points,
                .fill = self.style.color,
            });
        },
        .triangle_outline => {
            const points = try polyshape.triangle(allocator, x, y, self.style.radius);
            try svg.addPolyline(.{
                .points = points,
                .stroke = self.style.color,
                .stroke_width = .{ .pixel = self.style.radius / 4 }
            });
        },
        .rhombus => {
            const points = try polyshape.rhombus(allocator, x, y, self.style.radius);
            try svg.addPolyline(.{
                .points = points,
                .fill = self.style.color,
            });
        },
        .rhombus_outline => {
            const points = try polyshape.rhombus(allocator, x, y, self.style.radius);
            try svg.addPolyline(.{
                .points = points,
                .stroke = self.style.color,
                .stroke_width = .{ .pixel = self.style.radius / 4 }
            });
        },
        .plus => {
            const points = try polyshape.plus(allocator, x, y, self.style.radius);
            
            try svg.addPolyline(.{
                .points = points,
                .fill = self.style.color,
            });
        },
        .plus_outline => {
            const points = try polyshape.plus(allocator, x, y, self.style.radius);
            
            try svg.addPolyline(.{
                .points = points,
                .stroke = self.style.color,
                .stroke_width = .{ .pixel = self.style.radius / 4 }
            });
        },
        .cross => {
            const points = try polyshape.cross(allocator, x, y, self.style.radius);

            try svg.addPolyline(.{
                .points = points,
                .fill = self.style.color,
            });
        },
        .cross_outline => {
            const points = try polyshape.cross(allocator, x, y, self.style.radius);
            
            try svg.addPolyline(.{
                .points = points,
                .stroke = self.style.color,
                .stroke_width = .{ .pixel = self.style.radius / 4 }
            });
        },
    }
}

/// Draw the scatter plot (converts to SVG).
pub fn draw(impl: *const anyopaque, allocator: Allocator, svg: *SVG, info: FigureInfo) !void {
    const self: *const Scatter = @ptrCast(@alignCast(impl));

    if (self.x) |x_| {
        for(x_, self.y) |x, y| {
            

            const x1 = info.compute_x(x);
            const y1 = info.compute_y(y);
            
            try self.add_point(allocator, svg, x1, y1);
        }
    } else {
        for (self.y, 0..) |y, x| {
            const x1 = info.compute_x(@floatFromInt(x));
            const y1 = info.compute_y(y);

            try self.add_point(allocator, svg, x1, y1);
        }
    }
}

/// Converts the Scatter Plot to a Plot (its interface)
pub fn interface(self: *const Scatter) Plot {
    return Plot.init(
        @as(*const anyopaque, self),
        &get_x_range,
        &get_y_range,
        &draw
    );
}