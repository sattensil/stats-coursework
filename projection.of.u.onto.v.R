#############################################
#
#   Projection of vector u onto vector v.
#
#
##############################################

u = c(5,8)
v = c(3,10)

u.dot.v = u[1]*v[1] +u[2]*v[2]
u.dot.v
#    or
u.dot.v = sum(u*v)
u.dot.v

v.norm = sqrt(v[1]^2 + v[2]^2)
v.norm
#    or
v.norm = sqrt(sum(v*v))
v.norm

normalized.v = v/v.norm

u.projected.onto.v = sum(u*normalized.v)*(normalized.v)

u.perp.v = u - u.projected.onto.v

orig     = c(0,0)
our.data = rbind(orig,u,v,u.projected.onto.v,u.perp.v)

plot(our.data,xlim = c(-10,10),ylim = c(-10,10), type = 'n')
lines(rbind(orig,u))
lines(rbind(orig,v))
lines(rbind(orig,u.projected.onto.v), col = 'blue')
lines(rbind(orig,u.perp.v), col = 'red')
lines(rbind(u.projected.onto.v,u.projected.onto.v+u.perp.v), col = 'red')


######################################################
#
#      repeat with random vectors
#
#
######################################################


u = c(round(runif(1,-9,9),2),round(runif(1,-9,9),2))
v = c(round(runif(1,-9,9),2),round(runif(1,-9,9),2))


u.dot.v = u[1]*v[1] +u[2]*v[2]
u.dot.v
#    or
u.dot.v = sum(u*v)
u.dot.v

v.norm = sqrt(v[1]^2 + v[2]^2)
v.norm
#    or
v.norm = sqrt(sum(v*v))
v.norm

u.norm = sqrt(sum(u*u))
u.norm 
normalized.v = v/v.norm
normalized.u = u/u.norm

u.projected.onto.v = sum(u*normalized.v)*(normalized.v)

u.perp.v = u - u.projected.onto.v

orig     = c(0,0)
our.data = rbind(orig,u,v,u.projected.onto.v,u.perp.v)

plot(our.data,xlim = c(-10,10),ylim = c(-10,10), type = 'n')
lines(rbind(orig,u))
lines(rbind(orig,v))
text(u[1],u[2],'u')
text(v[1],v[2],'v')
lines(rbind(orig,u.projected.onto.v), col = 'blue')
lines(rbind(orig,u.perp.v), col = 'red')
lines(rbind(u.projected.onto.v,u.projected.onto.v+u.perp.v), col = 'red')
u
v
cos.theta = sum(u*v)/(u.norm*v.norm)
cos.theta
theta     = acos(cos.theta)
theta    # in radians
theta = theta*(180/pi)
theta    # in degrees

#######################################################
#
#     repeat in 3D
#
#######################################################

library(rgl)


u = c(round(runif(1,-9,9),2),round(runif(1,-9,9),2),
      round(runif(1,-9,9),2))
v = c(round(runif(1,-9,9),2),round(runif(1,-9,9),2),
      round(runif(1,-9,9),2))


u.dot.v = sum(u*v)
u.dot.v

v.norm = sqrt(sum(v*v))
v.norm

u.norm = sqrt(sum(u*u))
u.norm 
normalized.v = v/v.norm
normalized.u = u/u.norm

u.projected.onto.v = sum(u*normalized.v)*(normalized.v)

u.perp.v = u - u.projected.onto.v

orig     = c(0,0,0)
our.data = rbind(orig,u,v,u.projected.onto.v,u.perp.v)

plot3d(our.data,xlim = c(-10,10),ylim = c(-10,10), type = 'n')
lines3d(rbind(orig,u))
lines3d(rbind(orig,v))
points3d(0,0,0,col = 'green',cex = 1.4)
text3d(u[1],u[2],u[3],'u')
text3d(v[1],v[2],v[3],'v')
lines3d(rbind(orig,u.projected.onto.v), col = 'blue')
points3d(u.projected.onto.v[1],
         u.projected.onto.v[2],
         u.projected.onto.v[3], pch ='x', col = 'blue') 
lines3d(rbind(u.projected.onto.v,u.projected.onto.v+u.perp.v), col = 'red')
u
v
cos.theta = sum(u*v)/(u.norm*v.norm)
cos.theta
theta     = acos(cos.theta)
theta    # in radians
theta = theta*(180/pi)
theta    # in degrees

################################################################
#
#     Gram-Schmidt   3D example
#
################################################################

u = c(3,7,2)
v = c(-4,5,8)
w = c(6,-7,-3)

norm.u = sqrt(sum(u*u))

q1     = u/norm.u

#   subtaract projection of v onto q1 from v
v.onto.q1 = sum(v*q1)*q1
v.perp.q1 = v - v.onto.q1

#   subtract projection of w onto q1 from w
w.onto.q1 = sum(w*q1)*q1
w.perp.q1 = w - w.onto.q1

q2        = v.perp.q1/sqrt(sum(v.perp.q1*v.perp.q1))

w.onto.q2 = sum(w.perp.q1*q2)*q2
w.perp.q2 = w.perp.q1 - w.onto.q2

q3        = w.perp.q2/sqrt(sum(w.perp.q2*w.perp.q2))

Q = cbind(q1,q2,q3)

t(Q)%*%Q

orig = c(0,0,0)
d = rbind(orig,u,v,w)

plot3d(d)
#points3d(orig, col = 'green')
lines3d(rbind(orig,u))
lines3d(rbind(orig,v))
lines3d(rbind(orig,w))

text3d(u[1],u[2],u[3],'u')
text3d(v[1],v[2],v[3],'v')
text3d(w[1],w[2],w[3],'w')
lines3d(rbind(orig,q1),col ='blue')
lines3d(rbind(orig,q2),col = 'red')
lines3d(rbind(orig,q3), col = 'red')






