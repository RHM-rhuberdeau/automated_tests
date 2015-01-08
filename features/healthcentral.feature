Feature: healthcentral should work properly

Scenario: Slideshow content should change on each slide
  Given I visit a slideshow page
  Then I should see a new slide each time I click the next arrow
  And I should see a new slide each time I click the back arrow

Scenario: Ads should refresh each time a new slide is show
  Given I visit a slideshow page
  Then I should see a new ad each time I click the next arrow
  And I should see a new ad each tim I click the previous arrow

Scenario: Healthcentral should use assets from the proper source
  Given I visit healthcentral
  And I browse some pages
  Then I should not see assets from other environments

Scenario: All assets should load correctly
  Given I have a list of pages
  Then I should see all the assets loading as I visit those pages

Scenario: Namspace.js should load
  Given I have a list of pages
  Then I should see the "/sites/all/modules/custom/assets_pipeline/public/js/namespace.js" file load for each page

@new
Scenario: Questions without expert answers should have a ugc value of y
  Given I have a list of questions without expert answers
  Then I should see a ugc value of y when I visit those questions

