# ---------------------------------------------
# Clear environment and load libraries

rm(list = ls())
library(data.table)
# ---------------------------------------------
# Load config
source("Rscripts/config.R")

# ---------------------------------------------
## Get related id

kingkin = fread(KING_KIN_FILE)

#Load king output file
king = fread(KING_KIN0_FILE, header = T)
length(king$FID1) # 31 relationship pairs

king2 = king

# plot relationships. Kinship coefficient vs IBSO
library(ggplot2)
ggplot(king2, aes(x=IBS0, y=Kinship))+geom_point()

### Set kin ship coefficients cut-offs. Generate values
cut.dup <- 1/(2^(3/2)) # 0.354 (duplicate or MZ twins)
cut.deg1 <- 1/(2^(5/2)) # 0.177 (1st degree)
cut.deg2 <- 1/(2^(7/2)) # 0.884 (2nd degree)
cut.deg3 <- 1/(2^(9/2)) # 0.0442 (3rd degree)

# In king df: if kinship coefficient >= to cut.deg3 (0.0443), then insert 1 in new related col.
king2$related <- ifelse(king$Kinship >= cut.deg3, 1, 0)

#Subset the related pairs (related=1) to new df
kingrelatedpairs <- subset(king2, king2$related==1, select = c("FID1", "FID2", "HetHet","IBS0", "Kinship"))

# Set strings as factors
kingrelatedpairs <- data.frame(kingrelatedpairs, stringAsFactors = F)
# As character
kingrelatedpairs$FID1 <- as.character(kingrelatedpairs$FID1)
kingrelatedpairs$FID2 <- as.character(kingrelatedpairs$FID2)

# Sorting and count how many times each individual is in a pair (either as FID1 or FID2)
multiples = sort(table(c(kingrelatedpairs$FID1, kingrelatedpairs$FID2)), decreasing = T)

multiples_df = as.data.frame(multiples)

# Set names
names(multiples) <- as.character(names(multiples))

# New column multiple.1 including how many times FID1 is present
kingrelatedpairs$multiple.1 = sapply(kingrelatedpairs$FID1, function(x){		multiples[x]
})

# New column multiple.2 including how many times FID2 is present
kingrelatedpairs$multiple.2 = sapply(kingrelatedpairs$FID2, function(x){		multiples[x]
})

# Set columns as numeric
kingrelatedpairs$multiple.1 <- as.numeric(kingrelatedpairs$multiple.1)
kingrelatedpairs$multiple.2 <- as.numeric(kingrelatedpairs$multiple.2)

# New column remove including NA
kingrelatedpairs$remove = NA

# Order df according to multiple.1 fist and then multiple.2
kingrelatedpairs = kingrelatedpairs[order(kingrelatedpairs$multiple.1, kingrelatedpairs$multiple.2, decreasing = T),]

# For all rows in kingrelatedpairs find those individuals present multiple times/those having multiple connections, which are to be removed
for (i in 1:dim(kingrelatedpairs)[1]){
	
	# line by line
	pair = kingrelatedpairs[i,]
	
	if(!is.na(kingrelatedpairs[i,]$remove)) {
		print(paste(i,"row already set"))
		next
	}

	# If multiple.1 < multiple.2 then this (else go to multiple.1 >= multiple.2)
	if(pair$multiple.1 < pair$multiple.2) {
		kingrelatedpairs[kingrelatedpairs$FID1 == pair$FID2 | kingrelatedpairs$FID2 == pair$FID2,]$remove = pair$FID2

	# 1st cel (FID1) for ID where multiple.1 < multiple.2
		idx = which(kingrelatedpairs$remove == pair$FID2 & kingrelatedpairs$FID1 == pair$FID2)
		if(length(idx) > 0) kingrelatedpairs[idx, ]$multiple.2 <- kingrelatedpairs[idx, ]$multiple.2 - 1

	# 2nd col (FID2)
		idx = which(kingrelatedpairs$remove == pair$FID2 & kingrelatedpairs$FID2 == pair$FID2)
        	if(length(idx) > 0) kingrelatedpairs[idx, ]$multiple.1 <- kingrelatedpairs[idx, ]$multiple.1 - 1

		next
	} 

	# If multiple.1 >= multiple.2
	else if (pair$multiple.1 >= pair$multiple.2){
		kingrelatedpairs[kingrelatedpairs$FID1 == pair$FID1 | kingrelatedpairs$FID2 == pair$FID1,]$remove = pair$FID1
		
		idx = which(kingrelatedpairs$remove == pair$FID1 & kingrelatedpairs$FID1 == pair$FID1)
		if(length(idx) > 0) kingrelatedpairs[idx, ]$multiple.2 <- kingrelatedpairs[idx, ]$multiple.2 -1

		idx = which(kingrelatedpairs$remove == pair$FID1 & kingrelatedpairs$FID2 == pair$FID1)
                if(length(idx) > 0) kingrelatedpairs[idx, ]$multiple.1 <- kingrelatedpairs[idx, ]$multiple.1 -1

		next
	}
}
			
# New df with unique individuals that have to be removed. Print ID twice in new df.
excluderelated <- data.frame(unique(kingrelatedpairs$remove), unique(kingrelatedpairs$remove))

length(excluderelated$unique.kingrelatedpairs.remove..1) # 31 related individuals

write.table(excluderelated, file = EXCLUDE_RELATED, sep="\t", quote = F, row.names = F, col.names = F)

# How many 1st and 2nd degree
related_first_second = subset (kingrelatedpairs, Kinship>0.354 | Kinship>0.0884 & Kinship<0.177)
head(related_first_second)
length(related_first_second$FID1) # 3
 
