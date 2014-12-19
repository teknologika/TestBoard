require 'nokogiri'

 # Any junit soource file will need to be added to the sources list
 sources = {
    'system_test_data' => "http://localhost/system_tests.xml",
    'unit_test_data' => "http://localhost/unit_tests.xml"
  }


# Set up a hash to store the last passing count for each source
# Set everything to zero
last_passing = {}
sources.each do |source, url|
    last_passing.store(source,0)
end

passing = 0

SCHEDULER.every '10s', :first_in => 0 do |job|


  sources.each do |source, url|

    # Reset the status to OK
    status = "ok"

    # Read the values from a JUnit XML file
    begin
      @doc = Nokogiri::HTML(open(url))
    rescue
      puts "\e[33mError reading Junit file: " + url + " \e[0m"
    end

    if @doc 
      duration =  @doc.at_css("testsuite").attr("time").to_i
      ignored = @doc.at_css("testsuite").attr("skipped").to_i
      if ignored > 0
        status = "danger"
      end
  
      failed_tests = @doc.at_css("testsuite").attr("failures").to_i 
      if failed_tests > 0
        status = "warning" 
      end

      total_tests = @doc.at_css("testsuite").attr("tests").to_i
      passing = total_tests.to_i - failed_tests - ignored
      
    end

    # Note: not run is hardcodded to zero. Setting Not run greater than 0 will introcude a black gap into the chart
    send_event(source, { passed: passing, last_passed: last_passing[source],ignored: ignored, failed: failed_tests, not_run:0, duration:duration, status:status})
  
    last_passing[source] = passing
  end
end