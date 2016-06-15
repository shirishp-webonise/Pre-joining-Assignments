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


/*********** create new user ***********/
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


/*********** send friend request to other user ***********/

INSERT INTO friendship (fromuser, touser) VALUES ('1', '2');
INSERT INTO friendship (fromuser, touser) VALUES ('1', '3');
INSERT INTO friendship (fromuser, touser) VALUES ('2', '3');
INSERT INTO friendship (fromuser, touser) VALUES ('5', '1');
INSERT INTO friendship (fromuser, touser) VALUES ('5', '2');
INSERT INTO friendship (fromuser, touser) VALUES ('5', '3');
INSERT INTO friendship (fromuser, touser) VALUES ('5', '4');


/*********** PROCEDURE for adding a friend ***********/
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

/* calling addFriend PROCEDURE */
CALL addFriend(4, 1);

/*********** post an article ***********/
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
 
 
 /*********** function to check if users are friends ***********/
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

 
 /*********** comment on a post ***********/
 
delimiter //

CREATE PROCEDURE commentOnPost
(IN user int, IN article int, IN commentText text)
BEGIN
    
    DECLARE userOfPost int;
    
    SELECT userId INTO userOfPost
    FROM article
    WHERE id = article;
    
    IF (CHAR_LENGTH(commentText) > 0 AND (areFriends(user, userOfPost) OR user = userOfPost) THEN
        INSERT INTO comments
        (article, user, comment_text)
        VALUES (article,user, commentText);
    END IF;
END//

call commentOnPost(2, 1, 'Hello there.. How do you do?');


/*********** state of all tables till now ***********/

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


/*********** get list of friend requests ***********/

SELECT f.id as 'Request Id', u.username, u.fname AS 'First Name', u.mname AS 'Middle Name', u.lname AS 'Surname', u.address
FROM user as u, friendship as f 
WHERE f.touser = 3 AND f.fromuser = u.userId AND f.accepted = 'FALSE';

mysql> SELECT f.id as 'Request Id', u.username, u.fname AS 'First Name', u.mname AS 'Middle Name', u.lname AS 'Surname', u.address
    -> FROM user as u, friendship as f
    -> WHERE f.touser = 3 AND f.fromuser = u.userId AND f.accepted = 'FALSE';
+------------+-----------+------------+-------------+----------+----------------------+
| Request Id | username  | First Name | Middle Name | Surname  | address              |
+------------+-----------+------------+-------------+----------+----------------------+
|          2 | DJ Rohan  | Rohan      | NULL        | NULL     | Mapusa, Goa          |
|          4 | Savio     | Savio      | NULL        | Ferns    | Mapusa, Goa          |
|          8 | Karishman | Karishma   | Shrikant    | Parsekar | Khorlim, Mapusa, Goa |
+------------+-----------+------------+-------------+----------+----------------------+


/*********** accept friend requests ***********/
UPDATE friendship
SET accepted = TRUE
WHERE id = 2;

/* now check friend requests of user with user id 3*/
+------------+-----------+------------+-------------+----------+----------------------+
| Request Id | username  | First Name | Middle Name | Surname  | address              |
+------------+-----------+------------+-------------+----------+----------------------+
|          4 | Savio     | Savio      | NULL        | Ferns    | Mapusa, Goa          |
|          8 | Karishman | Karishma   | Shrikant    | Parsekar | Khorlim, Mapusa, Goa |
+------------+-----------+------------+-------------+----------+----------------------+


/************** get list of friends ***************/

SELECT username 'Friend', fname AS 'First Name', mname AS 'Middle Name', lname AS 'Surname', 
address 'Address', gender, phone AS 'Phone No', email AS 'Mail Id'
FROM user
WHERE userId IN
(
    SELECT fromuser
    FROM friendship
    WHERE touser = 3 AND accepted = TRUE
    UNION
    SELECT touser
    FROM friendship
    WHERE fromuser = 3 AND accepted = TRUE
);

+----------+------------+-------------+---------+-------------+--------+------------+---------------------------------+
| Friend   | First Name | Middle Name | Surname | Address     | gender | Phone No   | Mail Id                         |
+----------+------------+-------------+---------+-------------+--------+------------+---------------------------------+
| DJ Rohan | Rohan      | NULL        | NULL    | Mapusa, Goa | M      | 9090909090 | rohan.xxyyzz.9090@something.com |
+----------+------------+-------------+---------+-------------+--------+------------+---------------------------------+

/* accept another friend of user with id 3*/
UPDATE friendship
SET accepted = TRUE
WHERE id = 8;

mysql> SELECT username 'Friend', fname AS 'First Name', mname AS 'Middle Name', lname AS 'Surname',
    -> address 'Address', gender, phone AS 'Phone No', email AS 'Mail Id'
    -> FROM user
    -> WHERE userId IN
    -> (
    ->     SELECT fromuser
    ->     FROM friendship
    ->     WHERE touser = 3 AND accepted = TRUE
    ->     UNION
    ->     SELECT touser
    ->     FROM friendship
    ->     WHERE fromuser = 3 AND accepted = TRUE
    -> );
+-----------+------------+-------------+----------+----------------------+--------+------------+------------------------------------+
| Friend    | First Name | Middle Name | Surname  | Address              | gender | Phone No   | Mail Id                            |
+-----------+------------+-------------+----------+----------------------+--------+------------+------------------------------------+
| DJ Rohan  | Rohan      | NULL        | NULL     | Mapusa, Goa          | M      | 9090909090 | rohan.xxyyzz.9090@something.com    |
| Karishman | Karishma   | Shrikant    | Parsekar | Khorlim, Mapusa, Goa | F      | 1090909000 | karishma.xxyyzz.9090@something.com |
+-----------+------------+-------------+----------+----------------------+--------+------------+------------------------------------+


/************* posts of a user *************/
call postArticle('1', 'Good Morning every one! have a nice day!');
call postArticle('2', 'Feeling energetic today!');
call postArticle('3', 'Good night friends');
call postArticle('4', 'Cmon India!');

SELECT article_text 
FROM article
WHERE userId = 1;


/*************posts of a friend ************/

delimiter //

CREATE PROCEDURE getPostsOfFriends
(IN user int)
BEGIN
    SELECT username, article_text AS Article, post_date AS Date
    FROM article, user
    WHERE user.userId = article.userId AND user.userId IN
    (
        SELECT userId
        FROM user
        WHERE userId IN
        (
            SELECT fromuser
            FROM friendship
            WHERE touser = user AND accepted = TRUE
            UNION
            SELECT touser
            FROM friendship
            WHERE fromuser = user AND accepted = TRUE
        )
    );
END//

call getPostsOfFriends(1);

/*************comments of a user ************/
SELECT  article_text AS 'Article', comment_text 'Comment'
from article, comments
where comments.user = 2 AND article.id = comments.article;

mysql> SELECT  article_text AS 'Article', comment_text 'Comment'
    -> from article, comments
    -> where comments.user = 2 AND article.id = comments.article;
+------------------------------------------+------------------------------+
| Article                                  | Comment                      |
+------------------------------------------+------------------------------+
| Hello friends!                           | Hello there.. How do you do? |
| Good Morning every one! have a nice day! | hahaha                       |
| friends I am going to pune tomorrow      | for how long dear?           |
+------------------------------------------+------------------------------+

/********* count friend requests *********/
SELECT COUNT(*) AS 'Total Friend requests' FROM friendship
WHERE touser = 2 AND accepted = false;

/********* count friends *********/
SELECT COUNT(*) AS 'Total Friends' FROM friendship
WHERE (fromuser = 2 OR touser = 2) AND accepted = true;

/********* count friends *********/
SELECT COUNT(*) AS 'Total Posts' FROM article
WHERE userId = 2;

/********* count friends *********/
SELECT COUNT(*) AS 'Total Comments' FROM comments
WHERE user = 2;


/*********************************************************************/

user

+--------+--------------+----------+----------+----------+--------+----------------------+------------+------------------------------------+
| userId | username     | fname    | mname    | lname    | gender | address              | phone      | email                              |
+--------+--------------+----------+----------+----------+--------+----------------------+------------+------------------------------------+
|      1 | DJ Rohan     | Rohan    | NULL     | NULL     | M      | Mapusa, Goa          | 9090909090 | rohan.xxyyzz.9090@something.com    |
|      2 | Savio        | Savio    | NULL     | Ferns    | M      | Mapusa, Goa          | 1090909090 | savio.xxyyzz.9090@something.com    |
|      3 | Lovely$uzane | Suzane   | NULL     | Dsauza   | F      | Ponda, Goa           | 1090909000 | suzane.xxyyzz.9090@something.com   |
|      4 | sanket.natu  | Sanket   | NULL     | Natu     | M      | Khorlim, Mapusa, Goa | 8993432424 | sanket.xxyyzz.9090@something.com   |
|      5 | Karishman    | Karishma | Shrikant | Parsekar | F      | Khorlim, Mapusa, Goa | 1090909000 | karishma.xxyyzz.9090@something.com |
+--------+--------------+----------+----------+----------+--------+----------------------+------------+------------------------------------+


friendship

+----+----------+--------+----------+
| id | fromuser | touser | accepted |
+----+----------+--------+----------+
|  1 |        1 |      2 |        1 |
|  2 |        1 |      3 |        1 |
|  4 |        2 |      3 |        0 |
|  6 |        5 |      1 |        0 |
|  7 |        5 |      2 |        1 |
|  8 |        5 |      3 |        1 |
|  9 |        5 |      4 |        0 |
| 12 |        4 |      1 |        0 |
| 13 |        4 |      2 |        1 |
+----+----------+--------+----------+


article

+----+--------+------------------------------------------+---------------------+
| id | userId | article_text                             | post_date           |
+----+--------+------------------------------------------+---------------------+
|  1 |      1 | Hello friends!                           | 2016-06-14 11:57:27 |
|  2 |      1 | Good Morning every one! have a nice day! | 2016-06-15 22:52:53 |
|  3 |      1 | Good Morning every one! have a nice day! | 2016-06-15 22:54:14 |
|  4 |      2 | Feeling energetic today!                 | 2016-06-15 22:54:14 |
|  5 |      3 | Good night friends                       | 2016-06-15 22:54:14 |
|  6 |      4 | Cmon India!                              | 2016-06-15 22:54:15 |
|  7 |      4 | friends I am going to pune tomorrow      | 2016-06-15 23:42:30 |
+----+--------+------------------------------------------+---------------------+


comments

+----+---------+------+------------------------------+---------------------+
| id | article | user | comment_text                 | comment_time        |
+----+---------+------+------------------------------+---------------------+
|  1 |       1 |    2 | Hello there.. How do you do? | 2016-06-14 12:36:38 |
|  3 |       1 |    3 | hello dear                   | 2016-06-15 23:28:19 |
|  4 |       3 |    2 | hahaha                       | 2016-06-15 23:30:44 |
|  6 |       7 |    2 | for how long dear?           | 2016-06-15 23:46:44 |
+----+---------+------+------------------------------+---------------------+