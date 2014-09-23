# -*- coding: utf-8 -*-
module ApplicationHelper

  def current_user
    controller.current_user
  end

  @@tags_table_all = nil
  def tags_table_all
    return @@tags_table_all if @@tags_table_all
    tags_table = "<div><b>内容标签</b><table cellpadding='0px' cellspacing='0px' class='tags'>"
    GenreTag.grouped_by_3.each do |subarray|
      tags_table << "<tr>"
      subarray.each do |tag|
        tags_table << "<td><a href='#{books_by_tag_path(tag: tag.name)}'>#{tag.cn}</a></td>"
      end
      tags_table << "</tr>"
    end
    @@tags_table_all = tags_table << "</table></div>"
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
