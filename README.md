# World models

TODO: Paper link.

### What kind of code repository is this?
This repo is an archival collection of code files that were used to produce the examples in our paper. For now, this code is intended to be run manually in the playground settings described below. However, as next steps, we believe our framework naturally suggests many kinds of concrete implementations that function end-to-end as natural dialogue systems capable of complex, probabilistic reasoning.

# Framework overview

- **Meaning function** <img src="assets/nn_icon.png" width=20px>: Translates from natural language to code expressions.
- **Inference function** <img src="assets/cogs_icon.png" width=20px>: Runs probabilistic inference over possible worlds described by a generative model.

## Experimenting with a meaning function

For the examples we present in our paper, we use OpenAI's Codex model to play the role of the meaning function. Everywhere that a <img src="assets/nn_icon.png" width=20px> symbol appears indicates a translation produced by Codex. To reproduce these translations, you can use the [OpenAI Playground](https://platform.openai.com/playground) (account required to access). For each domain, the `prompt.scm` file contains the text that was used for prompting.

## Experimenting with an inference function

In our paper, we used a probabilistic programming languguage called [Church](https://v1.probmods.org) to play the role of the inference function. Everywhere that a <img src="assets/cogs_icon.png" width=20px> symbol appears indicates a  computation that was performed with Church's probabilistic inference engine. TO reproduce these inferences, you can use the [Church Play Space](https://v1.probmods.org/play-space.html). For each domain, the `world-model.scm` file contains generative model in Church that can be pasted directly into the editor.

# Domains

![fig-splash-v2](https://github.com/gabegrand/world-models/assets/10052880/71d30fc4-d728-4016-8b33-9851b13d0c77)

## Probabilistic reasoning

As an introductory example, we consider the Bayesian Tug-of-War (Gerstenberg & Goodman, 2012; Goodman et al., 2014). We start with a generative model of a tournament in which players of varying strengths compete in a series of matches as part of fluid teams. Each player has a latent strength value randomly sampled from a Gaussian distribution (with parameters arbitrarily chosen as μ = 50 and σ = 20). As an observer, our goal is to infer the latent strength of each individual based on their win/loss record. However, players sometimes don’t pull at their full strength and each player has a different intrinsic “laziness” value (uniformly sampled from the interval [0, 1]) that describes how likely they are to be lethargic in a given match.

As a simple example, suppose we observe two matches. In the first match, Tom won against John. In the second match, John and Mary won against Tom and Sue. We can encode both of these observations as the following Church conditioning statement.

```
(condition
  (and
    ;; Condition: Tom won against John.
    (won-against '(tom) '(john))
    ;; Condition: John and Mary won against Tom and Sue.
    (won-against '(john mary) '(tom sue))))
```

Based on the fact that Tom won against John, we might expect Tom to be stronger than John. Therefore, the fact that John and Mary won against Tom and Sue suggests that Mary's strength is above average. We can replicate this probabilistic inference with the following Church query:

```
;; Query: How strong is Mary?
(strength 'mary)
```

<img width="600px" alt="mary-strength" src="https://github.com/gabegrand/world-models/assets/10052880/73cd736e-959c-4d20-a58d-0aabaef221e3">

This is just a simple example of the kinds of probabilistic inferences we can make in the Bayesian tug-of-war. In our paper, we consider more complex observations (e.g., "Josh has a propensity to slack off") and inferences (e.g., "Is Gabe stronger than the weakest player on the faculty team?"), before scaling up to new domains of reasoning.

## Relational reasoning

TODO

## Grounded visual reasoning

TODO

## Goal-directed reasoning

TODO
