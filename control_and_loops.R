#################################################
#
#          conditional expressions and loops 
#
#################################################

#  Aside from the workhorse numerical and character modes, we have a logical
#  mode (but no illogical mode).

x = c(4, 5, 16, 7,  8)
y = c(0, 8, 12,30,100)

u = c(4,8,10,7,100)

a = x[1] > y[1]     # compare one element to another
mode(a)
print(a)

#### We can compare entire vectors

a = x > y
print(a)

sum(a)      # we can add logical variables
            # The logic is that "TRUE" is converted to 1, and "FALSE" to 0
prod(a)     # The product of a is 1 only if all elements are "TRUE"

temp = a + x       # We can mix logical and numeric modes
mode(temp)
print(temp)

a = u == x
print(a)
#        The power of computer languages derives from its ability to
#        conditionally process data

#        The form of an if statement is:
#        if ( <expression> )
#           <statement>
#
#        The <expression> inside the parentheses should evaluate to
#        one of the logical values TRUE or FALSE.
#        If the <expression> evaluates to to TRUE, then the <statement>
#        is executed. Otherwise the <statement> is not executed.
#
#       Example

r = 0
if ( x[1] > 6 )
  r = 3
print(r)

#        Note thw value of x[1] is 4, so the expression x[1] > 6 evaluates to FALSE.
#        Hence the statement r = 3 is not executed. But note the following print(r) statement
#        is executed.

#        Now we have an example where the expression evaluates to TRUE.
if ( x[1] > -5 )
  r = 3
print(r)


#        Should we wish to perform a series of actions when the <expression>
#        evaluates to TRUE, then we surround that series of actions by braces as shown
#        below. We will call the statements enclosed by the braces a compund if clause.
#
#        if (expression)
#          {
#             <statement 1>
#             <statement 2>
#                 .
#                 .
#             <statement n>
#          }

#       Now if the expression evaluates to TRUE all actions from <statement 1> through
#       <statement n> will be executed.

#       Example

r = 0
s = 1
if ( x[1] > -5 )
  { # start if clause
    r = 3*(s+1)
    s = r^2
  } # end if clause
print(r)
print(s)

#       See what happens if we forget to use braces to enclose a compound if clause.

r = 0
s = 1
if ( x[1] > 235 )
    r = 3*(s+1)
    s = r^2
print(r)
print(s)

#      Since the if expression evaluates to FALSE, the statement r = 3*(s+1) is not
#      executed, but the statement s = r^2 is executed unconditionally (that is, it
#      is exectued when the if expression evaluates to FALSE or TRUE).
#      When you do not use braces you have a simple if clause. R ignores the indentation.
#      Some languages actually use the indentation of the code to determine the extent of the
#      if clause, but R is not one of them.

#      Also note that the if clause can itself have control statements. This is what allows us
#      to write code to perform very complex algorithms.

#      Many times we wish to perform some action when an expression is true and another action
#      when an expression is false. We accomplish this by having the keyword "else" immediately
#      after the conclusion of the if clause, followed by the else clause.
#      The else clause can be simple or compound.

#      One problem with R being an interpreted language is that R reads your script line by
#      line and when it sees a complete syntax unit it immediately executes it.

#      Here is an example of a problem caused by this behavior.

z = -1
if ( x[1] > 4 )
  {
     z = x[1]^2
  }
else
  {
     z = sqrt(x[1])
  }
print(z)


#      Note that we get an error of an unexpected "else". As soon as R encountered the
#      closing brace for the if clause, it executed the if statement. It did not try to look
#      ahead to see if there is an else following the if clause. This behavior will be
#      unexpected by anyone who has experience coding other programming languages.
#      More dangerous is that after sloughing off the "else" as an error, R will uncondionally
#      execute the code that was intended to be an else clause.

z = -1
if ( x[1] > -5 )
  {
     z = x[1]^2
     print("if clause executed")
  }
