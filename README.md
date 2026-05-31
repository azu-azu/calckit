# CalcKit

iOS 電卓アプリ。基本的な計算機能に加えて、ワリカン・日数計算・目標計算・数学ツールを搭載。

## 機能

### ホーム（電卓）
- 四則演算（+, -, ×, ÷）
- 括弧 `()` による優先順位指定
- `←` で1文字削除
- Save で計算過程と結果を History に保存

### ワリカン
- 合計金額 ÷ 人数のシンプルなワリカン
- 特殊払い追加（金額 × 人数）を複数設定可能
- 残額を自動で均等割り

### 日数計算
- カレンダーからスタート日・エンド日を選択
- 全日数 / 営業日のみ（土日除外）の切り替え

### 目標計算
- **期間指定**: 日・週・月・年の期間を指定して目標数値を入力、各時間単位の内訳を自動計算
- **期限指定**: 年末・月末・任意日付を締め切りに設定してペースを逆算
- **単位入力**: 1日あたりの数値を入力して1週間・1ヶ月・1年の累計を自動計算
- 平日のみモード（土日除外）対応

### 数学
- ルート計算

### History
- 保存した計算結果の一覧表示
- コンテキストメニューから削除

## 技術スタック

- Swift / SwiftUI
- iOS 17.0+
- Xcode 16+

## アーキテクチャ

- `Page` enum + ZStack switch によるページ切り替え（NavigationStack 不使用）
- サイドバーナビゲーション（左スワイプ / ハンバーガーボタン）
- Token-first デザインシステム（`DesignTokens`）
- `@Observable` + `UserDefaults` による History 永続化
- Shunting-yard algorithm による式評価（括弧対応）

## プロジェクト構成

```
CalcKit/
├── App/                    # エントリポイント、ルートビュー
├── DesignSystem/           # デザイントークン、色、フォント、サイドバー、共通コンポーネント
├── Core/                   # モデル、サービス、Extension
└── Features/               # 各機能画面
    ├── Home/               # 電卓
    ├── Warikan/            # ワリカン
    ├── DayCount/           # 日数計算
    ├── GoalCalc/           # 目標計算
    ├── MathTools/          # 数学ツール
    └── History/            # 履歴
```

## セットアップ

1. `CalcKit.xcodeproj` を Xcode で開く
2. Signing & Capabilities で Team を設定
3. Run (⌘R)

プロジェクト生成に [XcodeGen](https://github.com/yonaskolb/XcodeGen) を使用。`project.yml` から再生成する場合:

```sh
xcodegen generate
```

---

### ✨ App Store
- v1.2.0 2026/05/31 - 目標計算に単位入力タブ追加、Enter ボタン導入（全画面）、Localization 基盤整備
- v1.1.0 2026/05/05 - Raised keys スタイル、haptic feedback、shared components 追加、UI 統一
- v1.0.0 2026/04/27
