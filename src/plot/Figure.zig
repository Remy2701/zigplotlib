const std = @import("std");
const Allocator = std.mem.Allocator;

const SVG = @import("../svg/SVG.zig");
const Range = @import("../util/range.zig").Range;

const rgb = @import("../svg/util/rgb.zig");
const RGB = rgb.RGB;

const Plot = @import("Plot.zig");
const FigureInfo = @import("FigureInfo.zig");

const intf = @import("../core/intf.zig");

const Figure = @This();

/// The Default Values used for the figure
const Default = struct {
    const gap: f32 = 10.0;
    const plot_padding: f32 = 50.0;
    const width: f32 = 512;
    const height: f32 = 512;
};

pub const ValuePercent = union(enum) {
    /// The value
    value: f32,
    /// The percent (0.1 => 10%, 1.0 => 100%)
    percent: f32,
};

/// The style of the figure
pub const Style = struct {
    /// The width of the figure (excluding the axis a label)
    width: union(enum) {
        /// Width in px.
        pixel: f32,
        /// Width computed from the given gap
        auto_gap: f32,
    } = .{ .pixel = Default.width },
    /// The height of the figure (excluding the axis a label)
    height: union(enum) {
        /// Width in px.
        pixel: f32,
        /// Width computed from the given gap
        auto_gap: f32,
    } = .{ .pixel = Default.height },
    /// The size used for the axis and labels
    plot_padding: f32 = Default.plot_padding,
    /// The color of the background
    background_color: RGB = rgb.WHITE,
    /// The opacity of the background
    background_opacity: f32 = 1.0,
    /// The padding of the ranges
    value_padding: struct {
        x_max: ValuePercent = .{ .percent = 0.0 },
        y_max: ValuePercent = .{ .percent = 0.1 },
        x_min: ValuePercent = .{ .percent = 0.0 },
        y_min: ValuePercent = .{ .percent = 0.1 },
    } = .{},
    /// The style of the axis
    axis: struct {
        /// The range of values on the x_axis
        x_range: ?Range(f32) = null,
        /// The range of values on the y_axis
        y_range: ?Range(f32) = null,
        /// The color of the axis
        color: RGB = rgb.BLACK,
        /// The width of the axis
        width: f32 = 2.0,
        /// The color of the labels
        label_color: RGB = rgb.BLACK,
        /// The size of the labels
        label_size: f32 = 10.0,
        /// The padding between the axis and the labels
        label_padding: f32 = 10.0,
        /// The font of the labels
        label_font: []const u8 = "sans-serif",
        /// The number of ticks on the x-axis
        tick_count_x: union(enum) {
            /// The number of ticks
            count: usize,
            /// The gap between the ticks
            gap: f32,
        } = .{ .count = 5.0 },
        /// The number of ticks on the y-axis
        tick_count_y: union(enum) {
            /// The number of ticks
            count: usize,
            /// The gap between the ticks
            gap: f32,
        } = .{ .count = 5.0 },
        /// Whether to show the x-axis
        show_x_axis: bool = true,
        /// Whether to show the y-axis
        show_y_axis: bool = true,
        /// Whether to show the grid on the x-axis
        show_grid_x: bool = true,
        /// Whether to show the grid on the y-axis
        show_grid_y: bool = true,
        /// The opacity of the grid
        grid_opacity: f32 = 0.2,
        /// The color of the frame
        frame_color: RGB = rgb.BLACK,
        /// The width of the frame
        frame_width: f32 = 4.0,
    } = .{},
    /// The style the legend
    legend: struct {
        /// Whether to show the legend
        show: bool = true,
        /// The position of the legend
        position: union(enum) {
            top_left,
            top_right,
            bottom_left,
            bottom_right,
        } = .bottom_right,
        /// The font size to use for the lengend
        font_size: f32 = 10.0,
        /// The color of the background
        background_color: RGB = rgb.WHITE,
        /// The color of the border
        border_color: RGB = rgb.BLACK,
        /// The width of the border
        border_width: f32 = 2.0,
        /// The padding with the plot
        padding: f32 = 10.0,
    } = .{},
};

/// The allocator used for the figure
allocator: Allocator,
/// The arena allocator (used for local data)
arena: std.heap.ArenaAllocator,
/// The list of plots
plots: Plot.List,
/// The style of the figure
style: Style,

/// Initialize the figure with the given allocator
pub fn init(allocator: Allocator, style: Style) Figure {
    return Figure {
        .allocator = allocator,
        .arena = std.heap.ArenaAllocator.init(allocator),
        .plots = std.ArrayList(Plot).init(allocator),
        .style = style,
    };
}

