# -*- coding: utf-8 -*-
module ApplicationHelper

  def current_user
    controller.current_user
  end

  def canonical_link_tag
    if controller.canonical_path
      href = "#{request.host+controller.canonical_path}"
    else
      href = "#{request.host+request.fullpath}"
    end
    "<link rel='canonical' href='https://#{href}' />".html_safe
  end

  @@tags_list = nil
  def tags_list
    return @@tags_list if @@tags_list
    tags_list = "<ul class='nav-flow'>"
    GenreTag.all.each do |tag|
      tags_list << "<li>"
      tags_list << "<a href='#{books_by_tag_path(tag: tag.name)}'>#{tag.cn}</a>"
      tags_list << "</li>"
    end
    @@tags_list = (tags_list << "</ul>").html_safe
  end

  def account_menu
    remind = false
    list = "<ul class='nav-line'>"
    # list_item is a 2 or 3 element array.  
    # list_item[0] - path; anchor href
    # list_item[1] - string; anchor contents
    # list_item[3] - :em; if this element exists and is :em, the anchor is emphasized
    controller.account_list.each do |list_item|
      list << "<li>"
      list << "<a href='#{list_item[0]}'>#{list_item[1]}"
      if ((list_item.size == 3) and (list_item[2] == :em))
        remind = true
        list << "<em class='remind'>*</em>"
      end
      list << "</a></li>"
    end
    list << "</ul>"
    menu = "<li><a href='#'>账户"
    menu << "<em class='remind'>*</em>" if remind
    menu << "</a>"
    menu << list
    menu << "</li>"
    menu.html_safe
  end

  def bookmarks_list
    list = "<ul class='nav-line'>"
    # list_item is a 2 element array.
    # list_item[0] - path; anchor href
    # list_item[1] - string; anchor contents
    controller.bookmarks_list.each do |list_item|
      list << "<li><a href='#{list_item[0]}'>#{list_item[1]}</a></li>"
    end
    list << "</ul>"
    list.html_safe
  end

  def sort_cn(sort)
    controller.sort_cn(sort)
  end

  # pretty print a Mongoid document
  def doc_pp(document)
    html = ""
    document.attributes.each do | key, value |
      html << "#{key} -> #{value} <br />"
    end
    html
  end

  def my_form_for(record_or_name_or_array, *args, &block)
    flash_content = ""
    options = args.extract_options!
    content_tag(:div, :class => "form-model") do
      flash.each do |name, msg|
        if name == "form_error"
          flash_content << content_tag(:div, msg, class: "error")
        end
        if name == "form_notice"
          flash_content << content_tag(:div, msg, class: "notice")
        end
      end
      flash_content.html_safe + form_for(record_or_name_or_array, *(args << options.merge(builder: MyFormBuilder, :html => {:class => "form"})), &block)
    end
  end

end
