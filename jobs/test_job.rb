# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
  system_last_passing = 0
  system_passing = 0

SCHEDULER.every '10s', :first_in => 0 do |job|
  system_last_passing = system_passing
  system_passing = rand(100)
  system_failed = 100 - system_passing 
  send_event('unit_test_data', { passed: 140, last_passed: 138, failed:0, not_run:50})
  send_event('system_test_data', { passed: system_passing, last_passed: system_last_passing, failed: system_failed, not_run:0})
end