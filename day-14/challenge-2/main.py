import re

class Robot:
    def __init__(self, px: int, py: int, vx: int, vy: int):
        self.px = px
        self.py = py
        self.vx = vx
        self.vy = vy
        self.quad = -1

    def add_quadrant(self, quad: int):
        self.quad = quad
    
    def debug_print(self):
        print("px: " + str(self.px))
        print("py: " + str(self.py))
        print("vx: " + str(self.vx))
        print("vy: " + str(self.vy) + "\n")
    
    def simulate(self, seconds: int, width: int, height: int):
        for _ in range(seconds):
            new_px = self.px + self.vx
            if new_px > width - 1:
                new_px = 0 + (new_px - width)
            elif new_px < 0:
                new_px = width + new_px
            self.px = new_px
            
            new_py = self.py + self.vy
            if new_py > height - 1:
                new_py = 0 + (new_py - height)
            elif new_py < 0:
                new_py = height + new_py
            self.py = new_py

def get_safety_factor(width: int, height: int, file_path: str):
    # Open and read file in data structure
    robots = []
    file = open(file_path)
    for line in file:
        match = re.search('p=(\d+),(\d+) v=(-?\d+),(-?\d+)', line)
        if match:
            robot = Robot(int(match.group(1)), int(match.group(2)), int(match.group(3)), int(match.group(4)))
            robots.append(robot)
        else:
            print("error parsing")

    find_tree_iter = False
    if find_tree_iter:
        # had to seek help for this one
        # the theory is that we repeat every 101 x 103 iterations
        # and that the outlier for the safety factor in those iterations is when the tree is formed
        did_not_find_tree = True
        safety_factors = []
        iter_count = 0
        while did_not_find_tree:
            iter_count += 1
            if iter_count > 10403:
                print("exceeded max loops")
                did_not_find_tree = False
            
            # sim one second
            quadrant_count = [0, 0, 0, 0]
            print("simulating a total of " + str(iter_count) + " seconds")  
            for robot in robots:
                robot.simulate(1, width, height)

                if robot.px < (width - 1) / 2 and robot.py < (height - 1) / 2:
                    quadrant_count[0] += 1
                    robot.add_quadrant(0)
                elif robot.px >= (width + 1) / 2 and robot.py < (height - 1) / 2:
                    quadrant_count[1] += 1
                    robot.add_quadrant(1)
                elif robot.px < (width - 1) / 2 and robot.py >= (height + 1) / 2:
                    quadrant_count[2] += 1
                    robot.add_quadrant(2)
                elif robot.px >= (width + 1) / 2 and robot.py >= (height + 1) / 2:
                    quadrant_count[3] += 1
                    robot.add_quadrant(3)
            
            safety_factor = 1
            for quad in quadrant_count:
                safety_factor *= quad

            safety_factors.append((iter_count, safety_factor))

        # find the min safety factor
        min_factor = -1
        iter_to_look_at = -1
        for (iter, safety_factor) in safety_factors:
            if min_factor == -1:
                min_factor = safety_factor
                iter_to_look_at = iter
            elif min_factor > safety_factor:
                min_factor = safety_factor
                iter_to_look_at = iter
        
        print(iter_to_look_at) # 7286

    else:
        for robot in robots:
            robot.simulate(7286, width, height)

        # debug print quadrants
        for y in range(height):
            print("")
            for x in range(width):
                robot_count = -1
                for robot in robots:
                    if (robot.px == x and robot.py == y):
                        robot_count += 1
                
                if robot_count != -1:
                    print(str(robot_count), end = "")
                else:
                    print(".", end = "")
        print("")
    
get_safety_factor(101, 103, "day-14/challenge-1/input.txt")
