#############   Brief introduction to variables
#############      and vectors

############################################
#######   variables
############################################

#   One can think of a variable as a name for a chunk
#   of memory. In many progamming languages one must declare
#   all varaibles before using them. This is especially true
#   for languages that are compiled. The compiler allocates 
#   memory for each declared variable. Then the code is translated
#   to the instruction set used by the computer. This is the executable code. 
#
#          example using C language syntax
#    double x,y;   <the declarations>
#
#    x = 3.0;     /* the executable code */
#    y = 2*x;
#
#    z = x;       /* causes a compilation error. code will not run*/
#
#    in R (and Fortran) you don't have to declare a variable before
#    using it. 

#  We simultaneously allocate memory for x, and assign a value to x.  
x = 3.0 
print(x)

#    Here we note the above is called "an assignment statement"
#    The RHS is evaluated, and the value is stored in a memory
#    chunk called x. We can later read the value stored in x, and
#    use it in an assignment statement.
#    If we can evaluate the RHS of an assignment, we can save the
#    evaluation in a new variable.

y = 2*x
print(y)

#    For completeness, we add that instead of "=", we can use
#    "<-" in assignment statements. 

z <- exp(1)   # z gets the value of e = 2.718281828......
sprintf("z = %8.5f",z)    # a fancier way to print that
                          # gives you more control. For
                          # more info, type ?sprintf
sprintf('z = %1.11e',z)   # prints value is exponential notation.


### Take care. If you accidently type < - (space between < and -)
z < - exp(1)     # R interprets this as the expression "is z less than -exp(1)?". It then gives the
                 # logical value FALSE

#    Some people prefer "<-" for aesthetic reasons.
#    Some people also prefer "<-" because "=" and "=="
#    are easy to confuse. One types "=" when meaning "==",
#    for example. More about "==" later.

#    We can also use "->" for an assignment statement.
#    Now the LHS is evaluated and stored in the RHS.
#    I strongly recommend you NEVER do this. It is quirky,
#    and has no advantage. It makes your code harder to read.

5 -> w
sprintf("%d",w)  # %d for integers

#    From now on, we only use "=" or "<-" for assignments.


#    You cannot use a variable that has not been used before
#    on the RHS of an assignment statement. 

#    Here no value is known for the (non-existing) variable
#    a.b.c

x = 2*y + a.b.c    # note we can use "." as part of the name

#    This is a sensible reaction, because how does R know how
#    to calculate the RHS when it doesn't know the value of a.b.c?

#    Variable names 

#    Ordinary variables start with a letter (a-z,A-Z). R is case
#    sensitive. After the letter, we may append as many other letters,
#    numerals (0-9), underscore (_), or dots (.) as we please.

#   These are valid names

x.2 = 6
x2  = 61
x_2 = 61


#   These are not.

0x = 4
_x = 4

a.very.long.name = 3*cos(x)

#
#    suppose there is a lot of intervening code here
#

a.very.long.nme = log(y)  # you meant a.very.long.name = log(y)
x               = 2*a.very.long.name

#    At this point x does not have the value you intended.
#    This will lead to incorrect results, and then you must debug.
#    Since you are not a computer, when you scan your code
#    it is VERY likely (do trust me on this) you will not notice
#    the typo.

#    An aside on your workspace before we debug. If you want to
#    know the variables in your workspace use

ls()

#    We can remove a variable. For instance,

rm(w)   # Important note: rm(w) removes your ability to access the
        # object w; it does not delete the memory for the object.
        # (John Chambers, Software for Data Analysis, p.472)
        # R will run garbage collection when it feels like it
        # to free this memory up

#   In fact, when we use an assignment statement, such as a = 5,
#   a is a pointer to the chunk of memory that holds the value of a.
#   A pointer is a variable that contains an address of a memory location.
#   The C language allows pointer variables, and R is essentially a C 
#   program that interprets R statements. In R we cannot directly perform
#   pointer operations. You could write code in R and be blissfully unaware 
#   that a is a pointer to a chunk of memory that contains the variable a.
#   One thing this shows is that R uses more memory than necessary. 

