from Training.tasks.python.long import longest

def test_longest():
    res = longest("sample.txt")
    print(res)
    assert 3 == res


def test_neg_longest():
    res = longest("sample.txt")
    print(res)
    assert "a" != res


def test_spl_char_longest():
    res = longest("sample.txt")
    print(res)
    assert "!!" != res



def test_without_file_longest():
    try:
        res = longest()
        assert False, "Expected a TypeError but no exception was raised."
    except TypeError:
        print("TypeError was correctly raised.")
