Feature: Require login
  Scenario: Guest is redirected to login
    Given I am not logged in
    When I visit the items page
    Then I should be on the login page