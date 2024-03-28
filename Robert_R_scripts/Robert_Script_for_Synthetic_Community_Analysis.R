
# Loading Packages
library(tidyverse)
library(FactoMineR)

# Create a clean plotting theme
themeClean <- 
  theme(axis.text = element_text(size = 6, color = "#000000"),
        axis.title = element_text(size = 8),
        title = element_text(size = 8), 
        legend.text = element_text(size = 8),
        rect = element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),plot.background=element_blank(),
        axis.line.x.bottom = element_line(color = 'black', size = 0.3525, lineend = 'round'),
        axis.line.y.left = element_line(color = 'black', size =  0.3525, lineend = 'round'),
        axis.ticks = element_line(lineend = 'round', size = 0.3525, color = "black"),
        panel.background = element_blank())

########################
#
#
# 1. Data Setup
#
#
########################

### i. Loading data
# Make sure to navigate to the working directory with the file "Synthetic_Communities_Less_than_5kp.RData", then load
load("Synthetic_Communities_Less_than_5kp.RData")
# This will load an R object called raw_data, or "M" in the Methods 
# Rows represent different synthetic communities
# Columns represent strains (except the last column)
# Each element is a binary 0/1 if a strain was in a community
# The last column denotes the RF predicted log10 Kp CFU/mL aka suppression for a given community. Lower number means more suppression

### ii. Organize data into tibble
data <- raw_data
data_tibble <-
  data %>% 
  tibble::as_tibble(rownames = 'mix_number')

### iii. Separate community makeup from outcome
kp_final <- data[, ncol(data)]
data <- data[, 1:(ncol(data)-1)]

### iv. Create a sample dataset that describes features of the communities
# This should include the number of different strains in the community, as well as different suppression groups
samples <- data.frame(
  mix_number = data_tibble$mix_number, 
  n_members = rowSums(data[, 2:ncol(data)]),
  kp_group = rep("kp_5", nrow(data)),
  kp_final = kp_final
)
samples$kp_group[samples$kp_final <= 4.5] <- "kp_4_5"
samples$kp_group[samples$kp_final <= 4] <- "kp_4"

########################
#
#
# 2. Removing information regarding community diversity
#
#
########################
### i. Plot the level of suppression as a function of community diversity
ggplot(samples, aes(x = n_members, y = kp_final) ) +
  geom_point(alpha = 0.2, color = 'white', stroke = .2, fill = '#3F516AFF', size = 1, shape = 21) +
  themeClean +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  xlab("Number of Community Members") +
  ylab("log10(CFU/mL)") +
  theme(legend.position='none')
# Is this relationship significant?
lm_n_members_v_kp <- lm(kp_final ~ n_members, data = samples)
summary(lm_n_members_v_kp) # p < 10^-16

### ii. Regress out Kp suppression information related to community size
kp_residualized <- lm_n_members_v_kp$residuals 

########################
#
#
# 3. Principal Component Analysis
#
#
########################
###### 1. Perform a basic principal components analysis
pca_1 <- PCA(data, ncp = min(dim(data)), scale.unit = FALSE, graph = FALSE)
u_1 <- pca_1$ind$coord # These are the row projections
v_1 <- pca_1$var$coord # These are the column projections
u_coords <- data.frame(cbind(u_1, log10kp = samples$kp_final)) # Adding kp suppression
u_coords$n_members <- samples$n_members # Adding community diversity
u_coords$log10kp_residualized <- kp_residualized # Adding residualized kp suppression

### i. Does PC1 contain any information about community diversity?
plot(u_coords$Dim.1, u_coords$n_members)
lm_PC1_v_diversity <- lm(n_members ~ Dim.1, data = u_coords)
lm_PC1_v_diversity_results <- coefficients(summary(lm_PC1_v_diversity))
lm_PC1_v_diversity_results # p = 4.4x10^-97
ggplot(data = u_coords) +
  geom_point(aes(x = Dim.1, y = n_members), alpha = 0.2, color = 'white', stroke = .2, fill = '#3F516AFF', size = 1, shape = 21) +
  themeClean +
  ggtitle('PC1 vs Community Diversity') +
  xlab('PC1 (2.9% Variance Explained') +
  ylab('Community Diversity')