/// Deinitialize the figure.
pub fn deinit(self: *const Figure) void {
    self.arena.deinit();
    self.plots.deinit();
}

/// Add a plot to the figure, the given `plot` should be of type `Plot` or have the interface method that returns a 
/// `Plot`.
pub fn addPlot(self: *Figure, plot: anytype) !void {
    if (@TypeOf(plot) == Plot) {
        try self.plots.append(plot);
    } else {
        intf.ensureImplement(struct {
            interface: fn(*const anyopaque) Plot
        }, @TypeOf(plot));

        const mem = try self.arena.allocator().create(@TypeOf(plot));
        mem.* = plot;
        try self.plots.append(mem.interface());
    }
}

/// Get the x-range of the plot
fn getRangeX(self: *const Figure) Range(f32) {
    // Initialize the range to ]∞;-∞[
    var range_x = Range(f32).init(std.math.inf(f32), -std.math.inf(f32));
    for (self.plots.items) |plot| {
        const plot_range_x = plot.getRangeX();
        
        range_x.min = @min(range_x.min, plot_range_x.min);
        range_x.max = @max(range_x.max, plot_range_x.max);
    }

    return range_x;
}

/// Get the y-range of the plot
fn getRangeY(self: *const Figure) Range(f32) {
    // Initialize the range to ]∞;-∞[
    var range_y = Range(f32).init(std.math.inf(f32), -std.math.inf(f32));
    for (self.plots.items) |plot| {
        const plot_range_y = plot.getRangeY();
        
        range_y.min = @min(range_y.min, plot_range_y.min);
        range_y.max = @max(range_y.max, plot_range_y.max);
    }

    return range_y;
}

/// Compute the width of the plot (excluding the axis and labels)
fn computePlotWidth(self: *const Figure, x_range: Range(f32)) f32 {
    switch (self.style.width) {
        .pixel => |pixel| return pixel,
        .auto_gap => |gap| return gap * (x_range.max - x_range.min),
    }
}

/// Compute the height of the plot (excluding the axis and labels)
fn computePlotHeight(self: *const Figure, y_range: Range(f32)) f32 {
    switch (self.style.height) {
        .pixel => |pixel| return pixel,
        .auto_gap => |gap| return gap * (y_range.max - y_range.min),
    }
}

/// Get the height of the positive and negative section
fn getSectionHeight(info: FigureInfo) struct { pos: f32, neg: f32 } {
    const y0 = info.getBaseY();
    return .{
        .pos = y0,
        .neg = info.height - y0,
    };
}

/// Get the width of the positive and negative section
fn getSectionWidth(info: FigureInfo) struct { pos: f32, neg: f32 } {
    const x0 = info.computeX(0.0);
    return .{
        .pos = info.width - x0,
        .neg = x0,
    };
}

/// Compute the gap between the ticks on the x-axis
fn computeXTickGap(self: *const Figure, info: FigureInfo) f32 {
    return switch(self.style.axis.tick_count_x) {
        .count => |count| blk: {
            const sections = getSectionHeight(info);
            break :blk @max(sections.pos, sections.neg) / @as(f32, @floatFromInt(count + 1));
        },
        .gap => |gap| gap
    };
}

/// Compute the gap between the ticks on the y-axis
fn computeYTickGap(self: *const Figure, info: FigureInfo) f32 {
    return switch(self.style.axis.tick_count_y) {
        .count => |count| blk: {
            const sections = getSectionWidth(info);
            break :blk @max(sections.pos, sections.neg) / @as(f32, @floatFromInt(count + 1));
        },
        .gap => |gap| gap
    };
}

/// Compute the number of ticks on the x-axis
fn computeXTickCount(self: *const Figure, info: FigureInfo, gap: f32) struct { pos: usize, neg: usize } {
    return switch(self.style.axis.tick_count_x) {
        .count => |count| blk: {
            const sections = getSectionHeight(info);
            break :blk .{
                .pos = if (sections.pos > sections.neg) count else @intFromFloat(sections.pos / gap),
                .neg = if (sections.neg > sections.pos) count else @intFromFloat(sections.neg / gap),
            };
        },
        .gap => blk: {
            const sections = getSectionHeight(info);
            break :blk .{
                .pos = @intFromFloat(sections.pos / gap),
                .neg = @intFromFloat(sections.neg / gap),
            };
        },
    };
}

