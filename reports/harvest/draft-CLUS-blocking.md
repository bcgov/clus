---
output: 
  html_document: 
    keep_md: yes
---


## Introduction
The size of a harvest unit (ie. a cutblock) has important implications for economic feasiblity, patch size distrubtion objectives and metrics important to wildlife habitat (Ie. distance to a cutblock). While forest cover-polygons, representing stand-level forest attributes, may be assumed as an operational unit; typically, harvest units have included the aggregation of many forest cover-polygons given harvesting operations can capture economies of scale from harvesting a number of stands in a spatially contiguous manner. Given the implications of harvesting units on wildlife and other forest values; how do we simulate into the future the size of these operational harvesting units? 

First, the spatial bounds on a cutblock, are generally predicated by law. The Forest Practices Code of British Columbia Act ["Operation and Site Planning Regulation"](http://www.bclaws.ca/civix/document/id/loo60/loo60/107_98) states (11(1)) - the maximum size of a harvest unit must not exceed 40 ha for coast forest region and some areas within the South interior region and 60 ha for the northern interior region and some areas within the South interior region. However, these maximal sizes can be increased further: given objectives from a high level forest plan for the salvage timber from natural disturbances; it retains 40% or more of the pre-harvest basal area or at the discretion of the district manager. Second, given these spatial bounds, we need an alogirthum for aggregating forest cover polygons or pixels into harvest units or blocks.

A block building algorithum aggregates forest cover polygons or pixels into harvest units or blocks. Note that the term block here does not convey any information concerning the geometry of the harvest unit but rather the term is used to describe an operational harvesting boundary which can take on many shapes and include alternative harvesting systems to notions of clearcutting and 'cutblocks'. Two general assumptions about block development can be made i) 'pre-blocking' (e.g., Murray and Weintraub 2002) which is used in a unit restrictive model (Murray 1999)  and ii) 'dynamic blocking' (e.g., Gustafson 1998) which is used in a area restriction model (Murray 1999).Typically, the choice of these assumptions are made in concordance with the proposed harvest scheduling approach. Under a pre-blocking approach, the entire landscape is divided into blocks before the harvest schedule is determined. This assunption can be limiting given harvest block configurations are to be be known _a_ _priori_ . Conversely, dynamic blocking assigns harvest unit size and determines its geometry during the harvest scheduling simulation. The advantages of 'pre-blocking' is a cost saving during run time of the simulation and the ability to provide an impetus to spatial optimization formulations of the harvest schedule problem. In particular, this information gives the planner insight into future outcomes from harvesting that could be used within a harvest scheduling model to make improved decisions (intertemporal decision making). An advantage of using a 'dynamic blocking' approach is that during the simulation, 'emergent processes' like salvage operations can be included to dictate block size. In particular, this approach presents the ability of the simulation to account for reactive decision making when modelling land uses under uncertainty. In reality a combination of these approaches is implemeneted (given the flexiblity of management) which allows advantages from both approaches to be realized.

### Dynamic blocking

The general dynamic blocking algorithum is as follows from Murray and Weintraub (2002):
1. the area is randomly seeded with blocks 'growing' around these seeds 
2. polygons/pixels are then grouped into harvest units based on the closest seed point
3. the harvest unit size is thus controlled by the number of initial seed points or some target size

