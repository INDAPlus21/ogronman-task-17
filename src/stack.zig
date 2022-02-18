const std = @import("std");
const Allocator = std.mem.Allocator;

pub const StackAllocator = struct {
    underlying: std.mem.Allocator,
    buffer: []u8,
    current_index: usize,

    pub fn init(underlying: std.mem.Allocator, size: usize) !StackAllocator {
        return StackAllocator{
            .underlying = underlying,
            .buffer = try underlying.alloc(u8, size),
            .current_index = 0,
        };
    }

    pub fn deinit(self: StackAllocator) void {
        self.underlying.free(self.buffer);
    }

    pub fn allocator(self: *StackAllocator) Allocator {
        return Allocator.init(self, alloc, resize, free);
    }

    fn alloc(
        self: *StackAllocator,
        size: usize,
        ptr_align: u29,
        len_align: u29,
        ret_addr: usize,
    ) error{OutOfMemory}![]u8 {
        _ = len_align;

        // The return address is not needed, it can be used when detecting memory leaks (See GeneralPurposeAllocator)
        _ = ret_addr;

        // Align ptr to required pointer alignment
        const aligned_ptr = std.mem.alignForward(@ptrToInt(self.buffer.ptr) + self.current_index, ptr_align);

        // Calculate the index in the buffer of the aligned pointer
        const aligned_index = aligned_ptr - @ptrToInt(self.buffer.ptr);

        // Calculate the end index of the allocation
        const end_index = aligned_index + size;

        // If the end index is past the end of the allocator buffer return an OutOfMemory error
        if (end_index >= self.buffer.len) return error.OutOfMemory;

        // Create a slice of the allocator buffer for the allocation
        const allocation = self.buffer[aligned_index..end_index];

        // Set the current index to the end of the allocation buffer
        self.current_index = end_index;

        return allocation;
    }

    fn resize(
        self: *StackAllocator,
        buf: []u8,
        buf_align: u29,
        new_size: usize,
        len_align: u29,
        ret_addr: usize,
    ) ?usize {
        _ = self;
        _ = buf_align;
        _ = ret_addr;

        // We can't grow any allocation because we might grow into another one
        if (new_size > buf.len) return null;

        // But we can shrink the allocation easily
        return std.mem.alignAllocLen(buf.len, new_size, len_align);
    }

    // The linear allocator can't free memory
    fn free(
        self: *StackAllocator,
        buf: []u8,
        buf_align: u29,
        ret_addr: usize,
    ) void {
        _ = self;
        _ = buf_align;
        _ = ret_addr;
        _ = buf;
    }
};
