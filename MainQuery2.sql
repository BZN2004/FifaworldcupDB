-- ============================================================
-- FIFA 2026 World Cup Database
-- Group Members: Andile Mahlangu, Muzomuhle Manaka, Rian Puth, Bandile Ndlangamndla
-- ============================================================

-- SECTION 1: DDL - Database & Table Creation
-- Switch to master so you're not inside the database
USE master;
GO

-- Put the database in single-user mode and drop it
IF DB_ID('Fifa2026_WorldCupDB') IS NOT NULL
BEGIN
    ALTER DATABASE Fifa2026_WorldCupDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Fifa2026_WorldCupDB;
END
GO

-- Create the database (without multi-statement transaction issues)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'Fifa2026_WorldCupDB')
BEGIN
    CREATE DATABASE Fifa2026_WorldCupDB
    ON PRIMARY (
        NAME = TournamentData1,
        --Change FILENAME'S TO YOUR SPECIFIC FILEPATH
      --  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\TournamentData1.mdf',
        SIZE = 15MB,
        MAXSIZE = 500MB,
        FILEGROWTH = 5MB
    ),
    (
        NAME = TournamentData2,
       -- FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\TournamentData2.ndf',
        SIZE = 10MB,
        MAXSIZE = 50MB,
        FILEGROWTH = 5MB
    )
    LOG ON (
        NAME = Fifa2026_WorldCup_Log,
       -- FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\Fifa2026_WorldCup_Log.ldf',
        SIZE = 10MB,
        MAXSIZE = 50MB,
        FILEGROWTH = 5MB
    );
END;
GO

USE Fifa2026_WorldCupDB;
GO

-- Drop existing objects if they exist (in correct order to respect foreign keys)
IF OBJECT_ID('PlayerStats', 'U') IS NOT NULL DROP TABLE PlayerStats;
IF OBJECT_ID('Tickets', 'U') IS NOT NULL DROP TABLE Tickets;
IF OBJECT_ID('Matches', 'U') IS NOT NULL DROP TABLE Matches;
IF OBJECT_ID('Staff', 'U') IS NOT NULL DROP TABLE Staff;
IF OBJECT_ID('Players', 'U') IS NOT NULL DROP TABLE Players;
IF OBJECT_ID('Teams', 'U') IS NOT NULL DROP TABLE Teams;
IF OBJECT_ID('Fans', 'U') IS NOT NULL DROP TABLE Fans;
IF OBJECT_ID('Stadiums', 'U') IS NOT NULL DROP TABLE Stadiums;
IF OBJECT_ID('Countries', 'U') IS NOT NULL DROP TABLE Countries;
GO

-- Create Tables
CREATE TABLE Countries (
    CountryID INT PRIMARY KEY,
    CountryName VARCHAR(50) NOT NULL
);

CREATE TABLE Stadiums (
    StadiumID INT PRIMARY KEY,
    StadiumName VARCHAR(50) NOT NULL,
    Capacity INT NOT NULL,
    City VARCHAR(50)
);

CREATE TABLE Fans (
    FanID INT PRIMARY KEY,
    FanName VARCHAR(50),
    ContactInfo VARCHAR(200)  -- Increased size for encrypted data
);

CREATE TABLE Teams (
    TeamID INT PRIMARY KEY,
    CountryID INT FOREIGN KEY REFERENCES Countries(CountryID),
    TeamName VARCHAR(30) NOT NULL
);

CREATE TABLE Players (
    PlayerID INT PRIMARY KEY,
    TeamID INT FOREIGN KEY REFERENCES Teams(TeamID),
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30),
    DateOfBirth DATE NOT NULL,
    Position VARCHAR(10)
);

CREATE TABLE Staff (
    StaffMemberID INT PRIMARY KEY,
    TeamID INT FOREIGN KEY REFERENCES Teams(TeamID),
    FirstName VARCHAR(20) NOT NULL,
    LastName VARCHAR(20),
    TeamRole VARCHAR(20)
);

CREATE TABLE Matches (
    MatchID INT PRIMARY KEY,
    Team1ID INT FOREIGN KEY REFERENCES Teams(TeamID),
    Team2ID INT FOREIGN KEY REFERENCES Teams(TeamID),
    StadiumID INT FOREIGN KEY REFERENCES Stadiums(StadiumID),
    MatchTime Time NOT NULL,
    MatchDate Date NOT NULL,
    TournamentStage VARCHAR(50) NOT NULL,
    MatchStatus VARCHAR(20) DEFAULT 'Scheduled',
    Team1Goals INT DEFAULT 0,
    Team2Goals INT DEFAULT 0
);

CREATE TABLE Tickets (
    TicketID INT PRIMARY KEY,
    MatchID INT FOREIGN KEY REFERENCES Matches(MatchID),
    FanID INT FOREIGN KEY REFERENCES Fans(FanID),
    SeatNumber VARCHAR(10) NOT NULL,
    Price MONEY NOT NULL,
    PurchaseDate Date NOT NULL,
    TicketStatus VARCHAR(20) DEFAULT 'Booked',
    CONSTRAINT chk_TicketStatus CHECK (TicketStatus IN ('Booked', 'Used', 'Cancelled'))
);

CREATE TABLE PlayerStats (
    PlayerStatsID INT PRIMARY KEY,
    PlayerID INT FOREIGN KEY REFERENCES Players(PlayerID),
    MatchID INT FOREIGN KEY REFERENCES Matches(MatchID),
    MinutesPlayed INT DEFAULT 0,
    Goals INT DEFAULT 0,
    Assists INT DEFAULT 0,
    YellowCards INT DEFAULT 0,
    RedCards INT DEFAULT 0,
    ShotsOnTarget INT DEFAULT 0,
    PassesCompleted INT DEFAULT 0,
    CONSTRAINT UQ_PlayerStats_FK1_FK2 UNIQUE (PlayerID,MatchID) 
);
GO

-- Authentication
-- Drop existing logins and users if they exist
USE master;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'SystemAdminLogin')
    DROP LOGIN SystemAdminLogin;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'OperatorLogin')
    DROP LOGIN OperatorLogin;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'AnalystLogin')
    DROP LOGIN AnalystLogin;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'AuditorLogin')
    DROP LOGIN AuditorLogin;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'FansLogin')
    DROP LOGIN FansLogin;
GO

-- Create Logins
CREATE LOGIN SystemAdminLogin WITH Password = 'Password123';
CREATE LOGIN OperatorLogin WITH Password = 'Password123';
CREATE LOGIN AnalystLogin WITH Password = 'Password123';
CREATE LOGIN AuditorLogin WITH Password = 'Password123';
CREATE LOGIN FansLogin WITH Password = 'Password123';
GO

USE Fifa2026_WorldCupDB;
GO

-- Drop existing users if they exist
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'SystemAdminUser')
    DROP USER SystemAdminUser;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'OperatorUser')
    DROP USER OperatorUser;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AnalystUser')
    DROP USER AnalystUser;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AuditorUser')
    DROP USER AuditorUser;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'FanUser')
    DROP USER FanUser;
GO

-- Create Users
CREATE USER SystemAdminUser FOR LOGIN SystemAdminLogin;
CREATE USER OperatorUser For Login OperatorLogin;
CREATE USER AnalystUser For Login AnalystLogin;
CREATE USER AuditorUser FOR Login AuditorLogin;
CREATE USER FanUser FOR LOGIN FansLogin;
GO

-- Drop existing roles if they exist
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'SystemAdminRole')
    DROP ROLE SystemAdminRole;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'OperatorRole')
    DROP ROLE OperatorRole;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AnalystRole')
    DROP ROLE AnalystRole;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AuditorRole')
    DROP ROLE AuditorRole;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'FansRole')
    DROP ROLE FansRole;
GO

-- Create roles
CREATE ROLE SystemAdminRole;
CREATE ROLE OperatorRole;
CREATE ROLE AnalystRole;
CREATE ROLE AuditorRole;
CREATE ROLE FansRole;
GO

-- Add users to roles
ALTER ROLE SystemAdminRole ADD MEMBER SystemAdminUser;
ALTER ROLE OperatorRole ADD MEMBER OperatorUser;
ALTER ROLE AnalystRole ADD MEMBER AnalystUser;
ALTER ROLE AuditorRole ADD MEMBER AuditorUser;
ALTER ROLE FansRole ADD MEMBER FanUser;
GO

