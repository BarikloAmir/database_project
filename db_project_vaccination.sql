-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 28, 2022 at 02:38 AM
-- Server version: 10.4.21-MariaDB
-- PHP Version: 8.0.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_project_vaccination`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_beh_center` (IN `_name` VARCHAR(250), IN `_address` VARCHAR(250))  BEGIN
insert into beh_center (name, address) values (_name, _address);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_to_login_table` (IN `_user_name` VARCHAR(250), IN `_tag` VARCHAR(250))  BEGIN
	
INSERT INTO login_table (user_name, tag) VALUES (_user_name, _tag);
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `change_password` (IN `_user_name` VARCHAR(250), IN `_password` VARCHAR(250))  BEGIN
UPDATE user_system_information SET user_system_information.password = md5(_password)
WHERE user_system_information.user_name = _user_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `check_password` (IN `password` VARCHAR(250), OUT `result` BOOLEAN)  begin
    if (length(password) >= 8 ) then
        set result = true;
    else
        set result = false;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `check_user_name` (IN `user_name` VARCHAR(250), OUT `result` BOOLEAN)  begin
    if (length(user_name) = 10 and user_name REGEXP '^[0-9]+$') then
        set result = true;
    else
        set result = false;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_brand` (IN `_dose_number` INT, IN `_day` INT, IN `_berand` VARCHAR(250), IN `_tag` INT(250))  BEGIN


set  @_doc_cod = (SELECT doctor_account.doctor_code
                 from doctor_account
                 WHERE 		  doctor_account.user_name=(SELECT user_name 
				FROM login_table
                WHERE login_table.tag = _tag));

INSERT INTO berand (berand_name, dose_number, day, doctor_code) VALUES (_berand, _dose_number, _day, @_doc_cod);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_injection` (IN `_user_name` VARCHAR(250), IN `_beh_name` VARCHAR(250), IN `_vaccine_serial` VARCHAR(250), IN `_tag` VARCHAR(250))  BEGIN
set  @_nurse_code = (SELECT nurse_account.nurse_code
                 from nurse_account
                 WHERE 	nurse_account.user_name=
                     (SELECT user_name 
				FROM login_table
                WHERE login_table.tag = _tag));
INSERT INTO injection (user_name, beh_center_name, serial_vaccine, injection_date, nurse_code) VALUES (_user_name,_beh_name , _vaccine_serial, now(), @_nurse_code);


                
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `creat_vaccine` (IN `_serial_number` VARCHAR(250), IN `_berand` VARCHAR(250), IN `_production_date` VARCHAR(250), IN `_dose_number` INT, IN `_tag` VARCHAR(250))  BEGIN

set  @nurse_level = (SELECT nurse_account.level
                 from nurse_account
                 WHERE 	nurse_account.user_name=
                     (SELECT user_name 
				FROM login_table
                WHERE login_table.tag = _tag));

IF @nurse_level ='metron' THEN
	INSERT INTO vaccine (serial_number, berand, 	production_date, dose_number) VALUES (_serial_number, _berand, _production_date, _production_date);
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `doctor_sighn_up` (IN `_user_name` VARCHAR(250), IN `_password` VARCHAR(250), IN `_first_name` VARCHAR(250), IN `_last_name` VARCHAR(250), IN `_birthday` VARCHAR(8), IN `_phone_number` VARCHAR(250), IN `_gender` BOOLEAN, IN `_special_disease` BOOLEAN, IN `_doctor_code` VARCHAR(5))  BEGIN
	#set @date = now() 
    
    START TRANSACTION;
	
    INSERT INTO user_system_information 
    (
        user_name,
        password,
        register_date
    ) 
    VALUES 
    (
		_user_name,
        md5(_password),
        now()
        
        
   );


    INSERT INTO user_person_information 
    (
        birthday,
        first_name,
        gender,
        last_name,
        special_disease,
        telephon_number
        
    ) 
    VALUES 
    (
        _birthday,
        _first_name,
        _gender,
        _last_name,
        _special_disease,
        _phone_number
    );
    
    INSERT INTO doctor_account
    (
        user_name,
        telephon_number,
        doctor_code
	)
    VALUES
    (
        _user_name,
        _phone_number,
        _doctor_code
        
    );    
    COMMIT;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_avgScore_behCenter` (IN `start_index` INT, IN `finish_index` INT)  BEGIN
 (
 select user_behcenter.beh_center,avg(user_behcenter.score) as avg_score
    from user_behcenter
    group by user_behcenter.beh_center) 
