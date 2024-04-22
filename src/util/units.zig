/// A value or a percentage.
pub const ValuePercent = union(enum) {
    value: f32,
    percent: f32,
};

/// A padding for the values.
pub const ValuePadding = struct {
    x_max: ValuePercent = .{ .percent = 0.0 },
    y_max: ValuePercent = .{ .percent = 0.1 },
    x_min: ValuePercent = .{ .percent = 0.0 },
    y_min: ValuePercent = .{ .percent = 0.1 },
};

/// A value in pixels or an auto gap.
pub const PixelAutoGap = union(enum) {
    pixel: f32,
    auto_gap: f32,
};

/// A count of values or the gap between them.
pub const CountGap = union(enum) {
    count: usize,
    gap: f32,
};

/// A position in the corner.
pub const CornerPosition = enum {
    top_left,
    top_right,
    bottom_left,
    bottom_right,
};
