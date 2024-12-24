import main

def test():
    assert main.get_tokens("day-13/challenge-1/test_input.txt") == 480

def test_2():
    assert main.get_tokens("day-13/challenge-1/test_input_one_machine.txt") == 280

def test_3():
    assert main.get_tokens("day-13/challenge-1/test_input_no_solution.txt") == 0