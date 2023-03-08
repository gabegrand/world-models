# World models

TODO: Paper link.

# Framework overview

- **Meaning function** <img src="assets/nn_icon.png" width=20px>: Translates from natural language to code expressions.
- **Inference function** <img src="assets/cogs_icon.png" width=20px>: Runs probabilistic inference over possible worlds described by a generative model.

## Experimenting with a meaning function

For the examples we present in our paper, we use OpenAI's Codex model to play the role of the meaning function. Everywhere that a <img src="assets/nn_icon.png" width=20px> symbol appears indicates a translation produced by Codex. To reproduce these translations, you can use the [OpenAI Playground](https://platform.openai.com/playground) (account required to access). For each domain, the `prompt.scm` file contains the text that was used for prompting.

## Experimenting with an inference function

In our paper, we used a probabilistic programming languguage called [Church](https://v1.probmods.org) to play the role of the inference function. Everywhere that a <img src="assets/cogs_icon.png" width=20px> symbol appears indicates a  computation that was performed with Church's probabilistic inference engine. TO reproduce these inferences, you can use the [Church Play Space](https://v1.probmods.org/play-space.html). For each domain, the `world-model.scm` file contains generative model in Church that can be pasted directly into the editor.

# Domains

## Probabilistic reasoning

TODO

## Relational reasoning

TODO

## Grounded visual reasoning

TODO

## Goal-directed reasoning

TODO