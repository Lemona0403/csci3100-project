Feature: How claim status is changed together with item status
  Background:
    Given facility "University Library" exists
    And staff "staff.ulib@example.com" belongs to "University Library"
    And general user "user1@example.com" exists
    And available item "Blue Hoodie" exists at "University Library"
    And available item "Red Backpack" exists at "University Library"
    And available item "Green Scarf" exists at "University Library"

  Scenario: User submits a claim
    Given I am logged in as "user1@example.com"
    When I claim item "Blue Hoodie" with contact "12345678"
    Then the claim for "Blue Hoodie" should have status "pending"
    And I should see claim status "pending"
    And item "Blue Hoodie" should have status "claim_pending"

  Scenario: General users cannot see claim review controls
    Given a pending claim on "Blue Hoodie" by "user1@example.com"
    And I am logged in as "user1@example.com"
    When I view the claim for "Blue Hoodie"
    Then I should not see claim review controls
    And I should see item information for "Blue Hoodie"

  Scenario: General user's claims default to pending and can be filtered by status
    Given a pending claim on "Blue Hoodie" by "user1@example.com"
    And an approved claim on "Red Backpack" by "user1@example.com"
    And a rejected claim on "Green Scarf" by "user1@example.com"
    And I am logged in as "user1@example.com"
    When I visit the claims page
    Then the claim status filter should default to pending
    And I should see a claim for "Blue Hoodie"
    And I should not see a claim for "Red Backpack"
    And I should not see a claim for "Green Scarf"
    When I filter claims by "approved"
    Then I should see a claim for "Red Backpack"
    And I should not see a claim for "Blue Hoodie"
    When I filter claims by "rejected"
    Then I should see a claim for "Green Scarf"
    And I should not see a claim for "Red Backpack"

  Scenario: Staff claims default to pending without an all statuses option
    Given a pending claim on "Blue Hoodie" by "user1@example.com"
    And an approved claim on "Red Backpack" by "user1@example.com"
    And I am logged in as "staff.ulib@example.com"
    When I visit the claims page
    Then the claim status filter should default to pending
    And I should see a claim for "Blue Hoodie"
    And I should not see a claim for "Red Backpack"

  Scenario: User tries to submit a claim for item that are claim_pending or claimed
    Given a pending claim on "Blue Hoodie" by "user1@example.com"
    And I am logged in as "user1@example.com"
    When I try to claim "Blue Hoodie"
    Then I should be redirected to the items page
    Then I should see that the item cannot be claimed
    And item "Blue Hoodie" should have status "claim_pending"

  Scenario: Staff approves a claim
    Given a pending claim on "Blue Hoodie" by "user1@example.com"
    And I am logged in as "staff.ulib@example.com"
    When I approve the claim for "Blue Hoodie"
    Then I should see claim status "approved"
    And the claim for "Blue Hoodie" should have status "approved"
    And item "Blue Hoodie" should have status "claimed"

  Scenario: Staff rejects a claim
    Given a pending claim on "Blue Hoodie" by "user1@example.com"
    And I am logged in as "staff.ulib@example.com"
    When I reject the claim for "Blue Hoodie"
    Then I should see claim status "rejected"
    And the claim for "Blue Hoodie" should have status "rejected"
    And item "Blue Hoodie" should have status "available"