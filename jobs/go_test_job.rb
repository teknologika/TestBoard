require 'nokogiri'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
  last_passing = 0
  passing = 0


SCHEDULER.every '10s', :first_in => 0 do |job|

  last_passing = passing
  status = "ok"
  url = "http://localhost:8153/go/api/jobs/46.xml"

  # Read the values from the GO jobs API
  begin 
    @doc = Nokogiri::XML(open(url))
  
    if @doc 
      duration =  @doc.at_css("[name='tests_total_duration']").text.to_i
      ignored = @doc.at_css("[name='tests_ignored_count']").text.to_i
      if ignored > 0
      	status = "danger"
      end
    
      failed_tests = @doc.at_css("[name='tests_failed_count']").text.to_i
      if failed_tests > 0
        status = "warning" 
      end
      total_tests = @doc.at_css("[name='tests_total_count']").text.to_i
      passing = total_tests.to_i - failed_tests - ignored
  
  
      # Note: not run is hardcodded to zero. Setting Not run greater than 0 will introcude a black gap into the chart
      send_event('quickquote_gui_test_data', { passed: passing, last_passed: last_passing,ignored: ignored, failed: failed_tests, not_run:0, duration:duration, status:status})
    end
  rescue
    puts "\e[33mError connecting to Go Server: " + url + " \e[0m"
  end
end