const std = @import("std");

/// The type corresponding to the SVG <length>|<percentage>|auto type.
pub const LengthPercentAuto = union(enum) {
    /// The length in pixels
    pixel: f32,
    /// The length in percent (of the parent)
    percent: f32,
    /// Automatic length
    auto: void,

    pub fn format(self: LengthPercentAuto, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .pixel => |value| try writer.print("{d}", .{value}),
            .percent => |value| try writer.print("{d}%", .{value}),
            .auto => try writer.writeAll("auto"),
        }
    }
};

/// The type corresponding to the SVG <length>|<percentage> type.
pub const LengthPercent = union(enum) {
    /// The length in pixels.
    pixel: f32,
    /// The length in percent (of the parent).
    percent: f32,

    pub fn format(self: LengthPercent, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        switch (self) {
            .pixel => |value| try writer.print("{d}", .{value}),
            .percent => |value| try writer.print("{d}%", .{value}),
        }
    }
};