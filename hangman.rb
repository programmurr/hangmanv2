# frozen_string_literal: true

require 'io/console'
require 'yaml'

class WordGenerator
  attr_accessor :blank_word, :secret_word

  def initialize
    loop do
      @secret_word = File.readlines('words.txt').sample(1).pop.strip.downcase
      return @secret_word unless @secret_word.length < 5 || @secret_word.length > 12
    end
  end

  def convert_to_blank_string
    @blank_word = secret_word.gsub(/[a-zA-Z]/, '_ ')
  end
end

class Player
  attr_accessor :guesses_remaining, :incorrect_letters
  def initialize
    @guesses_remaining = 6
    @incorrect_letters = String.new('')
  end
end

class Display
  attr_accessor :player, :word_generator

  def initialize(player, word_generator)
    @player = player
    @word_generator = word_generator
    welcome_screen
  end

  def welcome_screen
    system 'clear'
    puts "\n >>> HANGMAN <<< "
    puts "\nPress 1 to start a new game, or 2 to load a saved game"
  end

  def game_screen
    system 'clear'
    puts "\n#{word_generator.blank_word}"
    puts "\n#{player.guesses_remaining} guesses left!"
    puts "\nIncorrect letters: #{player.incorrect_letters}"
    puts "\nPress the letter you want to guess, or press 1 to save your game."
  end

  def load_screen
    system 'clear'
    puts 'Press the number of the file you want to load'
    Dir.chdir('save_files') { puts Dir.glob('*.yaml').sort }
  end

  def win_message
    system 'clear'
    game_screen
    puts "\nYOU WON! YOU'RE THE BEST HANGMAN PLAYER OF ALL TIME!"
    sleep 2
  end

  def loss_message
    system 'clear'
    game_screen
    puts "\nOH NO! You lost!"
    sleep 2
    puts "\nThe secret word was '#{word_generator.secret_word}'"
    sleep 2
    puts "\nBetter luck next time!"
    sleep 2
  end

  def game_save_message
    system 'clear'
    game_screen
    puts "\nGame saved! Press 1 to continue game, or any key to exit"
  end
end

module SaveLoad
  def save_game
    save_object = {
      guesses_remaining: player.guesses_remaining,
      blank_word: word_generator.blank_word,
      secret_word: word_generator.secret_word,
      incorrect_letters: player.incorrect_letters
    }
    File.open("save_files/#{file_name}.yaml", 'w') { |file| file.write(YAML.dump(save_object)) }
  end

  def load_game(choice)
    file_to_load = Dir.chdir('save_files') { Dir.glob('*.yaml').sort[choice] }
    loaded_game = YAML.safe_load(File.read("save_files/#{file_to_load}"), [Symbol])
    player.guesses_remaining = loaded_game[:guesses_remaining]
    word_generator.blank_word = loaded_game[:blank_word]
    player.incorrect_letters = loaded_game[:incorrect_letters]
    word_generator.secret_word = loaded_game[:secret_word]
  rescue Errno::EISDIR
    puts "That file doesn't exist, please choose again"
    sleep 3
    user_interface.load_screen
    load_screen_choice
  end
end

module Logic
  def welcome_screen_choice
    choice = user_input
    if choice == '1'
      puts 'Going to game'
      gameplay
    elsif choice == '2'
      user_interface.load_screen
      load_screen_choice
    end
  end

  def game_screen_choice
    choice = user_input
    if choice =~ /[a-zA-Z]/
      letter_check(choice)
    elsif choice == '1'
      save_game
      user_interface.game_save_message
      save_screen_choice
    else
      puts 'Enter a letter only'
      sleep 3
      gameplay
    end
  end

  def replace_blank_space(choice)
    split_blank = word_generator.blank_word.split
    split_secret = word_generator.secret_word.split('')
    split_secret.each_index do |index|
      split_blank[index] = choice if split_secret[index] == choice
    end
    word_generator.blank_word = split_blank.join(' ')
  end

  def remove_guess_remaining
    player.guesses_remaining -= 1
  end

  def add_to_incorrect_letters(choice)
    player.incorrect_letters << choice
  end

  def letter_check(choice)
    if word_generator.secret_word.match?(choice)
      replace_blank_space(choice)
    elsif !word_generator.secret_word.match?(choice)
      remove_guess_remaining
      add_to_incorrect_letters(choice)
    end
    gameplay
  end

  def save_screen_choice
    choice = user_input
    if choice == '1'
      gameplay
    else
      puts "\nBye!"
    end
  end

  def load_screen_choice
    loop do
      choice = user_input
      if choice =~ /\d/
        load_game(choice.to_i)
        gameplay
      else
        puts 'Please enter a number'
        sleep 3
        user_interface.load_screen
      end
    end
  end

  def win_check?
    if word_generator.blank_word.split == word_generator.secret_word.split('') && player.guesses_remaining.positive?
      true
    else
      false
    end
  end

  def loss_check?
    if word_generator.blank_word.split != word_generator.secret_word.split('') && player.guesses_remaining.zero?
      true
    else
      false
    end
  end
end

class Game
  include Logic
  include SaveLoad
  attr_accessor :player, :word_generator, :user_interface, :file_name

  def initialize(player:, word_generator:)
    @player = player
    @word_generator = word_generator
    word_generator.convert_to_blank_string
    @user_interface = Display.new(player, word_generator)
    @file_name = create_unique_file_name
    launch_game
  end

  def launch_game
    welcome_screen_choice
  end

  def gameplay
    if win_check?
      user_interface.win_message
      exit
    elsif loss_check?
      user_interface.loss_message
      exit
    else
      user_interface.game_screen
      game_screen_choice
    end
  end

  def finish_game; end

  def create_unique_file_name
    Dir.mkdir('save_files')
    count = Dir.glob('save_files/*.yaml').length
    date_and_time = Time.new
    "#{count} - Hangman: #{date_and_time.strftime('%d-%m-%Y %I:%M %p')}"
  rescue Errno::EEXIST
    count = Dir.glob('save_files/*.yaml').length
    date_and_time = Time.new
    "#{count} - Hangman: #{date_and_time.strftime('%d-%m-%Y %I:%M %p')}"
  end

  def user_input
    state = `stty -g`
    `stty raw -echo -icanon isig`
    STDIN.getc.chr.downcase
  ensure
    `stty #{state}`
  end
end

Game.new(player: Player.new, word_generator: WordGenerator.new)