else
  {
     z = sqrt(x[1])
     print("else clause executed")
  }
print(z)


#      There are some work arounds.

z = -1
if ( x[1] > -5 )
  {
     z = x[1]^2
     print("if clause executed")
  } else {
     z = sqrt(x[1])
     print("else clause executed")
  }
print(z)

#   Here the line "} else {" has an opening brace. This makes R read more lines until the
#   matching closing brace is encountered. Only then does R have a complete syntax unit.

#   When writing complex code, where if clauses and else clauses contain loops and conditional
#   code, it is my opinion that the previos style is unwieldy.

#   Another solution is to surround your if-else statement by braces.

{ # start syntax unit
z = -1
if ( x[1] > -5 )
  {
     z = x[1]^2
     print("if clause executed")
  }
else
  {
     z = sqrt(x[1])
     print("else clause executed")
  }
} # end syntax unit
print(z)

#  When R encounters the first opening brace it will not have a complete syntax unit until it
#  encounters the matching closing brace. Therefore, when it encounters the end of the if clause
#  it will not prematurely execute.

#  You will see later that we usually don't need to do this. The most complex code you write
#  will usually be a function. Many times your conditional statement will be inside a loop. In
#  these cases R will need to read the entire function or loop before it has a complete syntax unit.

#  Code is easier to read when if clasues and else clauses are indented to the same level.

####   Notice the indentation. It is easier to read code that is systematically
####   indented following the logic of the program. Compare
if ( x[1] > 4 ) {
z = sin(x[1])
w = sqrt(x[1])
}else {
z = cos(x[1])
w = sqrt(x[1] - 4)
}

##### conditions may be simple, ">", ">=", "<', "<=", "!=" (for not equal),
##### "==" for equal. Note the second "="

{
if ( x[1] == 3 )
  {
    print("if clause")
  } 
else 
  {
    print("else clause")
  }
}

if ( x[1] = 3 )   # if you forget the second "=", you get an error
{
    print("if clause");
} 

##### but it still executes the if clause. Not what you want.

# now let's look at logical values
as.logical(3)
as.logical(-1)
as.logical(0.001)
as.logical(0)

#####  Is that logical? This behavior is similar to C

##   In this example x[2] is NOT converted (or cast in C terminology) to a logical value before doing the comparison.
##   Instead TRUE is converted to 1. Since x[2] = 
{
if ( x[2] == TRUE )
  {
    print('if clause')
    w = 1
  }
else
  {
    print('else clause')
    w = 0
  }
}
print(w)

###     Here we use as.logical to convert x[2] to a logical variable.
{
if ( as.logical(x[2]) == TRUE )
  {
    print('if clause')
    w = 1
  }
else
  {
    print('else clause')
    w = 0
  }
}
print(w)

#######  the expession inside the parentheses follwing "if" will be evaluates to a logical
#######  variable. x[2] is converted to TRUE.  
{
if ( x[2]  )
  {
    print('if clause')
    w = 1
  }
else
  {
    print('else clause')
    w = 0
  }
}
print(w)

####               temporarily change the value of x[2]
save.x2 = x[2]
x[2]    = 1

{
if ( x[2] == TRUE )
  {
    print('if clause')
    w = 1
  }
else
  {
    print('else clause')
    w = 0
  }
}
print(w)

##### Note that when x[2] is 1, and TRUE is converted to 1, the if clause executes.


# make x[2] revert to its original value

x[2] = save.x2

 

if ( x[1] == 0 )  
{
    print("if clause");
} 

#     Since x[1] is not 0, the if clause is not exectued. This is expected bahavior.

    

# if you forget the second "=", you get an error message, but you also
# execute the if clause. That is definetely not good.

if ( x[1] = 0 )  
{
    print("if clause");
} 

