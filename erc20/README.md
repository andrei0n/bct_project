# ERC-20 contract governance

For the ERC-20 token contract, governance becomes a little more complicated.
The logic contract and the interfaces it's based on are in `token.sol` and `erc20.sol` respectively.
To facilitate replacement, the logic contract uses a separate storage contract (like the `database` PoC), which is given to the new logic contract upon replacement. Here we use the Proxy with "delegatecall", so the storage is at the proxy's address.

As opposed to earlier governed contracts, there is only one governor now.
In this example, the token should follow the ERC-20 specification, which does not allow any governance other than the access control in the spec.
The one remaining governor can transfer the token storage (i.e. everyone's balances) to a new contract.

The total picture is then

```
┌───────────────┐  has one  ┌───────────────┐  is a 
│ Proxy         ├───────────┤ GovernorOwner ├──────┬─ Governor
└──┬────────────┘           └───────────────┘      └─ Ownable (you!)
   │
   │ forwards unknown calls to
   │
┌──┴────────────┐  is a  ┌─ ERC20Token
│ GovernedToken ├────────┼
└──┬────────────┘        └─ ERC20Details
   │
   │ has one
   │
┌──┴────────────┐  is a
│ TokenStorage  ├────────── Ownable (owner = GovernedToken)
└───────────────┘
```

To make sure that the (proxied) storage is properly initialized, there is a separate "initialize" method that can only be called once. Maybe in the future this can be avoided. 
To initialize everything, make a GovernedToken.
Then, make a Proxy with the GovernedToken as its new token (constructor argument). Then call the initialize method on the proxy address (using the GovernedToken ABI).
The Proxy makes its own Governor.

To replace the GovernedToken, make a version with updated code.

After creating the new token, you can ask your GovernorOwner to tell the Proxy to tell the GovernedToken to transfer its storage to the new token.
