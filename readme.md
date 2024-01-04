# Zig Plot Lib
The Zig Plot Lib is a library for plotting data in Zig. It is designed to be easy to use and to have a simple API.

**Note:** This library is still in development and is not yet ready for production use.

I'm developping this library with version 0.12.0-dev.1768+39a966b0a.

## Example

![Example Plot](out.svg)

The above plot was generated with the following code:

```zig
const std = @import("std");

const SVG = @import("svg/SVG.zig");

const Figure = @import("plot/Figure.zig");
const Line = @import("plot/Line.zig");
const Area = @import("plot/Area.zig");
const Scatter = @import("plot/Scatter.zig");

/// The function for the 1st plot (area - blue)
fn f(x: f32) f32 {
    if (x > 10.0) {
        return 20 - (2 * (x - 10.0));
    }
    return 2 * x;
}

/// The function for the 2nd plot (scatter - red)
fn f2(x: f32) f32 {
    if (x > 10.0) {
        return 10.0;
    }
    return x;
}

/// The function for the 3rd plot (line - green)
fn f3(x: f32) f32 {
    if (x < 8.0) {
        return 0.0;
    }
    return 0.5 * (x - 8.0);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    var points: [25]f32 = undefined;
    var points2: [25]f32 = undefined;
    var points3: [25]f32 = undefined;
    for (0..25) |i| {
        points[i] = f(@floatFromInt(i));
        points2[i] = f2(@floatFromInt(i));
        points3[i] = f3(@floatFromInt(i));
    }

    var figure = Figure.init(allocator, .{});
    defer figure.deinit();

    try figure.addPlot(Area {
        .y = &points,
        .style = .{
            .color = 0x0000FF,
        }
    });
    try figure.addPlot(Scatter {
        .y = &points2,
        .style = .{
            .shape = .plus,
            .color = 0xFF0000,
        }
    });
    try figure.addPlot(Line {
        .y = &points3,
        .style = .{
            .color = 0x00FF00,
        }
    });
    try figure.addPlot(Area {
        .x = &[_]f32 { -5.0, 0.0, 5.0 },
        .y = &[_]f32 { 5.0, 3.0, 5.0 },
        .style = .{
            .color = 0xFF00FF,
        }
    });
    try figure.addPlot(Area {
        .x = &[_]f32 { -5.0, 0.0, 5.0 },
        .y = &[_]f32 { -5.0, -3.0, -5.0 },
        .style = .{
            .color = 0xFFFF00,
        }
    });

    var svg = try figure.show();
    defer svg.deinit();

    // Write to an output file (out.svg)
    var file = try std.fs.cwd().createFile("out.svg", .{});
    defer file.close();

    try svg.write_to(file.writer());
}
```

## Usage

The first thing needed is to create a figure which will contain the plots.

```zig
const std = @import("std");
const Figure = @import("plot/Figure.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var figure = Figure.init(allocator, .{});
    defer figure.deinit();
}
```

The figure takes two arguments, the allocator (used to store the plot and generate the SVG) and the style for the plot. The options available for the style are:

| Option | Type | Description |
| --- | --- | --- |
| `width` | `union(enum) { pixel: f32, auto_gap: f32 }` | The width of the plot in pixels (excluding the axis and label). |
| `height` | `union(enum) { pixel: f32, auto_gap: f32 }` | The height of the plot in pixels (excluding the axis and label). |
| `plot_padding` | `f32` | The padding around the plot |
| `background_color` | `RGB (u48)` | The background color of the plot |
| `background_opacity` | `f32` | The opacity of the background |
| `value_padding` | `...` | The padding to use for the range of the plot |
| `axis` | `...` | The style for the axis |

The `value_padding` option is defined like so:
```zig
pub const ValuePercent = union(enum) {
    value: f32,
    percent: f32,
};

value_padding: struct {
    x_max: ValuePercent,
    y_max: ValuePercent,
    x_min: ValuePercent,
    y_min: ValuePercent,
},
```

The `axis` option contains more parameters:

