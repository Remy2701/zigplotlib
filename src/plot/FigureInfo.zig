//! The info of a Figure shared between the plots.

const std = @import("std");

const Range = @import("../util/range.zig").Range;

const FigureInfo = @This();

/// The width of the plot (in pixels). 
/// Note that this is not the width of the figure, but only the width of the plot.
width: f32,
/// The height of the plot (in pixels).
/// Note that this is not the height of the figure, but only the height of the plot.
height: f32,
/// The range of the x axis.
x_range: Range(f32),
/// The range of the y axis.
y_range: Range(f32),

/// Get the delta x of the figure.
pub fn get_dx(self: *const FigureInfo) f32 {
    return self.width / (self.x_range.max - self.x_range.min);
}

/// Get the delta y of the figure.
pub fn get_dy(self: *const FigureInfo) f32 {
    return self.height / (self.y_range.max - self.y_range.min);
}

/// Compute the x coordinate of a point in the figure
pub fn compute_x(self: *const FigureInfo, x: f32) f32 {
    return (x - self.x_range.min) * self.get_dx();
}

/// Compute the y coordinate of a point in the figure
pub fn compute_y(self: *const FigureInfo, y: f32) f32 {
    return self.height - (y - self.y_range.min) * self.get_dy();
}

/// Compute the inverse x coordinate of a point in the figure
pub fn compute_x_inv(self: *const FigureInfo, x: f32) f32 {
    return x / self.get_dx() + self.x_range.min;
}

/// Compute the inverse y coordinate of a point in the figure
pub fn compute_y_inv(self: *const FigureInfo, y: f32) f32 {
    return (self.height - y) / self.get_dy() + self.y_range.min;
}

/// Get the base-y coordinate (0.0, or minimum, or maximum)
pub fn get_base_y(self: *const FigureInfo) f32 {
    if (self.y_range.contains(0)) return self.compute_y(0.0)
    else if (self.y_range.min < 0.0) return self.compute_y(self.y_range.max)
    else return self.compute_y(self.y_range.min);
}

/// Get the base-x coordinate (0.0, or minimum, or maximum)
pub fn get_base_x(self: *const FigureInfo) f32 {
    if (self.x_range.contains(0)) return self.compute_x(0.0)
    else if (self.x_range.min < 0.0) return self.compute_x(self.x_range.max)
    else return self.compute_x(self.x_range.min);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                               Tests for "compute Δx"                                               //   
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

test "compute Δx - Positive Zero" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 10.0),
        .y_range = Range(f32).init(0.0, 0.0),
    };

    const dx = info.get_dx();

    try std.testing.expectEqual(@as(f32, 10.0), dx);
}

test "compute Δx - Positive" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(5.0, 10.0),
        .y_range = Range(f32).init(0.0, 0.0),
    };

    const dx = info.get_dx();

    try std.testing.expectEqual(@as(f32, 20.0), dx);
}

test "compute Δx - Negative Zero" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(-10.0, 0.0),
        .y_range = Range(f32).init(0.0, 0.0),
    };

    const dx = info.get_dx();

    try std.testing.expectEqual(@as(f32, 10.0), dx);
}

test "compute Δx - Negative" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(-10.0, -5.0),
        .y_range = Range(f32).init(0.0, 0.0),
    };

    const dx = info.get_dx();

    try std.testing.expectEqual(@as(f32, 20.0), dx);
}

test "compute Δx - Positive & Negative" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(-10.0, 10.0),
        .y_range = Range(f32).init(0.0, 0.0),
    };

    const dx = info.get_dx();

    try std.testing.expectEqual(@as(f32, 5.0), dx);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                               Tests for "compute Δy"                                               //   
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

test "compute Δy - Positive Zero" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 0.0),
        .y_range = Range(f32).init(0.0, 10.0),
    };

    const dy = info.get_dy();

    try std.testing.expectEqual(@as(f32, 10.0), dy);
}

test "compute Δy - Positive" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 0.0),
        .y_range = Range(f32).init(5.0, 10.0),
    };

    const dy = info.get_dy();

    try std.testing.expectEqual(@as(f32, 20.0), dy);
}

test "compute Δy - Negative Zero" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 0.0),
        .y_range = Range(f32).init(-10.0, 0.0),
    };

    const dy = info.get_dy();

    try std.testing.expectEqual(@as(f32, 10.0), dy);
}

test "compute Δy - Negative" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 0.0),
        .y_range = Range(f32).init(-10.0, -5.0),
    };

    const dy = info.get_dy();

    try std.testing.expectEqual(@as(f32, 20.0), dy);
}

test "compute Δy - Positive & Negative" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 0.0),
        .y_range = Range(f32).init(-10.0, 10.0),
    };

    const dy = info.get_dy();

    try std.testing.expectEqual(@as(f32, 5.0), dy);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                               Tests for "compute x"                                                //   
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

test "compute x - Positive Zero" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 10.0),
        .y_range = Range(f32).init(0.0, 0.0),
    };

    // start of the range
    const x_start = info.compute_x(0.0);     
    try std.testing.expectEqual(@as(f32, 0.0), x_start);

    // Middle of the range
    const x_middle = info.compute_x(5.0);     
    try std.testing.expectEqual(@as(f32, 50.0), x_middle);
    
    // End of the range
    const x_end = info.compute_x(10.0);   
    try std.testing.expectEqual(@as(f32, 100.0), x_end);
}

