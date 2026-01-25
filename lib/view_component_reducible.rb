# frozen_string_literal: true

require_relative 'view_component_reducible/version'
require_relative 'view_component_reducible/configuration'
require_relative 'view_component_reducible/msg'
require_relative 'view_component_reducible/adapter/base'
require_relative 'view_component_reducible/adapter/hidden_field'
require_relative 'view_component_reducible/adapter/session'
require_relative 'view_component_reducible/adapter/redis'
require_relative 'view_component_reducible/debug_bar_assets'
require_relative 'view_component_reducible/debug_helpers'
require_relative 'view_component_reducible/dispatch_helpers'
require_relative 'view_component_reducible/helpers'
require_relative 'view_component_reducible/state/schema'
require_relative 'view_component_reducible/state/dsl'
require_relative 'view_component_reducible/state/envelope'
require_relative 'view_component_reducible/component'
require_relative 'view_component_reducible/runtime'
require_relative 'view_component_reducible/dispatch'
require_relative 'view_component_reducible/dispatch_controller'
require_relative 'view_component_reducible/engine'
require_relative 'view_component_reducible/railtie'

module ViewComponentReducible
  class Error < StandardError; end
  class NoMatchingPatternError < Error; end

  # @return [Hash{String=>Class}]
  def self.registry
    @registry ||= {}
  end

  # @param component_klass [Class]
  # @return [void]
  def self.register(component_klass)
    registry[component_klass.vcr_id] = component_klass
  end

  # @return [ViewComponentReducible::Configuration]
  def self.config
    @config ||= Configuration.new
  end

  # @yield [ViewComponentReducible::Configuration]
  # @return [void]
  def self.configure
    yield config
  end
end
