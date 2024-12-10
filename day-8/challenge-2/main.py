import pandas as pd
import numpy as np
import sys

np.set_printoptions(threshold=sys.maxsize)

file = open(
    "/Users/iancash/Documents/Code/adventofcode2024/day-8/challenge-2/input.txt"
)

frequencies_df = pd.DataFrame()
antinode_df = pd.DataFrame()

line_count = 0
for line in file:
    line_count += 1

    char_count = 0
    for char in line:
        char_count += 1
        if char != '.' and char !='\n':
            # print(char)
            df = pd.DataFrame({"freq": [char], "row": [line_count], "col": [char_count]})
            frequencies_df = pd.concat([frequencies_df, df], ignore_index=True)

# print(frequencies_df)

unique_frequencies = frequencies_df['freq'].unique()
# print(unique_frequencies)

for freq in unique_frequencies:
    all_freq_rows = frequencies_df.loc[frequencies_df['freq'] == freq]
    # print(all_freq_rows)

    row_count = len(all_freq_rows)
    # iterate through all possible pairs of the antenae for a particular frequency
    for i in range(row_count):
        if (i == row_count - 1):
            break

        for j in range(i + 1, row_count):
            first_freq = all_freq_rows.iloc[i]
            second_freq = all_freq_rows.iloc[j]

            row_distance = second_freq['row'] - first_freq['row']
            col_distance = second_freq['col'] - first_freq['col']

            should_place_right = True
            k = 0
            while (should_place_right):
                antinode_1 = pd.DataFrame({'freq': first_freq['freq'], 'row': [second_freq['row'] + (row_distance * k)], 'col': [second_freq['col'] + (col_distance * k)]})
                
                # check if in bounds before adding
                if antinode_1['row'].values[0] > 0 and antinode_1['row'].values[0] <= line_count and antinode_1['col'].values[0] > 0 and antinode_1['col'].values[0] <= char_count:
                    antinode_df = pd.concat([antinode_df, antinode_1], ignore_index=True)
                    k += 1
                else:
                    should_place_right = False
                    # print("out of bounds")

            should_place_left = True
            k = 0
            while(should_place_left):
                antinode_2 = pd.DataFrame({'freq': first_freq['freq'], 'row': [first_freq['row'] - (row_distance * k)], 'col': [first_freq['col'] - (col_distance * k)]})           

                if antinode_2['row'].values[0] > 0 and antinode_2['row'].values[0] <= line_count and antinode_2['col'].values[0] > 0 and antinode_2['col'].values[0] <= char_count:
                    antinode_df = pd.concat([antinode_df, antinode_2], ignore_index=True)
                    k += 1
                else:
                    should_place_left = False
                    # print("out of bounds")

            # print("----")


# create the grid to print against
rows, cols = (line_count, char_count)
grid = np.array([['.']*cols]*rows)
# print(grid)

# get unique antinode locations
antinode_df = antinode_df.drop_duplicates(subset=['row', 'col'])
# print(antinode_df)

# print grid to debug
for row in range(1, line_count + 1):
    for col in range(1, char_count + 1):
        matching_antenna = frequencies_df.query('row == @row and col == @col')
        matching_antinode = antinode_df.query('row == @row and col == @col')
        if matching_antinode.empty and matching_antenna.empty:
            print(".", end="")
        elif not matching_antinode.empty:
            print('#', end="")
            # print(matching_antinode.index.values[0], end="")
        else:
            print(matching_antenna['freq'].values[0], end="")
    print("\n", end="")

print("there are " + str(len(antinode_df)) + " unique antinode locations")