const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const FigureInfo = @import("FigureInfo.zig");

const Marker = @This();

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                             Marker                                             //
////////////////////////////////////////////////////////////////////////////////////////////////////

/// A List of markers
pub const List = std.ArrayList(Marker);

/// The type of the draw function
const DrawFn = fn (*const anyopaque, allocator: Allocator, *SVG, FigureInfo) anyerror!void;

/// The implementation of the marker
impl: *const anyopaque,

/// The draw function of the marker
draw_fn: *const DrawFn,

/// Initialize a marker with the implementation and the draw function.
pub fn init(impl: *const anyopaque, draw_fn: *const DrawFn) Marker {
    return Marker{
        .impl = impl,
        .draw_fn = draw_fn,
    };
}

/// Draws the marker
pub fn draw(self: *const Marker, allocator: Allocator, svg: *SVG, info: FigureInfo) anyerror!void {
    try self.draw_fn(self.impl, allocator, svg, info);
}
