# -*- coding: utf-8 -*-
module MailerHelper

  def email_header(text)
  	"<tr><td align='center' valign='top' class='mobilePadding' style='padding-top:40px; padding-right:40px; padding-bottom:0; padding-left:40px;'><table border='0' cellpadding='0' cellspacing='0' width='100%'><tr><td valign='middle' class='headerContent' style='color:#606060; font-family:Helvetica, Arial, sans-serif; font-size:15px; line-height:150%; text-align:left;'><h1 style='color:#606060 !important; font-family:Helvetica, Arial, sans-serif; font-size:26px; font-weight:bold; letter-spacing:-1px; line-height:115%; margin:0; padding:0; text-align:left;'>#{text}</h1></td></tr></table></td></tr>".html_safe
  end

  def email_button(text, url)
  	"<tr><td align='center' valign='middle' class='mobilePadding' style='padding-right:40px; padding-bottom:40px; padding-left:40px;'><table border='0' cellpadding='0' cellspacing='0' class='emailButton' style='background-color:#4BA2BD; border-collapse:separate !important; border-radius:3px;'><tr><td align='center' valign='middle' class='emailButtonContent' style='color:#FFFFFF; font-family:Helvetica, Arial, sans-serif; font-size:15px; font-weight:bold; line-height:100%; padding-top:18px; padding-right:15px; padding-bottom:15px; padding-left:15px;'><a href='#{url}' target='_blank' style='color:#FFFFFF; text-decoration:none;'>#{text}</a></td></tr></table></td></tr>".html_safe
  end

  def email_paragraph(text)
  	"<tr><td align='center' valign='top' class='bodyContent' style='color:#606060; font-family:Helvetica, Arial, sans-serif; font-size:15px; line-height:150%; padding-top:40px; padding-right:40px; padding-bottom:20px; padding-left:40px; text-align:left;'>#{text}</td></tr>".html_safe
  end

end
