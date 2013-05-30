# SERVER=XXX.XXX.XXX ROOM=#IRC_ROOM NICK=Peat nohup ruby newpete.rb &
#
# encoding: UTF-8
require 'fiber'
require 'cinch'
require 'csv'

SIDES_OF_A_DIE = 6

class Staging
  attr_accessor :locker

  def initialize
    @locker = "nobody"
  end
end

staging = Staging.new


def parse_trivia_questions
  trivia_file = "trivia.txt"
  trivia = Array.new

  CSV.foreach(trivia_file, :col_sep => "/", :quote_char => "|") do |row|
    trivia << row.compact
  end

  puts "Parsed #{trivia.length} rows."

  trivia
end

trivia_question_list = parse_trivia_questions

def peat_sez(context, message)
  context.reply("#{message}")
end

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = ENV["NICK"]
    c.server = ENV["SERVER"]
    c.channels = [ENV["ROOM"]]
  end

  on :message, "!staging" do |m|
    peat_sez(m, staging.locker)
  end

  on :message, /^\!trivia(.*)/ do |m, other_user|

    trivia_row = trivia_question_list.sample
    category = trivia_row[0]
    @trivia_question = trivia_row.last
    @trivia_answers = trivia_row.slice(1, trivia_row.length-2)

    challenge = other_user.present? ? "CHALLENGE TO #{other_user}: " : ""
    peat_sez(m, challenge + "Trivia[!answer to guess, !reveal to give up]: #{@trivia_question}")
  end

  on :message, /^\!reveal(.*)/ do |m|
    if @trivia_question
      peat_sez(m, "#{@trivia_question} ==> #{@trivia_answers.first}")
    else
      peat_sez(m, "#{m.user.nick} come on -- you need to generate a question with !trivia first...")
    end
  end

  on :message, /^\!answer(.*)/ do |m, guessed_answer|

    guessed_answer.strip! unless guessed_answer.nil?

    if guessed_answer.nil?
      peat_sez(m, "#{m.user.nick}, you need to actually type an answer.")
      next
    elsif @trivia_question.nil?
      peat_sez(m, "#{m.user.nick} come on -- you need to generate a question with !trivia first...")
      next
    end

    # Compare to possible answers
    correct = false
    @trivia_answers.each do |answer|
      if answer.casecmp(guessed_answer) == 0
        peat_sez(m, "#{m.user.nick}: CORRECT!!!!!1111111one")
        peat_sez(m, "#{@trivia_question} ==> #{@trivia_answers.first}")
        correct = true
      end
    end

    next if correct

    # Incorrect if we get here
    peat_sez(m, "#{m.user.nick}: Sorry, that is not correct :(")
  end

  on :message, /^\!number(.*)/ do |m, max_guess|

    max_guess = max_guess.to_i
    if max_guess <= 1
      peat_sez(m, "Usage: !number <n>")
      next
    end

    @number_target = rand(max_guess) + 1
    @last_guesser = nil
    @guess_range = [1, max_guess]
    peat_sez(m, "I've picked a number between 1 and #{max_guess}. Use !guess to hit it!")
  end

  on :message, /^\!guess(.*)/ do |m, guess|

    if @number_target.nil?
      peat_sez(m, "Heh, nice try. Use !number first before guessing, #{m.user.nick}")
      next
    elsif m.user == @last_guesser
      peat_sez(m, "Uh...no. You were the last person to guess, #{m.user.nick}. Wait ur turn.")
      next
    end

    guess = guess.to_i
    if guess == 0
      peat_sez(m, "Oh come now, #{m.user.nick}, do you take me for a fool?")
      next
    else
      @last_guesser = m.user
    end

    if guess == @number_target
      peat_sez(m, "BOOOOO0000000MMMM!!!1111one:   #{m.user.nick} YOU WIN!")
      @number_target = nil
    elsif guess < @number_target
      @guess_range[0] = guess if guess > @guess_range[0]
      peat_sez(m, "^^^ Higher, #{m.user.nick}, HIGHER!  [#{@guess_range[0]} - #{@guess_range[1]}]")
    else # guess > target
      @guess_range[1] = guess if guess < @guess_range[1]
      peat_sez(m, "vvvvv Lower, #{m.user.nick}, LOWER   [#{@guess_range[0]} - #{@guess_range[1]}]")
    end
  end


  on :message, "!roll" do |m|
    next unless @fiber && @fiber.alive?

    roll = rand(@limit) + 1
    nick = m.user.nick

    next if @attempts[nick]

    @attempts.merge!(nick => roll)

    peat_sez(m, "#{m.user.nick}: #{roll}")
  end

  on :message, /^\!rolloff(.*)/ do |m, limit|
    next if @fiber && @fiber.alive?

    @attempts = {}
    @limit    = limit.to_i > 1 ? limit.to_i : SIDES_OF_A_DIE

    @fiber = Fiber.new do
      sleep 10

      high_score = @attempts.sort_by { |nick, roll| roll }.last.last
      @winners   = @attempts.select { |nick, roll| roll  == high_score }
    end

    @fiber.resume

    winning_names = @winners.map(&:first)

    if winning_names.length == 1
      peat_sez(m, "W1NN4R: #{winning_names.first}!!!111one")
    else
      peat_sez(m, "TIE!!: #{winning_names.join(", ")}!!!111one")
    end
  end

  on :message, "!lockstaging" do |m|
    if staging.locker == "nobody"
      staging.locker = m.user.nick

      peat_sez(m, "l0ck3d t3h st4g3")
    else
      peat_sez(m, "nice try d00d -- #{staging.locker}'s g07 17 l0ck3d")
    end
  end

  on :message, "!lockproduction" do |m|
    peat_sez(m, "D3pL000Y1NG 70 Pr0DUC710N!!!111one")
  end

  on :message, "!unlockproduction" do |m|
    peat_sez(m, "2 L473 2 A90l0G1Z3, L0L!!!one")
  end

  on :message, "!unlockstaging" do |m|
    if m.user.nick == staging.locker
      staging.locker = "nobody"

      peat_sez(m, "unl0ck3d t3h st4g3")
    else
      peat_sez(m, "nice try d00d -- #{staging.locker}'s g07 17 l0ck3d")
    end
  end

  on :message, /peat/ do |m|
    peat_sez(m, "m4k1n t3h c0d3z 3v3n b3773r!!!111one")
  end
end


bot.start
