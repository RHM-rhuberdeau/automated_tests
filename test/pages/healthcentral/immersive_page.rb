require_relative './healthcentral_page'

class ImmersivePage < HealthCentralPage
  attr_reader :driver, :proxy

  def initialize(driver, proxy)
    @driver = driver
    @proxy = proxy
  end

  def start_immersive
    driver.find_element(:css, "#edit-submit").click
  end

  def show_side_nav
    titles = driver.find_elements(:css, ".chapter-title")
    begin
      driver.action.move_to(titles[1]).perform
    rescue Selenium::WebDriver::Error::MoveTargetOutOfBoundsError
      sleep 2
      driver.action.move_to(titles[1]).perform
    end
  end

  def go_to_chapter(chapter)
    chapter = chapter.to_i
    links = driver.find_elements(:css, "span.chapter")
    link = links.select {|link| link.text.include?("CHAPTER #{chapter}")}
    link.first.click
    sleep 2
  end

  def go_through_chapter
    articles = driver.find_elements(:css, "article").length + driver.find_elements(:css, ".galleryModule audio").length - 1
    articles.times do
      driver.find_element(:css, ".overlay").click
      wait_for_page_to_load
      sleep 2
    end
  end

  def ad_for_chapter(chapter)
    chapter_ads = []
    proxy.har.entries.each do |entry|
      if entry.request.url.include?("ad.doubleclick.net/N3965/adj/cm.ver.lblnskin/immersive/#{chapter}")
        chapter_ads << entry.request.url
      end
    end
    chapter_ads.compact.length
  end
end