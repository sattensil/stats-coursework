###############################################
#
#    demonstrate effect of diagonal shift on
#    the eigenstructure of a matrix
#
###############################################

temp = rnorm(36)

m    = matrix(temp,ncol = 6)

m    = t(m) %*% m

eigen(m)

I.6 = diag(rep(1,6))
I.6

m1 = m + I.6
eigen(m1)

m2 = m + 7*I.6
eigen(m2)

m3 = m - 2*I.6
eigen(m)


