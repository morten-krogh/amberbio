setwd("/Users/mkrogh/amber/app/Amberbio/demo-data/diabetes")

values  = read.delim("diabetes-values.txt", as.is = T, sep="\t", row.names = 1, header = T)
factors = read.delim("diabetes-factors.txt", as.is = T, sep=",", row.names = 1, header = T)

nans = apply(values, 1, function(x){sum(is.na(x))})

values0 = values[nans == 0, ]

distf = function(i, j) {
      dist(t(cbind(values0[,i], values0[,j])))
}

nnk = function(i, k) {
   dists = rep(0, 12)
   for (j in 1:12) {
       dists[j] = distf(i, j)
   }

   nnindices = order(dists)[2:(k+1)]
   facs = factors[1,nnindices]

   if (sum(facs == "Healthy") > k / 2) {
      return("Healthy")
   } else if (sum(facs == "Diabetic") > k / 2)  {
      return("Diabetic")
   } else {
     return("Unclassified")
  }  

   return(facs)
}








#iris_table = t(iris_data[,1:4])

#sample_names = c(paste("iris-setosa", 1:50, sep = "-"), paste("iris-versicolor", 1:50, sep = "-"), paste("iris-virginica", 1:50, sep = "-"))
#colnames(iris_table) = sample_names

#molecule_names = c("sepal length", "sepal width", "petal length", "petal width")
#rownames(iris_table) = molecule_names

#write.table(iris_table, file = "/Users/mkrogh/amber/app/Bioinformatics/data/iris/iris_values.txt", sep=",", quote = F, row.names = T, col.names = NA)


#species = c(rep("iris-setosa", 50), rep("iris-versicolor", 50), rep("iris-virginica", 50))

#factor_table = matrix(species, nrow = 1, ncol = 150)
#rownames(factor_table) = "species"
#colnames(factor_table) = sample_names

#write.table(factor_table, file = "/Users/mkrogh/amber/app/Bioinformatics/data/iris/iris_factors.txt", sep=",", quote = F, row.names = T, col.names = NA)
