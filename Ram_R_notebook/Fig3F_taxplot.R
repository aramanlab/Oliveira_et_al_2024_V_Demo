# Taxonomy plot

library(tidyverse)

# Make sure to navigate to the working directory with the folder "Datasets"
setwd("YOUR WORKING DIRECTORY")

source("Ram_code/getRdpPal.R")

df_meta = read_excel("Datasets", "metadata_16s.xlsx")

calWidth = function(nsamples){ return(4.5 + 0.28*nsamples) }
treads = sum(sample_data(physub)$reads.in)
freads = sum(sample_data(physub)$reads.out)

t = read.csv("Datasets", "16S_otu_pctseqs.csv") %>%
  replace_na(list(Species="unclassified",
                  Genus="unclassified",
                  Family="unclassified",
                  Order="unclassified",
                  Class="unclassified",
                  Phylum="unclassified")) %>%
  mutate(Genus=ifelse(Genus=="unclassified",
                      paste(Family,Genus,sep="\n"),
                      as.character(Genus))) 


t_new = t %>% 
  mutate(sample_id = gsub("\\.", "_", sampleid)) %>% 
  dplyr::select(-any_of(c("experiment", "day", "mouse", "group"))) %>% 
  left_join(df_meta) %>% 
  dplyr::select(sample, sample_id, experiment, day, mouse, group, 
                Kingdom, Phylum, Class, Order, Family, Genus, pctseqs) %>% 
  
  group_by(day, group, 
           Kingdom, Phylum, Class, Order, Family, Genus, pctseqs) %>% 
  summarize(pctseqs = mean(pctseqs)) %>% 
  ungroup() %>% 
  
  mutate(day = stringr::str_pad(day, 2, side="left", pad="0"),
         day = paste0("D", day)) %>% 
  mutate(sample = paste0(day, "_", group)) %>% 
  
  group_by(sample) %>% 
  mutate(pctseqs = pctseqs/sum(pctseqs))


pal = getRdpPal(t_new)
wd = calWidth(length(unique(t_new$sample)))
lvls = unique(t_new$sample)

gg = t_new %>%
  group_by(group, sample, Kingdom,Phylum,Class,Order,Family,Genus) %>%
  summarise(pctseqs=sum(pctseqs)) %>%
  ungroup() %>%
  arrange(Kingdom, Phylum, Class, Order, Family, Genus) %>% 
  mutate(Genus = factor(Genus, levels = unique(Genus))) %>% 
  group_by(group, sample) %>% 
  arrange(Genus) %>% 
  mutate(cum.pct = cumsum(pctseqs), 
         y.text = (cum.pct + c(0, cum.pct[-length(cum.pct)]))/2) %>% 
  ungroup() %>%
  dplyr::select(-cum.pct) %>% 
  mutate(
    tax.label= if_else(grepl("unclassified",Genus), 
                       "unclassified",
                       as.character(Genus))) %>%
  mutate(tax.label = if_else(pctseqs >= .1, tax.label, "")) %>%
  
  mutate(sample = factor(sample, levels = lvls)) %>% 
  mutate(sample = gsub("_.*", "", sample)) %>% 
  
  mutate(group = factor(group, levels = c("PBS", "FMT", "Block 19", "Block 20", "SynCom15 (Block 16+20)"))) %>% 
  
  ggplot(aes(x=sample,y=pctseqs)) +
  geom_bar(aes(fill=Genus), stat="identity") +
  geom_text(aes(y=1-y.text,x=sample,label=tax.label), angle=90,
            lineheight=0.6,size=2.5) +
  scale_fill_manual(values=pal) +
  facet_grid(. ~group, scales = "free") +
  ggtitle("RDP 16s Taxonomy") +
  ylab("16S % Abundance") +
  xlab("") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=60, vjust = 0.5, hjust = 1 )) +
  theme(
    panel.grid = element_blank(),
    strip.text.x=element_text(size=13),
    legend.position="none") 


gg

