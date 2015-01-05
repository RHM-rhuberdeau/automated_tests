def wait_for_ajax
  begin
    Timeout.timeout(Capybara.default_wait_time) do
      loop until finished_all_ajax_requests?
    end
  rescue Timeout::Error
    page.execute_script("window.stop();")
  end
end

def finished_all_ajax_requests?
  begin
    page.evaluate_script('jQuery.active').zero?
    sleep 0.5
  rescue Timeout::Error
    page.execute_script("window.stop();")
  end
end

Given(/^I visit "(.*?)"$/) do |url|
  visit url
end

Then(/^I should see "(.*?)" in "(.*?)"$/) do |text, tag|
  page.should have_selector(tag, text: text)
end

Then(/^"(.*?)" should equal "(.*?)"$/) do |prop_variable, prop_value|
  page.evaluate_script("thcn.#{prop_variable}").should eql(prop_value)
end

Then(/^I check the omniture values$/) do
  props = {'prop1' => 'foo', 'prop45' => 'bar'}
  failed = []
  props.each do |prop|
  	if page.evaluate_script("thcn.#{props[prop]}" != props[prop])
  		failed << prop
  	end
  end
  failed.length.should equal(0), "Failed values: #{failed}"
end

Then(/^check the omniture values$/) do
  props = {'prop1' => 'Body & Mind', 'prop45' => 'cm.ver.lblnibd'}
  failed = []
  props.each do |prop|
  	if page.evaluate_script("thcn.#{props[prop]}" != props[prop])
  		failed << prop
  	end
  end
  failed.length.should equal(0), "Failed values: #{failed}"
end

Given(/^I have a text file with urls$/) do
  File.exists?("links.txt").should equal(true)
end

Given(/^I visit a slideshow page$/) do
  visit "#{BW_BASE_URL}/healthy-eating/food/slideshow/can-food-cause-body-odor"
  wait_for_ajax
end

Then(/^I should see a new slide each time I click the next arrow$/) do
  @slideshow = page.all("ul.slides").first
  @slides    = @slideshow.all('li', visible: false)
  @slides.each_with_index do |slide, index|
    unless index == 6
      text = slide.text
      page.find("a.flex-next").click
      wait_for_ajax
      expect(@slideshow.text).to_not eq(text)
    end
  end
end

Then(/^I should see a new slide each time I click the back arrow$/) do
  @slides = @slides.to_a.reverse
  @slides.each_with_index do |slide, index|
    unless index == 6
      text = slide.text
      page.find("a.flex-prev").click
      wait_for_ajax
      expect(@slideshow.text).to_not eq(text)
    end
  end
end

Then(/^I should see a new ad each time I click the next arrow$/) do
  @slideshow = page.all("ul.slides").first
  @slides    = @slideshow.all('li', visible: false)
  @iframe_count = 1
  @ads_text_for_slide = {}
  @slides.each_with_index do |slide, index|
    unless index == 6
      @ads_text_for_slide[index] = page.evaluate_script("$('iframe').eq(#{@iframe_count}).html();")
      page.find("a.flex-next").click
      wait_for_ajax
      sleep 5
      @iframe_count += 3
      new_ads_text = page.evaluate_script("$('iframe').eq(#{@iframe_count}).html();")
      expect(@ads_text_for_slide[index]).to_not eq(new_ads_text), "#{@ads_text_for_slide[index]} \n  should not equal \n #{new_ads_text}"
    end
  end
end

Then(/^I should see a new ad each tim I click the previous arrow$/) do
  @iframe_count = 18
  @slides = @slides.to_a.reverse
  @slides.each_with_index do |slide, index|
    unless index == 6
      ads_text = page.evaluate_script("$('iframe').eq(#{@iframe_count}).html();")
      page.find("a.flex-prev").click
      wait_for_ajax
      sleep 5
      @iframe_count -= 3
      new_ads_text = page.evaluate_script("$('iframe').eq(#{@iframe_count}).html();")
      expect(ads_text).to_not eq(new_ads_text), "#{ads_text} \n should not equal \n #{new_ads_text}"
    end
  end
end

Given(/^I visit healthcentral$/) do
  visit HC_BASE_URL
end

Given(/^I browse some pages$/) do
  wrong_asset_host = (["qa.healthcentral.", "www.healthcentral.com"] - [ASSET_HOST]).to_s
  urls = [
    "http://www.healthcentral.com/multiple-sclerosis/c/255251/172231/turning-embrace?ic=caro",
    "http://www.healthcentral.com/adhd/",
    "http://www.healthcentral.com/skin-care/d/LBLN/living-with-psoriasis/launch/?ic=caro",
    "http://immersive.healthcentral.com/skin-care/d/LBLN/living-with-psoriasis/?ic=caro",
    "http://www.healthcentral.com/heart-disease/c/all",
    "http://www.healthcentral.com/heart-disease/c/question",
    "http://www.healthcentral.com/heart-disease/c/question/230633/173694",
    "http://www.healthcentral.com/vision-care/d/quizzes/things-every-contact-lens-wearer-should-know"
  ]
  @failed = urls.map do |url|
    visit url
    wait_for_ajax
    if page.html.include? wrong_asset_host
      url
    end
  end
end

Then(/^I should not see assets from other environments$/) do
  expect(@failed.compact.length).to eq(0), "#{@failed.inspect}"
end

Given(/^I have a list of pages$/) do
  @urls = [
    "http://www.healthcentral.com/multiple-sclerosis/c/255251/172231/turning-embrace?ic=caro",
    "http://www.healthcentral.com/adhd/",
    "http://www.healthcentral.com/skin-care/d/LBLN/living-with-psoriasis/launch/?ic=caro",
    "http://immersive.healthcentral.com/skin-care/d/LBLN/living-with-psoriasis/?ic=caro",
    "http://www.healthcentral.com/heart-disease/c/all",
    "http://www.healthcentral.com/heart-disease/c/question",
    "http://www.healthcentral.com/heart-disease/c/question/230633/173694",
    "http://www.healthcentral.com/vision-care/d/quizzes/things-every-contact-lens-wearer-should-know"
  ]
end

Then(/^I should see all the assets loading as I visit those pages$/) do
  @@proxy.new_har

  @urls.each do |url|
    visit url
    wait_for_ajax
  end

  unloaded_assets = []
  unloaded_assets << @@proxy.har.entries.find do |entry|
    entry.request.url.split('.com').first.include?("http://healthcentral") && entry.response.status != 200
  end

  expect(unloaded_assets.compact).to be_empty, "#{unloaded_assets.each {|x| puts x.inspect }}"
end

Then(/^I should see the "(.*?)" file load for each page$/) do |asset_url|
  @urls.each do |url|
    visit url
    wait_for_ajax
    expect(page.source.include?(asset_url)).to eq(true)
  end
end