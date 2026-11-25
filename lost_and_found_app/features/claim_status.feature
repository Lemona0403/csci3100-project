Feature: How claim status is changed together with item status
  Background:
    Given facility "University Library" exists
    And staff "staff.ulib@example.com" belongs to "University Library"
    And general user "user1@example.com" exists
    And available item "Blue Hoodie" exists at "University Library"

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