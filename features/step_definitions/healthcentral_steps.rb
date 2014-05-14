Given(/^I visit "(.*?)"$/) do |url|
  visit url
end

Then(/^I should see "(.*?)" in "(.*?)"$/) do |text, tag|
  page.should have_selector(tag, text: text)
end