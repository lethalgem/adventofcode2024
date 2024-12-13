import pandas as pd
import numpy as np

# Open and read file in data structure
garden_map = []
file = open("day-12/challenge-1/test_input_small.txt")
for line in file:
    garden_map.append(list(line.strip()))
print(garden_map)

region_info_df = pd.DataFrame()
# if we look around and see the same char, then we don't add a fence count
# if we look around and see a diff char then we add a fence count
# if we look around and see nothing (eg out of bounds) then we add a fence count
# we know we're in the same region if
#   to the left or right we see the same char
#   to the bottom or above we see the same char -- but we're traversing horizontally
#   so that means we can keep track of the locations of regions below that belong to a region and then which region to total up
#   ex. we catch scenarios like
# AAAA
# BABB
# BCCB
# By keeping track of the row below, we know there are two regions of B

for i, garden_row in enumerate(garden_map):
    print(garden_row)
    for j, plot in enumerate(garden_row):
        # count fences around current plot
        fences_around_plot = 0

        # look up
        if (i == 0):
            fences_around_plot += 1
        elif (garden_map[i - 1][j] != plot):
            fences_around_plot += 1
        
        # look left
        if (j == 0):
            fences_around_plot += 1
        elif (garden_map[i][j - 1] != plot):
            fences_around_plot += 1

        # look right
        if (j == len(garden_row) - 1):
            fences_around_plot += 1
        elif (garden_map[i][j + 1] != plot):
            fences_around_plot += 1

        # look down
        if (i == len(garden_map) - 1):
            fences_around_plot += 1
        elif (garden_map[i + 1][j] != plot):
            fences_around_plot += 1
        
        print("plot " + plot + " has " + str(fences_around_plot) + " fences around plot.")