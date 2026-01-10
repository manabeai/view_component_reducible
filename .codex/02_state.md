# State model (envelope + schema DSL)

## Envelope shape
Envelope must be JSON-serializable.

```
{
  "v": 1,                       # schema version of envelope
  "root": "MyPageComponent",     # root component vcr_id
  "path": "root",               # path for the node
  "data": { ... },              # component local state
  "children": {                 # optional: nested states by key
    "root/0": { ...envelope... }
  },
  "meta": {
    "errors": { ... },          # validation errors
    "loading": false,           # optional UI flag
    "cache": { ... }            # optional (avoid large payloads)
  }
}
```

## State schema DSL (core requirement)

Goal:
- define defaults & types (lightweight)
- create state instances from hash
- dump to hash
- no heavy deps in v0

DSL example:
```rb
class MyFormComponent < ViewComponentReducible::Component
  state do
    field :name, default: ""
    field :email, default: ""
    field :page, default: 1

    meta :errors, default: {}
    meta :loading, default: false
  end
end
```

Implementation contract:
```rb
# lib/view_component_reducible/state/schema.rb
module ViewComponentReducible
  module State
    class Schema
      Field = Struct.new(:name, :default, :kind, keyword_init: true) # kind: :data or :meta

      def initialize
        @fields = []
      end

      def add_field(name, default:, kind:)
        @fields << Field.new(name:, default:, kind:)
      end

      def build(data_hash, meta_hash)
        data = {}
        meta = {}
        @fields.each do |f|
          src = (f.kind == :meta ? meta_hash : data_hash) || {}
          value = src.key?(f.name.to_s) ? src[f.name.to_s] : (src.key?(f.name) ? src[f.name] : nil)
          value = f.default.call if value.nil? && f.default.respond_to?(:call)
          value = f.default if value.nil? && !f.default.respond_to?(:call)

          if f.kind == :meta
            meta[f.name.to_s] = value
          else
            data[f.name.to_s] = value
          end
        end
        [data, meta]
      end

      def defaults
        data, meta = build({}, {})
        [data, meta]
      end
    end
  end
end
```

```rb
# lib/view_component_reducible/state/dsl.rb
module ViewComponentReducible
  module State
    module DSL
      def self.define(component_klass, &block)
        schema = Schema.new
        dsl = Builder.new(schema)
        dsl.instance_eval(&block)
        component_klass.instance_variable_set(:@vcr_state_schema, schema)

        component_klass.define_singleton_method(:vcr_state_schema) { @vcr_state_schema }
      end

      class Builder
        def initialize(schema) = (@schema = schema)
        def field(name, default:) = @schema.add_field(name, default:, kind: :data)
        def meta(name, default:)  = @schema.add_field(name, default:, kind: :meta)
      end
    end
  end
end
```

## Creating initial envelope
```rb
module ViewComponentReducible
  module State
    class Envelope
      def self.initial(root_component_klass, path: "root")
        schema = root_component_klass.vcr_state_schema
        data, meta = schema.defaults
        {
          "v" => 1,
          "root" => root_component_klass.vcr_id,
          "path" => path,
          "data" => data,
          "children" => {},
          "meta" => meta
        }
      end
    end
  end
end
```

