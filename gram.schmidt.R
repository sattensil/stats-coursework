########################################
#
#   function:   gram.schmidt
#
#      input arg:     V, a matrix
#
########################################

gram.schmidt <- function(V)
{ # start gram.schmidt function

  if ( !is.matrix(V) ) { stop('input must be a matrix.\n') }

  m = ncol(V)
  R = matrix( rep(0,m^2), ncol = m)
  for ( k in 1:(m-1) )
    {                   # work on vector k                     
      R[k,k] = sqrt(sum(V[,k]*V[,k]))    # compute norm(kth column of vector)
      if ( R[k,k] == 0 ) { return(NULL) }
      V[,k] = (1/R[k,k])*V[,k]           # normalize kth column of V

      for ( j in (k+1):m )
        {                 # remove projection of V[,j] on V[,k]
           R[k,j] = sum(V[,j]*V[,k])
           V[,j]  = V[,j] - R[k,j]*V[,k]
        }                 # remove projection of V[,j] on V[,k]
    }                   # work on vector k
  
  R[m,m] = sqrt(sum(V[,m]*V[,m]))
  if ( R[m,m] == 0 ) { return(NULL) }
  V[,m] = (1/R[m,m])*V[,m]
  return( list(Q = V, R = R) )
} # end   gram.schmidt function

##