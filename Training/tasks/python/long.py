def longest(files):
    with open(files, 'r') as file:
        content = file.read().split()
        count = 0
        for i in content:
            if len(i) > 2 and i[0] == i[-1]:
                count += 1
    return count


print(longest('sample.txt'))
