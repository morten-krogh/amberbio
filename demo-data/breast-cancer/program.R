#value_data = read.delim("Primary_vs_DistMetastases.csv", as.is = T, sep=",")
factor_data = read.delim("PatientData_140120.csv", as.is = T)

value_data = read.delim("Primary_vs_LocRec.csv", as.is = T, sep=",")

factor_subset = c(57:58, 63:70, 73:74, 81:92)
#factor_subset = c(8:10, 12:15, 17:18, 21:22, 26, 30:32, 42:44, 48:50, 55:56)
factor_data_reduced = factor_data[factor_subset, ]

sample_names = paste("sample-", 1:24, sep = "")

patient_id = factor_data_reduced[, 1]
tumor_type = factor_data_reduced[, 5]
tumor_type[tumor_type == "Rec"] = "recurrence"
tumor_type[tumor_type == "Prim"] = "primary"
recurrence_site = factor_data_reduced[, 6]
er_status = factor_data_reduced[, 8]
er_status[er_status == "0"] = "negative"
er_status[er_status == "1"] = "positive"
pr_status = factor_data_reduced[, 9]
pr_status[pr_status == "0"] = "negative"
pr_status[pr_status == "1"] = "positive"
time_to_recurrence = factor_data_reduced[, 16]
age = factor_data_reduced[, 18]
age = round(age)

factors = cbind(sample_names, patient_id, tumor_type, recurrence_site, er_status, pr_status, time_to_recurrence, age)
colnames(factors) = c("sample names", "patient", "tumor type", "recurrence site", "ER status", "PR status", "time to recurrence", "age")

samples_in_values = c(36, 64, 12, 40, 14, 42, 45, 17, 35, 63, 21, 49, 51, 23, 53, 25, 46, 18, 66, 39, 27, 54, 56, 28)

#samples_in_values = c(40, 38, 12, 30, 42, 14, 32, 44, 16, 46, 18, 34, 50, 48, 20, 53, 55, 25, 37, 26, 57, 58, 29)

values = value_data[3:1446, samples_in_values]
colnames(values) = sample_names
rownames(values) = value_data[3:1446, 1]


annotations = value_data[3:1446, c(2,11)]
colnames(annotations) = c("peptide count", "description")
rownames(annotations) = value_data[3:1446, 1]



write.table(annotations, file = "breast-cancer-annotations.txt", col.names = NA, quote = F, sep = "\t")
write.table(values, file = "breast-cancer-values.txt", col.names = NA, quote = F, sep = "\t")
write.table(t(factors), file = "breast-cancer-factors.txt", col.names = F, quote = F, sep = "\t")






