# problem 10.29 (c) simulation

# data is on page 393
x <- c(136.3, 136.6, 135.8, 135.4, 134.7, 135, 134.1, 143.3, 147.8, 148.8, 134.8, 135.2, 134.9, 146.5, 141.2, 135.4, 134.8, 135.8, 135, 133.7, 134.4, 134.9, 134.8, 134.5, 134.3, 134.2)

set.seed(123)

N = numeric(1000)

for (i in 1:1000) {
	sam = sample(x, 26, replace=TRUE)
	N[i] = length(which(sam >= 141.2))
}
total = length(which(N >=10))
cat(total)