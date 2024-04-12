# Deploying an R Shiny Dashboard App through R Shinylive

This repository demonstrates how to deploy an R Shiny Dashboard app built with [`{bslib}`](https://rstudio.github.io/bslib/articles/dashboards/index.html) using GitHub Actions and GitHub Pages.

This is a follow-up to [Deploying an R Shinylive App via GitHub Pages through GitHub Actions](https://github.com/coatless-tutorials/convert-shiny-app-r-shinylive) guide.

## Background

This tutorial originated due to a question asked by [Giandomenico Bisaccia
](https://github.com/bisacciamd). He asked it over on [StackOverflow](https://stackoverflow.com/questions/78073680/a-way-for-shinylive-integration-for-serverless-quarto-r-dashboard?sem=2), via e-mail, and, then, via tutorial repo on [using quarto with Shinylive for R](https://github.com/coatless-quarto/r-shinylive-demo/issues/11).

We're using [earthquake dashboard](https://colorado.posit.co/rsc/nz-quakes/quakes.html) ([source](https://github.com/cwickham/quakes/blob/main/quakes.qmd)) from the Quarto Team's [R Dashboard Gallery](https://quarto.org/docs/dashboards/examples/#r).