/// Compute the number of ticks on the y-axis
fn computeYTickCount(self: *const Figure, info: FigureInfo, gap: f32) struct { pos: usize, neg: usize } {
    return switch(self.style.axis.tick_count_x) {
        .count => |count| blk: {
            const sections = getSectionWidth(info);
            break :blk .{
                .pos = if (sections.pos > sections.neg) count else @intFromFloat(sections.pos / gap),
                .neg = if (sections.neg > sections.pos) count else @intFromFloat(sections.neg / gap),
            };
        },
        .gap => blk: {
            const sections = getSectionWidth(info);
            break :blk .{
                .pos = @intFromFloat(sections.pos / gap),
                .neg = @intFromFloat(sections.neg / gap),
            };
        },
    };
}

fn applyPaddingToRange(range: Range(f32), min: ValuePercent, max: ValuePercent) Range(f32) {
    return Range(f32).init(
        switch (min) {
            .value => |value| range.min - value,
            .percent => |percent| range.min - @abs(range.min) * percent,
        },
        switch (max) {
            .value => |value| range.max + value,
            .percent => |percent| range.max + @abs(range.max) * percent,
        },
    );
}

/// Get the information of the figure
fn getInfo(self: *const Figure) FigureInfo {
    const x_range = 
        if (self.style.axis.x_range) |x_range| x_range 
        else applyPaddingToRange(self.getRangeX(), self.style.value_padding.x_min, self.style.value_padding.x_max);
    
    const y_range = 
        if (self.style.axis.y_range) |y_range| y_range
        else applyPaddingToRange(self.getRangeY(), self.style.value_padding.y_min, self.style.value_padding.y_max);

    const width = self.computePlotWidth(x_range);
    const height = self.computePlotHeight(y_range);

    return FigureInfo {
        .x_range = x_range,
        .y_range = y_range,
        .width = width,
        .height = height,
    };
}

/// Draw the x axis of the figure
fn drawXAxis(self: *Figure, svg: *SVG, info: FigureInfo) !void {
    if (!info.y_range.contains(0.0)) return;

    const y0 = info.computeY(0.0);
    try svg.addLine(.{
        .x1 = .{ .pixel = 0.0 },
        .y1 = .{ .pixel = y0 },
        .x2 = .{ .pixel = info.width },
        .y2 = .{ .pixel = y0 },
        .stroke = self.style.axis.color,
        .stroke_width = .{ .pixel = self.style.axis.width },
    });
}

/// Draw the grid on the y axis of the figure
fn drawYGrid(self: *Figure, svg: *SVG, info: FigureInfo) !void {
    const gap = self.computeXTickGap(info);
    const counts = self.computeXTickCount(info, gap);

    const y0 = info.getBaseY();

    // Positive section
    for (0..(counts.pos + 1)) |i| {
        const y: f32 = y0 - @as(f32, @floatFromInt(i)) * gap;
        try svg.addLine(.{
            .x1 = .{ .pixel = 0.0 },
            .y1 = .{ .pixel = y },
            .x2 = .{ .pixel = info.width },
            .y2 = .{ .pixel = y },
            .stroke = self.style.axis.color,
            .stroke_width = .{ .pixel = self.style.axis.width },
            .opacity = self.style.axis.grid_opacity,
        });
    }

    // Negative section
    for (1..(counts.neg + 1)) |i| {
        const y: f32 = y0 + @as(f32, @floatFromInt(i)) * gap;
        try svg.addLine(.{
            .x1 = .{ .pixel = 0.0 },
            .y1 = .{ .pixel = y },
            .x2 = .{ .pixel = info.width },
            .y2 = .{ .pixel = y },
            .stroke = self.style.axis.color,
            .stroke_width = .{ .pixel = self.style.axis.width },
            .opacity = self.style.axis.grid_opacity,
        });
    }
}

/// Draw the y axis of the figure
fn drawYAxis(self: *Figure, svg: *SVG, info: FigureInfo) !void {
    if (!info.x_range.contains(0.0)) return;

    const x0 = info.computeX(0.0);
    try svg.addLine(.{
        .x1 = .{ .pixel = x0 },
        .y1 = .{ .pixel = 0.0 },
        .x2 = .{ .pixel = x0 },
        .y2 = .{ .pixel = info.height },
        .stroke = self.style.axis.color,
        .stroke_width = .{ .pixel = self.style.axis.width },
    });
}

