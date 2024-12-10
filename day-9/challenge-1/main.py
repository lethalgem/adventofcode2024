# parse and create the block list from the disk map
block_list = ""
id = 0
is_free_space = False
with open("day-9/challenge-1/input.txt") as file:
    for char in file.read():
        # print(char, end="")
        for i in range(int(char)):
            if is_free_space:
                block_list += "."
            else:
                block_list += str(id)
        is_free_space = not is_free_space
        if not is_free_space:
            id += 1
    # print("")

# print(block_list)

# rearrange the block list as appropriate
for i, char in enumerate(block_list):
    if char == ".":
        # see if we're at the end or not
        is_done = True
        for k in range(i, len(block_list) - 1):
            if block_list[k] != ".":
                is_done = False

        if is_done:
            break

        # find last digit from the right
        replacement_offset = 0
        for j, end_char in enumerate(reversed(block_list)):
            if end_char != ".":
                replacement_offset = j
                break
        
        # perform the swap
        char_list = list(block_list)
        char_list[i], char_list[len(block_list) - 1 - replacement_offset] = char_list[len(block_list) - 1 - replacement_offset], char_list[i],
        block_list = "".join(char_list)
        
    print(block_list)

# calc checksum
checksum = 0
for i, char in enumerate(block_list):
    # convert to digit and see if we're at end of list
    digit = 0
    try:
        digit = int(char)
    except ValueError:
        # print("found '.'")
        break

    checksum += digit * i

print(checksum)