#   To remove everything from your workspace type: rm(list=ls())
#   Don't worry now why this command works. 
#   The best way to track down the problem of mistyped
#    variables is:
#    clear your workspace 
rm(list=ls())  # this removes all variables.

#   Rerun your code
x = 3.0
y = 2*x
z <- exp(1)

 a.very.long.name = 3*cos(x)

#
#    suppose there is a lot of intervening code here
#

a.very.long.nme = log(y)  # you meant a.very.long.name = log(y)
x               = 2*a.very.long.name

#  now issue
ls()

# Now look for variable names you do not expect. Then you can use
# an editor to find where the misspelling occurred.

# Note that if R required variables to be declared before assigning values to the
# variable, then the assignment to a.very.long.nme would have caused an error.
# The declare before use policy of languages like C make them more robust.
# The R policy makes it less cumbersome to write code. 

# Nicely organized code is easier to read and debug. When I have
# several assignment statements occur consecutively I find it
# much easier to line up the "=" sign. Remember that when you
# enter code, you type it once, but you read it hundreds of times.

#       Example

#     a.factor = 2*cos( 3*asin(y^2) )
#     a.much.bigger.var = a - b + exp(sqrt(y))
#     j = 3
#     very.important = floor(a.factor -j)
#     do.not.forget.this.ever = log(1-x)

#     a.factor                = 2*cos( 3*asin(y^2) )
#     a.much.bigger.var       = a - b + exp(sqrt(y))
#     j                       = 3
#     very.important          = floor(a.factor -j)
#     do.not.forget.this.ever = log(1-x)

#     Which code would you rather read?

#     Also be liberal in the use of spaces

#     2*sqrt(3+log(y-atan(4*uvw))+ cos(theta))   
#     2*sqrt(3 + log(y - atan(4*uvw)) + cos(theta))

#    or    a+abc*de-f    vs.    a + abc*de - f   


# Another insidious problem for which there is no easy solution:
# Suppose you have variables named v.1, v.2, v.3, and v.4

# Some of your code will be similar so you cut and paste the following code

#     a.1 = 3*v.1
#     b.2 = 6 - v.1*v.2

# after cutting and pasting, and making what you think are
# the necessary changes you get

#     a.3 = 3*v.3
#     b.4 = 6 - v.1*v.4

# You wanted

#     a3 = 3*v.3
#     b.4 = 6 - v.3*v.4

# You get an error and need to debug. If you can't find the
# bug quickly, 
# You have to slow down. Don't scan your code. A human being
# is intelligent (aren't we?),and makes inferences. Your natural
# reaction is to read the code as you read anything. You will
# interpret what you read to be intelligible. Make a conscious
# effort to mimic a computer. Don't read a variable, or a line
# of code, quickly. 
# Read your code one CHARACTER at a time, as a computer does. Stop
# after each character, and ask yourself "Is this what I wanted?"
# This is what you must do if you get syntax errors from the R
# interpreter.If you read "b.4 = 6-v.1*v.4" one character
# at a time, you are much more likely to notice the incorrect v.1
 

# Read the next two lines at your normal speed

#               Paris  in
#             in the spring

#  Most people think it reads "Paris in the spring".

################################################
#
#          vectors
#
################################################

#### you can create a vector in many ways.

#  one way is to use the c() function. think of this as concatenate.
#  c() will make a vector from the values that are separated by commas.
x = c(1,2,3,4,5,6,7,8,9,10)
print(x)
is.vector(x)       # tests whether x is a vector. Gives back the logical value TRUE or FALSE
                   # Note: is.vector(x) returns TRUE if x is a list
                   # more on this later

x2 = c(5)          # has the same efect as x2 = 5
print(x2)

y = 5.6
is.vector(y)

##     even y is a vector

##   We would ordinarily think y is a scalar, but in R it is a vector.
#    We do not officially have scalars in R, but a vector of length 1 can
#    be treated as a scalar for all practical purposes.

# another way to create a vector is using the colon (:)

x.2 = 1:6
print(x.2)
is.vector(x.2)
is.vevtor(1:6)

x.3 = 8:3
print(x.3) 

