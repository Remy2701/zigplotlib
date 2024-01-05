const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const Range = @import("../util/range.zig").Range;
const RGB = @import("../svg/util/rgb.zig").RGB;

const FigureInfo = @import("FigureInfo.zig");

const Plot = @This();

/// A List of Plot
pub const List = std.ArrayList(Plot);

impl: *const anyopaque,
title: ?[]const u8,
color: RGB,
get_range_x_fn: *const fn(*const anyopaque) Range(f32),
get_range_y_fn: *const fn(*const anyopaque) Range(f32),
draw_fn: *const fn(*const anyopaque, allocator: Allocator, *SVG, FigureInfo) anyerror!void,

pub fn init(
    impl: *const anyopaque,
    title: ?[]const u8,
    color: RGB,
    get_range_x_fn: *const fn(*const anyopaque) Range(f32),
    get_range_y_fn: *const fn(*const anyopaque) Range(f32),
    draw_fn: *const fn(*const anyopaque, Allocator, *SVG, FigureInfo) anyerror!void,
) Plot {
    return Plot {
        .impl = impl,
        .title = title,
        .color = color,
        .get_range_x_fn = get_range_x_fn,
        .get_range_y_fn = get_range_y_fn,
        .draw_fn = draw_fn,
    };
}

pub fn getRangeX(self: *const Plot) Range(f32) {
    return self.get_range_x_fn(self.impl);
}

pub fn getRangeY(self: *const Plot) Range(f32) {
    return self.get_range_y_fn(self.impl);
}

pub fn draw(self: *const Plot, allocator: Allocator, svg: *SVG, info: FigureInfo) anyerror!void {
    try self.draw_fn(self.impl, allocator, svg, info);
}