people = {
    'htanaka': "Haru Tanaka"
    ,'ppatel': "Priya Patel"
    ,'bagarcia': "Benjamin Alberto Garcia"
    ,'zmin': 'Zhang Min'
    ,'afarooqi': "Ayesha Farooqi"
    ,'hajackson': "Hanna Jackson"
    ,'papatel': "Pratyush Aarav Patel"
    ,'hrjackson': "Henery Jackson"
}

print(people)
print(people['zmin'])

print('hrjackson' in people)
person = 'bagarcia'
print(people.get(person))
print(people.get('schmeedledorp', 'Unbeknownst to theis dictionary'))

print(people['hajackson'])
people['hajackson'] = 'Hanna Jackson-Smith'

print(people['hajackson'])

people.update({'hrjackson':'Henrietta Jackson'})
people.update({'wwiggins':'Wanda Wiggins'})

for person in people.keys():
    print(person + "=" + people[person])

del people['hajackson']
print(people)

#value only
adios = people.pop('zmin')
print(people)

#key value pair
aurevoir = people.popitem()

adios
aurevoir

people.clear()
print(people)

DWC001 = dict.fromkeys(['name', 'uni_price', 'taxable', 'in_stock', 'models'])
print(DWC001)

