# frozen_string_literal: true

require 'io/console'
require 'pry'

class WordGenerator
  attr_reader :secret_word
  attr_accessor :blank_word

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
  attr_accessor :guesses_remaining
  def initialize
    @guesses_remaining = 6
  end
end

class Display
  attr_accessor :player, :word_generator, :incorrect_letters

  def initialize(player, word_generator, incorrect_letters)
    @player = player
    @word_generator = word_generator
    @incorrect_letters = incorrect_letters
    welcome_screen
  end

  def welcome_screen
    system 'clear'
    puts "\n >>> HANGMAN <<< "
    puts "\nPress 1 to start a new game, or 2 to load a saved game"
  end

  def load_screen
    system 'clear'
    puts 'LOAD SCREEN UNDER CONSTRUCTION'
    puts 'Press 1 to start a game, or any key to exit'
  end

  def game_screen
    system 'clear'
    puts "\n#{word_generator.blank_word}"
    puts "\n#{player.guesses_remaining} guesses left!"
    puts "\nIncorrect letters: #{incorrect_letters}"
    puts "\nPress the letter you want to guess, or press 1 to save your game."
  end

  def save_screen
    system 'clear'
    puts 'SAVE SCREEN UNDER CONSTRUCTION'
    puts 'Press 1 to return to the game, or any key to exit'
  end

  def win_message
    system 'clear'
    game_screen
    puts "\nYOU WON! YOU'RE THE BEST HANGMAN PLAYER OF ALL TIME!"
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
end

module Logic
  def welcome_screen_choice
    choice = user_input
    if choice == '1'
      puts 'Going to game'
      gameplay
    elsif choice == '2'
      load_game
    end
  end

  def game_screen_choice
    choice = user_input
    if choice =~ /[a-zA-Z]/
      letter_check(choice)
    elsif choice == '1'
      save_game
    else
      puts 'Enter a letter only'
      sleep 3
      gameplay
    end
  end

  def replace_blank_space(choice)
    split_blank = word_generator.blank_word.split
    split_secret = word_generator.secret_word.split('')
    split_secret.each.with_index do |_char, index|
      split_blank[index] = choice if split_secret[index] == choice
    end
    word_generator.blank_word = split_blank.join(' ')
  end

  def remove_guess_remaining
    player.guesses_remaining -= 1
  end

  def add_to_incorrect_letters(choice)
    incorrect_letters << choice
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
      puts 'END'
    end
  end

  def load_screen_choice
    choice = user_input
    if choice == '1'
      gameplay
    else
      puts 'END'
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
  attr_accessor :player, :word_generator, :user_interface, :incorrect_letters

  def initialize(player:, word_generator:)
    @player = player
    @word_generator = word_generator
    @incorrect_letters = String.new('')
    word_generator.convert_to_blank_string
    @user_interface = Display.new(player, word_generator, incorrect_letters)
    launch_game
  end

  def launch_game
    welcome_screen_choice
  end

  def gameplay
    if win_check? == true
      user_interface.win_message
    elsif loss_check? == true
      user_interface.loss_message
    else
      user_interface.game_screen
      game_screen_choice
    end
  end

  def load_game
    user_interface.load_screen
    load_screen_choice
  end

  def save_game
    user_interface.save_screen
    save_screen_choice
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