| Option | Type | Description |
| --- | --- | --- |
| `x_range` | `?Range(f32)` | The range of values for the x axis |
| `y_range` | `?Range(f32)` | The range of values for the y axis |
| `color` | `RGB (u48)` | The color of the axis |
| `width` | `f32` | The width of the axis |
| `label_color` | `RGB (u48)` | The color of the labels |
| `label_size` | `f32` | The font size of the labels |
| `label_padding` | `f32` | The padding between the labels and the axis | 
| `label_padding` | `f32` | The padding between the labels and the axis |
| `label_font` | `[]const u8` | The font to use for the labels |
| `tick_count_x` | `...` | The number of ticks to use on the x axis |
| `tick_count_y` | `...` | The number of ticks to use on the y axis |
| `show_x_axis` | `bool` | whether to show the x axis |
| `show_y_axis` | `bool` | whether to show the y axis |
| `show_grid_x` | `bool` | whether to show the grid on the x axis |
| `show_grid_y` | `bool` | whether to show the grid on the y axis |
| `grid_opacity` | `f32` | The opacity of the grid |
| `frame_color` | `RGB (u48)` | The color of the frame |
| `frame_width` | `f32` | The width of the frame |

The `tick_count_x` and `tick_count_y` options are defined like so:
```zig
tick_count_x: union(enum) {
    count: usize,
    gap: f32,
}
```

Then you can add a plot like so (here is the example with the line plot):

```zig
const Line = @import("plot/Line.zig");
...
figure.addPlot(Line {
    .y = points,
    .style = .{
        .color = 0x0000FF,
    }
});
```

## Supported Plots

There are currently 3 types of plots supported:

### Line
The options for styling the line plot are:

| Option | Type | Description |
| --- | --- | --- |
| `color` | `RGB (u48)` | The color of the line |
| `width` | `f32` | The width of the line |
| `dash` | `?f32` | The length of the dash for the line (null means no dash)  |

### Area
The options for styling the area plot are:

| Option | Type | Description |
| --- | --- | --- |
| `color` | `RGB (u48)` | The color of the area |
| `opacity` | `f32` | The opacity of the area |
| `width` | `f32` | The width of the line (above the area) |

### Scatter

![Scatter Plot](example/out/scatter.svg)

The options for styling the scatter plot are:

| Option | Type | Description |
| --- | --- | --- |
| `color` | `RGB (u48)` | The color of the points |
| `radius` | `f32` | The radius of the points |
| `shape` | `...` | The shape of the points |

The available shapes are:

| Shape | Description |
| --- | --- |
| `circle` | A circle |
| `circle_outline` | The outline of a circle | 
| `square` | A square |
| `square_outline` | The outline of a square |
| `triangle` | A triangle (facing upwards) |
| `triangle_outline` | The outline of a triangle (facing upwards) |
| `rhombus` | A rhombus |
| `rhombus_outline` | The outline of a rhombus |
| `plus` | A plus sign |
| `plus_outline` | The outline of a plus sign |
| `cross` | A cross |
| `cross_outline` | The outline of a cross |

### Step

![Step Plot](example/out/step.svg)

The first value of the x and y arrays are used as the starting point of the plot, this means that the step will start from this point. The options for styling the step plot are:

| Option | Type | Description |
| --- | --- | --- |
| `color` | `RGB (u48)` | The color of the line |
| `width` | `f32` | The width of the line |

### Stem

![Stem Plot](example/out/stem.svg)

The options for styling the stem plot are:

| Option | Type | Description |
| --- | --- | --- |
| `color` | `RGB (u48)` | The color of the stem |
| `width` | `f32` | The width of the stem |
| `shape` | `Shape` | The shape of the points (at the end of the stem) |
| `radius` | `f32` | The radius of the points (at the end of the stem) |

## Create a new plot type
In order to create a new type of plot, all that is needed is to create a struct that contains an `interface` function, defined as follows:

```zig
pub fn interface(self: *const Self) Plot {
    ...
}
```

The `Plot` object, contains the following fields:
- a pointer to the data (`*const anyopaque`)
- a pointer to the get_range_x function `*const fn(*const anyopaque) Range(f32)`
- a pointer to the get_range_y function `*const fn(*const anyopaque) Range(f32)`
- a pointer to the draw function `*const fn(*const anyopaque, Allocator, *SVG, FigureInfo) anyerror!void`

You can look at the implementation of the `Line`, `Scatter` or `Area` plots for examples.

## Roadmap
- Ability to set the title of a plot
- Ability to set the title of the axis
- Ability to add arrows at the end of axis
- Ability to add a legend
- More plot types
    - Bar
    - Histogram
    - Logarithmic
- Spline shape for line plot
