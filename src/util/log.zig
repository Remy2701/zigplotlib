/// A ghost logger used for testing to ignore any outputs
pub const GhostLogger = struct {
    pub fn err(
        comptime format: []const u8,
        args: anytype,
    ) void {
        _ = format;
        _ = args;
    }

    pub fn warn(
        comptime format: []const u8,
        args: anytype,
    ) void {
        _ = format;
        _ = args;
    }

    pub fn info(
        comptime format: []const u8,
        args: anytype,
    ) void {
        _ = format;
        _ = args;
    }

    pub fn debug(
        comptime format: []const u8,
        args: anytype,
    ) void {
        _ = format;
        _ = args;
    }
};
