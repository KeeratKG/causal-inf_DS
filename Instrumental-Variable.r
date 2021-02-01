## Instrumental Variable

```{r warning=F}
# function to simulate data set
dat<-sim.iv.df()

# explore data
colnames(dat)

head(dat)

#users who use the mobile app have higher motivation; those who retain also have higher retention
#this biases a naive regression
tapply(dat$Unobs.Motivation,dat$Use.Mobile.App,mean)
tapply(dat$Unobs.Motivation,dat$Retention,mean)
```
<!-- ### Console Output
> colnames(dat)
[1] "Received.Email"   "Unobs.Motivation" "Use.Mobile.App"
[4] "Retention"
>
> head(dat)
  Received.Email Unobs.Motivation Use.Mobile.App Retention
1              1       -2.2817595              1         0
2              0        0.7629666              1         1
3              1       -1.2542867              1         0
4              1        0.2890082              1         1
5              0        0.1010221              1         1
6              1        0.1821351              1         1
>
> #users who use the mobile app have higher motivation; those who retain also have higher retention
> #this biases a naive regression
> tapply(dat$Unobs.Motivation,dat$Use.Mobile.App,mean)
         0          1
-0.4132142  0.1435677
> tapply(dat$Unobs.Motivation,dat$Retention,mean)
        0         1
-0.275034  0.177019  -->


```{r warning=F}
# fit IV model

# naive regression
model1<-lm(Retention~Use.Mobile.App,data=dat)

# first stage regression
model2<-lm(Use.Mobile.App~Received.Email,data=dat)

# second stage regression
model3<-lm(Retention~predict(model2),data=dat)

# two stage least squares for IV
model4<-ivreg(Retention~Use.Mobile.App|Received.Email,data=dat)

```

```{r}
# compare all models
stargazer(model1,model2,model3,model4,type="text",style="aer",
          column.labels=c("Y~X","X~Z","Y~Xhat","IV"),
          omit=c("Constant"),
          dep.var.labels=c("Retention","Use.Mobile.App",
                           "Retention","Retention"),
          covariate.labels=c("Use.Mobile.App","Received.Email",
                             "Use.Mobile.App.Hat"),
          model.names=F,omit.stat=c("ser","rsq","n","adj.rsq"),
          intercept.bottom=F)
```
<!-- ### Console Output
====================================================================
                           Retention  Use.Mobile.App    Retention
                              Y~X          X~Z       Y~Xhat    IV
                              (1)          (2)         (3)     (4)
--------------------------------------------------------------------
Use.Mobile.App              0.110***                         0.089**
                            (0.011)                          (0.039)

Received.Email                           0.249***
                                         (0.008)

Use.Mobile.App.Hat                                   0.089**
                                                     (0.039)

F Statistic (df = 1; 9998) 96.132***    902.791***   5.160**
--------------------------------------------------------------------
Notes:                     ***Significant at the 1 percent level.
                           **Significant at the 5 percent level.
                           *Significant at the 10 percent level. -->
