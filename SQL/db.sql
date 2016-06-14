CREATE DATABASE friendz;

CREATE TABLE user(
    userId int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username varchar(64),
    fname char(20) NOT NULL,
    mname char(20),
    lname char(20),
    gender char CHECK (gender IN ('M', 'F', 'O')),
    address varchar(255),
    phone char(12),
    email varchar(255) NOT NULL UNIQUE
);

/* not used passwd table yet */
CREATE TABLE passwd(
    userId int NOT NULL PRIMARY KEY,
    password BINARY(64) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    join_date DATE DEFAULT NOW(),
    FOREIGN KEY (userId) REFERENCES user(userId)
);

CREATE TABLE friendship(
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fromuser int NOT NULL,
    touser int NOT NULL,
    accepted boolean DEFAULT FALSE,
    FOREIGN KEY (fromuser) REFERENCES user(userId),
    FOREIGN KEY (touser) REFERENCES user(userId),
    CONSTRAINT check_self_relation CHECK (fromuser != touser)
);

ALTER TABLE friendship
ADD CONSTRAINT check_same 
CHECK fromuser<>touser;

select *
from information_schema.table_constraints
where constraint_schema = 'frendz';

CREATE TABLE article(
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    userId int NOT NULL,
    article_text text,
    post_date timestamp DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (userId) REFERENCES user(userId)
);

CREATE TABLE comments(
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    article int NOT NULL,
    user int NOT NULL,
    comment_text text,
    comment_time timestamp DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (article) REFERENCES article(id),
    FOREIGN KEY (user) REFERENCES user(userId)
);

/* create new user */
/* not considered authentication yet */
INSERT INTO user 
(username, fname, gender, address, phone, email)
VALUES ('DJ Rohan', 'Rohan', 'M', 'Mapusa, Goa', '9090909090', 'rohan.xxyyzz.9090@something.com');

INSERT INTO user 
(username, fname, lname, gender, address, phone, email)
VALUES ('Savio', 'Savio', 'Ferns', 'M', 'Mapusa, Goa', '1090909090', 'savio.xxyyzz.9090@something.com');

INSERT INTO user 
(username, fname,  lname, gender, address, phone, email)
VALUES ('Lovely$uzane', 'Suzane', 'Dsauza', 'F', 'Ponda, Goa', '1090909000', 'suzane.xxyyzz.9090@something.com');

INSERT INTO user 
(username, fname,  lname, gender, address, phone, email)
VALUES ('sanket.natu', 'Sanket', 'Natu', 'M', 'Khorlim, Mapusa, Goa', '8993432424', 'sanket.xxyyzz.9090@something.com');

INSERT INTO user 
(username, fname, mname, lname, gender, address, phone, email)
VALUES ('Karishman', 'Karishma', 'Shrikant', 'Parsekar', 'F', 'Khorlim, Mapusa, Goa', '1090909000', 'karishma.xxyyzz.9090@something.com');


/* send friend request to other user */

INSERT INTO friendship (fromuser, touser) VALUES ('1', '2');
INSERT INTO friendship (fromuser, touser) VALUES ('1', '3');
INSERT INTO friendship (fromuser, touser) VALUES ('2', '3');
INSERT INTO friendship (fromuser, touser) VALUES ('5', '1');
INSERT INTO friendship (fromuser, touser) VALUES ('5', '2');
INSERT INTO friendship (fromuser, touser) VALUES ('5', '3');
INSERT INTO friendship (fromuser, touser) VALUES ('5', '4');


/** PROCEDURE for adding a friend **/
delimiter //

CREATE PROCEDURE addFriend 
(IN fromUsr int, IN toUsr int)
BEGIN
    DECLARE isFriend int;
    
    SELECT COUNT(*) INTO isFriend 
    FROM friendship 
    WHERE (fromuser = fromUsr AND touser = toUsr) OR (fromuser = toUsr AND touser = fromUsr);
    
    IF (isFriend = 0 AND fromUsr != toUsr) THEN
        INSERT INTO friendship (fromuser, touser) VALUES (fromUsr, toUsr);
    END IF;
END//

delimiter ;

/** calling addFriend PROCEDURE **/
CALL addFriend(4, 1);

/** post an article **/
delimiter //

CREATE PROCEDURE postArticle
(IN user int, IN articleText text)
BEGIN
    IF CHAR_LENGTH(articleText) > 0 THEN
        INSERT INTO article
        (userId, article_text)
        VALUES (user, articleText);
    END IF;
