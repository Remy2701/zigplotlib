const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Kind = @import("kind.zig").Kind;

const rgb = @import("util/rgb.zig");
const RGB = rgb.RGB;

const length = @import("util/length.zig");
const LengthPercent = length.LengthPercent;

const Path = @This();

/// The command for the path
pub const Command = union(enum) {
    /// `M x y`
    MoveTo: struct {
        x: f32,
        y: f32,
    },
    /// `m dx dy`
    MoveToRelative: struct {
        x: f32,
        y: f32,
    },
    /// `L x y`
    LineTo: struct {
        x: f32,
        y: f32,
    },
    /// `l dx dy`
    LineToRelative: struct {
        x: f32,
        y: f32,
    },
    /// `H x`
    HorizontalLineTo: struct {
        x: f32,
    },
    /// `h dx`
    HorizontalLineToRelative: struct {
        x: f32,
    },
    /// `V y`
    VerticalLineTo: struct {
        y: f32,
    },
    /// `v dy`
    VerticalLineToRelative: struct {
        y: f32,
    },
    /// `C x1 y1 x2 y2 x y`
    CubicBezierCurveTo: struct {
        x1: f32,
        y1: f32,
        x2: f32,
        y2: f32,
        x: f32,
        y: f32,
    },
    /// `c dx1 dy1 dx2 dy2 dx dy`
    CubicBezierCurveToRelative: struct {
        dx1: f32,
        dy1: f32,
        dx2: f32,
        dy2: f32,
        dx: f32,
        dy: f32,
    },
    /// `S x2 y2 x y`
    SmoothCubicBezierCurveTo: struct {
        x2: f32,
        y2: f32,
        x: f32,
        y: f32,
    },
    /// `s dx2 dy2 dx dy`
    SmoothCubicBezierCurveToRelative: struct {
        dx2: f32,
        dy2: f32,
        dx: f32,
        dy: f32,
    },
    /// `Q x1 y1 x y`
    QuadraticBezierCurveTo: struct {
        x1: f32,
        y1: f32,
        x: f32,
        y: f32,
    },
    /// `q dx1 dy1 dx dy`
    QuadraticBezierCurveToRelative: struct {
        dx1: f32,
        dy1: f32,
        dx: f32,
        dy: f32,
    },
    /// `T x y`
    SmoothQuadraticBezierCurveTo: struct {
        x: f32,
        y: f32,
    },
    /// `t dx dy`
    SmoothQuadraticBezierCurveToRelative: struct {
        dx: f32,
        dy: f32,
    },
    /// `A rx ry x-axis-rotation large-arc-flag sweep-flag x y`
    EllipticalArcTo: struct {
        rx: f32,
        ry: f32,
        x_axis_rotation: f32,
        large_arc_flag: bool,
        sweep_flag: bool,
        x: f32,
        y: f32,
    },
    /// `a rx ry x-axis-rotation large-arc-flag sweep-flag dx dy`
    EllipticalArcToRelative: struct {
        rx: f32,
        ry: f32,
        x_axis_rotation: f32,
        large_arc_flag: bool,
        sweep_flag: bool,
        dx: f32,
        dy: f32,
    },
    /// `Z`
    ClosePath: void,

    /// Write the command to the given writer
    pub fn writeTo(self: *const Command, writer: anytype) anyerror!void {
        switch (self.*) {
            .MoveTo => {
                try writer.print("M {d} {d}", .{ self.MoveTo.x, self.MoveTo.y });
            },
            .MoveToRelative => {
                try writer.print("m {d} {d}", .{ self.MoveToRelative.x, self.MoveToRelative.y });
            },
            .LineTo => {
                try writer.print("L {d} {d}", .{ self.LineTo.x, self.LineTo.y });
            },
            .LineToRelative => {
                try writer.print("l {d} {d}", .{ self.LineToRelative.x, self.LineToRelative.y });
            },
            .HorizontalLineTo => {
                try writer.print("H {d}", .{self.HorizontalLineTo.x});
            },
            .HorizontalLineToRelative => {
                try writer.print("h {d}", .{self.HorizontalLineToRelative.x});
            },
            .VerticalLineTo => {
                try writer.print("V {d}", .{self.VerticalLineTo.y});
            },
            .VerticalLineToRelative => {
                try writer.print("v {d}", .{self.VerticalLineToRelative.y});
            },
            .CubicBezierCurveTo => {
                try writer.print("C {d} {d} {d} {d} {d} {d}", .{
                    self.CubicBezierCurveTo.x1,
                    self.CubicBezierCurveTo.y1,
                    self.CubicBezierCurveTo.x2,
                    self.CubicBezierCurveTo.y2,
                    self.CubicBezierCurveTo.x,
                    self.CubicBezierCurveTo.y,
                });
            },
            .CubicBezierCurveToRelative => {
                try writer.print("c {d} {d} {d} {d} {d} {d}", .{
                    self.CubicBezierCurveToRelative.dx1,
                    self.CubicBezierCurveToRelative.dy1,
                    self.CubicBezierCurveToRelative.dx2,
                    self.CubicBezierCurveToRelative.dy2,
                    self.CubicBezierCurveToRelative.dx,
                    self.CubicBezierCurveToRelative.dy,
                });
            },
            .SmoothCubicBezierCurveTo => {
                try writer.print("S {d} {d} {d} {d}", .{
                    self.SmoothCubicBezierCurveTo.x2,
                    self.SmoothCubicBezierCurveTo.y2,
                    self.SmoothCubicBezierCurveTo.x,
                    self.SmoothCubicBezierCurveTo.y,
                });
            },
            .SmoothCubicBezierCurveToRelative => {
                try writer.print("s {d} {d} {d} {d}", .{
                    self.SmoothCubicBezierCurveToRelative.dx2,
                    self.SmoothCubicBezierCurveToRelative.dy2,
                    self.SmoothCubicBezierCurveToRelative.dx,
                    self.SmoothCubicBezierCurveToRelative.dy,
                });
            },
            .QuadraticBezierCurveTo => {
                try writer.print("Q {d} {d} {d} {d}", .{
                    self.QuadraticBezierCurveTo.x1,
                    self.QuadraticBezierCurveTo.y1,
                    self.QuadraticBezierCurveTo.x,
                    self.QuadraticBezierCurveTo.y,
                });
            },
            .QuadraticBezierCurveToRelative => {
                try writer.print("q {d} {d} {d} {d}", .{
                    self.QuadraticBezierCurveToRelative.dx1,
                    self.QuadraticBezierCurveToRelative.dy1,
                    self.QuadraticBezierCurveToRelative.dx,
                    self.QuadraticBezierCurveToRelative.dy,
                });
            },
            .SmoothQuadraticBezierCurveTo => {
                try writer.print("T {d} {d}", .{ self.SmoothQuadraticBezierCurveTo.x, self.SmoothQuadraticBezierCurveTo.y });
            },
            .SmoothQuadraticBezierCurveToRelative => {
                try writer.print("t {d} {d}", .{ self.SmoothQuadraticBezierCurveToRelative.dx, self.SmoothQuadraticBezierCurveToRelative.dy });
            },
            .EllipticalArcTo => {
                try writer.print("A {d} {d} {d} {s} {s} {d} {d}", .{
                    self.EllipticalArcTo.rx,
                    self.EllipticalArcTo.ry,
                    self.EllipticalArcTo.x_axis_rotation,
                    if (self.EllipticalArcTo.large_arc_flag) "1" else "0",
                    if (self.EllipticalArcTo.sweep_flag) "1" else "0",
                    self.EllipticalArcTo.x,
                    self.EllipticalArcTo.y,
                });
            },
            .EllipticalArcToRelative => {
                try writer.print("a {d} {d} {d} {s} {s} {d} {d}", .{
                    self.EllipticalArcToRelative.rx,
                    self.EllipticalArcToRelative.ry,
                    self.EllipticalArcToRelative.x_axis_rotation,
                    if (self.EllipticalArcToRelative.large_arc_flag) "1" else "0",
                    if (self.EllipticalArcToRelative.sweep_flag) "1" else "0",
                    self.EllipticalArcToRelative.dx,
                    self.EllipticalArcToRelative.dy,
                });
            },
            .ClosePath => {
                try writer.writeAll("Z");
            },
        }
    }
};

