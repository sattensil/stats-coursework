
###################     1       ####################################
################### bubble sort ####################################

####################################################################
#
#    function name: sort.b
#        input argument is x.
#                x must be a numeric vector
#                it must have a positive length
#
#        output is a vector containing the sorted values of x
#               in ascending order
#
#   This function implements the bubble sort algorithm.
#   Given a vector x[1:n], we can place the maximum value of x[1:n]
#   into location n.
#   We can do this by comparing x[j] with x[j+1] and switching the locations
#   when x[j] > x[j+1]. If we start with j = 1, increment j by 1, and stop when j = n-1,
#   we guaranteed to have the maximum element of x[1:n] in location x[n]
#   Now we consider the vector x[1:(n-1)]. 
#   As before, comparisons of x[j] and x[j+1] will result in x[n-1] having the maximum
#   element of x[1:(n-1)]. Note we end the comparison with x[n-2] and x[n-1]. There is
#   no need to compare x[n-1] with x[n].
#   It should be clear we now have the largest two elements in x[(n-1]:n].
#
#   We proceed with the same process, each time working on a vector with one less element.
#
#   The implementation uses an outer loop and an inner loop. The outer loop starts by
#   working on a vector of size n, then size n-1, etc. until we have a vector of size 2.
#   The inner for loop moves the maximum of the subvector to the last location of the subvector.
####################################################################

sort.b <- function(x)
{ # sort.b
  
   if ( !is.vector(x)  ) { stop("x must be a vector.\n")      };
         # need to verify x is not a list becaue is.vector() returns TRUE for a list
   if ( is.list(x)     ) { stop("x cannot be a list.\n")      );
   if ( any(is.na(x)   ) { stop("x has NaN or NA values.\n")  };

   n = length(x)
   if ( n == 1 ) { return(x) }
   if ( n < 1 )  { stop("length of x < 1.\n") };

   for ( i in n:2 )
      {  # loop i works on vector of size n, then n-1, then n-2, ... down  to 2
         for ( j in 1:(i-1))
            { # loop j pushes max element of x[1:i] to x[i]
               if ( x[j] > x[j+1] )
                  { # switch
                     t      = x[j]
                     x[j]   = x[j+1]
                     x[j+1] = t
                  } # switch
            } # loop j pushes max element of x[1:i] to x[i] 
      }  #  loop i works on vector of size n, then n-1, then n-2, ... down  to 2

   return(x)
} # sort.b	

