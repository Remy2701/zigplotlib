const std = @import("std");

const zigplotlib = @import("zigplotlib");
const SVG = zigplotlib.SVG;

const rgb = zigplotlib.rgb;
const Range = zigplotlib.Range;

const Figure = zigplotlib.Figure;
const Stem = zigplotlib.Stem;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    var x: [14]f32 = undefined;
    var y: [14]f32 = undefined;
    for (0..14) |i| {
        x[i] = @floatFromInt(i);
        y[i] = std.math.sin(x[i] / 2.0);
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

    try figure.addPlot(Stem {
        .x = &x,
        .y = &y,
        .style = .{
            .color = rgb.BLUE,
            .width = 4.0,
        }
    });
    var svg = try figure.show();
    defer svg.deinit();

    // Write to an output file (out.svg)
    var file = try std.fs.cwd().createFile("example/out/stem.svg", .{});
    defer file.close();

    try svg.writeTo(file.writer());
}