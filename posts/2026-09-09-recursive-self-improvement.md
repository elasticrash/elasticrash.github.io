---
title: what is recursive self-improvement? 
date: 09/09/2026
description: yet another ai hype calls recursive self-improvement
tags: AI
---

The new trend in recent months in the space of AI is recursive self-improvement. The idea is for an AI system to use its own output and reasoning in order to train and upgrade itself, without relying on external data.

But the reality is that a model, and thus a model's [parameters](https://en.wikipedia.org/wiki/Parameter#Artificial_intelligence), are basically frozen. Parameters are the numbers set during training, and once a model ships they never change again. So when a lab is referring to recursive self-improvement, what they usually mean is using one model to train another. Which makes me wonder how that differs from the well-known technique referred to as [distillation](https://en.wikipedia.org/wiki/Knowledge_distillation), which can be simply explained as one model generating data and the other training on it. Nothing self-improves. It's a type of knowledge transfer with a human in the loop. In some cases, some people, more honestly, are using the term self-improvement to mean improving the model's current context, which is nothing really innovative or interesting. It makes a session better, not the entire model, which is where lots of the noticeable improvements come from. Let's not forget that current AI is just a sampling from a predefined distribution. It can occasionally piece things together but cannot generate new knowledge. 

There is one thing that would qualify as self-improvement, and that is online continuous learning. So far, that technique results in catastrophic outcomes, and in record times, if I might say so. It's not hard for a small number of users to manipulate and guide the model to act outside of its limitations, guardrails and context. One of the best examples was Microsoft's [Tay](https://www.bbc.co.uk/news/technology-35902104). It was a complete disaster, ending with Microsoft apologising. Which is, I believe, a reason why all the models nowadays have frozen parameters.

In reality, if they figured out how to allow models to do continuous online learning, it would lower the cost of continuously training new models to keep them up to date. But for such a thing to work, the model would need to know and understand what is good and bad data. So the prize is real, it's just not the one being advertised. The term self-improvement is a blatant lie.

Models cannot get new data in any magic way. They are stuck at the moment their training ends. I am sure a lot of people remember the answer that ChatGPT used to repeat: "my knowledge is limited until {date}". In order to get around that problem, the models started using harnesses and tools, one of them being Retrieval-Augmented Generation (RAG), which can be translated to: searching for the information online and adding it into the session's context.

What they are trying to convince the public of is that they will reach a moment in time when they will have a system similar to [Deep Thought](https://hitchhikers.fandom.com/wiki/Deep_Thought), from Douglas Adams' The Hitchhiker's Guide to the Galaxy, which might not be capable of asking the question of life, but is capable of building another AI that would be able to do that. Obviously Adams meant this as a joke, as the more capable AI that Deep Thought created was basically life itself.

But in reality a system building a more capable system is just nonsense. It might successfully improve the new model in a similar way to evolution, by trial and error, but it cannot generate new knowledge that will make the new model smarter, because if it could, it would already be what it is trying to build.
