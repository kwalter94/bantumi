-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(64) NOT NULL UNIQUE,
    fullname VARCHAR(256),
    email VARCHAR(256),
    avatar VARCHAR(512),
    address VARCHAR(512)
);
-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE users;