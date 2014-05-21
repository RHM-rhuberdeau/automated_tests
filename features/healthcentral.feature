Feature: healthcentral should work properly

Scenario: I visit healthcentral
  Given I visit "http://qa.healthcentral.choicemedia.com"
  Then I should see "Stories That Inspire Us" in "h1"
@iphone
Scenario: A mobile user visits health central
  Given I visit "http://qa.healthcentral.choicemedia.com"
  Then I should see "Stories That Inspire Us" in "h1"