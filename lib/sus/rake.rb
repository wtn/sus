# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require 'rake'
require 'rake/tasklib'

require_relative '../sus'
require_relative 'config'
require_relative 'registry'
require_relative 'filter'
require_relative 'assertions'
require_relative 'output'
require_relative 'output/null'

module Sus
	module Rake
		class TestTask < ::Rake::TaskLib
			attr_accessor :name, :test_paths, :verbose
			
			def initialize(name = :test)
				@name = name
				@test_paths = nil
				@verbose = false
				
				yield self if block_given?
				
				define_task
			end
			
			private
			
			def define_task
				task = ::Rake::Task.define_task(@name) do
					run_tests
				end
				task.add_description "Run Sus tests"
			end
			
			def run_tests
				config = Sus::Config.load
				
				if @test_paths
					registry = Sus::Filter.new(config.make_registry)
					@test_paths.each do |path|
						registry.load(path)
					end
				else
					registry = config.registry
				end
				
				if @verbose
					output = config.output
					verbose = true
				else
					output = Sus::Output::Null.new
					verbose = false
				end
				
				assertions = Sus::Assertions.default(output: output, verbose: verbose)
				
				config.before_tests(assertions)
				registry.call(assertions)
				config.after_tests(assertions)
				
				unless assertions.passed?
					abort "Tests failed!"
				end
			end
		end
	end
end
