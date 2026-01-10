# view_component_reducible

![sample](doc/img/sample.png)

This sample shows state transitions and partial updates powered entirely by ViewComponent.
The only thing you add in Rails is a single endpoint:

```rb
mount ViewComponentReducible::Engine, at: "/vcr"
```

Everything else stays inside ViewComponent—no extra endpoints, controllers, or JS frameworks required.

view_component_reducible brings reducer-based state transitions
to Rails ViewComponent, inspired by TEA (The Elm Architecture).

This is a server-driven, HTTP-based approach — no WebSocket required.
