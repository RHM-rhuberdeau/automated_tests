require_relative '../../minitest_helper' 
require_relative '../../pages/the_body_mobile_page'

class HowDoIKnowIfIHaveHiv < MiniTest::Test
  context "A TheBody mobile page" do 
    setup do 
      mobile_fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/the_body/articles.yml')
      body_fixture = YAML::load_documents(io)
      @body_fixture = OpenStruct.new(body_fixture[0]['how-do-i-know-if-i-have-HIV-mobile'])
      @page = ::TheBody::TheBodyMobilePage.new(@driver, @proxy, @body_fixture)
      visit "#{Configuration["thebody"]["base_url"]}/h/how-do-i-know-if-i-have-HIV.html"
    end


    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        functionality = @page.functionality
        functionality.validate
        assert_equal(true, functionality.errors.empty?, "#{functionality.errors.messages}")
      end
    end

    ##################################################################
    ################### ASSETS #######################################
    context "assets" do 
      should "have valid assets" do 
        assets = @page.assets
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end

    ##################################################################
    ################### SEO ##########################################
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, @page.has_correct_title?)
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "have unique ads" do 
        @driver.execute_script "window.scrollBy(0, 4000)"
        sleep 1
        # page.ads_on_page(3), 3 because we expect 3 ads on the page
        ads1 = @page.ads_on_page(3)
        visit "#{Configuration["thebody"]["base_url"]}/h/how-do-i-know-if-i-have-HIV.html"
        sleep 1
        @driver.execute_script "window.scrollBy(0, 4000)"
        sleep 1
        ads2 = @page.ads_on_page(3)

        ord_values_1 = ads1.collect(&:ord).uniq
        ord_values_2 = ads2.collect(&:ord).uniq
    
        assert_equal(1, ord_values_1.length, "Ads on the first view had multiple ord values: #{ord_values_1}")
        assert_equal(1, ord_values_2.length, "Ads on the second view had multiple ord values: #{ord_values_2}")
        assert_equal(true, (ord_values_1[0] != ord_values_2[0]), "Ord values did not change on page reload: #{ord_values_1} #{ord_values_2}")
      end

      should "have valid omniture values" do 
        omniture = @page.omniture
        omniture.validate
        assert_equal(true, omniture.errors.empty?, "#{omniture.errors.messages}")
      end
    end

    ##################################################################
    ################### GLOBAL SITE TESTS ############################
    context "Global Site tests" do 
      should "have passing global test cases" do 
        mobile_menu = @driver.find_element(:css, ".icon-menu.js-icon-menu")
        mobile_menu.click
        wait_for { @driver.find_element(css: '.ul.Nav-listGroup-list--HealthTools .js-Nav--Primary-accordion-title.Nav-listGroup-list-title').displayed? }

        global_test_cases = @page.global_test_cases
        global_test_cases.validate
        assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")
      end
    end
  end#A TheBody mobile page

  def teardown  
    @driver.quit  
    @proxy.close
  end
end