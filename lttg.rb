class Lttg < CampfireBot::Plugin
  on_command 'LTTG', :on_lttg

  def on_lttg(msg)
    other_user = m[:message].strip
    if other_user.present?
      msg.speak "#{other_user}...you are LATE to the mutha-f'in GAAAAAMMME!!!!!!!!!!!!!!!111111111one"
    end
  end

end
