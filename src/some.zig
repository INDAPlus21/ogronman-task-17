const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;

///Did not come up with anything smart, tried to make up my own but that was hard ://
pub const SomeAllocator = struct{
    underlying: std.mem.Allocator,
    end_index: usize,
    buffer: []u8,

        pub fn init(underlying: std.mem.Allocator, buffer: []u8) !SomeAllocator {
            //Maybe got a way to make 2d-arrays with some size, lets go
            //nvm :( sad times, it is not allowed in the language, is fine i guess :/

            return SomeAllocator{
                .underlying = underlying,
                .end_index = 0,
                .buffer = buffer,
            };
        }

        pub fn allocator(self: *SomeAllocator) Allocator {
            return Allocator.init(self, alloc, resize, free);
        }   

        pub fn alloc(self: *SomeAllocator, size: usize, ptr_align: u29, len_align: u29, ra: usize)  std.mem.Allocator.Error![]u8{
            _ = len_align;
            _ = ra;
            const offset = mem.alignPointerOffset(self.buffer.ptr + self.end_index, ptr_align) orelse
                return error.OutOfMemory;
            const index = self.end_index + offset;
            const new_end_index = index + size;
            if (new_end_index > self.buffer.len) {
                return error.OutOfMemory; 
            }
            const result = self.buffer[index..new_end_index];
            self.end_index = new_end_index;

            return result;
        }

        pub fn free(self: *SomeAllocator, buf: []u8, ptr_align: u29, ret_addr: usize) void {
            _ = ptr_align;
            _ = ret_addr;
            if(self.isLastAllocation(buf)) {
                self.end_index -= buf.len;
            }
        }

        fn resize(self: *SomeAllocator, buf: []u8, ptr_align: u29, new_len: usize, len_align: u29, ret_addr: usize) ?usize {
            _ = ptr_align;
            _ = ret_addr;
        
            if(!self.isLastAllocation(buf)){
                if(new_len > buf.len) return null;
                    return mem.alignAllocLen(buf.len, new_len, len_align);
            }

            if (new_len <= buf.len){
                const sub = buf.len - new_len;
                self.end_index -= sub;
                return mem.alignAllocLen(buf.len - sub, new_len, len_align);
            }

            const add = new_len - buf.len;
            if (add+self.end_index  > self.buffer.len) return null;

            self.end_index += add;
            return new_len;
        }

        pub fn isLastAllocation(self: *SomeAllocator, buf: []u8) bool{
            return buf.ptr + buf.len == self.buffer.ptr + self.end_index;
        }

};
