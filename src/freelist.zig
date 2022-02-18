const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const print = @import("std").debug.print;
const assert = std.debug.assert;


//Before implementing a poolAllocator or memory pool
// It would have probably been smart to do a freeList, however
// I am doing that now, and will maybe (Doubt it maybe some day) add a correct implementation of a memory pool

pub const FreeList = struct{
    underlying: std.mem.Allocator,
    nodes: std.TailQueue([]u8),

    
    const Fnode = std.TailQueue([]u8).Node;

        pub fn init(underlying: std.mem.Allocator, comptime size: usize) !FreeList {

            const heap = try underlying.alloc(u8, size);
            //You have to ignore the first few values since that is used for the heap, "remove"/ignore the size of one node
            const buffer = heap[@sizeOf(Fnode)..];

            var free_arr = @as(std.TailQueue([]u8), .{});
            const free_n = @ptrCast(*Fnode, @alignCast(@alignOf(Fnode), buffer.ptr));

            free_n.* = Fnode{
                .data = buffer,
            };
            
            free_arr.prepend(free_n);
            //Prints memory address to console of the buffer
            print("\nMemory adress/ptr of buffer: {any}\n\n\n", .{@alignCast(@alignOf(Fnode), buffer.ptr)});
            return FreeList{
                .underlying = underlying,
                .nodes = free_arr,
            };
        }

        pub fn allocator(self: *FreeList) Allocator {
            return Allocator.init(self, alloc, resize, free);
        }   

        pub fn alloc(self: *FreeList, size: usize, ptr_align: u29, len_align: u29, ra: usize)  std.mem.Allocator.Error![]u8{
            _ = len_align;
            _ = ra;

            if (self.has_space(size)) |space|{
                const ptr = mem.alignForward(@ptrToInt(space.ptr),ptr_align);
                const index = ptr - @ptrToInt(space.ptr);
                const end_index = index + size;
                const result = space[index..end_index];
                self.add_node(space[end_index..]);

                return result;
            }else{
                return error.OutOfMemory;
            }


        }

        fn add_node(self: *FreeList, buffer: []u8) void{
            const ptr = mem.alignForward(@ptrToInt(buffer.ptr),@alignOf(Fnode));
            const index = ptr - @ptrToInt(buffer.ptr);
            const new_n = @ptrCast(*Fnode, @alignCast(@alignOf(Fnode), buffer[index..]));
            new_n.* = Fnode{
                .data = buffer,
            };
            self.nodes.append(new_n);
            //Apparently the insertAfter and findLast are for nodes() and not the list...
            //And get error "type '?*std.linked_list.Node' does not support field access"
            //Do not know
                //var firstN = self.nodes.first;
                //firstN.insertAfter(Fnode.findLast(), new_n);
            
        }

        fn has_space(self: *FreeList, size: usize) ?[]u8{
            var x = self.nodes.first;
            //Killen har no mercy i github issue kommentarerna..
            //Vilket betyder ingen for-loop, bara whiiiile
            while (x) |node| : (x = node.next)  {
                if(node.data.len >= size){
                    self.nodes.remove(node);
                    return node.data;
                }
            }
            return null;
        }

        pub fn free(self: *FreeList, buf: []u8, ptr_align: u29, ret_addr: usize) void {
            _ = ptr_align;
            _ = ret_addr;

            self.add_node(buf);

        }

        fn resize(self: *FreeList, buf: []u8, ptr_align: u29, new_len: usize, len_align: u29, ret_addr: usize) ?usize {
            _ = self;
            _ = buf;
            _ = ptr_align;
            _ = new_len;
            _ = len_align;
            _ = ret_addr;
            return 0;
        }


};

//Försökte göra en linkedlist från grunden upp... Gick sådär
pub const Header = struct{
    size: usize,
    next: *?Header,
    prior: *?Header,
};