-- Permissions
GRANT CONTROL ON DATABASE::Fifa2026_WorldCupDB TO SystemAdminRole;
GRANT INSERT, UPDATE ON Players TO OperatorRole;
GRANT INSERT, UPDATE ON Matches TO OperatorRole;
GRANT INSERT, UPDATE ON Tickets TO OperatorRole;
GRANT INSERT, UPDATE ON Countries TO OperatorRole;
GRANT INSERT, UPDATE ON Stadiums TO OperatorRole;
GRANT INSERT, UPDATE ON Staff TO OperatorRole;
GRANT INSERT, UPDATE ON Fans TO OperatorRole;
GRANT SELECT ON Players TO AnalystRole;
GRANT SELECT ON Matches TO AnalystRole;
GRANT SELECT ON PlayerStats TO AnalystRole;
GRANT SELECT ON Tickets TO AnalystRole;
GRANT SELECT ON Countries TO AnalystRole;
GRANT SELECT ON Stadiums TO AnalystRole;
GRANT SELECT ON DATABASE::Fifa2026_WorldCupDB TO AuditorRole;
GRANT EXECUTE TO FansRole;
GO

-- SECTION 2: DML - Data Insertion
USE Fifa2026_WorldCupDB;
GO

INSERT INTO Countries (CountryID,CountryName)
VALUES
(1,'England'),(2,'Republic of South Africa'),
(3,'Federative Republic of Brazil'),(4,'French Republic'),
(5,'Argentine Republic'),(6,'Portugeuses Republic'),(7,'Republic of Senegal'),
(8,'Republic of Ghana'),(9,'Japan'),(10,'Federal Republic of Germany'),
(11,'Kingdom of Spain'),(12,'Republic of Korea');

INSERT INTO Stadiums (StadiumID,StadiumName,Capacity,City)
VALUES
(1,'Metlife Stadium',82500,'East Rutherford'),(2,'AT&T Stadium',80000,'Arlington'),(3,'Mercedes-Benz Stadium',71000,'Atlanta'),(4,'NRG Stadium',72000,'Houston'),(5,'SoFi Stadium',70000,'Inglewood'),(6,'Levis Stadium',68500,'Santa Clara'),(7,'Gillete Stadium',65800,'Foxborough'),(8,'Lincoln Financial Field',69800,'Philadelphia'),(9,'Lumen Field',68000,'Seattle'),(10,'Hard Rock Stadium',65300,'Miami Gardens'),(11,'Arrowhead Stadium',76400,'Kansas City'),(12,'BMO Field',44300,'Toronto'),(13,'BC Place',48800,'Vancouver'),(14,'Estadio Azteca',87500,'Mexico City'),(15,'Estadio Akron',48000,'Guadalajara'),(16,'Estadio BBVA',53500,'Monterrey');

INSERT INTO Fans (FanID,FanName,ContactInfo)
VALUES
(1,'Liam Johnson','+27 82 345 6712'),(2,'Noah Smith','+1 202 555 0147'),(3,'Oliver Williams','+44 7700 900123'),(4,'Elijah Brown','+61 412 345 678'),(5,'James Jones','+91 98765 43210'),(6,'William Garcia','+34 612 345 678'),(7,'Benjamin Miller','+49 1512 3456789'),(8,'Lucas Davis','+33 6 12 34 56 78'),(9,'Henry Rodriguez','+55 11 91234 5678'),(10,'Alexander Martinez','+52 55 1234 5678'),(11,'Mason Hernandez','+27 73 876 5432'),(12,'Michael Lopez','+1 303 555 0198'),(13,'Ethan Gonzalez','+44 7911 123456'),(14,'Daniel Wilson','+61 423 456 789'),(15,'Jacob Anderson','+91 87654 32109'),(16,'Logan Thomas','+34 623 456 789'),(17,'Jackson Taylor','+49 160 9876543'),(18,'Sebastian Moore','+33 7 98 76 54 32'),(19,'Jack Jackson','+55 21 99876 5432'),(20,'Aiden Martin','+52 81 2345 6789'),(21,'Owen Lee','+27 72 567 8901'),(22,'Samuel Perez','+1 415 555 0133'),(23,'Matthew Thompson','+44 7800 111222'),(24,'Joseph White','+61 434 567 890'),(25,'Levi Harris','+91 76543 21098'),(26,'David Sanchez','+34 634 567 890'),(27,'John Clark','+49 170 1234567'),(28,'Wyatt Ramirez','+33 6 87 65 43 21'),(29,'Carter Lewis','+55 31 98765 4321'),(30,'Julian Robinson','+52 33 3456 7890'),(31,'Grayson Walker','+27 83 678 9012'),(32,'Leo Young','+1 646 555 0172'),(33,'Jayden Allen','+44 7700 123789'),(34,'Gabriel King','+61 445 678 901'),(35,'Isaac Wright','+91 65432 10987'),(36,'Lincoln Scott','+34 645 678 901'),(37,'Anthony Torres','+49 152 2345678'),(38,'Hudson Nguyen','+33 7 76 54 32 10'),(39,'Dylan Hill','+55 41 97654 3210'),(40,'Ezra Flores','+52 55 4567 8901'),(41,'Thomas Green','+27 74 789 0123'),(42,'Charles Adams','+1 212 555 0168'),(43,'Christopher Nelson','+44 7911 654321'),(44,'Jaxon Baker','+61 456 789 012'),(45,'Maverick Hall','+91 54321 09876'),(46,'Josiah Rivera','+34 656 789 012'),(47,'Isaiah Campbell','+49 171 3456789'),(48,'Andrew Mitchell','+33 6 65 43 21 09'),(49,'Joshua Carter','+55 51 96543 2109'),(50,'Nathan Roberts','+52 81 5678 9012');

INSERT INTO Teams (TeamID,CountryID,TeamName) 
VALUES
(1,1,'England'),(2,2,'South Africa'),(3,3,'Brazil'),(4,4,'France'),(5,5,'Argentina'),(6,6,'Portugal'),(7,7,'Senegal'),(8,8,'Ghana'),(9,9,'Japan'),(10,10,'Germany'),(11,11,'Spain'),(12,12,'South Korea');

