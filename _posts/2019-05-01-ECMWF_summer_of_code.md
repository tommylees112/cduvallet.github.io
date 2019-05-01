---
layout: single
title:  "ECMWF Summer of Weather Code Competition 2019"
# header:
#   teaser: "unsplash-gallery-image-2-th.jpg"
categories:
  - news
tags:
  - ESoWC
permalink: /posts/2019/1/esowc_kick_off
date: 2019-05-02
---

# Great news!

My friend, Gabriel Tseng, and I recently won a competition to apply machine learning to predicting drought in East Africa! We will be working on this project through until September as part of the [ECMWF Summer of Weather Code Competition](https://www.ecmwf.int/en/learning/workshops/ecmwf-summer-weather-code-2019)!

# How did we get here?

Recently I began working with a friend [Gabriel Tseng](https://gabrieltseng.github.io/) to apply machine learning technologies to hydrological and climate science, with a focus on East African Droughts.

Gabi is currently working as a Machine Learning Engineer at [Drop](https://www.earnwithdrop.com/).

### Predicting Vegetation Health
With this in mind we set out to build a simple pipeline to predict vegetation health ahead of time from the meteorological conditions in previous time steps. This makes sense right? The weather in month 1, month 2 and month 3 should have an impact on how healthy plants and trees are in month 4. This ongoing project can be found [here](https://github.com/tommylees112/vegetation_health).

What is awesome is our complementary skill set! Gabi is an absolute coding legend with expertise and experience in building data processing pipelines and applying machine learning algorithms. I come with an understanding of climate datasets and drought processes. Although I think my major contribution is just being overly excited about everything that's going on.

# ECMWF Summer of Weather Code
> The Summer of Weather Code(ESoWC) programme by the European Centre for Medium-Range Weather Forecasts (ECMWF) is a collabrative online programme to promote the development of weather-related open-source software. [Ref](https://github.com/esowc/challenges_2019)

<!-- ![ESoWC](ESoWC.jpg) -->

While playing with this problem we came across the ECMWF [**Summer of Weather Code**](https://www.ecmwf.int/en/learning/workshops/ecmwf-summer-weather-code-2019) Competition. [ECMWF](https://www.ecmwf.int/), the European Centre for Medium Range Weather Forecasting, are global leaders in monthly, seasonal and medium-range weather forecasting and they are both a research institute and an operational weather forecasting service.

ECMWF had [12 challenges](https://github.com/esowc/challenges_2019) for teams to contribute to. They picked 5 winning teams from all applications across all 12 challenges. **And we got one!**.

We submitted our proposal to Challenge 12 - **Machine learning for predicting extreme weather hazards**.
> Goal: To use ECMWF/Copernicus open datasets to evaluate machine learning (ML) techniques to better predict one specific kind of an extreme weather event, e.g. drought or hurricanes; provide templates for future ML work. [Ref](https://github.com/esowc/challenges_2019/issues/14).

# Our Proposal

Our proposal focused on Drought monitoring/prediction in East Africa. We chose this region & hazard for 3 reasons:
1. There is comparatively less research here compared with the USA or Europe.
2. Drought events have huge human and environmental costs in East Africa. For example, the 2011 Drought impacted over 9 million people and the food security caused by the event is estimated to have caused between 150,000 and 250,000 deaths in Somalia alone!
3. it fits with my PhD and a region I already work in.

### Aim
The overarching aim of our proposal is to build a flexible experimental set up where we can test multiple:
* *definitions of drought*
*  *input datasets*
* *machine learning algorithms*

### Spatio-temporal Relationships
We want to consider both the spatial and temporal relationships in our model, as far as possible, and we have a focus on interpreting what the models are learning.

### Interpretability
A key criticism lobbied against machine learning techniques is that they fail to provide insights into the processes which drive our predictions. They're great at making predictions but do they really help us to understand the system we are studying?

Much of our focus will be to make these models interpretable. One way of doing this is with [SHAP values](https://medium.com/@gabrieltseng/interpreting-complex-models-with-shap-values-1c187db6ec83). Essentially, **the SHAP values tell us how important each feature is and in what direction they push our predictions**. This will be very useful for 2 reasons:
1. By identifying important features we can tell if the predictions are *physically realistic*
2. We can run the models with multiple geographic predictors (think sea surface temperature over the Pacific, over the Atlantic and over the Indian Ocean). This can give us insights into the driving forces of droughts in East Africa and help identify possible teleconnections which we can then go back and test.


# Goals

1. Produce a data-processing pipeline that downloads the ECMWF/Copernicus open datasets, cleans that data and prepares the data ready for analysis and prediction.
2. Implement an experimental set up for testing different algorithms and techniques for predicting drought metrics. We will compare different measures of drought (low rainfall - SPI, low river levels, low water availability - SPEI) and look at how they match up with major events (such as the 2011 Horn of Africa Drought).
3. Use a variety of tools (e.g. [SHAP]()) for interpreting what the model is learning. *Let's open up the black box!*
4. Document, Document, Document! We want to make the steps clear to everyone and so we will be blogging throughout the process and documenting our steps. This will be both code documentation and documentation of the overall approach.
5. Communicating our results. This will be through a series of (more polished) blog posts and a scientific paper.

# The next steps

All of these goals and the proposal itself is now subject to updates as we clearly specify what we are going to do and how we are going to do it. Gabi and I are working on better defining the minimum we need to achieve as well as the nice-to-haves that we can work on if there is time available.

We will be meeting our ECMWF mentors very soon and are incredibly excited to open the discussion and learn more about how we will be working together.

Huge thanks to ECMWF for making this challenge possible and I cannot wait to share what we get up to over the coming weeks.