test "compute x - Positive" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(5.0, 10.0),
        .y_range = Range(f32).init(0.0, 0.0),
    };

    // start of the range
    const x_start = info.compute_x(5.0);     
    try std.testing.expectEqual(@as(f32, 0.0), x_start);

    // Middle of the range
    const x_middle = info.compute_x(7.5);     
    try std.testing.expectEqual(@as(f32, 50.0), x_middle);
    
    // End of the range
    const x_end = info.compute_x(10.0);   
    try std.testing.expectEqual(@as(f32, 100.0), x_end);
}

test "compute x - Negative Zero" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(-10.0, 0.0),
        .y_range = Range(f32).init(0.0, 0.0),
    };

    // start of the range
    const x_start = info.compute_x(-10.0);     
    try std.testing.expectEqual(@as(f32, 0.0), x_start);

    // Middle of the range
    const x_middle = info.compute_x(-5.0);     
    try std.testing.expectEqual(@as(f32, 50.0), x_middle);
    
    // End of the range
    const x_end = info.compute_x(0.0);   
    try std.testing.expectEqual(@as(f32, 100.0), x_end);
}

test "compute x - Negative" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(-10.0, -5.0),
        .y_range = Range(f32).init(0.0, 0.0),
    };

    // start of the range
    const x_start = info.compute_x(-10.0);     
    try std.testing.expectEqual(@as(f32, 0.0), x_start);

    // Middle of the range
    const x_middle = info.compute_x(-7.5);     
    try std.testing.expectEqual(@as(f32, 50.0), x_middle);
    
    // End of the range
    const x_end = info.compute_x(-5.0);   
    try std.testing.expectEqual(@as(f32, 100.0), x_end);
}

test "compute x - Positive & Negative" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(-10.0, 10.0),
        .y_range = Range(f32).init(0.0, 0.0),
    };

    // start of the range
    const x_start = info.compute_x(-10.0);     
    try std.testing.expectEqual(@as(f32, 0.0), x_start);

    // Middle of the range
    const x_middle = info.compute_x(0.0);     
    try std.testing.expectEqual(@as(f32, 50.0), x_middle);
    
    // End of the range
    const x_end = info.compute_x(10.0);   
    try std.testing.expectEqual(@as(f32, 100.0), x_end);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                               Tests for "compute y"                                                //   
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

test "compute y - Positive Zero" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 0.0),
        .y_range = Range(f32).init(0.0, 10.0),
    };

    // start of the range
    const y_start = info.compute_y(0.0);     
    try std.testing.expectEqual(@as(f32, 100.0), y_start);

    // Middle of the range
    const y_middle = info.compute_y(5.0);     
    try std.testing.expectEqual(@as(f32, 50.0), y_middle);
    
    // End of the range
    const y_end = info.compute_y(10.0);   
    try std.testing.expectEqual(@as(f32, 0.0), y_end);
}

test "compute y - Positive" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 0.0),
        .y_range = Range(f32).init(5.0, 10.0),
    };

    // start of the range
    const y_start = info.compute_y(5.0);     
    try std.testing.expectEqual(@as(f32, 100.0), y_start);

    // Middle of the range
    const y_middle = info.compute_y(7.5);     
    try std.testing.expectEqual(@as(f32, 50.0), y_middle);
    
    // End of the range
    const y_end = info.compute_y(10.0);   
    try std.testing.expectEqual(@as(f32, 0.0), y_end);
}

test "compute y - Negative Zero" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 0.0),
        .y_range = Range(f32).init(-10.0, 0.0),
    };

    // start of the range
    const y_start = info.compute_y(-10.0);     
    try std.testing.expectEqual(@as(f32, 100.0), y_start);

    // Middle of the range
    const y_middle = info.compute_y(-5.0);     
    try std.testing.expectEqual(@as(f32, 50.0), y_middle);
    
    // End of the range
    const y_end = info.compute_y(0.0);   
    try std.testing.expectEqual(@as(f32, 0.0), y_end);
}

test "compute y - Negative" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 0.0),
        .y_range = Range(f32).init(-10.0, -5.0),
    };

    // start of the range
    const y_start = info.compute_y(-10.0);     
    try std.testing.expectEqual(@as(f32, 100.0), y_start);

    // Middle of the range
    const y_middle = info.compute_y(-7.5);     
    try std.testing.expectEqual(@as(f32, 50.0), y_middle);
    
    // End of the range
    const y_end = info.compute_y(-5.0);   
    try std.testing.expectEqual(@as(f32, 0.0), y_end);
}

test "compute y - Positive & Negative" {
    const info = FigureInfo {
        .width = 100.0,
        .height = 100.0,
        .x_range = Range(f32).init(0.0, 0.0),
        .y_range = Range(f32).init(-10.0, 10.0),
    };

    // start of the range
    const y_start = info.compute_y(-10.0);   
    try std.testing.expectEqual(@as(f32, 100.0), y_start);

    // Middle of the range
    const y_middle = info.compute_y(0.0);     
    try std.testing.expectEqual(@as(f32, 50.0), y_middle);
    
    // End of the range
    const y_end = info.compute_y(10.0);   
    try std.testing.expectEqual(@as(f32, 0.0), y_end);
}