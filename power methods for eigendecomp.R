####################################################################
#
#     power method for computing largest magnitude
#     eigenvalue and associated eigenvector
#
####################################################################

power.method <- function(A,x.0,tol = 1.0e-6,max.iter = 2000)
{ # power.method


  norm2 <- function(x) { return( sqrt(sum(x*x)) ) }
  stopifnot( is.matrix(A) )
  stopifnot( nrow(A) == ncol(A) )
  stopifnot( is.vector(x.0) )
  stopifnot( nrow(A) == length(x.0) )
  stopifnot( length(tol) == 1 )
  stopifnot( is.numeric(tol) && (tol >= 1.0e-16) )
  stopifnot( length(max.iter) == 1 )
  stopifnot( is.numeric(max.iter) && (max.iter > 0) )

###   get first estimate of lambda before entering while loop

  x.old      = x.0/norm2(x.0)
  x.new      = A%*%x.old
  lambda.old = t(x.new)%*%A%*%x.new
  x.old      = x.new/norm2(x.new)
  count      = 1                     # first iteration complete

  while ( count <= max.iter )
    { 
      count      = count + 1
      x.new      = A%*%x.old
      x.new      = x.new/norm2(x.new)
      lambda.new =  t(x.new)%*%A%*%x.new      # Rayleigh Quotient
      ratio      = lambda.new/lambda.old
      if ( abs(ratio-1) < tol ) {break}  # break if convergence achieved
      x.old      = x.new
      lambda.old = lambda.new
  }
 # x   = x.new/norm2(x)
  return( list(lambda = lambda.new, vector = x.new) )  
}


###############################################################################
#
#         inverse power method to calculate the smallest magnitude
#         eigenvalue and associated eigenvector
#
###############################################################################

inverse.pow <- function(A,x.old,tol = 1.0e-6,max.iter = 50)
{ # inverse.pow

  stopifnot( is.matrix(A) )
  stopifnot( nrow(A) == ncol(A) )
  stopifnot( is.vector(x.old) )
  stopifnot( nrow(A) == length(x.old) )
  stopifnot( length(tol) == 1 )
  stopifnot( is.numeric(tol) && (tol > 0) )
  stopifnot( length(max.iter) == 1 )
  stopifnot( is.numeric(max.iter) && (max.iter > 0) )

      #### test to see if A is numerically singular

  temp = try(solve(A,x.old),silent = TRUE)
  if ( is.numeric(temp) == TRUE )
    { # A is ok
      singular = 0
    } # A is ok
  else
    { # make A ok
      singular = 1
      A = A - diag(rep(1/256,nrow(A))) # shift eigenvalue
    } # make A ok


  count = 0
  x.m2  = rep(0,nrow(A))
  x.old = x.old/max(abs(x.old))
  while ( count <= max.iter )
    {
      count = count = 1
      x.new = try(solve(A,x.old),silent = TRUE)
      if ( is.numeric(x.new) == TRUE )
        { # solve worked
          x.new = x.new/max(abs(x.new))
          del   = x.new - x.m2
          x.m2  = x.old
          x.old = x.new
          if ( max(abs(del)) < tol ) {break}
        } # solve worked
      else
        { # A is nearly singular
           x.new = x.old
           break
        } # A is nearly singular
    } # end while

##  do a shift to polish the final answer

  lam.tentative = t(x.new)%*%A%*%x.new/(t(x.new)%*%x.new)
  shift         = diag(rep(lam.tentative,nrow(A)))
  A.shift       = A - shift
  x.try         = try(solve(A.shift,x.new), silent = TRUE)
  if ( is.numeric(x.try) == FALSE )
    { # system was nearly singular
      norm.x.new = sqrt(sum(x.new*x.new))
      return(list(lambda = lam.tentative + singular*(1/256), vec = x.new/norm.x.new))
    }
  else
    {  print(x.try)
      lam.final     = t(x.try)%*%A%*%x.try/(t(x.try)%*%x.try)
      norm.x.try    = sqrt(sum(x.try*x.try))
      return( list(lambda = lam.final + singular*(1/256), vec = x.try/norm.x.try) )
    }
}  # inverse.pow

####################################################################################
#
#          power.both
#
#    This runs the forward power method to get an approximation to the
#    dominant eigenvalue.
#    Then we shift the diagonal of the matrix by the approximate value of
#    the dominant eigenvalue. We run inverse power iteration on the
#    shifted matrix to polish the forward power estimate.
#
####################################################################################

