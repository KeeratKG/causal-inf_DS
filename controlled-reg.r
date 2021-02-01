## Controlled / Fixed Effects Regression

```{r}
# function to simulate data set
dat<-sim.fixed.effects.df()

# explore data
colnames(dat)

head(dat)
```

```{r}
# customer Spend vs. satisfaction
g1<-dat %>%
  ggplot(aes(Customer.Rating,Customer.Spend,fill="A")) +
  geom_point() +
  theme_economist() +
  scale_fill_economist()

g1
cor(dat$Customer.Rating,dat$Customer.Spend)
```

```{r}
# customer Spend vs. time
g2<-dat %>%
  ggplot(aes(Time.FE,Customer.Spend,fill="A")) +
  geom_boxplot() +
  theme_economist() +
  scale_fill_economist() +
  theme(legend.position="none",axis.text.x=element_text(angle=45,
                                                        vjust=0.5))

# customer spend vs. product
g3<-dat %>%
  ggplot(aes(Product.FE,Customer.Spend,fill="A")) +
  geom_boxplot() +
  theme_economist() +
  scale_fill_economist() +
  theme(legend.position="none",axis.text.x=element_text(angle=45,
                                                        vjust=0.5))

# Customer spend vs. customer Age
g4<-dat %>%
  ggplot(aes(Customer.Age,Customer.Spend,fill="A")) +
  geom_point() +
  theme_economist() +
  scale_fill_economist() +
  theme(legend.position="none")

# Customer spend vs. total purchases
g5<-dat %>%
  ggplot(aes(Total.Purchases,Customer.Spend,fill="A")) +
  geom_point() +
  theme_economist() +
  scale_fill_economist() +
  theme(legend.position="none")

# combind all plots
grid.arrange(g2,g3,g4,g5,nrow=2)

# observe differences across time & products & customer age
# need to include in regression to control for their effects
```

```{r warning=F}
# compare controlled reg/fixed effect models

# naive regression; no controls
model1<-lm(Customer.Spend~Customer.Rating,data=dat)

# control for customer age only
model2<-lm(Customer.Spend~Customer.Rating+Customer.Age,data=dat)

# control for product and time fixed effects only
model3<-lm(Customer.Spend~Customer.Rating+Product.FE+Time.FE,data=dat)

# full controls; and included variable bias of total purchases
model4<-lm(Customer.Spend~Customer.Rating+Customer.Age+Product.FE+Time.FE+Total.Purchases,data=dat)

# full controls; no included variable bias
model5<-lm(Customer.Spend~Customer.Rating+Customer.Age+Product.FE+Time.FE,data=dat)
```

```{r}
# see here for more info on stargazer:
# (1) https://cran.r-project.org/web/packages/stargazer/vignettes/stargazer.pdf
# (2) https://www.jakeruss.com/cheatsheets/stargazer/

# view coefficient of interest in each regression model
stargazer(model1,model2,model3,model4,model5,type="text",
          style="aer",omit=c("Constant","Customer.Age",
                             "Product.FE","Time.FE",
                             "Total.Purchases"),
          column.labels=c("Y~X","Y~X+C","Y~X+FE","Y~X+C+FE+IVB",
                          "Y~X+C+FE"),
          dep.var.labels="Controlled / Fixed Effects Regression",
          omit.stat=c("f","ser","rsq","n"),
          notes=c("True Coef on X = 2"),
          add.lines=list(c("Add. Controls","No","Yes","No",
                           "Yes","Yes"),
                         c("Fixed effects","No","No","Yes",
                           "Yes","Yes"),
                         c("Included Variable Bias","No","No","No",
                           "Yes","No")))
```
### Console Output

<!-- =======================================================================
                            Controlled / Fixed Effects Regression
                         Y~X     Y~X+C    Y~X+FE  Y~X+C+FE+IVB Y~X+C+FE
                         (1)      (2)     (3)        (4)        (5)
-----------------------------------------------------------------------
Customer.Rating        4.934*** 3.367*** 3.545***   2.451***   1.994***
                       (0.991)  (0.701)  (0.698)    (0.620)    (0.011)

Add. Controls             No      Yes       No        Yes        Yes
Fixed effects             No       No      Yes        Yes        Yes
Included Variable Bias    No       No       No        Yes         No
Adjusted R2             0.002    0.501    0.506      1.000      1.000
-----------------------------------------------------------------------
Notes:                 ***Significant at the 1 percent level.
                       **Significant at the 5 percent level.
                       *Significant at the 10 percent level.
                       True Coef on X = 2

------------------------------------------------------------------------ -->
