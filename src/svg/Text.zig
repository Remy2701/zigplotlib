const std = @import("std");
const Allocator = std.mem.Allocator;

const Kind = @import("kind.zig").Kind;

const length = @import("util/length.zig");
const LengthPercent = length.LengthPercent;
const LengthPercentAuto = length.LengthPercentAuto;

const rgb = @import("util/rgb.zig");
const RGB = rgb.RGB;

const Text = @This();

/// Representation of the SVG FontSize property.
pub const FontSize = union(enum) {
    /// The absolute size.
    pixel: f32,
    /// The relative size.
    em: f32,
    /// The size in percent of the parent
    percent: f32,

    /// Absolute Size - xx-small
    xx_small: void,
    /// Absolute Size - x-small
    x_small: void,
    /// Absolute Size - small
    small: void,
    /// Absolute Size - medium
    medium: void,
    /// Absolute Size - large
    large: void,
    /// Absolute Size - x-large
    x_large: void,
    /// Absolute Size - xx-large
    xx_large: void,
    /// Absolute Size - xxx-large
    xxx_large: void,

    /// Relateive Size - smaller
    smaller: void,
    /// Relateive Size - larger
    larger: void,

    /// Math value
    math: void,

    pub fn format(self: FontSize, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .pixel => |value| try writer.print("{d}px", .{value}),
            .em => |value| try writer.print("{d}em", .{value}),
            .percent => |value| try writer.print("{d}%", .{value}),
            .xx_small => try writer.writeAll("xx-small"),
            .x_small => try writer.writeAll("x-small"),
            .small => try writer.writeAll("small"),
            .medium => try writer.writeAll("medium"),
            .large => try writer.writeAll("large"),
            .x_large => try writer.writeAll("x-large"),
            .xx_large => try writer.writeAll("xx-large"),
            .xxx_large => try writer.writeAll("xxx-large"),
            .smaller => try writer.writeAll("smaller"),
            .larger => try writer.writeAll("larger"),
            .math => try writer.writeAll("math"),
        }
    }
};

/// Representation of the SVG FontWeight property
pub const FontWeight = enum {
    /// The normal font weight
    normal,
    /// The bold font weight
    bold,
    /// The 100 font weight (thin)
    w100,
    /// The 200 font weight (extra light)
    w200,
    /// The 300 font weight (light)
    w300,
    /// The 400 font weight (normal)
    w400,
    /// The 500 font weight (medium)
    w500,
    /// The 600 font weight (semi bold)
    w600,
    /// The 700 font weight (bold)
    w700,
    /// The 800 font weight (extra bold)
    w800,
    /// The 900 font weight (black)
    w900,
    /// The lighter font weight
    lighter,
    /// The bolder font weight
    bolder,

    pub fn format(self: FontWeight, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .normal => try writer.writeAll("normal"),
            .bold => try writer.writeAll("bold"),
            .w100 => try writer.writeAll("100"),
            .w200 => try writer.writeAll("200"),
            .w300 => try writer.writeAll("300"),
            .w400 => try writer.writeAll("400"),
            .w500 => try writer.writeAll("500"),
            .w600 => try writer.writeAll("600"),
            .w700 => try writer.writeAll("700"),
            .w800 => try writer.writeAll("800"),
            .w900 => try writer.writeAll("900"),
            .lighter => try writer.writeAll("lighter"),
            .bolder => try writer.writeAll("bolder"),
        }
    }
};

/// Representation of the SVG TextAnchor property
pub const TextAnchor = enum {
    /// The start anchor
    start,
    /// The middle anchor
    middle,
    /// The end anchor
    end,

    pub fn format(self: TextAnchor, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .start => try writer.writeAll("start"),
            .middle => try writer.writeAll("middle"),
            .end => try writer.writeAll("end"),
        }
    }
};

