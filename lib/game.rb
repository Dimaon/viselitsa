# encoding: utf-8
#
# Основной класс игры Game. Хранит состояние игры и предоставляет функции для
# развития игры (ввод новых букв, подсчет кол-ва ошибок и т. п.).
# Для версии руби 2.3.3 и ниже
require "unicode"

class Game
  attr_reader :errors, :letters, :good_letters, :bad_letters, :status

  attr_accessor :version

  MAX_ERRORS = 7
  # Конструктор — вызывается всегда при создании объекта данного класса имеет
  # один параметр, в него нужно передавать при создании строку к загаданнмы
  # словом. Например, game = Game.new('молоко').
  def initialize(word)
    # Инициализируем переменные экземпляра. В @letters будет лежать массив букв
    # загаданного слова. Для того, чтобы его создать, вызываем метод get_letters
    # этого же класса.
    @letters = get_letters(Unicode.upcase(word))

    # Переменная @errors будет хранить текущее количество ошибок, всего можно
    # сделать не более 7 ошибок. Начальное значение — 0.
    @errors = 0

    # Переменные @good_letters и @bad_lettes будут содержать массивы, хранящие
    # угаданные и неугаданные буквы. В начале игры они пустые.
    @good_letters = []
    @bad_letters = []

    # Специальная переменная-индикатор состояния игры (см. метод get_status)
    @status = :in_progress
  end

  # Метод, который возвращает массив букв загаданного слова
  def get_letters(word)
    if word == nil || word == ""
      abort "Загадано пустое слово, нечего отгадывать. Закрываемся"
    end

    word.encode('UTF-8').split("")
  end

  def in_progress?
    @status == :in_progress
  end

  def won?
    @status == :won
  end

  def lost?
    @status == :lost || @errors >= MAX_ERRORS
  end

  def max_errors
    MAX_ERRORS
  end

  def errors_left
    MAX_ERRORS - @errors
  end

  def is_letter_good?(letter)
    @letters.include?(letter) ||
    letter.match(/[EЁИЙ]/) && @letters.join.match(/[ЕЁИЙ]/)
  end

  def add_letter_to_letters(letter, letters)
    letters << letter

    case letter
      when "И" then letters << "Й"
      when "Й" then letters << "И"
      when "Е" then letters << "Ё"
      when "Ё" then letters << "Е"
    end
  end

  def solved?
    #@good_letters.uniq.sort == @letters.uniq.sort
    (@letters - @good_letters).empty?
  end

  def letter_repeated?(letter)
    @good_letters.include?(letter) || @bad_letters.include?(letter)
  end

  # Основной метод игры "сделать следующий шаг". В качестве параметра принимает
  # букву, которую ввел пользователь. Основная логика взята из метода
  # check_user_input (см. первую версию программы).
  def next_step(letter)
    # Предварительная проверка: если статус игры равен 1 или -1, значит игра
    # закончена и нет смысла дальше делать шаг. Выходим из метода возвращая
    # пустое значение.
    letter = Unicode.upcase(letter)
    return if @status == :lost || @status == :won

    # Если введенная буква уже есть в списке "правильных" или "ошибочных" букв,
    # то ничего не изменилось, выходим из метода.
    return if letter_repeated?(letter)

    if is_letter_good?(letter)
      # Если в слове есть буква запишем её в число "правильных" буква
      # @good_letters << letter
      add_letter_to_letters(letter, @good_letters)

      # Дополнительная проверка — угадано ли на этой букве все слово целиком.
      # Если да — меняем значение переменной @status на 1 — победа.
      @status = :won if solved?
    else
      # Если в слове нет введенной буквы — добавляем эту букву в массив
      # «плохих» букв и увеличиваем счетчик ошибок.
      #@bad_letters << letter
      add_letter_to_letters(letter, @bad_letters)
      @errors += 1

      # Если ошибок больше 7 — статус игры меняем на -1, проигрыш.
      @status = :lost if lost?
    end
  end

  # Метод, спрашивающий юзера букву и возвращающий ее как результат. В идеале
  # этот метод лучше вынести в другой класс, потому что он относится не только
  # к состоянию игры, но и к вводу данных.
  def ask_next_letter
    puts "\nВведите следующую букву"

    letter = ""
    while letter == ""
      letter = Unicode.upcase(STDIN.gets.encode("UTF-8").chomp)
    end

    # После получения ввода, передаем управление в основной метод игры
    next_step(letter)
  end

end
