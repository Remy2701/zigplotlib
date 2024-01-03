const std = @import("std");

const SVG = @import("SVG.zig");

/// The different kind of SVG Components
pub const Kind = union(enum) {
    /// A List of Kind
    pub const List = std.ArrayList(Kind);

    /// The Line SVG Component
    line: SVG.Line,
    /// The Rect SVG Component
    rect: SVG.Rect,
    /// The Circle SVG Component
    circle: SVG.Circle,
    /// The Polyline SVG Component
    polyline: SVG.Polyline,
    /// The Text SVG Component
    text: SVG.Text,

    /// Write the Kind to the given writer
    pub fn write_to(self: *const Kind, writer: anytype) anyerror!void {
        try switch (self.*) {
            .line => |line| line.write_to(writer),
            .rect => |rect| rect.write_to(writer),
            .circle => |circle| circle.write_to(writer),
            .polyline => |polyline| polyline.write_to(writer),
            .text => |text| text.write_to(writer),            
        };
    }

    /// Deinitialize the Kind
    pub fn deinit(self: *const Kind) void {
        switch(self.*) {
            .polyline => |polyline| polyline.deinit(),
            .text => |text| text.deinit(),
            else => {},
        }
    }
};