/// Representation of the SVG DominantBaseline property
pub const DominantBaseline = enum {
    /// The auto baseline
    auto,
    /// The use script baseline
    use_script,
    /// The no change baseline
    no_change,
    /// The reset size baseline
    reset_size,
    /// The ideographic baseline
    ideographic,
    /// The alphabetic baseline
    alphabetic,
    /// The hanging baseline
    hanging,
    /// The mathematical baseline
    mathematical,
    /// The central baseline
    central,
    /// The middle baseline
    middle,
    /// The text after edge baseline
    text_after_edge,
    /// The text before edge baseline
    text_before_edge,

    pub fn format(self: DominantBaseline, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .auto => try writer.writeAll("auto"),
            .use_script => try writer.writeAll("use-script"),
            .no_change => try writer.writeAll("no-change"),
            .reset_size => try writer.writeAll("reset-size"),
            .ideographic => try writer.writeAll("ideographic"),
            .alphabetic => try writer.writeAll("alphabetic"),
            .hanging => try writer.writeAll("hanging"),
            .mathematical => try writer.writeAll("mathematical"),
            .central => try writer.writeAll("central"),
            .middle => try writer.writeAll("middle"),
            .text_after_edge => try writer.writeAll("text-after-edge"),
            .text_before_edge => try writer.writeAll("text-before-edge"),
        }
    }
};

/// The options of a Text.
pub const Options = struct {
    /// The x coordinate of the text.
    x: LengthPercent = .{ .pixel = 0.0 },
    /// The y coordinate of the text.
    y: LengthPercent = .{ .pixel = 0.0 },
    /// The x displacement of the text
    dx: LengthPercent = .{ .pixel = 0.0 },
    /// The y displacement of the text
    dy: LengthPercent = .{ .pixel = 0.0 },
    /// The length of the text
    length: ?LengthPercent = null,
    /// The color of the fill of the text
    fill: ?RGB = null,
    /// The opacity of the fill of the text
    fill_opacity: f32 = 1.0,
    /// The color of the stroke of the text
    stroke: ?RGB = null,
    /// The opacity of the stroke of the text
    stroke_opacity: f32 = 1.0,
    /// The width of the stroke of the text
    stroke_width: LengthPercent = .{ .pixel = 1.0 },
    /// The opacity of the text (fill + stroke)
    opacity: f32 = 1.0,
    /// The text to display
    text: []const u8 = "",
    /// The allocator of the text (null means not allocated)
    allocator: ?Allocator = null,
    /// The font family of the text
    font_family: []const u8 = "sans-serif",
    /// The font size of the text
    font_size: FontSize = .medium,
    /// The font weight of the text,
    font_weight: FontWeight = .normal,
    /// The anchor of the text
    text_anchor: TextAnchor = .start,
    /// The dominant baseline of the text
    dominant_baseline: DominantBaseline = .auto,
};

/// The options of the Text
options: Options,

/// Initialize the Text with the given options
pub fn init(options: Options) Text {
    return Text {
        .options = options,
    };
}

/// Deinitialize the Text
pub fn deinit(self: *const Text) void {
    if (self.options.allocator) |allocator| {
        allocator.free(self.options.text);
    }
}

/// Write the text to the given writer
pub fn writeTo(self: *const Text, writer: anytype) anyerror!void {
    try writer.writeAll("<text ");
    try writer.print("x=\"{}\" ", .{self.options.x});
    try writer.print("y=\"{}\" ", .{self.options.y});
    try writer.print("dx=\"{}\" ", .{self.options.dx});
    try writer.print("dy=\"{}\" ", .{self.options.dy});
    if (self.options.length) |length_| try writer.print("textLength=\"{}\" ", .{length_})
    else try writer.writeAll("textLength=\"none\" ");
    if (self.options.fill) |fill| try writer.print("fill=\"#{X:0>6}\" ", .{fill})
    else try writer.writeAll("fill=\"none\" ");
    try writer.print("fill-opacity=\"{d}\" ", .{self.options.fill_opacity});
    if (self.options.stroke) |stroke| try writer.print("stroke=\"#{X:0>6}\" ", .{stroke})
    else try writer.writeAll("stroke=\"none\" ");
    try writer.print("stroke-opacity=\"{d}\" ", .{self.options.stroke_opacity});
    try writer.print("stroke-width=\"{}\" ", .{self.options.stroke_width});
    try writer.print("opacity=\"{d}\" ", .{self.options.opacity});
    try writer.print("font-family=\"{s}\" ", .{self.options.font_family});
    try writer.print("font-size=\"{}\" ", .{self.options.font_size});
    try writer.print("font-weight=\"{}\" ", .{self.options.font_weight});
    try writer.print("text-anchor=\"{}\" ", .{self.options.text_anchor});
    try writer.print("dominant-baseline=\"{}\" ", .{self.options.dominant_baseline});
    try writer.print(">{s}</text>", .{self.options.text});
}

/// Wrap the text in a kind
pub fn wrap(self: *const Text) Kind {
    return Kind {
        .text = self.*
    };
}