const std = @import("std");

const zigplotlib = @import("zigplotlib");
const SVG = zigplotlib.SVG;

const Figure = zigplotlib.Figure;
const CandleStick = zigplotlib.CandleStick;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var candles: [10]CandleStick.Candle = .{
        CandleStick.Candle{
            .open = 1.0,
            .close = 1.2,
            .low = 0.9,
            .high = 1.5,
        },
        CandleStick.Candle{
            .open = 1.2,
            .close = 1.3,
            .low = 1.1,
            .high = 1.4,
        },
        CandleStick.Candle{
            .open = 1.3,
            .close = 1.1,
            .low = 1.0,
            .high = 1.4,
        },
        CandleStick.Candle{
            .open = 1.1,
            .close = 1.4,
            .low = 1.0,
            .high = 1.5,
        },
        CandleStick.Candle{
            .open = 1.4,
            .close = 2.4,
            .low = 1.3,
            .high = 3.1,
        },
        CandleStick.Candle{
            .open = 2.4,
            .close = 2.6,
            .low = 2.3,
            .high = 2.7,
        },
        CandleStick.Candle{
            .open = 2.6,
            .close = 2.2,
            .low = 1.8,
            .high = 2.7,
        },
        CandleStick.Candle{
            .open = 2.2,
            .close = 1.6,
            .low = 1.5,
            .high = 2.3,
            .color = 0x6688FF,
        },
        CandleStick.Candle{
            .open = 1.6,
            .close = 1.8,
            .low = 1.5,
            .high = 1.9,
        },
        CandleStick.Candle{
            .open = 1.8,
            .close = 1.9,
            .low = 1.7,
            .high = 2.0,
        },
    };

    var figure = Figure.init(allocator, .{
        .title = .{
            .text = "CandleStick example",
        },
        .axis = .{
            .show_grid_x = false,
            .show_grid_y = false,
            .show_x_labels = false,
            .y_labels_formatter = Figure.formatters.default(.{}),
        },
    });
    defer figure.deinit();

    try figure.addPlot(CandleStick{
        .candles = &candles,
        .style = .{},
    });

    var svg = try figure.show();
    defer svg.deinit();

    // Write to an output file (out.svg)
    var file = try std.fs.cwd().createFile("example/out/candlestick.svg", .{});
    defer file.close();

    try svg.writeTo(file.writer());
}
