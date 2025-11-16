# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require 'sus'
require 'rake'
require_relative '../../lib/sus/rake'

describe Sus::Rake do
	with "default task" do
		let(:task_name) { :test }
		let(:rake_application) { Rake::Application.new }
		
		def before
			Rake.application = self.rake_application
			Sus::Rake::TestTask.new
		end
		
		def after(error = nil)
			Rake.application = nil
		end
		
		it "defines a test task" do
			expect(rake_application.tasks).to have_attributes(size: be > 0)
			expect(rake_application[task_name]).to be_a(Rake::Task)
		end
		
		it "has a description" do
			task = rake_application[task_name]
			expect(task.comment).not.to be_nil
		end
	end
	
	with "custom task name" do
		let(:task_name) { :spec }
		let(:rake_application) { Rake::Application.new }
		
		def before
			Rake.application = self.rake_application
			Sus::Rake::TestTask.new(:spec)
		end
		
		def after(error = nil)
			Rake.application = nil
		end
		
		it "can define a task with custom name" do
			expect(rake_application[task_name]).to be_a(Rake::Task)
		end
	end
	
	with "task configuration" do
		let(:rake_application) { Rake::Application.new }
		
		def before
			Rake.application = self.rake_application
		end
		
		def after(error = nil)
			Rake.application = nil
		end
		
		it "can configure test paths" do
			task_instance = nil
			Sus::Rake::TestTask.new do |t|
				task_instance = t
				t.test_paths = ["custom/test/path"]
			end
			
			expect(task_instance.test_paths).to be == ["custom/test/path"]
		end
		
		it "can configure verbose mode" do
			task_instance = nil
			Sus::Rake::TestTask.new do |t|
				task_instance = t
				t.verbose = true
			end
			
			expect(task_instance.verbose).to be == true
		end
	end
end
