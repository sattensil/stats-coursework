###################
#
#   odds and ends
######################

################    unique ############################

## unique removes duplicates

x = c(1:20,15:25)
print(x)
u = unique(x)
print(u)

########################   which ##########################
#####  which gives locations 

m1 = which(x == 18)
print(m1)
length(m1)

#   suppose no element matches the which condition
m0 = which(x > 1000)
print(m0)
mode(m0)
length(m0)
storage.mode(m0)


m2 = which( (x == 18) & (u == 18) )    #### note the recycling
print(m2)

m3 = which( (x == 18) | (u == 18) )    ##### and here
print(m3)

### now try &&

which( x == 18 && u == 18 )

####  recall && does not work on vectors whose length is greater than 1

##### The && only looks at the first x and first u
which( x == 1 && u == 1)

y = c(3,9,4,-6,0,5,9,6,-1)
which.max(y)
which.min(y)

#### notice which.max and which.min do not tell you how many max/min
#### there may be

### here is a little function I wrote to return indices of all
### the values equal to the maximum
where.all.max <- function(x) 
{ # begin where.all.max
   return( which(x == max(x)) )
} # end whereall..max

where.all.max(y)

###  many times you see people write R code with expressions like
###  which(x == max(x)) without telling you what is going on. And there
### are many more complicated ways of combining R functions that do very
### nice and useful things.

### the intent of these complicated expressions should be put in comments.
### if you find yourself using one of these useful, but tricky, things
### you might make it into a function with a meaningful name, and this
### will make your code easier to understand

### unique does not give us a count for its entries. R can do it nicely

### recall u has the unique elements of x

count = numeric(length(u))
for ( i in 1:length(u) )
   {
       count[i] = length(which(x == u[i]))
   }
### is our answer right?
( sum(count) == length(x) )
( sum(x) == sum(u*count) )

print(count)

### note that in R the u*count is element by element multiplication
### R was written by statisticians, not by numerical linear algebraicists


#####  %in%      ##################################

( 13 %in% x )   # is 13 in x?
( 1.5 %in% seq(0,4,0.5) )
( 1:10 %in% c(4,5,6,9,12) )

##### match       ##################################
##### match(x,y,nomatch = z)
####  this looks in y for first matching value of x
####  if there is no match, then z is returned. You can
####  leave out the nomatch, and then NA is returned for no match

a = c(1,3,5,7,8,9,10,11,3)
b = c(3,3,6,8,9,13)

v = match(a,b)
length(v)
v
# note the length of match(a,b) is the same as the length of a
# Since a[1] is not found in b, v[1] is set to NA
# Since a[2] is found at b[1], v[2] is set to 1
#              Note that the match with b[2] is ignored.
#              That is, match() does not tell you where all the matches occur.
match(a,b,nomatch = -1) 

#######################   union and intersect  ##############################
### just what you expect
union(a,b)
intersect(a,b)

vv = c(4,2,NA)
w  = c(4,NA)
intersect(vv,w)

##### One general note. There is no uniformity in R about the treatment
##### of NA and NaN values. Some funtions will not distinguish between
##### NA and NaN, but some will.

#### any and all   ######################################################

if ( any(a %% 5 == 0) ) {print("a has multiples of 5")}
if ( all(a %% 5 == 0) ) {print("a has only multiples of 5")}
if ( all(a > 0) ) {print("a has only positive values")}

### we can accomplish the last with
if ( min(a) > 0 ) { print("a has only positive values") }

##  or with
if ( prod(a > 0) ) {print("a has only positive values") }
##### there are many ways to accomplish the same thing in R

##### I will suggest that if you have many of the unique, which,
##### %in%, etc combined in one statement you may get it to work
##### once, but even the next day you won't understsand it.

##### For clarity I suggest breaking it into multiple statements
##### with pertinet comments

#####################   ifelse ###############################

#       This works as one expects
u = 4
v = 2.6
ifelse( u > v, 2*u, 2*v) # if <condition> is true first is done, else second


v = 10
ifelse( u > v, 2*u, 2*v)

### but ...
a = c(4,2,3)
b = c(-1,1,5)
ifelse(u > 0,a+b,a-b) 
##### u > 0, but it only adds the first elements of a+b.
#####        it does not add the whole vector.

