# Msg and adapters

## Msg
Msg is a small JSON payload.

```rb
# lib/view_component_reducible/msg.rb
module ViewComponentReducible
  Msg = Struct.new(:type, :payload, keyword_init: true) do
    def self.from_params(params)
      type = params.fetch("vcr_msg_type")
      payload_json = params["vcr_msg_payload"]
      payload = payload_json && payload_json != "" ? JSON.parse(payload_json) : {}
      new(type:, payload:)
    end
  end
end
```

Client sends:
- `vcr_msg_type=ClickedSave`
- `vcr_msg_payload={"id":123}`
- also: `vcr_target_path=root/0/2` (where to deliver)

## Adapter interface
```rb
# lib/view_component_reducible/adapter/base.rb
module ViewComponentReducible
  module Adapter
    class Base
      def initialize(secret:) = (@secret = secret)

      # encode envelope -> string to send to client OR store key
      def dump(envelope, request:) = raise NotImplementedError

      # load envelope from request
      def load(request:) = raise NotImplementedError
    end
  end
end
```

## Configuration
Default adapter is `Session`. Set a different adapter or secret via configuration.

```rb
# config/initializers/view_component_reducible.rb (host app)
ViewComponentReducible.configure do |config|
  config.adapter = ViewComponentReducible::Adapter::Session
  config.secret = Rails.application.secret_key_base
end
```

You can override the adapter per controller:

```rb
class ViewComponentReducible::DispatchController
  vcr_adapter ViewComponentReducible::Adapter::HiddenField
end
```

## HiddenField adapter
Use ActiveSupport::MessageVerifier (signing). No encryption in v0.1.

```rb
# lib/view_component_reducible/adapter/hidden_field.rb
require "active_support"
require "active_support/message_verifier"

module ViewComponentReducible
  module Adapter
    class HiddenField < Base
      def verifier
        @verifier ||= ActiveSupport::MessageVerifier.new(@secret, digest: "SHA256", serializer: JSON)
      end

      def dump(envelope, request:)
        verifier.generate(envelope)
      end

      def load(request:)
        signed = request.params.fetch("vcr_state")
        verifier.verify(signed)
      end
    end
  end
end
```

## Session adapter
Stores envelope in session under a key; client carries the key (signed).

```rb
# lib/view_component_reducible/adapter/session.rb
module ViewComponentReducible
  module Adapter
    class Session < Base
      def verifier
        @verifier ||= ActiveSupport::MessageVerifier.new(@secret, digest: "SHA256", serializer: JSON)
      end

      def dump(envelope, request:)
        key = SecureRandom.hex(16)
        request.session["vcr:#{key}"] = envelope
        verifier.generate({ "k" => key })
      end

      def load(request:)
        signed = request.params.fetch("vcr_state")
        payload = verifier.verify(signed)
        key = payload.fetch("k")
        request.session.fetch("vcr:#{key}")
      end
    end
  end
end
```
