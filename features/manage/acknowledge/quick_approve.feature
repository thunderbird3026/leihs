Feature: Quick Approve orders

  In order to approve contracts quickly
  As a Lending Manager
  I want to have quick approve functionalities on the submitted orders

  Background:
    Given personas existing
    And I am "Pius"

  @javascript
  Scenario: Quick approve an order with no problems
    Given I open the daily view
    When I quick approve a submitted order
    Then that order is approved
    And I see a link to the hand over process of that order

  @javascript
  Scenario: Approve anyway on daily view
    Given I open the daily view
    And I try to approve a contract that has problems
    Then I got an information that this contract has problems
    When I approve anyway
    Then this contract is approved

