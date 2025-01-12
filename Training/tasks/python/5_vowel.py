names = ['adithyan', 'ram', 'sham', 'anand', 'varun', 'oman', 'ozil']


def vowel(x):
    out = []
    for i in x:
        if i[0] in 'aeiou':
            out += i
        return out


output = filter(vowel, names)

print(list(output))
