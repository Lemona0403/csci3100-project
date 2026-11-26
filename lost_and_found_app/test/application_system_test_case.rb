require "test_helper"
require "capybara/selenium/driver_specializations/chrome_driver"

# Chrome 158 rejects Capybara's wildcard origin when resetting the browser.
module ClearChromeStorageWithoutWildcardOrigin
  private

  def execute_cdp(cmd, params = {})
    return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    storage_types = params[:storageTypes].to_s.split(",")
    super("Network.clearBrowserCookies") if storage_types.delete("cookies")

    origin = Capybara.current_session.server&.base_url
    if origin && storage_types.any?
      super(cmd, params.merge(origin: origin, storageTypes: storage_types.join(",")))
    end
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ClearChromeStorageWithoutWildcardOrigin)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
end
