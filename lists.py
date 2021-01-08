students = ["Mark", "Amber", "Todd", "Anita", "Sandy"]
has_anita = "Anita" in students
print(has_anita)

#doesn't work
students.append("Goober","Amanda")

students.append("Goober")
students.append("Amanda")

print(students)

student_name = "Amanda"
if student_name in students:
    print(student_name + " already in list")
else:
    students.append(student_name)
    print(student_name +" added to list")

other_students = ("Nader", "Bubba")
students.extend(other_students)
print(students)

students.remove("Nader")
print(students)

#remove the first item
students.pop(0)
#remove the last item
students.pop()
print(students)

last_removed = students.pop()
print(last_removed)

students.clear()
print(students)

grades = ["C", "B", "A", "D", "C", "B", "C"]
b_grades = grades.count("B")
look_for = "C"
c_grades = grades.count(look_for)
print('There are ' + str(b_grades) + "Bs and " + str(c_grades) + "Cs")

grades.index("B")
look_for = "F"
if look_for in grades:
    print(str(look_for) + 'is at index ' + str(grades.index(look_for)))
else:
    print(str(look_for) + " is not in list")

grades.sort(reverse=True)
print(grades)
# for upper and lower letters, use
grades.sort(key=lambda s:s.lower())

names = ["Mark", "Amber", "Todd", "Anita", "Sandy"]
names.reverse()
print(names)

#order isn't fixed in sets
sample_set = {1.98, 98.9, 74.95, 2.5, 1, 16.3}
sample_set.add(11.23)
sample_set.update([88, 123.45, 2.98])
print(sample_set)
set_2 = sample_set.copy()
print(sample_set)
print(set_2)