### ii. Identify which PCs share the most information with Kp
pca_regression_results <- matrix(0, nrow = ncol(u_1), ncol = 4)
rownames(pca_regression_results) <- colnames(u_1)
colnames(pca_regression_results) <- c("beta", "SE", "t", "p")
for(i in 1:ncol(u_1)){ # This loop creates a linear model for each PC and tests its relationship 
  formula1 <- paste('log10kp ~ Dim.', i, sep = '')
  formula1 <- as.formula(formula1)
  lm1 <- lm(formula1, data = u_coords)
  pca_regression_results[i, ] <- coefficients(summary(lm1))[2, ]
}
pca_regression_results <- data.frame(pca_regression_results)
pca_regression_results$q <- p.adjust(pca_regression_results$p, method = 'fdr') # Adding FDR-adjusted p-value
pca_regression_results <- pca_regression_results[order(pca_regression_results$q, decreasing = FALSE), ]
pca_regression_results
write.csv(pca_regression_results, file = "linear_models_PCs_v_Kp.csv")

### iii. Identify which PCs share the most information with residualized Kp
pca_regression_results_residualized <- matrix(0, nrow = ncol(u_1), ncol = 4)
rownames(pca_regression_results_residualized) <- colnames(u_1)
colnames(pca_regression_results_residualized) <- c("beta", "SE", "t", "p")
for(i in 1:ncol(u_1)){ # This loop creates a linear model for each PC and tests its relationship 
  formula1 <- paste('log10kp_residualized ~ Dim.', i, sep = '')
  formula1 <- as.formula(formula1)
  lm1 <- lm(formula1, data = u_coords)
  pca_regression_results_residualized[i, ] <- coefficients(summary(lm1))[2, ]
}
pca_regression_results_residualized <- data.frame(pca_regression_results_residualized)
pca_regression_results_residualized$q <- p.adjust(pca_regression_results_residualized$p, method = 'fdr') # Adding FDR-adjusted p-value
pca_regression_results_residualized <- pca_regression_results_residualized[order(pca_regression_results_residualized$q, decreasing = FALSE), ]
pca_regression_results_residualized
write.csv(pca_regression_results_residualized, file = "linear_models_PCs_v_KpResidualized.csv")

### iii. Plot a regression line between PC46 and Kp suppression
ggplot(data = u_coords) +
  geom_point(aes(x = Dim.46, y = log10kp), alpha = 0.2, color = 'white', stroke = .2, fill = '#3F516AFF', size = 1, shape = 21) +
  themeClean +
  ggtitle('PCA (scaled) all communities') +
  xlab('PC46 (0.43% Variance Explained)') +
  ylab('log10(CFU/mL)')

### iv. Plot a regression line between PC46 and residualized Kp suppression
ggplot(data = u_coords) +
  geom_point(aes(x = Dim.46, y = log10kp_residualized), alpha = 0.2, color = 'white', stroke = .2, fill = '#3F516AFF', size = 1, shape = 21) +
  themeClean +
  ggtitle('PCA (scaled) all communities') +
  xlab('PC46 (0.43% Variance Explained)') +
  ylab('log10(CFU/mL)')

########################
#
#
# 4. Hierarchical clustering of strains based on their PC46 projection
#
#
########################
### i. Assess the distance matrix using PC46 only
dist1 <- v_1[, 46] # Take the PC46 column projections
dist1 <- dist(dist1, diag = TRUE) # Create euclidian distance matrix
sim1 <- max(as.matrix(dist1))- as.matrix(dist1) # 
pheatmap(sim1,
         color = colorRampPalette(c('white', 'darkblue'))(200)
         )

