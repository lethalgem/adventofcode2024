const std = @import("std");

const ArrayList = std.ArrayList;

// 1. Create tuple that handles first number and second number to be multiplied
// 2. parse through, character by character with order of pref -> needs m->u->l->(->number1->,->number2->)
// 3. get result on each multiple, and add to sum

pub fn main() !void {
    const sum = try get_sum("./input.txt");
    std.debug.print("sum: {d} ", .{sum});
}

fn get_sum(comptime path: []const u8) !u32 {
    const input = @embedFile(path);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var sum: u32 = 0;
    var current_command = Mul{ .allocator = allocator, .m = false, .u = false, .l = false, .o_p = false, .x = ArrayList(u8).init(allocator), .comma = false, .y = ArrayList(u8).init(allocator), .c_p = false };

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        for (line) |char| {
            const command_completed = current_command.look_for_next_char(char);
            if (try command_completed) {
                const x = try std.fmt.parseInt(u32, current_command.x.items, 10);
                const y = try std.fmt.parseInt(u32, current_command.y.items, 10);
                std.debug.print("\nfound a command multiplying {any} x {any}\n", .{ x, y });

                const product = x * y;
                sum += product;

                current_command.reset();
            }
        }
    }

    return sum;
}

// each bool represents whether we've seen it or not
const Mul = struct {
    allocator: std.mem.Allocator,
    m: bool,
    u: bool,
    l: bool,
    o_p: bool,
    x: ArrayList(u8),
    comma: bool,
    y: ArrayList(u8),
    c_p: bool,

    // consume token to create command, return whether or not command is complete
    fn look_for_next_char(self: *Mul, char: u8) !bool {
        if (char == 'm') {
            self.reset();
            self.m = true;
        } else if (self.m and char == 'u' and !self.u) {
            self.u = true;
        } else if (self.u and char == 'l' and !self.l) {
            self.l = true;
        } else if (self.l and char == '(' and !self.o_p) {
            self.o_p = true;
        } else if (self.o_p and std.ascii.isDigit(char) and !self.comma) {
            try self.x.append(char);
        } else if (self.o_p and char == ',' and !self.comma) {
            self.comma = true;
        } else if (self.comma and std.ascii.isDigit(char) and !self.c_p) {
            try self.y.append(char);
        } else if (self.comma and char == ')' and !self.c_p) {
            self.c_p = true;
        } else {
            self.reset();
        }

        return self.c_p;
    }

    fn reset(self: *Mul) void {
        self.m = false;
        self.u = false;
        self.l = false;
        self.o_p = false;
        self.x.deinit();
        self.x = ArrayList(u8).init(self.allocator);
        self.comma = false;
        self.y.deinit();
        self.y = ArrayList(u8).init(self.allocator);
        self.c_p = false;
    }
};

test "simple test" {
    const sum = try get_sum("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 161), sum);
}
