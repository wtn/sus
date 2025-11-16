# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by William T. Nelson.

require "sus/rake"
require "open3"
require "rbconfig"

describe Sus::Rake::TestTask do
	with "a rake application" do
		def around
			previous = Rake.application
			Rake.application = Rake::Application.new
			
			# Rake only records descriptions when listing tasks (e.g. `rake -T`):
			record_task_metadata = Rake::TaskManager.record_task_metadata
			Rake::TaskManager.record_task_metadata = true
			
			super
		ensure
			Rake::TaskManager.record_task_metadata = record_task_metadata
			Rake.application = previous
		end
		
		it "defines a test task by default" do
			Sus::Rake::TestTask.new
			
			expect(Rake::Task[:test]).to be_a(Rake::Task)
			expect(Rake::Task[:test].comment).to be == "Run tests using sus"
		end
		
		it "can define a task with a custom name" do
			Sus::Rake::TestTask.new(:spec)
			
			expect(Rake::Task.task_defined?(:spec)).to be == true
			expect(Rake::Task.task_defined?(:test)).to be == false
		end
		
		it "can be configured with a block" do
			instance = Sus::Rake::TestTask.new do |task|
				task.paths = ["test/sus/rake.rb"]
				task.verbose = true
			end
			
			expect(instance).to have_attributes(
				name: be == :test,
				paths: be == ["test/sus/rake.rb"],
				verbose: be == true,
			)
		end
	end
	
	with "rake executable" do
		def run_rake(*arguments, env: {})
			Open3.capture3(
				{
					"RUBYOPT" => ENV["RUBYOPT"],
					"SUS_VERBOSE" => nil,
				}.merge(env),
				RbConfig.ruby,
				"-I", File.expand_path("../../lib", __dir__),
				"-S", "rake",
				*arguments,
				chdir: File.expand_path("../../fixtures/sus/rake", __dir__),
			)
		end
		
		it "fails when any test fails" do
			output, error, status = run_rake("failing")
			
			expect(status).not.to be(:success?)
			expect(error).to be(:include?, "1 passed 1 failed out of 2 total")
		end
		
		it "runs all tests as a complete run" do
			output, error, status = run_rake("test")
			
			expect(status).to be(:success?)
			expect(error).to be(:include?, "1 passed out of 1 total")
			expect(error).to be(:include?, "You should write more tests")
		end
		
		it "runs only the configured paths" do
			output, error, status = run_rake("passing")
			
			expect(status).to be(:success?)
			expect(error).to be(:include?, "1 passed out of 1 total")
		end
		
		it "ignores other task names on the command line" do
			output, error, status = run_rake("passing", "other")
			
			expect(status).to be(:success?)
			expect(error).to be(:include?, "1 passed out of 1 total")
			expect(output).to be(:include?, "other task ran")
		end
		
		it "is quiet by default" do
			output, error, status = run_rake("passing")
			
			expect(error).not.to be(:include?, "passing rake fixture")
		end
		
		it "can be verbose when configured" do
			output, error, status = run_rake("verbose")
			
			expect(status).to be(:success?)
			expect(error).to be(:include?, "passing rake fixture")
		end
		
		it "can be verbose with rake's verbose option" do
			output, error, status = run_rake("--verbose", "passing")
			
			expect(status).to be(:success?)
			expect(error).to be(:include?, "passing rake fixture")
		end
		
		it "can be verbose from the environment" do
			output, error, status = run_rake("passing", env: {"SUS_VERBOSE" => "true"})
			
			expect(status).to be(:success?)
			expect(error).to be(:include?, "passing rake fixture")
		end
	end
end