# by the way we can display the value of x.3 to the console without using the print funtion
x.3
 
x.4 = 3.7:6.5
x.4

a = 3
b = 9

a:b        # the colon can use variables to make a sequence

a = 6.5
b = 4.3
a:b

# note that when a < b we have an ascending sequence and when a > b we have a descending sequence.
# the absolute value of the interval between consecutive sequence values is 1. We start at a and
# increment (or decrement) by 1 until we cross the boundary marked by b.

n = 20
z = 11:n     
x = 1:10

# operations can be applied to vectors 
s = x + z    # example of vector addition
print(s)  

s1  = 2*x    # each element is doubled
print(s1)

s2  = x^2    # each element is squared
print(s2)

sum(x)       # all elements are summed together
             # notice there is no assignment
             # the result is printed, but lost
             # We have to recalculate it if we want it

mean(x)      # there are many useful functions available
var(x)

#############  vector addition and recycling
#############

u = c(2,4,6,8,10,12)
v = c(1,2,3)

###          Even though u and v differ in length, we can still add the vectors.
###          The shorter vector is "recycled".

w = u + v
w

###          note that w[1] = u[1] + v[1]      w[2] = u[2] + v[2]      w[3] = u[3] + v[3]
###                    w[4] = u[4] + w[1]   since ther is no w[4],
###                                         we just cycle back the v index to 1
###                    w[5] = u[5] + w[2]
###                    w[6] = u[6] + w[3]

x = c(10,v)
x

w = u + x
w

####     Note the warning when the length of the shorter vector will not divide the length of
####     the longer vector

####     We can use vector recycling to add a constant to a vector
####     here 1 is treated as a vector of length 1 whose only value is 1.
w = u + 1
w

x.2 = c(1+3,5,6/0)  # We can have Inf values
print(x.2)
mean(x.2)


s.3 = 2^(x)        # R is VERY powerful
print(s.3)
print(x)           # reminder of the values of x
s.4 = log2(s.3)
print(s.4)

###   We can build new vectors from old ones

a.new = c(x,z)
print(a.new)
a.new = c(a.new,0,0,1,s2) # redefine a.new
print(a.new)

####  Use seq() to build more general sequences than by using the colon operator

a.new = seq(from = 1, to = 200, by = 1)
a.new[3]
length(a.new)
a.new = seq(1,10,2)  # do not need "from". etc.
print(a.new)

a.new = seq(0,1,0.1)
####    what is the length of a.new?
length(a.new)
print(a.new)

####            sometimes people do this
a.new = seq(from = 0, to = 1, length = 10)
print(a.new)

####            when they wanted this result
a.new = seq(from = 0, to = 1, length = 11)
print(a.new)


###   apply operations to a vector

v = c(2,3,5,6,8)
print(v^2)

###   apply a vector to a function
v = c(0,pi/4,pi/2,3*pi/4,pi)
sin(v)

# note the value for sin(pi). 

###  Note seq is very useful. Type "?seq" or
###  help(seq) for more information.
###  This applies to all the functions in R

###  Two helpful hints.
###  (1) Sometimes you will forget the exact name of a 
###      function, but know it contains a certain character
###      string. Suppose you know it has "lin" in its name.
###      use (apropos("lin"). This prints all functions
###      containing tha string.

apropos("lin")

###  hint (2). The documentation for most R functions
###  contain examples.You can run the examples for the seq
### function by typing

example(seq)

####### note the seq> prompt from this command
####### One last seq example from John Chambers
seq(-0.45,0.45,0.15)

#### better to do it this way
seq(-3,3,1) * 0.15

a.new = runif(20000) # this generates 20000 values
                     # from a uniform distribution.
                     # We will cover random number
                     # generation in detail later.

length(a.new)        # how long is it?
# If we have a long vector and do not want to
# list the whole thing, but want a glimpse of it

head(a.new)     # prints first 10 elements by default
head(a.new,15)  # use a second argument to specify how
                # many elements you want printed
# or use
tail(a.new)  # to see the last elements

# You can also create a vector by reading a file.
# We will cover that later.

#### One of the most useful and powerful things in R
#### is the way we can select vector elements

