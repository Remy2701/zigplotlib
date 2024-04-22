const std = @import("std");

/// A range of values.
pub fn Range(comptime T: type) type {
    return struct {
        const Self = @This();

        min: T,
        max: T,

        /// Initialize a range with the given [min] and [max] values. [min; max]
        pub fn init(min: T, max: T) Self {
            return Self{
                .min = min,
                .max = max,
            };
        }

        /// Initialize a range with the minimum and maximum values set to the same value. [-∞; ∞]
        pub fn inf() Self {
            if (@typeInfo(T) != .Float) @compileError("Only floating point types can have infinite ranges");

            return Self{
                .min = -std.math.inf(T),
                .max = std.math.inf(T),
            };
        }

        /// Initialize a range with the minimum and maximum values set to the same value. [∞; -∞]
        pub fn invInf() Self {
            if (@typeInfo(T) != .Float) @compileError("Only floating point types can have infinite ranges");

            return Self{
                .min = std.math.inf(T),
                .max = -std.math.inf(T),
            };
        }

        /// Check if the range contains the given [value].
        pub fn contains(self: *const Self, value: T) bool {
            return value >= self.min and value <= self.max;
        }
    };
}
