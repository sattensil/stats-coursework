#########   Matrices
#         and operations on matrices

a = matrix(1:6, nrow = 2 )  # a is 2X3
b = matrix(0:5, nrow = 3 )  # b is 3X2

print(a)
print(b)

m.c = a %*% b    #  %*% is the matrix multiplication operator
print(m.c)

m.c = b %*% a    # now we get a 3X3 matrix
print(m.c)

m.c.trans = t(m.c)   # t() gives the transpose
print(m.c.trans)

# another transpose
print(t(a))

##   what happens if you multiply matrices with non-conforming
#    dimensions? Remember, R allows one to add vectors with
#    non-conforming dimensions using the recycling rule.

t(a) %*% b    # a 3X2 times a 3X2
#    That's a relief. No recycling rule here
#    Remove the "%" around the "*"
print( t(a)*b )

#    if a and b are vectors a*b results in the element-by-element
#    multiplication of vectors. The same thing happens if a and b
#    are matrices. However, for vectors of unequal length we have
#    the recycling rule for the "*" operator. We do not for matrices.


d = matrix(11:14, nrow = 2)
print(d)
d * b
#   Matrices must have the dimensions one expects from a standard
#   linear algebra viewpoint.


#   Other matrix functions
print(dim(m.c))   # get the dimensions of m.c
print(diag(m.c))  # get the diagonals

s = diag(c(1,4,6))     # create a diagonal matrix 
print(s)
print(diag(diag(m.c))) # to form a matrix from the diagonals
                       # instead of a vector
#  Create an identity matrix of size n
n = 4
I.n = diag(rep(1,n))
print(I.n)

#   We can calculate the determinant for square matrices
options(digits = 16)
print(det(d))
##  Really! I am surprised by the inaccuracy.
#   Let's look under the hood.
det
#  ah, it calls determinant. It uses complex variables.
determinant
#  Can't look there. Must be compiled code.
determinant(d)

#  Everyone should recognize 0.693147... as ln(2)

#  Of course exp(ln(2)) = 2, and sign = -1, so
#  with no round-off errors we would get -2, which happens to
#  be correct.
print(11*14 - 12*13)

#  What's an error of 6*10^-15 anyway? But then this was a VERY
#  simple determinant to calculate

d = matrix(c(11.01,12,13,14), nrow = 2)
print(d)
print(det(d))
#  Now 11.01*14 = 154 + 0.01*14 = 154.14
#  So 11.01*14 - 12*13 = -1.86 exactly

print(11.01*14 - 12*13)
#  Now I am really feeling uneasy.

d = matrix(c(11+1/7,12,13,14), nrow = 2)

###  Actual determinant of d is 0
print(det(d))

# You do not want to rely on det() to test for a matrix
# being singular. To be fair, it is very difficult to use
# numerical methods to exactly determine if a matrix is
# singular or not. 

# Mathematically, a matrix is either singular or it isn't.
# But some matrices will have very small determinants on
# the order of 10^-16 or so. We really cannot distinguish
# these matrices from the ones which are mathematically singular.
#  Let's solve a system
A = matrix(c(2,1,3,2), nrow = 2)
b = c(12,5)
x = solve(A,b)
print(A)
print(x)
print(A %*% x)
#  Indeed 2*9 +3*(-2) = 12
#  and    1*9 +2*(-2) = 5
#
# also, when you want to find the inverse of a matrix
# use solve(). 
A.inv = solve(A)
print(A.inv)
print(A %*% A.inv)

#######  how to access a row or column from a matrix

#        first we build a matrix

set.seed(59012) # we want reproducibility

A = matrix(c(round(rnorm(24),3)), ncol = 4)
A

#####  well, ok

options(digits = 3)

A

v1 = A[2,]
v1

m1 = A[2:4,]
m1

is.matrix(v1)
is.matrix(m1)

is.vector(v1)

### When you select only one row (or column) your matrix becomes a vector
### unless .....

v1 = A[2,,drop = FALSE]
v1
is.matrix(v1)
dim(v1)

### get used to sprinkling drop = FALSE in your code

v2 = A[,3, drop = FALSE]
v2
dim(v2)
is.matrix(v2)

###  useful functions
rowSums(A)
colSums(A)
colMeans(A)
rowMeans(A)

### to find the number of rows and columns of a matrix
nrow(A)
ncol(A)

####  let's make a new matrix

c1 = c(12.3,34.1,16.7,15.2)
c2 = c(56.2,129.0,60.1,74.3)
my.data = cbind(c1,c2)
my.data

#  we can choose better column names
colnames(my.data) = c('height','weight')
my.data

#  store the 'height' column as a vector
#  this is really convenient with data with many columns.
#  you do not have to remember which column has the height
#  measurement. Also, if the data matrix is changed so that
#  the height measurement is moved to a new column, your 
#  my.data[,'height'] will get the correct column.

a = my.data[,'height']
is.vector('height')

# if you do not want column names you can remove them.

colnames(my.data) = NULL
my.data


######   doing QR using base R

V = matrix(runif(25), ncol = 5) # make a 5x5 random vector

V.qr = qr(V)
V.qr$rank            # the numeric rank

Q    = qr.Q(V.qr)
R    = qr.R(V.qr)

V - Q %*% R         # result should be all zeroes
                    # actual results are within acceptable range

#   what happens if you use qr.Q on the original matrix V

qr.Q(V)

#   you must first call qr, and use the result of qr as the input
#   to qr.Q and qr.R


#   Here is a wrapper function that takes the pain away
qrd <- function(M)
{  # start function qrd

  if ( !is.matrix(M) ) { stop('input must be a matrix.\n') }
  temp = qr(M)
  rank = temp$rank
  Q    = qr.Q(temp)
  R    = qr.R(temp)

  return( list(Q = Q, R = R, numerical.rank = rank) )

}  # end function qrd


qrd(V)



















