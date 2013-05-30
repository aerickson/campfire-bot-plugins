class Peat < CampfireBot::Plugin
  on_message    Regexp.new("#{bot.config['nickname']}", Regexp::IGNORECASE), :peat

  def peat(msg)
    msg.speak "m4k1n t3h c0d3z 3v3n b3773r!!!111one"
  end

end
