iris_data = read.delim("/Users/mkrogh/amber/app/Bioinformatics/data/iris/bezdekIris.data", as.is = T, sep=",", header = F)

iris_table = t(iris_data[,1:4])

sample_names = c(paste("iris-setosa", 1:50, sep = "-"), paste("iris-versicolor", 1:50, sep = "-"), paste("iris-virginica", 1:50, sep = "-"))
colnames(iris_table) = sample_names

molecule_names = c("sepal length", "sepal width", "petal length", "petal width")
rownames(iris_table) = molecule_names

write.table(iris_table, file = "/Users/mkrogh/amber/app/Bioinformatics/data/iris/iris_values.txt", sep=",", quote = F, row.names = T, col.names = NA)


species = c(rep("iris-setosa", 50), rep("iris-versicolor", 50), rep("iris-virginica", 50))

factor_table = matrix(species, nrow = 1, ncol = 150)
rownames(factor_table) = "species"
colnames(factor_table) = sample_names

write.table(factor_table, file = "/Users/mkrogh/amber/app/Bioinformatics/data/iris/iris_factors.txt", sep=",", quote = F, row.names = T, col.names = NA)
