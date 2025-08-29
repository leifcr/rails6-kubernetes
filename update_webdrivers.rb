# Prefetch Selenium Manager drivers (Chrome & Firefox) so first test is fast.
require "selenium-webdriver"

def prefetch(browser)
  case browser
  when :chrome
    opts = Selenium::WebDriver::Options.chrome(args: %w[--headless=new --disable-gpu])
  when :firefox
    opts = Selenium::WebDriver::Options.firefox(args: %w[-headless])
  end
  driver = Selenium::WebDriver.for(browser, options: opts)
  driver.quit
  puts "#{browser} driver ready"
rescue => e
  warn "#{browser} prefetch failed: #{e.class}: #{e.message}"
end

[:chrome, :firefox].each { |b| prefetch(b) }