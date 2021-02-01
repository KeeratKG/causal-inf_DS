## Regression Discontinuity

```{r}
# function to simulate data set
dat<-sim.reg.discontinuity.df()

# explore data
colnames(dat)

head(dat)
```
<!-- ### Console Output: -->

<!-- > colnames(dat)
[1] "Lead.Score"     "Add.Support"    "Counterfactual" "Customer.Spend"
> head(dat)
  Lead.Score Add.Support Counterfactual Customer.Spend
1          0       FALSE       0.000000       0.000000
2          1       FALSE       1.826155       1.826155
3          2       FALSE       3.478371       3.478371
4          3       FALSE       7.910210       7.910210
5          4       FALSE      11.649041      11.649041
6          5       FALSE       6.221730       6.221730 -->


```{r}
# regression discontinuity plot
dat %>%
  ggplot(aes(Lead.Score,Customer.Spend,color=Add.Support)) +
  geom_line(lwd=2) +
  geom_line(aes(Lead.Score,Counterfactual),lty=2,lwd=2) +
  geom_vline(xintercept=dat$Lead.Score[sum(!dat$Add.Support)],
             lty=2,lwd=2) +
  xlab("Lead Score") +
  ylab("Customer Spend") +
  theme_economist() +
  scale_color_economist() +
  theme(legend.position="none")
```
![alt text](https://github.com/KeeratKG/causal-inf_DS/blob/main/media/reg-disc.png)

```{r warning=F}
# fit regression discontinuity model
model1<-lm(Customer.Spend~Lead.Score+I(Lead.Score>=70)+Lead.Score:I(Lead.Score>=70),data=dat)
```

```{r}
# view regression discontinuity model
stargazer(model1,type="text",style="aer",
          column.labels=c("Y~X+I(X>Cutoff)+X*I(X>Cutoff)"),
          dep.var.labels="Regression Discontinuity",
          omit.stat=c("f","ser","rsq","n","adj.rsq"),
          intercept.bottom=F)

# causal impact is difference in regression lines at cutoff
# I(X>Cutoff)+X*I(X>Cutoff)
coef(model1)["I(Lead.Score >= 70)TRUE"]+coef(model1)["Lead.Score:I(Lead.Score >= 70)TRUE"]*70
```
<!-- ### Console Output

======================================================================
                                       Regression Discontinuity
                                    Y~X+I(X>Cutoff)+X*I(X>Cutoff)
----------------------------------------------------------------------
Constant                                        -5.796
                                               (6.947)

Lead.Score                                     2.164***
                                               (0.174)

I(Lead.Score > = 70)                            20.101
                                               (50.892)

Lead.Score:I(Lead.Score > = 70)                2.075***
                                               (0.615)

----------------------------------------------------------------------
Notes:                          ***Significant at the 1 percent level.
                                **Significant at the 5 percent level.
                                *Significant at the 10 percent level.
>
> # causal impact is difference in regression lines at cutoff
> # I(X>Cutoff)+X*I(X>Cutoff)
> coef(model1)["I(Lead.Score >= 70)TRUE"]+coef(model1)["Lead.Score:I(Lead.Score >= 70)TRUE"]*70
I(Lead.Score >= 70)TRUE
               165.3832 -->
