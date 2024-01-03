//! Utility module to generate the points of shape (to use in a polyline)

const std = @import("std");
const Allocator = std.mem.Allocator;

/// Generate the points of a triangle (facing upwards)
pub fn triangle(allocator: Allocator, center_x: f32, center_y: f32, radius: f32) ![]f32 {
    const points = try allocator.alloc(f32, 8);
    points[0] = center_x;
    points[1] = center_y - radius;
    points[2] = center_x - radius;
    points[3] = center_y + radius;
    points[4] = center_x + radius;
    points[5] = center_y + radius;
    points[6] = points[0];
    points[7] = points[1];
    return points;
}  

// Generate the points of a rhombus (facing upwards)
pub fn rhombus(allocator: Allocator, center_x: f32, center_y: f32, radius: f32) ![]f32 {
    const points = try allocator.alloc(f32, 10);
    points[0] = center_x;
    points[1] = center_y - radius;
    points[2] = center_x - radius;
    points[3] = center_y;
    points[4] = center_x;
    points[5] = center_y + radius;
    points[6] = center_x + radius;
    points[7] = center_y;
    points[8] = points[0];
    points[9] = points[1];
    return points;
}  

/// Generate the points of a plus (+)
pub fn plus(allocator: Allocator, center_x: f32, center_y: f32, radius: f32) ![]f32 {
    const points = try allocator.alloc(f32, 26);
    points[0] = center_x - radius / 4;      // Top - Left
    points[1] = center_y - radius;     
    points[2] = center_x + radius / 4;    // Top - Right
    points[3] = center_y - radius;          
    points[4] = center_x + radius / 4;    // Inner - Top Right
    points[5] = center_y - radius / 4;      
    points[6] = center_x + radius;          // Center - Top Right
    points[7] = center_y - radius / 4;      
    points[8] = center_x + radius;          // Center - Bottom Right
    points[9] = center_y + radius / 4;
    points[10] = center_x + radius / 4;     // Inner - Bottom Right
    points[11] = center_y + radius / 4;
    points[12] = center_x + radius / 4;     // Bottom - Right
    points[13] = center_y + radius;
    points[14] = center_x - radius / 4;     // Bottom - Left
    points[15] = center_y + radius;
    points[16] = center_x - radius / 4;     // Inner - Bottom Left
    points[17] = center_y + radius / 4;
    points[18] = center_x - radius;     // Center - Bottom Left
    points[19] = center_y + radius / 4;
    points[20] = center_x - radius;     // Center - Top Left
    points[21] = center_y - radius / 4;
    points[22] = center_x - radius / 4;     // Inner - Top Left
    points[23] = center_y - radius / 4;
    points[24] = points[0];
    points[25] = points[1];
    return points;
}  

/// Generate the points of a cross (x)
pub fn cross(allocator: Allocator, center_x: f32, center_y: f32, radius: f32) ![]f32 {
    const points = try allocator.alloc(f32, 34);
    points[0] = center_x - radius;      
    points[1] = center_y - radius;     
    points[2] = center_x - radius + radius / 4;    
    points[3] = center_y - radius;          
    points[4] = center_x;    
    points[5] = center_y - radius / 4;      
    points[6] = center_x + radius - radius / 4;         
    points[7] = center_y - radius;      
    points[8] = center_x + radius;          
    points[9] = center_y - radius;
    points[10] = center_x + radius;     
    points[11] = center_y - radius + radius / 4;
    points[12] = center_x + radius / 4;     
    points[13] = center_y;
    points[14] = center_x + radius;     
    points[15] = center_y + radius - radius / 4;
    points[16] = center_x + radius;     
    points[17] = center_y + radius;
    points[18] = center_x + radius - radius / 4;     
    points[19] = center_y + radius;
    points[20] = center_x;     
    points[21] = center_y + radius / 4;
    points[22] = center_x - radius + radius / 4;     
    points[23] = center_y + radius;
    points[24] = center_x - radius;     
    points[25] = center_y + radius;
    points[26] = center_x - radius;     
    points[27] = center_y + radius - radius / 4;
    points[28] = center_x - radius / 4;     
    points[29] = center_y;
    points[30] = center_x - radius;     
    points[31] = center_y - radius + radius / 4;
    points[32] = points[0];
    points[33] = points[1];
    return points;
}  