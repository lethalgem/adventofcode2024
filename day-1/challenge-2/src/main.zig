const std = @import("std");

const ArrayList = std.ArrayList;

// 1. parse each side of the input into a list of ints
// 2. iterate through first list
// 3. for each item, find number of instances in second list
// 4. multiply item by number of instances
// 4. sum to get similarity score

pub fn main() !void {
    const similarity = try get_similarity("./input.txt");
    std.debug.print("similarity: {d} ", .{similarity});
}

fn get_similarity(comptime path: []const u8) !u32 {
    const input = @embedFile(path);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var first_locs = ArrayList(u32).init(allocator);
    defer first_locs.deinit();

    var second_locs = ArrayList(u32).init(allocator);
    defer second_locs.deinit();

    var line = std.mem.splitScalar(u8, input, '\n');
    while (line.next()) |token| {
        var location_ids = std.mem.tokenizeScalar(u8, token, ' ');

        var i: i32 = 0;
        while (location_ids.next()) |location_id| : (i += 1) {
            const id = try std.fmt.parseInt(u32, location_id, 10);

            if (@rem(i, 2) == 0) {
                try first_locs.append(id);
            } else {
                try second_locs.append(id);
            }
        }
    }

    const dumped_second_locs = try second_locs.toOwnedSlice();

    var similarity: u32 = 0;
    for (try first_locs.toOwnedSlice()) |first_loc| {
        var count: u32 = 0;

        for (dumped_second_locs) |second_loc| {
            if (first_loc == second_loc) {
                count += 1;
            }
        }

        const increase = first_loc * count;
        similarity += increase;
    }

    return similarity;
}

test "simple test" {
    const similarity = try get_similarity("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 31), similarity);
}
