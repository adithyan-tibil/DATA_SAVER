def longest(data1):
    count = 0
    for i in data1:
        if len(i) > 2 and i[0] == i[-1]:
            count += 1
    return count


data = ['aah', 'abba', 'hah', 'jjj']
print(longest(data))
