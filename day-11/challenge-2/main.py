import collections

def get_new_carving(str):
    final_carving = ""
    for i, char in enumerate(str):
        if char != "0" or i != len(str):
            final_carving += char
    return int(final_carving)

def update_stone_dict(dict: dict, carving, increased_count):
    dict[carving] = dict.get(carving, 0) + increased_count

file = open("day-11/challenge-2/input.txt")
initial_stone_list = [int(x) for x in file.read().split()]

amount_of_blinks = 75
# order doesn't matter, only the total number of stones based on the number carved into the stone
stone_dict = collections.Counter(initial_stone_list) # carving: count
# print(stone_dict)

for blink in range(amount_of_blinks):
    print("blinking: " + str(blink))
    # print(stone_dict)
    
    # can't modify a dict while iterating through it, so use a copy
    updated_stone_dict = {}
    for carving in stone_dict.keys():
        # print("looking at carving: " + str(carving))
        current_count = stone_dict[carving]
        if carving == 0:
            update_stone_dict(updated_stone_dict, 1, current_count)
        elif int(len(str(carving))) % 2 == 0:
            carving_str = str(carving)
            halfway_loc = int(len(carving_str) / 2)
            left_carving = get_new_carving(carving_str[0:halfway_loc])
            right_carving = get_new_carving(carving_str[halfway_loc:len(carving_str)])

            update_stone_dict(updated_stone_dict, left_carving, current_count)
            update_stone_dict(updated_stone_dict, right_carving, current_count)
        else:
            update_stone_dict(updated_stone_dict, carving * 2024, current_count)

    stone_dict = updated_stone_dict

print(stone_dict)
print(sum(stone_dict.values()))