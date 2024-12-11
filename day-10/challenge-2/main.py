import numpy as np

# parse and create the block list from the disk map
initial_list = []
id = 0
is_free_space = False
with open("day-9/challenge-1/test_input_2.txt") as file:
    for char in file.read():
        # print(char, end="")
        for i in range(int(char)):
            if is_free_space:
                initial_list.append(-1) # represents '.'
            else:
                initial_list.append(id)
        is_free_space = not is_free_space
        if not is_free_space:
            id += 1
    # print("")

block_list = np.array(initial_list)

def print_block_list(list):
    for num in list:
        if num == -1:
            print(".", end="")
        else:
            print(num, end="")
        print(" ", end="")
    print("")

# print_block_list(block_list)

# rearrange the block list as appropriate
for i, num in enumerate(block_list):
    if num == -1:
        # see if we're at the end or not
        is_done = True
        for k in range(i, len(block_list) - 1):
            if block_list[k] != -1:
                is_done = False

        if is_done:
            break

        # find last digit from the right
        replacement_offset = 0
        for j, num_from_end in enumerate(reversed(block_list)):
            if num_from_end != -1:
                replacement_offset = j
                break
        
        # perform the swap
        print("performing a swap")
        block_list[i], block_list[len(block_list) - 1 - replacement_offset] = block_list[len(block_list) - 1 - replacement_offset], block_list[i],
        
# print_block_list(block_list)

print("going to calc checksum")

# calc checksum
checksum = 0
for i, num in enumerate(block_list):
    if num == -1:
        break

    checksum += num * i

print(checksum)