# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Breadcrumbs schema markup', :aggregate_failures do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :public, namespace: user.namespace) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:subgroup) { create(:group, :public, parent: group) }
  let_it_be(:group_project) { create(:project, :public, namespace: subgroup) }

  it 'generates the breadcrumb schema for user projects' do
    visit project_url(project)

    item_list = get_schema_content

    expect(item_list.size).to eq 3
    expect(item_list[0]['name']).to eq project.namespace.name
    expect(item_list[0]['item']).to eq user_path(project.owner)

    expect(item_list[1]['name']).to eq project.name
    expect(item_list[1]['item']).to eq project_path(project)

    expect(item_list[2]['name']).to eq 'Details'
    expect(item_list[2]['item']).to eq project_path(project)
  end

  it 'generates the breadcrumb schema for group projects' do
    visit project_url(group_project)

    item_list = get_schema_content

    expect(item_list.size).to eq 4
    expect(item_list[0]['name']).to eq group.name
    expect(item_list[0]['item']).to eq group_path(group)

    expect(item_list[1]['name']).to eq subgroup.name
    expect(item_list[1]['item']).to eq group_path(subgroup)

    expect(item_list[2]['name']).to eq group_project.name
    expect(item_list[2]['item']).to eq project_path(group_project)

    expect(item_list[3]['name']).to eq 'Details'
    expect(item_list[3]['item']).to eq project_path(group_project)
  end

  it 'generates the breadcrumb schema for group' do
    visit group_url(subgroup)

    item_list = get_schema_content

    expect(item_list.size).to eq 3
    expect(item_list[0]['name']).to eq group.name
    expect(item_list[0]['item']).to eq group_path(group)

    expect(item_list[1]['name']).to eq subgroup.name
    expect(item_list[1]['item']).to eq group_path(subgroup)

    expect(item_list[2]['name']).to eq 'Details'
    expect(item_list[2]['item']).to eq group_path(subgroup)
  end

  it 'generates the breadcrumb schema for issues' do
    visit project_issues_url(project)

    item_list = get_schema_content

    expect(item_list.size).to eq 3
    expect(item_list[0]['name']).to eq project.namespace.name
    expect(item_list[0]['item']).to eq user_path(project.owner)

    expect(item_list[1]['name']).to eq project.name
    expect(item_list[1]['item']).to eq project_path(project)

    expect(item_list[2]['name']).to eq 'Issues'
    expect(item_list[2]['item']).to eq project_issues_path(project)
  end

  it 'generates the breadcrumb schema for specific issue' do
    visit project_issue_url(project, issue)

    item_list = get_schema_content

    expect(item_list.size).to eq 4
    expect(item_list[0]['name']).to eq project.namespace.name
    expect(item_list[0]['item']).to eq user_path(project.owner)

    expect(item_list[1]['name']).to eq project.name
    expect(item_list[1]['item']).to eq project_path(project)

    expect(item_list[2]['name']).to eq 'Issues'
    expect(item_list[2]['item']).to eq project_issues_path(project)

    expect(item_list[3]['name']).to eq issue.to_reference
    expect(item_list[3]['item']).to eq project_issue_path(project, issue)
  end

  def get_schema_content
    content = find('script[type="application/ld+json"]', visible: false).text(:all)

    expect(content).not_to be_nil

    Gitlab::Json.parse(content)['itemListElement']
  end
end
