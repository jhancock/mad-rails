# -*- coding: utf-8 -*-
require 'mandrill'

class MandrillDelivery
  attr_accessor :message

  def initialize(mail)
  end

  def deliver!(mail)
    build_meta_mandrill(mail)
    send_mandrill(mail)
  end

#Message stuff

  def build_meta_mandrill(mail)
    #build Mandrill message hash
    @message = {
      :from_name=> "迷蝴蝶 - mihudie",
      :from_email=>"support@mihudie.com",
      :subject=> "#{mail['subject']}",
      :to=>[
            {
              :email=> "#{mail['to']}",
              :name=> "#{mail['to']}" # don't know user's name
            }
           ],
      :auto_text => true,
      :global_merge_vars => [
                             {
                               :name => "LISTCOMPANY",
                               :content => "Mihudie LLC"
                             }
                            ],
      :tags => ["#{mail['mandrill_tag']}"]
    }

    true
  end

  #sends email via Mandrill
  def send_mandrill(mail)
    m = Mandrill::API.new(Rails.application.secrets.mandrill_api_key)
    sending = m.messages.send_template('mhd-mc',
                                       [
                                        {
                                          :name => 'main',
                                          :content => "#{mail.body}"
                                        }
                                       ],
                                       message = @message)
  end

end
