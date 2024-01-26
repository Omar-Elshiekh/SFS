DROP DATABASE IF EXISTS coursework;

CREATE DATABASE coursework;
USE coursework;
-- This is the Course table
DROP TABLE IF EXISTS Course;
CREATE TABLE Course (
Crs_Code 	INT UNSIGNED NOT NULL,
Crs_Title 	VARCHAR(255) NOT NULL,
Crs_Enrollment INT UNSIGNED,
PRIMARY KEY (Crs_code));
INSERT INTO Course VALUES 
(100,'BSc Computer Science', 150),
(101,'BSc Computer Information Technology', 20),
(200, 'MSc Data Science', 100),
(201, 'MSc Security', 30),
(210, 'MSc Electrical Engineering', 70),
(211, 'BSc Physics', 100);
-- This is the student table definition
DROP TABLE IF EXISTS Student;
CREATE TABLE Student (
URN INT UNSIGNED NOT NULL,
Stu_FName 	VARCHAR(255) NOT NULL,
Stu_LName 	VARCHAR(255) NOT NULL,
Stu_DOB 	DATE,
Stu_Phone 	VARCHAR(12),
Stu_Course	INT UNSIGNED NOT NULL,
Stu_Type 	ENUM('UG', 'PG'),
PRIMARY KEY (URN),
FOREIGN KEY (Stu_Course) REFERENCES Course (Crs_Code)
ON DELETE RESTRICT);
INSERT INTO Student VALUES
(612345, 'Sara', 'Khan', '2002-06-20', '01483112233', 100, 'UG'),
(612346, 'Pierre', 'Gervais', '2002-03-12', '01483223344', 100, 'UG'),
(612347, 'Patrick', 'O-Hara', '2001-05-03', '01483334455', 100, 'UG'),
(612348, 'Iyabo', 'Ogunsola', '2002-04-21', '01483445566', 100, 'UG'),
(612349, 'Omar', 'Sharif', '2001-12-29', '01483778899', 100, 'UG'),
(612350, 'Yunli', 'Guo', '2002-06-07', '01483123456', 100, 'UG'),
(612351, 'Costas', 'Spiliotis', '2002-07-02', '01483234567', 100, 'UG'),
(612352, 'Tom', 'Jones', '2001-10-24',  '01483456789', 101, 'UG'),
(612353, 'Simon', 'Larson', '2002-08-23', '01483998877', 101, 'UG'),
(612354, 'Sue', 'Smith', '2002-05-16', '01483776655', 101, 'UG');
DROP TABLE IF EXISTS Undergraduate;
CREATE TABLE Undergraduate (
UG_URN 	INT UNSIGNED NOT NULL,
UG_Credits   INT NOT NULL,
CHECK (60 <= UG_Credits <= 150),
PRIMARY KEY (UG_URN),
FOREIGN KEY (UG_URN) REFERENCES Student(URN)
ON DELETE CASCADE);
INSERT INTO Undergraduate VALUES
(612345, 120),
(612346, 90),
(612347, 150),
(612348, 120),
(612349, 120),
(612350, 60),
(612351, 60),
(612352, 90),
(612353, 120),
(612354, 90);
DROP TABLE IF EXISTS Postgraduate;
CREATE TABLE Postgraduate (
PG_URN 	INT UNSIGNED NOT NULL,
Thesis  VARCHAR(512) NOT NULL,
PRIMARY KEY (PG_URN),
FOREIGN KEY (PG_URN) REFERENCES Student(URN)
ON DELETE CASCADE);
-- Please add your table definitions below this line.......
CREATE TABLE HOBBY(
Hobby_Name VARCHAR(255) NOT NULL,
NumberOfPlayers INT NOT NULL,
PRIMARY KEY(Hobby_Name)
);
INSERT INTO HOBBY (Hobby_Name, NumberOfPlayers) VALUES
('Football', 22),
('Reading', 5),
('Climbing', 2),
('Tennis', 15),
('Rugby', 10);

