require 'mechanize'

class LolCats < CampfireBot::Plugin
  on_command 'lolcat', :lolcats

  def initialize
    @log = Logging.logger["CampfireBot::Plugin::Lolcat"]
  end

  def lolcats(msg)
    # Scrape random lolcat
    # BUSTED
    # lolcat = (Hpricot(open('http://icanhascheezburger.com/?random#top'))/'div.entry img').first['src']
    # working
    agent = Mechanize.new
    urls = agent.get('http://icanhas.cheezburger.com/lolcats').search("//img[contains(@src,'maxW500')]")
    lolcat = urls[rand(urls.length)]['src'] + 'image.jpg'
    msg.speak(lolcat)
  end
end