INSERT INTO Players (PlayerID,TeamID,FirstName,LastName,DateOfBirth,Position)
VALUES
(100,1,'Jordan','Pickford','1994-03-07','GK'),(101,1,'Dean','Henderson','1997-03-12','GK'),(102,1,'Marc','Guehi','2000-07-13','CB'),(103,1,'Trent','Alexander-Arnold','1998-10-07','FB'),(104,1,'Tino','Livramento','2002-11-12','FB'),(105,1,'John','Stones','1994-05-28','CB'),(106,1,'Reece','James','1999-12-08','FB'),(107,1,'Trevor','Chalobah','1999-07-05','CB'),(108,1,'Dan','Burn','1992-05-09','CB'),(109,1,'Declan','Rice','1999-01-14','CDM'),(110,1,'Jude','Bellingham','2003-06-29','CM'),(111,1,'Cole','Palmer','2002-05-06','CAM'),(112,1,'Phil','Foden','2000-05-28','CAM'),(113,1,'Eberechi','Eze','1998-06-29','CAM'),(114,1,'Harry','Kane','1993-07-28','ST'),(115,1,'Anthony','Gordon','2001-02-24','LW'),(116,1,'Bukayo','Saka','2001-09-05','RW'),(117,1,'Ivan','Toney','1996-03-16','ST'),(120,2,'Ronwen','Williams','1992-01-21','GK'),(121,2,'Sipho','Chaine','1996-12-14','GK'),(122,2,'Khuliso','Mudau','1995-04-26','FB'),(123,2,'Aubrey','Modiba','1995-07-22','FB'),(124,2,'Grant','Kekana','1992-10-31','CB'),(125,2,'Nkosinathi','Sibisi','1995-09-22','CB'),(126,2,'Teboho','Mokoena','1997-01-10','CDM'),(127,2,'Thalente','Mbatha','2000-05-15','CM'),(128,2,'Themba','Zwane','1989-08-03','CAM'),(129,2,'Patrick','Maswanganyi','1998-04-23','CAM'),(130,2,'Relebohile','Mofokeng','2004-10-08','LW'),(131,2,'Oswin','Appollis','2001-08-25','RW'),(132,2,'Percy','Tau','1994-05-13','RW'),(133,2,'Lyle','Foster','2000-09-03','ST'),(134,2,'Elias','Mokwana','1999-09-07','LW'),(135,2,'Iqraam','Rayners','1995-12-19','ST'),(136,2,'Jayden','Adams','2001-05-05','CM'),(137,2,'Siyanda','Xulu','1991-12-30','CB'),(140,3,'Alisson','Becker','1992-10-02','GK'),(141,3,'Ederson','Moraes','1993-08-17','GK'),(142,3,'Danilo',NULL,'1991-07-15','FB'),(143,3,'Gabriel','Magalhaes','1997-12-19','CB'),(144,3,'Marquinhos',NULL,'1994-05-14','CB'),(145,3,'Eder','Militao','1998-01-18','CB'),(146,3,'Casemiro',NULL,'1992-02-23','CDM'),(147,3,'Bruno','Guimaraes','1997-11-16','CM'),(148,3,'Lucas','Paqueta','1997-08-27','CAM'),(149,3,'Vinicius','Junior','2000-07-12','LW'),(150,3,'Rodrygo',NULL,'2001-01-09','RW'),(151,3,'Raphinha',NULL,'1996-12-14','RW'),(152,3,'Richarlison',NULL,'1997-05-10','ST'),(153,3,'Gabriel','Jesus','1997-04-03','ST'),(154,3,'Neymar',NULL,'1992-02-05','CAM'),(155,3,'Endrick',NULL,'2006-07-21','ST'),(156,3,'Antony',NULL,'2000-02-24','RW'),(157,3,'Joelinton',NULL,'1996-08-14','CM'),(160,4,'Mike','Maignan','1995-07-03','GK'),(161,4,'Theo','Hernandez','1997-10-06','FB'),(162,4,'Jules','Kounde','1998-11-12','CB'),(163,4,'Dayot','Upamecano','1998-10-27','CB'),(164,4,'William','Saliba','2001-03-24','CB'),(165,4,'Aurelien','Tchouameni','2000-01-27','CDM'),(166,4,'Adrien','Rabiot','1995-04-03','CM'),(167,4,'Antoine','Griezmann','1991-03-21','CAM'),(168,4,'Ousmane','Dembele','1997-05-15','RW'),(169,4,'Kingsley','Coman','1996-06-13','LW'),(170,4,'Kylian','Mbappe','1998-12-20','ST'),(171,4,'Olivier','Giroud','1986-09-30','ST'),(172,4,'Randal','Kolo Muani','1998-12-05','ST'),(173,4,'Marcus','Thuram','1997-08-06','ST'),(174,4,'Eduardo','Camavinga','2002-11-10','CM'),(175,4,'Warren','Zaire-Emery','2006-03-08','CM'),(176,4,'Benjamin','Pavard','1996-03-28','FB'),(177,4,'Ibrahima','Konate','1999-05-25','CB'),(180,5,'Emiliano','Martinez','1992-09-02','GK'),(181,5,'Nahuel','Molina','1998-04-06','FB'),(182,5,'Cristian','Romero','1998-04-27','CB'),(183,5,'Nicolas','Otamendi','1988-02-12','CB'),(184,5,'Marcos','Acuna','1991-10-28','FB'),(185,5,'Enzo','Fernandez','2001-01-17','CM'),(186,5,'Rodrigo','De Paul','1994-05-24','CM'),(187,5,'Alexis','Mac Allister','1998-12-24','CM'),(188,5,'Lionel','Messi','1987-06-24','CAM'),(189,5,'Angel','Di Maria','1988-02-14','RW'),(190,5,'Lautaro','Martinez','1997-08-22','ST'),(191,5,'Julian','Alvarez','2000-01-31','ST'),(192,5,'Paulo','Dybala','1993-11-15','CAM'),(193,5,'Giovani','Lo Celso','1996-04-09','CM'),(194,5,'Nicolas','Gonzalez','1998-04-06','LW'),(195,5,'German','Pezzella','1991-06-27','CB'),(196,5,'Leandro','Paredes','1994-06-29','CDM'),(197,5,'Exequiel','Palacios','1998-10-05','CM'),(200,6,'Diogo','Costa','1999-09-19','GK'),(201,6,'Joao','Cancelo','1994-05-27','FB'),(202,6,'Ruben','Dias','1997-05-14','CB'),(203,6,'Pepe',NULL,'1983-02-26','CB'),(204,6,'Nuno','Mendes','2002-06-19','FB'),(205,6,'Joao','Palhinha','1995-07-09','CDM'),(206,6,'Bruno','Fernandes','1994-09-08','CAM'),(207,6,'Bernardo','Silva','1994-08-10','CM'),(208,6,'Vitor','Ferreira','2000-02-13','CM'),(209,6,'Rafael','Leao','1999-06-10','LW'),(210,6,'Cristiano','Ronaldo','1985-02-05','ST'),(211,6,'Goncalo','Ramos','2001-06-20','ST'),(212,6,'Rodrigo','Mora','2007-05-05','ST'),(213,6,'Pedro','Neto','2000-03-09','RW'),(214,6,'Joao','Felix','1999-11-10','CAM'),(215,6,'Ruben','Neves','1997-03-13','CM'),(216,6,'Antonio','Silva','2003-10-30','CB'),(217,6,'Joao','Mario','1993-01-19','CM'),(220,7,'Edouard','Mendy','1992-03-01','GK'),(221,7,'Kalidou','Koulibaly','1991-06-20','CB'),(222,7,'Abdou','Diallo','1996-05-04','CB'),(223,7,'Youssouf','Sabaly','1993-03-05','FB'),(224,7,'Fode','Ballo-Toure','1997-01-03','FB'),(225,7,'Idrissa','Gueye','1989-09-26','CDM'),(226,7,'Pape','Gueye','1999-01-24','CM'),(227,7,'Nampalys','Mendy','1992-06-23','CM'),(228,7,'Sadio','Mane','1992-04-10','LW'),(229,7,'Ismaila','Sarr','1998-02-25','RW'),(230,7,'Boulaye','Dia','1996-11-16','ST'),(231,7,'Nicolas','Jackson','2001-06-20','ST'),(232,7,'Habib','Diallo','1995-06-15','ST'),(233,7,'Krepin','Diatta','1999-02-25','RW'),(234,7,'Iliman','Ndiaye','2000-03-06','CAM'),(235,7,'Pape','Matar Sarr','2002-09-14','CM'),(236,7,'Moussa','Niakhate','1996-03-08','CB'),(237,7,'Cheikhou','Kouyate','1989-12-21','CM'),(240,8,'Lawrence','Ati-Zigi','1996-11-25','GK'),(241,8,'Daniel','Amartey','1994-12-21','CB'),(242,8,'Mohammed','Salisu','1999-04-17','CB'),(243,8,'Gideon','Mensah','1998-07-18','FB'),(244,8,'Denis','Odoi','1988-05-27','FB'),(245,8,'Thomas','Partey','1993-06-13','CDM'),(246,8,'Salim','Adams','2000-02-15','CM'),(247,8,'Mohammed','Kudus','2000-08-02','CAM'),(248,8,'Andre','Ayew','1989-12-17','LW'),(249,8,'Jordan','Ayew','1991-09-11','ST'),(250,8,'Inaki','Williams','1994-06-15','RW'),(251,8,'Antoine','Semenyo','2000-01-07','ST'),(252,8,'Ernest','Nuamah','2003-11-01','RW'),(253,8,'Kamaldeen','Sulemana','2002-02-15','LW'),(254,8,'Elisha','Owusu','1997-11-07','CM'),(255,8,'Alidu','Seidu','2000-06-04','FB'),(256,8,'Joseph','Paintsil','1998-02-01','RW'),(257,8,'Alexander','Djiku','1994-08-09','CB'),(260,9,'Shuichi','Gonda','1989-03-03','GK'),(261,9,'Zion','Suzuki','2002-08-21','GK'),(262,9,'Hiroki','Ito','1999-05-12','CB'),(263,9,'Takehiro','Tomiyasu','1998-11-05','CB'),(264,9,'Yuto','Nagatomo','1986-09-12','FB'),(265,9,'Ko','Itakura','1997-01-27','CB'),(266,9,'Wataru','Endo','1993-02-09','CDM'),(267,9,'Hidemasa','Morita','1995-05-10','CM'),(268,9,'Daichi','Kamada','1996-08-05','CAM'),(269,9,'Takefusa','Kubo','2001-06-04','RW'),(270,9,'Kaoru','Mitoma','1997-05-20','LW'),(271,9,'Junyaa','Ito','1993-03-09','RW'),(272,9,'Ayase','Ueda','1998-08-28','ST'),(273,9,'Ritsu','Doan','1998-06-16','RW'),(274,9,'Kyogo','Furuhashi','1995-01-20','ST'),(275,9,'Reo','Hatate','1997-11-21','CM'),(276,9,'Maya','Yoshida','1988-08-24','CB'),(277,9,'Keito','Nakamura','2000-07-28','LW'),(280,10,'Manuel','Neuer','1986-03-27','GK'),(281,10,'Marc-Andre','ter Stegen','1992-04-30','GK'),(282,10,'Antonio','Rudiger','1993-03-03','CB'),(283,10,'Nico','Schlotterbeck','1999-12-01','CB'),(284,10,'Niklas','Sule','1995-09-03','CB'),(285,10,'Joshua','Kimmich','1995-02-08','CDM'),(286,10,'Leon','Goretzka','1995-02-06','CM'),(287,10,'Ilkay','Gundogan','1990-10-24','CM'),(288,10,'Florian','Wirtz','2003-05-03','CAM'),(289,10,'Serge','Gnabry','1995-07-14','RW'),(290,10,'Leroy','Sane','1996-01-11','LW'),(291,10,'Niclas','Fullkrug','1993-02-09','ST'),(292,10,'Thomas','Muller','1989-09-13','CAM'),(293,10,'Jamala','Musiala','2003-02-26','CAM'),(294,10,'David','Raum','1998-04-22','FB'),(295,10,'Robin','Gosens','1994-07-05','FB'),(296,10,'Jonathan','Tah','1996-02-11','CB'),(297,10,'Kai','Havertz','1999-06-11','ST'),(300,11,'Unai','Simon','1997-06-11','GK'),(301,11,'David','Raya','1995-09-15','GK'),(302,11,'Dani','Carvajal','1992-01-11','FB'),(303,11,'Alejandro','Balde','2003-10-18','FB'),(304,11,'Aymeric','Laporte','1994-05-27','CB'),(305,11,'Robin','Le Normand','1996-11-11','CB'),(306,11,'Rodri',NULL,'1996-06-22','CDM'),(307,11,'Pedri',NULL,'2002-11-25','CM'),(308,11,'Gavi',NULL,'2004-08-05','CM'),(309,11,'Dani','Olmo','1998-05-07','CAM'),(310,11,'Lamine','Yamal','2007-07-13','RW'),(311,11,'Nico','Williams','2002-07-12','LW'),(312,11,'Alvaro','Morata','1992-10-23','ST'),(313,11,'Ferran','Torres','2000-02-29','RW'),(314,11,'Mikel','Oyarzabal','1997-04-21','LW'),(315,11,'Martin','Zubimendi','1999-02-02','CDM'),(316,11,'Pau','Torres','1997-01-16','CB'),(317,11,'Marco','Asensio','1996-01-21','RW'),(320,12,'Kim','Seung-gyu','1990-09-30','GK'),(321,12,'Jo','Hyeon-woo','1991-09-25','GK'),(322,12,'Kim','Min-jae','1996-11-15','CB'),(323,12,'Kwon','Kyung-won','1992-01-31','CB'),(324,12,'Kim','Jin-su','1992-06-13','FB'),(325,12,'Seol','Young-woo','1998-12-05','FB'),(326,12,'Hwang','In-beom','1996-09-20','CM'),(327,12,'Jung','Woo-young','1989-12-14','CDM'),(328,12,'Lee','Kang-in','2001-02-19','CAM'),(329,12,'Son','Heung-min','1992-07-08','LW'),(330,12,'Hwang','Hee-chan','1996-01-26','RW'),(331,12,'Cho','Gue-sung','1998-01-25','ST'),(332,12,'Oh','Hyeon-gyu','2001-04-12','ST'),(333,12,'Na','Sang-ho','1996-08-12','RW'),(334,12,'Lee','Jae-sung','1992-08-10','CM'),(335,12,'Paik','Seung-ho','1997-03-17','CM'),(336,12,'Kim','Young-gwon','1990-02-27','CB'),(337,12,'Hong','Chul','1990-09-17','FB');

