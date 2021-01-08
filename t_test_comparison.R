# estimation of probability of type I error, comparing 2-sample t methods

s2x = 9			# true population variance of the Xs
s2y = 9			# true population variance of the Ys

mux = 5			# true population mean of the Xs
muy = 5			# true population mean of the Ys

n = 10			# sample size of Xs
m = 10			# sample size of Ys

B = 10000		# number of simulated samples

p.value1 = numeric(B)	# p-values assuming equal variances
p.value2 = numeric(B)	# unequal variances

for (i in 1:B) {
#	x = rnorm(n, mux, sqrt(s2x))
	x = rexp(n, 1/mux)
#	y = rnorm(m, muy, sqrt(s2y))
	y = rpois(m, muy)
	p.value1[i] = t.test(x,y,var.equal=TRUE)$p.value
	p.value2[i] = t.test(x,y,var.equal=FALSE)$p.value
}

cat(length(which(p.value1<.05))/B, '\n')
cat(length(which(p.value2<.05))/B, '\n')

# play around with true variances, sample sizes, and population distributions!