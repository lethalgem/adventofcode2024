import re

class ClawMachine:
    def __init__(self, a_x: int, a_y: int, b_x: int, b_y: int, p_x: int, p_y: int):
        self.a_x = a_x
        self.a_y = a_y
        self.b_x = b_x
        self.b_y = b_y
        self.p_x = p_x
        self.p_y = p_y
    
    def debug_print(self):
        print("a_x: " + str(self.a_x))
        print("a_y: " + str(self.a_y))
        print("b_x: " + str(self.b_x))
        print("b_y: " + str(self.b_y))
        print("p_x: " + str(self.p_x))
        print("p_y: " + str(self.p_y) + "\n")


def get_tokens(file_path: str):
    # Open and read file in data structure
    claw_machines = []
    file = open(file_path)
    button = 0 # 0 = x, 1 = y
    a_x = -1
    a_y = -1
    b_x = -1
    b_y = -1
    p_x = -1
    p_y = -1
    for line in file:
        button_match = re.search('X\+(\d+), Y\+(\d+)', line)
        if button_match and button == 0:
            a_x = int(button_match.group(1))
            a_y = int(button_match.group(2))
            button = 1
        elif button_match and button == 1:
            b_x = int(button_match.group(1))
            b_y = int(button_match.group(2))
            button = 0
        
        prize_location_match = re.search('X=(\d+), Y=(\d+)', line)
        if prize_location_match:
            p_x = int(prize_location_match.group(1)) + 10000000000000
            p_y = int(prize_location_match.group(2)) + 10000000000000
            
            # sanity check
            if a_x == -1 or a_y == -1 or b_x == -1 or b_y == -1 or p_x == -1 or p_y == -1:
                print("error parsing")
                return 0

            claw_machine = ClawMachine(a_x, a_y, b_x, b_y, p_x, p_y)
            # claw_machine.debug_print()
            claw_machines.append(claw_machine)

    total_tokens = 0
    for claw_machine in claw_machines:
        # a_x * a_pushes + b_x * b_pushes = p_x
        # a_y * a_pushes + b_y * b_pushes = p_y

        # claw_machine.debug_print()
        b_pushes = round((int(claw_machine.p_y) - int(claw_machine.a_y) * int(claw_machine.p_x) / int(claw_machine.a_x)) / (int(claw_machine.b_y) - int(claw_machine.a_y) * int(claw_machine.b_x) / int(claw_machine.a_x)))
        # print(b_pushes)

        a_pushes = round((int(claw_machine.p_x) - int(claw_machine.b_x) * int(b_pushes)) / int(claw_machine.a_x))
        # print(a_pushes)

        # sanity check
        p_x = int(claw_machine.a_x) * a_pushes + int(claw_machine.b_x) * b_pushes
        p_y = int(claw_machine.a_y) * a_pushes + int(claw_machine.b_y) * b_pushes
        if p_x != int(claw_machine.p_x) or p_y != int(claw_machine.p_y):
            continue

        button_a_cost = 3
        button_b_cost = 1
        tokens = a_pushes * button_a_cost + b_pushes * button_b_cost
        # print(tokens)

        total_tokens += tokens

    print(total_tokens)

    return total_tokens != 0

tokens = get_tokens("day-13/challenge-2/input.txt")
