require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class QuestionFollow
  attr_accessor :questions_id, :user_id

  def self.followers_for_question_id(questions_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, questions_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows
      ON
        question_follows.user_id = users.id
      WHERE
        question_follows.questions_id = ?
    SQL
    data.map {|datum| User.new(datum)}
  end

  def self.followed_qs(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows
      ON
        question_follows.questions_id = questions.id
      WHERE
        question_follows.user_id = ?
    SQL
    data.map {|datum| Questions.new(datum)}
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows
      ON
        questions.id = question_follows.questions_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL
    data.map {|datum| Questions.new(datum)}
  end

  def initialize(options)
    @questions_id = options['questions_id']
    @user_id = options['user_id']
  end

end

class Questions
  attr_accessor :title, :body, :user_id, :id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map {|datum| Questions.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end



  def create
    # debugger
    raise "#{self} already in Database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
      questions (title, body, user_id)
      VALUES
      (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_id(id)
    id = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
    *
    FROM
    questions
    WHERE
    id = ?
    SQL
    id.map {|id| Questions.new(id)}
  end
end

class QuestionLikes
  attr_accessor :questions_id, :user_id
  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
      users.*
      FROM
        users
      JOIN
        question_likes
      ON
        question_likes.user_id = users.id
      WHERE
        question_likes.questions_id = ?
    SQL
    data.map {|datum| User.new(datum)}
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(*) as "LIKES"
    FROM
      question_likes
    WHERE
      questions_id = ?
    SQL
  end

  def self.followed_qs(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows
      ON
        question_follows.questions_id = questions.id
      WHERE
        question_follows.user_id = ?
    SQL
    data.map {|datum| Questions.new(datum)}
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows
      ON
        questions.id = question_follows.questions_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL
    data.map {|datum| Questions.new(datum)}
  end

  def initialize(options)
    @questions_id = options['questions_id']
    @user_id = options['user_id']
  end


end

class User
  attr_accessor :fname, :lname
  attr_reader :id


  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map {|datum| User.new(datum)}
  end

  def self.find_by_name(fname, lname)
    id = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      fname LIKE ? AND lname LIKE ?;
    SQL

    id.map {|id| User.new(id)}
  end

  def followed_questions
    QuestionFollow.followed_qs(self.id)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end


end

if __FILE__ == $PROGRAM_NAME
  10.times do |i|
    options = { 'title'=> "hello" + i, 'body' => 'this is a question'+ i, 'user_id' => 1}
    q = Questions.new(options)
    q.create
  end
end
