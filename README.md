# R-stata-tutorials
Teaching materials for a set of NYU methods demos

---

# Should I choose R or STATA?

You will hopefully pick whichever software makes *you* more productive. 

### Open Science

R is the winner.

### Open-souce + cost considerations

STATA: Some people will say "why would you pay for Stata?" Or "why would you pay for software that does LESS THAN R?" These are reasonable questions but don't forget that there are also upsides to using software with a *finite set of commands*. 

**Again, Stata is more likely to do what you expect it to do.**

R: The benefits of countless packages and user-written functions (that don't require $) are... undeniable. But not every package you install will behave exactly as advertised. And, unless you're experienced, it's not optimal to face 10 choices when trying to accomplish a computationally uncomplicated task.

### Related: Simplicity considerations

STATA: If you type a command, it can only mean one thing; if you are familiar with a particular function, you know exactly what will happen.

R: You will only execute the command you think are executing if you are careful about how you load packages. Names of functions from different packages sometimes overlap. You'll experience puzzling malfunctions that you will be able to "solve" by calling the SAME packages written by the R community but calling them in a DIFFERENT ORDER.

And as Shiro Kuriwaki says, you will want to debug your code, and you if you read in too many packages, you'll waste more time tracking down the source of the problem. Check out Shiro's [warnings about function masking](https://vimeo.com/399959368).

A less serious issue is that you have the freedom to choose from many functions in R that seem to do the same things, but they work differently in certain cases. Should you use `subset()` or `dplyr::filter()` when you want to use a particular subgroup of observations for analysis? There are only small differences (e.g. one of them does not preserve row names and could be ok) but the problem could be that you are often left in the dark about the "choices" that you are unintentionally making when writing your code.


### Reading and understanding other people's code

STATA: Every command has, or should have, a unique meaning. 95-98% of the time, you will be fine. That said, some functions do become obsolete, and if the code you are reading was written by someone with a newer version of Stata, there could be parts of the code that you won't be able to run.

R: There are many ways to accomplish the same objective with R. This choice proliferation is not always a blessing. For example:

  - Readings someone else's code, you may not always catch what exactly people are using (a tibble? a data.frame? a model.matrix object?) when they are estimating their models. 
  - You will see a lot of generic functions: people will write `predict()` and feed into it a LASSO model or an RF model, so what's really being activated under the hood would be `predict.glmnet()` or `predict.ranger()` and they allow, or expect, different things. So if you think you know what arguments are expected or allowed inside a common function like `predict()`, you will be disappointed.

### Building and recoding datasets

STATA: Recoding variables may be more intuitive.

R: Will not always be quite as friendly - you have to type more, categorical variables ("factors") will not always behave as expected, and you'll waste time checking whether a variable is of the correct/expected type.

But don't let that discourage you, things are getting more amiable, with functions like `case_when()`.

Merging news variables into existing cases can be faster in R, where you can work with multiple datasets in memory simultaneously. This means you don't need to start with a single "master file" and joining new datasets *one by one* in the process of building your final dataset.

Counterpoint: In version 16 of STATA you actually can keep [several datasets in memory at the same time](https://www.stata.com/new-in-stata/multiple-datasets-in-memory/). That's great but it looks like there is always one active "frame" and you need to switch between them. Not optimal for multitasking. 


### Reshaping datasets (converting from wide to long and the other way)

Until recently, I preferred STATA's `reshape` command to R's `gather()` and `spread()`. Now, R is becoming extremely friendly on this front with `pivot_longer()` and `pivot_wider()`. Our descendants may never know what we struggled with in the old days...


### Speed of data exploration

STATA: Assuming your data is labeled, the data exploration phase will be a walk in the park,
and exporting models into tables and coefficients plots should go smoothly.

R: It's fine. But you will probably spend time manually adding text to charts and tables.

-----

Possibly my **favorite attribute of STATA**: If there is a problem with the program, it will stop.

### Data visualization considerations

R: Your code may finish running even if there is a ruinous mistake.

STATA & R graphics: Both will produce effective and -- if you want! -- aesthetic plots.
	- In STATA, you must change some defaults setting.
	- But just one line of code can yield a decent chart.
	- In R, it will take more lines of code to prepare a clear chart.
	- R gives you more freedom but the number of steps (again, lines of code) to get to the finish line may frustrate you.
	- You can make interactive plots in R (but it doesn't mean you should).

Minor things: 

- Importing data directly into R or STATA; STATA has some useful options: the The St. Louis Federal Reserve data can be [downloaded easily](https://www.stata.com/stata15/import-fred/). Same for the World Bank macro data; just run ssc install wbopendata and db wbopendata. You can use various APIs to download data directly into your RStudio session as well.
- For writing functions, the R environment makes a lot more sense to me.



