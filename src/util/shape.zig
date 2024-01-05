const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const RGB = @import("../svg/util/rgb.zig").RGB;

const polyshape = @import("polyshape.zig");

/// The enumeration of shape
pub const Shape = enum {
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

    /// Write the shape to the given SVG
    pub fn writeTo(self: Shape, allocator: Allocator, svg: *SVG, x: f32, y: f32, radius: f32, color: RGB) !void {
        switch (self) {
            .circle => try svg.addCircle(.{ 
                .center_x = .{ .pixel = x }, 
                .center_y = .{ .pixel = y }, 
                .radius = .{ .pixel = radius },
                .fill = color,
            }),
            .circle_outline => try svg.addCircle(.{ 
                .center_x = .{ .pixel = x }, 
                .center_y = .{ .pixel = y }, 
                .radius = .{ .pixel = radius },
                .fill = null,
                .stroke = color,
                .stroke_width = .{ .pixel = radius / 4 }
            }),
            .square => try svg.addRect(.{
                .x = .{ .pixel = x - radius },
                .y = .{ .pixel = y - radius },
                .width = .{ .pixel = radius * 2 },
                .height = .{ .pixel = radius * 2 },
                .fill = color
            }),
            .square_outline => try svg.addRect(.{
                .x = .{ .pixel = x - radius },
                .y = .{ .pixel = y - radius },
                .width = .{ .pixel = radius * 2 },
                .height = .{ .pixel = radius * 2 },
                .fill = null,
                .stroke = color,
                .stroke_width = .{ .pixel = radius / 4 }
            }),
            .triangle => {
                const points = try polyshape.triangle(allocator, x, y, radius);
                try svg.addPolyline(.{
                    .points = points,
                    .fill = color,
                });
            },
            .triangle_outline => {
                const points = try polyshape.triangle(allocator, x, y, radius);
                try svg.addPolyline(.{
                    .points = points,
                    .stroke = color,
                    .stroke_width = .{ .pixel = radius / 4 }
                });
            },
            .rhombus => {
                const points = try polyshape.rhombus(allocator, x, y, radius);
                try svg.addPolyline(.{
                    .points = points,
                    .fill = color,
                });
            },
            .rhombus_outline => {
                const points = try polyshape.rhombus(allocator, x, y, radius);
                try svg.addPolyline(.{
                    .points = points,
                    .stroke = color,
                    .stroke_width = .{ .pixel = radius / 4 }
                });
            },
            .plus => {
                const points = try polyshape.plus(allocator, x, y, radius);
                
                try svg.addPolyline(.{
                    .points = points,
                    .fill = color,
                });
            },
            .plus_outline => {
                const points = try polyshape.plus(allocator, x, y, radius);
                
                try svg.addPolyline(.{
                    .points = points,
                    .stroke = color,
                    .stroke_width = .{ .pixel = radius / 4 }
                });
            },
            .cross => {
                const points = try polyshape.cross(allocator, x, y, radius);

                try svg.addPolyline(.{
                    .points = points,
                    .fill = color,
                });
            },
            .cross_outline => {
                const points = try polyshape.cross(allocator, x, y, radius);
                
                try svg.addPolyline(.{
                    .points = points,
                    .stroke = color,
                    .stroke_width = .{ .pixel = radius / 4 }
                });
            },
        }
    }
};