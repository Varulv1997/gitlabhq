# frozen_string_literal: true

module QA
  RSpec.describe 'Manage', :smoke do
    describe 'Project creation' do
      it 'user creates a new project', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/429', quarantine: { issue: 'https://gitlab.com/gitlab-org/gitlab/-/issues/280585', type: :investigating, only: { subdomain: :staging } } do
        Flow::Login.sign_in

        created_project = Resource::Project.fabricate_via_browser_ui! do |project|
          project.name = 'awesome-project'
          project.description = 'create awesome project test'
        end

        expect(page).to have_content(created_project.name)
        expect(page).to have_content(
          /Project \S?awesome-project\S+ was successfully created/
        )
        expect(page).to have_content('create awesome project test')
        expect(page).to have_content('The repository for this project is empty')
      end
    end
  end
end