#####   examples

v = seq(1,30)
print(v)

v[6:10]

######   how many elements are there in v[6:10]
######   many think it is 4
length(v[6:10])

n = 7;
v[3:n+1]

####  v[3:n+1] does not do what most expect because of the
####  operator precedence. We expect n+1 to be evaluated to 8,
####  then used as the endpoint in 3:8. In fact the sequence
####  3:7 is generated and finally 1 is added to make 4:8
####  So use parentheses
v[3:(n+1)]

v[30:1]   # we can reverse the order

v[seq(3,22,4)]

length(v)
temp = v[28:32]  # we can access elements beyond the end
                 # of the array
                 # Note that v[31] and v[32] did not exist
                 # before this assignment. If the vector exists and we try to access
                 # an index beyond the length of the vector we get a NA value. In many
                 # languages you would get an error when you try to access v[31].
length(temp)                 
print(temp)

t = sum(temp)        # sum cannot compute the sum of temp because of the NA elements
t

t = sum(temp,na.rm=TRUE)  # we can tell sum to ignore the NA values by setting na.rm to TRUE
t
temp                      # note that the NA values are not actually removed by sum. They are ignored.

temp = v[-(1:5)]        # a minus sign means remove these
print(temp)

s = c(1,5,7,8,11)
v[s]      # we can select elemnts based on any subset
          # of the integers from 1 to 30 from v
v[-s]     # or deselect

s = c(1,5,7,15,2,4,1)  # the set can be "out of order"
v[s]

#  also note in the example above that the value 1 was repested in the s vector, so you
#  can select a vector element more than once.

s1 = c(12,24,36)
v[s1]

#  In the above example, note that v[36] does not exist. When we ask for it we get an NA.
#  This is what R does when you ask for an element "beyond the end" of the array.

s1 = c(0,10,15)
v[s1]

# note that the 0 value is s1 is simply ignored. Strangely, it does not cause an error.

v[s1] > 3

# note the length of s1 is 3, but the length of v[s1] > 3 is only two.

s1 = c(-5,4)
v[s1]

# we get an error

s1 = c(-5,0,-2)
v[s1]

# we lose the 2 and 5 elements. The 0 is ignored.

print(v)               # v is still 1:30

v[-35]                 # this is streange behavior
v[-3.7]                # this is also strange

v[-seq(3,22,4)]        # we can use seq() instead of c() to create the (de)selection indicies



# v > 23 creates a vector of logical values
v > 23

t = v > 23
t
is.vector(v > 23)

v[(v > 23)]            # This selects all indices where v > 23 evaluates to TRUE 

t = v[v > 34]
t
length(t)
# Since no element of v exceeds 34, we get nothing when we use v > 34 for selection.



v[ -(v > 23) ]         

# You might expect the above statement to remove all values of v greater than 23.
# What is -(v > 23)?

-(v > 23)

# The - sign here is the unary minus sign. It negates the operand immeditely to its right.
# When you ask R to do arithmetic on logical values, it converts TRUE to 1 and converts FALSE
# to 0. Then it does the arithmetic.

v > 23

sum(v > 23)    # computes 7 since 7 values are TRUE

TRUE*(FALSE + 3)   # predict what this will be.

# now we see why -(v > 23) has 0 where v > 23 had FALSE and -1 where V > 23 had TRUE.

# As we saw above we can mix zero and negative numbers. R ignores the zeroes, and the -1
# deselects v[1]. Note that R does not complain that we deselect it many times.

v[c(1,1,1,1)]      # selects v[1] four times

v[-c(1,1,1,1)]     # deselects v[1] one time. But then, it is hard to deselect four times.
                   # I suppose that would be akin to eating your cake four times.

#####   predict this result #######################

v[ -(v > 23)*2 ]

#   Note which element(s) get deselected
#  Also note that operator precedence is important

-v > 23      # What happens when we remove the ( )?

# The unary minus operator negated all the values of v. Then these negated values are compared to
# 23. Hence all comparisons give FALSE.

#to get the operator precedence you can type ?Syntax into the workspace. A web page will pop up
# and you can determine precedence by reading the web page.

