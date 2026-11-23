Feature: Access limit

  Background:
    Given facility "University Library" exists
    And facility "University Sport Centre" exists
    And staff "staff.ulib@example.com" belongs to "University Library"
    And staff "staff.usc@example.com" belongs to "University Sport Centre"
    And general user "user1@example.com" exists
    And general user "user2@example.com" exists
    And available item "Blue Hoodie" exists at "University Library"
    And available item "Sports Towel" exists at "University Sport Centre"

  Scenario: General users cannot claim item that is claim_pending
    Given a pending claim on "Blue Hoodie" by "user1@example.com"
    And I am logged in as "user2@example.com"
    When I claim item "Blue Hoodie" with contact "12345678"
    Then I should see that the item cannot be claimed
    And item "Blue Hoodie" should have status "claim_pending"

  Scenario: Staff cannot see items from another facility
    Given I am logged in as "staff.ulib@example.com"
    When I visit the items page
    Then I should see item "Blue Hoodie"
    And I should not see item "Sports Towel"

  Scenario: General user only sees own claims
    Given a pending claim on "Blue Hoodie" by "user1@example.com"
    And a pending claim on "Sports Towel" by "user2@example.com"
    And I am logged in as "user2@example.com"
    When I visit the claims page
    Then I should see a claim for "Sports Towel"
    And I should not see a claim for "Blue Hoodie"

  Scenario: General user cannot create claim for another user
    Given I am logged in as "user1@example.com"
    When I claim item "Blue Hoodie" with contact "12345678"
    Then the claim for "Blue Hoodie" should belong to "user1@example.com"