INSERT INTO Staff (StaffMemberID,TeamID,FirstName,LastName,TeamRole)
VALUES 
(1,1,'Thomas','Tuchel','Head Coach'),(2,1,'Parker','Spence','Assistant Coach'),(3,1,'Jamie','Burns','Fitness Coach'),(4,1,'Ryan','Braun','Coach Analyst'),(21,2,'Hugo ','Broos','Head Coach'),(22,2,'Sibusiso','Mokwena','Assistant Coach'),(23,2,'Jakob','Van der wet','Fitness Coach'),(24,2,'Philip','Mhlanga','Coach Analyst'),(31,3,'Carlo','Ancelotti','Head Coach'),(32,3,'Gabriel','Estevao','Assistant Coach'),(33,3,'Rodriguez','Da Silva','Fitness Coach'),(34,3,'Lucianna','Esquivel','Coach Analyst'),(41,4,'Didier','Deschamps','Head Coach'),(42,4,'Desree','Girou','Assistant Coach'),(43,4,'Joao','Paulo','Fitness Coach'),(44,4,'Aureilen','Ousmane','Coach Analyst'),(51,5,'Lionel ','Scaloni','Head Coach'),(52,5,'Rodrigo','McCoy','Assistant Coach'),(53,5,'Averie','Acuna','Fitness Coach'),(54,5,'Mylo','Cisners','Coach Analyst'),(61,6,'Roberto ','Martinez','Head Coach'),(62,6,'Ureil','Bryd','Assistant Coach'),(63,6,'Adona','Ochoa','Fitness Coach'),(64,6,'Leia','Fernando','Coach Analyst'),(71,7,'Pepe','Thaiw','Head Coach'),(72,7,'Ephraim','Kalanga','Assistant Coach'),(73,7,'Emani','Sarr','Fitness Coach'),(74,7,'Ibrahim','Fekour','Coach Analyst'),(81,8,'Otto','Ado','Head Coach'),(82,8,'Ace','Li','Assistant Coach'),(83,8,'Benjamin','Gueye','Fitness Coach'),(84,8,'Andres','Ayew','Coach Analyst'),(91,9,'Hajime','Moriyasu','Head Coach'),(92,9,'Kakazu','Kilzuo','Assistant Coach'),(93,9,'Itachi','Harishma','Fitness Coach'),(94,9,'Ken','Kenpachi','Coach Analyst'),(101,10,'Julian ','Naglesman','Head Coach'),(102,10,'Atlas','Fletcher','Assistant Coach'),(103,10,'Gerd','Rues','Fitness Coach'),(104,10,'Kradem','Kreeder','Coach Analyst'),(111,11,'Luis','de la Fuente','Head Coach'),(112,11,'Alexandra','Cucurella','Assistant Coach'),(113,11,'Andres','Rivas','Fitness Coach'),(114,11,'Sylvia','Alvrado','Coach Analyst'),(121,12,'Hong ','Myung-bo','Head Coach'),(122,12,'Thea','Maldona','Assistant Coach'),(123,12,'Reina','Beuo','Fitness Coach'),(124,12,'Rafael','Lowe','Coach Analyst');

INSERT INTO Matches (MatchID,Team1ID,Team2ID,StadiumID,MatchTime,MatchDate,TournamentStage,MatchStatus,Team1Goals,Team2Goals)
VALUES
(1,1,3,1,'22:00:00','2026-06-11','GroupStage','Completed',2,1),(2,11,5,6,'22:00:00','2026-06-11','GroupStage','Completed',3,0),(3,4,7,3,'19:45:00','2026-06-11','GroupStage','Completed',1,1),(4,8,12,5,'19:45:00','2026-06-12','GroupStage','Completed',0,2),(5,2,9,7,'22:00:00','2026-06-12','GroupStage','Completed',4,2),(6,6,10,15,'23:00:00','2026-06-12','GroupStage','Completed',2,2),(7,8,1,3,'19:45:00','2026-06-18','GroupStage','Completed',1,3),(8,9,4,6,'22:00:00','2026-06-18','GroupStage','Completed',2,0),(9,11,6,11,'22:00:00','2026-06-18','GroupStage','Completed',3,1),(10,12,3,14,'19:45:00','2026-06-19','GroupStage','Completed',0,0),(11,7,2,8,'22:00:00','2026-06-19','GroupStage','Completed',1,2),(12,5,10,13,'22:00:00','2026-06-19','GroupStage','Completed',2,1),(13,1,12,10,'19:45:00','2026-06-25','GroupStage','Live',1,1),(14,4,2,9,'22:00:00','2026-06-25','GroupStage','Live',2,0),(15,10,11,2,'22:00:00','2026-06-25','GroupStage','Live',0,0),(16,3,8,12,'19:45:00','2026-06-26','GroupStage','Scheduled',0,0),(17,7,9,4,'22:00:00','2026-06-26','GroupStage','Scheduled',0,0),(18,5,6,16,'22:00:00','2026-06-26','GroupStage','Scheduled',0,0);

