# 04. Fee Mining & PayList Distribution

LinkProxy provides flexible, hardware-safe fee routing with multi-wallet payout distribution.

---

## Basic Fee Configuration

In the port configuration modal, switch to the **Fee Settings** tab:

1. **Fee Percentage**: Enter the service percentage (e.g. `1.5` for 1.5%). Set to `0` for no fee.
2. **Fee Wallet Address**: Enter your receiving wallet address or pool sub-account.
3. **Custom Worker Name (Optional)**: Specify how fee workers appear on pool dashboards (e.g. `fee_worker`). Defaults to original worker name if empty.
4. **Dedicated Fee Pool (Optional)**:
   - **Leave empty (Recommended)**: Routes fee shares to the same main pool smoothly without switching pools.
   - **External Pool**: Specify an external pool address if you prefer collecting all fee shares in a single designated pool.

---

## Multi-Wallet Distribution (PayList)

For mining operations with multiple partners or automated profit-sharing:

```
Total Fee Shares (100%)
   ├── Partner A Wallet: 60%
   ├── Partner B Wallet: 30%
   └── Operations Fund:  10%
```

Configuration example:
```json
[
  { "wallet": "Wallet_Partner_A", "percent": 60 },
  { "wallet": "Wallet_Partner_B", "percent": 30 },
  { "wallet": "Wallet_Team_Fund", "percent": 10 }
]
```

LinkProxy's deterministic share scheduler allocates fee shares strictly according to configured weights over time.

---

## VIP Zero-Fee Whitelist (`FilterWallet`)

Exempt VIP clients or internal test miners without creating separate ports:

- In the **Whitelist (`filter_wallet`)** field, enter comma-separated wallet addresses:
  ```
  wallet_vip_01,wallet_vip_02,wallet_vip_03
  ```
- Any miner matching the whitelist receives **lifetime 100% pass-through**, bypassing fee switching entirely with zero overhead.
