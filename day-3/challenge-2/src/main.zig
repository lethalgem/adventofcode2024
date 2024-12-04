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
    var do_command = Do{ .d = false, .o = false, .o_p = false, .c_p = false };
    var dont_command = Dont{ .d = false, .o = false, .n = false, .apostrophe = false, .t = false, .o_p = false, .c_p = false };
    var commands_enabled = true;

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        for (line) |char| {
            if (commands_enabled) {
                const dont_command_completed = dont_command.look_for_next_char(char);
                if (dont_command_completed) {
                    commands_enabled = false;
                    dont_command.reset();
                    std.debug.print("\nfound a don't command\n", .{});
                }

                const command_completed = current_command.look_for_next_char(char);
                if (try command_completed) {
                    const x = try std.fmt.parseInt(u32, current_command.x.items, 10);
                    const y = try std.fmt.parseInt(u32, current_command.y.items, 10);
                    std.debug.print("\nfound a command multiplying {any} x {any}\n", .{ x, y });

                    const product = x * y;
                    sum += product;

                    current_command.reset();
                }
            } else {
                const do_command_completed = do_command.look_for_next_char(char);
                if (do_command_completed) {
                    commands_enabled = true;
                    do_command.reset();
                    std.debug.print("\nfound a do command\n", .{});
                }
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

const Do = struct {
    d: bool,
    o: bool,
    o_p: bool,
    c_p: bool,

    fn look_for_next_char(self: *Do, char: u8) bool {
        if (char == 'd') {
            self.reset();
            self.d = true;
        } else if (self.d and char == 'o' and !self.o) {
            self.o = true;
        } else if (self.o and char == '(' and !self.o_p) {
            self.o_p = true;
        } else if (self.o_p and char == ')' and !self.c_p) {
            self.c_p = true;
        } else {
            self.reset();
        }

        return self.c_p;
    }

    fn reset(self: *Do) void {
        self.d = false;
        self.o = false;
        self.o_p = false;
        self.c_p = false;
    }
};

const Dont = struct {
    d: bool,
    o: bool,
    n: bool,
    apostrophe: bool,
    t: bool,
    o_p: bool,
    c_p: bool,

    fn look_for_next_char(self: *Dont, char: u8) bool {
        if (char == 'd') {
            self.reset();
            self.d = true;
        } else if (self.d and char == 'o' and !self.o) {
            self.o = true;
        } else if (self.o and char == 'n' and !self.n) {
            self.n = true;
        } else if (self.n and char == '\'' and !self.apostrophe) {
            self.apostrophe = true;
        } else if (self.apostrophe and char == 't' and !self.t) {
            self.t = true;
        } else if (self.t and char == '(' and !self.o_p) {
            self.o_p = true;
        } else if (self.o_p and char == ')' and !self.c_p) {
            self.c_p = true;
        } else {
            self.reset();
        }

        return self.c_p;
    }

    fn reset(self: *Dont) void {
        self.d = false;
        self.o = false;
        self.n = false;
        self.apostrophe = false;
        self.t = false;
        self.o_p = false;
        self.c_p = false;
    }
};

test "simple test" {
    const sum = try get_sum("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 48), sum);
}
