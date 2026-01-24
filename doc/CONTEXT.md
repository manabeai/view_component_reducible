# Context

このリポジトリは ViewComponent に reducer/dispatch 方式の状態更新を載せる gem。
最小構成で「HTTPのみ」「JS最小」で状態遷移を回すのが狙い。

## 現状の仕様（重要）
- `state` DSL でフラットな state を定義する
- `reduce` は `Data` の state を受け取る
- `reduce` は `state` / `[state]` / `[state, effects...]` を返せる（必要なら `effects(state, msg)` も併用）
- `Envelope` が初期状態を生成
- `Msg` が `vcr_msg_type`/`vcr_msg_payload` を解釈
- `Runtime` が reducer 実行 → HTML をレンダリング
- `DispatchController` が `POST /vcr/dispatch` で受ける
- `vcr_partial=1` のときは対象 path の HTML だけ返す（部分更新）

## 主要API
- `ViewComponentReducible::Component`（include前提）
  - `vcr_envelope` / `vcr_state` / `vcr_state_token`
  - `vcr_dom_id(path:)`
- `ViewComponentReducible::State::Schema` + `State::DSL`
- `ViewComponentReducible::State::Envelope.initial`
- `ViewComponentReducible::Runtime#call` / `#render_target`
- `ViewComponentReducible::DispatchController#call`
- `ViewComponentReducible::Helpers`
  - `vcr_boundary(path:)`
  - `vcr_button_to(...)`
  - `vcr_dispatch_script_tag`

## ルーティング/アダプタ
- Engineで `/dispatch`
- spec/dummy は `POST /vcr/dispatch` を直接定義
- HiddenField adapter を spec/dummy で利用

## ダミーアプリ（spec/dummy/）
- `MyFormComponent` は `count`/`last_updated_at` を持つ
- `Increment/Decrement/Reset/UpdatedAt` を reducer で処理
- コンポーネント境界は自動で `data-vcr-path` を付与
- layout で `vcr_dispatch_script_tag` を挿入
- Tailwind CDN で UI をリッチ化

## 直近の設計メモ
- `.codex/06_partial_updates.md` に部分更新設計あり
- `doc/feature/state_object.md` に Stateオブジェクト案
- `doc/feature/state_debugger.md` にデバッグUI案
- `doc/tasks.md` に未解決タスク

## 既知の課題
- 部分更新のDOM差し替えは最小JSで実装済み
- テストはhelpers中心で拡充途中
