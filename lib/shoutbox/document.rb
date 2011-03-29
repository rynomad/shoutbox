require 'mongoid'
require 'json'

require 'lib/shoutbox/status'

class Shoutbox
  class ShoutboxDocument
    include Mongoid::Document
    include Status
    
    field :account_name
    field :status_data, :type => Hash
    field :auth_token
    field :auth_salt

  
    def self.find_or_create_for_account( account_name )
       find_document_for( account_name ) || create_shoutbox_document_for( account_name )
    end
  
    def self.find_document_for( account_name )
      self.where( :account_name => account_name ).first
    end
  
    private

    def self.create_shoutbox_document_for( account_name )
      salt, token = Shoutbox::Authentication.create_auth_token_for( account_name )
      self.create!( :account_name => account_name, :status_data => default_status, :auth_token => token, :auth_salt => salt )
    end
  
    def self.default_status
      { "Shoutbox Default Group" => { "Use Shoutbox" => { "slug"        => "shoutbox-default-group-use-shoutbox",
                                                          "updated_at"  => Time.now.to_i,
                                                          "expires_at"  => Time.now.to_i + 5*60,
                                                          "status"      => "red", 
                                                          "message"     => "You can remove me by using your shoutbox client." } } }
    end
  end
end