# One of the most insidious errors is using "=" instead of "==" in an iff statement.
# This is a problem R has inherited from C. If R insisted on using "<-" as the assignment operator
# and did not allow "=" for the assignment operator, then we could use "=" as the equality relational
# operator and our lives would be easier.


#  R sees an error in the line if ( x[1] = 0 )
#  It gives you an error message
#  But then it sees
{
  print("if clause")
}

# and these are perfectly legitimate statements, so it executes them

if ( x[1] = 0 ) { print("if clause") }

# Notice "if clause" is not printed since if( x[1] = 0 ) is not
# a complete syntax unit. The syntax unit is thrown away.

# Apparently when the print statement was on a separate line, R
# just throws away the line because it detected an error.
# The error and the new line character were enough to reset R's
# parser, apparently.

##### Be VERY careful about not typing "=" for "=="


##### You can also have compound conditionals using and (&&) and or (||)
if ( (x[1] == 4) || (x[2] >10) ) {print("true")} else {print("false")}

if ( !( (x[1] == 4) || (x[2] >10) ) ) {print("true")} else {print("false")}

####  you can use DeMorgan's Law to make your intent clearer
####  !(p or q) is the same as !p and !q
####  !(p and q) is the same as !p or !q

if (  (x[1] != 4) && (x[2] <= 10)  ) {print("true")} else {print("false")}



if ( (x[1] == 4) && (x[2] >10) ) {print("true")} else {print("false")}

#### You can use many && and many ||, or a combination of them, and ! (not)

#####   && and || return a single TRUE or FALSE value. 

# print x and y (you do not need print function)
x
y
x && y
x || y

##   x && y  is the same as x[1] && y[1]. Similarly for x || y

if ( x && y) print('if clause') else print('else clause')

#### We also have the & and | operators. & and | can work on an
#### entire vector, and return a vector result

x & y
x | y

if ( x & y ) print('if clause') else print('else clause')

##  Note the warning. Use && and || inside if(). When you want to
##  to 'and' two vectors use &. The result will be a vector which you
##  can use later.


############################   Never use "&" or "|" inside an if statement's condition (nor a while statement's condition).
#                              Use these for vectors only.
#                              "&&" and "||" should be used for if statements and while statements.
#                              They are also known as short-circuit opoerators.
#                              When evaluating "a && b", we begin by evaluating a. If a is FALSE, "a && b" cannot
#                              possible be true. We do not evaluate b. Simlar considerations apply to "||". If we
#                              evaluate "a || b" and a is TRUE, then we need not evaluate b.


a = -1
g = 7
h = 0
if ( (a > 0) && (g/log(a) > 0) )
  {
      h = 3
  }
print(h)

# Now consider
if ( (a > 0) & (g/log(a) > 0) )
  {
      h = 3
  }
print(h)

#  We see that even though (a > 0) evaluates to FALSE we till evaluate (g/log(a) > 0). log(-1) produces a NaN.

#  Now consider


a = -1
g = 7
h = 0

{
if ( (a > 0) & (g/log(a) > 0) )
  {
      h = 3
  }
else
  {
      h = 2
  }
}
print(h)

(g/log(a) > 0)             # has value NA

(a > 0) & (g/log(a) > 0)   #   FALSE anded with NA gives FALSE

#  let us leave off the (a > 0) condition


a = -1
g = 7
h = 0

{
if ( g/log(a) > 0 )
  {
      h = 3
  }
else
  {
      h = 2
  }
}
print(h)

####   neither the if clause nor the else clause were executed
####   This is very interesting. One expects that always one of the clause to executes.


####  You can also put more than one calculation on a line if you use the ";"
####  separator.

