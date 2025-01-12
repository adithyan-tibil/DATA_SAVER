data = "This is  a a test test sentence and a test.".split()
out = ''
previous_word = ''
for i in data:
    if i != previous_word:
        out += i + ' '
    previous_word = i
print(out)