INSERT INTO Tickets (TicketID,MatchID,FanID,SeatNumber,Price,PurchaseDate,TicketStatus)
VALUES 
(1,5,1,'A1',150,'2026-05-10','Used'),(2,14,2,'A2',300,'2026-06-12','Used'),(3,2,3,'A3',750,'2026-04-15','Used'),(4,9,4,'B1',150,'2026-06-05','Used'),(5,17,5,'B2',300,'2026-06-18','Booked'),(6,6,6,'B3',750,'2026-05-30','Used'),(7,11,7,'C1',150,'2026-06-10','Used'),(8,3,8,'C2',300,'2026-04-18','Cancelled'),(9,15,9,'C3',750,'2026-06-19','Used'),(10,1,10,'D1',150,'2026-05-01','Used'),(11,8,11,'D2',300,'2026-06-08','Used'),(12,13,12,'D3',750,'2026-06-16','Used'),(13,4,13,'E1',150,'2026-05-20','Used'),(14,10,14,'E2',300,'2026-06-09','Used'),(15,18,15,'E3',750,'2026-06-17','Booked'),(16,7,16,'F1',150,'2026-06-05','Used'),(17,12,17,'F2',300,'2026-06-13','Used'),(18,16,18,'F3',750,'2026-06-14','Used'),(19,2,19,'G1',150,'2026-05-28','Used'),(20,9,20,'G2',300,'2026-06-02','Used'),(21,14,21,'G3',750,'2026-06-11','Used'),(22,6,22,'H1',150,'2026-05-25','Used'),(23,11,23,'H2',300,'2026-06-09','Used'),(24,3,24,'H3',750,'2026-04-30','Cancelled'),(25,17,25,'J1',150,'2026-06-15','Booked'),(26,8,26,'J2',300,'2026-06-10','Used'),(27,1,27,'J3',750,'2026-05-10','Used'),(28,13,28,'K1',150,'2026-06-14','Used'),(29,4,29,'K2',300,'2026-05-22','Used'),(30,18,30,'K3',750,'2026-06-19','Booked'),(31,10,31,'L1',150,'2026-06-13','Used'),(32,7,32,'L2',300,'2026-06-12','Used'),(33,16,33,'L3',750,'2026-06-18','Booked'),(34,5,34,'M1',150,'2026-05-18','Used'),(35,12,35,'M2',300,'2026-06-11','Used'),(36,15,36,'M3',750,'2026-06-17','Used'),(37,3,37,'N1',150,'2026-04-22','Cancelled'),(38,6,38,'N2',300,'2026-05-11','Used'),(39,9,39,'N3',750,'2026-06-07','Used'),(40,2,40,'P1',150,'2026-05-14','Used'),(41,11,41,'P2',300,'2026-06-07','Used'),(42,1,42,'P3',750,'2026-05-29','Used'),(43,8,43,'Q1',150,'2026-06-06','Used'),(44,14,44,'Q2',300,'2026-06-08','Used'),(45,7,45,'Q3',750,'2026-06-11','Used'),(46,13,46,'1',150,'2026-06-04','Used'),(47,5,47,'2',300,'2026-05-19','Used'),(48,12,48,'3',750,'2026-06-13','Used'),(49,16,49,'S1',150,'2026-06-18','Booked'),(50,10,50,'S2',300,'2026-06-17','Used');

INSERT INTO PlayerStats (PlayerStatsID,PlayerID,MatchID,MinutesPlayed,Goals,Assists,YellowCards,RedCards,ShotsOnTarget,PassesCompleted)
VALUES
(1,143,1,70,0,0,0,0,4,20),(2,101,1,85,2,1,0,0,2,17),(3,142,1,90,0,0,0,0,2,29),(4,151,1,85,0,0,0,1,5,67),(5,116,1,60,1,1,0,0,4,15),(6,113,1,75,0,0,0,1,3,52),(7,111,1,80,1,0,0,0,0,36),(8,141,1,75,2,1,1,0,4,36),(9,146,1,85,0,0,0,1,1,70),(10,107,1,70,0,1,1,0,3,26),(11,185,2,60,2,0,1,0,5,68),(12,191,2,80,0,1,0,0,6,58),(13,192,2,90,1,0,0,0,0,16),(14,311,2,85,1,1,1,1,3,50),(15,187,2,90,1,1,1,0,0,30),(16,317,2,85,1,0,0,1,2,38),(17,313,2,75,2,1,0,0,6,23),(18,306,2,80,1,1,0,0,0,25),(19,182,2,90,0,0,1,0,3,58),(20,186,2,90,0,1,0,1,2,42),(21,166,3,75,2,1,0,0,1,59),(22,220,3,90,0,0,1,0,2,16),(23,236,3,70,2,1,0,0,5,33),(24,172,3,90,0,1,1,0,3,64),(25,231,3,70,0,1,0,1,6,55),(26,168,3,80,0,1,0,0,5,57),(27,222,3,75,2,0,1,0,3,42),(28,162,3,90,1,0,1,0,3,25),(29,169,3,85,2,1,1,1,1,29),(30,230,3,80,1,1,0,1,2,20),(31,329,4,70,1,0,0,0,0,17),(32,326,4,90,0,1,1,0,0,49),(33,244,4,75,1,0,1,1,4,70),(34,335,4,85,0,0,1,1,1,37),(35,328,4,60,1,0,0,0,1,53),(36,247,4,85,1,1,0,0,5,28),(37,253,4,80,1,0,0,0,2,53),(38,241,4,70,0,0,1,1,3,60),(39,242,4,70,0,0,0,1,5,65),(40,249,4,60,1,0,0,0,0,65),(41,124,5,60,0,1,1,0,6,58),(42,122,5,90,0,1,0,0,5,34),(43,263,5,75,1,1,0,0,1,43),(44,275,5,80,1,1,0,0,2,46),(45,133,5,75,0,1,0,0,2,39),(46,134,5,75,1,1,0,1,0,65),(47,261,5,70,1,0,0,0,5,57),(48,120,5,90,0,0,0,1,1,41),(49,131,5,60,1,0,0,0,2,23),(50,271,5,70,2,0,0,1,2,16),(51,297,6,75,2,0,0,0,6,29),(52,209,6,60,1,1,0,0,5,51),(53,290,6,90,1,1,0,1,6,30),(54,215,6,85,2,0,1,0,6,24),(55,212,6,90,1,1,1,1,3,41),(56,210,6,70,0,0,0,0,4,65),(57,213,6,70,1,0,0,0,5,26),(58,289,6,60,0,0,0,0,4,43),(59,216,6,75,0,1,0,0,3,16),(60,207,6,70,0,0,1,0,3,31),(61,251,7,80,0,1,0,0,5,49),(62,252,7,85,0,1,1,0,0,53),(63,242,7,70,0,1,0,1,0,30),(64,257,7,60,0,0,0,0,3,39),(65,113,7,60,0,0,1,1,4,48),(66,114,7,60,0,1,0,1,1,21),(67,250,7,80,1,1,0,1,5,50),(68,112,7,75,1,1,0,0,1,46),(69,106,7,70,2,1,0,0,2,24),(70,117,7,85,0,0,1,0,3,35),(71,260,8,70,2,0,1,0,4,51),(72,171,8,90,1,1,1,0,3,36),(73,168,8,85,0,0,0,0,4,29),(74,176,8,85,0,0,0,0,4,29),(75,268,8,70,0,1,0,0,2,49),(76,263,8,80,0,0,1,0,0,21),(77,177,8,85,2,0,0,0,6,61),(78,161,8,85,0,1,0,1,5,62),(79,261,8,90,0,1,0,0,4,33),(80,174,8,80,0,1,0,0,6,32),(81,314,9,60,0,0,0,0,3,34),(82,315,9,80,1,0,1,0,6,31),(83,207,9,75,2,1,0,0,3,53),(84,209,9,75,1,1,1,1,5,34),(85,313,9,60,1,0,1,0,5,57),(86,215,9,60,1,0,0,1,2,26),(87,217,9,70,0,0,1,1,2,21),(88,213,9,90,2,0,0,0,6,58),(89,317,9,75,1,0,0,1,0,17),(90,204,9,70,0,0,0,0,5,31),(91,143,10,80,2,0,0,0,1,27),(92,152,10,85,1,0,1,0,6,67),(93,328,10,80,2,0,0,0,5,38),(94,334,10,60,0,0,0,0,4,26),(95,330,10,85,0,0,0,1,2,61),(96,146,10,70,0,0,1,0,0,53),(97,326,10,90,1,0,1,0,0,22),(98,148,10,80,0,0,0,1,5,22),(99,153,10,85,0,1,0,0,2,41),(100,325,10,90,1,0,0,0,0,45),(101,235,11,85,1,0,1,0,1,34),(102,120,11,75,1,0,1,1,2,30),(103,126,11,75,0,0,0,0,3,31),(104,131,11,85,1,1,0,0,5,55),(105,223,11,90,1,1,0,0,4,69),(106,124,11,80,0,1,0,0,6,17),(107,132,11,80,0,1,1,0,0,68),(108,220,11,85,1,0,1,0,6,25),(109,227,11,85,0,1,0,0,4,58),(110,129,11,70,0,0,0,1,5,60),(111,186,12,80,1,0,0,0,2,22),(112,192,12,90,1,0,1,0,4,59),(113,181,12,70,2,0,0,0,4,28),(114,281,12,70,1,0,0,0,6,54),(115,284,12,90,0,0,1,0,6,62),(116,193,12,85,2,0,0,1,3,55),(117,183,12,70,1,0,1,0,6,52),(118,295,12,70,1,1,0,1,3,69),(119,296,12,70,0,1,0,0,2,69),(120,282,12,75,1,0,0,1,0,19),(121,107,13,60,0,0,0,0,5,37),(122,328,13,60,0,0,0,1,0,41),(123,320,13,75,0,0,1,0,0,38),(124,103,13,85,1,0,1,0,0,63),(125,323,13,90,0,0,1,0,6,17),(126,326,13,80,1,1,0,0,6,31),(127,324,13,85,0,1,0,0,2,54),(128,335,13,80,1,0,0,0,4,23),(129,102,13,80,0,0,0,1,5,26),(130,330,13,85,2,0,1,0,3,68),(131,135,14,85,1,0,1,0,3,70),(132,170,14,85,0,0,0,0,2,58),(133,166,14,80,0,0,1,0,4,21),(134,125,14,85,0,1,0,0,1,20),(135,123,14,60,0,1,1,0,2,26),(136,174,14,70,0,0,0,0,6,49),(137,167,14,75,2,0,0,0,1,32),(138,126,14,80,0,1,1,0,3,36),(139,177,14,70,2,0,0,1,2,69),(140,131,14,90,1,0,0,1,4,44),(141,292,15,85,0,0,0,1,2,65),(142,287,15,75,1,1,1,0,0,50),(143,311,15,85,1,0,1,0,4,31),(144,307,15,80,0,0,0,0,1,47),(145,305,15,60,2,0,1,1,2,34),(146,312,15,85,1,0,0,0,3,17),(147,310,15,70,1,0,0,0,5,28),(148,309,15,90,2,0,0,0,4,27),(149,290,15,75,0,0,1,0,1,54),(150,296,15,60,1,0,0,0,4,44),(151,249,16,70,0,1,0,0,6,27),(152,157,16,80,0,0,0,0,2,50),(153,149,16,70,0,0,0,0,5,19),(154,241,16,85,0,0,0,0,5,36),(155,156,16,70,0,1,1,1,5,67),(156,252,16,80,2,1,0,0,5,27),(157,155,16,70,0,0,0,0,0,30),(158,153,16,70,0,0,0,1,2,67),(159,250,16,85,0,1,0,0,5,70),(160,245,16,90,1,0,0,0,3,20),(161,272,17,70,1,0,0,0,1,45),(162,266,17,85,2,0,1,1,1,46),(163,263,17,80,0,0,0,0,4,70),(164,232,17,60,1,0,1,0,5,15),(165,269,17,70,0,0,0,0,2,29),(166,236,17,80,0,0,0,0,5,20),(167,235,17,60,0,1,0,0,3,23),(168,226,17,90,1,0,0,0,0,39),(169,230,17,75,0,0,0,0,0,58),(170,233,17,70,0,0,1,0,2,55),(171,216,18,70,2,1,0,0,1,55),(172,195,18,75,0,0,0,0,2,33),(173,190,18,85,1,0,1,0,3,32),(174,183,18,75,1,0,0,0,5,57),(175,203,18,85,0,0,0,0,4,60),(176,194,18,80,0,1,0,0,3,22),(177,208,18,85,0,1,0,0,0,42),(178,217,18,85,0,0,0,0,5,52),(179,210,18,60,1,0,0,0,2,63),(180,184,18,60,0,0,0,0,0,69);
GO