pub const Options = struct {
    /// The commands for the path
    commands: ?[]Command = null,
    /// The allocator for the commands (null means not-allocated)
    allocator: ?Allocator = null,
    /// The color of the fill
    fill: ?RGB = null,
    /// The opacity of the fill
    fill_opacity: f32 = 1.0,
    /// The color of the stroke
    stroke: ?RGB = null,
    /// The opacity of the stroke
    stroke_opacity: f32 = 1.0,
    /// The width of the stroke
    stroke_width: LengthPercent = .{ .pixel = 1.0 },
    /// The dash array of the stroke
    stroke_dasharray: ?[]const f32 = null,
    /// The opacity of the stroke
    opacity: f32 = 1.0,
};

/// The options of the path
options: Options,

/// Initialize the path with the given options
pub fn init(options: Options) Path {
    return Path{
        .options = options,
    };
}

/// Deinitialize the path
pub fn deinit(self: *const Path) void {
    if (self.options.allocator) |allocator| {
        if (self.options.commands) |commands| {
            allocator.free(commands);
        }
    }
}

/// Write the path to the given writer
pub fn writeTo(self: *const Path, writer: anytype) anyerror!void {
    try writer.writeAll("<path");
    if (self.options.commands) |commands| {
        try writer.writeAll(" d=\"");
        for (commands) |command| {
            try command.writeTo(writer);
            try writer.writeAll(" ");
        }
        try writer.writeAll("\" ");
    } else try writer.writeAll(" d=\"\" ");
    if (self.options.fill) |fill| try writer.print("fill=\"#{X:0>6}\" ", .{fill}) else try writer.writeAll("fill=\"none\" ");
    try writer.print("fill-opacity=\"{d}\" ", .{self.options.fill_opacity});
    if (self.options.stroke) |stroke| try writer.print("stroke=\"#{X:0>6}\" ", .{stroke}) else try writer.writeAll("stroke=\"none\" ");
    try writer.print("stroke-opacity=\"{d}\" ", .{self.options.stroke_opacity});
    try writer.print("stroke-width=\"{}\" ", .{self.options.stroke_width});
    if (self.options.stroke_dasharray) |dasharray| {
        try writer.writeAll("stroke-dasharray=\"");
        for (dasharray) |dash| {
            try writer.print("{d} ", .{dash});
        }
        try writer.writeAll("\" ");
    }
    try writer.print("opacity=\"{d}\" ", .{self.options.opacity});
    try writer.writeAll("/>");
}

pub fn wrap(self: *const Path) Kind {
    return Kind{ .path = self.* };
}
