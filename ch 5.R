#2
A=matrix(c(1,4,2,6,3,8), nrow = 3, ncol = 2, byrow = TRUE)
B=matrix(c(1,3,1,4,2,5), nrow = 3, ncol = 2, byrow = TRUE)
C=matrix(c(3,8,1,5,4,0), nrow = 2, ncol = 3, byrow = TRUE)
A+B
A-B
A%*%C
A%*%t(B)
t(B)%*%A

#5
X=matrix(c(4,1,2,3,3,4), nrow = 1, ncol = 6, byrow = TRUE)
Y=matrix(c(16,5,10,15,13,22), nrow = 1, ncol = 6, byrow = TRUE)

t(Y)%*%Y
t(X)%*%X
t(X)%*%Y

#14
M=matrix(c(4,7,2,3), nrow = 2, ncol = 2, byrow = TRUE)
N=matrix(c(25,12), nrow = 2, ncol = 1, byrow = TRUE)

solve(M,N)

