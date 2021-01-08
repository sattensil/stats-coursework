name = "Scarlett Townsend"
#Statistics 6861/4861 Assignment 2
#Wednesday, Nov. 4

in.circle <- function(pts,cntr,r)
{ # in.circle
  name = "Scarlett Townsend"
  print(name)
  # verify length or r
  if (!length(r) == 1 ) {stop("r is the radius, it must be of length 1.\n")};
  #verify pts is a matrix
  if ( !is.matrix(pts)  ) { as.matrix(pts) };
  if ( length(pts)==2 ) { dim(pts)=c(length(pts)/2,2) };
 #verify cntr is a matrix
  if ( !is.matrix(cntr)  ) { as.matrix(cntr) };
  #verify cntr has both coordinates
  if ( !length(cntr)==2  ) {stop("cntr must have x and y coordinates.\n") };
  if ( !is.matrix(cntr)  ) { dim(cntr)=c(length(cntr)/2,2) };
  #verify pts and center have both coordinates
  if ( !ncol(pts)==2  ) { stop("pts must have x and y coordinates.\n")   };
  if ( !ncol(cntr)==2  ) {stop("cntr must have x and y coordinates.\n") };
  
  dist=((pts[,1]-cntr[1])^2+(pts[,2]-cntr[2])^2)^(.5)
  incir=dist<=r
  pts=cbind(pts,dist,incir)
 
  a=pts[which(pts[,4]==TRUE),1:2]
 dim(a)=c(length(a)/2,2)
  b=pts[which(pts[,4]==FALSE),1:2]
  dim(b)=c(length(b)/2,2)
  require("plotrix")
  plot(b,xlim=c(min(cntr[1]-1.5*r,pts[,1]),
                  max(cntr[1]+1.5*r,pts[,1])),
                  ylim=c(min(cntr[2]-1.5*r,pts[,2]),
                         max(cntr[2]+1.5*r,pts[,2])),col="blue",
                  xlab="x",ylab="y",sub="Scarlett Townsend")
  points(a,type="p",col="red")
  draw.ellipse(cntr[1],cntr[2],r,r,nv=100,col=NA,lty=1,lwd=1)
  return(a)
} # in.circle


#check given in assignment
set.seed(40)
x = runif(14,0,10)
x = round(x,3)

y = runif(14,0,10)
y = round(y,3)

pts = cbind(x,y)
print(pts)

cntr = c(4,5)
r = 3.5

a = in.circle(pts,cntr,r)
print(a)

#check vector of length 1
set.seed(40)
x = runif(1,0,10)
x = round(x,3)

y = runif(1,0,10)
y = round(y,3)

pts = cbind(x,y)
print(pts)

cntr = c(4,5)
r = 3.5

a = in.circle(pts,cntr,r)
print(a)

#on circle
x = c(3,-4)
y = c(4,-3)

pts = cbind(x,y)
print(pts)

cntr = c(0,0)
r = 5

a = in.circle(pts,cntr,r)
print(a)