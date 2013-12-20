require 'mechanize'
require 'json'

class ImageSearch < CampfireBot::Plugin
  on_command 'image', :image_me
  on_message Regexp.new("^image me", Regexp::IGNORECASE), :image_me

  def initialize
    @log = Logging.logger["CampfireBot::Plugin::ImageSearch"]
    @agent = Mechanize.new
  end

  def image_me(msg)
    ## basically stolen from hubot
    # https://github.com/github/hubot/blob/master/src/scripts/google-images.coffee
    search_term = msg[:message]
    params = {:v => '1.0', :rsz => '8', :q => search_term, :safe => 'active'}
    result = @agent.get("http://ajax.googleapis.com/ajax/services/search/images", params)
    json = JSON.parse(result.body)
    images = json['responseData']['results']
    if images.length > 0
      image = images[rand(images.length)]['unescapedUrl']
      msg.speak(image)
    end
  end
end