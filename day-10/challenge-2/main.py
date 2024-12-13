import numpy as np
import pandas as pd

# parse and create traversable array
list = []
with open("day-10/challenge-2/input.txt") as file:
    for line in file:
        line_list = []
        for char in line:
            if char == ".":
                line_list.append(-1)
            elif char == "\n":
                break
            else:
                line_list.append(int(char))
        list.append(line_list)

topomap = np.array(list)
# print(topomap)

trailheads = np.asarray(np.where(topomap == 0)).T
# print(trailheads)

trailheads_df = pd.DataFrame(trailheads, columns=['row', 'col'])
trailheads_df['score'] = 0
# print(trailheads_df)

# traverse
for i in range(len(trailheads_df)): # apparently we shouldn't iterate over a dataframe. too late
    trailhead = trailheads_df.iloc[i]
    # print(trailhead)

    # look at adjacent paths
    next_paths = pd.DataFrame({'row': [trailhead['row']], 'col': [trailhead['col']], 'value': 0})
    # print(next_paths)

    located_peaks = pd.DataFrame({'row': [-1], 'col': [-1]})

    for look_for in range(1, 10):
        paths_to_check = next_paths[next_paths['value'] == look_for - 1]

        for index, current_loc in paths_to_check.iterrows():
            look_at_row = current_loc['row'] - 1
            look_at_col = current_loc['col']
            if look_at_row >= 0:
                adjacent_path = topomap[look_at_row][look_at_col]
                if adjacent_path == look_for:
                    loc_peaks = np.array([look_at_row, look_at_col])
                    df = pd.DataFrame({'row': [look_at_row], 'col': [look_at_col], 'value': [adjacent_path]})
                    next_paths = pd.concat([next_paths, df], ignore_index=True)
                    if adjacent_path == 9:
                        df2 = pd.DataFrame({'row': [look_at_row], 'col': [look_at_col]})
                        located_peaks = pd.concat([located_peaks, df2], ignore_index=True)

            look_at_row = current_loc['row']
            look_at_col = current_loc['col'] + 1
            if look_at_col < topomap.shape[1]:
                adjacent_path = topomap[look_at_row][look_at_col]
                if adjacent_path == look_for:
                    loc_peaks = np.array([look_at_row, look_at_col])
                    df = pd.DataFrame({'row': [look_at_row], 'col': [look_at_col], 'value': [adjacent_path]})
                    next_paths = pd.concat([next_paths, df], ignore_index=True)
                    if adjacent_path == 9:
                        df2 = pd.DataFrame({'row': [look_at_row], 'col': [look_at_col]})
                        located_peaks = pd.concat([located_peaks, df2], ignore_index=True)

            look_at_row = current_loc['row'] + 1
            look_at_col = current_loc['col']
            if look_at_row < topomap.shape[0]:
                adjacent_path = topomap[look_at_row][look_at_col]
                if adjacent_path == look_for:
                    loc_peaks = np.array([look_at_row, look_at_col])
                    df = pd.DataFrame({'row': [look_at_row], 'col': [look_at_col], 'value': [adjacent_path]})
                    next_paths = pd.concat([next_paths, df], ignore_index=True)
                    if adjacent_path == 9:
                        df2 = pd.DataFrame({'row': [look_at_row], 'col': [look_at_col]})
                        located_peaks = pd.concat([located_peaks, df2], ignore_index=True)
            
            look_at_row = current_loc['row']
            look_at_col = current_loc['col'] - 1
            if look_at_col >= 0:
                adjacent_path = topomap[look_at_row][look_at_col]
                if adjacent_path == look_for:
                    loc_peaks = np.array([look_at_row, look_at_col])
                    df = pd.DataFrame({'row': [look_at_row], 'col' : [look_at_col], 'value': [adjacent_path]})
                    next_paths = pd.concat([next_paths, df], ignore_index=True)
                    if adjacent_path == 9:
                        df2 = pd.DataFrame({'row': [look_at_row], 'col' : [look_at_col]})
                        located_peaks = pd.concat([located_peaks, df2], ignore_index=True)

    trailheads_df.at[i, 'score'] = len(next_paths[next_paths['value'] == 9])

# sum scores
print("score: " + str(trailheads_df['score'].sum()))