This algorthium is very similar to a [k-means clustering](https://en.wikipedia.org/wiki/K-means_clustering) which partions _n_ pixels into _k_ clusters with each pixel belonging to a cluster with the nearest mean. The result of this process is ability to partition the data space into [Voronoi cells](https://en.wikipedia.org/wiki/Voronoi_diagram) which can be used to represent objects like harvest units. Various modifications to this approach have been made with consideration to i) using a randomly sampled block size target and ii) including various priorities for aggregating like stand type, age, and terrain for achieving objectives of block homogeneity. Both pre-blocking and dynamic blocking approches can be implemented with this simple algorithum.

### Pre-blocking 

Various approaches to 'pre-blocking' have included optimization formulations and near optimal solutions via heuristics. Lu and Eriksson (1999) used a genetic algorithum to build harvest units but this algorthium was applied to a 20 ha landscape with realtively long run-times. Boyland (2004) used simulated annealing to group polygons into harvest units based on area, age, species and shape criteria for the Invermere TSA. The use of algorithums with greater complexity increases the computational time and restricts the scalability of the analysis. These characteristics are vitally important to the caribou and landscape simulator, which requires the simulation of land use events across very large spatial and temporal scales in a timely manner. Thus, heuristics are of interest for pre-blocking. 

A problem with heuristic alogorithums is their ability to leave a local optimum to achieve a global optimum. For pre-blocking this means being able to accomodate variability in the forest or image of the forest. The process of 'pre-blocking' for purposes of creating spatially contigous harvesting units has some similarities to the image segementation problem. The goal of image segmentation is to partion or cluster pixels into regions that represent meaningful objects or parts of objects. The problem of segementing an image into objects has been posed by many studies for applications ranging from improving the stratification of the forest which is needed in some forest inventory sampling regimes to  interpreting biomedical images (e.g., delineating oragans or tumours). Typically, image sgenmentation involves either top-down or bottom-up perspectives.

Keeping in line with the forestry applications- a common commercial software used for image segemetnation is [eCognition](http://www.ecognition.com/). This software is proprietary, but uses a bottom-up region merging technique (Baatz and Schape 2000), that merges indiviudal pixels into larger objects based on a 'scale' parameter. However, Blaschke and Hay (2001), were largely unsucessful in finding any relatioship between this 'scale' parameter and spatial indicators which forces a trial and error approach for meeting segementation objectives (i.e., size and homogenity). Hay et al. (2005) attempted to overcome issues with parameters having no intuituvive meaning by developing multiscale object-specific segmentation (MOSS) which uses an integrative three-part approach. In particualr, the size constrained region merging (SCRM) is of importance to blocking harvest units in forestry land use models.

SCRM cencept stems from the topographic view of a watershed. Watersheds defines a network of ridges that represent the boundaries of where each drop of rain would drain towards. For region merging, the idea is to find sinks where the rain would drain to and then fill these uplift areas with water. As water fills a sink, these area represent contiguous are with similar features (i.e., elevation). Various size constraints can then be used to stop the process of merging and then various objects can be sperated.

In blockingCLUS, we leverage ideas from image based segementation and SCRM to develop a graph based image segementation approach that spatialy clusters pixels into harvest units based on similarity between adjacent pixels under size constraints. The following steps are used:
1. Convert the image into a undirected graph
2. Solve the minnimum spanning tree of the graph to get a list of edges
3. Sort the edgelist according to the weight (similarity of the two pixels)
3. Starting with the pixel with the largest degree, cluster surounding pixels until the largest size constraint has been met
4. When there are no more adjacent pixels or the size has been met, go on to the next block

The following is an example of an example test from using this algorithum

![](draft-CLUS-blocking_files/figure-html/unnamed-chunk-1-1.png)<!-- -->![](draft-CLUS-blocking_files/figure-html/unnamed-chunk-1-2.png)<!-- -->

## Case Study


The spatial simulation of cutblock size can be approached in 3 ways. 1) set the cutblock size as a random variable from a distribution (estimated empirically), 2) pre-solve the forest area into blocks by aggregating based on some rule

Below is a histogram of the historical (1908-2018) cutblock size which could be used direct block size.The negative "J" shaped curve is often similar to natural distruabnce size and thus provides some empirical evidence of cutblock size emulating natural disturbances which has been argued as a foundation for achieving forest management objectives. This is useful becuase forests without a comprehensive historical cutblock dataset could thus rely on the natural disturbance size distribution.

```r
dist.cutblk.size<-getTableQuery("select width_bucket(areaha, 0, 100, 100) as sizebin, count(*)
    from cns_cut_bl_polygon where harvestyr >= 1980 and datasource != 'Landsat'
    group by sizebin 
    order by sizebin;") 

ggplot(dist.cutblk.size, aes(x = sizebin,y =count)) +
  geom_bar(stat="identity") +
  xlab("Cutblock Size (ha)") + 
  ylab("Frequency")
```

![](draft-CLUS-blocking_files/figure-html/unnamed-chunk-3-1.png)<!-- -->





#References

Gustafson, E.J. 1998. Clustering timber harvests and the effect of dynamic forest management policy on forest fragmentation.
Ecosystems 1:484-492.

Nelson, J.D. 2001. Assessment of harvest blocks generate from operational polygons and forest cover polygons in tactical and strategic planning. Can. J. For. Res. 31:682-693.

Lu, F. and Eriksson, L.O. 2000. Formation of harvest units with genetic algorithms. For. Ecol. And Manage. 130:57-67. 

Murray, A.T., and Weintraub, A. 2002. Scale and unit specification influences in harvest scheduling with maximum area restrictions. For. Sci. 48(4):779-789.