UNION
(SELECT
    beh_center.name , 0 AS avg_score
FROM
    beh_center
WHERE 

   NOT EXISTS(
    SELECT
        *
    FROM
        user_behcenter
    WHERE
        beh_center.name = user_behcenter.beh_center
       

)
) 
ORDER BY avg_score DESC
limit start_index, finish_index;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_berand_vaccine` ()  BEGIN
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_injection_day_number` ()  BEGIN

SELECT
    *
FROM
    (
    SELECT
        injection.injection_date,
        COUNT(injection.user_name)
    FROM
        injection
    GROUP BY
        injection.injection_date
) AS T
ORDER BY
    T.injection_date DESC;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_person_infromation` (IN `_user_name` VARCHAR(250))  BEGIN
SELECT *
FROM user_person_information
WHERE user_person_information.telephon_number=
(SELECT normal_account.telephon_number
 FROM normal_account
 WHERE normal_account.user_name = _user_name)
 or 
 user_person_information.telephon_number = (SELECT nurse_account.telephon_number
 FROM nurse_account
 WHERE nurse_account.user_name = _user_name) 
 OR
  user_person_information.telephon_number = (SELECT doctor_account.telephon_number
 FROM doctor_account
 WHERE doctor_account.user_name = _user_name); 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_phone` (IN `_user_name` VARCHAR(250), OUT `phone` VARCHAR(250))  set phone = (SELECT telephon_number 
FROM normal_account
WHERE normal_account.user_name = _user_name)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_score_vaccine_berand` ()  BEGIN
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_system_information` (IN `_user_name` VARCHAR(250))  BEGIN
SELECT user_system_information.user_name,user_system_information.register_date
FROM user_system_information
WHERE user_system_information.user_name = _user_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `_user_name` VARCHAR(250), IN `_password` VARCHAR(250), OUT `_result` BOOLEAN, OUT `_tag` VARCHAR(250))  BEGIN
IF exists(select user_name,password
          from user_system_information
          where user_name = _user_Name and 
          password = md5(_password))
          then
        set _tag = md5(_user_name);
        	
INSERT INTO login_table (user_name, tag) VALUES (_user_name, _tag);
         set _result = true;
    	else
        set _result = false;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `logout` (IN `_tag` VARCHAR(250))  BEGIN
DELETE FROM login_table WHERE login_table.tag = _tag;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `md5` (IN `input` VARCHAR(250), OUT `output` VARCHAR(250))  begin
    
	set output = MD5(input);

 
    
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `normal_sighn_up` (IN `_user_name` VARCHAR(250), IN `_password` VARCHAR(250), IN `_first_name` VARCHAR(250), IN `_last_name` VARCHAR(250), IN `_birthday` VARCHAR(8), IN `_phone_number` VARCHAR(250), IN `_gender` BOOLEAN, IN `_special_disease` BOOLEAN)  BEGIN
	#set @date = now() 
    
    START TRANSACTION;
	
    INSERT INTO user_system_information 
    (
        user_name,
        password,
        register_date
    ) 
    VALUES 
    (
		_user_name,
        md5(_password),
        now()
        
        
   );


    INSERT INTO user_person_information 
    (
        birthday,
        first_name,
        gender,
        last_name,
        special_disease,
        telephon_number
        
    ) 
    VALUES 
    (
        _birthday,
        _first_name,
        _gender,
        _last_name,
        _special_disease,
        _phone_number
    );
    
    INSERT INTO normal_account
    (
        user_name,
        telephon_number
	)
    VALUES
    (
        _user_name,
        _phone_number
        
    );    
    COMMIT;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `nurse_sighn_up` (IN `_user_name` VARCHAR(250), IN `_password` VARCHAR(250), IN `_first_name` VARCHAR(250), IN `_last_name` VARCHAR(250), IN `_birthday` VARCHAR(8), IN `_phone_number` VARCHAR(250), IN `_gender` BOOLEAN, IN `_special_disease` BOOLEAN, IN `_nurse_code` VARCHAR(8), IN `_level` VARCHAR(250))  BEGIN
	#set @date = now() 
    
    START TRANSACTION;
	
    INSERT INTO user_system_information 
    (
        user_name,
        password,
        register_date
    ) 
    VALUES 
    (
		_user_name,
        md5(_password),
        now()
        
        
   );


    INSERT INTO user_person_information 
    (
        birthday,
        first_name,
        gender,
        last_name,
        special_disease,
        telephon_number
        
    ) 
    VALUES 
    (
        _birthday,
        _first_name,
        _gender,
        _last_name,
        _special_disease,
        _phone_number
    );
    
    INSERT INTO nurse_account
    (
        user_name,
        telephon_number,
        nurse_code,
        level
	)
    VALUES
    (
        _user_name,
        _phone_number,
        _nurse_code,
        _level
        
    );    
    COMMIT;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `personal_show` ()  BEGIN
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `remove_user` (IN `_user_name` VARCHAR(250))  BEGIN

