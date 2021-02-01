## Difference in Difference


```{r}
# function to simulate data set
dat<-sim.diff.in.diff.df()

# explore data
colnames(dat)

head(dat)
```
<!-- ### Console Output
> colnames(dat)
[1] "Time"           "Period"         "Country"        "Revenue"
[5] "Counterfactual"
>
> head(dat)
        Time           Period Country   Revenue Counterfactual
1 2018-01-01 Pre.Price.Change      US  67.78704       67.78704
2 2018-02-01 Pre.Price.Change      US  91.30776       91.30776
3 2018-03-01 Pre.Price.Change      US  86.95928       86.95928
4 2018-04-01 Pre.Price.Change      US 131.83683      131.83683
5 2018-05-01 Pre.Price.Change      US 145.61302      145.61302
6 2018-06-01 Pre.Price.Change      US  62.21730       62.21730 -->


```{r}
# difference in difference plot
dat %>%
  ggplot(aes(Time,Revenue,color=Country)) +
  geom_line(lwd=2) +
  geom_line(aes(Time,Counterfactual),lty=2,lwd=2) +
  xlab("Time") +
  ylab("Revenue") +
  theme_economist() +
  scale_color_economist()
```
![alt text](https://github.com/KeeratKG/causal-inf_DS/blob/main/media/dind.png)

```{r warning=F}
# fit difference in difference model
model1<-lm(Revenue~Period+Country+Period:Country,data=dat)

# Note what the estimated revenue from the model is in each scenario:
# Rev in US Pre Price change = Intercept (Period, Country, Interaction all 0)
# Rev in AU Pre Price change = Intercept + Country (Period, Interaction all 0)
# Rev in US Post Price change = Intercept + Period (Country, Interaction all 0)
# Rev in AU Post Price change = Intercept + Period + Country + Interaction
# Diff in Diff = (Rev in AU Post Price change - Rev in AU Pre Price change) - (Rev in US Post Price change - Rev in US Pre Price change)
#              = (Intercept + Period + Country + Interaction - Intercept + Country) - (Intercept + Period - Intercept)
#              = Interaction
```

```{r}
# view difference in difference model
stargazer(model1,type="text",style="aer",
          column.labels=c("Y~Post+G+Post*G"),
          dep.var.labels="Difference in Difference",
          omit.stat=c("f","ser","rsq","n","adj.rsq"),
          notes=c("Causal Impact = 100"),intercept.bottom=F)
```
<!-- ### Console Output
========================================================================
                                         Difference in Difference
                                             Y~Post+G+Post*G
------------------------------------------------------------------------
Constant                                        90.709***
                                                 (8.142)

PeriodPost.Price.Change                         206.614***
                                                 (11.290)

CountryAU                                       104.536***
                                                 (11.514)

PeriodPost.Price.Change:CountryAU               90.155***
                                                 (15.967)

------------------------------------------------------------------------
Notes:                            ***Significant at the 1 percent level.
                                  **Significant at the 5 percent level.
                                  *Significant at the 10 percent level.
                                  Causal Impact = 100   -->