SELECT 'Tables created successfully!' AS Status;
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE';
GO

-- Drop existing keys and certificates if they exist
USE Fifa2026_WorldCupDB;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'FifaCert')
    DROP CERTIFICATE FifaCert;
IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'FifaKey')
    DROP SYMMETRIC KEY FifaKey;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'MasterFifaCert')
    DROP CERTIFICATE MasterFifaCert;
GO

-- Enable TDE encryption (only if not already encrypted)
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE MasterFifaCert;
GO

ALTER DATABASE Fifa2026_WorldCupDB
SET ENCRYPTION ON;
GO

-- Column specific encryption
-- Create master key for column encryption
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Password123';
GO

-- Create certificate to encrypt/decrypt keys
CREATE CERTIFICATE FifaCert
WITH SUBJECT = 'Fifa 2026 Encryption Certificate';
GO

-- Create key for encryption
CREATE SYMMETRIC KEY FifaKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE FifaCert;
GO

-- Encrypt sensitive fields
OPEN SYMMETRIC KEY FifaKey
DECRYPTION BY CERTIFICATE FifaCert;
UPDATE Fans
SET ContactInfo = ENCRYPTBYKEY(KEY_GUID('FifaKey'), ContactInfo);
CLOSE SYMMETRIC KEY FifaKey;
GO

-- SECTION 3: Queries
-- JOIN: Shows All Team staffs
SELECT 
    s.FirstName, 
    s.LastName, 
    s.TeamRole, 
    t.TeamName AS NationalTeam
FROM Staff s
JOIN Teams t ON s.TeamID = t.TeamID
ORDER BY t.TeamName;
GO

-- SUBQUERY: Counts Number of Tickets a fan has bought
OPEN SYMMETRIC KEY FifaKey
DECRYPTION BY CERTIFICATE FifaCert;

SELECT 
    f.FanName, 
    CONVERT(NVARCHAR(20), DECRYPTBYKEY(f.ContactInfo)) AS ContactInfo,
    (SELECT COUNT(*) 
     FROM Tickets t 
     WHERE t.FanID = f.FanID) AS TotalTicketsBought
FROM Fans f;
CLOSE SYMMETRIC KEY FifaKey;
GO

-- CTE: Displays Total goals from players
WITH TopScorers AS (
    SELECT 
        PlayerID, 
        SUM(Goals) AS TotalGoals, 
        SUM(ShotsOnTarget) AS TotalShots
    FROM PlayerStats
    GROUP BY PlayerID
)
SELECT 
    P.FirstName, 
    P.LastName, 
    P.Position, 
    ts.TotalGoals
FROM Players P
JOIN TopScorers ts ON p.PlayerID = ts.PlayerID
ORDER BY ts.TotalGoals DESC, ts.TotalShots DESC;
GO

-- CASE: Card status report for the tournament
SELECT 
    PlayerID, 
    YellowCards, 
    RedCards,
    CASE 
        WHEN RedCards > 0 THEN 'Suspended (Red Card)'
        WHEN YellowCards >= 2 THEN 'Suspension Warning'
        WHEN YellowCards = 1 THEN 'Caution Active'
        ELSE 'Clean Record'
    END AS DisciplineStatus
FROM PlayerStats;
GO

-- Procedures
DROP PROCEDURE IF EXISTS RegisterTeams;
GO

CREATE PROCEDURE RegisterTeams(
    @TeamName VARCHAR(50),
    @CountryID INT,
    @TeamID INT
)
AS
BEGIN
    IF @CountryID <= 0
    BEGIN
        PRINT 'Invalid CountryID';
        RETURN;
    END

    IF @TeamID <= 0
    BEGIN
        PRINT 'Invalid TeamID';
        RETURN;
    END

    IF @TeamName IS NULL OR @CountryID IS NULL
    BEGIN
        PRINT 'This field cannot be empty';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Countries WHERE CountryID = @CountryID)
    BEGIN
        PRINT 'Country already exists';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Teams WHERE TeamName = @TeamName)
    BEGIN
        PRINT 'Team already exists';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO dbo.Teams (TeamID, CountryID, TeamName)
        VALUES (@TeamID, @CountryID, @TeamName);
        COMMIT;
        PRINT 'Team successfully registered';
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error occurred while registering team';
    END CATCH
END;
GO

DROP PROCEDURE IF EXISTS AddPlayers;
GO

