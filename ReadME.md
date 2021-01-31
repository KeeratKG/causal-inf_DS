**Background**:
Data Science Questions often fall into a standard format:
- Some outcome metric of interest Y
- Some variable of interest X
- A goal to estimate coefficient of interest/causal impact(estimating impact of changing X on Y)

*Intuition behind causal inference*: To control for all possible confounders and look for natural
sources of variation that can split the data into quasi random groups and mimic the randomization
we would get from AB testing.

**Problem Statement**:
To use causal inference techniques to estimate coefficient of interest/ causal impact. The following 5 techniques are to be used for the same:
* Controlled Regression
* Regression Discontinuity
* Difference in Difference
* Instrumental Variables
* ML+Causal Inference

**Method**
We consider X as the satisfaction rating(1-10) signifying a product's quality and Y as the Usage of the product(till a certain time period).
1. *Controlled Regression*:
Steps:
- Univariate Regression of Y on X
- Multiple Regression of Y on X and a set of controls
If:
1. R squared in second Regression is close to 100% (meaning entire variance of the data has been captured in this regression)
2. coefficient of interest on X is similar in the two models
then by theory of controlled regression, we can use it as the causal impact.  
Sources of error:
1. Omitted Variable Bias: Omitting control variables that matter from the model. Can be detected if R squared is not close to 100% in the regression with controls.
2. Included Variable Bias: opposite of omitted variable bias and involves including too many controls(confounding factors).

2. *Regression Discontinuity*:
Suppose we want to measure the effect of adding subtitles to a course.
- We cannot run AB test due to difficulty in randomly giving some learners access to subtitles given product limitations.
- We cannot do controlled regression due to key unobservables like course popularity leading to omitted variable bias.
- We can run a natural experiment by providing a cut off point of 80% subtitled, only beyond which do we advertise a course to be available in a specific language.

Therefore we run a regression discontinuity with a cutoff point of 80% where:
* Y variable-> Revenue
* X variable-> % of Course subtitled

Idea: To focus on the cut off point that can be thought of as a local randomised experiment. We treat the 2 random groups of data in AB test where:
- Control: prior to cutoff
- Treatment: post cutoff
- Causal Impact: difference in regression lines at cutoff(intercept at 80%)

Assumptions:
* Sample similar above+below cutoff(in terms of other vatiables like samples size/observables/confounding factors, etc)
* No confounding discontinuities(check by running placebo tests- run regression discontinuity at points other than the cutoff and check for no effect)

3. *Difference in Difference*: Suppose we want to measure the effect of lowering price on revenue:
- We cannot run an AB test because customers may complain if only some get lower prices and hear about it.
- We can run a quasi experiment: change price in select geographies but not others and use control markets to compute the counterfactual(what would have happened absent price change in the treatment markets).

Thus we run a Difference in Difference design with control and treatment markets where:
* Y variable: Revenue
* X variable: treatment group in the post period

Idea: similar to a regression discontinuity. We compare the pre and post outcomes between treatment and control groups.

Assumption: Parallel trends-The control group and treatment groups are highly correlated in the pre period(i.e. no difference in their slopes).

Extension: Synthetic Control(creates a synthetic control group that is a weighted average of many control groups).

4. *Instrumental Variable*: Suppose we want to measure the effect of using the mobile app on course completion.
- We can't run AB test because difficult to randomly give some learners access to the mobile app.
- We cannot do controlled regression because key unobservables like learner motivation lead to omitted variable bias.
- We can do a natural experiment where we nudge learners to download the mobile app in a randomised controlled trial. the nudge here will be the instrument that we use to measure the relationship between mobile app usage and course completion.

Thus we run Instrumental variables where:
* Y variable-> Completion, X variable-> Use mobile app
* Z(instrument) variable: Received random nudge

General Problem: Unobserved variable(s) C affect both X and Y; we can't use controlled regression because of omitted variable bias with no proxy variable that can be used as control.
Idea: "Instrument" for X of interest with some feature, Z, that drives Y only through its effect on X-> use to indirectly measure impact of Y on X.

Assumptions:
1. Strong first stage: Z needs to be a strong predictor of our variable of interest X(Regress variable X on intrument Z and check that F statistic is above 11, as a rough rule of thumb. For weak intruments, perform other hypothesis tests.)
2. Exclusion Restriction: Z needs to impact Y only through its impact on X(Randomized encouragement trials are great in companies where one can nudge customers to take actions we care about measuring the impact of. No specific test, only logic).

5. *ML+Causal Inference-Double Selection*:
Weaknesses of classical causal approaches:
- Fail with many covariates
- Model selection unprinciples
- Generally assumes linear relationships and no interactions
Benefits of ML:
+ Can handle high dimensionality
+ Principled ways to choose model
+ Many non-linear models that implicitly use higher order features.

Idea: Use variables or reasonable proxies to isolate causal relationship of variable of interest by controlling other factors(ML version of controlled regression).
We use ML models to control for many potential confounders and/or nonlinear effects. They can be of 2 types:
- Double Selection(Lasso)
- Double Debiased(Generic ML models)

Steps:
1. Have Y and treatment indicator X, high dimensional set of controls C.
2. Split data into 2 sets: Tr, Te*.
3. Fit two Lassos of X~C and Y~C on Tr.
4. Take fitted models and apply to Te.
5. Get all nonzero variables in C and use as controls in controlled regression of Y on X.
*Can generalise this process to K-folds.

Benefits of applying Double Selection on AB Test Data: Increased statistical power gives smaller confidence intervals and decreased time to resolution- good for small samples and effect sizes.

6. *ML+Causal Inference-Causal Trees/Forests*:
Idea: Everything previously assumed homogeneous treatment effects. Causal trees/forests estimates heterogeneous treatment effects where impact differs on observed criteria.
To use trees or forests to identify partition of the space that maximizes observed difference of Y between treatment and control while balancing overfitting.

Steps:
1. Split data into two halves.
2. Fit tree/forest on one half and apply to second half to estimate treatment effects.
3. Heterogeneous treatment Effectsfrom difference in Y in leaf nodes i.e. effect conditioned on C attributes in leaf nodes.
4. Optimisation criteria set up to find best fit given the data splitting.
5. Forest is just average of a bunch of trees with sampling.

Useful in companies to understand how different demographics would result in different causal impacts in response to a particular intervention. 