END//

 call postArticle('1', 'Hello friends!');
 
 
 /* function to check if users are friends */
CREATE FUNCTION areFriends(user1 int, user2 int)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN 
DECLARE tempCount int;

SELECT COUNT(*) INTO tempCount FROM friendship 
    WHERE (fromuser = user1 AND touser = user2
            OR fromuser = user2 AND touser = user1) AND accepted = TRUE;

RETURN (tempCount != 0);

END//

UPDATE friendship SET accepted = true WHERE id = 1;

SELECT areFriends(1,2);

mysql> select * from friendship//
+----+----------+--------+----------+
| id | fromuser | touser | accepted |
+----+----------+--------+----------+
|  1 |        1 |      2 |        1 |
|  2 |        1 |      3 |        0 |
|  4 |        2 |      3 |        0 |
|  6 |        5 |      1 |        0 |
|  7 |        5 |      2 |        0 |
|  8 |        5 |      3 |        0 |
|  9 |        5 |      4 |        0 |
| 12 |        4 |      1 |        0 |
+----+----------+--------+----------+
8 rows in set (0.00 sec)

mysql> SELECT areFriends(1,2);
    -> //
+-----------------+
| areFriends(1,2) |
+-----------------+
|               1 |
+-----------------+
1 row in set (0.00 sec)

 
 /* comment on a post */
 
delimiter //

CREATE PROCEDURE commentOnPost
(IN user int, IN article int, IN commentText text)
BEGIN
    
    DECLARE userOfPost int;
    
    SELECT userId INTO userOfPost
    FROM article
    WHERE id = article;
    
    IF (CHAR_LENGTH(commentText) > 0 AND areFriends(user, userOfPost)) THEN
        INSERT INTO comments
        (article, user, comment_text)
        VALUES (article,user, commentText);
    END IF;
END//

call commentOnPost(2, 1, 'Hello there.. How do you do?');


/* state of all tables till now */

user table

mysql> select * from user//
+--------+--------------+----------+----------+----------+--------+----------------------+------------+------------------------------------+
| userId | username     | fname    | mname    | lname    | gender | address              | phone      | email                              |
+--------+--------------+----------+----------+----------+--------+----------------------+------------+------------------------------------+
|      1 | DJ Rohan     | Rohan    | NULL     | NULL     | M      | Mapusa, Goa          | 9090909090 | rohan.xxyyzz.9090@something.com    |
|      2 | Savio        | Savio    | NULL     | Ferns    | M      | Mapusa, Goa          | 1090909090 | savio.xxyyzz.9090@something.com    |
|      3 | Lovely$uzane | Suzane   | NULL     | Dsauza   | F      | Ponda, Goa           | 1090909000 | suzane.xxyyzz.9090@something.com   |
|      4 | sanket.natu  | Sanket   | NULL     | Natu     | M      | Khorlim, Mapusa, Goa | 8993432424 | sanket.xxyyzz.9090@something.com   |
|      5 | Karishman    | Karishma | Shrikant | Parsekar | F      | Khorlim, Mapusa, Goa | 1090909000 | karishma.xxyyzz.9090@something.com |
+--------+--------------+----------+----------+----------+--------+----------------------+------------+------------------------------------+
5 rows in set (0.00 sec)


friendship table

mysql> select * from friendship//
+----+----------+--------+----------+
| id | fromuser | touser | accepted |
+----+----------+--------+----------+
|  1 |        1 |      2 |        1 |
|  2 |        1 |      3 |        0 |
|  4 |        2 |      3 |        0 |
|  6 |        5 |      1 |        0 |
|  7 |        5 |      2 |        0 |
|  8 |        5 |      3 |        0 |
|  9 |        5 |      4 |        0 |
| 12 |        4 |      1 |        0 |
+----+----------+--------+----------+
8 rows in set (0.00 sec)


article

mysql> select * from article//
+----+--------+----------------+---------------------+
| id | userId | article_text   | post_date           |
+----+--------+----------------+---------------------+
|  1 |      1 | Hello friends! | 2016-06-14 11:57:27 |
+----+--------+----------------+---------------------+
1 row in set (0.00 sec)

comments

mysql> select * from comments//
+----+---------+------+------------------------------+---------------------+
| id | article | user | comment_text                 | comment_time        |
+----+---------+------+------------------------------+---------------------+
|  1 |       1 |    2 | Hello there.. How do you do? | 2016-06-14 12:36:38 |
+----+---------+------+------------------------------+---------------------+
1 row in set (0.00 sec)