CALL get_phone(_user_name,@phone);

#set result = @phone;



DELETE FROM normal_account WHERE normal_account.user_name = _user_name;

DELETE FROM user_system_information WHERE user_system_information.user_name = _user_name;

DELETE FROM user_person_information WHERE user_person_information.telephon_number =@phone;





END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `score_to_behCenter` (IN `_user_name` VARCHAR(250), IN `_score` INT, IN `_beh_center` VARCHAR(250), OUT `_result` VARCHAR(250))  BEGIN
IF EXISTS(SELECT injection.user_name
                 FROM injection
                 WHERE injection.beh_center_name=_beh_center AND
injection.user_name = _user_name )
AND NOT EXISTS(SELECT *
                  FROM user_behcenter
                  WHERE user_behcenter.user_name=_user_name AND
user_behcenter.beh_center = _beh_center )
AND _score>0 AND _score<6 
                 THEN
                 INSERT INTO user_behcenter (user_name, score, beh_center) VALUES (_user_name, _score, _beh_center);
                 SET _result = 'succesful';
                 ELSE
                 SET _result = 'you can not score to this';
                 END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `beh_center`
--

CREATE TABLE `beh_center` (
  `name` varchar(250) NOT NULL,
  `address` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `beh_center`
--

INSERT INTO `beh_center` (`name`, `address`) VALUES
('aliabad', 'ab.ads'),
('alian', 'dfdfdfdfd'),
('amiri', 'aaaaaaaaaaaaaaaaaaaaaaaaaaa.bbbbbbbbbb'),
('hafez', 'tohid street');

-- --------------------------------------------------------

--
-- Table structure for table `berand`
--

CREATE TABLE `berand` (
  `berand_name` varchar(250) NOT NULL,
  `dose_number` int(11) NOT NULL,
  `day` int(11) NOT NULL,
  `doctor_code` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `berand`
--

INSERT INTO `berand` (`berand_name`, `dose_number`, `day`, `doctor_code`) VALUES
('afdfdsfasfasadf', 5, 45, '12398'),
('barekat', 2, 10, '22222'),
('tgrg', 5, 54, '98765'),
('vvvv', 5, 60, '98765');

-- --------------------------------------------------------

--
-- Table structure for table `doctor_account`
--

CREATE TABLE `doctor_account` (
  `user_name` varchar(250) NOT NULL,
  `telephon_number` varchar(11) NOT NULL,
  `doctor_code` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `doctor_account`
--

INSERT INTO `doctor_account` (`user_name`, `telephon_number`, `doctor_code`) VALUES
('0000000000', '1561561551', '12365'),
('0101010101', '56561256156', '12398'),
('0321654987', '02133333333', '98765'),
('2525252525', '03216544', '12349'),
('7777777777', '5656565', '22222');

--
-- Triggers `doctor_account`
--
DELIMITER $$
CREATE TRIGGER `check_doctor_code` BEFORE INSERT ON `doctor_account` FOR EACH ROW IF (length(new.doctor_code) != 5) then
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'You can not insert record from trigger length of code is not 5';
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `injection`
--

CREATE TABLE `injection` (
  `user_name` varchar(10) NOT NULL,
  `beh_center_name` varchar(250) NOT NULL,
  `serial_vaccine` varchar(250) NOT NULL,
  `injection_date` date NOT NULL,
  `nurse_code` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `injection`
--

INSERT INTO `injection` (`user_name`, `beh_center_name`, `serial_vaccine`, `injection_date`, `nurse_code`) VALUES
('12345678', 'hafez', '22572745275', '2022-01-03', '454'),
('1234567891', 'hafez', '156151511', '2022-01-27', '1515151'),
('9638527410', 'hafez', '15611', '2022-01-27', '87654321'),
('9999999999', 'hafez', '1379', '2022-01-27', '25896347');

-- --------------------------------------------------------

--
-- Table structure for table `login_table`
--

CREATE TABLE `login_table` (
  `user_name` varchar(10) NOT NULL,
  `tag` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `login_table`
--

INSERT INTO `login_table` (`user_name`, `tag`) VALUES
('0101010101', '2a29e197400f55dc4db300bcdeddbbad'),
('0321654987', '1709d49072fb7f115f087346dc3c6269'),
('6416515161', 'd4f65d4fd654f'),
('7878787878', '3c637af21d03fb6f5add9fd86b36bad9'),
('9638527410', '9c2845863f114e6db26f8efd89084978'),
('9999999999', 'e0ec043b3f9e198ec09041687e4d4e8d');

-- --------------------------------------------------------

--
-- Table structure for table `normal_account`
--

CREATE TABLE `normal_account` (
  `user_name` varchar(250) NOT NULL,
  `telephon_number` varchar(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `normal_account`
--

INSERT INTO `normal_account` (`user_name`, `telephon_number`) VALUES
('9638527410', '02133565988'),
('3720286160', '09127435986'),
('9999999999', '569845984'),
('5555555555', '61651515615');

-- --------------------------------------------------------

--
-- Table structure for table `nurse_account`
--

CREATE TABLE `nurse_account` (
  `user_name` varchar(250) NOT NULL,
  `telephon_number` varchar(11) NOT NULL,
  `level` enum('metron','super','nurse','b') NOT NULL,
  `nurse_code` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `nurse_account`
--

INSERT INTO `nurse_account` (`user_name`, `telephon_number`, `level`, `nurse_code`) VALUES
('0147852369', '415615151', 'super', '22154369'),
('0202020202', '055459821', 'metron', '25896347'),
('1212121212', '0115255454', 'metron', '87654321'),
('1234567891', '12345678912', 'b', '12345678'),
('1478523698', '021546589', 'b', '55555123'),
('7878787878', '46545454545', 'nurse', '44445555');

--
-- Triggers `nurse_account`
--
DELIMITER $$
CREATE TRIGGER `check_level_length_nurse_account` BEFORE INSERT ON `nurse_account` FOR EACH ROW IF (length(new.nurse_code) != 8 OR  not new.nurse_code REGEXP '^[0-9]+$' OR (new.level != 'super' and new.level != 'metron' and new.level!='b' and 
  new.level!='nurse')) then
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'You can not insert record from trigger';
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `user_behcenter`
--

CREATE TABLE `user_behcenter` (
  `user_name` varchar(250) NOT NULL,
  `score` int(11) NOT NULL,
  `beh_center` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user_behcenter`
--

INSERT INTO `user_behcenter` (`user_name`, `score`, `beh_center`) VALUES
('9638527410', 2, 'hafez'),
('1212121212', 3, 'hafez'),
('7777777777', 1, 'amiri');

-- --------------------------------------------------------

--
-- Table structure for table `user_person_information`
--

CREATE TABLE `user_person_information` (
  `first_name` varchar(250) NOT NULL,
  `last_name` varchar(250) NOT NULL,
  `telephon_number` varchar(11) NOT NULL,
  `gender` tinyint(1) NOT NULL,
  `birthday` varchar(8) NOT NULL,
  `special_disease` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user_person_information`
--

INSERT INTO `user_person_information` (`first_name`, `last_name`, `telephon_number`, `gender`, `birthday`, `special_disease`) VALUES
('ad', 'bariklo', '0115255454', 0, '15.5.15', 0),
('garib', 'gg', '02133333333', 1, '12.32.32', 0),
('ali', 'madadii', '02133565988', 1, '12.3.66', 0),
('ddd', 'aaa', '021546589', 0, '12.3.85', 0),
('hasan', 'zand', '0236644949', 0, '12.3.25', 0),
('amir', 'bariklo', '02538832075', 0, '17.6.79', 0),
('amir', 'bariklo', '03216544', 1, '16.6.98', 0),
('zari', 'zaer', '055459821', 0, '(1, 27, ', 0),
('amir.h', 'barklooo', '09127435986', 0, '(1, 27, ', 0),
('amir', 'bariklo', '12345678912', 1, '2022-01-', 0),
('amirkhan', 'bariklooo', '12345678945', 1, '17.6.79', 0),
('afd', 'dfad', '1561561551', 0, '(1, 27, ', 0),
('aaa', 'jdklj', '415615151', 0, '(1, 27, ', 0),
('aa', 'bb', '46545454545', 0, 'cc', 0),
('fadfdsfadfdsfdsfd', 'dfdf', '56561256156', 0, '(1, 27, ', 0),
('frf', 'fddf', '5656565', 0, 'dfdf', 0),
('adf', 'asdf', '569845984', 0, '(1, 27, ', 0),
('adfaf', 'fdsfds', '61651515615', 0, '(1, 27, ', 0);

-- --------------------------------------------------------

--
-- Table structure for table `user_system_information`
--

CREATE TABLE `user_system_information` (
  `user_name` varchar(10) NOT NULL,
  `password` varchar(250) NOT NULL,
  `register_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user_system_information`
--

INSERT INTO `user_system_information` (`user_name`, `password`, `register_date`) VALUES
('0000000000', '187ef4436122d1cc2f40dc2b92f0eba0', '2022-01-27'),
('0101010101', 'ab56b4d92b40713acc5af89985d4b786', '2022-01-27'),
('0147852369', 'e8dc4081b13434b45189a720b77b6818', '2022-01-27'),
('0202020202', '0701aa317da5a004fbf6111545678a6c', '2022-01-27'),
('0303030303', '0121515', '2022-01-04'),
('0303030304', '54564561561515151a', '2022-01-10'),
('0303030305', '22dsfsfdsfdfdfds', '2022-01-03'),
('0321654987', '46212a3d2e76e5758896cf0c42e6b400', '2022-01-26'),
('1111511111', '757825', '0000-00-00'),
('1212121212', '81f8d77564d5c935fc97980ce64620d6', '2022-01-27'),
('1234567754', '5745457', '0000-00-00'),
('12345678', '57457', '0000-00-00'),
('1234567891', '1254', '2022-01-11'),
('1478523698', '6464644fd64f4', '2022-01-26'),
('2525252525', 'e10adc3949ba59abbe56e057f20f883e', '2022-01-27'),
('3720286160', 'f154092583e93c56cdc8cd60ac422a11', '2022-01-27'),
('5555555555', 'e2fc714c4727ee9395f324cd2e7f331f', '2022-01-27'),
('7777777777', '4444', '2022-01-26'),
('7878787878', '3c637af21d03fb6f5add9fd86b36bad9', '2022-01-27'),
('9638527410', '9c2845863f114e6db26f8efd89084978', '2022-01-26'),
('9999999999', '900150983cd24fb0d6963f7d28e17f72', '2022-01-27');

--
-- Triggers `user_system_information`
--
DELIMITER $$
CREATE TRIGGER `check_password` BEFORE INSERT ON `user_system_information` FOR EACH ROW BEGIN   
   set @upper = UPPER(new.password);
    set @lower = LOWER(new.password);

IF  not new.password REGEXP '([A-Za-z]+[0-9]|[0-9]+[A-Za-z])[A-Za-z0-9]*'
OR
length(new.password) < 8

                                
    
    then
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'can not to insert from pass';
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `check_user_name` BEFORE INSERT ON `user_system_information` FOR EACH ROW IF (length(new.user_name) != 10 OR  not new.user_name REGEXP '^[0-9]+$') then
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'You can not insert record from trigger';
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `vaccine`
--

CREATE TABLE `vaccine` (
  `serial_number` varchar(250) NOT NULL,
  `berand` varchar(250) NOT NULL,
  `production_date` varchar(250) NOT NULL,
  `dose_number` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `vaccine`
--

INSERT INTO `vaccine` (`serial_number`, `berand`, `production_date`, `dose_number`) VALUES
('0215487963258', 'barekat', '(1, 27, 2012)', 0),
('1379', 'barekat', '(1, 27, 2022)', 0),
('15611', 'barekat', '12.311.165', 12311),
('46444464', 'barekat', '51.5.45', 515),
('df', 'barekat', 'fd', 2);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `beh_center`
--
ALTER TABLE `beh_center`
  ADD PRIMARY KEY (`name`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `berand`
--
ALTER TABLE `berand`
  ADD PRIMARY KEY (`berand_name`),
  ADD UNIQUE KEY `berand_name` (`berand_name`),
  ADD KEY `doctor_code` (`doctor_code`);

--
-- Indexes for table `doctor_account`
--
ALTER TABLE `doctor_account`
  ADD PRIMARY KEY (`user_name`),
  ADD UNIQUE KEY `doctor_code` (`doctor_code`),
  ADD UNIQUE KEY `user_name` (`user_name`),
  ADD KEY `telephon_number` (`telephon_number`);

--
-- Indexes for table `injection`
--
ALTER TABLE `injection`
  ADD PRIMARY KEY (`user_name`),
  ADD KEY `beh_center_name` (`beh_center_name`);

--
-- Indexes for table `login_table`
--
ALTER TABLE `login_table`
  ADD PRIMARY KEY (`tag`),
  ADD UNIQUE KEY `tag` (`tag`),
  ADD UNIQUE KEY `user_name` (`user_name`);

--
-- Indexes for table `normal_account`
--
ALTER TABLE `normal_account`
  ADD PRIMARY KEY (`user_name`),
  ADD KEY `telephon_number` (`telephon_number`);

--
-- Indexes for table `nurse_account`
--
ALTER TABLE `nurse_account`
  ADD PRIMARY KEY (`user_name`),
  ADD UNIQUE KEY `user_name` (`user_name`),
  ADD UNIQUE KEY `nurse_code` (`nurse_code`),
  ADD KEY `telephon_number` (`telephon_number`);

--
-- Indexes for table `user_behcenter`
--
ALTER TABLE `user_behcenter`
  ADD KEY `beh_center` (`beh_center`),
  ADD KEY `user_name` (`user_name`);

--
-- Indexes for table `user_person_information`
--
ALTER TABLE `user_person_information`
  ADD PRIMARY KEY (`telephon_number`),
  ADD UNIQUE KEY `telephon_number` (`telephon_number`);

--
-- Indexes for table `user_system_information`
--
ALTER TABLE `user_system_information`
  ADD PRIMARY KEY (`user_name`),
  ADD UNIQUE KEY `password` (`password`),
  ADD UNIQUE KEY `user_name` (`user_name`);

--
-- Indexes for table `vaccine`
--
ALTER TABLE `vaccine`
  ADD PRIMARY KEY (`serial_number`),
  ADD UNIQUE KEY `serial_number` (`serial_number`),
  ADD KEY `berand` (`berand`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `berand`
--
ALTER TABLE `berand`
  ADD CONSTRAINT `berand_ibfk_1` FOREIGN KEY (`doctor_code`) REFERENCES `doctor_account` (`doctor_code`);

--
-- Constraints for table `doctor_account`
--
ALTER TABLE `doctor_account`
  ADD CONSTRAINT `doctor_account_ibfk_1` FOREIGN KEY (`user_name`) REFERENCES `user_system_information` (`user_name`),
  ADD CONSTRAINT `doctor_account_ibfk_2` FOREIGN KEY (`telephon_number`) REFERENCES `user_person_information` (`telephon_number`);

--
-- Constraints for table `injection`
--
ALTER TABLE `injection`
  ADD CONSTRAINT `injection_ibfk_1` FOREIGN KEY (`user_name`) REFERENCES `user_system_information` (`user_name`),
  ADD CONSTRAINT `injection_ibfk_2` FOREIGN KEY (`beh_center_name`) REFERENCES `beh_center` (`name`);

--
-- Constraints for table `normal_account`
--
ALTER TABLE `normal_account`
  ADD CONSTRAINT `normal_account_ibfk_1` FOREIGN KEY (`user_name`) REFERENCES `user_system_information` (`user_name`),
  ADD CONSTRAINT `normal_account_ibfk_2` FOREIGN KEY (`telephon_number`) REFERENCES `user_person_information` (`telephon_number`);

--
-- Constraints for table `nurse_account`
--
ALTER TABLE `nurse_account`
  ADD CONSTRAINT `nurse_account_ibfk_1` FOREIGN KEY (`user_name`) REFERENCES `user_system_information` (`user_name`),
  ADD CONSTRAINT `nurse_account_ibfk_2` FOREIGN KEY (`telephon_number`) REFERENCES `user_person_information` (`telephon_number`);

--
-- Constraints for table `user_behcenter`
--
ALTER TABLE `user_behcenter`
  ADD CONSTRAINT `user_behcenter_ibfk_1` FOREIGN KEY (`beh_center`) REFERENCES `beh_center` (`name`),
  ADD CONSTRAINT `user_behcenter_ibfk_2` FOREIGN KEY (`user_name`) REFERENCES `user_system_information` (`user_name`);

--
-- Constraints for table `vaccine`
--
ALTER TABLE `vaccine`
  ADD CONSTRAINT `vaccine_ibfk_1` FOREIGN KEY (`berand`) REFERENCES `berand` (`berand_name`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
