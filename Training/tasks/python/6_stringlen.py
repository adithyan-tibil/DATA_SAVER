strings = ['abc', 'xyz', 'aba', '1221']
# count = 0
# for i in strings:
#     if len(i)>2 and i[0]==i[-1]:
#         count+=1
# print(count)

func = list(filter(lambda i: len(i) > 2 and i[0] == i[-1], strings))
print(len(func))
