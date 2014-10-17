# -*- coding: utf-8 -*-
module ApplicationHelper

  def current_user
    controller.current_user
  end

  @@tags_list = nil
  def tags_list
    return @@tags_list if @@tags_list
    tags_list = "<ul>"
    GenreTag.all.each do |tag|
      tags_list << "<li>"
      tags_list << "<a href='#{books_by_tag_path(tag: tag.name)}'>#{tag.cn}</a>"
      tags_list << "</li>"
    end
    @@tags_list = tags_list << "</ul>"
  end

  # pretty print a Mongoid document
  def doc_pp(document)
    html = ""
    document.attributes.each do | key, value |
      html << "#{key} -> #{value} <br />"
    end
    html
  end

  #TODO add flash messages inside form-model div
  def my_form_for(record_or_name_or_array, *args, &block)
    options = args.extract_options!
    content_tag(:div, :class => "form-model") do
      form_for(record_or_name_or_array, *(args << options.merge(builder: MyFormBuilder, :html => {:class => "form"})), &block)
    end
  end

end