power.both <- function(A,x.old,tol = 1.0e-6,max.iter = 50)
{ # power.both

  stopifnot( is.matrix(A) )
  stopifnot( nrow(A) == ncol(A) )
  stopifnot( is.vector(x.old) )
  stopifnot( nrow(A) == length(x.old) )
  stopifnot( length(tol) == 1 )
  stopifnot( is.numeric(tol) && (tol > 0) )
  stopifnot( length(max.iter) == 1 )
  stopifnot( is.numeric(max.iter) && (max.iter > 0) )

  n = nrow(A)

  pow = power.method(A,x.old,tol,max.iter)
  v   = as.vector(pow$vector)
  l   = pow$lambda

  A   = A - diag( rep(l,n) ) # move eigenvalue to zero
  p = inverse.pow(A,v,tol,max.iter=10)
  return( list("lambda" = p$lambda + l, "vec" = p$vec) )

 } # power both

############################################################################
#
#     hotelling deflation
#
#      default is not to use inverse power iteration to refine eigenvalues
#
###########################################################################

hotelling <- function(A,tol = 1.0e-12,refine = FALSE)
{ # hotelling deflate

  stopifnot( is.matrix(A) )
  stopifnot( nrow(A) == ncol(A) )
  A.t = t(A)
  m   = A.t - A
  stopifnot(max(abs(m)) < 4*.Machine$double.eps)
  stopifnot( length(tol) == 1 )
  stopifnot( is.numeric(tol) && (tol > 0) )
  stopifnot( is.logical(refine))
  stopifnot( length(refine) == 1)

  A.orig = A
  n      = nrow(A)
  x      = rep(1,n)
  value  = numeric(n) 
  v      = matrix( rep(0,n^2), ncol = n)
  for ( i in 1:n)
    {
       t = power.method(A,x,tol)
       if ( refine == TRUE )
         {
           shift    = diag(rep(t$lambda,n))
           A.shift  = A.orig - shift    # move dominant eigenvalue close to zero
           t.inv    = inverse.pow(A.shift,as.vector(t$vec),1.0e-10,5)
           value[i] = t.inv$lambda + t$lambda # add shift back
           v[,i]    = t.inv$vec 
           A        = A - value[i]*t.inv$vec%*%t(t.inv$vec)        
         } # refine is true
       else
         { # no refinement
           value[i] = t$lambda
           v[,i]    = t$vec
           m        = matrix(t$vec,ncol=1)
           A        = A - value[i]*m%*%t(m)  
         } # no refinement 
    }
  return( list(eigval = value, eigvec = v) )

} # hotelling.deflate

##############################################################################
#
#       hotelling.both
#
#       uses power.both to get eigenpair estimate before deflating
#
#  note that if eigenvalues are negative the eigenvalues may not
#  be returned in descending order. Should be fixed.
##############################################################################

hotelling.both <- function(A,tol = 1.0e-12)
{ # hotelling.both

  stopifnot( is.matrix(A) )
  stopifnot( nrow(A) == ncol(A) )
  A.t = t(A)
  m   = A.t - A
  stopifnot(max(abs(m)) < 4*.Machine$double.eps)
  stopifnot( length(tol) == 1 )
  stopifnot( is.numeric(tol) && (tol > 0) )

  A.orig = A
  n      = nrow(A)
  x      = rep(1,n)
  value  = numeric(n) 
  v      = matrix( rep(0,n^2), ncol = n)
  for ( i in 1:n)
    {
       t        = power.both(A,x,tol)
       shift    = diag(rep(t$lambda,n))
       A.shift  = A.orig - shift    # move dominant eigenvalue close to zero
       t.inv    = inverse.pow(A.shift,as.vector(t$vec),1.0e-10,5)
       value[i] = t.inv$lambda + t$lambda # add shift back
       v[,i]    = t.inv$vec 
       A        = A - value[i]*t.inv$vec%*%t(t.inv$vec)        
    }
  return( list(eigval = value, eigvec = v) )

} # hotelling.both


####################################################################
#
#        SVD using hotelling.both on A*t(A) and t(A)*A
#
#####################################################################

svd.power <- function(A,tol = 1e-12)
{ # svd.power
  stopifnot( is.matrix(A) )
  stopifnot( is.numeric(A) )

  m = nrow(A)
  n = ncol(A)

  ata = t(A)%*%A
  aat = A%*%t(A)

  ata.eig = hotelling.both(ata,tol) # V and sigma^2
  aat.eig = hotelling.both(aat,tol) # U and sigma^2

  v       = ata.eig$eigvec
  u       = aat.eig$eigvec
  if ( m > n )
    {
       sigma = sqrt(ata.eig$eigval)
       u     = u[,1:n]
    }
  else
    {
       sigma = sqrt(aat.eig$eigval)
       v     = v[,1:m]
    }
  
  return( list( "sigma" = sigma, "u" = u, "v" = v ) )
} # svd.power




