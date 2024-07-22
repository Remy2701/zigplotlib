const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const RGB = @import("../svg/util/rgb.zig").RGB;
const FigureInfo = @import("FigureInfo.zig");
const Marker = @import("Marker.zig");

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          Text Marker                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////

const TextMarker = @This();

/// The x-axis value of the marker
x: f32,

/// The y-axis value of the marker
y: f32,

/// The color of the marker
color: RGB = 0x000000,

/// The text of the marker
text: []const u8,

/// The size of the text
size: f32 = 12.0,

/// The weight of the text
weight: SVG.Text.FontWeight = .normal,

/// Draws the marker
pub fn draw(impl: *const anyopaque, allocator: Allocator, svg: *SVG, info: FigureInfo) anyerror!void {
    _ = allocator;
    const self: *const TextMarker = @ptrCast(@alignCast(impl));

    const x = info.computeX(self.x);
    const y = info.computeY(self.y);

    try svg.addText(.{
        .text = self.text,
        .x = .{ .pixel = x },
        .y = .{ .pixel = y },
        .font_size = .{ .pixel = self.size },
        .fill = self.color,
        .font_weight = self.weight,
    });
}

/// Convert the ShapeMarker to a Marker
pub fn interface(self: *const TextMarker) Marker {
    return Marker.init(
        @as(*const anyopaque, self),
        &TextMarker.draw,
    );
}
