# Tasks

細かい直したいところ（メモ）

## 自動 vcr_boundary
- コンポーネント境界は手書きではなく自動付与にしたい
- 例: `ViewComponentReducible::Component` が `#call` の出力をラップ
- 既存のテンプレに影響を出さない設計が必要
- `data-vcr-path` と `data-vcr-root` の付与を標準化

## テスト拡充
- `Runtime#render_target` の部分更新を仕様テストで担保
- `DispatchController#call` の `vcr_partial=1` 分岐をテスト
- `Helpers#vcr_dispatch_script_tag` の置換挙動（最低限DOM解析）のテスト
- dummyアプリのE2E（最小で `Increment/Decrement/Reset` が通る）を検討
