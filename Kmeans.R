################################################################
#
#         K means clustering algorithm
#
################################################################

find.d <- function(p,center)
{
  t = matrix( rep(center,nrow(p)), byrow = TRUE,ncol = ncol(p) )
  return( rowSums((p-t)^2) )
}

km.cl <-function(p,n = 6)
{ # start km.l

  start = sample(1:nrow(p),n, replace = FALSE)

  cntr  = p[start,]
  old.cntr = 0.9*cntr

  while ( any(cntr != old.cntr) )
    {                             # update center points
           # allocate matrix contining squared distance
           # of p points from cntr points.
           # column i has sq. dist. from p to ith cntr point
      old.cntr = cntr
      d = matrix( rep(0,nrow(p)*n), ncol = n)
      for ( i in 1:n )
        {
          d[,i] = find.d(p,cntr[i,]) 
        }
      closest = apply(d,1,which.min)
      if ( length(unique(closest)) < n )
        {
          cat('Note: we have a center containing no points.\n')
        }
      for ( j in unique(closest) )
        {
          cntr[j,] = colMeans(p[which(closest == j),])
        }
    }                             # update center points

    for ( i in 1:n )
      {
        d[,i] = find.d(p,cntr[i,]) 
      }
    closest = apply(d,1,which.min)

    return( list("cluster.num" = closest, "centers" = cntr) )
} # end km.cl

#####################################################################
#
#      K Means Clustering Algorithm
#
#      Plots Progress of Algorithm
#
####################################################################

km.cl.steps <-function(p,n = 6)
{ # start km.l

  start = sample(1:nrow(p),n, replace = FALSE)

  cntr  = p[start,]
  old.cntr = 0.9*cntr

############################# display code ###############
dev.new()
plot(p, type = 'n')
points(cntr, cex = 2)
##########################################################

  while ( any(cntr != old.cntr) )
    {                             # update center points
           # allocate matrix contining squared distance
           # of p points from cntr points.
           # column i has sq. dist. from p to ith cntr point
      old.cntr = cntr
      d = matrix( rep(0,nrow(p)*n), ncol = n)
      for ( i in 1:n )
        {
          d[,i] = find.d(p,cntr[i,]) 
        }
      closest = apply(d,1,which.min)

#######################  display code #####################
for ( k in 1:n )
{
  points(p[which(closest == k),], col = 11*k, pch = k)
}
Sys.sleep(3)
###########################################################

      if ( length(unique(closest)) < n )
        {
          cat('Note: we have a center containing no points.\n')
        }
      for ( j in unique(closest) )
        {
          cntr[j,] = colMeans(p[which(closest == j),])
        }

######################## display code ########################
dev.new()
plot(p, type = 'n')
points(cntr,cex = 2)
##############################################################

    }                             # update center points

    for ( i in 1:n )
      {
        d[,i] = find.d(p,cntr[i,]) 
      }
    closest = apply(d,1,which.min)

#################### display code ####################
dev.new()
plot(p,type = 'n', main = 'Final Result')
for ( i in 1:n )
{
  points(p[which(closest == i),], col = 11*i, pch = i)
}
points(cntr, cex = 2)
#####################################################

    return( list("cluster.num" = closest, "centers" = cntr) )
} # end km.cl


###
