const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Ty = enum {
    int, float, string, boolean, void_,

    pub fn format(self: Ty, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.writeAll(@tagName(self));
    }
};

pub const Value = union(Ty) {
    int: i64,
    float: f64,
    string: []const u8,
    boolean: bool,
    void_: void,

    pub fn typeOf(self: Value) Ty {
        return std.meta.activeTag(self);
    }
};

pub const Token = union(enum) {
    fn_kw,
    let_kw,
    print_kw,
    ident: []const u8,
    string_lit: []const u8,
    int_lit: i64,
    lparen,
    rparen,
    lbrace,
    rbrace,
    semicolon,
    assign,
    eof,
};

pub const Lexer = struct {
    source: []const u8,
    pos: usize,
    allocator: Allocator,

    pub fn init(allocator: Allocator, source: []const u8) Lexer {
        return .{ .source = source, .pos = 0, .allocator = allocator };
    }

    pub fn tokenize(self: *Lexer) ![]Token {
        var tokens = std.ArrayList(Token).init(self.allocator);
        errdefer tokens.deinit();

        while (self.pos < self.source.len) {
            const c = self.source[self.pos];
            switch (c) {
                ' ', '\t', '\n', '\r' => self.pos += 1,
                '(' => {
                    try tokens.append(.lparen);
                    self.pos += 1;
                },
                ')' => {
                    try tokens.append(.rparen);
                    self.pos += 1;
                },
                '{' => {
                    try tokens.append(.lbrace);
                    self.pos += 1;
                },
                '}' => {
                    try tokens.append(.rbrace);
                    self.pos += 1;
                },
                ';' => {
                    try tokens.append(.semicolon);
                    self.pos += 1;
                },
                '=' => {
                    try tokens.append(.assign);
                    self.pos += 1;
                },
                '"' => {
                    self.pos += 1;
                    const start = self.pos;
                    while (self.pos < self.source.len and self.source[self.pos] != '"') {
                        self.pos += 1;
                    }
                    const s = try self.allocator.dupe(u8, self.source[start..self.pos]);
                    try tokens.append(.{ .string_lit = s });
                    self.pos += 1;
                },
                else => {
                    if (std.ascii.isAlphabetic(c) or c == '_') {
                        const start = self.pos;
                        while (self.pos < self.source.len and
                            (std.ascii.isAlphanumeric(self.source[self.pos]) or self.source[self.pos] == '_'))
                        {
                            self.pos += 1;
                        }
                        const word = self.source[start..self.pos];
                        if (std.mem.eql(u8, word, "fn")) {
                            try tokens.append(.fn_kw);
                        } else if (std.mem.eql(u8, word, "let")) {
                            try tokens.append(.let_kw);
                        } else if (std.mem.eql(u8, word, "print")) {
                            try tokens.append(.print_kw);
                        } else {
                            const s = try self.allocator.dupe(u8, word);
                            try tokens.append(.{ .ident = s });
                        }
                    } else {
                        self.pos += 1;
                    }
                },
            }
        }
        try tokens.append(.eof);
        return tokens.toOwnedSlice();
    }
};

pub const Expr = union(enum) {
    int_lit: i64,
    string_lit: []const u8,
    ident: []const u8,
};

pub const Stmt = union(enum) {
    let_stmt: struct { name: []const u8, value: Expr },
    print_stmt: Expr,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const source = "fn main() { let saluto = \"Ciao\"; print(saluto); }";
    var lexer = Lexer.init(allocator, source);
    const tokens = try lexer.tokenize();
    defer allocator.free(tokens);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Token generati: {d}\n", .{tokens.len});
}
