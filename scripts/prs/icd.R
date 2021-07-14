# icd codes
# ---------------------------------------

# Date of first in-patient diagnosis - ICD10
h5readAttributes(h5.fn,"f.41280")
dateICD10 = h5read(h5.fn,"f.41280/f.41280")
colnames(dateICD10) = h5readAttributes(h5.fn,"f.41280/f.41280")$f.41280
rownames(dateICD10) <- sample.id[,1]

# Date of first in-patient diagnosis - ICD9
h5readAttributes(h5.fn,"f.41281")
dateICD9 = h5read(h5.fn,"f.41281/f.41281")
colnames(dateICD9) = h5readAttributes(h5.fn,"f.41281/f.41281")$f.41281
rownames(dateICD9) <- sample.id[,1]

# # externalCauses data-coding 19
# h5readAttributes(h5.fn,"f.41201")
# externalCauses_datacoding19 = h5read(h5.fn,"f.41201/f.41201")
# colnames(externalCauses_datacoding19) = h5readAttributes(h5.fn,"f.41201/f.41201")$f.41201
# rownames(externalCauses_datacoding19) <- sample.id[,1]

# Diagnoses -  ICD10
h5readAttributes(h5.fn,"f.41270")
ICD10 = h5read(h5.fn,"f.41270/f.41270")
colnames(ICD10) = h5readAttributes(h5.fn,"f.41270/f.41270")$f.41270
rownames(ICD10) <- sample.id[,1]

# Diagnoses -  ICD9
h5readAttributes(h5.fn,"f.41271")
ICD9 = h5read(h5.fn,"f.41271/f.41271")
colnames(ICD9) = h5readAttributes(h5.fn,"f.41271/f.41271")$f.41271
rownames(ICD9) <- sample.id[,1]

#Death status
h5readAttributes(h5.fn,"f.40001")
causeOfDeath = h5read(h5.fn,"f.40001/f.40001")
colnames(causeOfDeath) = h5readAttributes(h5.fn,"f.40001/f.40001")$f.40001
rownames(causeOfDeath) <- sample.id[,1]

icd_codes_list = list(ICD10 = ICD10, 
                    dateICD10= dateICD10,
                    ICD9 = ICD9,
                    dateICD9 = dateICD9 )

