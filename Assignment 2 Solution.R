############ Problem Set 1 ########################

#####################  Problem 1 ##############################################
#   Given below are 4 vectors, v1, v2, v3, v4. Use the Gram-Schmidt procedure to
#   find 4 orthonormal vectors that span the same space as {v1,v2,v3,v4}. Call these
#   orthonormal vectors q1, q2, q3, q4.
#   Do the Gram-Schmidt procedure "by hand". Verify q1,q2,q3,q4 are orthonormal.
#   
#   I will find q1 and q2 for you to show what I mean by do it by hand.

#   Optional Problem: Organize the calculations in the modified Gram-Schmidt
#   manner.
#################################################################################
#   First some handy functions are provided

#   This function produces the dot product of two vectors
dprod <- function(u,v)
{ # begin dprod
  stopifnot( length(u) == length(v) )
  return(sum(u*v))
} # end dprod

#   This function produces the Euclidean norm of a vector
norm2 <- function(u)
{ # begin norm2
  return(sqrt(dprod(u,u)))
} # end norm2

v1 = c(4,-1,3,2,9)
v2 = c(-6,2,4,1,0)
v3 = c(5,8,1,2,11)
v4 = c(1,7,2,5,6)

q1 = v1/norm2(v1)
w2 = v2 -dprod(v2,q1)*q1
q2 = w2/norm2(w2)


#####  this is mine
w3 = v3 - dprod(v3,q1)*q1 - dprod(v3,q2)*q2
q3 = w3/norm2(w3)
w4 = v4 - dprod(v4,q1)*q1 - dprod(v4,q2)*q2 - dprod(v4,q3)*q3
q4 = w4/norm2(w4)

Q = cbind(q1,q2,q3,q4)

print(Q) # contains the orthonormal column vectors

# this multiplication verifies the vectors are orthonormal
t(Q)%*%Q
###########   end this is mine


######################   Problem 2 #######################################
#
#      Solve the linear system Ax = b, where A and b are given below
#
#  (a)  Solve using the normal equation approach
#  (b)  Solve using the QR decompostion
#  (c)  Solve using the SVD. print the singular values
#
#  For each part (a), (b) and (c) do the following:
#  For part (a), call your solution x.n
#  For part (b), call your solution x.qr
#  For part (c), call your solution x.svd 

#  Calculate y.n        = A%*%x.n
#  Calculate error.n    = b-y.n
#  Calculate y.qr       = A%*%x.qr
#  Calculate error.qr   = b-y.qr
#  Calculate y.svd      = A%*%x.svd
#  Calculate error.svd  = b-y.svd

#  What do you notice about the relationship between error and y? 
#
#  If you cannot obtain a solution using a posrticular method, give the
#  reason you cannot obtain the solution.

#  Note: to solve a system of equations in R when we have a square matrix
#        use x.solution = solve(A,b)
#        Then A%*%x.solution = b (within numerical accuracy)

set.seed(1000)
A = matrix(runif(240,-1,10),ncol=12)
b = runif(20,-10,10)


############# this is mine
# (a)  

x.n = solve(t(A)%*%A,t(A)%*%b)
print(x.n)
 y.n = A%*%x.n
error.n = b - y.n
print(error.n)
dprod(error.n,y.n)/(norm2(error.n)*norm2(y.n))
norm2(error.n)
# (b)
A.qr = qr(A)
Q    = qr.Q(A.qr)
R    = qr.R(A.qr)
x.qr = solve(R,t(Q)%*%b)
print(x.qr)
 y.qr = A%*%x.qr
error.qr = b - y.qr
dprod(error.qr,y.qr)/(norm2(error.qr)*norm2(y.qr))
norm2(error.qr)
# (c)  
A.svd =svd(A)
U = A.svd$u
D.inv = diag(1/A.svd$d)
V = A.svd$v

x.svd = V%*%(D.inv)%*%t(U)%*%b
print(x.svd)
 y.svd = A%*%x.svd
error.svd = b - y.svd
print(error.svd)
dprod(error.svd,y.svd)/(norm2(error.svd)*norm2(y.svd))
norm2(error.svd)

### another way to calculate the error.
### we do not even have to calculate the solution.

A.svd =svd(A,nu=20) # get full U matrix
U     = A.svd$u
error.U = numeric(20)
for ( i in 13:20)
  {
     error.U = error.U + dprod(U[,i],b)*U[,i]
  }
print(error.U-error.svd)
print(norm2(error.U))

################   Problem 3 ####################################
#  repeat problem 2 using the new A and b

#  In particular, note the singular values when solving with the SVD.
#  Solve using all the singular values, and solve using 2 singular values.

rm(x.n,x.qr,x.svd,y.n,y.qr,y.svd)
rm(error.n,error.qr,error.svd)

a1 = c(5,7,-1,6,7)
a2 = c(-3,0,-4,2,-1)
a3 = c(13.000001,14,2,10,15)
A = cbind(a1,a2,a3)
b = c(2,-6,8,1,4)

x.n = solve(t(A)%*%A,t(A)%*%b)

###### note that we cannot even solve the normal equation
###### The reason is that our matrix is rank deficient

print(x.n)
 y.n = A%*%x.n
error.n = b - y.n
dprod(error.n,y.n)/(norm2(error.n)*norm2(y.n))
norm2(error.n)
# (b)
A.qr = qr(A)
Q    = qr.Q(A.qr)
R    = qr.R(A.qr)
x.qr = solve(R,t(Q)%*%b)
print(x.qr)
 y.qr = A%*%x.qr
