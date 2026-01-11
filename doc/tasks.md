# Tasks

細かい直したいところ（メモ）

## 自動 vcr_boundary
- `ViewComponentReducible::Component` で自動ラップ対応済み

## テスト拡充
- `Runtime#render_target` の部分更新を仕様テストで担保
- `DispatchController#call` の `vcr_partial=1` 分岐をテスト
- `Helpers#vcr_dispatch_script_tag` の置換挙動（最低限DOM解析）のテスト
- dummyアプリのE2E（最小で `Increment/Decrement/Reset` が通る）を検討
