const std = @import("std");

const zigplotlib = @import("zigplotlib");
const SVG = zigplotlib.SVG;

const rgb = zigplotlib.rgb;
const Range = zigplotlib.Range;

const Figure = zigplotlib.Figure;
const Scatter = zigplotlib.Scatter;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    var xoshiro = std.rand.Xoshiro256.init(100);
    var rand = xoshiro.random();

    var x: [28]f32 = undefined;
    var y1: [28]f32 = undefined;
    var y2: [28]f32 = undefined;
    for (0..28) |i| {
        x[i] = @floatFromInt(i);
        const r = rand.float(f32);
        y1[i] = x[i] + r * 10.0 - 5.0;
        y2[i] = x[i] + r * 2.0 - 1.0;
    }

    var figure = Figure.init(allocator, .{
        .value_padding = .{
            .x_min = .{ .value = 1.0 },
            .x_max = .{ .value = 1.0 },
        },
        .axis = .{
            .show_y_axis = false,
        }
    });
    defer figure.deinit();

    try figure.addPlot(Scatter {
        .x = &x,
        .y = &y1,
        .style = .{
            .color = rgb.BLUE,
            .radius = 4.0,
            .shape = .circle
        }
    });
    try figure.addPlot(Scatter {
        .x = &x,
        .y = &y2,
        .style = .{
            .color = rgb.RED,
            .radius = 4.0,
            .shape = .rhombus
        }
    });

    var svg = try figure.show();
    defer svg.deinit();

    // Write to an output file (out.svg)
    var file = try std.fs.cwd().createFile("example/out/scatter.svg", .{});
    defer file.close();

    try svg.write_to(file.writer());
}