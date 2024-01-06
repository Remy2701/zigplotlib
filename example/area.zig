const std = @import("std");

const zigplotlib = @import("zigplotlib");
const SVG = zigplotlib.SVG;

const rgb = zigplotlib.rgb;
const Range = zigplotlib.Range;

const Figure = zigplotlib.Figure;
const Area = zigplotlib.Area;

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
        .axis = .{
            .show_y_axis = false,
        }
    });
    defer figure.deinit();
    try figure.addPlot(Area {
        .x = &x,
        .y = &y2,
        .style = .{
            .color = rgb.GRAY,
            .width = 2.0,
        }
    });
    try figure.addPlot(Area {
        .x = &x,
        .y = &y,
        .style = .{
            .color = rgb.BLUE,
            .width = 2.0,
        }
    });
    var svg = try figure.show();
    defer svg.deinit();

    // Write to an output file (out.svg)
    var file = try std.fs.cwd().createFile("example/out/area.svg", .{});
    defer file.close();

    try svg.writeTo(file.writer());
}