CREATE PROCEDURE AddPlayers (
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @DateOfBirth DATE,
    @Position VARCHAR(30),
    @TeamID INT,
    @PlayerID INT
)
AS
BEGIN
    IF @DateOfBirth > GETDATE()
    BEGIN
        PRINT 'Invalid date';
        RETURN;
    END

    IF @PlayerID <= 0
    BEGIN
        PRINT 'Invalid PlayerID';
        RETURN;
    END

    IF @FirstName IS NULL OR @TeamID IS NULL OR @LastName IS NULL OR @PlayerID IS NULL
    BEGIN
        PRINT 'Field cannot be empty ';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Teams WHERE TeamID = @TeamID)
    BEGIN
        PRINT 'Team does not exist';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Players WHERE FirstName = @FirstName AND PlayerID = @PlayerID AND TeamID = @TeamID)
    BEGIN
        PRINT 'Player already exists in this team';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION
        INSERT INTO dBO.Players(PlayerID, TeamID, FirstName, LastName, DateOfBirth, Position)
        VALUES(@PlayerID, @TeamID, @FirstName, @LastName, @DateOfBirth, @Position);
        COMMIT;
        PRINT 'Player successfully added';
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error has occurred adding the player';
    END CATCH
END;
GO

DROP PROCEDURE IF EXISTS ScheduleMatch;
GO

CREATE PROCEDURE ScheduleMatch (
    @MatchID INT,
    @HomeTeam INT,
    @AwayTeam INT,
    @StadiumID INT,
    @MatchTime TIME,
    @MatchDate DATE
)
AS
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM dbo.Teams WHERE TeamID = @HomeTeam)
    BEGIN
        PRINT 'Team does not exist';
        RETURN;
    END

    IF @MatchDate < GETDATE()
    BEGIN
        PRINT 'Match should be in the future';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Teams WHERE TeamID = @AwayTeam)
    BEGIN
        PRINT 'Team does not exist';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Stadiums WHERE StadiumID = @StadiumID)
    BEGIN
        PRINT 'Stadium does not exist';
        RETURN;
    END

    IF @HomeTeam = @AwayTeam
    BEGIN
        PRINT 'Different teams should play against each other';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Matches WHERE StadiumID = @StadiumID AND MatchDate = @MatchDate)
    BEGIN
        PRINT 'Stadium is already booked for a match';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION
        INSERT INTO Matches (MatchID, Team1ID, Team2ID, StadiumID, MatchTime, MatchDate, TournamentStage, MatchStatus, Team1Goals, Team2Goals)
        VALUES (@MatchID, @HomeTeam, @AwayTeam, @StadiumID, @MatchTime, @MatchDate, 'Group Stage', 'Scheduled', 0, 0);
        COMMIT;
        PRINT 'Match successfully scheduled';
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error Scheduling match';
    END CATCH
END;
GO

DROP PROCEDURE IF EXISTS RecordMatchResult;
GO

CREATE PROCEDURE RecordMatchResult(
    @MatchID INT,
    @HomeGoals INT,
    @AwayGoals INT,
    @MatchStatus VARCHAR(50)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Matches WHERE MatchID = @MatchID)
    BEGIN
        PRINT 'Match does not exist';
        RETURN;
    END

    IF @HomeGoals < 0 OR @AwayGoals < 0
    BEGIN
        PRINT 'Score cannot be negative';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Matches WHERE MatchID = @MatchID AND Team1Goals IS NOT NULL AND Team2Goals IS NOT NULL AND MatchStatus = 'Completed')
    BEGIN
        PRINT 'Match already recorded';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION
        UPDATE dbo.Matches
        SET Team1Goals = @HomeGoals,
            Team2Goals = @AwayGoals,
            MatchStatus = 'Completed'
        WHERE MatchID = @MatchID;
        PRINT 'Match successfully recorded';
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error recording match result';
    END CATCH
END;
GO

DROP PROCEDURE IF EXISTS UpdatePlayerstats;
GO

CREATE PROCEDURE UpdatePlayerstats(
    @PlayerID INT,
    @MatchID INT,
    @Goals INT = 0,
    @MinutesPlayed INT = 0,
    @Assists INT = 0,
    @YellowCard INT = 0,
    @RedCard INT = 0,
    @ShotsOnTarget INT = 0,
    @PassesCompleted INT = 0
)
AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM dbo.Players WHERE PlayerID = @PlayerID)
    BEGIN
        PRINT 'Player Does Not Exist';
        RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM dbo.Matches WHERE MatchID = @MatchID)
    BEGIN
        PRINT 'Match Does Not Exist';
        RETURN;
    END

    IF (@Goals < 0 OR @MinutesPlayed < 0 OR @Assists < 0 OR @YellowCard < 0 OR @RedCard < 0 OR @ShotsOnTarget < 0 OR @PassesCompleted < 0)
    BEGIN
        PRINT 'Values cannot be lower than 0';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION 
        IF EXISTS (SELECT 1 FROM dbo.PlayerStats WHERE PlayerID = @PlayerID AND MatchID = @MatchID)
        BEGIN
            UPDATE dbo.PlayerStats 
            SET
                MinutesPlayed = MinutesPlayed + @MinutesPlayed,
                Goals = Goals + @Goals,
                Assists = Assists + @Assists,
                YellowCards = YellowCards + @YellowCard, 
                RedCards = RedCards + @RedCard,
                ShotsOnTarget = ShotsOnTarget + @ShotsOnTarget,
                PassesCompleted = PassesCompleted + @PassesCompleted
            WHERE PlayerID = @PlayerID AND MatchID = @MatchID;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.PlayerStats (PlayerStatsID, PlayerID, MatchID, MinutesPlayed, Goals, Assists, YellowCards, RedCards, ShotsOnTarget, PassesCompleted)
            VALUES ((SELECT ISNULL(MAX(PlayerStatsID), 0) + 1 FROM PlayerStats), @PlayerID, @MatchID, @MinutesPlayed, @Goals, @Assists, @YellowCard, @RedCard, @ShotsOnTarget, @PassesCompleted);
        END
        COMMIT;
        PRINT 'PLAYER STATS UPDATED';
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error occurred when updating player stats';
    END CATCH
END;
GO

DROP FUNCTION IF EXISTS GetTicketPrice;
GO

CREATE FUNCTION GetTicketPrice(
    @MatchID INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Price DECIMAL(10,2);
    DECLARE @MatchDate DATE;
    
    SELECT @MatchDate = MatchDate
    FROM dbo.Matches
    WHERE MatchID = @MatchID;
    
    SELECT @Price = 
        CASE 
            WHEN @MatchDate >= '2026-06-01' THEN 150
            WHEN @MatchDate BETWEEN '2026-07-01' AND '2026-09-01' THEN 300
            ELSE 750
        END;
    
    RETURN @Price;
END;
GO

DROP FUNCTION IF EXISTS GetAvailableSeats;
GO

CREATE FUNCTION GetAvailableSeats (@MatchID INT)
RETURNS INT
AS 
BEGIN
    DECLARE @Capacity INT;
    DECLARE @TicketsSold INT;

    SELECT @Capacity = s.Capacity
    FROM dbo.Matches m
    INNER JOIN dbo.Stadiums s ON m.StadiumID = s.StadiumID
    WHERE m.MatchID = @MatchID;

    SELECT @TicketsSold = COUNT(*)
    FROM dbo.Tickets
    WHERE MatchID = @MatchID AND TicketStatus IN ('Booked', 'Used');

    RETURN ISNULL(@Capacity, 0) - ISNULL(@TicketsSold, 0);
END;
GO

DROP PROCEDURE IF EXISTS BookTicket;
GO

CREATE PROCEDURE BookTicket(
    @TicketID INT,
    @MatchID INT,
    @FanID INT,
    @SeatNumber VARCHAR(10),
    @PurchasedDate DATE
)
AS
BEGIN
    DECLARE @Price DECIMAL(10,2);
    SET @Price = dbo.GetTicketPrice(@MatchID);

    DECLARE @AvailableSeats INT;
    SET @AvailableSeats = dbo.GetAvailableSeats(@MatchID);

    -- VALIDATION
    IF EXISTS (SELECT 1 FROM Tickets WHERE TicketID = @TicketID)
    BEGIN
        PRINT 'Ticket already exists';
        RETURN;
    END

    IF @TicketID IS NULL OR @MatchID IS NULL OR @PurchasedDate IS NULL
    BEGIN
        PRINT 'Field cannot be empty';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Matches WHERE MatchID = @MatchID)
    BEGIN
        PRINT 'Match does not exist';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Fans WHERE FanID = @FanID)
    BEGIN
        PRINT 'Fan does not exist';
        RETURN;
    END

    IF @AvailableSeats <= 0
    BEGIN
        PRINT 'Stadium is full';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Tickets WHERE MatchID = @MatchID AND SeatNumber = @SeatNumber)
    BEGIN
        PRINT 'Seat is taken';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION
        INSERT INTO dbo.Tickets(TicketID, MatchID, FanID, SeatNumber, Price, PurchaseDate, TicketStatus)
        VALUES (@TicketID, @MatchID, @FanID, @SeatNumber, @Price, @PurchasedDate, 'Booked');
        COMMIT;
        PRINT 'Ticket booked successfully';
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error booking ticket';
    END CATCH
