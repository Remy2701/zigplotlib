//! The Candle Stick plot

const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const RGB = @import("../svg/util/rgb.zig").RGB;
const Range = @import("../util/range.zig").Range;

const Plot = @import("Plot.zig");
const FigureInfo = @import("FigureInfo.zig");

const Step = @This();

/// A candle
pub const Candle = struct {
    open: f32,
    close: f32,
    high: f32,
    low: f32,
    color: ?RGB = null,
};

/// The style of the candle stick plot
pub const Style = struct {
    /// The title of the plot
    title: ?[]const u8 = null,
    /// The color of the bar when it increases
    inc_color: RGB = 0x00FF00,
    /// The color of the bar when it decreases
    dec_color: RGB = 0xFF0000,
    /// The width of the bars
    width: f32 = 8.0,
    /// The gap between the bars
    gap: f32 = 2.0,
    /// The thickness of the line
    line_thickness: f32 = 2.0,
};

/// The y-axis values of the candle stick plot
candles: []Candle,
/// The style of the candle stick plot
style: Style = .{},

/// Returns the range of the x values of the step plot
fn getXRange(impl: *const anyopaque) Range(f32) {
    const self: *const Step = @ptrCast(@alignCast(impl));

    return Range(f32){
        .min = 0.0,
        .max = @as(f32, @floatFromInt(self.candles.len)) * (self.style.width + self.style.gap),
    };
}

/// Returns the range of the y values of the step plot
fn getYRange(impl: *const anyopaque) Range(f32) {
    const self: *const Step = @ptrCast(@alignCast(impl));

    var min: f32 = std.math.inf(f32);
    var max: f32 = 0;
    for (self.candles) |y| {
        if (y.low < min) min = y.low;
        if (y.high > max) max = y.high;
    }

    return Range(f32){
        .min = min,
        .max = max,
    };
}

/// Draws the candle stick plot (converts to SVG)
fn draw(impl: *const anyopaque, allocator: Allocator, svg: *SVG, info: FigureInfo) !void {
    const self: *const Step = @ptrCast(@alignCast(impl));
    _ = allocator;

    const gap_x = info.computeX(self.style.gap);
    for (self.candles, 0..) |y, x| {
        const x_left = info.computeX(@as(f32, @floatFromInt(x)) * (self.style.width + self.style.gap));
        const x_right = info.computeX(@as(f32, @floatFromInt(x + 1)) * (self.style.width + self.style.gap));
        const y_open = info.computeY(y.open);
        const y_close = info.computeY(y.close);
        const y_high = info.computeY(y.high);
        const y_low = info.computeY(y.low);

        const color = y.color orelse if (y.open > y.close) self.style.dec_color else self.style.inc_color;

        try svg.addLine(.{
            .x1 = .{ .pixel = (x_left + x_right) / 2 },
            .y1 = .{ .pixel = y_high },
            .x2 = .{ .pixel = (x_left + x_right) / 2 },
            .y2 = .{ .pixel = y_low },
            .stroke = color,
            .stroke_width = .{ .pixel = self.style.line_thickness },
            .stroke_linecap = SVG.Line.LineCap.round,
        });

        try svg.addRect(.{
            .x = .{ .pixel = x_left + gap_x / 2 },
            .y = .{ .pixel = @min(y_open, y_close) },
            .width = .{ .pixel = x_right - x_left - gap_x },
            .height = .{ .pixel = @abs(y_close - y_open) },
            .fill = color,
        });
    }
}

/// Convert the Step Plot to a Plot (its interface)
pub fn interface(self: *const Step) Plot {
    return Plot.init(
        @as(*const anyopaque, self),
        self.style.title,
        self.style.inc_color,
        &getXRange,
        &getYRange,
        &draw,
    );
}