CREATE TABLE PLAYS(
URN INT UNSIGNED NOT NULL,
Hobby_Name VARCHAR(255) NOT NULL,
Frequency ENUM('daily', 'weekly', 'monthly', 'occasionally'),
Level ENUM('beginner', 'intermediate', 'advanced'),
Preference ENUM('low', 'medium', 'high'),
PRIMARY KEY (URN,Hobby_Name),
FOREIGN KEY(URN) REFERENCES student (URN) ON DELETE CASCADE,
FOREIGN KEY (Hobby_Name) REFERENCES HOBBY (Hobby_Name) ON DELETE CASCADE
);

INSERT INTO PLAYS (URN, Hobby_Name, Frequency, Level, Preference) VALUES
 (612345, 'Football', 'weekly', 'beginner', 'low'),
 (612346, 'Climbing', 'monthly', 'intermediate', 'medium'),
 (612347, 'Rugby', 'daily', 'advanced', 'high'),
 (612348, 'Tennis', 'weekly', 'intermediate', 'medium'),
 (612349, 'Reading', 'daily', 'beginner', 'low');
 CREATE TABLE TEAM(
Team_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Team_Name VARCHAR(255) NOT NULL,
NumberOfPlayers INT UNSIGNED NOT NULL,
CHECK (NumberOfPlayers > 10),
PRIMARY KEY (Team_ID)
);
INSERT INTO TEAM (Team_Name, NumberOfPlayers) VALUES
('Turkish De Ligt', 20),
('Kinder Mbeumo', 15),
('Who Ate Depays', 12),
('Dunk Those Busquets', 25),
('Borussia Teeth', 18);

CREATE TABLE TEAM_MEMBERSHIP(
Memb_ID INT NOT NULL AUTO_INCREMENT,
Height FLOAT NOT NULL,
Weight FLOAT NOT NULL,
Position VARCHAR(10) NOT NULL,
Age INT UNSIGNED NOT NULL,
CHECK (Age >= 18),
Memb_Type ENUM('Standard', 'Premium') NOT NULL,
URN INT UNSIGNED NOT NULL UNIQUE,
Team_ID INT UNSIGNED NOT NULL,
PRIMARY KEY (Memb_ID),
FOREIGN KEY (URN) REFERENCES Student (URN) ON DELETE CASCADE,
FOREIGN KEY (Team_ID) REFERENCES TEAM(Team_ID) ON DELETE CASCADE
);
INSERT INTO TEAM_MEMBERSHIP (Height, Weight, Position, Age, Memb_Type, URN, Team_ID) VALUES
(1.75, 70, 'Forward', 20, 'Standard', 612345, 1),
(1.78, 68, 'Midfielder', 21, 'Standard', 612350,1),
(1.76, 72, 'Forward', 21, 'Standard', 612351, 1),
(1.82, 79, 'Midfielder', 21, 'Standard', 612352, 1),
(1.68, 65, 'Midfielder', 21, 'Premium', 612346, 2),
(1.80, 75, 'Defender', 22, 'Standard', 612347, 3),
(1.85, 80, 'Goalkeeper', 23, 'Premium', 612348, 4),
(1.70, 72, 'Forward', 24, 'Standard', 612349, 5);
 CREATE TABLE GAME(
Game_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Game_Date DATE,
Game_Time TIME,
Game_Location VARCHAR(255),
Team_ID INT UNSIGNED NOT NULL,
PRIMARY KEY (Game_ID),
FOREIGN KEY (Team_ID) REFERENCES TEAM(Team_ID) ON DELETE CASCADE,
CONSTRAINT chk_game_time CHECK (MINUTE(Game_Time) IN (0, 30))
);
INSERT INTO GAME (Game_ID,Game_Date, Game_Time, Game_Location, Team_ID) VALUES
(1, '2023-12-20', '14:30', 'Camp Zoo', 1),
(2, '2023-12-22', '16:00', 'Banda Metropolitano', 2),
(3, '2023-12-24', '10:00', 'Musty Field', 3),
(4, '2023-12-26', '11:30', 'AGP 3', 4),
(5, '2023-12-28', '13:00', 'Arena E', 5),
( 6, '2023-12-23', '03:30', 'Camp Zoo', 2);





CREATE TABLE COACH(
Coach_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Coach_FName VARCHAR(255),
Coach_LName VARCHAR(255) NOT NULL,
PRIMARY KEY (Coach_ID));
INSERT INTO COACH (Coach_FName, Coach_LName) VALUES
('Josep', 'Gvardiola'),
('Jurgen', 'Norbert'),
('Thomas', 'Shelby'),
('Micheal', 'Scofield'),
('Lincoln', 'Burrows');


