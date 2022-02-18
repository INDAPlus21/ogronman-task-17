const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

///Not workink, kinda
//Kan allocate memory but crashes when you try to use that memory...
pub const BuddyAllocator = struct{
    underlying: std.mem.Allocator,
    size: usize,
    pair_arr: [255][255]Pair,

        pub fn init(underlying: std.mem.Allocator, size: u8) !BuddyAllocator {
            
            if (size < 255){

                const x:u8 = @floatToInt(u8,math.ceil((math.log(f32, 10, @intToFloat(f32,size)) / math.log(f32, 10, 2)))); 
                //var array: [x+1][]Pair = [][x]Pair;
                //array[x][0] = Pair.init(0, size - 1);

                _ = x;

                //Ska bara göra en 2d-array, hur svårt ska det vara?????
                //Okej sätter 2d-arrayen till en max gräns... för att får det inte att fungera..
                var array:[255][255]Pair = undefined;
                array[x][0] = try Pair.init(0, size - 1);

                return BuddyAllocator{
                    .underlying = underlying,
                    .size = size,
                    .pair_arr = array,
                };
            }else{
                std.log.info("Invalid size for allocator...", .{});
                std.process.exit(0);

            }
        }


        pub fn alloc(self: *BuddyAllocator, size: usize, ptr_align: u29, len_align: u29, ra: usize)  std.mem.Allocator.Error![]u8{

            _ = ra;
            _ = ptr_align;
            _ = len_align;

            const x:u8 = @floatToInt(u8,math.ceil((math.log(f32, 10, @intToFloat(f32,size)) / math.log(f32, 10, 2)))); 
            var i: u8 = x+1;
            var j: u8 = 1;

            var temp: Pair = Pair{
                .lower_b = 0,
                .upper_b = 0,
                .data = undefined,
            };

            if (self.pair_arr[x].len > 0){
                temp = self.pair_arr[x][0];

                for (self.pair_arr[i]) |value| {
                    if(value.upper_b == 0 ){
                        break;
                    }
                    if (j > 254){
                        break;
                    }
                    //std.log.info("{}", .{j});
                    self.pair_arr[i][j-1] = self.pair_arr[i][j];
                    j += 1;
                }
                j = 1;
                return temp.data;
            }

            //Right for loops are not nice...
            while(i < self.pair_arr[x].len()){
                if(self.pair_arr[i].len() > 0){
                    break;
                }
                if (j > 254){
                    break;
                }
                i += 1;
            }

            if (i == self.pair_arr.len()){
                return []null;
            }

            //Nvm wont work cause you have to move all of the values in the string down one step...
            //Nvm the nvm got it working.. maybe?? Havent tested it but yeah...
            temp = self.pair_arr[i][0];
            for (self.pair_arr[i]) |value| {
                if(value == null){
                    break;
                }
                if (j > 254){
                    break;
                }
                self.pair_arr[i][j-1] = self.pair_arr[i][j];
                j += 1;
            }
            j = 1;


            i -= 1;

            while(i >= x){
                
                var new_pair: Pair = Pair.init(temp.lower_b, temp.lower_b + (temp.upper_b-temp.lower_b) / 2);

                var new_pair2:Pair = Pair.init(temp.lower_b + (temp.upper_b - temp.lower_b + 1) / 2, temp.upper_b);

                self.pair_arr[i][self.pair_arr[i].len()-1] = new_pair;
                self.pair_arr[i][self.pair_arr[i].len()-1] = new_pair2;

                temp = self.pair_arr[i][0];
                for (self.pair_arr[i]) |value| {
                    if(value == null){
                        break;
                    }
                    self.pair_arr[i][j-1] = self.pair_arr[i][j];
                    j += 1;
                }
                j = 1;

                i -= 1;
            }
            return temp.data;
        }

        pub fn free(self: *BuddyAllocator, buf: []u8, ptr_align: u29, ret_addr: usize) void {
            _ = self;
            _ = buf;
            _ = ptr_align;
            _ = ret_addr;
        }

        
        pub fn allocator(self: *BuddyAllocator) Allocator {
            return Allocator.init(self, alloc, resize, free);
        }   

        fn resize(self: *BuddyAllocator, buf: []u8, ptr_align: u29, new_len: usize, len_align: u29, ret_addr: usize) ?usize {
            _ = self;
            _ = buf;
            _ = ptr_align;
            _ = new_len;
            _ = len_align;
            _ = ret_addr;
            return 0;
        }


};


pub const Pair = struct{
    lower_b: u8,
    upper_b: u8,
    data: []u8,

        pub fn init(a: u8, b: u8) !Pair{
            return Pair{
                .lower_b = a,
                .upper_b = b,
                .data = undefined,
            };
        }

};