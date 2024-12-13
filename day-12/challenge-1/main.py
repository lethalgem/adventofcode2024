import pandas as pd
import numpy as np

# Open and read file in data structure
garden_map = []
file = open("day-12/challenge-1/input.txt")
for line in file:
    garden_map.append(list(line.strip()))
# print(garden_map)

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
# We know we're done tracking a region if we haven't seen anything to the right of below for that region

region_info_df = pd.DataFrame() # 'plot_name', 'count'
local_region_tracker = {} # {(row, col) : region_info_df_index}
for i, garden_row in enumerate(garden_map):
    for j, plot_name in enumerate(garden_row):
        # count fences around current plot
        fences_around_plot = 0

        # look up
        if (i == 0):
            fences_around_plot += 1
        elif (garden_map[i - 1][j] != plot_name):
            fences_around_plot += 1
        
        # look left
        if (j == 0):
            fences_around_plot += 1
        elif (garden_map[i][j - 1] != plot_name):
            fences_around_plot += 1

        # look right
        if (j == len(garden_row) - 1):
            fences_around_plot += 1
        elif (garden_map[i][j + 1] != plot_name):
            fences_around_plot += 1

        # look down
        if (i == len(garden_map) - 1):
            fences_around_plot += 1
        elif (garden_map[i + 1][j] != plot_name):
            fences_around_plot += 1
        
        # print("plot " + plot_name + " has " + str(fences_around_plot) + " fences around plot.")

        # track regions, we'll just look again to keep the logic separate even though it's less efficient (barely)

        # scan right and down, if same plot add to region. If we're already in that region list, then we know which one to add to
        # if we're not in the list at all, then we start a new region

        # see if we're already marked as a plot in a region and we should continue that region
        df_index = local_region_tracker.get((i, j), len(region_info_df))  
        print((i, j))

        df_row = pd.DataFrame({"plot_name": [plot_name], "area": 1, "perimeter": fences_around_plot})
        if df_index == len(region_info_df):
            # print("this location wasn't in the tracker, creating a new region")
            region_info_df = pd.concat([region_info_df, df_row], ignore_index=True)
        else:
            # print("currently tracking this region")
            df_row = region_info_df.iloc[df_index]
            region_info_df.at[df_index, "perimeter"] += fences_around_plot
        # print(df_row)

        # see if the plot below is part of the region and should be tracked
        if (i < len(garden_row) - 1):
            if garden_map[i + 1][j] == plot_name and local_region_tracker.get((i + 1, j)) is None:
                # print("looked down, updating area to " +  str(df_row['area'] + 1))
                region_info_df.at[df_index, "area"] = df_row["area"] + 1
                local_region_tracker[(i + 1, j)] = df_index
                df_row = region_info_df.iloc[df_index]

                # We're scanning down and to the right. So we can miss plots that are down and to the left
                # So if we something below us, we'll see how many contiguous plots to our left are part of the same region
                for index in range(j - 1, -1, -1):
                    # print("index: " + str(index))
                    if garden_map[i + 1][index] == plot_name and local_region_tracker.get((i + 1, index)) is None:
                        # print("looked down and to the left, updating area to " +  str(df_row['area'] + 1))
                        region_info_df.at[df_index, "area"] = df_row["area"] + 1
                        local_region_tracker[(i + 1, index)] = df_index
                        df_row = region_info_df.iloc[df_index]

        # see if we're continuing the region to the right
        if (j == len(garden_map) - 1):
            # clear the row before, to preserve memory. We only store the current garden_row and the next garden_row positions at a given time
            # we've already counted this as part of a region or started a new one, so nothing to add
            keys_to_remove = []
            for key in local_region_tracker.keys():
                if (key[0] == i - 1):
                    keys_to_remove.append(key)
            for key in keys_to_remove:
                del(local_region_tracker[key])
            # print(local_region_tracker)
        elif garden_map[i][j + 1] == plot_name and local_region_tracker.get((i, j + 1)) is None:
                # print("looked right, updating area to " + str(df_row['area'] + 1))
                region_info_df.at[df_index, "area"] = df_row["area"] + 1
                local_region_tracker[(i, j + 1)] = df_index
                df_row = region_info_df.iloc[df_index]

        # print("-----")
print(region_info_df)

# calc total price
print("calcing price")
zipped = list(zip(region_info_df["area"].values, region_info_df["perimeter"].values))
price = 0
for area, perimeter in zipped:
    price += area * perimeter
print(price)