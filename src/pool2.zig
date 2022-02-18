const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const print = @import("std").debug.print;


///TODO?
// 1. Make size bigger so nodes can actually be in the list ://
// 2. Get data out from the nodes (?)
// 3. Maybe done?

pub const PoolAllocator = struct{
    underlying: std.mem.Allocator,
    freeList: std.TailQueue([]u8),
    chunk_size: usize,
    total_size: usize,
    used: usize,
    peak: usize,
    start_ptr: []u8,
    
    const Fnode = std.TailQueue([]u8).Node;

        pub fn init(underlying: std.mem.Allocator, comptime total: usize, comptime chunk_size: usize) !PoolAllocator {

            if(total % chunk_size != 0){
                print("\nTotal size must be multiple of chunk size\n", .{});
                std.process.exit(0);
            }

            const nChunk = total/chunk_size;

            var newTotal = total + @sizeOf(Fnode)*nChunk;

            const buffer = try underlying.alloc(u8, newTotal);
            //print("\n\n\nThe heap contains... {any}\n\n\n", .{heap});
            //You have to ignore the first few values since that is used for the heap, "remove"/ignore the size of one node
            //const buffer = heap[@sizeOf(Fnode)..];
            print("\n\n\nThe buffer contains... {any}\n\n\n", .{buffer});

            var free_arr = @as(std.TailQueue([]u8), .{});
            //const free_n = @ptrCast(*Fnode, @alignCast(@alignOf(Fnode), buffer.ptr));

            //free_n.* = Fnode{
                //.data = buffer,
            //};
            

            var pool =  PoolAllocator{
                .underlying = underlying,
                .freeList = free_arr,
                .chunk_size = chunk_size,
                .total_size = total,
                .used = 0,
                .peak = 0,
                .start_ptr = buffer,
            };
            pool.reset();
            return pool;
        }

        pub fn allocator(self: *PoolAllocator) Allocator {
            return Allocator.init(self, alloc, resize, free);
        }   

        //Think i got the init to work... Now i just have to make the alloc() work too...
            //Nvm prepended instead of appending... my bad
        pub fn alloc(self: *PoolAllocator, size: usize, ptr_align: u29, len_align: u29, ra: usize)  std.mem.Allocator.Error![]u8{   
            _ = ptr_align;
            _ = len_align;
            _ = ra;
            if(size == self.chunk_size){
                const free_pos = self.freeList.pop();
                //Where did all of the zeros come from????
                print("I think this is what crashes... \n{any}", .{free_pos});
                self.used += self.chunk_size;
                self.peak = @maximum(self.peak, self.used);
                //Now I just have to understand how to get the data out from the node...
                return error.OutOfMemory;
            }else{
                return error.OutOfMemory; 
            }
        }

        fn reset(self: *PoolAllocator) void {
            self.used = 0;
            self.peak = 0;

            const nChunks: usize = self.total_size/self.chunk_size;

            var i: usize = 0;

            while(i < nChunks){

                //This is big spaghetti right now, and just a complete mess but it starting to work (maybe)
                
                //const ptr = self.start_ptr.data.ptr + i * self.chunk_size;
                //print("\n\n\nThe 11 buffer contains... {any}\n\n\n", .{self.start_ptr});
                const ptr = mem.alignForward(@ptrToInt(self.start_ptr.ptr + i * self.chunk_size),@alignOf(Fnode));
                //print("\n\n\nThe 22 buffer contains... {any}\n\n\n", .{self.start_ptr});
                print("\n\n\nPtr is: {any}\n\n\n", .{ptr});
               
                //Varför försvinner self.start_ptr.data :((((
                    //Den blir bara result, vilket inte är så nice
                        //Den ska fortsätta vara samma :(((
                            //Feels bad
                const index = ptr - @ptrToInt(self.start_ptr.ptr);
                print("\n\n\n Index is: {any}\n\n\n", .{index});
                //print("\n\n\nThe 33 buffer contains... {any}\n\n\n", .{self.start_ptr});
                const end_index = index + self.chunk_size + @sizeOf(Fnode);
                //print("\n\n\nThe 44 buffer contains... {any}\n\n\n", .{self.start_ptr});
                var result = self.start_ptr[index..end_index];
                //print("\n\n\nThe 55 buffer contains... {any}\n\n\n", .{self.start_ptr});
                //print("\n\n\nThe result contains after... {any}\n\n\n", .{result});
                const new = @ptrCast(*Fnode, @alignCast(@alignOf(Fnode), result));
                //print("\n\n\nThe 66 buffer contains... {any}\n\n\n", .{self.start_ptr});
                //Här försvinner start_ptr.data av någon anledning
                //Overrider det här den för att jag har använt en ptr till den?
                new.* = Fnode{
                    .data = result,
                };
                //print("\n\n\nThe 77 buffer contains... {any}\n\n\n", .{self.start_ptr});
                print("\n\n\n{any}\n\n\n", .{new}); 
                
                print("\n\n\nThe 88 buffer contains... {any}\n\n\n", .{self.start_ptr});
                self.freeList.append(new);
                //print("\n\n\n{any}\n\n\n", .{self.freeList});
                //print("\n\n\nThe buffer contains after... {any}\n\n\n", .{self.start_ptr.data});
                i += 1;
                print("\n\n\n Number is: {any}\n", .{i}); 
                print("\n Go to: {any}\n\n\n", .{nChunks}); 
                if(i == nChunks){
                    print("\n Will break now\n\n\n", .{});
                    break;
                }
            } 
            print("\nHas finished\n\n", .{});
        }

        fn add_node(self: *PoolAllocator, buffer: []u8) void{
            const ptr = mem.alignForward(@ptrToInt(buffer.ptr),@alignOf(Fnode));
            const index = ptr - @ptrToInt(buffer.ptr);
            const new_n = @ptrCast(*Fnode, @alignCast(@alignOf(Fnode), buffer[index..]));
            new_n.* = Fnode{
                .data = buffer,
            };
            self.freeList.append(new_n);
        }

        pub fn free(self: *PoolAllocator, buf: []u8, ptr_align: u29, ret_addr: usize) void {
            _ = ptr_align;
            _ = ret_addr;

            self.used -= self.chunk_size;
            self.add_node(buf);
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


