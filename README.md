# README: Charity Donation Smart Contract

## Overview

This Clarity smart contract is designed to facilitate donations to approved charities on the Stacks blockchain. It allows users to register charities, make donations, allocate matching funds, and claim donations for approved charities. It also ensures secure handling of funds and enforces permissions for administrative actions.

---

## Key Features

1. **Charity Registration**:
   - Users can register new charities with a name, description, and wallet address.
   - Each charity is assigned a unique `charity-id`.

2. **Charity Approval**:
   - Only an admin can approve a charity, making it eligible to receive donations.

3. **Donations**:
   - Users can donate STX to approved charities.
   - Donations can be matched from a separate matching fund.

4. **Matching Fund**:
   - A fund maintained by the contract to match donations up to the available balance.

5. **Fund Claims**:
   - Charities can claim their collected donations and matching funds.
   - Donation records and matching amounts are reset upon claiming.

6. **Read-only Functions**:
   - View details of a specific charity.
   - Retrieve all donations made by a specific donor.

---

## Data Structures

### Maps
1. **`charities`**:
   - Key: `{charity-id: uint}`
   - Value: `{name, description, wallet, total-donations, total-matched, is-approved}`

2. **`donations`**:
   - Key: `{charity-id: uint, donor: principal}`
   - Value: `{amount: uint}`

### Data Variables
1. **`matching-fund`**: Tracks the available balance for matching donations.
2. **`next-charity-id`**: Maintains the next available `charity-id`.

---

## Functions

### Public Functions

1. **`register-charity`**:
   - Registers a new charity with its details.
   - Returns the assigned `charity-id`.
   - Example Usage:
     ```clarity
     (register-charity "Charity Name" "Charity Description" 'SP123...)
     ```

2. **`approve-charity`**:
   - Admin-only function to approve a charity.
   - Ensures the charity is eligible to receive donations.
   - Example Usage:
     ```clarity
     (approve-charity u1)
     ```

3. **`donate`**:
   - Allows users to donate to an approved charity.
   - Matches the donation from the matching fund if available.
   - Example Usage:
     ```clarity
     (donate u1 u1000)
     ```

4. **`add-matching-fund`**:
   - Adds STX to the matching fund.
   - Example Usage:
     ```clarity
     (add-matching-fund u5000)
     ```

5. **`claim-funds`**:
   - Allows charities to claim their total donations and matching funds.
   - Example Usage:
     ```clarity
     (claim-funds u1)
     ```

### Read-only Functions

1. **`get-charity`**:
   - Retrieves details of a specific charity by `charity-id`.
   - Example Usage:
     ```clarity
     (get-charity u1)
     ```

2. **`get-donor-donations`**:
   - Retrieves all donations made by a specific donor.
   - Example Usage:
     ```clarity
     (get-donor-donations 'SP123...)
     ```

---

## Error Codes

- **`u100`**: Unauthorized access (admin-only action).
- **`u101`**: Charity not found.
- **`u102`**: Charity not approved.
- **`u103`**: No funds available for claiming.

---

## How to Deploy and Use

1. **Deployment**:
   - Deploy the contract using a Clarity-compatible environment like [Stacks CLI](https://docs.hiro.so/cli-reference) or a smart contract deployment tool.

2. **Admin Setup**:
   - Replace `'SPADMINADDRESS` with the actual admin principal before deployment.

3. **Operations**:
   - Use the public functions to register, approve, donate, and claim funds.

---

## Security Features

- **Access Control**: 
  - Admin-only functions ensure secure charity approval.
  
- **Fund Management**:
  - STX transfers are securely handled through Clarity's `stx-transfer?`.

- **Validation**:
  - Proper checks ensure charities are approved before receiving donations.

---

## Future Enhancements

1. **Enhanced Reporting**:
   - Add functionality to generate detailed donation reports.

2. **Multiple Admins**:
   - Allow multiple administrators to manage the platform.

3. **Donation Refunds**:
   - Provide an option to refund donations under certain conditions.

---

## Conclusion

This contract provides a robust platform for managing charitable donations on the Stacks blockchain. Its built-in features ensure secure and transparent fund management, making it an excellent choice for decentralized charity platforms.
