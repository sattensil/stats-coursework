# population distribution affect on independent t-test with equal variances

s2x = s2y = 9			# true population variance of the Xs and Ys

mux = 5			# true population mean of the Xs
muy = 5			# true population mean of the Ys

n = 10			# sample size of Xs
m = 10			# sample size of Ys

B = 10000		# number of simulated samples

p.value1 = numeric(B)	# p-values assuming equal variances

for (i in 1:B) {
	x = rnorm(n, mux, sqrt(s2x))
	y = rnorm(m, muy, sqrt(s2y))
	p.value1[i] = t.test(x,y,var.equal=TRUE)$p.value
}

cat(length(which(p.value1<.05))/B, '\n')

# play around with true variances, sample sizes, and population distributions!