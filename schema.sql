PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE files (id integer primary key autoincrement, uniqueid text, type text, filename text, description text, downloaded int, uploaded datetime, expire datetime, payment_address text, receive_address text, price int, expired int);
CREATE TABLE dependencies (id integer primary key autoincrement, file_id integer, filename text);
CREATE TABLE btc_queue (id integer primary key autoincrement, file_id integer, expect_amount, expect_address, pay_amount, pay_address, created datetime, processed datetime, result text);
COMMIT;
