const std = @import("std");

const ArrayList = std.ArrayList;

// 1. parse each side of the input into a list of ints
// 2. sort list from min to max
// 3. compare each item in list and sub to get distances
// 4. sum

pub fn main() !void {
    const sum = try get_sum("./test_input.txt");
    std.debug.print("sum: {d} ", .{sum});
}

fn get_sum(comptime path: []const u8) !u32 {
    const input = @embedFile(path);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var first_locs = ArrayList(i32).init(allocator);
    defer first_locs.deinit();

    var second_locs = ArrayList(i32).init(allocator);
    defer second_locs.deinit();

    var line = std.mem.splitScalar(u8, input, '\n');
    while (line.next()) |token| {
        var location_ids = std.mem.tokenizeScalar(u8, token, ' ');

        var i: i32 = 0;
        while (location_ids.next()) |location_id| : (i += 1) {
            const id = try std.fmt.parseInt(i32, location_id, 10);

            if (@rem(i, 2) == 0) {
                try first_locs.append(id);
            } else {
                try second_locs.append(id);
            }
        }
    }

    const sorted_first_locs = try first_locs.toOwnedSlice();
    std.mem.sort(i32, sorted_first_locs, {}, comptime std.sort.asc(i32));

    const sorted_second_locs = try second_locs.toOwnedSlice();
    std.mem.sort(i32, sorted_second_locs, {}, comptime std.sort.asc(i32));

    var sum: u32 = 0;
    for (sorted_first_locs, sorted_second_locs) |first_loc, second_loc| {
        const distance: u32 = @abs(first_loc - second_loc);
        sum += distance;
    }

    return sum;
}

test "simple test" {
    const sum = try get_sum("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 11), sum);
}
