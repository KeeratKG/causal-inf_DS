
## Causal Forests

```{r}
# function to simulate data set
dat<-sim.causal.forest.df()

# explore data
colnames(dat)

head(dat)

table(dat$Registration.Source)
```
<!-- ### Console Output
> colnames(dat)
[1] "Revenue"             "Discount"            "V1"
[4] "V2"                  "V3"                  "V4"
[7] "V5"                  "Registration.Source"
>
> head(dat)
   Revenue Discount           V1         V2          V3        V4
1 109.1013        1  0.112100944 -0.2049514 -0.81778206 -3.592924
2 280.5117        1 -0.013645044 -0.2605280 -0.06280238  2.713362
3 235.9486        0  0.198912092  0.3900383  0.31194688  1.657563
4 137.2165        1  0.507709194 -0.2576882 -0.70324049 -1.799299
5 260.6181        0  0.002866622 -0.2406002  0.50813194  2.005809
6 251.2608        0  0.145977819  0.7017203  0.17977447  2.017560
          V5 Registration.Source
1 -0.4186616              Google
2  3.5139394              Google
3 -1.5738921              Google
4 -1.6086386              Google
5  2.0577278              Google
6 -1.1039182              Google
>
> table(dat$Registration.Source)

   Google Instagram   Twitter      Bing
     1250      1250      1250      1250
 -->

```{r warning=F}
# regular OLS
model1<-lm(Revenue~.,data=dat[,-which(colnames(dat)=="Registration.Source")])

# OLS with interactions for heterogeneous treatments by source
model2<-lm(Revenue~.+Discount*Registration.Source,data=dat)
```

```{r}
# compare OLS models
stargazer(model1,model2,type="text",style="aer",
          column.labels=c("All Controls",
                          "All Controls + Group Interactions"),
          dep.var.labels=c("","",""),
          covariate.labels=c("Discount",
                             "Discount x Instagram",
                             "Discount x Twitter",
                             "Discount x Bing"),
          omit=c("V","Constant","^Registration.Source"),
          model.names=F,omit.stat=c("ser","rsq","n","adj.rsq"))
```

<!-- ### Console Output
===================================================================================

                             All Controls          All Controls + Group Interactions
                                  (1)                             (2)
------------------------------------------------------------------------------------
Discount                       12.464***                       5.067***
                                (0.114)                         (0.056)

Discount x Instagram                                           4.956***
                                                                (0.079)

Discount x Twitter                                             9.849***
                                                                (0.079)

Discount x Bing                                                14.901***
                                                                (0.079)

F Statistic          262,819.300*** (df = 6; 4993) 2,227,470.000*** (df = 12; 4987)
------------------------------------------------------------------------------------
Notes:               ***Significant at the 1 percent level.
                     **Significant at the 5 percent level.
                     *Significant at the 10 percent level.  -->

```{r warning=F}
# fit causal forest
X<-model.matrix(~.,data=dat[,-which(colnames(dat)%in%c("Revenue","Discount"))])
cf<-causal_forest(X=X,Y=dat$Revenue,W=dat$Discount)
```

```{r}
# obtain causal forest model predictions
pred<-predict(cf)$predictions

# view average causal forest model predictions by source
# is estimate of heterogeneous treatment effect
tapply(pred,dat$Registration.Source,mean)

# extract variable importance from causal forest model
cf %>%
  variable_importance() %>%
  as.data.frame() %>%
  mutate(variable=colnames(X)) %>%
  arrange(desc(V1))

# plot distribution of causal forest model predictions by sources
data.frame("est"=pred,"Registration.Source"=dat$Registration.Source) %>%
  ggplot(aes(Registration.Source,pred,fill=Registration.Source)) +
  geom_boxplot() +
  xlab("Registration Source") +
  ylab("Estimated Treatment") +
  theme_economist() +
  scale_fill_economist() +
  theme(legend.position="none")
```
<!--
### Console Output

# obtain causal forest model predictions
> pred<-predict(cf)$predictions
>
> # view average causal forest model predictions by source
> # is estimate of heterogeneous treatment effect
> tapply(pred,dat$Registration.Source,mean)
   Google Instagram   Twitter      Bing
 4.646049 10.723606 14.849190 20.122578
>
> # extract variable importance from causal forest model
> cf %>%
+   variable_importance() %>%
+   as.data.frame() %>%
+   mutate(variable=colnames(X)) %>%
+   arrange(desc(V1))
          V1                     variable
1 0.62497169      Registration.SourceBing
2 0.08991590   Registration.SourceTwitter
3 0.06408752                           V3
4 0.06368068                           V5
5 0.06128813                           V2
6 0.04311481                           V4
7 0.02663632 Registration.SourceInstagram
8 0.02630495                           V1
9 0.00000000                  (Intercept)
>
> # plot distribution of causal forest model predictions by sources
> data.frame("est"=pred,"Registration.Source"=dat$Registration.Source) %>%
+   ggplot(aes(Registration.Source,pred,fill=Registration.Source)) +
+   geom_boxplot() +
+   xlab("Registration Source") +
+   ylab("Estimated Treatment") +
+   theme_economist() +
+   scale_fill_economist() +
+   theme(legend.position="none") -->

![alt text](https://github.com/KeeratKG/causal-inf_DS/blob/main/media/causaML.png)
