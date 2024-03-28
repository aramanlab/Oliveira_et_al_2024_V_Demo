## Oliveira_et_al_2024
This repository pertains to the manuscript "Statistical Design of a Synthetic Bacterial Community that Clears a multi-drug Resistant gut 
pathogen."

____________________________________________________________________________
#### Installation:

1. In your terminal type and execute the following:
          git clone https://github.com/aramanlab/Oliveira_et_al_2024.git


2. Alternatively, go to the link https://github.com/aramanlab/Oliveira_et_al_2024.git. And download the zip file.

Installation/Download Time: 1 minute. 
_____________________________________________________________________________
### Pseudocodes:
Pseudocodes describing the overarching steps in the calculations can be found in the Pseudocodes folder as well as folders with notebooks.
They also contain Run times for the codes they describe.
_____________________________________________________________________________

_____________________________________________________________________________

### Datasets:
This repository contains the following datasets:
____________________________________________________________________________

1. consortia_taxa_presence_and_KpCFUs.csv------- [Iput => RF_Model_Metabolites.ipynb, Strain_Space_Principal_component_landscape.ipynb]
2. Metabolite_120_Hr_dataset.csv-------            [Input => RF_Model_Metabolites.ipynb, Metabolite_Space_Principal_component_landscape.ipynb]
3. Metabolite_120_Hrs_OOS_set_log10_CFU.csv-------        [Input => \rightarrow$  RF_Model_Metabolites.ipynb]
4. PCA_coordinates_Metabolite_space_original_81.csv -------       [Metabolite_Space_Principal_component_landscape.ipynb => Output]
5. PCA_coordinates_Strain_Presence_Absence_Space_Original_96.csv -------   [Strain_Space_Principal_component_landscape.ipynb => Output] 
6. Strain_pool_66_DFI_with_umap_coordinates.xlsx-------     [Input =>  Umap_based_design_of_96_communities.R]
7. Initial_96_community.xlsx -------         [Input => RF_model_on_strains.ipynb] 
8. Validation_60_Communities.xlsx  -------   [Input => RF_model_on_strains.ipynb]
9. metadata_16s.xlsx --------                [Input => Fig3D_and_3E.Rmd]
10. metadata_16s.xlsx--------                [Input => Fig3F_taxplot.R]
11. 16S_phyloseq.rds --------                [Input => Fig3D_and_3E.Rmd]
12. 16S_otu_pctseqs.csv-------               [Input => Fig3F_taxplot.R]

________________________________________________________________________
### Python/R Notebooks and Scripts:
This repository contains the following notebooks:
________________________________________________________________________________________
#### Author: Bipul Pandey: [Mac OS 14.4 Python 3.9.12]
   Major Package Detail: scikit-learn[1.0.2] , scipy[1.7.3], Matplotlib[3.5.1] 
  1. Jupyter Notebook to construct Metabolite space landscape of the original experiments
               [Metabolite_Space_Prinincipal_component_landscape.ipynb]                     [Runtime 5 minutes]
  2. Jupyter Notebook to construct Strain space landscape of the original experiments
               [Strain_Space_Prinincipal_component_landscape.ipynb]                         [Runtime 5 minutes]
  3. Jupyter Notebook to construct a Random Forest Model on Metabolites to predict KP suppression
               [RF_Model_Metabolites.ipynb]                                                  [Runtime 5 minutes]
     <br /> - Trained on original 96 experiments
     <br /> - Tested on 60 Out-of-sample experiments 

#### Author: Robert Y. Chen [Windows 11 R 4.3.1] 
  1. R-script for synthetic community analysis [Robert_Script_for_Synthetic_Community_Analysis.R] 

#### Author: Kiseok Lee [Mac OS 14.4 R 4.0.3] 
  1. R-script for designing the original 96 communities from UMAP [Umap_based_design_of_96_communities.R] [Runtime 30 minutes]

#### Author: Mahmoud Yousef [Mac OS 14.4 Python 3.10.13]:
  Major Package Detail: scikit-learn[1.3.0],
  1. Jupyter Notebook to construct a Random Forest Model on Strains to predict KP suppression [RF_model_on_strains.ipynb]
        <br /> - Trained on original 96 experiments                     [Runtime 2 minutes]
        <br /> - Validated on 60 Out-of-sample experiments              [Runtime 2 minutes]
        <br /> - Exploration of 1,000,000 in-silico experiments         [Runtime 40 minutes]


#### Author: Ramanujam Ramaswamy: [Mac OS 14.4 R 4.2.2]
  1. R-script for generating taxonomy plot from 16S data [Fig3F_taxplot.R]
  2. R-markdown for computing alpha and beta diversities from 16S data [Fig3D_and_3E.Rmd]
___________________________________________________________________________________________________________________________________
      


