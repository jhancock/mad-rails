# -*- coding: utf-8 -*-
class PublicController < ApplicationController
  def index
    @page_title = self.class.home_page_title
    @page_description = "迷蝴蝶中文电子书在线阅读网络社区，由用户共同推荐分享喜爱的 中文电子书，提供最清爽干净、简捷方便和安全的社区环境，无广告病毒烦忧。"
    @page_keywords = "电子书 在线阅读 安全 简便"
    @sort = 'recent'
    @books = Book.online_recent.page(1)
  end

  def self.home_page_title
    "迷蝴蝶 电子书 穿越时空/都市言情/仙侠修真/网游同人 在线阅读"
  end

  def upload_notice
  end

  def contact
    @page_title = "联系我们 电子书在线阅读"
    @page_description = "有任何问题，请随时联系迷蝴蝶客服人员，我们会即时提供解答"
    @page_keywords = "联系 迷蝴蝶 电子书"
  end

  def terms_of_service
    @page_title = "服务协议 电子书在线阅读"
    @page_description = "迷蝴蝶中文电子书在线阅读网站的服务协议，以约定的规则来保证 为广大用户提供高质量的服务"
    @page_keywords = "服务协议 电子书 在线阅读"
  end

  def privacy_policy
    @page_title = "隐私声明 电子书在线阅读"
    @page_description = "迷蝴蝶中文电子书在线阅读网站的隐私声明，网站确保用户提供信 息的私密性 "
    @page_keywords = "隐私声明 电子书 在线阅读"
  end
end
