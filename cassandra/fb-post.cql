CREATE KEYSPACE IF NOT EXISTS facebook
WITH REPLICATION = {
  'class': 'SimpleStrategy',
  'replication_factor': '1'
};

USE facebook;


CREATE TABLE IF NOT EXISTS post (
  publish_time TIMESTAMP,
  post_id VARCHAR,
  post_url TEXT,
  author_id VARCHAR,
  author_name TEXT,
  author TEXT,
  content TEXT,
  comment_count INT,
  like_count INT,
  share_count INT,
  share_link TEXT,
  image TEXT,
  comments TEXT,
  reshare_list TEXT,
  group_id VARCHAR,
  group_name VARCHAR,
  reaction_list TEXT,
  share_link_meta TEXT,
  is_sharelist_update TINYINT,
  is_comments_update TINYINT,
  is_reaction_list_update TINYINT,
  db_create_time TIMESTAMP,
  db_update_time TIMESTAMP,
  attached_post_id VARCHAR,
  attached_author_id VARCHAR,
  attached_author TEXT,
  PRIMARY KEY ((publish_time), post_id)
);

DROP TABLE post;
TRUNCATE TABLE post;

SELECT publish_time, post_id
FROM facebook.post
WHERE publish_time > '2022-11-19'
LIMIT 10
ALLOW FILTERING;