error.qr = b - y.qr
dprod(error.qr,y.qr)/(norm2(error.qr)*norm2(y.qr))
norm2(error.qr)
# (c)  
A.svd =svd(A,nu=5)
U = A.svd$u
print(A.svd$d)

###  Since A.svd$d[3] is so small, we ignore it.

D.inv = diag(c(1/A.svd$d[1:2],0))
V = A.svd$v

x.svd = V%*%(D.inv)%*%t(U[,1:3])%*%b
print(x.svd)
 y.svd = A%*%x.svd
error.svd = b - y.svd
dprod(error.svd,y.svd)/(norm2(error.svd)*norm2(y.svd))
norm2(error.svd)


#################   Problem 4 ####################################

# Change A[1,3] to be exactly 13. In this case, neither the normal
# equation or QR approach work. Solve using the SVD
#   (a) Use all the singular values
#   (b) Solve using two singular values

A[1,3] = 13
rm(x.svd,y.svd)
A.svd =svd(A)
U = A.svd$u
print(A.svd$d)
D.inv = diag(1/A.svd$d)
V = A.svd$v

x.svd = V%*%(D.inv)%*%t(U)%*%b
print(x.svd)
 y.svd = A%*%x.svd
error.svd = b - y.svd
dprod(error.svd,y.svd)/(norm2(error.svd)*norm2(y.svd))
norm2(error.svd)

x.svd.proj.v1 = dprod(V[,1],x.svd)
x.svd.proj.v2 = dprod(V[,2],x.svd)
x.svd.proj.v3 = dprod(V[,3],x.svd)

print(x.svd.proj.v1)
print(x.svd.proj.v2)
print(x.svd.proj.v3)
#### note the solution is essentially a multiple of v3.
#### this is expected, since 1/d[3] is so large
print( x.svd.proj.v1*V[,1] + x.svd.proj.v2*V[,2])

D.inv[3,3]=0

x.svd = V%*%(D.inv)%*%t(U)%*%b
print(x.svd)
 y.svd = A%*%x.svd
error.svd = b - y.svd
dprod(error.svd,y.svd)/(norm2(error.svd)*norm2(y.svd))
norm2(error.svd)

#### note this small perturbation in A[1,3] does not cause x.svd
#### or y.svd to change.

x.svd.proj.v1 = dprod(V[,1],x.svd)
x.svd.proj.v2 = dprod(V[,2],x.svd)
x.svd.proj.v3 = dprod(V[,3],x.svd)

print(x.svd.proj.v1)
print(x.svd.proj.v2)
print(x.svd.proj.v3)

print(dprod(U[,1],b)/A.svd$d[1])
print(dprod(U[,2],b)/A.svd$d[2])



#################### Problem 5 #####################################

library(mvtnorm) # generate MVN distribution

S = matrix(c(6,3,-1,3,4,2,-1,2,3),ncol=3)
mu = c(1,2,3)
set.seed(50)

#   generate 10,000 multivariate normal random vectors using S as the
#   covariance matrix and mu as the expected value of the random vector.
#   Find an expression for a alpha% confidence interval for the random vector.
#   Use the given set.seed to generate the random vectors.

#   Use 80%, 90%, 95%, and 99% for alpha.

#   How many of the vectors are in the confidence interval?

n = 10000
x = rmvnorm(n,mu,S)
e = eigen(S)
S.inv.1 = (e$vectors)%*%diag(1/e$values)%*%t(e$vectors) # one way

S.inv = solve(S) 

d = numeric(10000)
for ( i in 1:n)
   {
      v=x[i,]-mu
      d[i] = t(v)%*%S.inv%*%v
   }
d = sort(d)
v = c(0.5,0.6,0.7,0.8,0.9,0.95,0.99)
for ( i in 1:length(v) )
{
   k   = qchisq(v[i],3)
   num[i] = length(d[d< k]) 
   expected.num[i] = v[i]*n
}

print(num)
print(expected.num) 

library(rgl)
in.90 = numeric(10000)
out.90 = numeric(10000)
in.count = 0
out.count = 0
k = qchisq(0.90,3)
for ( i in 1:n)
   {
      v=x[i,]-mu
      d[i] = t(v)%*%S.inv%*%v
      if ( d[i] <= k )
        {
          in.count          = in.count + 1
          in.90[in.count]   = i
        }
      else
        {
          out.count         = out.count + 1
          out.90[out.count] = i
        }
   }
in.90 = in.90[1:in.count]
out.90 = out.90[1:out.count]
plot3d(x[out.90,], col='blue')
points3d(x[in.90,], col = 'red')

x.in = x[in.90,] -matrix( rep(mu,in.count),ncol=3,byrow = T)
z.in = t(e$vectors%*%diag(1/sqrt(e$values))%*%t(e$vectors)%*%t(x.in))
dim(z.in)

mag.z.in = numeric(in.count)
for ( i in 1:in.count )
  {
    mag.z.in[i] = (dprod(z.in[i,],z.in[i,]))
  }
max(mag.z.in) 
k

x.out = x[out.90,] -matrix( rep(mu,out.count),ncol=3,byrow = T)
z.out = t(e$vectors%*%diag(1/sqrt(e$values))%*%t(e$vectors)%*%t(x.out))
dim(z.out)

mag.z.out = numeric(out.count)
for ( i in 1:out.count )
  {
    mag.z.out[i] = (dprod(z.out[i,],z.out[i,]))
  }
min(mag.z.out) 
k

plot3d(z.out,col = 'blue')
points3d(z.in,col = 'red')









