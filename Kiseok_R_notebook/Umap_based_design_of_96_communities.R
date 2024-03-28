# libraries
library(dplyr)
library(ggplot2)
library(tidyverse)
library(openxlsx)
library(ape)
library(tidyr)
library(fields)


## Import strain pool data
Strain_pool <- read.xlsx("../Datasets/Strain_pool_66_DFI_with_umap_coordinates.xlsx")


## functions

## Function for plotting UMAP coordinates for a subset of strain pools
plot_UMAP <- function(strain_set){
  Strain_pool_subset <- Strain_pool %>% filter(phy_id %in% strain_set)
  ggplot(Strain_pool_subset, aes(x=umapA1, y=umapA2)) +
    xlab('umap A1')+
    ylab("umap A2") +
    geom_point(aes(fill = genus), shape = 21 ,size=4, alpha=0.9) +
    scale_fill_manual(values = my_color_collection)+
    ggtitle(paste0("UMAP coordination"," \n")) +
    theme(legend.text=element_text(size=13)) +
    theme_bw()
}

## Random sampling function: randomly select n number of different species many times (rand_num)

# execute function
sampling_func <- function(rand_num = 10000, n = 20, lower_percentile){
  # rand_num = 10000 # how many sampling
  # n = 20 # community size

  # set empty list
  sampling20_list <- list()

  # do sampling for rand_num of times
  for (rand in 1:rand_num){
    # print(rand)
    # random sampling
    strain20_rand <- sample(Strain_pool$phy_id, n)
    strain20_coor <- Strain_pool %>% filter(phy_id %in% strain20_rand) %>% select(phy_id, umapA1, umapA2) # Using the Strain pool of 66 strains
    strain20_coor <- tibble::column_to_rownames(strain20_coor, var="phy_id")
    strain20_dist <- rdist(strain20_coor)
    dim(strain20_dist)
    strain20_dist <- as.data.frame(strain20_dist)
    rownames(strain20_dist) <- rownames(strain20_coor)
    colnames(strain20_dist) <- rownames(strain20_coor)
    head(strain20_dist)

    # get minimum distance (minimum positive)
    nearest_dist_vec <- apply(strain20_dist, 1, FUN = function(x) {min(x[x > 0])})
    nearest_dist_vec <- nearest_dist_vec[order(nearest_dist_vec)] # order from lowest to highest

    # nearest distance for lower percentile
    nearest_dist_vec[1:round(n*lower_percentile)]
    # get mean of nearest UMAP distance
    mean1 = mean(nearest_dist_vec[1:round(n*lower_percentile)])

    # save in list
    sampling20_list[[rand]] <- list(
      mean_nearest_distance = mean1,
      distance_mat = strain20_dist
    )
  }
  return(sampling20_list)
}

## Function to maximize mean nearest distance of lower 30% percentile. (confer methods for details)
mix_selection <- function(rand_num, n, lower_percentile){
  # Sampling
  strain20_per <- sampling_func(rand_num, n, lower_percentile)

  # Computing the mean nearest distance
  mean_nearest_dist_vec <- c()
  for (i in 1:rand_num){
    mean_nearest_dist_vec[i] <- strain20_per[[i]]$mean_nearest_distance
  }

  max_set <- strain20_per[[which.max(mean_nearest_dist_vec)]]$distance_mat   # matrices
  max_30strain_list <- rownames(max_set)  # strain_id
  max_dist <- strain20_per[[which.max(mean_nearest_dist_vec)]]$mean_nearest_distance   # nearest distance

  # return list
  l_set <- list(n = n,
                mix = max_30strain_list,
                dist = max_dist)
  return(l_set)
}


# Decide how many communities do you want with which size
combination_vec <- c(1, 1, 1, 1, 2, 2, 3, 5, 8, 14, 20, 14, 8, 5, 3, 2, 2, 1, 1, 1, 1) # number of communities of certain size
names(combination_vec) <- c(2, 4, 6, 8, 10, 12, 14, 16, 17, 18, 20, 22, 23, 24, 26, 28, 30, 34, 36, 38, 40) # community size

# Execute and design the combinations
mix_list <- list()
index = 1
val_rand_num = 10000 # chose how many times for random sampling
for (i in 1:length(combination_vec)){
  # print(i)
  com_num <- as.numeric(names(combination_vec[i]))
  replicate <- combination_vec[[i]]
  for (j in 1:replicate){
    # print(j)
    single_mix <- mix_selection(rand_num = val_rand_num, n = com_num, lower_percentile = 0.3) # 10000
    mix_list[[index]] <- single_mix
    index = index + 1
  }
}

# Check values of first community
mix_list[[1]]$n
mix_list[[1]]$dist


# Confirming we designed the right number of communities with histogram
vec_n <- c()
for (i in 1:length(mix_list)){
  vec_n[i] <- mix_list[[i]]$n
}
hist(vec_n, breaks = 50)

# Visualize the Umap of the 96th community. (Change the number for others)

my_color_collection <- c(
  "#CBD588", "#5F7FC7", "orange", "#AD6F3B", "#673770",
  "#D14285", "#652926", "#C84248", "#8569D5", "#5E738F",
  "#D1A33D", "#8A7C64", "#599861","#616163", "#FFCDB2",
  "#6D9F71", "#242F40",
  "#CCA43B", "#F92A82", "#ED7B84", "#7EB77F",
  "#DEC4A1", "#E5D1D0", '#0E8482', '#C9DAEA', '#337357',
  '#95C623', '#E55812', '#04471C', '#F2D7EE', '#D3BCC0',
  '#A5668B', '#69306D', '#0E103D', '#1A535C', '#4ECDC4',
  '#F7FFF7', '#FF6B6B', '#FFE66D', '#6699CC', '#FFF275',
  '#FF8C42', '#FF3C38', '#A23E48', '#000000', '#CF5C36',
  '#EEE5E9', '#7C7C7C', '#EFC88B', '#2E5266', '#6E8898',
  '#9FB1BC', '#D3D0CB', '#E2C044', '#5BC0EB', '#FDE74C',
  '#9BC53D', '#E55934', '#FA7921', "#CD9BCD", "#508578", "#DA5724")

plot_UMAP(mix_list[[96]]$mix)




