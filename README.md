Technologies Used:

Solidity: Smart contract programming language.
OpenZeppelin Contracts: Reusable smart contract components following best practices.
tested using foundry.

Efficiency Considerations:
Gas Costs: Gas costs can be optimized further based on specific requirements.
Token Conversion: Adjust the calculateTokenAmount function based on your token conversion logic.
Security: Additional security measures such as input validation and testing are essential.
Gas Efficiency: Carefully consider gas costs for each function and optimize where possible.

**Token Sale Smart Contract - Test Cases**

1. **Presale Contribution:**
   - **Scenario:**
     - A user contributes within the minimum and maximum limits during the presale.
   - **Steps:**
     1. Start the presale.
     2. User Alice contributes Ether within the allowed limits.
   - **Expected Result:**
     - Ether is deducted from Alice's account.
     - Project tokens are immediately distributed to Alice.
     - Presale contribution event is logged.

2. **Public Sale Contribution:**
   - **Scenario:**
     - A user contributes within the minimum and maximum limits during the public sale.
   - **Steps:**
     1. Start the public sale (after ending the presale).
     2. User Bob contributes Ether within the allowed limits.
   - **Expected Result:**
     - Ether is deducted from Bob's account.
     - Project tokens are immediately distributed to Bob.
     - Public sale contribution event is logged.

3. **Token Distribution:**
   - **Scenario:**
     - The owner distributes project tokens to a specified address.
   - **Steps:**
     1. Call the token distribution function as the contract owner.
   - **Expected Result:**
     - Project tokens are transferred to the specified address.
     - Token distribution event is logged.

4. **Refund - Minimum Cap Not Reached:**
   - **Scenario:**
     - The presale or public sale minimum cap is not reached, and a contributor claims a refund.
   - **Steps:**
     1. End the presale or public sale without reaching the minimum cap.
     2. A contributor requests a refund.
   - **Expected Result:**
     - The contributor's Ether is refunded.
     - Refund claimed event is logged.

5. **Refund - Minimum Cap Reached:**
   - **Scenario:**
     - The presale or public sale minimum cap is reached, and a contributor cannot claim a refund.
   - **Steps:**
     1. Contribute to reach the minimum cap.
     2. Try to claim a refund.
   - **Expected Result:**
     - Refund cannot be claimed as the minimum cap is reached.

6. **Security Check - Unauthorized Token Distribution:**
   - **Scenario:**
     - A non-owner attempts to distribute project tokens.
   - **Steps:**
     1. Call the token distribution function as a non-owner.
   - **Expected Result:**
     - The transaction should revert, and tokens should not be distributed.
     - An error or exception event is logged.

7. **Security Check - Unauthorized Sale Start:**
   - **Scenario:**
     - A non-owner attempts to start the presale or public sale.
   - **Steps:**
     1. Call the start presale or start public sale function as a non-owner.
   - **Expected Result:**
     - The transaction should revert, and the sale phase should not change.
     - An error or exception event is logged.

8. **Gas Optimization Check:**
   - **Scenario:**
     - Contribute Ether to the presale or public sale and check gas costs.
   - **Steps:**
     1. Contribute Ether within the allowed limits.
     2. Check gas costs.
   - **Expected Result:**
     - Gas costs should be within reasonable limits for typical contributions.

9. **Error Handling Check:**
   - **Scenario:**
     - Attempt various operations with invalid parameters.
   - **Steps:**
     1. Contribute with an amount exceeding the maximum limit.
     2. Attempt a refund before the end of the presale or public sale.
     3. Distribute tokens without specifying a recipient.
   - **Expected Result:**
     - Transactions with invalid parameters should revert, and errors should be appropriately logged.
