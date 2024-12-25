import main

def test():
    assert main.get_tokens("day-13/challenge-2/test_input_one_machine.txt") == True

def test_2():
    assert main.get_tokens("day-13/challenge-2/test_input_one_machine_2.txt") == True

def test_3():
    assert main.get_tokens("day-13/challenge-2/test_input_no_solution.txt") == False

def test_4():
    assert main.get_tokens("day-13/challenge-2/test_input_no_solution_2.txt") == False