######   ifelse is vectorized. Since the length of u > 0 is 1,
######   only the first addition is done. One might expect that
######   u > 0 vector will be recycled (R recycles vectors in many contexts),
######   but not in this case.

######   We can use rep to manually recycle the U > 0 condition
d = ifelse( rep(u > 0, length(a)), a+b, a-b)
print(d)

######  Here is an intended use of the vectorized ifelse

u = c(5,3,7,2)
v = c(2,12,4,3)

x = c(1,2,3,4)
y = c(5,6,7,8)

z = ifelse( u > v, x+y, x-y)

print(z)

# ifelse is the one statement which can use a vector condition

# This code is equivalent to the ifelse above
z = numeric(length(u))
for ( i in 1: length(u) )
  {
     if ( u[i] > v[i] )
       {
         z[i] = x[i] + y[i]
       }
     else
       {
         z[i] = x[i] - y[i]
       }
   }
print(z)

# Note that if we have to perform more than one statement for the if clause and/or more than
# one staement for the else clause we can easily do so in the if statement contained in the for loop

#  Here is a third way to code a solution
z1 = x +(2*(u > v) - 1)*y

print(z1)

#      How does it work?
#      Recall u > v will give a logical vector. 
#      2*(u > v) converts all TRUEs to 1 and all Falses to 0. The converted value
#      is multiplied by 2.
#      Then the -1 is recycled and applied to the numeric 2*(u > v) vector.
#      Convince yourself that for indices where u > v, 2*(u >v) -1 is converted to 1,
#      and when u > v is False, 2*(u>v) -1 is converted to -1.

#      Hence we have y added to x or subtracted from x.





##### Now for a quick introduction to matrices

##### first way

x = 1:10
y = 101:110
z = 201:210

m = cbind(x,y,z)  # combines vectors of equal length into a matrix
                  # x becomes the first column, y the second, etc.
print(m)          # note the column names
dim(m)            # gives dimension. just like length for a vector
dim(m)[1]         # number of rows
dim(m)[2]         # number of columns
is.matrix(m)
m[2,3]          # reference one element
m[,2]           # reference column 2. The "," means let the first index
                # range form first row to last row
m[,"z"]         # access column named z
sum(m[,1])
m[3,]           # access the third row
length(m[,1])   # if you forget about dim

nrow(m)
ncol(m)
##### second way

mr = rbind(x,y,z)   # bind the vectors by row
print(mr)
dim(mr)

##### a third way
m.new = matrix( c(x,y,z), nrow = length(x)) # do not need to specify num.
                                            # of columns 
print(m.new)
m.row = matrix( c(1,2,3,4,5,6,7,8,9), nrow = 3) # default is to fill by col
print(m.row)
m.row = matrix( c(1,2,3,4,5,6,7,8,9), nrow = 3, byrow = TRUE)
print(m.row)

########  The switch statement

#   switch(expression,s1,s2,s3,s4,s5) for example
#   if expression = 1, then s1 is executed.
#   if expression = 2, then s2 is executed, etc.
#   expressn should evaluate to an integer

n = 2
a = switch(n,
           3*n,
           3^n,
           3/n,
           3 + n)
print(a)
n=4
a = switch(n,
           3*n,
           3^n,
           3/n,
           3 + n)
print(a)

n = 6
a = switch(n,
           3*n,
           3^n,
           3/n,
           3 + n)
print(a)

###      Equivalent code

###    if ( n == 1 )
#        { a = 3*n )
#      elseif ( n == 2 )
#        { a = 3^n }
#      elseif ( n == 3 )
#        { a = 3/n }
#      elseif ( n == 4 )
#        { a = 3 + n }
#      else
#        { a = NULL }

####   if you want to do more than 1 thing
n = 3 
a = switch(n,
           c(3*n,exp(n)),
           c(3^n,sin(n)),
           c(3/n,5),
           c(3+n, n^2))
print(a)

#   or if you want to do something very complicated
#   you could write a function for each case.
#
#    a = switch(n,
#               f1(n),
#               f2(n),
#               f3(n) )


#####    naming vector elements ##############################

ci = c('lwr' = 34.6, 'upr' = 39.7)
ci['upr']
ci[2]

####    Using names can make your code easier to understand and easier to change.

# Suppose you have written some code that refers to ci['upr'] instead of ci[2]
# Then suppose you need to change your ci to have three values

