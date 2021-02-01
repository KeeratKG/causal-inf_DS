## Double Selection

```{r warning=F}
# function to simulate data set
dat<-sim.double.selection.df()

# explore data
dim(dat)

colnames(dat[,1:10])

head(dat[,1:10])
```
<!-- ### Console Output
> dim(dat)
[1] 1000  502
>
> colnames(dat[,1:10])
 [1] "Customer.Value"       "Social.Proof.Variant" "V1"
 [4] "V2"                   "V3"                   "V4"
 [7] "V5"                   "V6"                   "V7"
[10] "V8"
>
> head(dat[,1:10])
  Customer.Value Social.Proof.Variant        V1        V2        V3
1       188.8085                    0 0.7801386 0.9979248 1.0060368
2       205.2293                    1 1.3050949 1.0993128 1.0921122
3       185.0398                    1 0.8713593 0.9948969 1.0308502
4       208.5822                    1 1.1735680 1.0268785 1.0207358
5       177.9362                    0 0.8097054 0.9755838 0.9733450
6       196.8597                    0 1.0894712 0.9917257 0.9704784
         V4        V5        V6        V7        V8
1 1.1110303 0.9908170 1.1508037 1.0011042 0.9894936
2 1.1350519 1.1547349 0.8173114 0.9985152 0.9442994
3 0.9978511 1.0079737 1.0459495 0.9819702 0.9398430
4 1.2286516 1.0950800 1.0069691 1.0103734 1.0905426
5 1.0800108 0.8139979 1.0386658 0.9961244 1.0106004
6 1.0123684 1.1001662 1.1782101 0.9990303 1.0360617 -->


```{r warning=F}
# fit double selection model

# isolate control variables
C<-dat[,-which(colnames(dat)%in%c("Customer.Value","Social.Proof.Variant"))]
C<-as.matrix(C)

# fit lasso regressing outcome on control variables
y.glmnet.model<-cv.glmnet(C,dat$Customer.Value)

# extract nonzero coefficients from lasso above
# use lambda min CV within 1 se (select less coeff)
predict(y.glmnet.model,s="lambda.1se",type="nonzero")
nonzero<-unlist(predict(y.glmnet.model,s="lambda.1se",type="nonzero"))
Y.on.C<-colnames(C)[nonzero]
Y.on.C

# fit lasso regressing treatment on control variables
x.glmnet.model<-cv.glmnet(C,dat$Social.Proof.Variant)

# extract nonzero coefficients from lasso above
# use lambda min CV within 1 se (select less coeff)
predict(x.glmnet.model,s="lambda.1se",type="nonzero")
nonzero<-unlist(predict(x.glmnet.model,s="lambda.1se",type="nonzero"))
X.on.C<-colnames(C)[nonzero]
X.on.C

# combine two sets of nonzero coefficients to get unique nonzero
# coefficients across models
var.union<-unique(c(Y.on.C,X.on.C))

# count number of nonzero variables
length(var.union)
var.union

# use all nonzero coefficients + treatment indicator
# in double selection regression
double.selection<-lm(Customer.Value~.,dat[,c("Customer.Value","Social.Proof.Variant",var.union)])
```

<!--
### Console Output

> # isolate control variables
> C<-dat[,-which(colnames(dat)%in%c("Customer.Value","Social.Proof.Variant"))]
> C<-as.matrix(C)
>
> # fit lasso regressing outcome on control variables
> y.glmnet.model<-cv.glmnet(C,dat$Customer.Value)
>
> # extract nonzero coefficients from lasso above
> # use lambda min CV within 1 se (select less coeff)
> predict(y.glmnet.model,s="lambda.1se",type="nonzero")
  X1
1  1
2  2
3  3
4  4
5  5
6  6
7  7
8  8
9  9
> nonzero<-unlist(predict(y.glmnet.model,s="lambda.1se",type="nonzero"))
> Y.on.C<-colnames(C)[nonzero]
> Y.on.C
[1] "V1" "V2" "V3" "V4" "V5" "V6" "V7" "V8" "V9"
>
> # fit lasso regressing treatment on control variables
> x.glmnet.model<-cv.glmnet(C,dat$Social.Proof.Variant)
>
> # extract nonzero coefficients from lasso above
> # use lambda min CV within 1 se (select less coeff)
> predict(x.glmnet.model,s="lambda.1se",type="nonzero")
$`1`
NULL

> nonzero<-unlist(predict(x.glmnet.model,s="lambda.1se",type="nonzero"))
> X.on.C<-colnames(C)[nonzero]
> X.on.C
character(0)
>
> # combine two sets of nonzero coefficients to get unique nonzero
> # coefficients across models
> var.union<-unique(c(Y.on.C,X.on.C))
>
> # count number of nonzero variables
> length(var.union)
[1] 9
> var.union
[1] "V1" "V2" "V3" "V4" "V5" "V6" "V7" "V8" "V9"
>
> # use all nonzero coefficients + treatment indicator
> # in double selection regression
> double.selection<-lm(Customer.Value~.,dat[,c("Customer.Value","Social.Proof.Variant",var.union)]) -->

```{r}
# compare naive model, full model, and double selection

# naive regression
naive.regression<-lm(Customer.Value~Social.Proof.Variant,data=dat)

# regression with full controls
full.model<-lm(Customer.Value~.,data=dat)
```

```{r}
# compare all models
stargazer(naive.regression,full.model,double.selection,type="text",style="aer",
          column.labels=c("No Controls","All Controls",
                          "Double Selection"),
          dep.var.labels=c(""),
          covariate.labels=c("Social.Proof.Variant"),
          omit=c("V[0-9]","Constant"),
          model.names=F,omit.stat=c("ser","rsq","n","adj.rsq","F"),
          notes=c("Causal Impact = 2"))
```

<!-- ### Console Output

==============================================================

                     No Controls All Controls Double Selection
                         (1)         (2)            (3)
--------------------------------------------------------------
Social.Proof.Variant  2.966***     1.978***       2.009***
                       (0.657)     (0.086)        (0.062)

--------------------------------------------------------------
Notes:               ***Significant at the 1 percent level.
                     **Significant at the 5 percent level.
                     *Significant at the 10 percent level.
                     Causal Impact = 2   -->
