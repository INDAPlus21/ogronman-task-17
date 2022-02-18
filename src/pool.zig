const std = @import("std");
const Allocator = std.mem.Allocator;

//Not working, not done dunno what to do with this one...
pub const PoolAllocator = struct{
    underlying: std.mem.Allocator,
    ck_per_block: usize,
    mAlloc: ?*Chunk,

        pub fn init(underlying: std.mem.Allocator, chunk_size: usize) !PoolAllocator {
            return PoolAllocator{
                .underlying = underlying,
                .ck_per_block = chunk_size,
                .mAlloc = null,
            };
        }

        pub fn allocator(self: *PoolAllocator) Allocator {
            return Allocator.init(self, alloc, resize, free);
        }   

        pub fn alloc(self: *PoolAllocator, size: usize, ptr_align: u29, len_align: u29, ra: usize)  std.mem.Allocator.Error![]u8{
            _ = len_align;
            _ = ra;
            _ = ptr_align;

            if (self.mAlloc == null) {
                self.mAlloc = try allocateBlock(self, size);
            }


            //?????
            var free_chunk: *Chunk = self.mAlloc;
            
            self.mAlloc = self.mAlloc.next;
            
            return free_chunk;
        }

        //Will give up if i have to do this...
            // comptime can't really do reinterpret casting yet,
            // so we need to write the bytes manually.
            //for (hashes_bytes[i * @sizeOf(HashResult) ..][0..@sizeOf(HashResult)]) |*byte| {
                //byte.* = @truncate(u8, h);
                //h = h >> 8;   
            //}

        fn allocateBlock(self: *PoolAllocator, chunk_size: usize) !Chunk{

            var block_size: usize = self.ck_per_block * chunk_size;

            const a : []u8 = try self.underlying.alloc(u8, block_size);
            var block_begin: Chunk = Chunk{
                .next = null,
                .data = a,
            };
            var chunk: Chunk = block_begin;

            //Why are for loops so complicated???????????
                        //for (0...ck_per_block-1) {
                //chunk.next = @as(char, chunk) + chunk_size;
                //chunk = chunk.next;
            //}

            //Fu*k for-loops apparently
            var i: usize = 0;
            while (i < self.ck_per_block-1){
                
                chunk.next = @intToPtr(*Chunk, @ptrToInt(chunk) + chunk_size);
                chunk = chunk.next;
                i += 1;
            }


            chunk.next = null;

            return block_begin;

        }

        pub fn free(self: *PoolAllocator, buf: []u8, ptr_align: u29, ret_addr: usize) void {
            _ = ptr_align;
            _ = ret_addr;
            _ = buf;
            self.underlying.free(buf);
        }

    fn resize(self: *PoolAllocator, buf: []u8, ptr_align: u29, new_len: usize, len_align: u29, ret_addr: usize) ?usize {
        _ = self;
        _ = buf;
        _ = ptr_align;
        _ = new_len;
        _ = len_align;
        _ = ret_addr;
        return 0;
    }

};

pub const Chunk = struct{
    next: ?*Chunk,
    data: []u8,
};