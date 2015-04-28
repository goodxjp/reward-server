class ClickHistory < ActiveRecord::Base
  belongs_to :media_user
  belongs_to :offer

  def user_agent
    begin
      json = JSON.parse(request_info)
    #rescue JSON::ParserError => e
    rescue Exception => e
      logger.debug(e)
      return nil
    end
    return json["user_agent"]
  end
end
