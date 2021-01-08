# Finding optimal CIs

require(Rsolnp)

alpha <- 0.05

len <- function(a) {
	return(abs(qbeta(1-a[2],20,9) - qbeta(a[1],20,9)))
#	return(abs(qchisq(1-a[2],5) - qchisq(a[1],5)))
	} # objective function
	
con <- function(a) {
	return(a[1]+a[2])
	} # constraint
	
x0 <- rep(alpha/2, 2)

sol <- solnp(x0, fun=len, eqfun=con, eqB=c(.05), LB=c(0,0), UB=c(1,1))

cat("Values of alpha_1 and alpha_2 are ",sol$pars, "\n")
cat("This yields the CI ", qbeta(sol$pars[1],20,9), qbeta(1-sol$pars[2],20,9),"\n")
#cat("This yields the CI ", qchisq(sol$pars[1],5), qchisq(1-sol$pars[2],5),"\n")