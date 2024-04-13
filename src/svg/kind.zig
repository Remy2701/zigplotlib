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
    /// The Path SVG Component
    path: SVG.Path,

    /// Write the Kind to the given writer
    pub fn writeTo(self: *const Kind, writer: anytype) anyerror!void {
        try switch (self.*) {
            .line => |line| line.writeTo(writer),
            .rect => |rect| rect.writeTo(writer),
            .circle => |circle| circle.writeTo(writer),
            .polyline => |polyline| polyline.writeTo(writer),
            .text => |text| text.writeTo(writer),
            .path => |path| path.writeTo(writer),
        };
    }

    /// Deinitialize the Kind
    pub fn deinit(self: *const Kind) void {
        switch (self.*) {
            .polyline => |polyline| polyline.deinit(),
            .text => |text| text.deinit(),
            .path => |path| path.deinit(),
            else => {},
        }
    }
};
