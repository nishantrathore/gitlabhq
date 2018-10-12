require 'securerandom'

module QA
  module Factory
    module Resource
      class MergeRequest < Factory::Base
        attr_accessor :title,
                      :description,
                      :source_branch,
                      :target_branch,
                      :assignee,
                      :milestone,
                      :labels

        attribute :source_branch

        attribute :project do
          Factory::Resource::Project.fabricate! do |resource|
            resource.name = 'project-with-merge-request'
          end
        end

        attribute :target do
          project.visit!

          Factory::Repository::ProjectPush.fabricate! do |resource|
            resource.project = project
            resource.branch_name = 'master'
            resource.remote_branch = target_branch
          end
        end

        attribute :source do
          Factory::Repository::ProjectPush.fabricate! do |resource|
            resource.project = project
            resource.branch_name = target_branch
            resource.remote_branch = source_branch
            resource.file_name = "added_file.txt"
            resource.file_content = "File Added"
          end
        end

        def initialize
          @title = 'QA test - merge request'
          @description = 'This is a test merge request'
          @source_branch = "qa-test-feature-#{SecureRandom.hex(8)}"
          @target_branch = "master"
          @assignee = nil
          @milestone = nil
          @labels = []
        end

        def fabricate!
          target
          source
          project.visit!
          Page::Project::Show.act { new_merge_request }
          Page::MergeRequest::New.perform do |page|
            page.fill_title(@title)
            page.fill_description(@description)
            page.choose_milestone(@milestone) if @milestone
            page.create_merge_request
          end
        end
      end
    end
  end
end
