# frozen_string_literal: true

module BreadcrumbsHelper
  def add_to_breadcrumbs(text, link)
    @breadcrumbs_extra_links ||= []
    @breadcrumbs_extra_links.push({
      text: text,
      link: link
    })
  end

  def breadcrumb_title_link
    return @breadcrumb_link if @breadcrumb_link

    request.path
  end

  def breadcrumb_title(title)
    return if defined?(@breadcrumb_title)

    @breadcrumb_title = title
  end

  def breadcrumb_list_item(link)
    content_tag "li" do
      link + sprite_icon("angle-right", size: 8, css_class: "breadcrumbs-list-angle")
    end
  end

  def add_to_breadcrumb_dropdown(link, location: :before)
    @breadcrumb_dropdown_links ||= {}
    @breadcrumb_dropdown_links[location] ||= []
    @breadcrumb_dropdown_links[location] << link
  end

  def push_to_schema_breadcrumb(text, link)
    list_item = schema_list_item(text, link, schema_breadcrumb_list.size + 1)

    schema_breadcrumb_list.push(list_item)
  end

  def schema_breadcrumb_json
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      'itemListElement': build_item_list_elements
    }.to_json
  end

  private

  def schema_breadcrumb_list
    @schema_breadcrumb_list ||= []
  end

  def build_item_list_elements
    return @schema_breadcrumb_list unless @breadcrumbs_extra_links&.any?

    last_element = schema_breadcrumb_list.pop

    @breadcrumbs_extra_links.each do |el|
      push_to_schema_breadcrumb(el[:text], el[:link])
    end

    last_element['position'] = schema_breadcrumb_list.last['position'] + 1
    schema_breadcrumb_list.push(last_element)
  end

  def schema_list_item(text, link, position)
    {
      '@type' => 'ListItem',
      'position' => position,
      'name' => text,
      'item' => link
    }
  end
end
