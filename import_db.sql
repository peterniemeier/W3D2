-- PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  questions_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES user(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
    id PRIMARY KEY NOT NULL,
    questions_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    parent_id INTEGER,
    reply TEXT NOT NULL,
    FOREIGN KEY (questions_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (parent_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  questions_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES user(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Ahmed','Singh'),
  ('Blake','Zeiny');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('question1', 'horrible question' , 1),
  ('question1', 'horrible question' , 1),
  ('question1', 'horrible question' , 1),
  ('question1', 'horrible question' , 2),
  ('question1', 'horrible question' , 2),
  ('question1', 'horrible question' , 1);

  INSERT INTO
    replies(id,questions_id, user_id, parent_id, reply)
  VALUES
    ('1','1','2','1','YOYOYOPIEs'),
    ('2','2','2','1','SCOOBY'),
    ('3','1','1','1','SNACKS'),
    ('4','4','2','4','DELICIOUS'),
    ('5','2','1','2','underlined'),
    ('6','1','1','2','lowercaserox');

    INSERT INTO
      question_follows(questions_id, user_id)
    VALUES
      ('3','2'),
      ('2','2'),
      ('1','1');

    INSERT INTO
      question_likes(questions_id, user_id)
    VALUES
      ('1','1'),
      ('1','2'),
      ('2','1'),
      ('6','1'),
      ('3','2'),
      ('4','2'),
      ('5','2');

SELECT COUNT(DISTINCT(user_id)) FROM questions WHERE user_id = '1';
SELECT COUNT(*) FROM question_likes WHERE user_id = '1'
