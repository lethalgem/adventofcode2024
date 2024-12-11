def get_new_carving(str):
    final_carving = ""
    for i, char in enumerate(str):
        if char != "0" or i != len(str):
            final_carving += char
    return int(final_carving)

file = open("day-11/challenge-1/input.txt")
stone_list = [int(x) for x in file.read().split()]

amount_of_blinks = 25
for blink in range(amount_of_blinks):
    # print("blinking")
    new_stone_list = []
    for carving in stone_list:
        # print("looking at carving: " + str(carving))
        if carving == 0:
            new_stone_list.append(1)
        elif int(len(str(carving))) % 2 == 0:
            carving_str = str(carving)
            halfway_loc = int(len(carving_str) / 2)
            left_carving = get_new_carving(carving_str[0:halfway_loc])
            right_carving = get_new_carving(carving_str[halfway_loc:len(carving_str)])

            new_stone_list.append(left_carving)
            new_stone_list.append(right_carving)
        else:
            new_stone_list.append(carving * 2024)

    stone_list = new_stone_list

print(stone_list)
print(len(stone_list))