require "fileutils"
require_relative "definitions/deployment"
require_relative "definitions/partition"

module Batch
  class Runner

    def initialize(context)
      @context = context
    end

    def deploy(partition)
    end

    def teardown(partition)
    end

  end
end