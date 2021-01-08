#############################################################
#
#    Matrix Selection Operations
#
#############################################################

# make a matrix

m = round(matrix(runif(35,-5,5),ncol = 5),2)

print(m)

y = m[2,5]     # gives one element. row 2 and column 5
is.matrix(y)
is.vector(y)
print(y)

               # if you want the result to be a vector
y = m[2,5, drop = FALSE]     # gives one element. row 2 and column 5
is.matrix(y)                 # but now it is a matrix
is.vector(y)
print(y)



y = m[2:4,]    # gives a matrix of rowa 2 through 4
is.matrix(y)
print(y)


v = c(2,4,6)
y = m[v,]    # selects rows given by vector v
is.matrix(y)
is.vector(y)
print(y)

v = c(1,5)
y = m[,v]      # selects columns given by v
is.matrix(y)
is.vector(y)

y = m[1:3,4:5]   # select from rows AND columns
is.matrix(y)
is.vector(y)
print(y)

y = m[2,]       # selects a single row
is.matrix(y)
is.vector(y)
print(y)

y = m[2,,drop = FALSE]    # use drop = FALSE to make result a matrix
is.matrix(y)
is.vector(y)
print(y)

y = m[,3,drop = FALSE]    # use drop = FALSE to make result a matrix
is.matrix(y)
is.vector(y)
print(y)