END;
GO

DROP PROCEDURE IF EXISTS CancelTicket;
GO

CREATE PROCEDURE CancelTicket
    @TicketID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Tickets WHERE TicketID = @TicketID)
    BEGIN
        PRINT 'Ticket does not exist';
        RETURN;
    END

    IF EXISTS(SELECT 1 FROM dbo.Tickets WHERE TicketID = @TicketID AND TicketStatus = 'Cancelled')
    BEGIN
        PRINT 'Ticket already cancelled';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION
        UPDATE dbo.Tickets
        SET TicketStatus = 'Cancelled'
        WHERE TicketID = @TicketID;
        COMMIT;
        PRINT 'Ticket cancelled successfully';
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error cancelling ticket';
    END CATCH
END;
GO

-- Views
DROP VIEW IF EXISTS vw_MatchDetails;
GO

CREATE VIEW vw_MatchDetails AS
SELECT 
    m.MatchID,
    ht.TeamName AS HomeTeam,
    at.TeamName AS AwayTeam,
    s.StadiumName,
    m.MatchDate,
    m.MatchTime,
    m.TournamentStage,
    m.MatchStatus,
    m.Team1Goals,
    m.Team2Goals
FROM dbo.Matches m
INNER JOIN dbo.Teams ht ON m.Team1ID = ht.TeamID
INNER JOIN dbo.Teams at ON m.Team2ID = at.TeamID
INNER JOIN dbo.Stadiums s ON m.StadiumID = s.StadiumID;
GO

DROP VIEW IF EXISTS vw_TicketDetails;
GO

CREATE VIEW vw_TicketDetails AS
SELECT 
    t.TicketID,
    f.FanName,
    m.MatchID,
    ht.TeamName AS HomeTeam,
    at.TeamName AS AwayTeam,
    t.SeatNumber,
    t.Price,
    t.PurchaseDate,
    t.TicketStatus
FROM dbo.Tickets t
INNER JOIN dbo.Fans f ON t.FanID = f.FanID
INNER JOIN dbo.Matches m ON t.MatchID = m.MatchID
INNER JOIN dbo.Teams ht ON m.Team1ID = ht.TeamID
INNER JOIN dbo.Teams at ON m.Team2ID = at.TeamID;
GO

DROP VIEW IF EXISTS vw_PlayerStats;
GO

CREATE VIEW vw_PlayerStats AS
SELECT 
    p.FirstName,
    p.LastName,
    t.TeamName,
    ps.Goals,
    ps.Assists,
    ps.YellowCards,
    ps.RedCards,
    ps.MinutesPlayed,
    ps.ShotsOnTarget,
    ps.PassesCompleted
FROM dbo.Players p
INNER JOIN dbo.Teams t ON p.TeamID = t.TeamID
INNER JOIN dbo.PlayerStats ps ON p.PlayerID = ps.PlayerID;
GO

DROP VIEW IF EXISTS vw_AvailableSeats;
GO

CREATE VIEW vw_AvailableSeats AS
SELECT 
    m.MatchID,
    ht.TeamName AS HomeTeam,
    at.TeamName AS AwayTeam,
    dbo.GetAvailableSeats(m.MatchID) AS AvailableSeats
FROM dbo.Matches m
INNER JOIN dbo.Teams ht ON m.Team1ID = ht.TeamID
INNER JOIN dbo.Teams at ON m.Team2ID = at.TeamID;
GO

-- Triggers
DROP TRIGGER IF EXISTS trg_NewTicket;
GO

CREATE TRIGGER trg_NewTicket -- Verifies a new/changed tickets
ON Tickets
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @Booked int, @MatchID int, @Total int, @SeatNumber varchar(10);
    
    SELECT @MatchID = MatchID, @SeatNumber = SeatNumber FROM inserted;
    
    SELECT @Booked = COUNT(TicketID) 
    FROM Tickets 
    WHERE MatchID = @MatchID AND TicketStatus IN ('Booked', 'Used');
    
    SELECT @Total = Capacity 
    FROM Stadiums 
    WHERE StadiumID IN (SELECT StadiumID FROM Matches WHERE MatchID = @MatchID);
    
    IF @Booked > @Total
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'All seats are booked';
    END
    
    IF EXISTS (SELECT 1 FROM Tickets WHERE MatchID = @MatchID AND SeatNumber = @SeatNumber AND TicketStatus IN ('Booked', 'Used'))
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Seat already booked';
    END
END;
GO

DROP TRIGGER IF EXISTS trg_MatchNotification;
GO

CREATE TRIGGER trg_MatchNotification -- Simple trigger to inform Teams of a new match or match changes
ON Matches
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @Team1Name VARCHAR(30), @Team2Name VARCHAR(30), @StadiumName VARCHAR(50), @MatchDate DATE, @MatchTime TIME;
    
    SELECT 
        @Team1Name = (SELECT TeamName FROM Teams WHERE TeamID = inserted.Team1ID),
        @Team2Name = (SELECT TeamName FROM Teams WHERE TeamID = inserted.Team2ID),
        @StadiumName = (SELECT StadiumName FROM Stadiums WHERE StadiumID = inserted.StadiumID),
        @MatchDate = inserted.MatchDate,
        @MatchTime = inserted.MatchTime
    FROM inserted;
    
    IF (SELECT MatchStatus FROM inserted) != 'Completed'
    BEGIN
        PRINT 'New Match Details: ' + @Team1Name + ' vs ' + @Team2Name + ' at ' + @StadiumName + ' on ' + CONVERT(VARCHAR(20), @MatchDate, 120) + ' at ' + CONVERT(VARCHAR(12), @MatchTime, 108);
    END
END;
GO

-- Sample Transactions
BEGIN TRANSACTION -- Example Transaction of registration of a new ticket
INSERT INTO Tickets (TicketID, MatchID, FanID, SeatNumber, Price, PurchaseDate, TicketStatus)
VALUES (51, 7, 8, 'S5', 160, '2026-05-11', 'Booked');
COMMIT TRANSACTION;
GO

BEGIN TRANSACTION -- Example Transaction of creating a new match
INSERT INTO Matches (MatchID, Team1ID, Team2ID, StadiumID, MatchTime, MatchDate, TournamentStage, MatchStatus, Team1Goals, Team2Goals)
VALUES (19, 5, 6, 9, '20:00:00', '2026-06-20', 'GroupStage', 'Scheduled', 0, 0);
COMMIT TRANSACTION;
GO

-- Cursor for ticket notifications
DECLARE @FanName VarChar(50), @SeatNumber Varchar(10), @MatchTime Time, @MatchDate Date;

DECLARE cur_TicketNotification CURSOR FOR
SELECT F.FanName, Tick.SeatNumber, M.MatchTime, M.MatchDate 
FROM Tickets Tick 
INNER JOIN Matches M ON Tick.MatchID = M.MatchID 
INNER JOIN Fans F ON Tick.FanID = F.FanID;

OPEN cur_TicketNotification;

FETCH NEXT FROM cur_TicketNotification INTO @FanName, @SeatNumber, @MatchTime, @MatchDate;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF DATEDIFF(DAY, GETDATE(), @MatchDate) = 1
    BEGIN
        PRINT '----------------------------------------------------------';
        PRINT '                                                          ';
        PRINT @FanName;
        PRINT '                                                          ';
        PRINT '                      REMINDER!                           ';
        PRINT '                                                          ';
        PRINT 'You have booked a ticket for seat ' + @SeatNumber;
        PRINT 'For tomorrow at ' + CONVERT(VARCHAR(12), @MatchTime, 108);
        PRINT '                                                          ';
        PRINT '----------------------------------------------------------';
        PRINT '                                                          ';
    END
    FETCH NEXT FROM cur_TicketNotification INTO @FanName, @SeatNumber, @MatchTime, @MatchDate;
END

CLOSE cur_TicketNotification;
DEALLOCATE cur_TicketNotification;
GO

PRINT 'Database setup completed successfully!';
GO