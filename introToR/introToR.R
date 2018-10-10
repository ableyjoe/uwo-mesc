# Intro to R, 2010-10-10 1300-1600
# jthomp83@uwo.ca
# https://csclub.uwaterloo.ca/~j7thomps/introToR_pm/

# numeric types, function names
class(1)
typeof(1)

x <- 1
x = 1 # same thing, not always supported but always used when using local variables in function parameters
1 -> x # same thing

y <- 5
x+y
x-y
x/y
x*y
x^y

x <- as.integer(x)
typeof(x)
class(1L) # L suffix denotes integers

# logical variables
TRUE
T
FALSE
F
class(TRUE)
TRUE*5 # (TRUE coerced into numeric)
200 > 100
100 == 100
100 != 200
TRUE | TRUE # or
TRUE & FALSE # and
any(FALSE) # useful for vectors, any element is true
any(FALSE)

# characters
"penguin"
class("penguin")
'penguin' # can use either
"\"quote"

x <- "penguin"
grep("g",x)
paste("pen", "guin", sep = "+")
paste0("pen", "guin")
strsplit(x, "g")

# other data types
NA # not available
Inf # infinity
2/0
NULL # empty set, no type
typeof(NULL)
NaN # not a number

is.numeric(x)
is.character(x)

z # Error, not found
ls() # list all objects in environment

# object names that start with a dot are hidden
.x <- 1
ls(all.names = TRUE)

# object names can't start with digits
1x <- 3 # error
# but dots and underscores are fine
x.1 <- 3
x_1 <- 5

# data structures
rm(list=ls())

# c means concatenate
x <- c(1, 2, 3, 4, 5)
x
class(x)
typeof(x)

# vector indices are numbered from 1
mean(x)
length(x)
x[1]
x[5]
x[6] # NA
1:5 # vector from 1 to 5 monotonically increasing
1.1:5.1 # step by 1
1.1:5 # step by 1, so only four elements
x[3:5] # indices, not values

# matrices
matrix(c(1,2,3,4), nrow = 2, ncol = 2)
matrix(c(1,2,3,4), nrow = 4, ncol = 4)

# array
array(c(1,2,3,4), dim = c(4,4,4))

# factor
x <- c("a", "b", "c", "b", "c", "b")
x <- factor(x)

# factor builds a dictionary of unique elements in the vector
# subsequent assignments are restricted to that dictionary

# lists
L <- list(1:3, "a", c(TRUE, FALSE, TRUE), c(2.2, 5.9))
L
str(L)
class(L)
typeof(L)

# data frames
df <- data.frame(a = 1:5, y = c("a", "b", "c", "D", "E"))
df
str(df)
class(df)
typeof(df)

# error because there's a missing value
df <- data.frame(a = 1:5, y = c("a", "b", "c", "D"))
# backfill with NA
df <- data.frame(a = 1:5, y = c("a", "b", "c", "D", NA))

# add observations (row bind)
rbind(df, data.frame(a = 6, y = "f"))

# add variable (column bind)
cbind(df, data.frame(z=c(T, F, T, F, T)))

rownames(d
colnames(df) # same as names with a dataframe
names(df) # use names

# subsetting

# vectors
x <- c(1.1, 2.2, 3.3, 4.4, 5.5)
x
x[1]
x[1:3]
x[3:1] # backwards
x[-1] # eliminate the first one
x[-1:3] # error
x[-(1:3)] # remove first three
x[0]
x[c(1, 2, 3, NA, 5)]

# matrix
x <- matrix(1:16, nrow = 4, ncol = 4)
x
x[,1]
x[1,]
names(x)
colnames(x)
colnames(x) <- c("A", "B", "C", "D")
x
x[,"A"]
x[,-2]

# dataframes
df
colnames(df) <- c("alpha", "gamma")
df
df$alpha
df$gamma
df[,1]
df[,"alpha"]
df$alpha[4]
df$alpha is a vector

df[df$alpha == 2,] # all the observations with alpha = 2

# lists
# lists need double brackets
L
L[[1]]

# working with data
