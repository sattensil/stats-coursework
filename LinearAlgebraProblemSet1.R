##############################################
#
#  script for Linear Algebra Problem Set 1
#
###############################################


#####  form the matrix A and the vector b
#####  then solve Ax = b

v1 = c(6,-2,5)
v2 = c(-2,3,1)
v3 = c(5,1,-2)

A  = cbind(v1,v2,v3)

b  = c(2,7,1)

print(A)
x  = solve(A,b)

print(x)      # x is the solution to Ax = b

#####   Now perturb A by adding 0.01 to A[3,3]
#####   Call this perturbatuion of A the A.p matrix

A.p = A
A.p[3,3] = A[3,3] + 1.0e-2

#####    Now solve A.p*x = b
x.p = solve(A.p,b)

print(x.p)

x.delta = x - x.p
print(x.delta)

# find the norm of the change to the solution
norm.x.delta = sqrt(sum(x.delta*x.delta))     

#  find the norm of the original solution 
norm.x        = sqrt(sum(x*x))   

print(norm.x)
print(norm.x.delta)                                          

#########  find the eigenvalues of A and A.p

A.eig   = eigen(A)
A.p.eig = eigen(A.p)

A.eig$values

A.p.eig$values

#######  Now form a rank deficient matrix. Call it B
B = cbind(v1,v2,2*v1 + 5*v2)
print(B)

#######  attempt to solve Bx = b
x = solve(B,b)

####### Why can't we get a solution?

B.eig = eigen(B)

B.eig$values

####### Now perturb B a little bit. Call the matrix B.p
B.p = B
B.p[3,3] = B.p[3,3] + 0.01

print(B.p)

x = solve(B.p,b)

####### We do get a solution
print(x)

B.p.eig = eigen(B.p)

B.p.eig$values

####### Now perturb B.p
B.p[3,3] = B.p[3,3] + 0.01

print(B.p)

x.p = solve(B.p,b)
print(x.p)

#######  note that a small perturbation results in an entirely
#######  different solution.

B.p.eig = eigen(B.p)

B.p.eig$values

######  try another pertabation of B

I.3 = diag(c(1,1,1))
print(I.3)

######## add a constant to the diagonal of B. Call the new vector B.d

B.d = B + 0.01*I.3  # add 0.5 to the diagonal

print(B.d)

x = solve(B.d,b)
print(x)

##### Now perturb B.d and see how much the perturbation affects
##### the solution

B.d.p      = B.d
B.d.p[3,3] = B.d[3,3] + 0.01

x.p        = solve(B.d.p,b)
print(x.p)

B.d.eig    = eigen(B.d)
B.d.p.eig  = eigen(B.d.p)

print(B.d.eig$values)
print(B.d.p.eig$values)


####   Now test the effect of adding different constants to
####   the diagonal of B.

diag.shift = c(0.01,0.02,0.1,0.3,0.5,1,2,3)

for ( shift in diag.shift )
  {                      # find solution for a given shift

    cat(c('diag shift is ',paste(shift),'.\n'))
    cat('**********************\n')

    B.d        = B + shift*I.3  # add disgonal shift  
    x          = solve(B.d,b)
    print(x) 
    B.d.p      = B.d
    B.d.p[3,3] = B.d[3,3] + 0.01

    x.p        = solve(B.d.p,b)
    print(x.p)

    B.d.eig    = eigen(B.d)

    print(B.d.eig$values)
    print(B.eig$values)

    cat('\n\n')

  }                      # find a solution for a given shift





