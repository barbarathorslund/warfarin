library(data.table)
library(EnhancedVolcano)

Livereqtl <- fread("/Users/barbara/Documents/barbara/warfarin/data/MetaXcan/spredixcan/eqtl/meta_warf_additive__PM__Liver_L.csv") 

Livereqtl <- Livereqtl %>%
  remove_rownames() %>%
  column_to_rownames(var = 'gene_name')



volcano <- EnhancedVolcano(Livereqtl,
                lab = rownames(Livereqtl),
                x = 'effect_size',
                y = 'pvalue',
                xlim = c(-4, 7.5),
                ylim =c(0,320),
                #selectLab = c('CYP2C8', 'VKORC1','ZNF668','RP11-196G11.6', 'ZNF646', 'KAT8', 'RP11-196G11.2',
                              #'PRSS8', 'RP11-1072A3.4', 'STX1B', 'ZNF768', 'SETD1A', 'ZNF747',
                              #'BCKDK', 'STX4', 'PRSS36', 'BCL7C', 'RNF40', 'ARMC5'),
                xlab = bquote('Effect size'),
                pCutoff = 4.98e-06,
                FCcutoff = 0,
                pointSize = 4,
                labSize = 4.5,
                boxedLabels = TRUE,
                drawConnectors = TRUE,
                widthConnectors = 0.75)
                #lengthConnectors = unit(0.05, 'npc'))
                #ylim = c(0, -log10(10e-12)))

png(file= paste(PLOTS_DIR,"Volcano_warfdose.png", sep = "/"), width = 10, height = 10, units = "in", res = 400)

volcano
dev.off()
