# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by William T. Nelson.

require "rake"
require "rake/tasklib"

require_relative "config"
require_relative "../sus"

module Sus
	# Provides integration with Rake.
	module Rake
		# Defines a Rake task which runs the test suite in the current process.
		class TestTask < ::Rake::TaskLib
			# Initialize and define the task.
			# @parameter name [Symbol] The name of the task.
			# @yields {|task| ...} Optionally configure the task before it is defined.
			def initialize(name = :test)
				@name = name
				@paths = nil
				@verbose = false
				
				yield self if block_given?
				
				define
			end
			
			# @attribute [Symbol] The name of the task.
			attr_accessor :name
			
			# @attribute [Array(String) | Nil] Specific test paths to run, optionally with a `:line` suffix. All tests are run by default.
			attr_accessor :paths
			
			# @attribute [Boolean] Whether to output verbose information.
			attr_accessor :verbose
			
			private
			
			def define
				desc "Run tests using sus."
				task(@name) do
					run
				end
			end
			
			def run
				# Rake leaves task names in ARGV, so they must not be read as test paths:
				config = Sus::Config.load(arguments: Array(@paths).dup)
				registry = config.registry
				
				verbose = @verbose || ::Rake::FileUtilsExt.verbose_flag == true || config.verbose?
				output = verbose ? config.output : Sus::Output::Null.new
				
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
