Link to the dataset used: https://www.kaggle.com/datasets/danielgrijalvas/movies

Main goal of the project is finding out which one of the features has the highest
correlation with the total revenue of a movie.

Firstly, some data cleaning is done using Pandas:
- handling missing values
- converting some data types
- using .split() method to split one column into multiple columns, and then stripping
  all blank spaces using .strip() method
- dropping unnecessary columns 
- dropping duplicates

Then some exploratory data analysis is done, like using boxplots to detect outliers,
plotting scatterplots to look at the correlations between features, using correlation
matrix and heatmap to display correlation between all numeric features. 
