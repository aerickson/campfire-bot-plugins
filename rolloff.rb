require "fiber"

class Rolloff < CampfireBot::Plugin
  on_command 'roll', :on_roll
  on_command 'rolloff', :on_rolloff

  SIDES_OF_A_DIE = 6

  def on_roll(msg)
    return unless @fiber && @fiber.alive?

    roll = rand(@limit) + 1
    nick = msg[:person]

    return if @attempts[nick]

    @attempts.merge!(nick => roll)

    msg.speak "#{nick}: #{roll}"
  end

  def on_rolloff(msg)
    return if @fiber && @fiber.alive?

    @limit = msg[:message].strip.to_i
    @limit    = SIDES_OF_A_DIE if @limit < 2
    @attempts = {}

    @fiber = Fiber.new do
      sleep 10

      if @attempts.any?
        high_score = @attempts.sort_by { |nick, roll| roll }.last.last
        @winners   = @attempts.select { |nick, roll| roll  == high_score }
      end
    end

    @fiber.resume

    winning_names = []
    winning_names = @winners.map(&:first) if @winners

    if winning_names.empty?
      msg.speak "LAME: No one guessed!!!!111111one"
    elsif winning_names.length == 1
      msg.speak "W1NN4R: #{winning_names.first}!!!111one"
    else
      msg.speak "TIE!!: #{winning_names.join(", ")}!!!111one"
    end
  end

end


