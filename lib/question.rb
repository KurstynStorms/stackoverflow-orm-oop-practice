class Question
  attr_reader :title, :content
  attr_accessor :views, :id

  def initialize(title:, content:, views:, id: nil)
    @title = title
    @content = content
    @views = views
    @id = id
  end

  def save
    sql = <<-SQL
      INSERT INTO questions (title, content, views)
      VALUES (?, ?, ?)
    SQL
    DB[:conn].execute(sql, title, content, views)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM questions")[0][0]
    self
  end

  def answers
    Answer.find_all_by_question_id(id)
  end

  def self.create(title:, content:, views:)
    new_question = new(title: title, content: content, views: views).save
  end

  def self.new_from_db(row)
    new(id: row[0], title: row[1], content: row[2], views: row[3])
  end

  def self.all
    sql = <<-SQL
    SELECT * FROM questions
    SQL
    rows = DB[:conn].execute(sql)
    rows.map { |row| new_from_db(row) }
  end

  def self.find_by_title(title)
    sql = <<-SQL
    SELECT * FROM questions
    WHERE title IS ?
    LIMIT 1
    SQL
    question = DB[:conn].execute(sql, title)
    new_from_db(question[0])
  end

  def self.find(id)
    sql = <<-SQL
      SELECT *
      FROM questions
      WHERE questions.id = ?
      LIMIT 1;
    SQL

    DB[:conn].execute(sql, id).map do |row|
      new_from_db(row)
    end.first
  end
end