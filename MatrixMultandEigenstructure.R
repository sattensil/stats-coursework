################################################
#
#   Matrix multiplication considered from the
#   point of view of its eigendecomposition.
#
#
################################################

# We will define a 2x2 matrix and then we will create
# a dense set of points on the unit circle.

# Then we will multiply these points by our matrix.
# Since any vector x is a scalar multiple of a vector
# on the unit circle this demonstrates the effect of
# matrix multiplication on any vector x.

# here we create the points on the circle. There will
# be 10,000 points.
t = seq(0,2*pi, length=10000)
x = cos(t)
y = sin(t)

v = rbind(x,y) # v is a 2x10000 matrix. Each column is
               # a point from the unit circle.

#  her we create a matrix
A = matrix(c(3,1,1,4),nrow = 2)

##  now w will be a matrix containing the output
##  of the matrix multiplicatin operation.

w = A %*% v

####  now we plot the results.
####  the input points are the black circle and the output
###   points are the red ellipse.

dev.new()
plot(x,y, type = 'l', xlim = c(-5,5), ylim = c(-5,5))
lines(w[1,],w[2,], col = 'red')
abline( v = 0, h = 0)


d = eigen(A)
print(d)

###   now we plot the eigenvectors on the existing plot
eig.val.1 = d$values[1]
eig.vec.1 = d$vectors[,1]
eig.val.2 = d$values[2]
eig.vec.2 = d$vectors[,2]
lines( c(0,eig.vec.1[1]),c(0,eig.vec.1[2]) )
lines( c(0,eig.vec.2[1]),c(0,eig.vec.2[2]) )

#   A is symmetric. Therefore, eigenvectors are 
#   mutually orthogonal, and eigenvectors are real.

#  Note that the eigenvectors point to the largest and smallest
#  increase in the unit circle.

#  we plot the points that were expanded the most and the least
#  as blue points. Of course these points come from multiplying
#  A by the eigenvectors of A.

w.max = A %*% eig.vec.1
points(w.max[1],w.max[2],col = 'blue')

w.min = A %*% eig.vec.2
points(w.min[1],w.min[2],col = 'blue')

##   repeat with animation


dev.new()
plot(x,y, type = 'n', xlim = c(-5,5), ylim = c(-5,5))

for ( i in 1:ncol(w) )
  {                   # plot one input/output pair
     points(v[1,i],v[2,i], cex = 0.2)
     points(w[1,i],w[2,i], col = 'red', cex = 0.2)
  }                   # plot one input/output pair




#  If A is singular....

A = matrix(c(2,1,4,2),nrow = 2)
w = A %*% v

dev.new()
plot(x,y, type = 'l', xlim = c(-5,5), ylim = c(-5,5))
lines(w[1,],w[2,], col = 'red')
abline( v = 0, h = 0)

d = eigen(A)
print(d)


####  Look at the eignvectors that were printed above.
####  By inspection one can see their dot product is zero,
####  so they are orthogonal. The plot makes it appear they
####  are not orthogoanl. This is a constant problem with R
####  plots.

eig.val.1 = d$values[1]
eig.vec.1 = d$vectors[,1]
eig.val.2 = d$values[2]
eig.vec.2 = d$vectors[,2]
lines( c(0,eig.vec.1[1]),c(0,eig.vec.1[2]) )
lines( c(0,eig.vec.2[1]),c(0,eig.vec.2[2]) )

#  note that Av is a one-dimensional space
#  This happens because all the vectors in v
#  are a linear combination of the two eigenvectors.
#  The component in the direction of the eigenvector
#  whose eigenvalue = 0 becomes zero. The other component
#  is in the direction of the eigenvector associated with
#  the eigenvalue 4. Hence the result is always a vector in the
#  direction of the eigenvector with the non-zero eigenvalue.
#  Hence the space spanned by Av is one dimensional. 




####   Now we demonstrate how the eigenstructure explains
####   matrix multiplication.

A      = matrix( c(5,2,-1,2,3,1,-1,1,7), byrow = TRUE, ncol = 3)
x      = c(1,2,3)

A.eig  = eigen(A)

V      = A.eig$vectors
lambda = A.eig$values

#     Now we express x as a linear combination of the eigenvectors.
#     We can solve V*c = x by multiplying by V transpose

c     = t(V) %*% x
print(c)

print( c[1]*V[,1] + c[2]*V[,2] + c[3]*V[,3] )

##   We see we have expressed x as a linear combination
##   of the eigenvectors. Think of our vector x as having
##   V column vectors as a basis, and c are then the coordinates
##   using the eigenvector basis.

##   Now perform the Ax multiplication

y = A %*% x
print(y)

##  Now we will see y = lambda[1]*c[1]*V[,1] + 
##                      lambda[2]*c[2]*V[,2] +
##                      lambda[3]*c[3]*V[,3]

print(lambda[1]*c[1]*V[,1] + lambda[2]*c[2]*V[,2] +
      lambda[3]*c[3]*V[,3])

##  If we express the vector to be multiplied in the
##  eigenvector coordinates (that is, the linear combination
##  of the eigenvectors that equal the input vector), we only
##  need to multiply those coordinates by the eigenvalues
##  and then the output of the multiplication is completed in
##  the eigenvector coordinate space. We can always switch back
##  to the natural coordinate system whenever we wish.

##  Find A*A*A*A*x = A^4*x

print(lambda[1]^4*c[1]*V[,1] + lambda[2]^4*c[2]*V[,2] +
      lambda[3]^4*c[3]*V[,3])

print(A %*% A %*% A %*% A %*% x)


##  Find the largest eigenvalue and its eigenvector.

#   Start with any vactor x, repeatedly multiply by A.
#   Scale the output to keep from overflowing or underflowing.

#   This is the power method algorithm for finding the
#   eigenvector associated with the largest eigenvalue.
#   We then find the eigenvalue.

#   start with x = c(1,1,1)

x = c(1,1,1) 

#   Note to students: Try other tarting values.
#   Does the algorithm seem robust?
#
#   Question: If we were using a machine that did
#             exact arithmentic, what wuld happen
#             if we unknowingly selected an eigenvector
#             associuated with a smaller eigenvalue as our
#             initial x value?

#   Note: this is not a sophisticated termination
#   condition.

for ( i in 1:1000 )
  {                  # one iteration of power method
    x = A %*% x
    if ( (i %% 50) == 0 )
      {   # normalize every 50 iterations
        x = x/max(x)
      }   # normalize every 50 iterations
  }                  # one iteration of power method

# normalize

norm.x = sqrt(sum(x*x))
x      = x/norm.x
print(x)

#  compare to V[,1]
print(V[,1])

# find eigenvalue

print( t(x) %*% A %*% x )

# compare to eigenvalue
print(lambda[1])