z = sin(x[i]); w = sqrt(x[1];

####  Note that R will put echo a "+" until it sees a syntactically complete
####  expression.

1 +
2 +
3

#### or

temp =
1 + 2^3 -
5

print(temp)

####  Note the inserted "+" can make it hard to read. Sometimes we just
####  have such long expressions we cannot complete them in one line. Of
####  course the example below is contrived, but real code can have similarly
####  lengthy expressions (wait until you see complicated plots)

a.very.long.name = 3000*x[3] - 1200*x[2] +cos(y[1]) -temp + (x[2] <= x[3]) +
                   atan(x[1]) + trunc(y[2]) - 28974.325678


###    R also has some quirks

6 ++++++++++++++++++++++ 3
6 +++++- 3
6 + + + - + 3

6 ++ -- 3
6 ++ --- 3

6 ++-+-- 3

2 ** 3   # Note: "**" is an exponentiation operator. This is the same as FOETRAN's exponentiation operator
2 ^ 3    # This is more common in R




####        a recommended style

####        if ( cond1 )
####          { # b1
####             if ( cond2 )
####               { # b2
####                 < some code >
####                 if ( cond3 )
####                   { # b3
####                     <more code>
####                   } # e3
####                 else
####                   { # b4
####                     < code >
####                   } # e4
####                 < more code >
####              } # e2
####          } # e1
####        else
####          { # b5
####            <some code>
####            if ( cond4 )
####              { # b6
####                < some code >
####              } # e6
####          } # e5
####
####       The nice thing about doing something like the above is
####       that you can quickly see which "}" is matched by which "{"
####       You don't have to use b1 (which means begin 1) or e1 (end 1),
####       but you should do something to help you find the match. Some
####       editors can help uou here. You should imagine <code> or <more code>
####       in the listing above to be several lines of code.
####       You can also helpfully use meningful comments instead of "b1" or "e1".

##         if ( condition )
##           { # normal case
##              <code>
##           } # normal case
##         else
##           { # error case
##              <code>
##           } # error case 

###    You will learn it is important to indent carefully and take the time
####   to give your code a readable appearance. You will type your code once, but it will be
####   a hundred times.

####   Now let's write code to solve a problem
####        example
####            compute total pay when you know the hours worked, the pay rate,
####            and the fact each hour beyond 40 is paid at 1.5 times the normal
####            rate

rate  = 18.36
hours = 37

####  one solution

{
if ( hours > 40 )
  { # overtime case
     hours.over = hours - 40;
     pay        = 40*rate + 1.5*hours.over*rate
  } # overtime case
else 
  { # normal case
     pay = hours*rate;
  } # normal case
}
print(pay)

####  another solution

normal.pay = hours*rate
if ( hours > 40 )
  { # overtime case
    pay = normal.pay + (hours - 40)*0.5*rate
  } # overtime case
print(pay)

#### test the overtime case

hours = 45

{
if ( hours > 40 )
  { # overtime case
     hours.over = hours - 40;
     pay        = 40*rate + 1.5*hours.over*rate
  } # overtime case
else 
  { # normal case
     pay = hours*rate;
  } # normal case
}
print(pay)


40*rate + 5*1.5*rate  # check

#####     When you test your code make sure all code executes in
#####     at least one test case.

#####     For complicated code, there are many sub-cases (think about
#####     if statements that are embedded inside if statements).

#####     When doing preliminary debugging, you can insert print statements
#####     to be removed later, that will show your code coverage.


{
if ( hours > 40 )
  { # overtime case
     print("overtime case")
     hours.over = hours - 40;
     pay        = 40*rate + 1.5*hours.over*rate
  } # overtime case
else 
  { # normal case
     print("normal case")
     pay = hours*rate;
  } # normal case
}





#####    Often you will want to perform the same task on many
#####    instances of the data. For example you read in hours
#####    and rate for many employees from a file. Suppose after 
#####    reading the file you have the following data. Element i
#####    of each vector is the hours and rate for the ith employee.

hours.data = c(22, 40.5, 40, 40, 43)
rate.data  = c(15.45,28.50,21.00,36.25,29.40)

####  We could then do something like,

hours = hours.data[1]
rate  = rate.data[1]

{
if ( hours > 40 )
  { # overtime case
     print("overtime case")
     hours.over = hours - 40;
     pay        = 40*rate + 1.5*hours.over*rate
  } # overtime case
else 
  { # normal case
     print("normal case")
     pay = hours*rate;
  } # normal case
}

pay[1] = pay

hours = hours.data[2]
rate  = rate.data[2]

{
if ( hours > 40 )
  { # overtime case
     print("overtime case")
     hours.over = hours - 40;
     pay        = 40*rate + 1.5*hours.over*rate
  } # overtime case
else 
  { # normal case
     print("normal case")
     pay = hours*rate;
  } # normal case
}

pay[2] = pay

######     You can see this is clumsy. Suppose we have 3500 employees!

######     A better way is to use a loop.

######     A for loop repeatedly executes the same code

######    example

x = 1:12
n = length(x)
p = 0;
for ( i in 1:n)
  {
     cat(sprintf("i = %d\n",i))         # to show how for works
     p = p + x[i]
     cat(sprintf(" p = %d\n",p))          # to show how for works
  }
   
#####  the loop iterates through the sequence specified after "in"
#####  the code within { ... } exectutes once for each element in the
#####  specified sequence after "in"

#####  We can specify the sequence in many ways. Let's do the previous
#####  example backwards

p = 0;
for ( i in n:1) 
  {
     cat(sprintf("i = %d\n",i))         # to show how for works
     p = p + x[i]
     cat(sprintf(" p = %d\n",p))          # to show how for works
  }

s = seq(from = 2, to = 8, by = 2)
print(s)

p = 0;
for ( i in s) 
  {
     print(i)          # to show how for works
     p = p + x[i]
     print(p)          # to show how for works
  }

###### i keeps the last value

sprintf("i = %d",i)

#########

s = 1:13  # more than 12
p = 0
for ( i in s) {
   print(i)         # to show how for works
   p = p + x[i]
   print(p)          # to show how for works
}

#####  We tried to access x[13] and when we did we obtained "NA"
#####  If you index outside the limits of your vector you get "NA".
#####  This is useful to know when you debug.

#####   Back to the pay example


{ # syntax
hours = c(22, 40.5, 40, 40, 43)
rate  = c(15.45,28.50,21.00,36.25,29.40)


n1 = length(hours)
n2 = length(rate)
if ( n1 != n2 )
  { # mismatch in length of hours and rate vectors
     sprintf("Error in obtaining hours and rate data.")
     sprintf("We have %d items for hours and %d items for rate",n1,n2)
  } # mismatch in length of hours and rate vectors 
else 
  { #  data is good. 
    pay = numeric(n1)   # preallocate output vector
    for ( i in 1:n1)    # doesn't matter if we use n1 or n2 here
      {  # begin for loop                   
        if ( hours[i] > 40 )
          { # overtime case 
            hours.over = hours[i] - 40;
            pay[i]     = 40*rate[i] + hours.over*(1.5*rate[i])
          } 
        else 
          {
            # normal case  
            pay[i] = hours[i]*rate[i];
          } # normal case
       } # end for loop
     } # data is good

} # syntax        
print(pay)

####### notice the preallocation of the pay vector. This is very
####### important. pay must be made an object before we enter the for
####### loop.

#######   example
#######  We have two vectors x and y. We wish to compute r.sq, where
#######  r.sq[i] = x[i]^2 + y[i]^2

n = 50000
x = rnorm(n) # generate n random values for x and the y
y = rnorm(n)

#### we get an error because object r.sq will not be found
for ( i in 1:n)
{
   r.sq[i] = x[i]^2 + y[i]^2
}

####  We can fix this by just declaring r.sq before the for loop
####  Sometimes, the cure is worse than the disease. We will time
####  the next section of code

t.0 = proc.time() # set a stop watch
r.sq = numeric()  # now the object r.sq will be found. We don't
                  # actually allocate memory for it. We let R
                  # allocate more memory as r.sq grows
for ( i in 1:n)
{
   r.sq[i] = x[i]^2 + y[i]^2
}
proc.time() - t.0



t.0 = proc.time()  # set a stop watch
r.sq = numeric(n)  # Allocate all the memory r.sq needs at one time
for ( i in 1:n)
{
   r.sq[i] = x[i]^2 + y[i]^2
}
proc.time() - t.0

####  You always know how many iterations your for loop will run.
####  Even if you use for ( j in s )... you can do a n=length(s)
####  before the for, and use numeric(n) to allocate all the memory
####  necessary. It is better to allocate more memory than necessary,
####  before the for loop executes, and then get rid of the unused memory
####  after the for loop finishes.

####  Interpreted code is always MUCH slower than the compiled functions
####  available in R

t.0 = proc.time()
r2.sq = x^2 + y^2
proc.time() - t.0

#### check we obtained the same result
temp = r.sq - r2.sq
max(abs(temp))

####   you can set up strange loop index sequences
S = c(4,2,7,3,4)
for ( j in S )
{
   print(j)
}
#####  Note the loop index follows the order of S.
#####  Also note S has a repeat, and the for loop executes
#####  the same code for j = 4 twice.

####  You cannot change the limits of the for loop inside the for loop.

m = 10
for ( j in 1:m )
{
   print(j)
   if ( j == 5 )
     { m = 20 }
}

m

####  nor can you change the loop index

for ( j in 1:m )
{
   print(j)
   if ( j == 5 )
     { j = 2 }      # if this worked we have an infinite loop
}
print(j)
#           this example is disturbing
x = 11:20
for ( j in 1:m )
{
   print("*****************")
   print(j)
   print(x[j])
   j = 3
   print(x[j])
   
}
print(j)

####   R allows you to change the value of j explicitly, but it does not
####   affect the indices used by the loop.

####   The j in the body of executable code is a distinct variable.

m = 10
for ( j in 1:m )
{
   print(j)
   if ( j == 5 )
     { j = 10 }      # we want to end the loop early
}


#####  but we do have the break and next statements

a = c(4,11,-5,2,3,6)
m = length(a)

out = numeric(m)  # puts a zero in allocated memory
for ( k in 1:m )
{
   if ( a[k] < 0 )
     {
        print("invalid value encountered. leaving for loop")
        break;  # this causes us to leave
     } 
   else 
     {
        out[k] = sqrt(a[k])
     } # end else
} # end for
print(k)
print(out)

##### suppose we want out[k] = 0 when a[k] < 0. We could use next
out = numeric(m)  # puts a zero in allocated memory
for ( k in 1:m )
{
   if ( a[k] < 0 )
   {
        print("go back to top of loop")
        next;  # this causes us to go to the top of the loop
   }
   out[k] = sqrt(a[k])
} # end for
print(k)
print(out)

#####  do not put loop invariant statements inside the loop. It
#####  is inefficient.
t.0 = proc.time();
r = 0;
for ( i in 1:60000 )
{
   k1 = 3.0
   k2 = 4.23
   r = k1*r + sin(k2*i)
}
proc.time() - t.0


t.0 = proc.time();
k1 = 3.0; k2 = 4.23; r = 0;
for ( i in 1:60000 )
{
   r = k1*r + sin(k2*i)
}
proc.time() - t.0

x = 1:10
y = sqrt(1:10)

for ( i in 1:length(x) )
{
  z = x[i] + y[i]
  print(z)
}

#  Suppose x has length 0

x = c()
print(x)
length(x)
x[1]          # Notice: not NA, which we usually get when we ask for indices beyond the length of x

for ( i in 1:length(x) )
{
  print(i)
  print(x[i])
}

####  In many cases we do not want the body of the loop to execute even once
####  if the length of the vactor is 0.
for ( i in seq_along(x) )
{
  print(i)
  print(x[i])
}

# revert

x = 1:10

for ( i in seq_along(x) )
{
  z = x[i] + y[i]
  print(z)
}

#######    the loop variable does not need to be an integer
x = 2*round(runif(12),2) + 1

for ( i in x )
  {   
    cat(i);cat('\n')
    cat(y[i]);cat('\n')
  }

#######     the loop variable can be a character vector
s = c('a','b','c','d','e','f')
u = c('b' = 2, 'a' = 1, 'c' = 3, 'e' = 5, 'f' = 6, 'd' = 4) # vectors can have names for each element
print(u)
u['d']

for ( i in s )
  {
    if ( i == 'a' ) { next }
    cat(u[i]);cat('\n')
  }

#####  another way to protect from 0 length vectors

#  if ( length(x) > 0 )
#    { # start if  
#        for ( i in 1:length(x) )
#            <body of for loop here >
#    } # end if

###### Another useful loop construct is while

s = 0; k = 1;
while ( a[k] > 0 )
{
   s = s + a[k]
   k = k + 1    # we could have k + 3 if we want to look at every third value
}
print(s)

a = 1:10; k = 1;     ### make all values of a positive
while ( a[k] > 0 )
{
   s = s + a[k]
   k = k + 1    # we could have k + 3 if we want to look at every third value
}
print(s)
##### We lucked out. when k = 11, we have the comparison "NA" > 0, which cannot
##### be resolved to TRUE or FALSE
##### When you use a while loop, BE SURE the condition will eventually be false

a = 1:10; k = 1; s = 0
while ( (a[k] > 0) && (k <= length(x)) )
{
   s = s + a[k]
   k = k + 1    
}
print(s)

######  When debugging, or just for safety, you can always use a
######  counter to get out of the while loop

################### *********************************************
#
#     The Example Below is an INFINITE LOOP!!
#
#      To stop it you need to make the console the active window
#      (you can hit contol-TAB to make it the active window if it
#       is not the active window. When the console is active click on
#       the STOP sign that appears at the top of the R screen. 
#       You can also hit the esc key if the console is active.
#
#       Or if you prefer, do not run the example immediately below.
#      If you look at the code you should be able to see why the
#      loop is infinite.
################ ***************************************************
#   Suppose you entered

s = 0; k = 1
while ( (a[k] > 0) & (k < 11) )
{
   s = s + a[k]
    # forgot to increment k
}
print(s)

######  notice the handy STOP sign. Use it when it takes too long!
######  Or you can go to the console and hit escape.

###### It could very well be the case when you have mildly complicated
###### code inside the while loop that you forget to change a variable that
###### will eventually cause the while loop to end. You can put a safety counter
###### in that is very big, but at least your code finishes. You can later take it
###### out if speed is critical. Of course you must set the safety counter limit
###### higher than what you EVER expect the bug free while loop to run.
###### Example: you use data sets with values no bigger than 10,000 entries for
###### several months (years?). Then you get a data set with 1,500,000 entries
###### and your safety counter was set at 1,000,000 for a limit. You get a strange
###### result, and have forgotten all about your safety counter, and have forgotten
###### about your while loop. 

###### If you test your code thoroughly, then it may be best to remove the safety
###### counter. If speed is not critical, perhaps you could set your safety counter
###### to 10^9. Then you should have your code issue a warning message if your
###### counter gets to be a big number. This warning message may indicate your code
###### has a latent bug your testing did not uncover.

###### break and next work in while loops just as they do in for loops

######  A fairly common use of while is:

######  while ( flag == 0 )
######   {
######            <code>
######   }

######  Somehwere the code better set flag = 1, or any non-zero value

######  Safety idea
#       counter = 0;
######  while ( (flag == 0) && (counter < big) )
#       {
#             <regular code>
#             counter = counter + 1
#       }
#       At the end of the while loop, if counter == big you can worry

#       Another common while loop is
#       while (1)
#       {
#          <code>
#       }
#       In this case the ONLY way to end the loop is a break

#       Another loop construct, which is not at all useful (note the
#       judgemental tone - other decent people may have another opinion)
#       is repeat.

#       repeat
#       {
#           <code>
#       }

#       I say it is not useful, because it is the same as while (1)

####   vector index subsetting can also occur on the LHS

v    = 1:12
S    = c(3,4,8)
v[S] = -1
print(v)

####   You should never use "==" when comparing two numeric values that
####   have gone through a lot of calculation

####   Here is a contirved example. Suppose s.x is the result of complex code
####   One of the branches of code does some processing that mathematically
####   should make the value of s.x = 0. Other branches will make s.x non-zero.
####   So you decide to use the value of s.x to test if this branch of the code was
####   taken.

####  Here are some calculations that should give a zero value for s.x,
####  (and would, if there were no truncation and rounding errors)

s.x = 0;
for ( i in 0:359) 
{
   s.x = s.x + cos(2*pi*i/360)
}
print(s.x)
####    if ( s.x == 0.0 )  will not work
####    if ( abs(s.x) < 1e-12) will work

###   R does have a function to do approximate equality checks. Sometimes this is
###   presented as a panacea. But it just does a abs(s.x) < tolerance check.
all.equal(s.x,0)

#   The default tolerance is 1.490116 x 10^-8

all.equal(1e-6,0)

all.equal(1.5e-8,0)

all.equal(1,0)

#    What good is this?

all.equal(s.x,0,tol = 1.0e-13)
all.equal(s.x,0,tol = 1.0e-14)


good = 0
tol = 1e-10   # set to what you think it should be
if ( abs(s.x) < tol )
  {
     good = 1
  }
print(good)

good = 0
tol = 1e-14
if ( abs(s.x) < tol )
  {
     good = 1
  }
print(good)

temp = all.equal(s.x,0)
print(temp)
is.logical(temp)           # all this seems fine

temp = all.equal(s.x,0,tol=1e-14)
print(temp)
is.logical(temp)  # if all.equal is not TRUE, then it is not a logical value
is.character(temp)

#####    what is bad is that when all.equal is not true, it is a character string and cannot 
#####    be evaluated to TRUE or FALSE
good = 0
tol = 1e-14
if ( all.equal(s.x,0,tol) )
  {
     good = 1
  }
print(good)

####   We need this
good = 0
tol = 1e-14
if ( isTRUE(all.equal(s.x,0,tol)) )
  {
     good = 1
  }
print(good)

# I do not care for all.equal
# Just use abs() and select your own tolerance.
# Most people have no idea what the default tolerance is.


####    I repeat: This is an artificial example, but there are times
####    one wants to do an equality comparison between two doubles.

####    Suppose we want to compare for equality of a and b, which are doubles
####    Use
####    if ( abs(a-b) < tol )
####    where tol is some arbitrary, but small, value. We used 1e-12 in the last
####    example. To make your code more portable, you might use
####    tol = sqrt(.Machine$double.eps), or at least base tol on .Machine$double.eps

####    Sometimes we might know the value should (using exact arithmetic)
####    be an integer. We can correct for rounding error with round()
round(1.3462e-9)
round(2.998)

####    round, trunc, ceiling, and floor are very useful functions. You
####    should run exmples of each.

####    Here is one use. Suppose we want an accurate value for 2^5000000

2^5000000
####    if x = 2^5000000, then log10(x) = 5000000*log10(2)
log10.x = 500000*log10(2)
print(log10.x)

x.exp    = floor(log10.x)
x.frac   = log10.x - x.exp
x.digits = 10^(x.frac)
print(x.exp)
print(x.frac)
print(x.digits)
sprintf("2^5000000 = %15.14fe+%d",x.digits,x.exp)

####   Think about the modification  you need to calculate 2^(-5000000)








 


