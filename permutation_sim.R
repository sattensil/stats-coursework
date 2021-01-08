# perm.test
# a is the first sample
# b is the second sample
# c is the number of permuations to simulate

perm.test = function(a,b,c=10000, alt=c("two.sided")){
	obs.dif = mean(b) - mean(a)
	dat = c(a,b)
	na = length(a)
	nb = length(b)
	n = length(a)+length(b)
	dif.perm = numeric(c)
	
	for (i in 1:c){
		ind = sample(1:n, na, replace = FALSE)
		a.random = dat[ind]
		b.random = dat[!1:n %in% ind]
		dif.perm[i] = mean(b.random) - mean(a.random)
	}
	if (alt=="greater") p.value = sum( dif.perm >= obs.dif)/c
	if (alt=="less") p.value = sum( dif.perm <= obs.dif)/c
	if (alt=="two.sided") p.value = sum( abs(dif.perm) >= abs(obs.dif))/c
	return(p.value)
}