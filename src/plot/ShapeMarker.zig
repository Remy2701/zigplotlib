const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const RGB = @import("../svg/util/rgb.zig").RGB;
const FigureInfo = @import("FigureInfo.zig");
const Shape = @import("../util/shape.zig").Shape;
const Marker = @import("Marker.zig");

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          Shape Marker                                          //
////////////////////////////////////////////////////////////////////////////////////////////////////

const ShapeMarker = @This();

/// The x-axis value of the marker
x: f32,

/// The y-axis value of the marker
y: f32,

/// The shape of the marker
shape: Shape = Shape.cross,

/// The size of the marker
size: f32 = 8.0,

/// The color of the marker
color: RGB = 0x000000,

/// The label of the marker (null = no label)
label: ?[]const u8 = null,

/// The color of the label (null = same as the marker)
label_color: ?RGB = null,

/// The size of the label
label_size: f32 = 12.0,

/// The weight of the label
label_weight: SVG.Text.FontWeight = .normal,

/// Draws the marker
pub fn draw(impl: *const anyopaque, allocator: Allocator, svg: *SVG, info: FigureInfo) anyerror!void {
    const self: *const ShapeMarker = @ptrCast(@alignCast(impl));

    const x = info.computeX(self.x);
    const y = info.computeY(self.y);

    try self.shape.writeTo(allocator, svg, x, y, self.size, self.color);

    if (self.label) |label| {
        const label_x = x + self.size + 8.0;
        const label_y = y + self.size / 2.0;
        try svg.addText(.{
            .text = label,
            .x = .{ .pixel = label_x },
            .y = .{ .pixel = label_y },
            .font_size = .{ .pixel = self.label_size },
            .fill = self.label_color orelse self.color,
            .font_weight = self.label_weight,
        });
    }
}

/// Convert the ShapeMarker to a Marker
pub fn interface(self: *const ShapeMarker) Marker {
    return Marker.init(
        @as(*const anyopaque, self),
        &ShapeMarker.draw,
    );
}