# You can always use parntheses to reverse the natural operator precedence.
#  3*(2+5) = 3*7 = 21, but 3*2+5 equals 6+5 = 11.

# It is usually best to use parenthese when you are unsure of precedence. Even if you are correct,
# the code becomes hard for others to read (and you may forget some operator precence rules with time).

s = v > 23

v[!(v > 23)]

# This also works because > has precedence over !. But I prefer the parentheses, because it is clearer.
# Most people work in several languages and pecedence rules are not the same for all programming
# languages. You do not want to spend your time memorizing arcana.
v[!v > 23] 

# Suppose you do not know the values of v, but you want to exclude all values greater than 34.
v[!(v > 34)]

#######  Sometimes the more direct method is easiest. exclusion and inclusion are related.
#######  So instead of v[!(v > 23)], we could use v[v<= 23]

####  Suppose you have a vector and have found the maximum value in the vector, and you have
####  saved that in a variable named max.val

####  Now the maximum value may occur more than once. Suppose you want to deselect all
####  elements of the vector equal to the maximum value. Suppose the name of your vector is
####  weight.

####  weight[weight != max.val]    or  weight[!(weight == max.val)] can be used.



#  the which function can do index selection.

which(v > 23)

# We see which returns a vector contining the indices where v > 23 is TRUE.

x.2 = c(3,15,6,12,10)
which(x.2 > 9)

v[which(v>23)]        # works as expected

v[-which(v > 23)]     # works as expected

v[which(v > 34)]      # works as expected

v[-which(v > 34)]     # does not work as expected.
                      # Since no element of v exceeds 34
                      # we expect the entire v array to be selected since nothing shuld be deselected
###  one fix for this is to test the length of the returned which() vector.

s = which(v > 34)
t = v                 # if length(s) is 0, we want t = v
if ( length(s) > 0 )
t = v[-s]

# now t contains what we want.

#  But isn't v[which(v <= 34)] easier?

u = c(3,8,6,2)

###  Predict this result

v[u[2]]

# You can even do quite ridiculous things like

v[u[v[3]]]

# A major rule for writing good code is to avoid doing something just because the syntax allows it.
  


######## more complex selection


v[(v>23) & (v<26)]   # note the "&"   (and)

v[(v>23) & (v<12)]
length( v[(v>23) & (v<12)] )
object.size( v[(v>23) & (v<12)] )  # everything is an object
v[(v<3) | (v>29)]              #  note the "|"  (or)

v[log10(v) <= 1.0]


v.2 = rep(1:10, 3)
print(v.2)

v[ v.2 == 7 ]         # we can even do this

##   note that we are using the contents of the vector v.2 to select
##   entries from v, which is a different vector.

v[ (v %% 10) == 7 ]   # use modulo

##### rep is also very powerful
example(rep)

#  c() is the concatenate function

#  Study these examples of c()
x = c(3,4,6,3,2)
y = c(100,104,401)

print(x)
print(y)

z = c(x,y)
print(z)

z = c(z,-5,y) 
print(z)

#  you can call functions inside c(). Here we call cos(), log(),
#  and rnorm. rnorm generates normal random vaiables.
t = c(cos(3),log(3),rnorm(5))
t

######    character vectors

ch.v = c('a',"b")      # we can use " or '. If you start with a single tick, you must
                       # end with a single tick. Same for double tick.
ch.v

ch.v = c(ch.v,'ready') # character vectors can have different lengths in each element
ch.v

x   = 34
ch.v = c(as.character(x),'abc')
ch.v

ch.v = c(x,'abc')
ch.v
mode(ch.v)

v = 1:5
mode(v)

#        vectors have a mode. All entries must be numeric, or all entries must be character,
#        or all entries must be logical, etc.

v = c(TRUE,TRUE,FALSE)
mode(v)

v = c(TRUE,FALSE,1)    
mode(v)                # all logicals can be converted to 0 or 1.
                       # not all numerics can be converted to TRUE or FALSE
                       # so the logicals get converted to 0 or 1.
print(v)

v = c(TRUE,1,'b')
mode(v)
print(v)
