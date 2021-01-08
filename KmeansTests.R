############################################################
#
#      test  K Means Clustering
#
############################################################


####  parameters to control cluster formation
####  num.c is the number of clusters
####  the number of points in each cluster will be
####  a random number between n.low and n.high
num.c  = 8
n.low  = 18
n.high = 120
n      = runif(num.c,n.low,n.high)
n      = trunc(n)                  # force it to be an interger
print(n)

for ( i in 1:num.c)
  { # begin for
     s= matrix( rep(0,4), ncol = 2)
     s[1,1] = runif(1,1.3,4)
     s[2,2] = runif(1,1.2,3)
     s[1,2] = s[2,1] = runif(1,-1,1)
     mu     = runif(2,-10-2*num.c,10 + 2*num.c)
     x      = rmvnorm(n[i],mu,s)
     rownames(x) = rep(i,n[i])
     if ( i == 1 ) 
       { data = x }
     else
       { data = rbind(data,x) }
  } #end for

### Look at the clusters formed.
### If the clusters formed do not seem good, just
### repeat the code above and form a new cluster
### until you get an interesting result
dev.new()
plot(data, type = 'n')
text(data, label = rownames(data))



dev.new()
plot(data,type = 'n')
n.clust = num.c
n.clust = 5
cl = km.cl(data,n.clust)
for ( i in 1:n.clust )
{
  points(data[which(cl$cluster.num == i),], col = 11*i, pch = min(c(i,25)) )
}
points(cl$centers, cex = 2)

########################################################
#
#
#          more points in clusters
#
########################################################

num.c  = 14
n.low  = 180
n.high = 1200
n      = runif(num.c,n.low,n.high)
n      = trunc(n)                  # force it to be an interger
print(n)

for ( i in 1:num.c)
  { # begin for
     s= matrix( rep(0,4), ncol = 2)
     s[1,1] = runif(1,1.3,4)
     s[2,2] = runif(1,1.2,3)
     s[1,2] = s[2,1] = runif(1,-1,1)
     mu     = runif(2,-25-2*num.c,25 + 2*num.c)
     x      = rmvnorm(n[i],mu,s)
     rownames(x) = rep(i,n[i])
     if ( i == 1 ) 
       { data = x }
     else
       { data = rbind(data,x) }
  } #end for

### Look at the clusters formed.
### If the clusters formed do not seem good, just
### repeat the code above and form a new cluster
### until you get an interesting result
dev.new()
plot(data, type = 'n')
text(data, label = rownames(data))



dev.new()
plot(data,type = 'n')
n.clust = num.c
n.clust = 14
cl = km.cl(data,n.clust)
for ( i in 1:n.clust )
{
  points(data[which(cl$cluster.num == i),], col = 11*i, pch = min(c(i,25)) )
  Sys.sleep(1)
}
points(cl$centers, cex = 2)



###################################################
#
#      3D
#
###################################################


num.c  = 12
n.low  = 180
n.high = 1200
n      = runif(num.c,n.low,n.high)
n      = trunc(n)                  # force it to be an interger
print(n)

for ( i in 1:num.c)
  { # begin for
#     s= matrix( rep(0,9), ncol = 3)
#     s[1,1] = runif(1,1.3,4)
#     s[2,2] = runif(1,1.2,3)
#     s[3,3] = runif(1,2,4)
#     s[1,2] = s[2,1] = runif(1,-1,1)
#     s[1,3] = s[3,1] = runif(1,-0.8,0.8)
#     s[2,3] = s[3,2] = runif(1,-0.7,0.7)
     s      = matrix(runif(9,-3,3), ncol = 3)
     s      = t(s) %*% s
     s      = round(s,3)
     s[1,1] = s[1,1] + 0.1
     s[2,2] = s[2,2] + 0.3
     s[3,3] = s[3,3] + 0.2
     mu     = runif(3,-25-2*num.c,25 + 2*num.c)
     x      = rmvnorm(n[i],mu,s)
     rownames(x) = rep(i,n[i])
     if ( i == 1 ) 
       { data = x }
     else
       { data = rbind(data,x) }
  } #end for

### Look at the clusters formed.
### If the clusters formed do not seem good, just
### repeat the code above and form a new cluster
### until you get an interesting result
open3d()
plot3d(data, type = 'n')
text3d(data, text = rownames(data))


open3d()
plot3d(data,type = 'n')
n.clust = num.c
#n.clust = 20
cl = km.cl(data,n.clust)
for ( i in 1:n.clust )
{
  points3d(data[which(cl$cluster.num == i),],
                alpha = 0.2, col = 11*i, pch = min(c(i,25)) )
  Sys.sleep(2)
}
points3d(cl$centers, size = 3)



