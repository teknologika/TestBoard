require 'nokogiri'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
  last_passing = 0
  passing = 0


SCHEDULER.every '10s', :first_in => 0 do |job|

  last_passing = passing
  status = "ok"

  # Read the values from a JUnit XML file
  @doc = Nokogiri::HTML(open("http://localhost/system_tests.xml"))

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


  # Note: not run is hardcodded to zero. Setting Not run greater than 0 will introcude a black gap into the chart
  send_event('system_test_data', { passed: passing, last_passed: last_passing,ignored: ignored, failed: failed_tests, not_run:0, duration:duration, status:status})
end