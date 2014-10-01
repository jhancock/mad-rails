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
      tags_table << "</li>"
    end
    @@tags_list = tags_list << "</ul>"
  end

  @@tags_table_all_old = nil
  def tags_table_all_old
    return @@tags_table_all_old if @@tags_table_all_old
    tags_table = "<div><b>内容标签</b><table cellpadding='0px' cellspacing='0px' class='tags'>"
    GenreTag.grouped_by_3.each do |subarray|
      tags_table << "<tr>"
      subarray.each do |tag|
        tags_table << "<td><a href='#{books_by_tag_path(tag: tag.name)}'>#{tag.cn}</a></td>"
      end
      tags_table << "</tr>"
    end
    @@tags_table_all_old = tags_table << "</table></div>"
  end

  # pretty print a Mongoid document
  def doc_pp(document)
    html = ""
    document.attributes.each do | key, value |
      html << "#{key} -> #{value} <br />"
    end
    html
  end

end
