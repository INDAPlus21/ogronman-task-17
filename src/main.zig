const std = @import("std");
const buffer = @import("buffer.zig");
const free = @import("freelist.zig");
const some = @import("some.zig");
const print = @import("std").debug.print;
const pool = @import("pool2.zig");
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});
                                                            //Dont know what to put as an allocator :/
                                                            //What the hell nothing is working


}

test "buffer test" {
    var array: [1000]u8 = undefined;
    _ = array;
    var bufferAl:buffer.BufferAllocator = try buffer.BufferAllocator.init(std.heap.page_allocator, 1000);
    const allocator = bufferAl.allocator();
    const memory = try allocator.alloc(u8,200);
        defer allocator.free(memory);



    assert(memory.len == 200);
}


//Same as buffer test ... :()
test "some test" {
    var array: [1000]u8 = undefined;
    var bufferAl:some.SomeAllocator = try some.SomeAllocator.init(std.heap.page_allocator, &array);
    const allocator = bufferAl.allocator();
    const memory = try allocator.alloc(u8,200);
        defer allocator.free(memory);



    assert(memory.len == 200);
}


test "freelist test" {
    var free_list:free.FreeList = try free.FreeList.init(std.heap.page_allocator, 1000);
    const allocator = free_list.allocator();
    const memory = try allocator.alloc(u8,200);
        defer allocator.free(memory);

    assert(memory.len == 200);
}

test "pool test" {
    comptime var total: usize = 500;
    comptime var chunk: usize = 20;
    var free_list:pool.PoolAllocator = try pool.PoolAllocator.init(std.heap.page_allocator, total, chunk);
    print("\nIs here now!\n\n", .{});
    const allocator = free_list.allocator();
    _ = allocator;
    print("\nHave passed here now!\n\n", .{});
    const memory = try allocator.alloc(u8,20);
        defer allocator.free(memory);

    assert(memory.len == 20);
}
