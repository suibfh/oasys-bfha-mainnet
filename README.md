# Brush Field Home Atelier (BFHA)

Pixel Art NFT Contract with BPC Fee Mechanism for Oasys Blockchain

## 概要

Brush Field Home Atelier (BFHA) は、ユーザーが16×16のピクセルアートを作成し、NFTとして発行できるコントラクトです。

## 主な機能

- **BPC Fee Mechanism**: NFT発行時に1000 BPCトークンが必要
- **ERC721準拠**: 標準的なNFTとして取引可能
- **On-chain Metadata**: トークンURIをコントラクトに保存

## デプロイ方法

### テストネット

```bash
forge create --rpc-url https://rpc.testnet.oasys.games \
    --private-key $PRIVATE_KEY \
    src/BrushFieldHomeAtelier.sol:BrushFieldHomeAtelier \
    --constructor-args <BPC_TOKEN_ADDRESS>
```

### メインネット

```bash
forge create --rpc-url https://rpc.mainnet.oasys.games \
    --private-key $PRIVATE_KEY \
    src/BrushFieldHomeAtelier.sol:BrushFieldHomeAtelier \
    --constructor-args <BPC_TOKEN_ADDRESS>
```

## コンストラクタ引数

- `_bpc`: BPC (Brush Point Coin) トークンのアドレス

## テストネット検証結果

- **TestBPC**: `0x83854AA73B858D90DF8EaC8fA811eAae7D05aD40`
- **BFHA**: `0xE52C66B9545F3F79057d681B6B95CDf411F1D039`
- **検証済みトランザクション**: https://explorer.testnet.oasys.games/tx/0x2448ceb9f51073cb10b5a60408d43c76597d2374eb3de0b4277e4dccfbe10e8c

## 使用方法

1. BPCトークンを1000以上保有
2. BFHAコントラクトに1000 BPCをApprove
3. `mint(tokenUri)` を実行してNFTを発行

## セキュリティ

- Slither解析済み
- OpenZeppelin標準ライブラリ使用
- Immutable変数による安全性確保

## ライセンス

MIT
