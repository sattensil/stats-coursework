#Scarlett Townsend
#STAT 6502
#HW #2

#9.3
p=seq(0,1,.0001)
u=(60-100*p)/(100*p*(1-p))^.5
l=(40-100*p)/(100*p*(1-p))^.5
power=1-pnorm(u,0,1)+pnorm(l,0,1)
plot(p,power,type="l")

#9.11
n=25
#alpha=.05
m=-1000:1000
u=1.96*100*(n^.5)+m
l=-1.96*100*(n^.5)+m
power=1-pnorm(u,m*n,100*n)+pnorm(l,m*n,100*n)
plot(m,power,type="l",col="red")  
#alpha=.1
u=1.65*100*(n^.5)+m
l=-1.65*100*(n^.5)+m
  power=1-pnorm(u,m*n,100*n)+pnorm(l,m*n,100*n)
    lines(m,power,type="l")

n=100
#alpha=.1
u=1.65*100*(n^.5)+m
l=-1.65*100*(n^.5)+m
  power=1-pnorm(u,m*n,100*n)+pnorm(l,m*n,100*n)
    lines(m,power,type="l",col="green")
#alpha=.05
u=1.96*100*(n^.5)+m
l=-1.96*100*(n^.5)+m
 power=1-pnorm(u,m*n,100*n)+pnorm(l,m*n,100*n)
   lines(m,power,type="l",col="blue")  