
################################################################
#
#        This works
#
#
#       We start by building a 1x1 matrix containing all permutations
#       of v[1].
#
#       From that, we then build a new matrix containing all permutations
#       of v[1] and v[2].
#
#       We then continue until a matrix is built containing all permutations
#       of v[1] through v[n]
#
#
#       Illustration of going from 2 to 3 (assume input vector is sequence 1:n
#
#       Start
#                     1    2
#                     2    1
#
#       Now we want to insert 3 into both rows.
#       Note that when we expand the first row we will get
#       3 1 2, then 1 3 2, then 1 2 3.
#       That is 3 can be inserted before the first element, before the second element,
#       then after the third element.
#
#       So first row of Sterting matrix expands to 3 rows (since it had two columns, we
#       have 3 choices where to put the 3.
#
#       Then we expand the second row of the start matrix in the same manner.
#
#       We name the start matrix p
#       The new matrix is new.p
#       The job of the for i loop is to compute the new.p matrix from p and v[i]
#
#       We know the number of columns of new.p = i
#       and we know we will generate i rows for each row of p.
#       Hence dimensions of new.p are i*dim(p) x i, or i! x i.
#
#       The job of the for j loop is to expand the jth row of p
#       and inert them (suitably augmented by placing the new value
#       v[i] into the row, so new.p will have i columns.
#
#      The for k loop has the job of actually moving v[i] from
#      its starting position, which is before the first element of
#      of the p matrix, and then moving v[i] until it becomes the last element.
#
#      Something a little ugly is that when k = i, t[k+1] is NA. However, this
#      is done at the end of the k loop, during the last iteration so the NA
#      value is actually never used.

################################################################


gen.perm <- function(v)
{ # gen.perm

  if ( !is.vector(v) ) { stop('argument must be a vector\n') }
 
  n = length(v)
  if ( n < 1 ) { stop('argument length is 0\n') } 
  if ( n == 1) { return(as.matrix(v)) }

  if ( n > 10 ) { stop('we only allow lengths of 10 or less\n') }

  p = matrix(v[1], ncol = 1)

  for ( i in 2:n )
    { # i loop
       new.p = matrix( rep(0,prod(2:i)*i), ncol = i )
       
       num.c = ncol(p)
       num.r = nrow(p)
       offset = 0
       for ( j in 1:num.r)
         { # j loop
             t       = c(v[i],p[j,])
             for ( k in 1:i )
               { # for k
                 new.p[offset+k,] = t
                 temp             = t[k]
                 t[k]             = t[k+1]
                 t[k+1]           = temp
               } # for k 
             offset = offset + i   
         } # j loop
      p = new.p
    } # i loop
         
  return(p)  

} # gen.perm

###