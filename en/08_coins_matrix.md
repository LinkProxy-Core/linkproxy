# 08. Supported Coins & Miner Setup

LinkProxy provides native support for 15 major PoW algorithms and next-generation coins.

---

## Supported Coin Matrix

| Coin | Full Name | Algorithm (PoW) | Hashrate Unit | Recommended Protocol | Compatible Hardware |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **BTC** | Bitcoin | SHA256d | TH/s, EH/s | SSLMIX / ECCP256MIX | Antminer S19/S21, Whatsminer M30/M50 |
| **BCH** | Bitcoin Cash | SHA256d | TH/s, PH/s | SSLMIX | Antminer, Whatsminer series |
| **LTC** | Litecoin | Scrypt | GH/s, TH/s | SSLMIX | Antminer L7/L9, Goldshell series |
| **ETC** | Ethereum Classic | Etchash | MH/s, GH/s | SSLMIX | Jasminer, Poloniex ASIC, GPU rigs |
| **ETHW** | EthereumPoW | Ethash | MH/s, GH/s | SSLMIX | GPU rigs, Ethash ASICs |
| **ZEC** | Zcash | Equihash | KSol/s | SSLMIX | Antminer Z15 series |
| **SC** | Siacoin | Blake2b-Sia | GH/s, TH/s | SSLMIX | Goldshell, Antminer SC series |
| **DASH** | Dash | X11 | GH/s, TH/s | SSLMIX | Antminer D9 series |
| **CKB** | Nervos | Eaglesong | TH/s | SSLMIX | Antminer K7 series |
| **CFX** | Conflux | Octopus | MH/s, GH/s | SSLMIX | GPU rigs |
| **ALEO** | Aleo ZKP | SnarkVM | K/s, M/s | TCP / SSLMIX | Specialized GPU/CPU nodes |
| **KAS** | Kaspa | kHeavyHash | GH/s, TH/s | SSLMIX | Antminer KS3/KS5, IceRiver series |
| **ALPH** | Alephium | Blake3 | GH/s, TH/s | SSLMIX | Specialized Blake3 ASICs |
| **PRL** | Pearlhash | Pearlhash | MH/s, GH/s | SSLMIX / TCP | SRBMiner, custom rigs |
| **QTC** | Quantus | Quantus PoW | GH/s, TH/s | SSLMIX / TCP | Official client, compute nodes |

---

## Next-Gen Coins Native Support (PRL & QTC)

- **PRL (Pearlhash)**: Dual-algorithm protocol frame unpacker aligns dashboard hashrate with real pool payouts in real time.
- **QTC (Quantus)**: Poseidon2 protocol state machine with ultra-low latency share forwarding.

---

## Miner Configuration Examples

Point your miner's pool setting to your LinkProxy server IP and port:

### 1. Antminer S19/S21 (BTC Example)
- **URL**: `stratum+tcp://YOUR_PROXY_IP:8888`
- **Worker**: `YourWallet.worker01`
- **Password**: `123` or `x`

### 2. Antminer L7/L9 (LTC/DOGE Example)
- **URL**: `stratum+tcp://YOUR_PROXY_IP:3333`
- **Worker**: `YourLTCAccount.worker01`
- **Password**: `x`

### 3. GPU Rig (SRBMiner Example for ETC / PRL)
```bash
# ETC Example
SRBMiner-MULTI.exe --algorithm etchash --pool YOUR_PROXY_IP:9999 --wallet YourETCWallet.gpu01

# PRL Example
SRBMiner-MULTI.exe --algorithm pearlhash --pool YOUR_PROXY_IP:7777 --wallet YourPRLWallet.worker01
```
