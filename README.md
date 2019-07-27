# Market Basket Analysis

## Overview
The board of directors at Blackwell Electronics is considering acquiring Electronidex, a start-up electronics online retailer. We are tasked with helping them better understand Electronidex’s clientele and if we should acquire them or not. Main objective is to identify the purchasing patterns of Electronidex’s clientele and discovering any interesting relationships (or associations) between customer’s transactions and the item(s) they’ve purchased.

## What is Market Basket Analysis?
Market Basket Analysis is a modelling technique based upon the theory that if you buy a certain group of items, you are more (or less) likely to buy another group of items. For example, if you are in an English pub and you buy a pint of beer and don’t buy a bar meal, you are more likely to buy crisps (US. chips) at the same time than somebody who didn’t buy beer. The set of items a customer buys is referred to as an itemset, and market basket analysis seeks to find relationships between purchases. Typically the relationship will be in the form of a rule:

> _IF {beer, no bar meal} THEN {crisps}_

The probability that a customer will buy beer without a bar meal (i.e. that the antecedent is true) is referred to as the support for the rule. The conditional probability that a customer will purchase crisps is referred to as the confidence.

_[Visit my RPubs for the full report on this task](https://rpubs.com/kaisk/491535)_
