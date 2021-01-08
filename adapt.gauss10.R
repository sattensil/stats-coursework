#######################################################################
#
#     function   adapt.gauss10
#
#     input args:
#                    f,        the function to be integrated
#                    a,        lower integration limit
#                    b,        upper integration limit
#                    tol,      tolerance that determines if we
#                              will continue the recursion
#
#     inner function is recursive.f which itself has an
#     inner function inner.f  This last function, inner.f, merely
#     does 10 point Gaussian integration on the limits it is provided.
#
#     The recursive.f function calls inner,f on the limits it is given
#     and breaks the function limits into two pieces. If the integration
#     in inner.f for the two halves of the limit is close (within relative
#     tolerance) to the integration on the entire limit we return the sum
#     of the two half integrations. Otherwise, we call recursive,f with two
#     new limits.
#
############################################################################
                              
adapt.gauss10 <- function(f,a,b,tol=1.0e-8)
{ #adapt.gauss10

     ##############################################
     #   
     #   recursive.f does the work. We set w and z
     #   once, outside of the recursive.f function.
     #   Then recursive.f uses R's scoping rules to
     #   access w and z.
     ##############################################
     recursive.f <- function(f,a,b,tol)
       { # this does the recursion
          ###  inner.f does the Gaussian quadrature
          inner.f <- function(f,a.in,b.in)
            {
              z.p = 0.5*( (b.in-a.in)*z + (b.in+a.in) ) # translate to [-1,1]
              s = 0.5*(b.in-a.in)*f(z.p)
              return(sum(w*s))
            }
          ###  end of inner.f
   
          int.ab = inner.f(f,a,b)
          mid    = 0.5*(a+b)
          if ( (mid == a) || (mid == b) )
            { # there is no representable value between a and b
                stop("tol parameter needs to be increased.\n")
            } # there is no representable value between a and b
          l      = inner.f(f,a,mid)
          r      = inner.f(f,mid,b)
          if (  abs(l + r - int.ab) > tol*abs(int.ab) )
           {
             l.recursive = recursive.f(f,a,mid,tol)
             r.recursive = recursive.f(f,mid,b,tol)
             return(l.recursive + r.recursive)
           }
         else
           {
             return(l+r)
         }
       } # this does the recursion

    #################################################
    #  start execution
    #################################################

    if ( !is.function(f) ) { stop('f must be a function.\n') }
    if ( !is.numeric(a) || length(a) != 1 ) { stop('a must be numeric length 1.\n') }
    if ( !is.numeric(b) || length(b) != 1 ) { stop('b must be numeric length 1.\n') }
    if ( a == b ) { reurn(0) }
    if ( a > b )  { stop('We must have a <= b.\n') }
    if ( !is.numeric(tol) || length(tol) != 1 ) { stop('tol ust be numeric length 1.\n') }
    if ( tol < 1.0e-16 ) { stop('Minimum value for tol is 1.0e-16.\n') }

     ########   w is the weight vector and z is the
     ########   vector of locations where the function is evaluated.
     w1  = c( 0.2955242247147529, 0.2692667193099964,
              0.2190863625159820, 0.1494513491505806,
              0.0666713443086881)
     w   = c(w1[5:1],w1)

     z1  = c(0.1488743389816312, 0.4333953941292472,
             0.6794095682990244, 0.8650633666889845,
             0.9739065285171717)
     z2  = -z1[5:1]
     z   = c(z2,z1)

    #### now do the work
    return(recursive.f(f,a,b,tol))

} #adapt.gauss10







#####################################################################
#
#       adaptive gauss
#
#    Similar to adapt.gauss10 except
#
#    (1) it plots the splits
#    (2) it uses 5 point Gaussian integration
#####################################################################

call.adapt.gauss5<-function(f,a,b,tol.1 = 1.0e-60,tol.2=1.0e-10)
{

  dev.new();
  xp = seq(a,b, length = 2001)
  plot(xp,f(xp), type = 'l', main = 'Adaptive Gaussian Integration')
  return(adapt.gauss5.plot(f,a,b,tol.1,tol.2))                          
}

adapt.gauss5.plot <- function(f,a,b,tol.1 = 1.0e-60,tol.2=1.0e-10)
{
  
  w1  = c( 0.5688888888888889, 0.4786286704993665, 0.2369268850561891)
  w   = c(w1[3:2],w1)

  z   = c(-0.9061798459386640, -0.5384693101056831, 0,
          0.538469310105683, 0.9061798459386640)
  
  inner.f <- function(f,a.in,b.in)
    {
       z.p = 0.5*( (b.in-a.in)*z + (b.in+a.in) ) 
         s = 0.5*(b.in-a.in)*f(z.p)
       abline(v = a.in, col = 'blue')
       abline(v = b.in, col = 'blue')
       points(z.p,f(z.p),col = 'red',cex=0.2)
       return(sum(w*s))
    }
  int.ab = inner.f(f,a,b)
  mid    = 0.5*(a+b)
  l      = inner.f(f,a,mid)
  r      = inner.f(f,mid,b)
  if ( (abs(int.ab) > tol.1) & abs(l + r - int.ab)/abs(int.ab) > tol.2 )
    {
      l.recursive = adapt.gauss5.plot(f,a,mid)
      r.recursive = adapt.gauss5.plot(f,mid,b)
      return(l.recursive + r.recursive)
    }
  else
    {
      return(l+r)
    }
}