CREATE TABLE QUALIFICATIONS(
Coach_ID INT UNSIGNED NOT NULL,
Qualification_Name VARCHAR(255) NOT NULL,
PRIMARY KEY (Coach_ID, Qualification_Name),
FOREIGN KEY (Coach_ID) REFERENCES COACH(Coach_ID) ON DELETE CASCADE
);
INSERT INTO QUALIFICATIONS (Coach_ID, Qualification_Name) VALUES
(1, 'UEFA A License'),
(1,'FIFA Pro License'),
(2, 'Level 3 Coaching Certificate'),
(3, 'Masters in Sports Science'),
(4, 'National Coaching Certification'),
(5, 'FIFA Pro License');


CREATE TABLE COACHING_PLAN(
CoachingPlan_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Date DATE,
Time TIME,
Location VARCHAR(255),
Plan_Type ENUM('Private', 'Group'),
PRIMARY KEY (CoachingPlan_ID)
);
INSERT INTO COACHING_PLAN (Date, Time, Location, Plan_Type) VALUES
('2023-12-20', '09:00', 'Field 1', 'Group'),
('2023-12-22', '10:30', 'Stadium X', 'Private'),
('2023-12-24', '14:00', 'Court Y', 'Group'),
('2023-12-26', '12:30', 'Poolside Z', 'Private'),
('2023-12-28', '16:30', 'Arena A', 'Group');

-- Advanced Tasks
CREATE TABLE COACHING_SESSION(
CoachingSession_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Coach_ID INT UNSIGNED NOT NULL,
CoachingPlan_ID INT UNSIGNED NOT NULL,
Memb_ID INT NOT NULL,
Session_Date DATE,
Session_Time TIME,
Session_Location VARCHAR(255),
Session_Type ENUM('Group', 'Private'),
Skill_Focus VARCHAR(255) NOT NULL,
PRIMARY KEY (CoachingSession_ID),
FOREIGN KEY (Coach_ID) REFERENCES COACH (Coach_ID),
FOREIGN KEY (CoachingPlan_ID) REFERENCES COACHING_PLAN(CoachingPlan_ID) ON DELETE CASCADE,
FOREIGN KEY (Memb_ID) REFERENCES TEAM_MEMBERSHIP(Memb_ID) ON DELETE CASCADE
);
INSERT INTO COACHING_SESSION (Coach_ID, CoachingPlan_ID, Memb_ID, Session_Date, Session_Time, Session_Location, Session_Type, Skill_Focus)
VALUES 
(1, 1, 1, '2023-12-20', '14:00', 'Field A', 'Group', 'Passing Techniques'),
(2, 2, 2, '2023-12-21', '16:30', 'Stadium B', 'Private', 'Shooting Drills'),
(3, 3, 3, '2023-12-22', '10:00', 'Training Facility', 'Group', 'Defensive Strategies'),
(4, 4, 4, '2023-12-23', '11:30', 'Sports Complex', 'Private', 'Tactical Playbook'),
(5, 5, 5, '2023-12-24', '13:30', 'Arena C', 'Group', 'Fitness Training');


CREATE TABLE PARTICIPATION(
Team_ID INT UNSIGNED NOT NULL,
Game_ID INT UNSIGNED NOT NULL,
Scoreline VARCHAR(3) NOT NULL,
Outcome ENUM('Win', 'Loss','Draw') NOT NULL,
PRIMARY KEY (Team_ID, Game_ID),
FOREIGN KEY (Team_ID) REFERENCES TEAM(Team_ID) ON DELETE CASCADE,
FOREIGN KEY (Game_ID) REFERENCES GAME(Game_ID) ON DELETE CASCADE
);
INSERT INTO PARTICIPATION (Team_ID, Game_ID, Scoreline, Outcome) VALUES
(1, 1, '2-1', 'Win'),
(2, 2, '1-3', 'Loss'),
(3, 3, '0-0', 'Draw'),
(4, 4, '3-2', 'Win'),
(5, 5, '1-1', 'Draw');