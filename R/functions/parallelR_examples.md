---
title: "Parallel R: Examples"
author: "Kyle Lochhead"
date: "February 6, 2019"
output:
  html_document: 
    keep_md: yes
---

```r
# Copyright 2018 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
```
## Steps to go Parallel in R

For windows, use the following packages

+ _snow_ can use many machines on windows. snow = "Simple Network Of Workstations"
+ _parallel_ can only use one machine on windows. Uses _snow_ API. Has a useful function - detectCores(). 
+ _doParallel_ a parallel backend for the _foreach_ package. Additionally, requires registerDoParallel() or registerDoSNOW() to set up the cluster on windows.

There are others. E.g., _multicore_ but doesn't support windows



Once loaded, the common steps for making a process parallel in R

1. Initializing Workers
2. Functions and Environments
3. Parallel Process via
  ++ Round-robin with clusterApply()
  ++ Load balancing with clusterApplyLB()
  ++ Task chunking with parLapply()
  ++ Vectorizing with clusterSplit()
  ++ Iterating with foreach() %dopar%
4. End the process via stopCluster()

>Note: this is a summary of examples from - Parallel R: Data Anlaysis in the Distributed World. 2011. McCallum Q.E. and Weston, S. ISBN-10: 9781449309923. 126 pp. 

### 1. Initializing Workers
In order to execute any functions in parallel with snow you need to create a cluster object.

> Connecting a single workstation.


```r
nCores<-2 # set this to the number of cores you want to use.
cl <- makeCluster(nCores, type="SOCK") # type SOCK is a socket connection. If MPI is available use "MPI". Note declaring this type is not needed with the parallel package
```

> Connecting many workstations. 

Note: in order for this to work you have to set up SSH. On windows this may require downloading an OpenSSH server and having PuTTy.


```r
machineAddresses <-list(
  list(host='[computer name in network. E.g., kyle_comp]',
       user='kyle',
      
       rscript="[path to RScript. E.g., C:/Program Files/R/R-3.5.1/bin/Rscript]",
       rshcmd="C:/PuTTY/plink.exe -pw [password for user]"),
  list(host='tyler_comp',
       user='kyle',
       rscript="C:/Program Files/R/R-3.5.1/bin/Rscript",
       rshcmd="C:/PuTTY/plink.exe -pw 1234"), #this is the ssh cmd line call
  list()
)
cl <- makePSOCKcluster(machineAddresses, manual = F)

#A useful function
.libPaths() # returns location of the library
```

### 2. Functions and Environments
Setting up the functions and environments from which the workers will process. In _snow_, these take a function object as an argument and then send it to the worker(s). These functions must be serialized into a stream of bytes.


```r
#For executing a simple expression on the cluster workers:
clusterEvalQ(cl, {library(raster); NULL}) #return a NULL to avoid sending unnecessary data back to the master. Note the list one NULL for each worker.
```

```
## [[1]]
## NULL
## 
## [[2]]
## NULL
```

```r
#Takes two arguments: the cluster object, and an expression that is evaluated on each of the workers. It returns the result from each of the workers in a list. However, doesn't allow parameters to be past. Try: 
#ClusterCall()

#Example function to load packages in each worker
worker.init <- function(packages) {
  for (p in packages) {
    library(p, character.only=TRUE) #need character.only=TRUE to evaluate p as a character
  }
  NULL #return NULL to avoid sending unnecessary data back to the master process
}
clusterCall(cl, worker.init, c('igraph','data.table')) #can return the results as a list. Similar to #clusterApply() - but without the x. Executes once for each worker, rather than for each x.
```

```
## [[1]]
## NULL
## 
## [[2]]
## NULL
```

### clusterApply()
This function schedules taks to workers in a round-robin fashion by sending new tasks as they complete their previous task. It distributes tasks (i.e., elements of x) to clusters one at a time - similar to how cards are dealt to players. Thus, tasks are pushed to workers. It is used to implement parLapply()


```r
#example sys.sleep function
set.seed(7777442)
sleeptime<-abs(rnorm(10,10,10))
snow.time(
  clusterApply(cl, sleeptime, Sys.sleep)
)
```

```
## $elapsed
## [1] 63.07
## 
## $send
## [1] 0
## 
## $receive
## [1] 0
```

### clusterApplyLB()
This function schedules tasks to workers as the need them. Thus, tasks with uneven loads (i.e., tasks that would finish at differnt times) would be balanced. This function is more efficient if some tasks take longer than others or some workers are slower, e.g., > 10 seconds wasted due to round robin

```r
#example sys.sleep function
snow.time(
  clusterApplyLB(cl, sleeptime, Sys.sleep)
)
```

```
## $elapsed
## [1] 52.59
## 
## $send
## [1] 0
## 
## $receive
## [1] 0
```
### parLApply()
This function wraps an invocation of clusterApply(). It splits x into a list of subvectors and processes those subvectors on the cluster workers using lapply. It preschedules the work by dividing the tasks into as many chunks as workers. This is important because it reduces the number of sends and recieves between the master and workers. In the case below with clusterApply() -- this means that the master is  not only sending the task, but also the matrix with every task.


```r
#example sys.sleep function
bigsleep <- function(sleeptime, mat) Sys.sleep(sleeptime)
bigmatrix <- matrix(0, 2000, 2000)
sleeptime <- rep(1, 100)

snow.time(
  clusterApply(cl, sleeptime, bigsleep, bigmatrix)
)
```

```
## $elapsed
## [1] 72.8
## 
## $send
## [1] 0
## 
## $receive
## [1] 0
```

```r
snow.time(
  parLapply(cl,  sleeptime, bigsleep, bigmatrix)
)
```

```
## $elapsed
## [1] 50.59
## 
## $send
## [1] 0
## 
## $receive
## [1] 0
```

### clusterSplit()
This function can be used similar to cases that use parLapply(), the difference is it doesn't need to use lapply() to call the users function. It will split the tasks according to the number of workers. This is useful for the user to define which components of the function that are to be run in parallel.


```r
clusterSplit(cl, 1:30)
```

```
## [[1]]
##  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
## 
## [[2]]
##  [1] 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
```

### foreach() %dopar% 
This function is a parallel extension of the _foreach_ package. It uses  doParallel or doSNOW to initialize the cluster. Note: objects outside of the foreach are sent to each cluster, if they are required within the parallel processing loop. It provides an easy conversion from foreach() %do% to a parallelized version.

```r
set.seed(7777442)
sleeptime<-abs(rnorm(10,10,10))

registerDoParallel(cl)#requires this
snow.time(
foreach (i=1:length(sleeptime)) %dopar%
  Sys.sleep(sleeptime[i])
)
```

```
## $elapsed
## [1] 52.64
## 
## $send
## [1] 0
## 
## $receive
## [1] 0
```

## stopCluster()
Once the parallel process is done - it is best to stop the cluster connections via

```r
#stopCluster.default(cl) #snow package
stopCluster(cl) #parallel package
```
