#8.62
x=seq(0,10,by=.1)
p1=dgamma(x,shape=.25,rate=.5)
c1=dgamma(x,shape=(.25+20),rate=(.5+5.1))
p2=dgamma(x,shape=.25,rate=.025)
c2=dgamma(x,shape=(.25+20),rate=(.025+5.1))
plot(x,c1,type="l",col="blue",main=title("8.62 Comparision: Gamma"),ylab="")
lines(x,p1,col="red")
lines(x,c2,col="green")
lines(x,p2)


#8.63
x=seq(0,1,by=.01)
p1=dbeta(x,1,1)
c1=dbeta(x,4,98)
p2=dbeta(x,.5,.5)
c2=dbeta(x,3.5,97.5)
plot(x,c1,type="l",col="blue",main=title("8.62 Comparision: Beta"),ylab="")
lines(x,p1,col="red")
lines(x,c2,col="green")
lines(x,p2)