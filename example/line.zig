const std = @import("std");

const zigplotlib = @import("zigplotlib");
const SVG = zigplotlib.SVG;

const rgb = zigplotlib.rgb;
const Range = zigplotlib.Range;

const Figure = zigplotlib.Figure;
const Line = zigplotlib.Line;
const ShapeMarker = zigplotlib.ShapeMarker;

const SMOOTHING = 0.2;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var x: [28]f32 = undefined;
    var y: [28]f32 = undefined;
    var y2: [28]f32 = undefined;
    for (0..28) |i| {
        x[i] = @floatFromInt(i);
        y[i] = std.math.sin(x[i] / 4.0);
        y2[i] = std.math.sin(x[i] / 4.0) + 1;
    }

    var figure = Figure.init(allocator, .{
        .value_padding = .{
            .x_min = .{ .value = 1.0 },
            .x_max = .{ .value = 1.0 },
        },
        .axis = .{
            .show_y_axis = false,
        },
    });
    defer figure.deinit();
    try figure.addPlot(Line{ .x = &x, .y = &y, .style = .{
        .color = rgb.BLUE,
        .width = 2.0,
        .smooth = SMOOTHING,
    } });
    try figure.addPlot(Line{ .x = &x, .y = &y2, .style = .{
        .color = rgb.GRAY,
        .width = 2.0,
        .dash = 4.0,
        .smooth = SMOOTHING,
    } });

    try figure.addMarker(ShapeMarker{
        .x = 9.33,
        .y = 0.73,
        .shape = .cross,
        .color = 0xFF0000,
        .size = 6.0,
    });
    try figure.addMarker(ShapeMarker{
        .x = 18.67,
        .y = 0,
        .shape = .circle_outline,
        .color = 0x00FF00,
        .size = 8.0,
        .label = "Bottom",
        .label_weight = .w600,
    });

    var svg = try figure.show();
    defer svg.deinit();

    // Write to an output file (out.svg)
    var file = try std.fs.cwd().createFile("example/out/line.svg", .{});
    defer file.close();

    try svg.writeTo(file.writer());
}
