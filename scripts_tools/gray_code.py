def int2binlist(int_val : int, width : int):
    binary_list =  list(bin(int_val))[2:]
    binary_list = [ int(j) for j in  binary_list]
    if width < len(binary_list):
        print("warning: defined width is shorter than the value")
    else:
        for i in range (width - len(binary_list)):
            binary_list = [0] +  binary_list
    return binary_list

def binlist2int(binlist : list):
    binlist = "".join([str(j) for j in  binlist])
    return int(binlist,2)

def gray_decode(gray_code : int, width : int):
    gray_list = int2binlist(gray_code, width)
    int_list = []
    for i in range(len(gray_list)):
        if (i==0):
            int_last_bit = gray_list[0]
            int_list.append(int_last_bit)
        else:
            int_last_bit = int_list[-1]
            int_current_bist = gray_list[i] ^ int_last_bit
            int_list.append(int_current_bist)
    return binlist2int(int_list)

def gray_encode(int_code : int, width : int):
    bin_list = int2binlist(int_code, width)
    bin_list_shift = [0] + bin_list[0:-1]
    gray_list = []
    for i in range(len(bin_list)):
        gray_list.append(bin_list[i] ^ bin_list_shift[i])
    return binlist2int(gray_list)

def binary_format(int_val : int, width : int):
    binlist_str = "".join([str(j) for j in  int2binlist(int_val, width)])
    return binlist_str

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='gray code encode/decode')
    parser.add_argument('--encode', type=int)
    parser.add_argument('--decode', type=int)
    parser.add_argument('--width', type=int, default=4)
    parser.add_argument('--encode_serial', nargs="+",type=int)
    parser.add_argument('--binformat', action="store_true")
    args = parser.parse_args()
    
    if (args.encode != None):
        int_code = args.encode
        gray_code = gray_encode(int_code, args.width)
        if args.binformat:
            print("encode %s  --> %s  (width = %d)" %(binary_format(int_code, args.width), binary_format(gray_code, args.width), args.width))
        else:
            print("encode %d  --> %d  (width = %d)" %(int_code, gray_code, args.width))
    elif (args.decode != None):
        gray_code = args.decode
        int_code = gray_decode(gray_code, args.width)
        if args.binformat:
            print("decode %s  --> %s  (width = %d)" %(binary_format(gray_code, args.width), binary_format(int_code, args.width), args.width))
        else:
            print("decode %d  --> %d  (width = %d)" %(gray_code, int_code, args.width))
    elif (args.encode_serial != None):
        index = 0
        for int_code in args.encode_serial:
            gray_code = gray_encode(int_code, args.width)
            if args.binformat:
                print("%3d,encode %s  --> %s  (width = %d)" %(index, binary_format(int_code, args.width), binary_format(gray_code, args.width), args.width))
            else:
                print("%3d,encode %d  --> %d  (width = %d)" %(index, int_code, gray_code, args.width))
            index = index + 1

