//! A SVG Line component

const std = @import("std");

const Kind = @import("kind.zig").Kind;

const length = @import("util/length.zig");
const LengthPercent = length.LengthPercent;

const rgb = @import("util/rgb.zig");
const RGB = rgb.RGB;

const Line = @This();

/// The line cap options
pub const LineCap = enum {
    butt,
    round,
    square,

    pub fn format(self: LineCap, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .butt => try writer.writeAll("butt"),
            .round => try writer.writeAll("round"),
            .square => try writer.writeAll("square"),
        }
    }
};

/// The options of the Line
pub const Options = struct {
    /// The starting x-coordinate of the line
    x1: LengthPercent = .{ .pixel = 0.0 },
    /// The starting y-coordinate of the line
    y1: LengthPercent = .{ .pixel = 0.0 },
    /// The ending x-coordinate of the line
    x2: LengthPercent = .{ .pixel = 1.0 },
    /// The ending y-coordinate of the line
    y2: LengthPercent = .{ .pixel = 1.0 },
    /// The color of the stroke of the line
    stroke: ?RGB = null,
    /// opacity of the stroke
    stroke_opacity: f32 = 1.0,
    /// The width of the stroke
    stroke_width: LengthPercent = .{ .pixel = 1.0 },
    /// The line cap of the stroke
    stroke_linecap: LineCap = .butt,
    /// The dash array of the stroke
    stroke_dasharray: ?[]const f32 = null,
    /// The opacity of the line
    opacity: f32 = 1.0,
};

/// The options of the Line
options: Options,

/// Initialize the Line with the given options
pub fn init(options: Options) Line {
    return Line {
        .options = options,
    };
}

/// Write the line to the given writer
pub fn writeTo(self: *const Line, writer: anytype) anyerror!void {
    try writer.writeAll("<line ");
    try writer.print("x1=\"{}\" ", .{self.options.x1});
    try writer.print("y1=\"{}\" ", .{self.options.y1});
    try writer.print("x2=\"{}\" ", .{self.options.x2});
    try writer.print("y2=\"{}\" ", .{self.options.y2});
    if (self.options.stroke) |stroke| try writer.print("stroke=\"#{X:0>6}\" ", .{stroke})
    else try writer.writeAll("stroke=\"none\" ");
    try writer.print("stroke-opacity=\"{d}\" ", .{self.options.stroke_opacity});
    try writer.print("stroke-width=\"{}\" ", .{self.options.stroke_width});
    try writer.print("stroke-linecap=\"{}\" ", .{self.options.stroke_linecap});
    if (self.options.stroke_dasharray) |stroke_dash_array| {
        try writer.writeAll("stroke-dasharray=\" ");
        for (stroke_dash_array) |dash| {
            try writer.print("{} ", .{dash});
        }
        try writer.writeAll("\" ");
    }
    try writer.print("opacity=\"{d}\" ", .{self.options.opacity});
    try writer.writeAll("/>");
}

/// Wrap the line into a kind
pub fn wrap(self: *const Line) Kind {
    return Kind {
        .line = self.*
    };
}