/// Draw the grid on the x axis of the figure
fn drawXGrid(self: *Figure, svg: *SVG, info: FigureInfo) !void {
    const gap = self.computeYTickGap(info);
    const counts = self.computeYTickCount(info, gap);

    const x0 = info.computeX(0.0);

    // Positive section
    for (0..(counts.pos + 1)) |i| {
        const x: f32 = x0 + @as(f32, @floatFromInt(i)) * gap;
        try svg.addLine(.{
            .x1 = .{ .pixel = x },
            .y1 = .{ .pixel = 0.0 },
            .x2 = .{ .pixel = x },
            .y2 = .{ .pixel = info.height },
            .stroke = self.style.axis.color,
            .stroke_width = .{ .pixel = self.style.axis.width },
            .opacity = self.style.axis.grid_opacity,
        });
    }

    // Negative section
    for (1..(counts.neg + 1)) |i| {
        const x: f32 = x0 - @as(f32, @floatFromInt(i)) * gap;
        try svg.addLine(.{
            .x1 = .{ .pixel = x },
            .y1 = .{ .pixel = 0.0 },
            .x2 = .{ .pixel = x },
            .y2 = .{ .pixel = info.height },
            .stroke = self.style.axis.color,
            .stroke_width = .{ .pixel = self.style.axis.width },
            .opacity = self.style.axis.grid_opacity,
        });
    }
}

/// Draw the border of the figure (frame)
fn drawBorder(self: *Figure, svg: *SVG, info: FigureInfo) !void {
    try svg.addRect(.{
        .x = .{ .pixel = 0.0 },
        .y = .{ .pixel = 0.0 },
        .width = .{ .pixel = info.width },
        .height = .{ .pixel = info.height },
        .fill = null,
        .stroke = self.style.axis.frame_color,
        .stroke_width = .{ .pixel = self.style.axis.frame_width },
    });
}

/// Draw the labels on the y axis of the figure
fn drawYLabels(self: *Figure, svg: *SVG, info: FigureInfo) !void {
    const gap = self.computeXTickGap(info);
    const counts = self.computeXTickCount(info, gap);

    const y0 = info.getBaseY();

    // Positive section
    for (0..(counts.pos + 1)) |i| {
        const y: f32 = y0 - @as(f32, @floatFromInt(i)) * gap;

        const y_value = info.computeYInv(y);

        var buffer = std.ArrayList(u8).init(self.arena.allocator());
        try buffer.writer().print("{d:.2}", .{ y_value });

        try svg.addText(.{
            .x = .{ .pixel = -self.style.axis.label_padding },
            .y = .{ .pixel = y },
            .text_anchor = .end,
            .dominant_baseline = .middle,
            .font_family = self.style.axis.label_font,
            .font_size = .{ .pixel = self.style.axis.label_size },
            .fill = self.style.axis.label_color,
            .text = try buffer.toOwnedSlice(),
        });
    }

    // Negative section
    for (1..(counts.neg + 1)) |i| {
        const y: f32 = y0 + @as(f32, @floatFromInt(i)) * gap;

        const y_value = info.computeYInv(y);

        var buffer = std.ArrayList(u8).init(self.arena.allocator());
        try buffer.writer().print("{d:.2}", .{ y_value });

        try svg.addText(.{
            .x = .{ .pixel = -self.style.axis.label_padding },
            .y = .{ .pixel = y },
            .text_anchor = .end,
            .dominant_baseline = .middle,
            .font_family = self.style.axis.label_font,
            .font_size = .{ .pixel = self.style.axis.label_size },
            .fill = self.style.axis.label_color,
            .text = try buffer.toOwnedSlice(),
        });
    }
}

/// Draw the labels on the x axis of the figure
fn drawXLabels(self: *Figure, svg: *SVG, info: FigureInfo) !void {
    const gap = self.computeYTickGap(info);
    const counts = self.computeYTickCount(info, gap);

    const x0 = info.computeX(0.0);

    // Positive section
    for (0..(counts.pos + 1)) |i| {
        const x: f32 = x0 + @as(f32, @floatFromInt(i)) * gap;

        const x_value = info.computeXInv(x);

        var buffer = std.ArrayList(u8).init(self.arena.allocator());
        try buffer.writer().print("{d:.2}", .{ x_value });

        try svg.addText(.{
            .x = .{ .pixel = x },
            .y = .{ .pixel = info.height + self.style.axis.label_padding },
            .text_anchor = .middle,
            .dominant_baseline = .hanging,
            .font_family = self.style.axis.label_font,
            .font_size = .{ .pixel = self.style.axis.label_size },
            .fill = self.style.axis.label_color,
            .text = try buffer.toOwnedSlice(),
        });
    }

    // Negative section
    for (1..(counts.neg + 1)) |i| {
        const x: f32 = x0 - @as(f32, @floatFromInt(i)) * gap;

        const x_value = info.computeXInv(x);

        var buffer = std.ArrayList(u8).init(self.arena.allocator());
        try buffer.writer().print("{d:.2}", .{ x_value });

        try svg.addText(.{
            .x = .{ .pixel = x },
            .y = .{ .pixel = info.height + self.style.axis.label_padding },
            .text_anchor = .middle,
            .dominant_baseline = .hanging,
            .font_family = self.style.axis.label_font,
            .font_size = .{ .pixel = self.style.axis.label_size },
            .fill = self.style.axis.label_color,
            .text = try buffer.toOwnedSlice(),
        });
    }
}

