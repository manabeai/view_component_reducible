# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @component = CounterComponent.new
  end
end
