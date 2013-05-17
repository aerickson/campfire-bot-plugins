require 'csv'

class Trivia < CampfireBot::Plugin
  on_command 'trivia', :on_trivia_question
  on_command 'reveal', :on_trivia_reveal
  on_command 'answer', :on_trivia_answer

  def initialize
    @trivia_question_list = parse_trivia_questions
  end

  def peat_sez(msg, text)
    msg.speak text
  end

  def parse_trivia_questions
    trivia_file = "trivia.txt"
    trivia = Array.new

    CSV.foreach(trivia_file, :col_sep => "/", :quote_char => "|") do |row|
      trivia << row.compact
    end

    puts "Parsed #{trivia.length} rows."

    trivia
  end

  def on_trivia_question(m)
    trivia_row = @trivia_question_list.sample
    category = trivia_row[0]
    @trivia_question = trivia_row.last
    @trivia_answers = trivia_row.slice(1, trivia_row.length-2)

    other_user = m[:message].strip

    challenge = other_user.present? ? "CHALLENGE TO #{other_user}: " : ""
    peat_sez(m, challenge + "Trivia[!answer to guess, !reveal to give up]: #{@trivia_question}")
  end

  def on_trivia_reveal(m)
    if @trivia_question
      peat_sez(m, "#{@trivia_question} ==> #{@trivia_answers.first}")
    else
      peat_sez(m, "#{m[:person]} come on -- you need to generate a question with !trivia first...")
    end
  end

  def on_trivia_answer(m)
    guessed_answer = m[:message].strip

    if guessed_answer.nil?
      peat_sez(m, "#{m[:person]}, you need to actually type an answer.")
      return
    elsif @trivia_question.nil?
      peat_sez(m, "#{m[:person]} come on -- you need to generate a question with !trivia first...")
      return
    end

    # Compare to possible answers
    correct = false
    @trivia_answers.each do |answer|
      if answer.casecmp(guessed_answer) == 0
        peat_sez(m, "#{m[:person]}: CORRECT!!!!!1111111one")
        peat_sez(m, "#{@trivia_question} ==> #{@trivia_answers.first}")
        correct = true
      end
    end

    return if correct

    # Incorrect if we get here
    peat_sez(m, "#{m[:person]}: Sorry, that is not correct :(")
  end

end
