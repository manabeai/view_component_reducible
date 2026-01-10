# Msg object enhancement (pattern match ready)

Goal:
- `Msg` を `deconstruct`/`deconstruct_keys` 付きの Struct 化にする
- `case ... in` で型安全っぽく読めるようにする

## Motivation
- `type` は実質 enum なので、パターンマッチで表現したい
- `payload` の取り扱いを明確にして読みやすくする

## Proposed API

```ruby
def reduce(state, msg)
  case msg
  in ViewComponentReducible::Msg::Object(type: "Increment")
    # ...
  in ViewComponentReducible::Msg::Object(type: "LoadUser", payload: { "id" => Integer => id })
    # ...
  end
end
```

## Struct sketch

```ruby
module ViewComponentReducible
  module Msg
    Object = Struct.new(:type, :payload, keyword_init: true) do
      def deconstruct
        [type, payload]
      end

      def deconstruct_keys(keys)
        data = { "type" => type, "payload" => payload }
        keys ? data.slice(*keys) : data
      end
    end
  end
end
```

## Integration
- `Msg.from_params` は `Msg::Object` を返す
- 既存の `Msg` (Struct) は互換性維持のため残すか要検討

## Notes
- `type` は String 前提で統一（Symbolは変換）
- `payload` は JSON 互換 Hash 前提
