# Politicus

Personalized political news feed. Built using Flutter and can be compiled into both Android and iOS apps.

## Features:
* News Feed
  * Modules: Polical news feed consists of modules that include relevant news articles, congressional bills, and congressional tweets.
  * Categorization: Naive Bayes classifier used to categorize tweets and bills into modules and order them in the feed based on user preference.
  * Chips: Chips (https://material.io/components/chips/#choice-chips) for manually selecting topics.
  * Liking: Instagram-esque liking functionality (double tap to like/unlike). Liked items are saved locally and can be viewed later. Saved items are processed for user analytics (i.e. political typology and stances on specific issues).
  
  * ![alt text](https://i.imgur.com/g9hOMZY.png)
* Election Tracker
  * Polls: Scrapes the web for polling data and displays the results.
  * News: Displays latest news on the current election
  * Liking: Also supports liking functionality
  * Browser: Opens in-app browser for article viewing. This enables users to view the full article along with pictures.
  ![alt text](https://i.imgur.com/kaU1cu6.png)

* Personal Analytics 
  * Quiz: Includes a political typology quiz the first time the app is opened to set an estimate on the user's political beliefs.
  * Political Spectrum Graph: Plots the user's political side based off of data from quiz and liked items
  * Item/topic analysis: Includes plots to indicate what percentage of items in a certain topic are republican and democratic. This is intended to unveil the political stances of the user for specific subjects.
  ![alt text](https://i.imgur.com/Iv9kJbl.png)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