fn drawLegend(self: *Figure, svg: *SVG, info: FigureInfo) !void {
    var plot_count: usize = 0;
    var longuest_title: usize = 0;
    for (self.plots.items) |plot| {
        if (plot.title) |title| {
            longuest_title = @max(longuest_title, title.len);
            plot_count += 1;
        }
    }

    if (plot_count == 0) return;


    // FIXME: Not ideal
    const width = @as(f32, @floatFromInt(longuest_title)) * self.style.legend.font_size / 1.5 + 2 * self.style.legend.font_size;
    const height = @as(f32, @floatFromInt(plot_count)) * (self.style.legend.font_size * 1.5 + 2.0) + self.style.legend.font_size / 2.0;
    
    const x, const y = switch (self.style.legend.position) {
        .top_left => .{ self.style.legend.padding, self.style.legend.padding },
        .top_right => .{ info.width - self.style.legend.padding - width, self.style.legend.padding },
        .bottom_left => .{ self.style.legend.padding, info.height - self.style.legend.padding - height },
        .bottom_right => .{ info.width - self.style.legend.padding - width, info.height - self.style.legend.padding - height },
    };

    try svg.addRect(.{
        .x = .{ .pixel = x },
        .y = .{ .pixel = y },
        .width = .{ .pixel = width },
        .height = .{ .pixel = height },
        .fill = self.style.legend.background_color,
        .stroke = self.style.legend.border_color,
        .stroke_width = .{ .pixel = self.style.legend.border_width },
    });

    var i: usize = 0;
    for (self.plots.items) |plot| {
        if (plot.title) |title| {
            try svg.addRect(.{
                .x = .{ .pixel = x + self.style.legend.font_size / 2 },
                .y = .{ .pixel = y + (self.style.legend.font_size * 1.5 + 2) * @as(f32, @floatFromInt(i)) + self.style.legend.font_size / 2 },
                .width = .{ .pixel = self.style.legend.font_size },
                .height = .{ .pixel = self.style.legend.font_size },
                .fill = plot.color,
            });
            try svg.addText(.{
                .x = .{ .pixel = x + 2 * self.style.legend.font_size },
                .y = .{ .pixel = y + self.style.legend.font_size + (self.style.legend.font_size * 1.5 + 2) * @as(f32, @floatFromInt(i)) },
                .text_anchor = .start,
                .dominant_baseline = .middle,
                .font_family = self.style.axis.label_font,
                .font_size = .{ .pixel = self.style.legend.font_size },
                .fill = self.style.axis.label_color,
                .text = title,
            });
            i += 1;
            if (i == plot_count) break;
        }
    }
} 

/// Draw the figure on an SVG File.
pub fn show(self: *Figure) !SVG {
    if (self.plots.items.len == 0) return error.NoPlots;

    const info = self.getInfo();

    var svg = SVG.init(
        self.allocator, 
        info.width + 2 * self.style.plot_padding,
        info.height + 2 * self.style.plot_padding
    );

    svg.viewbox.x = -self.style.plot_padding;
    svg.viewbox.y = -self.style.plot_padding;

    // Draw the background
    try svg.addRect(.{
        .x = .{ .pixel = svg.viewbox.x },
        .y = .{ .pixel = svg.viewbox.y },
        .width = .{ .pixel = svg.viewbox.width },
        .height = .{ .pixel = svg.viewbox.height },
        .fill = self.style.background_color,
        .opacity = self.style.background_opacity,
    });

    // Draw the grid
    if (self.style.axis.show_grid_x) try self.drawXGrid(&svg, info);
    if (self.style.axis.show_grid_y) try self.drawYGrid(&svg, info);

    // Draw the plots
    for (self.plots.items) |plot| {
        try plot.draw(self.arena.allocator(), &svg, info);
    }

    // y-axis
    if (self.style.axis.show_y_axis) try self.drawYAxis(&svg, info);

    // x-axis
    if (self.style.axis.show_x_axis) try self.drawXAxis(&svg, info);

    // Border
    try self.drawBorder(&svg, info);

    // Labels
    try self.drawXLabels(&svg, info);
    try self.drawYLabels(&svg, info);

    // Legend
    if (self.style.legend.show) try self.drawLegend(&svg, info);

    return svg;
}