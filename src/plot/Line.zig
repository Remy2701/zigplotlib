//! The Line plot

const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const RGB = @import("../svg/util/rgb.zig").RGB;
const Range = @import("../util/range.zig").Range;

const Plot = @import("Plot.zig");
const FigureInfo = @import("FigureInfo.zig");

const Line = @This();

/// The style of the line plot
pub const Style = struct {
    /// The title of the plot
    title: ?[]const u8 = null,
    /// The color of the line
    color: RGB = 0x0000FF,
    /// The width of the line
    width: f32 = 2.0,
    /// The size of the dashes of the line (null = no dashes)
    dash: ?f32 = null,
    /// The smoothing factor [0; 1] (0 = no smoothing)
    smooth: f32 = 0.0,
};

/// The x-axis values of the line plot
x: ?[]const f32 = null,
/// The y-axis values of the line plot
y: []const f32,
/// The style of the line plot
style: Style = .{},

/// Returns the range of the x values of the line plot
fn getXRange(impl: *const anyopaque) Range(f32) {
    const self: *const Line = @ptrCast(@alignCast(impl));
    if (self.x) |x| {
        const min_max = std.mem.minMax(f32, x);
        return Range(f32){
            .min = min_max.@"0",
            .max = min_max.@"1",
        };
    } else {
        return Range(f32){
            .min = 0.0,
            .max = if (self.y.len == 0) 0 else @floatFromInt(self.y.len - 1),
        };
    }
}

/// Returns the range of the y values of the line plot
fn getYRange(impl: *const anyopaque) Range(f32) {
    const self: *const Line = @ptrCast(@alignCast(impl));
    const min_max = std.mem.minMax(f32, self.y);
    return Range(f32){
        .min = min_max.@"0",
        .max = min_max.@"1",
    };
}

/// Draws the line plot (converts to SVG)
fn draw(impl: *const anyopaque, allocator: Allocator, svg: *SVG, info: FigureInfo) !void {
    const self: *const Line = @ptrCast(@alignCast(impl));

    const stroke_dash_array: ?[]const f32 = if (self.style.dash) |dash| try allocator.dupe(f32, &[_]f32{dash}) else null;

    var commands = std.ArrayList(SVG.Path.Command).init(allocator);
    var started = false;
    if (self.x) |x_| {
        for (x_, self.y, 0..) |x, y, i| {
            if (!info.x_range.contains(x) or !info.y_range.contains(y)) {
                continue;
            }

            const x1 = info.computeX(x);
            const y1 = info.computeY(y);

            if (!started) {
                try commands.append(.{
                    .MoveTo = .{
                        .x = x1,
                        .y = y1,
                    },
                });
                started = true;
                continue;
            }

            const p_start_x = info.computeX(x_[i - 1]);
            const p_start_y = info.computeY(self.y[i - 1]);
            const p_end_x = info.computeX(x);
            const p_end_y = info.computeY(y);

            const p_prev_x = if (i >= 2) info.computeX(x_[i - 2]) else p_start_x;
            const p_prev_y = if (i >= 2) info.computeY(self.y[i - 2]) else p_start_y;
            const p_next_x = if (i + 1 < x_.len) info.computeX(x_[i + 1]) else p_end_x;
            const p_next_y = if (i + 1 < self.y.len) info.computeY(self.y[i + 1]) else p_end_y;

            const cps_x = p_start_x + self.style.smooth * (p_end_x - p_prev_x);
            const cps_y = p_start_y + self.style.smooth * (p_end_y - p_prev_y);

            const cpe_x = p_end_x + self.style.smooth * (p_start_x - p_next_x);
            const cpe_y = p_end_y + self.style.smooth * (p_start_y - p_next_y);

            try commands.append(.{
                .CubicBezierCurveTo = .{
                    .x1 = cps_x,
                    .y1 = cps_y,
                    .x2 = cpe_x,
                    .y2 = cpe_y,
                    .x = x1,
                    .y = y1,
                },
            });
        }
    } else {
        for (self.y, 0..) |y, x| {
            if (!info.x_range.contains(@floatFromInt(x)) or !info.y_range.contains(y)) {
                continue;
            }

            const x1 = info.computeX(@floatFromInt(x));
            const y1 = info.computeY(y);

            if (!started) {
                try commands.append(.{
                    .MoveTo = .{
                        .x = x1,
                        .y = y1,
                    },
                });
                started = true;
                continue;
            }

            const p_start_x: f32 = info.computeX(@floatFromInt(x - 1));
            const p_start_y = info.computeY(self.y[x - 1]);
            const p_end_x: f32 = info.computeX(@floatFromInt(x));
            const p_end_y = info.computeY(y);

            const p_prev_x: f32 = if (x >= 2) info.computeX(@floatFromInt(x - 1)) else p_start_x;
            const p_prev_y = if (x >= 2) info.computeY(self.y[x - 2]) else p_start_y;
            const p_next_x: f32 = if (x + 1 < self.y.len) info.computeX(@floatFromInt(x + 1)) else p_end_x;
            const p_next_y = if (x + 1 < self.y.len) info.computeY(self.y[x + 1]) else p_end_y;

            const cps_x = p_start_x + self.style.smooth * (p_end_x - p_prev_x);
            const cps_y = p_start_y + self.style.smooth * (p_end_y - p_prev_y);

            const cpe_x = p_end_x + self.style.smooth * (p_start_x - p_next_x);
            const cpe_y = p_end_y + self.style.smooth * (p_start_y - p_next_y);

            try commands.append(.{
                .CubicBezierCurveTo = .{
                    .x1 = cps_x,
                    .y1 = cps_y,
                    .x2 = cpe_x,
                    .y2 = cpe_y,
                    .x = x1,
                    .y = y1,
                },
            });
        }
    }

    try svg.addPath(.{
        .commands = commands.items,
        .allocator = allocator,
        .stroke = self.style.color,
        .stroke_width = .{ .pixel = self.style.width },
        .stroke_dasharray = stroke_dash_array,
    });
}

/// Convert the Line Plot to a Plot (its interface)
pub fn interface(self: *const Line) Plot {
    return Plot.init(
        @as(*const anyopaque, self),
        self.style.title,
        self.style.color,
        &getXRange,
        &getYRange,
        &draw,
    );
}