ci = c('lwr' = 34.6, 'mid' = 36.15, 'upr' = 39.7)


#  Now all code in which you use ci['upr'] or ci['lwr' will still work.
#  Had you used ci[2] to refer to ci['upr'] you would have to change ci[2] to ci[3].

# If you wish to find the names of a vector:

names(ci)


x = c(3,6,7,8)
x
names(x) # x has no nmaes

# set the names of x
names(x) = c("a","b","c","d")
x
names(x)

# remove names from a vector
names(x) = NULL
x

#####    vector multiplication and other vector operations ##############

a = c(3,9,4,2)
g = c(5,6,7,8)
print(a*g)

##   note that multiplication is element by element.
##   Of course this is not the mathematical definition of vector multiplication.

norm(a)       # does not give the norm of a matrix

x = c(2,3,5)
y = c(4,1,2)

#  what is the cross product of x and y

crossprod(x,y)

sum(x*y)   # this is the dot product of x and y

# Mathematically the cross product of x and y is another vector.

####   more examples

x = c(4,5)
y = c(2,3)

crossprod(x,y)
sum(x*y)

# Mathematically the cross product of x and y is not well defined.

# crossprod really gives the dot product. Why doesn't R just call it the dot product?
# You will see that R frequently does silly things like this.

# If you wish to compute a dot product of two vectors named u and v use sum(u*v).
# If you use crossprod(u,v) you will confuse other people. They might innocently think crossprod()
# will compute the cross product.

# It reminds one of Alice in Wonderland. R just redefines mathematical concepts as it pleases.
# Why conform to everyone else's definition? 

# If you want the Euclidean norm of a vector v, use sqrt(sum(v*v))
#

vec.norm2 <- function(v)
  { # begin norm2
#                    check arguments
    if ( length(v) == 0 ) { stop(' v has zero length.') }
    if ( !is.vector(v) )  { stop('argument is not a vector') }
    if ( !is.numeric(v) ) { stop('argument is not a numeric vector') }
    if ( any(is.na(v)) == TRUE ) { stop('numeric vector contains NA or NaN value(s)') }

    return( sqrt(sum(v*v)) )
  } # end norm2

####    a more complicated version which handles NA and NaN values

vec.norm2 <- function(v, na.rm = FALSE)
  { # begin norm2
#                       check arguments
    if ( length(v) == 0 ) { stop(' v has zero length.') }
    if ( !is.vector(v) )  { stop('argument is not a vector') }
    if ( !is.numeric(v) ) { stop('argument is not a numeric vector') }
    na.found = any(is.na(v))
    if (na.found)
      { # NA or NaN in v
        if ( length(na.rm) != 1 ) { stop("na.rm must have length 1.") }
        if (na.rm == 1) { na.rm = TRUE  } # allow 1 and 0 values for na.rm
        if (na.rm == 0) { na.rm = FALSE }
        if ( !is.logical(na.rm) ) { stop("na.rm argument must be logical.") }
        if ( na.rm )
          { # remove NA or NaN
             warning("NA or NaN values found in argument.")
             v = v[which(is.na(v) == FALSE)]
          } # remove NA or NaN
        else
          { # error
             stop("NA or NaN values found in argument.")
          } #error
      } # NA or NaN in v 

    return( sqrt(sum(v*v)) )
  } # end norm2

#########     defining your own binary operators #######################

# In R, binary operators are functions

6 + 9

'+'(6,9)

#   '+' is a binary function thats adds 6 and 9

#    Suppose you want to add 2 vectors but do not want to allow recycling.

'%v+%' <- function(x,y)
  { # begin function
     if ( !( is.vector(x) && is.vector(y) ) ) { stop("At least one argument is not a vector.") }
     if ( !( is.numeric(x) && is.numeric(y) ) ) { stop("At least one argument is not numeric.") }

     if ( length(x) != length(y) ) { stop("unequal vector lengths") }
     if ( length(x) == 0 )         { return(NULL)  }
 
     return(x+y)
  } # end function

a = c(3,6,9)
b = c(7,2,11)

a %v+% b

b = c(7,2)

a %v+% b

b = c("a",2,3) # a vector must have one type.
               # numbers can be converted to characters, but we do not convert characters to numbers.
               # in general if c() contains mixed types, we convert to the most general
b

a %v+% b

