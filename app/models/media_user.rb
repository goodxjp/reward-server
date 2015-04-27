class MediaUser < ActiveRecord::Base
  validates :terminal_id,
    :presence => true,
    :uniqueness => true

  def version
    begin
      json = JSON.parse(terminal_info)
    #rescue JSON::ParserError => e
    rescue Exception => e
      logger.debug(e)
      return nil
    end
    return json["VERSION.RELEASE"]
  end

  def brand
    begin
      json = JSON.parse(terminal_info)
    #rescue JSON::ParserError => e
    rescue Exception => e
      logger.debug(e)
      return nil
    end
    return json["BRAND"]
  end

  def model
    begin
      json = JSON.parse(terminal_info)
    #rescue JSON::ParserError => e
    rescue Exception => e
      logger.debug(e)
      return nil
    end
    return json["MODEL"]
  end
end
