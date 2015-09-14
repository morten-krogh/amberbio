value_data = read.delim("Primary_vs_DistMetastases.csv", as.is = T, sep=",")
factor_data = read.delim("PatientData_140120.csv", as.is = T)

factor_subset = c(8:18, 21:22, 25:26, 30:32, 41:44, 47:50, 55:56)
factor_data_reduced = factor_data[factor_subset, ]

sample_names = paste("sample-", 1:28, sep = "")

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

factors = cbind(sample_names, patient_id, tumor_type, recurrence_site, er_status, pr_status, time_to_recurrence, age)
colnames(factors) = c("sample names", "patient", "tumor type", "recurrence site", "ER status", "PR status", "time to recurrence", "age")



write.table(t(factors), file = "breast-cancer-factors.txt", col.names = F, quote = F, sep = "\t")


