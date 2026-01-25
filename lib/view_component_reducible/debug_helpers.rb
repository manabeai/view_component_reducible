# frozen_string_literal: true

module ViewComponentReducible
  # Debug UI helpers for VCR dispatch events.
  module DebugHelpers
    # Render the debug bar that listens for VCR dispatch events.
    # @return [String]
    def vcr_debug_bar_tag
      bar = content_tag(:aside, id: 'vcr-debug-bar', data: { vcr_debug_bar: true }) do
        safe_join(
          [
            content_tag(:div, class: 'vcr-debug-header') do
              safe_join(
                [
                  content_tag(:span, 'VCR Debug', class: 'vcr-debug-title-text'),
                  content_tag(:label, class: 'vcr-debug-toggle') do
                    safe_join(
                      [
                        tag.input(type: 'checkbox', data: { vcr_debug_toggle: true }),
                        content_tag(:span, 'Show all', class: 'vcr-debug-toggle-text')
                      ]
                    )
                  end,
                  content_tag(
                    :button,
                    'Hide',
                    type: 'button',
                    class: 'vcr-debug-collapse',
                    data: { vcr_debug_collapse: true }
                  )
                ]
              )
            end,
            content_tag(:div, class: 'vcr-debug-log', data: { vcr_debug_log: true }) do
              content_tag(:div, 'No events yet', class: 'vcr-debug-empty', data: { vcr_debug_empty: true })
            end,
            content_tag(:div, class: 'vcr-debug-footer') do
              content_tag(:button, 'Clear History', type: 'button', data: { vcr_debug_clear: true })
            end
          ]
        )
      end

      safe_join(
        [
          content_tag(:style, DebugBarAssets::STYLES),
          bar,
          content_tag(:script, DebugBarAssets::SCRIPT.html_safe)
        ]
      )
    end
  end
end
