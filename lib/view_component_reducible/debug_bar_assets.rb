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
      #vcr-debug-bar .vcr-debug-payload {
        color: #cbd5f5;
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        word-break: break-all;
        margin-bottom: 6px;
      }
      #vcr-debug-bar .vcr-debug-payload button {
        margin-left: 8px;
        font-size: 9px;
        letter-spacing: 0.12em;
      }
      #vcr-debug-bar .vcr-debug-chain {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 6px;
        margin-bottom: 6px;
      }
      #vcr-debug-bar .vcr-debug-chain-node {
        background: #0f172a;
        border: 1px solid #334155;
        border-radius: 999px;
        padding: 2px 8px;
        font-size: 10px;
        font-weight: 700;
        color: #f8fafc;
        position: relative;
      }
      #vcr-debug-bar .vcr-debug-chain-node-trigger {
        border-color: #38bdf8;
        color: #7dd3fc;
      }
      #vcr-debug-bar .vcr-debug-chain-node-effect {
        border-color: #a3e635;
        color: #bef264;
      }
      #vcr-debug-bar .vcr-debug-chain-arrow {
        color: #38bdf8;
        font-size: 10px;
        letter-spacing: 0.1em;
      }
      #vcr-debug-bar .vcr-debug-chain-tooltip {
        position: absolute;
        top: 120%;
        left: 0;
        min-width: 200px;
        max-width: 260px;
        padding: 6px 8px;
        border-radius: 8px;
        background: #111827;
        border: 1px solid #334155;
        color: #e2e8f0;
        font-size: 10px;
        line-height: 1.4;
        opacity: 0;
        transform: translateY(4px);
        transition: opacity 120ms ease, transform 120ms ease;
        pointer-events: none;
        z-index: 10;
      }
      #vcr-debug-bar .vcr-debug-chain-tooltip-title {
        font-weight: 700;
        color: #f8fafc;
        margin-bottom: 4px;
      }
      #vcr-debug-bar .vcr-debug-chain-tooltip-row {
        display: flex;
        gap: 6px;
        align-items: baseline;
        margin-top: 2px;
      }
      #vcr-debug-bar .vcr-debug-chain-tooltip-key {
        color: #94a3b8;
        min-width: 72px;
      }
      #vcr-debug-bar .vcr-debug-chain-tooltip-value {
        color: #e2e8f0;
        word-break: break-word;
      }
      #vcr-debug-bar .vcr-debug-chain-tooltip-list {
        margin-top: 4px;
        padding-left: 12px;
      }
      #vcr-debug-bar .vcr-debug-chain-tooltip-list li {
        margin-top: 2px;
      }
      #vcr-debug-bar .vcr-debug-chain-node:hover .vcr-debug-chain-tooltip {
        opacity: 1;
        transform: translateY(0);
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
      #vcr-debug-bar .vcr-debug-change.vcr-debug-change-highlight {
        outline: 1px solid #38bdf8;
        outline-offset: 2px;
        border-radius: 6px;
        background: rgba(56, 189, 248, 0.08);
        padding: 2px 4px;
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
        function cssEscape(value) {
          if (window.CSS && typeof window.CSS.escape === "function") {
            return window.CSS.escape(value);
          }
          return value.replace(/["\\\\]/g, "\\\\$&");
        }
        function highlightPath(path, active) {
          if (!path) return;
          var selector = '[data-vcr-path="' + cssEscape(path) + '"]';
          var nodes = document.querySelectorAll(selector);
          nodes.forEach(function(node) {
            if (active) {
              node.classList.add("vcr-debug-highlight");
            } else {
              node.classList.remove("vcr-debug-highlight");
            }
          });
        }
        function highlightChange(entry, key, active) {
          if (!entry || !key) return;
          var rows = entry.querySelectorAll('[data-vcr-debug-change-key="' + key + '"]');
          rows.forEach(function(row) {
            if (active) {
              row.classList.add("vcr-debug-change-highlight");
            } else {
              row.classList.remove("vcr-debug-change-highlight");
            }
          });
        }
        function bindHover(selector, onHover) {
          bar.addEventListener("mouseover", function(event) {
            var target = event.target;
            if (!(target instanceof HTMLElement)) return;
            if (!target.matches(selector)) return;
            onHover(target, true);
          });
          bar.addEventListener("mouseout", function(event) {
            var target = event.target;
            if (!(target instanceof HTMLElement)) return;
            if (!target.matches(selector)) return;
            onHover(target, false);
          });
        }
        function positionChainTooltip(node) {
          var tooltip = node.querySelector(".vcr-debug-chain-tooltip");
          if (!tooltip) return;
          tooltip.style.left = "";
          tooltip.style.right = "";
          tooltip.style.top = "";
          tooltip.style.bottom = "";
          var rect = tooltip.getBoundingClientRect();
          var gutter = 8;
          if (rect.right > window.innerWidth - gutter) {
            tooltip.style.left = "auto";
            tooltip.style.right = "0";
          }
          if (rect.left < gutter) {
            tooltip.style.left = "0";
            tooltip.style.right = "auto";
          }
          if (rect.bottom > window.innerHeight - gutter) {
            tooltip.style.top = "auto";
            tooltip.style.bottom = "120%";
          }
        }
        bindHover("[data-vcr-debug-source]", function(target, active) {
          highlightSource(target.getAttribute("data-vcr-debug-source-id"), active);
        });
        bindHover("[data-vcr-debug-path]", function(target, active) {
          highlightPath(target.getAttribute("data-vcr-debug-path"), active);
        });
        bindHover("[data-vcr-debug-key]", function(target, active) {
          highlightChange(target.closest("[data-vcr-debug-entry]"), target.getAttribute("data-vcr-debug-key"), active);
        });
        bindHover(".vcr-debug-chain-node", function(target, active) {
          if (active) {
            positionChainTooltip(target);
          }
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
        function truncateText(text, limit) {
          if (text.length <= limit) return text;
          return text.slice(0, limit) + "...";
        }
        function buildChainTooltip(stepDetail, fallbackType) {
          var wrapper = document.createElement("div");
          var eventType = stepDetail.msg_type || fallbackType || "unknown";
          var title = document.createElement("div");
          title.className = "vcr-debug-chain-tooltip-title";
          title.textContent = "event: " + eventType;
          wrapper.appendChild(title);
          function addRow(key, value) {
            var row = document.createElement("div");
            row.className = "vcr-debug-chain-tooltip-row";
            var keyNode = document.createElement("span");
            keyNode.className = "vcr-debug-chain-tooltip-key";
            keyNode.textContent = key;
            var valueNode = document.createElement("span");
            valueNode.className = "vcr-debug-chain-tooltip-value";
            valueNode.textContent = value;
            row.appendChild(keyNode);
            row.appendChild(valueNode);
            wrapper.appendChild(row);
          }
          if (stepDetail.payload !== undefined) {
            addRow("payload", truncateText(formatValue(stepDetail.payload), 140));
          }
          var keys = Array.isArray(stepDetail.changed_keys) ? stepDetail.changed_keys : [];
          addRow("changed", keys.length ? String(keys.length) : "(none)");
          if (keys.length) {
            var changesList = document.createElement("ul");
            changesList.className = "vcr-debug-chain-tooltip-list";
            var changes = stepDetail.changes || {};
            keys.slice(0, 3).forEach(function(key) {
              var change = changes[key];
              if (!change) return;
              var item = document.createElement("li");
              item.textContent = key + ": " + formatValue(change.from) + " -> " + formatValue(change.to);
              changesList.appendChild(item);
            });
            if (keys.length > 3) {
              var moreItem = document.createElement("li");
              moreItem.textContent = "+" + (keys.length - 3) + " more";
              changesList.appendChild(moreItem);
            }
            wrapper.appendChild(changesList);
          }
          if (stepDetail.state !== undefined) {
            var stateKeys = Object.keys(stepDetail.state || {});
            addRow("state keys", stateKeys.length ? String(stateKeys.length) : "0");
            if (stateKeys.length) {
              var stateList = document.createElement("ul");
              stateList.className = "vcr-debug-chain-tooltip-list";
              stateKeys.slice(0, 3).forEach(function(key) {
                var item = document.createElement("li");
                item.textContent = key + ": " + truncateText(formatValue(stepDetail.state[key]), 80);
                stateList.appendChild(item);
              });
              if (stateKeys.length > 3) {
                var moreState = document.createElement("li");
                moreState.textContent = "+" + (stateKeys.length - 3) + " more";
                stateList.appendChild(moreState);
              }
              wrapper.appendChild(stateList);
            }
          }
          return wrapper;
        }
        function buildChangeRow(key, change, unchangedValue) {
          var row = document.createElement("div");
          row.className = "vcr-debug-change";
          row.setAttribute("data-vcr-debug-change-key", key);
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
          } else if (unchangedValue !== undefined) {
            var value = document.createElement("span");
            value.className = "vcr-debug-unchanged";
            value.textContent = formatValue(unchangedValue);
            row.appendChild(value);
          }
          return row;
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
          path.setAttribute("data-vcr-debug-path", detail.path || "");
          entry.appendChild(path);
          if (detail.payload !== undefined) {
            var payload = document.createElement("div");
            payload.className = "vcr-debug-payload";
            var payloadLabel = document.createElement("span");
            payloadLabel.textContent = "payload: ";
            payload.appendChild(payloadLabel);
            var payloadText = document.createElement("span");
            payloadText.className = "vcr-debug-payload-text";
            var formattedPayload = formatValue(detail.payload);
            var limit = 160;
            if (formattedPayload.length > limit) {
              var truncated = truncateText(formattedPayload, limit);
              payloadText.textContent = truncated;
              var togglePayload = document.createElement("button");
              togglePayload.type = "button";
              togglePayload.className = "vcr-debug-payload-toggle";
              togglePayload.setAttribute("data-vcr-debug-payload-toggle", "true");
              togglePayload.setAttribute("aria-expanded", "false");
              togglePayload.textContent = "Expand";
              togglePayload.addEventListener("click", function() {
                var expanded = togglePayload.getAttribute("aria-expanded") === "true";
                if (expanded) {
                  payloadText.textContent = truncated;
                  togglePayload.textContent = "Expand";
                  togglePayload.setAttribute("aria-expanded", "false");
                } else {
                  payloadText.textContent = formattedPayload;
                  togglePayload.textContent = "Collapse";
                  togglePayload.setAttribute("aria-expanded", "true");
                }
              });
              payload.appendChild(payloadText);
              payload.appendChild(togglePayload);
            } else {
              payloadText.textContent = formattedPayload;
              payload.appendChild(payloadText);
            }
            entry.appendChild(payload);
          }
          if (Array.isArray(detail.chain) && detail.chain.length > 1) {
            var chainLabel = document.createElement("div");
            chainLabel.className = "vcr-debug-meta";
            chainLabel.textContent = "chain: " + detail.chain.join(" -> ");
            entry.appendChild(chainLabel);
            var chainGraph = document.createElement("div");
            chainGraph.className = "vcr-debug-chain";
            var stepDetails = Array.isArray(detail.chain_steps) ? detail.chain_steps : [];
            detail.chain.forEach(function(step, index) {
              var node = document.createElement("span");
              node.className = "vcr-debug-chain-node";
              if (index === 0) {
                node.classList.add("vcr-debug-chain-node-trigger");
              } else {
                node.classList.add("vcr-debug-chain-node-effect");
              }
              node.textContent = step;
              var tooltip = document.createElement("div");
              tooltip.className = "vcr-debug-chain-tooltip";
              var tooltipContent = buildChainTooltip(stepDetails[index] || {}, step);
              tooltip.appendChild(tooltipContent);
              node.appendChild(tooltip);
              chainGraph.appendChild(node);
              if (index < detail.chain.length - 1) {
                var arrow = document.createElement("span");
                arrow.className = "vcr-debug-chain-arrow";
                arrow.textContent = "->";
                chainGraph.appendChild(arrow);
              }
            });
            entry.appendChild(chainGraph);
          }
          var keys = Array.isArray(detail.changed_keys) ? detail.changed_keys : [];
          if (keys.length) {
            var keyWrap = document.createElement("div");
            keys.forEach(function(key) {
              var badge = document.createElement("span");
              badge.className = "vcr-debug-key";
              badge.textContent = "changed: " + key;
              badge.setAttribute("data-vcr-debug-key", key);
              keyWrap.appendChild(badge);
            });
            entry.appendChild(keyWrap);
          }
          if (showAll && detail.state) {
            var stateKeys = Object.keys(detail.state);
            stateKeys.forEach(function(key) {
              var change = detail.changes ? detail.changes[key] : null;
              entry.appendChild(buildChangeRow(key, change, detail.state[key]));
            });
            return;
          }
          var changes = detail.changes || {};
          Object.keys(changes).forEach(function(key) {
            var change = changes[key] || {};
            entry.appendChild(buildChangeRow(key, change));
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
