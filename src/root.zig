const std = @import("std");

// Plot Module
pub const Figure = @import("plot/Figure.zig");
pub const Plot = @import("plot/Plot.zig");
pub const Line = @import("plot/Line.zig");
pub const Area = @import("plot/Area.zig");
pub const Scatter = @import("plot/Scatter.zig");
pub const Step = @import("plot/Step.zig");
pub const Stem = @import("plot/Stem.zig");
pub const FigureInfo = @import("plot/FigureInfo.zig");

// Util Module
pub const Range = @import("util/range.zig").Range;
pub const polyshape = @import("util/polyshape.zig");

// SVG Module
const SVG = @import("svg/SVG.zig");
const length = @import("svg/util/length.zig");
const LengthPercent = length.LengthPercent;
const LengthPercentAuto = length.LengthPercentAuto;
pub const rgb = @import("svg/util/rgb.zig");
pub const RGB = rgb.RGB;

test "Plot Test" {
    std.testing.refAllDecls(FigureInfo);
    std.testing.refAllDecls(Figure);
}
