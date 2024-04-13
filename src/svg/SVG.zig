const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Line = @import("Line.zig");
pub const Rect = @import("Rect.zig");
pub const Circle = @import("Circle.zig");
pub const Polyline = @import("Polyline.zig");
pub const Text = @import("Text.zig");
pub const Path = @import("Path.zig");

pub usingnamespace @import("kind.zig");

const SVG = @This();

/// The repsentation of the viewbox of the SVG
pub const ViewBox = struct { x: f32, y: f32, width: f32, height: f32 };

/// The allocator used for the SVG
allocator: Allocator,
// The data inside the SVG (List of Kind)
data: SVG.Kind.List,

/// The width of the SVG
width: f32,
/// The height of the SVG
height: f32,
/// The viewbox of the SVG
viewbox: ViewBox,

/// Initialize the SVG with the given allocator, width and height
pub fn init(allocator: Allocator, width: f32, height: f32) SVG {
    return SVG{ .allocator = allocator, .data = SVG.Kind.List.init(allocator), .width = width, .height = height, .viewbox = ViewBox{
        .x = 0,
        .y = 0,
        .width = width,
        .height = height,
    } };
}

/// Deintiialize the SVG
pub fn deinit(self: *const SVG) void {
    for (self.data.items) |kind| {
        kind.deinit();
    }
    self.data.deinit();
}

/// Add a Kind to the SVG
pub fn add(self: *SVG, kind: SVG.Kind) !void {
    try self.data.append(kind);
}

/// Add a Line to the SVG
pub fn addLine(self: *SVG, options: Line.Options) !void {
    try self.add(Line.init(options).wrap());
}

/// Add a Rect to the SVG
pub fn addRect(self: *SVG, options: Rect.Options) !void {
    try self.add(Rect.init(options).wrap());
}

/// Add a Circle to the SVG
pub fn addCircle(self: *SVG, options: Circle.Options) !void {
    try self.add(Circle.init(options).wrap());
}

/// Add a Polyline to the SVG
pub fn addPolyline(self: *SVG, options: Polyline.Options) !void {
    try self.add(Polyline.init(options).wrap());
}

/// Add a Text to the SVG
pub fn addText(self: *SVG, options: Text.Options) !void {
    try self.add(Text.init(options).wrap());
}

/// Add a Path to the SVG
pub fn addPath(self: *SVG, options: Path.Options) !void {
    try self.add(Path.init(options).wrap());
}

/// The header of the SVG
const SVG_HEADER =
    \\<?xml version="1.0" encoding="UTF-8" standalone="no"?>
    \\<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    \\<svg width="{d}" height="{d}" viewBox="{d} {d} {d} {d}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    \\
;

/// Write the SVG to the given writer
pub fn writeTo(self: *const SVG, writer: anytype) anyerror!void {
    // Write the header
    try writer.print(SVG_HEADER, .{
        self.width,
        self.height,
        self.viewbox.x,
        self.viewbox.y,
        self.viewbox.width,
        self.viewbox.height,
    });
    // Write the data
    for (self.data.items) |kind| {
        try kind.writeTo(writer);
        try writer.writeByte('\n');
    }
    // End of the SVG
    try writer.writeAll("</svg>");
}
