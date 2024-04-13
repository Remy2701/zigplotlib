const std = @import("std");

const zigplotlib = @import("zigplotlib");
const SVG = zigplotlib.SVG;

const rgb = zigplotlib.rgb;
const Range = zigplotlib.Range;

const Figure = zigplotlib.Figure;
const Line = zigplotlib.Line;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var x: [221]f32 = undefined;
    var y: [221]f32 = undefined;
    var y2: [221]f32 = undefined;
    var y3: [221]f32 = undefined;
    for (0..221) |i| {
        x[i] = 0.05 * @as(f32, @floatFromInt(@as(i32, @intCast(i)) - 20));
        y[i] = std.math.pow(f32, 10, x[i]);
        y2[i] = x[i];
        y3[i] = std.math.log10(x[i]);
    }

    // Used to snap to the grid (will be fixed in later updates).
    y3[44] = 0.10;

    var figure = Figure.init(allocator, .{
        .axis = .{
            .y_scale = .log,
            .x_range = Range(f32){ .min = -1.0, .max = 10.0 },
            .tick_count_y = .{ .count = 4 },
            .y_range = Range(f32){ .min = 0.1, .max = 1000.0 },
        },
    });

    defer figure.deinit();
    try figure.addPlot(Line{
        .x = &x,
        .y = &y,
        .style = .{
            .color = rgb.RED,
            .width = 2.0,
            .smooth = 0.2,
        },
    });

    try figure.addPlot(Line{
        .x = &x,
        .y = &y2,
        .style = .{
            .color = rgb.GREEN,
            .width = 2.0,
            .smooth = 0.2,
        },
    });

    try figure.addPlot(Line{
        .x = &x,
        .y = &y3,
        .style = .{ .color = rgb.BLUE, .width = 2.0, .smooth = 0.2 },
    });

    var svg = try figure.show();
    defer svg.deinit();

    // Write to an output file (out.svg)
    var file = try std.fs.cwd().createFile("example/out/logarithmic.svg", .{});
    defer file.close();

    try svg.writeTo(file.writer());
}
