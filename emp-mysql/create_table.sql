CREATE TABLE `tbl_emp` (
  `userId` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `jobTitleName` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `firstName` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `lastName` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `preferredFullName` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `employeeCode` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `region` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phoneNumber` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `emailAddress` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`employeeCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `tbl_emp` (userId,jobTitleName,firstName,lastName,preferredFullName,employeeCode,region,phoneNumber,emailAddress) VALUES ("rKumar","Developer","Ram","Kumar","Ram Kumar","E1","CA","408-1234567","Ram.k.Kumar@gmail.com");
INSERT INTO `tbl_emp` (userId,jobTitleName,firstName,lastName,preferredFullName,employeeCode,region,phoneNumber,emailAddress) VALUES ("nKumar","Developer","Neil","Kumar","Neil Kumar","E2","CA","408-1111111","neilrKumar@gmail.com");
