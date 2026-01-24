# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module ViewComponentReducible
  # Shared CSS/JS assets for the debug bar.
  module DebugBarAssets
    STYLES = <<~CSS
      #vcr-debug-bar {
        position: fixed;
        top: 0;
        right: 0;
        width: 416px;
        height: 100vh;
        background: #0f172a;
        color: #e2e8f0;
        border-left: 1px solid #1e293b;
        font-family: ui-sans-serif, system-ui, -apple-system, sans-serif;
        z-index: 2147483647;
        display: flex;
        flex-direction: column;
      }
      #vcr-debug-bar .vcr-debug-header {
        padding: 12px 16px;
        border-bottom: 1px solid #1e293b;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
      }
      #vcr-debug-bar .vcr-debug-title-text {
        font-size: 11px;
        letter-spacing: 0.2em;
        text-transform: uppercase;
        color: #f8fafc;
        font-weight: 700;
      }
      #vcr-debug-bar .vcr-debug-toggle {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        color: #94a3b8;
        font-size: 10px;
        letter-spacing: 0.08em;
        text-transform: uppercase;
      }
      #vcr-debug-bar .vcr-debug-toggle input {
        accent-color: #38bdf8;
      }
      #vcr-debug-bar .vcr-debug-source {
        color: #f8fafc;
        cursor: pointer;
        padding: 2px 8px;
        border-radius: 999px;
        background: #0f172a;
        border: 1px solid #334155;
        font-weight: 700;
        letter-spacing: 0.08em;
      }
      #vcr-debug-bar .vcr-debug-source:hover {
        text-decoration: none;
        border-color: #f87171;
      }
      #vcr-debug-bar .vcr-debug-log {
        flex: 1;
        overflow-y: auto;
        padding: 12px;
        display: flex;
        flex-direction: column;
        gap: 10px;
      }
      #vcr-debug-bar .vcr-debug-empty {
        color: #64748b;
        font-size: 12px;
        text-align: center;
        padding: 20px 0;
      }
      #vcr-debug-bar .vcr-debug-entry {
        background: #1e293b;
        border: 1px solid #334155;
        border-radius: 10px;
        padding: 10px 12px;
        box-shadow: 0 4px 10px rgba(15, 23, 42, 0.35);
        font-size: 11px;
      }
      #vcr-debug-bar .vcr-debug-row {
        display: flex;
        justify-content: space-between;
        align-items: baseline;
        gap: 8px;
        margin-bottom: 6px;
      }
      #vcr-debug-bar .vcr-debug-title {
        font-weight: 700;
        color: #ffffff;
        font-size: 12px;
      }
      #vcr-debug-bar .vcr-debug-meta {
        color: #94a3b8;
        font-size: 10px;
      }
      #vcr-debug-bar .vcr-debug-path {
        color: #94a3b8;
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        word-break: break-all;
        margin-bottom: 6px;
      }
      #vcr-debug-bar .vcr-debug-key {
        display: inline-flex;
        border: 1px solid #334155;
        border-radius: 999px;
        padding: 2px 8px;
        font-size: 10px;
        margin: 0 4px 4px 0;
        color: #7dd3fc;
      }
      #vcr-debug-bar .vcr-debug-change {
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        color: #e2e8f0;
        margin-top: 4px;
      }
      #vcr-debug-bar .vcr-debug-unchanged {
        color: #ffffff;
      }
      .vcr-debug-highlight {
        outline: 2px dashed #f87171;
        outline-offset: 2px;
      }
      #vcr-debug-bar .vcr-debug-change .vcr-debug-from,
      #vcr-debug-bar .vcr-debug-change .vcr-debug-to {
        color: #f87171;
        font-weight: 700;
      }
      #vcr-debug-bar .vcr-debug-change .vcr-debug-to {
        color: #a3e635;
      }
      #vcr-debug-bar .vcr-debug-footer {
        border-top: 1px solid #1e293b;
        padding: 10px 16px;
        background: #111827;
      }
      #vcr-debug-bar button {
        background: transparent;
        border: 0;
        color: #94a3b8;
        font-size: 10px;
        letter-spacing: 0.2em;
        text-transform: uppercase;
        cursor: pointer;
      }
      #vcr-debug-bar button:hover {
        color: #ffffff;
      }
      @media (max-width: 960px) {
        #vcr-debug-bar {
          display: none;
        }
      }
    CSS

    SCRIPT = <<~JS
      (function() {
        if (window.__vcrDebugBarInstalled) return;
        window.__vcrDebugBarInstalled = true;
        window.__vcrDebugEnabled = true;
        var bar = document.querySelector("[data-vcr-debug-bar]");
        if (!bar) return;
        var log = bar.querySelector("[data-vcr-debug-log]");
        var empty = bar.querySelector("[data-vcr-debug-empty]");
        var clear = bar.querySelector("[data-vcr-debug-clear]");
        var toggle = bar.querySelector("[data-vcr-debug-toggle]");
        var showAll = false;
        function highlightSource(sourceId, active) {
          if (!sourceId) return;
          var nodes = document.querySelectorAll('[data-vcr-source-id="' + sourceId + '"]');
          nodes.forEach(function(node) {
            if (active) {
              node.classList.add("vcr-debug-highlight");
            } else {
              node.classList.remove("vcr-debug-highlight");
            }
          });
        }
        bar.addEventListener("mouseover", function(event) {
          var target = event.target;
          if (!(target instanceof HTMLElement)) return;
          if (!target.matches("[data-vcr-debug-source]")) return;
          highlightSource(target.getAttribute("data-vcr-debug-source-id"), true);
        });
        bar.addEventListener("mouseout", function(event) {
          var target = event.target;
          if (!(target instanceof HTMLElement)) return;
          if (!target.matches("[data-vcr-debug-source]")) return;
          highlightSource(target.getAttribute("data-vcr-debug-source-id"), false);
        });
        if (toggle) {
          toggle.addEventListener("change", function(event) {
            showAll = event.target.checked;
            if (log) {
              log.querySelectorAll("[data-vcr-debug-entry]").forEach(function(entry) {
                var raw = entry.getAttribute("data-vcr-detail");
                if (!raw) return;
                try {
                  renderEntry(entry, JSON.parse(raw), showAll);
                } catch (e) {
                  return;
                }
              });
            }
          });
        }
        if (clear) {
          clear.addEventListener("click", function() {
            if (log) {
              log.innerHTML = "";
              var placeholder = document.createElement("div");
              placeholder.className = "vcr-debug-empty";
              placeholder.setAttribute("data-vcr-debug-empty", "true");
              placeholder.textContent = "History cleared";
              log.appendChild(placeholder);
              empty = placeholder;
            }
          });
        }
        function formatValue(value) {
          if (value === null) return "null";
          if (value === undefined) return "undefined";
          if (typeof value === "string") return JSON.stringify(value);
          try {
            return JSON.stringify(value);
          } catch (e) {
            return String(value);
          }
        }
        function renderEntry(entry, detail, showAll) {
          entry.innerHTML = "";
          var header = document.createElement("div");
          header.className = "vcr-debug-row";
          var title = document.createElement("div");
          title.className = "vcr-debug-title";
          title.textContent = "event: " + (detail.event_type || "unknown");
          var meta = document.createElement("div");
          meta.className = "vcr-debug-meta";
          if (detail.source) {
            meta.appendChild(document.createTextNode("from: "));
            var source = document.createElement("span");
            source.className = "vcr-debug-source";
            source.setAttribute("data-vcr-debug-source", detail.source);
            if (detail.source_id) {
              source.setAttribute("data-vcr-debug-source-id", detail.source_id);
            }
            source.textContent = detail.source;
            meta.appendChild(source);
          }
          header.appendChild(title);
          header.appendChild(meta);
          entry.appendChild(header);
          var path = document.createElement("div");
          path.className = "vcr-debug-path";
          path.textContent = "path: " + (detail.path || "-");
          entry.appendChild(path);
          var keys = Array.isArray(detail.changed_keys) ? detail.changed_keys : [];
          if (keys.length) {
            var keyWrap = document.createElement("div");
            keys.forEach(function(key) {
              var badge = document.createElement("span");
              badge.className = "vcr-debug-key";
              badge.textContent = "changed: " + key;
              keyWrap.appendChild(badge);
            });
            entry.appendChild(keyWrap);
          }
          if (showAll && detail.state) {
            var stateKeys = Object.keys(detail.state);
            stateKeys.forEach(function(key) {
              var change = detail.changes ? detail.changes[key] : null;
              var row = document.createElement("div");
              row.className = "vcr-debug-change";
              row.appendChild(document.createTextNode(key + ": "));
              if (change) {
                var from = document.createElement("span");
                from.className = "vcr-debug-from";
                from.textContent = formatValue(change.from);
                var arrow = document.createTextNode(" -> ");
                var to = document.createElement("span");
                to.className = "vcr-debug-to";
                to.textContent = formatValue(change.to);
                row.appendChild(from);
                row.appendChild(arrow);
                row.appendChild(to);
              } else {
                var value = document.createElement("span");
                value.className = "vcr-debug-unchanged";
                value.textContent = formatValue(detail.state[key]);
                row.appendChild(value);
              }
              entry.appendChild(row);
            });
            return;
          }
          var changes = detail.changes || {};
          Object.keys(changes).forEach(function(key) {
            var change = changes[key] || {};
            var row = document.createElement("div");
            row.className = "vcr-debug-change";
            row.appendChild(document.createTextNode(key + ": "));
            var from = document.createElement("span");
            from.className = "vcr-debug-from";
            from.textContent = formatValue(change.from);
            var arrow = document.createTextNode(" -> ");
            var to = document.createElement("span");
            to.className = "vcr-debug-to";
            to.textContent = formatValue(change.to);
            row.appendChild(from);
            row.appendChild(arrow);
            row.appendChild(to);
            entry.appendChild(row);
          });
        }
        function addEntry(detail) {
          if (!log) return;
          if (empty) {
            empty.remove();
            empty = null;
          }
          var entry = document.createElement("div");
          entry.className = "vcr-debug-entry";
          entry.setAttribute("data-vcr-debug-entry", "true");
          entry.setAttribute("data-vcr-detail", JSON.stringify(detail));
          renderEntry(entry, detail, showAll);
          log.prepend(entry);
          var maxEntries = 100;
          while (log.children.length > maxEntries) {
            log.removeChild(log.lastElementChild);
          }
        }
        window.addEventListener("vcr:debug", function(event) {
          addEntry(event.detail || {});
        });
      })();
    JS
  end
end
# rubocop:enable Metrics/ModuleLength
