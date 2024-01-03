/// A range of values.
pub fn Range(comptime T: type) type {
    return struct {
        const Self = @This();

        min: T,
        max: T,

        pub fn init(min: T, max: T) Self {
            return Self {
                .min = min,
                .max = max,
            };
        }

        pub fn contains(self: *const Self, value: T) bool {
            return value >= self.min and value <= self.max;
        }
    };
}