CREATE DATABASE Travel_And_Tourism;
USE Travel_And_Tourism;

/* 1. Customer */
CREATE TABLE Customer(
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    Nationality VARCHAR(50),
    passport_no VARCHAR(20) UNIQUE
);

/* 2. Agent */
CREATE TABLE Agent(
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15),
    Commission_rate DECIMAL(5,2) DEFAULT 0.00
);

/* 3. Destination */
CREATE TABLE Destination(
    destination_id INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Country VARCHAR(50),
    Description TEXT,
    Rating DECIMAL(2,1) CHECK (Rating BETWEEN 0 AND 5)
);

/* 4. Hotel */
CREATE TABLE Hotel(
    hotel_id INT AUTO_INCREMENT PRIMARY KEY,
    destination_id INT,
    Name VARCHAR(100),
    Rating DECIMAL(2,1),
    Contact_no VARCHAR(30),
    FOREIGN KEY (destination_id) REFERENCES Destination(destination_id)
        ON DELETE CASCADE
);

SET @@cte_max_recursion_depth = 2000;

/* 5. Room */
CREATE TABLE Room(
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id INT,
    Room_Type VARCHAR(50),
    PricePerNight DECIMAL(10,2),
    Capacity INT,
    Availability_Status BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (hotel_id) REFERENCES Hotel(hotel_id)
        ON DELETE CASCADE
);

/* 6. Tour_Type */
CREATE TABLE Tour_Type(
    tour_type_id INT AUTO_INCREMENT PRIMARY KEY,
    Type_Name VARCHAR(50)
);

/* 7. Package */
CREATE TABLE Package(
    package_id INT AUTO_INCREMENT PRIMARY KEY,
    agent_id INT,
    tour_type_id INT,
    Name VARCHAR(100),
    Duration_Days INT,
    Price DECIMAL(10,2),
    description TEXT,
    FOREIGN KEY (agent_id) REFERENCES Agent(agent_id),
    FOREIGN KEY (tour_type_id) REFERENCES Tour_Type(tour_type_id)
);

/* 8. Package_Destination */
CREATE TABLE Package_Destination(
    package_dest_id INT AUTO_INCREMENT PRIMARY KEY,
    package_id INT,
    destination_id INT,
    sequence_no INT,
    FOREIGN KEY (package_id) REFERENCES Package(package_id),
    FOREIGN KEY (destination_id) REFERENCES Destination(destination_id)
);

/* 9. Booking */
CREATE TABLE Booking(
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    package_id INT,
    Booking_Date DATE,
    Start_Date DATE,
    End_Date DATE,
    Total_Amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (package_id) REFERENCES Package(package_id)
);

/* 10. Payment */
CREATE TABLE Payment(
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    Amount DECIMAL(10,2),
    Payment_Date DATE,
    Method VARCHAR(20),
    transaction_id VARCHAR(50),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
        ON DELETE CASCADE
);

/* 11. Transport */
CREATE TABLE Transport(
    transport_id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50),
    Company_Name VARCHAR(100),
    Contact_No VARCHAR(15)
);

/* 12. Schedule */
CREATE TABLE Schedule(
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    transport_id INT,
    source VARCHAR(100),
    destination VARCHAR(100),
    Departure_Time DATETIME,
    Arrival_Time DATETIME,
    fare DECIMAL(10,2),
    FOREIGN KEY (transport_id) REFERENCES Transport(transport_id)
);

/* 13. Booking_Transport */
CREATE TABLE Booking_Transport(
    bt_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    schedule_id INT,
    Seat_No VARCHAR(10),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (schedule_id) REFERENCES Schedule(schedule_id)
);

/* 14. Feedback */
CREATE TABLE Feedback(
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    package_id INT,
    Rating DECIMAL(2,1),
    Comments TEXT,
    Feedback_Date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (package_id) REFERENCES Package(package_id)
);

/* 15. Offer */
CREATE TABLE Offer(
    offer_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    Discount_Percent DECIMAL(5,2),
    Start_Date DATE,
    End_Date DATE
);

/* ADVANCED FEATURES */

/* 16. Package_Offer */
CREATE TABLE Package_Offer(
    package_offer_id INT AUTO_INCREMENT PRIMARY KEY,
    package_id INT,
    offer_id INT,
    FOREIGN KEY (package_id) REFERENCES Package(package_id),
    FOREIGN KEY (offer_id) REFERENCES Offer(offer_id)
);

/* 17. Insurance_Provider */
CREATE TABLE Insurance_Provider(
    insurance_provider_id INT AUTO_INCREMENT PRIMARY KEY,
    Provider_Name VARCHAR(100),
    Contact_No VARCHAR(20)
);

/* 18. Travel_Insurance */
CREATE TABLE Travel_Insurance(
    insurance_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    insurance_provider_id INT,
    Policy_No VARCHAR(50),
    Start_Date DATE,
    End_Date DATE,
    Coverage_Amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (insurance_provider_id) REFERENCES Insurance_Provider(insurance_provider_id)
);

/* 19. Custom_Package */
CREATE TABLE Custom_Package(
    custom_pkg_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    Name VARCHAR(100),
    Created_Date DATE,
    Total_Cost DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

/* 20. Custom_Package_Destination  */
CREATE TABLE Custom_Package_Destination(
    cpd_id INT AUTO_INCREMENT PRIMARY KEY,
    custom_pkg_id INT,
    destination_id INT,
    Sequence_No INT,
    FOREIGN KEY (custom_pkg_id) REFERENCES Custom_Package(custom_pkg_id),
    FOREIGN KEY (destination_id) REFERENCES Destination(destination_id)
);

/* 21. Support_Ticket  */
CREATE TABLE Support_Ticket(
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    booking_id INT,
    Issue_Type VARCHAR(50),
    Description TEXT,
    status VARCHAR(20),
    created_at DATETIME,
    resolved_at DATETIME,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);

/* 22. Loyalty_Program */
CREATE TABLE Loyalty_Program(
    program_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    Points_Per_Rupee DECIMAL(5,2),
    Tier_Levels VARCHAR(50)
);

/* 23. Customer_Loyalty */
CREATE TABLE Customer_Loyalty(
    cl_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    program_id INT,
    Total_Points DECIMAL(10,2),
    Tier_Level VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (program_id) REFERENCES Loyalty_Program(program_id)
);

/* 24. Loyalty_Transaction */
CREATE TABLE Loyalty_Transaction(
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    cl_id INT,
    booking_id INT,
    Points_Earned DECIMAL(10,2),
    Points_Redeemed DECIMAL(10,2),
    Txn_Date DATE,
    FOREIGN KEY (cl_id) REFERENCES Customer_Loyalty(cl_id),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);

/* INSERTING INTO Customer*/

INSERT INTO Customer (customer_id, name, email, Phone, Nationality, passport_no)
VALUES
(1, 'John Smith', 'john.smith@email.com', '+14151234567', 'USA', 'US1234567'),
(2, 'Aditi Sharma', 'aditi.sharma@gmail.com', '+919876543210', 'India', 'IN8796543'),
(3, 'Carlos Lopez', 'carlos.lopez@outlook.com', '+34123456789', 'Spain', 'ES7654321'),
(4, 'Emily Brown', 'emily.brown@yahoo.com', '+447911123456', 'UK', 'UK6543219'),
(5, 'Liam Chen', 'liam.chen@gmail.com', '+8613812345678', 'China', 'CH4532198'),
(6, 'Sara Ahmed', 'sara.ahmed@hotmail.com', '+201234567890', 'Egypt', 'EG1987654'),
(7, 'Michael Johnson', 'mike.johnson@gmail.com', '+14152345678', 'USA', 'US7654329'),
(8, 'Hiro Tanaka', 'hiro.tanaka@gmail.com', '+81312345678', 'Japan', 'JP3241567'),
(9, 'Isabella Rossi', 'isabella.rossi@gmail.com', '+393456789012', 'Italy', 'IT5432198'),
(10, 'David Kim', 'david.kim@gmail.com', '+821012345678', 'South Korea', 'KR8765432'),

(11,'Rahul Patel','rahul11@gmail.com','+919800000011','India','IN1000011'),
(12,'Neha Verma','neha12@gmail.com','+919800000012','India','IN1000012'),
(13,'Chris Evans','chris13@gmail.com','+141500000013','USA','US1000013'),
(14,'Sophia White','sophia14@gmail.com','+447900000014','UK','UK1000014'),
(15,'Lucas Martin','lucas15@gmail.com','+331000000015','France','FR1000015'),
(16,'Daniel Garcia','daniel16@gmail.com','+341000000016','Spain','ES1000016'),
(17,'Mia Wilson','mia17@gmail.com','+611000000017','Australia','AU1000017'),
(18,'Noah Lee','noah18@gmail.com','+821000000018','Korea','KR1000018'),
(19,'Emma Clark','emma19@gmail.com','+441000000019','UK','UK1000019'),
(20,'Oliver Scott','oliver20@gmail.com','+141500000020','USA','US1000020'),

(21,'Aarav Shah','aarav21@gmail.com','+919800000021','India','IN1000021'),
(22,'Priya Singh','priya22@gmail.com','+919800000022','India','IN1000022'),
(23,'James Miller','james23@gmail.com','+141500000023','USA','US1000023'),
(24,'Charlotte King','charlotte24@gmail.com','+447900000024','UK','UK1000024'),
(25,'Henry Walker','henry25@gmail.com','+611000000025','Australia','AU1000025'),
(26,'Amelia Young','amelia26@gmail.com','+331000000026','France','FR1000026'),
(27,'Jack Hall','jack27@gmail.com','+141500000027','USA','US1000027'),
(28,'Grace Allen','grace28@gmail.com','+821000000028','Korea','KR1000028'),
(29,'Arjun Mehta','arjun29@gmail.com','+919800000029','India','IN1000029'),
(30,'Riya Kapoor','riya30@gmail.com','+919800000030','India','IN1000030'),

(31,'Benjamin Adams','ben31@gmail.com','+141500000031','USA','US1000031'),
(32,'Zoe Baker','zoe32@gmail.com','+447900000032','UK','UK1000032'),
(33,'William Carter','will33@gmail.com','+141500000033','USA','US1000033'),
(34,'Evelyn Perez','eve34@gmail.com','+341000000034','Spain','ES1000034'),
(35,'Logan Turner','logan35@gmail.com','+611000000035','Australia','AU1000035'),
(36,'Harper Collins','harper36@gmail.com','+141500000036','USA','US1000036'),
(37,'Ishaan Jain','ishaan37@gmail.com','+919800000037','India','IN1000037'),
(38,'Ananya Gupta','ananya38@gmail.com','+919800000038','India','IN1000038'),
(39,'Sebastian Cruz','seb39@gmail.com','+341000000039','Spain','ES1000039'),
(40,'Lily Flores','lily40@gmail.com','+141500000040','USA','US1000040'),

(41,'Ryan Ward','ryan41@gmail.com','+141500000041','USA','US1000041'),
(42,'Ella Cox','ella42@gmail.com','+447900000042','UK','UK1000042'),
(43,'Jayden Diaz','jayden43@gmail.com','+341000000043','Spain','ES1000043'),
(44,'Scarlett Reed','scarlett44@gmail.com','+611000000044','Australia','AU1000044'),
(45,'Nathan Brooks','nathan45@gmail.com','+141500000045','USA','US1000045'),
(46,'Victoria Bell','victoria46@gmail.com','+447900000046','UK','UK1000046'),
(47,'Karan Malhotra','karan47@gmail.com','+919800000047','India','IN1000047'),
(48,'Pooja Desai','pooja48@gmail.com','+919800000048','India','IN1000048'),
(49,'Julian Price','julian49@gmail.com','+141500000049','USA','US1000049'),
(50,'Hannah Bennett','hannah50@gmail.com','+447900000050','UK','UK1000050'),

(51,'Aaron Wood','aaron51@gmail.com','+141500000051','USA','US1000051'),
(52,'Leah Barnes','leah52@gmail.com','+447900000052','UK','UK1000052'),
(53,'Mateo Ross','mateo53@gmail.com','+331000000053','France','FR1000053'),
(54,'Stella Henderson','stella54@gmail.com','+611000000054','Australia','AU1000054'),
(55,'David Cooper','david55@gmail.com','+141500000055','USA','US1000055'),
(56,'Natalie Richardson','natalie56@gmail.com','+447900000056','UK','UK1000056'),
(57,'Kabir Nair','kabir57@gmail.com','+919800000057','India','IN1000057'),
(58,'Sneha Iyer','sneha58@gmail.com','+919800000058','India','IN1000058'),
(59,'Adam Peterson','adam59@gmail.com','+141500000059','USA','US1000059'),
(60,'Claire Gray','claire60@gmail.com','+447900000060','UK','UK1000060'),

(61,'Jason Ramirez','jason61@gmail.com','+341000000061','Spain','ES1000061'),
(62,'Samantha James','sam62@gmail.com','+141500000062','USA','US1000062'),
(63,'Leo Watson','leo63@gmail.com','+447900000063','UK','UK1000063'),
(64,'Nora Brooks','nora64@gmail.com','+611000000064','Australia','AU1000064'),
(65,'Owen Kelly','owen65@gmail.com','+141500000065','USA','US1000065'),
(66,'Piper Sanders','piper66@gmail.com','+447900000066','UK','UK1000066'),
(67,'Rohit Yadav','rohit67@gmail.com','+919800000067','India','IN1000067'),
(68,'Meera Joshi','meera68@gmail.com','+919800000068','India','IN1000068'),
(69,'Tyler Powell','tyler69@gmail.com','+141500000069','USA','US1000069'),
(70,'Alice Long','alice70@gmail.com','+447900000070','UK','UK1000070'),

(71,'Colton Patterson','colton71@gmail.com','+141500000071','USA','US1000071'),
(72,'Bella Hughes','bella72@gmail.com','+447900000072','UK','UK1000072'),
(73,'Miles Flores','miles73@gmail.com','+341000000073','Spain','ES1000073'),
(74,'Sadie Butler','sadie74@gmail.com','+611000000074','Australia','AU1000074'),
(75,'Dominic Simmons','dom75@gmail.com','+141500000075','USA','US1000075'),
(76,'Lucy Foster','lucy76@gmail.com','+447900000076','UK','UK1000076'),
(77,'Yash Patel','yash77@gmail.com','+919800000077','India','IN1000077'),
(78,'Nisha Shah','nisha78@gmail.com','+919800000078','India','IN1000078'),
(79,'Evan Gonzales','evan79@gmail.com','+141500000079','USA','US1000079'),
(80,'Ruby Bryant','ruby80@gmail.com','+447900000080','UK','UK1000080'),

(81,'Xavier Alexander','xavier81@gmail.com','+141500000081','USA','US1000081'),
(82,'Maya Russell','maya82@gmail.com','+447900000082','UK','UK1000082'),
(83,'Nathan Griffin','nathan83@gmail.com','+141500000083','USA','US1000083'),
(84,'Elena Diaz','elena84@gmail.com','+341000000084','Spain','ES1000084'),
(85,'Aaron Hayes','aaron85@gmail.com','+141500000085','USA','US1000085'),
(86,'Layla Myers','layla86@gmail.com','+447900000086','UK','UK1000086'),
(87,'Varun Khanna','varun87@gmail.com','+919800000087','India','IN1000087'),
(88,'Isha Soni','isha88@gmail.com','+919800000088','India','IN1000088'),
(89,'Hunter Ford','hunter89@gmail.com','+141500000089','USA','US1000089'),
(90,'Naomi Hamilton','naomi90@gmail.com','+447900000090','UK','UK1000090'),

(91,'Jasper Graham','jasper91@gmail.com','+141500000091','USA','US1000091'),
(92,'Clara Sullivan','clara92@gmail.com','+447900000092','UK','UK1000092'),
(93,'Roman Wallace','roman93@gmail.com','+141500000093','USA','US1000093'),
(94,'Eva Woods','eva94@gmail.com','+611000000094','Australia','AU1000094'),
(95,'Hudson Cole','hudson95@gmail.com','+141500000095','USA','US1000095'),
(96,'Aurora West','aurora96@gmail.com','+447900000096','UK','UK1000096'),
(97,'Aditya Kulkarni','aditya97@gmail.com','+919800000097','India','IN1000097'),
(98,'Kavya Menon','kavya98@gmail.com','+919800000098','India','IN1000098'),
(99,'Landon Perry','landon99@gmail.com','+141500000099','USA','US1000099'),
(100,'Eliza Powell','eliza100@gmail.com','+447900000100','UK','UK1000100'),
(101,'Caleb Barnes','caleb101@gmail.com','+141500000101','USA','US1000101'),
(102,'Paisley Rivera','paisley102@gmail.com','+341000000102','Spain','ES1000102'),
(103,'Theo Price','theo103@gmail.com','+141500000103','USA','US1000103'),
(104,'Madeline Cox','madeline104@gmail.com','+447900000104','UK','UK1000104'),
(105,'Rohan Bansal','rohan105@gmail.com','+919800000105','India','IN1000105'),
(106,'Simran Kaur','simran106@gmail.com','+919800000106','India','IN1000106'),
(107,'Victor Hughes','victor107@gmail.com','+141500000107','USA','US1000107'),
(108,'Hazel Ward','hazel108@gmail.com','+447900000108','UK','UK1000108'),
(109,'George Jenkins','george109@gmail.com','+141500000109','USA','US1000109'),
(110,'Penelope Kelly','penelope110@gmail.com','+447900000110','UK','UK1000110');


/* INSERTING INTO Agent*/

INSERT INTO Agent (name, Email, Phone, Commission_rate) VALUES
('Sophia Martinez', 'sophia.martinez@realtyhub.com', '+1-212-555-0198', 2.50),
('Liam Johnson', 'liam.johnson@primeestate.com', '+1-310-555-0142', 1.75),
('Olivia Chen', 'olivia.chen@urbanhomes.com', '+1-646-555-0227', 2.10),
('Noah Patel', 'noah.patel@luxuryres.com', '+1-415-555-0339', 3.00),
('Emma Robinson', 'emma.robinson@dreamspace.com', '+1-305-555-0451', 1.90),
('Ava Thompson', 'ava.thompson@eliteagents.com', '+1-206-555-0555', 2.35),
('Mason Lee', 'mason.lee@metropolisrealty.com', '+1-702-555-0613', 1.85),
('Isabella Davis', 'isabella.davis@homefinder.com', '+1-512-555-0734', 2.20),
('Ethan Garcia', 'ethan.garcia@skylineprop.com', '+1-312-555-0821', 2.75),
('Mia Wilson', 'mia.wilson@havenestates.com', '+1-480-555-0975', 2.00),

('James Anderson','james.anderson@realtyhub.com','+1-212-555-1001',2.10),
('Charlotte White','charlotte.white@primeestate.com','+1-310-555-1002',1.80),
('Benjamin Harris','ben.harris@urbanhomes.com','+1-646-555-1003',2.40),
('Amelia Clark','amelia.clark@luxuryres.com','+1-415-555-1004',2.90),
('Lucas Lewis','lucas.lewis@dreamspace.com','+1-305-555-1005',1.95),
('Harper Walker','harper.walker@eliteagents.com','+1-206-555-1006',2.30),
('Henry Hall','henry.hall@metropolisrealty.com','+1-702-555-1007',1.85),
('Evelyn Allen','evelyn.allen@homefinder.com','+1-512-555-1008',2.20),
('Alexander Young','alex.young@skylineprop.com','+1-312-555-1009',2.65),
('Abigail King','abigail.king@havenestates.com','+1-480-555-1010',2.05),

('Daniel Wright','daniel.wright@realtyhub.com','+1-212-555-1011',2.15),
('Emily Scott','emily.scott@primeestate.com','+1-310-555-1012',1.70),
('Matthew Green','matt.green@urbanhomes.com','+1-646-555-1013',2.55),
('Ella Baker','ella.baker@luxuryres.com','+1-415-555-1014',3.10),
('Joseph Adams','joseph.adams@dreamspace.com','+1-305-555-1015',1.90),
('Avery Nelson','avery.nelson@eliteagents.com','+1-206-555-1016',2.25),
('David Carter','david.carter@metropolisrealty.com','+1-702-555-1017',2.05),
('Scarlett Mitchell','scarlett.mitchell@homefinder.com','+1-512-555-1018',2.35),
('Samuel Perez','samuel.perez@skylineprop.com','+1-312-555-1019',2.70),
('Victoria Roberts','victoria.roberts@havenestates.com','+1-480-555-1020',2.15),

('Anthony Turner','anthony.turner@realtyhub.com','+1-212-555-1021',2.40),
('Madison Phillips','madison.phillips@primeestate.com','+1-310-555-1022',1.85),
('Joshua Campbell','joshua.campbell@urbanhomes.com','+1-646-555-1023',2.60),
('Luna Parker','luna.parker@luxuryres.com','+1-415-555-1024',3.20),
('Andrew Evans','andrew.evans@dreamspace.com','+1-305-555-1025',1.95),
('Chloe Edwards','chloe.edwards@eliteagents.com','+1-206-555-1026',2.30),
('Christopher Collins','chris.collins@metropolisrealty.com','+1-702-555-1027',2.00),
('Grace Stewart','grace.stewart@homefinder.com','+1-512-555-1028',2.45),
('Ryan Sanchez','ryan.sanchez@skylineprop.com','+1-312-555-1029',2.75),
('Lily Morris','lily.morris@havenestates.com','+1-480-555-1030',2.10),

('Nathan Rogers','nathan.rogers@realtyhub.com','+1-212-555-1031',2.05),
('Zoey Reed','zoey.reed@primeestate.com','+1-310-555-1032',1.90),
('Aaron Cook','aaron.cook@urbanhomes.com','+1-646-555-1033',2.55),
('Hannah Morgan','hannah.morgan@luxuryres.com','+1-415-555-1034',3.00),
('Justin Bell','justin.bell@dreamspace.com','+1-305-555-1035',2.00),
('Natalie Murphy','natalie.murphy@eliteagents.com','+1-206-555-1036',2.35),
('Brandon Bailey','brandon.bailey@metropolisrealty.com','+1-702-555-1037',1.85),
('Samantha Rivera','samantha.rivera@homefinder.com','+1-512-555-1038',2.40),
('Kevin Cooper','kevin.cooper@skylineprop.com','+1-312-555-1039',2.65),
('Zara Richardson','zara.richardson@havenestates.com','+1-480-555-1040',2.15),

('Jason Cox','jason.cox@realtyhub.com','+1-212-555-1041',2.20),
('Paisley Howard','paisley.howard@primeestate.com','+1-310-555-1042',1.80),
('Eric Ward','eric.ward@urbanhomes.com','+1-646-555-1043',2.50),
('Audrey Torres','audrey.torres@luxuryres.com','+1-415-555-1044',3.10),
('Jordan Peterson','jordan.peterson@dreamspace.com','+1-305-555-1045',2.00),
('Bella Gray','bella.gray@eliteagents.com','+1-206-555-1046',2.25),
('Patrick Ramirez','patrick.ramirez@metropolisrealty.com','+1-702-555-1047',1.95),
('Skylar James','skylar.james@homefinder.com','+1-512-555-1048',2.35),
('Tyler Watson','tyler.watson@skylineprop.com','+1-312-555-1049',2.60),
('Ruby Brooks','ruby.brooks@havenestates.com','+1-480-555-1050',2.05);

/* INSERTING INTO Destination*/

INSERT INTO Destination (Name, Country, Description, Rating) VALUES
('Paris', 'France', 'The city of lights, famous for the Eiffel Tower and art museums.', 4.8),
('Tokyo', 'Japan', 'A bustling city blending modern skyscrapers with traditional temples.', 4.7),
('New York', 'USA', 'The Big Apple, known for Times Square, Broadway, and diverse culture.', 4.6),
('Rome', 'Italy', 'Historic city with the Colosseum, Vatican City, and ancient ruins.', 4.7),
('Sydney', 'Australia', 'Famous for the Sydney Opera House and beautiful beaches.', 4.5),
('Cape Town', 'South Africa', 'Known for Table Mountain, scenic landscapes, and wildlife.', 4.4),
('Barcelona', 'Spain', 'Vibrant city with architecture by Gaudí and Mediterranean beaches.', 4.6),
('Istanbul', 'Turkey', 'Where Europe meets Asia, famous for mosques and markets.', 4.5),
('Rio de Janeiro', 'Brazil', 'Famous for Copacabana beach, Carnival, and Christ the Redeemer.', 4.5),
('Dubai', 'UAE', 'Modern city with skyscrapers, luxury shopping, and desert adventures.', 4.4),

('London','UK','Historic city with Big Ben, Thames river and royal heritage.',4.7),
('Berlin','Germany','Capital known for history, museums and vibrant nightlife.',4.5),
('Amsterdam','Netherlands','Canals, cycling culture and artistic heritage.',4.6),
('Vienna','Austria','Classical music, imperial palaces and coffee culture.',4.7),
('Prague','Czech Republic','Fairytale architecture and historic old town square.',4.6),
('Budapest','Hungary','Famous for thermal baths and Danube river views.',4.6),
('Lisbon','Portugal','Colorful hills, trams and Atlantic ocean views.',4.5),
('Athens','Greece','Ancient ruins including the Acropolis.',4.6),
('Zurich','Switzerland','Beautiful lakeside city with Alpine scenery.',4.7),
('Geneva','Switzerland','International city with stunning lake and mountains.',4.6),

('Venice','Italy','Romantic canals and gondola rides.',4.8),
('Florence','Italy','Birthplace of Renaissance art and architecture.',4.8),
('Milan','Italy','Fashion capital with modern and historic charm.',4.6),
('Naples','Italy','Gateway to Pompeii and Amalfi coast.',4.5),
('Munich','Germany','Oktoberfest, beer gardens and Bavarian culture.',4.6),
('Hamburg','Germany','Major port city with modern architecture.',4.5),
('Brussels','Belgium','Famous for waffles, chocolate and EU headquarters.',4.4),
('Copenhagen','Denmark','Colorful harbor and cycling-friendly streets.',4.7),
('Stockholm','Sweden','Island city with Scandinavian design.',4.7),
('Oslo','Norway','Fjords, museums and Viking heritage.',4.6),

('Helsinki','Finland','Modern Nordic city with seaside charm.',4.5),
('Reykjavik','Iceland','Gateway to volcanoes and northern lights.',4.8),
('Dublin','Ireland','Friendly city with pubs and literary history.',4.6),
('Edinburgh','Scotland','Historic castle and festival city.',4.7),
('Manchester','UK','Industrial heritage and football culture.',4.5),
('Glasgow','Scotland','Art, music and vibrant culture.',4.5),
('Seville','Spain','Flamenco dancing and Moorish architecture.',4.7),
('Madrid','Spain','Royal palace, parks and nightlife.',4.6),
('Valencia','Spain','City of arts and futuristic architecture.',4.5),
('Malaga','Spain','Sunny beaches and Picasso heritage.',4.6),

('Los Angeles','USA','Hollywood, beaches and entertainment.',4.6),
('San Francisco','USA','Golden Gate Bridge and tech culture.',4.7),
('Chicago','USA','Architecture and deep dish pizza.',4.6),
('Las Vegas','USA','Entertainment capital and casinos.',4.5),
('Miami','USA','Beaches and Latin American culture.',4.6),
('Boston','USA','Historic American city and universities.',4.7),
('Seattle','USA','Coffee culture and tech hub.',4.6),
('Washington DC','USA','Capital with monuments and museums.',4.7),
('Orlando','USA','Theme parks and family attractions.',4.5),
('Houston','USA','Space center and diverse culture.',4.5),

('Toronto','Canada','Multicultural city and CN Tower.',4.6),
('Vancouver','Canada','Mountains and ocean views.',4.8),
('Montreal','Canada','French culture and festivals.',4.7),
('Quebec City','Canada','European charm in North America.',4.7),
('Mexico City','Mexico','Historic sites and vibrant food scene.',4.6),
('Cancun','Mexico','Beach resort paradise.',4.5),
('Lima','Peru','Gateway to Machu Picchu.',4.6),
('Cusco','Peru','Ancient Incan city.',4.7),
('Buenos Aires','Argentina','Tango and European-style architecture.',4.7),
('Santiago','Chile','Andes mountain backdrop.',4.5),

('Beijing','China','Great Wall and Forbidden City.',4.7),
('Shanghai','China','Modern skyline and historic districts.',4.6),
('Hong Kong','China','Skyline, shopping and harbor views.',4.7),
('Seoul','South Korea','K-pop culture and palaces.',4.6),
('Busan','South Korea','Beaches and temples.',4.5),
('Bangkok','Thailand','Temples and street food.',4.7),
('Phuket','Thailand','Island beaches and nightlife.',4.6),
('Chiang Mai','Thailand','Mountains and temples.',4.6),
('Bali','Indonesia','Tropical paradise and culture.',4.8),
('Jakarta','Indonesia','Bustling capital city.',4.4),

('Kuala Lumpur','Malaysia','Petronas towers and food culture.',4.6),
('Singapore','Singapore','Clean, futuristic city.',4.8),
('Manila','Philippines','Historic sites and islands.',4.4),
('Hanoi','Vietnam','Old quarter and lakes.',4.6),
('Ho Chi Minh City','Vietnam','Dynamic city and history.',4.5),
('Colombo','Sri Lanka','Coastal city and temples.',4.5),
('Kathmandu','Nepal','Gateway to Himalayas.',4.7),
('Male','Maldives','Luxury island destination.',4.8),
('Doha','Qatar','Modern skyline and desert culture.',4.5),
('Riyadh','Saudi Arabia','Rapidly modernizing capital.',4.4),

('Cairo','Egypt','Pyramids and ancient history.',4.7),
('Marrakech','Morocco','Markets and desert gateway.',4.6),
('Nairobi','Kenya','Safari starting point.',4.6),
('Zanzibar','Tanzania','Tropical island paradise.',4.7),
('Johannesburg','South Africa','Urban culture and history.',4.5),
('Lagos','Nigeria','Largest African city.',4.4),
('Accra','Ghana','Beaches and vibrant culture.',4.5),
('Addis Ababa','Ethiopia','African Union headquarters.',4.4),
('Casablanca','Morocco','Coastal city and architecture.',4.5),
('Tunis','Tunisia','Mediterranean charm.',4.4),

('Auckland','New Zealand','Harbor city and adventure sports.',4.8),
('Wellington','New Zealand','Creative capital city.',4.6),
('Queenstown','New Zealand','Adventure capital of world.',4.9),
('Melbourne','Australia','Arts, coffee and sports.',4.7),
('Brisbane','Australia','River city with sunny weather.',4.6),
('Perth','Australia','Remote city with beaches.',4.5),
('Gold Coast','Australia','Surf beaches and nightlife.',4.5),
('Hobart','Australia','Historic harbor city.',4.6),
('Suva','Fiji','Island capital and beaches.',4.5),
('Port Louis','Mauritius','Tropical island city.',4.7);

/* INSERTING INTO Hotel*/

INSERT INTO Hotel (destination_id, Name, Rating, Contact_no) VALUES
(1, 'Le Meurice', 4.8, '+33-1-44-58-10-10'),
(2, 'Park Hyatt Tokyo', 4.7, '+81-3-6270-1234'),
(3, 'The Plaza', 4.6, '+1-212-759-3000'),
(4, 'Hotel de Russie', 4.7, '+39-06-328-821'),
(5, 'Shangri-La Sydney', 4.5, '+61-2-9250-6000'),
(6, 'One&Only Cape Town', 4.4, '+27-21-202-7000'),
(7, 'W Barcelona', 4.6, '+34-93-280-9100'),
(8, 'Four Seasons Istanbul', 4.5, '+90-212-326-4646'),
(9, 'Belmond Copacabana Palace', 4.5, '+55-21-2548-7070'),
(10, 'Burj Al Arab', 4.4, '+971-4-301-7777'),

(11,'Alpine View Resort',4.2,'+1-800-100021'),
(12,'Emerald Bay Hotel',4.3,'+1-800-100022'),
(13,'Golden Sands Inn',4.1,'+1-800-100023'),
(14,'Ocean Breeze Suites',4.5,'+1-800-100024'),
(15,'Royal Garden Hotel',4.6,'+1-800-100025'),
(16,'Palm Paradise Resort',4.4,'+1-800-100026'),
(17,'Skyline Tower Stay',4.3,'+1-800-100027'),
(18,'Mountain Peak Lodge',4.2,'+1-800-100028'),
(19,'Crystal Lake Hotel',4.4,'+1-800-100029'),
(20,'Sunrise Bay Resort',4.5,'+1-800-100030'),

(21,'Elite Comfort Hotel',4.3,'+1-800-100031'),
(22,'Urban Nest Suites',4.1,'+1-800-100032'),
(23,'Paradise Retreat',4.6,'+1-800-100033'),
(24,'City Lights Hotel',4.2,'+1-800-100034'),
(25,'Royal Orchid Stay',4.5,'+1-800-100035'),
(26,'Blue Lagoon Resort',4.4,'+1-800-100036'),
(27,'Grand Horizon Hotel',4.6,'+1-800-100037'),
(28,'Comfort Zone Inn',4.1,'+1-800-100038'),
(29,'Golden Gate Hotel',4.3,'+1-800-100039'),
(30,'Pearl City Suites',4.4,'+1-800-100040'),

(31,'Harbour Lights Hotel',4.5,'+1-800-100041'),
(32,'Sea Breeze Resort',4.6,'+1-800-100042'),
(33,'Sky Palace Inn',4.2,'+1-800-100043'),
(34,'Hilltop Heaven Stay',4.3,'+1-800-100044'),
(35,'Royal Crown Hotel',4.7,'+1-800-100045'),
(36,'Green Valley Lodge',4.4,'+1-800-100046'),
(37,'Elite Plaza Suites',4.5,'+1-800-100047'),
(38,'Sunset Paradise Hotel',4.6,'+1-800-100048'),
(39,'Golden Sunrise Resort',4.3,'+1-800-100049'),
(40,'Crystal Palace Hotel',4.6,'+1-800-100050'),

(41,'Urban Oasis Inn',4.2,'+1-800-100051'),
(42,'Royal Skyline Hotel',4.5,'+1-800-100052'),
(43,'Palm Breeze Suites',4.4,'+1-800-100053'),
(44,'Oceanic Retreat',4.6,'+1-800-100054'),
(45,'Dreamland Resort',4.5,'+1-800-100055'),
(46,'City Comfort Hotel',4.3,'+1-800-100056'),
(47,'Golden Horizon Inn',4.4,'+1-800-100057'),
(48,'Majestic Palace Stay',4.7,'+1-800-100058'),
(49,'Sunset Dream Hotel',4.6,'+1-800-100059'),
(50,'Sky View Lodge',4.3,'+1-800-100060'),

(51,'Royal Paradise Resort',4.5,'+1-800-100061'),
(52,'Urban Grand Hotel',4.2,'+1-800-100062'),
(53,'Ocean Pearl Suites',4.6,'+1-800-100063'),
(54,'City Star Hotel',4.4,'+1-800-100064'),
(55,'Grand Plaza Resort',4.6,'+1-800-100065'),
(56,'Sunrise Comfort Inn',4.3,'+1-800-100066'),
(57,'Elite Crown Hotel',4.7,'+1-800-100067'),
(58,'Blue Wave Resort',4.5,'+1-800-100068'),
(59,'Golden Pearl Hotel',4.6,'+1-800-100069'),
(60,'Sky Heights Suites',4.4,'+1-800-100070'),

(61,'Royal Blue Hotel',4.5,'+1-800-100071'),
(62,'Urban Paradise Resort',4.6,'+1-800-100072'),
(63,'Sunshine Palace',4.3,'+1-800-100073'),
(64,'Mountain Royal Inn',4.4,'+1-800-100074'),
(65,'Dream Palace Hotel',4.7,'+1-800-100075'),
(66,'Golden Dream Resort',4.6,'+1-800-100076'),
(67,'Sky Royal Suites',4.5,'+1-800-100077'),
(68,'Ocean Royal Hotel',4.4,'+1-800-100078'),
(69,'Sun Palace Resort',4.5,'+1-800-100079'),
(70,'Grand Sky Hotel',4.6,'+1-800-100080'),

(71,'Royal Elite Suites',4.4,'+1-800-100081'),
(72,'City Royal Hotel',4.5,'+1-800-100082'),
(73,'Sunrise Royal Resort',4.6,'+1-800-100083'),
(74,'Golden Elite Inn',4.3,'+1-800-100084'),
(75,'Dream Sky Resort',4.7,'+1-800-100085'),
(76,'Blue Sky Palace',4.5,'+1-800-100086'),
(77,'Royal Comfort Hotel',4.4,'+1-800-100087'),
(78,'Ocean Sky Resort',4.6,'+1-800-100088'),
(79,'Grand Dream Suites',4.5,'+1-800-100089'),
(80,'Elite Sunrise Hotel',4.6,'+1-800-100090'),

(81,'Paradise Dream Resort',4.7,'+1-800-100091'),
(82,'Royal Dream Hotel',4.5,'+1-800-100092'),
(83,'Sky Paradise Inn',4.4,'+1-800-100093'),
(84,'Ocean Dream Suites',4.6,'+1-800-100094'),
(85,'Grand Royal Palace',4.7,'+1-800-100095'),
(86,'Sun Royal Hotel',4.5,'+1-800-100096'),
(87,'Dream Elite Resort',4.6,'+1-800-100097'),
(88,'Royal Sky Hotel',4.4,'+1-800-100098'),
(89,'Golden Royal Suites',4.6,'+1-800-100099'),
(90,'City Dream Resort',4.5,'+1-800-100100'),

(91,'Ocean Elite Palace',4.6,'+1-800-100101'),
(92,'Royal Ocean Hotel',4.4,'+1-800-100102'),
(93,'Golden Paradise Suites',4.7,'+1-800-100103'),
(94,'Sun Dream Palace',4.5,'+1-800-100104'),
(95,'Grand Elite Resort',4.6,'+1-800-100105'),
(96,'Royal Sunset Hotel',4.5,'+1-800-100106'),
(97,'Dream Horizon Suites',4.6,'+1-800-100107'),
(98,'Sky Elite Resort',4.4,'+1-800-100108'),
(99,'Golden Horizon Hotel',4.5,'+1-800-100109'),
(100,'Royal Bay Palace',4.6,'+1-800-100110');



/* INSERTING INTO Room*/

INSERT INTO Room (hotel_id, Room_Type, PricePerNight, Capacity, Availability_Status) VALUES
(1, 'Deluxe Suite', 450.00, 2, TRUE),
(2, 'Executive Room', 350.00, 2, TRUE),
(3, 'Presidential Suite', 900.00, 4, TRUE),
(4, 'Superior Room', 300.00, 2, TRUE),
(5, 'Ocean View Suite', 500.00, 3, TRUE),
(6, 'Luxury King Room', 400.00, 2, TRUE),
(7, 'Penthouse Suite', 1000.00, 4, TRUE),
(8, 'Family Room', 320.00, 4, TRUE),
(9, 'Deluxe Double', 280.00, 2, TRUE),
(10, 'Royal Suite', 850.00, 3, TRUE),

(11,'Deluxe Suite',460.00,2,TRUE),
(12,'Executive Room',360.00,2,TRUE),
(13,'Presidential Suite',920.00,4,TRUE),
(14,'Superior Room',310.00,2,TRUE),
(15,'Ocean View Suite',510.00,3,TRUE),
(16,'Luxury King Room',420.00,2,TRUE),
(17,'Penthouse Suite',1010.00,4,TRUE),
(18,'Family Room',330.00,4,TRUE),
(19,'Deluxe Double',290.00,2,TRUE),
(20,'Royal Suite',860.00,3,TRUE),

(21,'Deluxe Suite',455.00,2,TRUE),
(22,'Executive Room',365.00,2,TRUE),
(23,'Presidential Suite',905.00,4,TRUE),
(24,'Superior Room',315.00,2,TRUE),
(25,'Ocean View Suite',505.00,3,TRUE),
(26,'Luxury King Room',410.00,2,TRUE),
(27,'Penthouse Suite',995.00,4,TRUE),
(28,'Family Room',325.00,4,TRUE),
(29,'Deluxe Double',285.00,2,TRUE),
(30,'Royal Suite',845.00,3,TRUE),

(31,'Deluxe Suite',470.00,2,TRUE),
(32,'Executive Room',355.00,2,TRUE),
(33,'Presidential Suite',930.00,4,TRUE),
(34,'Superior Room',305.00,2,TRUE),
(35,'Ocean View Suite',515.00,3,TRUE),
(36,'Luxury King Room',430.00,2,TRUE),
(37,'Penthouse Suite',1020.00,4,TRUE),
(38,'Family Room',340.00,4,TRUE),
(39,'Deluxe Double',295.00,2,TRUE),
(40,'Royal Suite',870.00,3,TRUE),

(41,'Deluxe Suite',465.00,2,TRUE),
(42,'Executive Room',370.00,2,TRUE),
(43,'Presidential Suite',940.00,4,TRUE),
(44,'Superior Room',320.00,2,TRUE),
(45,'Ocean View Suite',520.00,3,TRUE),
(46,'Luxury King Room',435.00,2,TRUE),
(47,'Penthouse Suite',1030.00,4,TRUE),
(48,'Family Room',345.00,4,TRUE),
(49,'Deluxe Double',300.00,2,TRUE),
(50,'Royal Suite',880.00,3,TRUE),

(51,'Deluxe Suite',450.00,2,TRUE),
(52,'Executive Room',350.00,2,TRUE),
(53,'Presidential Suite',910.00,4,TRUE),
(54,'Superior Room',300.00,2,TRUE),
(55,'Ocean View Suite',500.00,3,TRUE),
(56,'Luxury King Room',400.00,2,TRUE),
(57,'Penthouse Suite',1000.00,4,TRUE),
(58,'Family Room',320.00,4,TRUE),
(59,'Deluxe Double',280.00,2,TRUE),
(60,'Royal Suite',850.00,3,TRUE),

-- pattern continues same style till 300

(291,'Deluxe Suite',470.00,2,TRUE),
(292,'Executive Room',365.00,2,TRUE),
(293,'Presidential Suite',935.00,4,TRUE),
(294,'Superior Room',315.00,2,TRUE),
(295,'Ocean View Suite',520.00,3,TRUE),
(296,'Luxury King Room',430.00,2,TRUE),
(297,'Penthouse Suite',1025.00,4,TRUE),
(298,'Family Room',340.00,4,TRUE),
(299,'Deluxe Double',295.00,2,TRUE),
(300,'Royal Suite',875.00,3,TRUE);

/* INSERTING INTO Tour_Type*/

INSERT INTO Tour_Type (Type_Name) VALUES
('Adventure Tour'),
('Cultural Heritage Tour'),
('Wildlife Safari'),
('City Sightseeing Tour'),
('Beach & Island Tour'),
('Culinary & Wine Tour'),
('Hiking & Trekking Tour'),
('Luxury Cruise Tour'),
('Religious & Pilgrimage Tour'),
('Eco & Nature Tour');

/* INSERTING INTO Package*/

INSERT INTO Package (agent_id, tour_type_id, Name, Duration_Days, Price, description)
VALUES
(1, 1, 'Himalayan Adventure Expedition', 10, 1200.00, 'A thrilling adventure tour through the Himalayas including trekking, rafting, and camping.'),
(2, 2, 'Cultural Wonders of Italy', 7, 1500.00, 'Explore the ancient ruins of Rome, the art of Florence, and the canals of Venice.'),
(3, 3, 'African Safari Experience', 8, 2200.00, 'Witness the Big Five in Kenya and Tanzania with luxury lodges and guided safaris.'),
(4, 4, 'Tokyo & Kyoto Highlights', 6, 1300.00, 'Discover Japan’s modern and traditional culture through iconic cities.'),
(5, 5, 'Maldives Island Retreat', 5, 1800.00, 'Relax on pristine beaches with snorkeling, spa treatments, and ocean villas.'),
(6, 6, 'Taste of France Culinary Tour', 7, 1700.00, 'Enjoy French cuisine and wine-tasting in Paris, Lyon, and Bordeaux.'),
(7, 7, 'Everest Base Camp Trek', 14, 2000.00, 'A guided trek to the iconic Everest Base Camp with full support team.'),
(8, 8, 'Mediterranean Cruise Escape', 10, 2500.00, 'Luxury cruise visiting Greece, Italy, and Spain with onboard entertainment.'),
(9, 9, 'Holy Lands Pilgrimage', 9, 1600.00, 'Visit Jerusalem, Bethlehem, and Nazareth on a guided religious journey.'),
(10, 10, 'Amazon Rainforest Eco Tour', 6, 1400.00, 'Experience the biodiversity of the Amazon with sustainable eco-lodges.');

-- INSERT INTO Package (agent_id, tour_type_id, Name, Duration_Days, Price, description)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 490
-- )
-- SELECT
--     FLOOR(1 + RAND() * 100) AS agent_id, 
--     FLOOR(1 + RAND() * 10) AS tour_type_id,  
--     CONCAT(
--         ELT(FLOOR(1 + RAND() * 10),
--             'Adventure Escape','Cultural Discovery','Wildlife Expedition','City Explorer',
--             'Beach Paradise','Gourmet Getaway','Mountain Trek','Luxury Cruise','Pilgrimage Journey','Eco Retreat'),
--         ' Package #', n
--     ) AS Name,
--     FLOOR(3 + RAND() * 15) AS Duration_Days,  
--     ROUND(500 + RAND() * 3000, 2) AS Price,  
--     CONCAT(
--         'A wonderful ',
--         ELT(FLOOR(1 + RAND() * 10),
--             'adventure','cultural','wildlife','city','beach','culinary','trekking','cruise','religious','eco'),
--         ' experience designed for travelers seeking memorable journeys.'
--     ) AS description
-- FROM seq;

/* INSERTING INTO Package_Destination*/

INSERT INTO Package_Destination (package_id, destination_id, sequence_no)
VALUES
(1, 1, 1),  
(1, 2, 2),   
(2, 3, 1),   
(2, 4, 2),   
(2, 5, 3),   
(3, 6, 1),   
(3, 7, 2),   
(4, 8, 1),   
(4, 9, 2),   
(5, 10, 1); 

-- INSERT INTO Package_Destination (package_id, destination_id, sequence_no)
-- WITH RECURSIVE
--     pkg AS (SELECT MAX(package_id) AS max_pkg FROM Package),
--     dest AS (SELECT MAX(destination_id) AS max_dest FROM Destination),
-- 	 seq AS (
--         SELECT 1 AS n
--         UNION ALL
--         SELECT n + 1 FROM seq WHERE n < 990
--     )
-- SELECT
--     FLOOR(1 + RAND() * (SELECT max_pkg FROM pkg)),
--     FLOOR(1 + RAND() * (SELECT max_dest FROM dest)),
--     FLOOR(1 + RAND() * 5)
-- FROM seq;

/* INSERTING INTO Booking */

INSERT INTO Booking (customer_id, package_id, Booking_Date, Start_Date, End_Date, Total_Amount, status)
VALUES
(1, 1, '2025-01-05', '2025-02-01', '2025-02-10', 1200.00, 'Confirmed'),
(2, 2, '2025-02-12', '2025-03-01', '2025-03-08', 1500.00, 'Confirmed'),
(3, 3, '2025-02-20', '2025-04-01', '2025-04-08', 2200.00, 'Pending'),
(4, 4, '2025-03-10', '2025-04-15', '2025-04-21', 1300.00, 'Cancelled'),
(5, 5, '2025-03-22', '2025-05-01', '2025-05-05', 1800.00, 'Confirmed'),
(6, 6, '2025-04-01', '2025-05-10', '2025-05-17', 1700.00, 'Confirmed'),
(7, 7, '2025-04-15', '2025-06-01', '2025-06-14', 2000.00, 'Confirmed'),
(8, 8, '2025-05-10', '2025-06-20', '2025-06-30', 2500.00, 'Pending'),
(9, 9, '2025-05-25', '2025-07-01', '2025-07-09', 1600.00, 'Confirmed'),
(10, 10, '2025-06-05', '2025-07-15', '2025-07-21', 1400.00, 'Confirmed');

-- INSERT INTO Booking (customer_id, package_id, Booking_Date, Start_Date, End_Date, Total_Amount, status)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 990
-- )
-- SELECT
--     FLOOR(1 + RAND() * 1000) AS customer_id,    
--     FLOOR(1 + RAND() * 500) AS package_id,     
--     DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 500) DAY) AS Booking_Date,
--     DATE_ADD('2024-02-01', INTERVAL FLOOR(RAND() * 500) DAY) AS Start_Date,
--     DATE_ADD('2024-02-10', INTERVAL FLOOR(RAND() * 520) DAY) AS End_Date,
--     ROUND(500 + RAND() * 3500, 2) AS Total_Amount,  -- $500–$4000 range
--     ELT(FLOOR(1 + RAND() * 4), 'Pending', 'Confirmed', 'Cancelled', 'Completed') AS status
-- FROM seq;

/* INSERTING INTO Payment*/

INSERT INTO Payment (booking_id, Amount, Payment_Date, Method, transaction_id)
VALUES
(1, 1200.00, '2025-01-15', 'Credit Card', 'TXN1001'),
(2, 850.50, '2025-02-10', 'PayPal', 'TXN1002'),
(3, 2200.00, '2025-03-05', 'Debit Card', 'TXN1003'),
(4, 1450.75, '2025-04-01', 'Bank Transfer', 'TXN1004'),
(5, 1999.99, '2025-05-12', 'Credit Card', 'TXN1005'),
(6, 550.00, '2025-06-18', 'UPI', 'TXN1006'),
(7, 780.50, '2025-07-23', 'Cash', 'TXN1007'),
(8, 1100.00, '2025-08-14', 'PayPal', 'TXN1008'),
(9, 3050.00, '2025-09-29', 'Credit Card', 'TXN1009'),
(10, 999.99, '2025-10-05', 'Bank Transfer', 'TXN1010');

-- INSERT INTO Payment (booking_id, Amount, Payment_Date, Method, transaction_id)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 990
-- )

-- SELECT
--     FLOOR(1 + RAND() * (SELECT MAX(booking_id) FROM Booking)) AS booking_id,  
--     ROUND(100 + RAND() * 4000, 2) AS Amount,                                 
--     DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 670) DAY) AS Payment_Date, 
--     ELT(FLOOR(1 + RAND() * 6),
--         'Credit Card', 'Debit Card', 'PayPal', 'UPI', 'Bank Transfer', 'Cash') AS Method,
--     CONCAT('TXN', FLOOR(100000 + RAND() * 900000)) AS transaction_id         
-- FROM seq;

/* INSERTING INTO Transport*/

INSERT INTO Transport (type, Company_Name, Contact_No)
VALUES
('Airline', 'Emirates Airlines', '+971-600-555555'),
('Airline', 'Singapore Airlines', '+65-6223-8888'),
('Train', 'Amtrak Railways', '+1-800-872-7245'),
('Bus', 'Greyhound Lines', '+1-214-849-8100'),
('Car Rental', 'Hertz Car Rentals', '+1-800-654-3131'),
('Cruise', 'Royal Caribbean Cruises', '+1-305-341-0204'),
('Ferry', 'BC Ferries', '+1-888-223-3779'),
('Taxi', 'Uber Technologies', '+1-415-986-2104'),
('Helicopter', 'HeliDubai Tours', '+971-4208-1455'),
('Private Jet', 'NetJets Aviation', '+1-614-239-5500');

-- INSERT INTO Transport (type, Company_Name, Contact_No)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 190
-- )

-- SELECT
--     ELT(FLOOR(1 + RAND() * 8),
--         'Airline', 'Train', 'Bus', 'Ferry', 'Car Rental', 'Taxi', 'Cruise', 'Helicopter') AS type,
--     CONCAT(
--         ELT(FLOOR(1 + RAND() * 8),
--             'Skyway', 'Globe', 'Express', 'BlueLine', 'Star', 'JetGo', 'Prime', 'Rapid'),
--         ' ',
--         ELT(FLOOR(1 + RAND() * 8),
--             'Travels', 'Transport', 'Airways', 'Logistics', 'Lines', 'Cruises', 'Rentals', 'Tours')
--     ) AS Company_Name,
--     CONCAT('+', FLOOR(1 + RAND() * 90), '-', FLOOR(100000000 + RAND() * 900000000)) AS Contact_No
-- FROM seq;

/* INSERTING INTO Schedule*/

INSERT INTO Schedule (transport_id, source, destination, Departure_Time, Arrival_Time, fare)
VALUES
(1, 'Dubai', 'London', '2025-01-05 09:30:00', '2025-01-05 14:15:00', 750.00),
(2, 'Singapore', 'Tokyo', '2025-01-10 08:00:00', '2025-01-10 15:00:00', 680.00),
(3, 'New York', 'Washington D.C.', '2025-02-02 07:00:00', '2025-02-02 11:00:00', 120.00),
(4, 'Los Angeles', 'San Francisco', '2025-02-07 09:00:00', '2025-02-07 14:30:00', 90.00),
(5, 'Paris', 'Lyon', '2025-03-12 10:00:00', '2025-03-12 13:00:00', 150.00),
(6, 'Miami', 'Bahamas', '2025-03-25 12:00:00', '2025-03-25 18:00:00', 400.00),
(7, 'Vancouver', 'Victoria', '2025-04-05 09:30:00', '2025-04-05 12:00:00', 80.00),
(8, 'New York', 'Boston', '2025-04-20 07:00:00', '2025-04-20 10:00:00', 100.00),
(9, 'Dubai', 'Abu Dhabi', '2025-05-01 10:30:00', '2025-05-01 11:30:00', 200.00),
(10, 'Los Angeles', 'Las Vegas', '2025-05-15 09:00:00', '2025-05-15 11:00:00', 180.00);

-- INSERT INTO Schedule (transport_id, source, destination, Departure_Time, Arrival_Time, fare)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 490
-- )

-- SELECT
--     FLOOR(1 + RAND() * (SELECT MAX(transport_id) FROM Transport)) AS transport_id,
--     ELT(FLOOR(1 + RAND() * 12),
--         'New York','London','Paris','Tokyo','Dubai','Singapore',
--         'Sydney','Rome','Toronto','Berlin','Los Angeles','Bangkok') AS source,
--     ELT(FLOOR(1 + RAND() * 12),
--         'New York','London','Paris','Tokyo','Dubai','Singapore',
--         'Sydney','Rome','Toronto','Berlin','Los Angeles','Bangkok') AS destination,
--     DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND() * 180) DAY) 
--         + INTERVAL FLOOR(RAND() * 24) HOUR AS Departure_Time,
--     DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND() * 180) DAY) 
--         + INTERVAL FLOOR(2 + RAND() * 12) HOUR AS Arrival_Time,
--     ROUND(50 + RAND() * 950, 2) AS fare  -- $50–$1000 range
-- FROM seq
-- HAVING source <> destination;  

/* INSERTING INTO Booking_Transport*/

INSERT INTO Booking_Transport (booking_id, schedule_id, Seat_No)
VALUES
(1, 1, 'A1'),
(2, 2, 'B3'),
(3, 3, '12C'),
(4, 4, '7A'),
(5, 5, '15B'),
(6, 6, '2A'),
(7, 7, 'D4'),
(8, 8, '8C'),
(9, 9, '3B'),
(10, 10, '10A');

-- INSERT INTO Booking_Transport (booking_id, schedule_id, Seat_No)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 590
-- )
-- SELECT
--     FLOOR(1 + RAND() * (SELECT MAX(booking_id) FROM Booking)) AS booking_id,
--     FLOOR(1 + RAND() * (SELECT MAX(schedule_id) FROM Schedule)) AS schedule_id,
--     CONCAT(
--         ELT(FLOOR(1 + RAND() * 6), 'A', 'B', 'C', 'D', 'E', 'F'),
--         FLOOR(1 + RAND() * 40)
--     ) AS Seat_No
-- FROM seq;

/* INSERTING INTO Feedback*/

INSERT INTO Feedback (customer_id, package_id, Rating, Comments, Feedback_Date)
VALUES
(1, 1, 4.8, 'Absolutely loved the Himalayan Adventure! The guides were knowledgeable and friendly.', '2025-01-15'),
(2, 2, 4.5, 'Italy tour was well-organized, great hotels and amazing food.', '2025-02-20'),
(3, 3, 5.0, 'The African Safari was a once-in-a-lifetime experience. Highly recommend!', '2025-03-10'),
(4, 4, 4.2, 'Tokyo & Kyoto trip was fantastic. Wish there was more free time.', '2025-03-25'),
(5, 5, 4.9, 'The Maldives retreat was paradise! Perfect for relaxation.', '2025-04-05'),
(6, 6, 4.3, 'European highlights were great, though a bit rushed.', '2025-04-15'),
(7, 7, 4.7, 'Wonderful South American journey, great mix of culture and adventure.', '2025-05-01'),
(8, 8, 3.9, 'The local tour was good, but hotel service could be improved.', '2025-05-12'),
(9, 9, 4.6, 'Loved the family package! Activities were fun for all ages.', '2025-05-22'),
(10, 10, 4.4, 'Beautiful trip overall. Transportation could be slightly better.', '2025-06-01');

-- INSERT INTO Feedback (customer_id, package_id, Rating, Comments, Feedback_Date)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 490
-- )

-- SELECT
--     FLOOR(1 + RAND() * (SELECT MAX(customer_id) FROM Customer)) AS customer_id,
--     FLOOR(1 + RAND() * (SELECT MAX(package_id) FROM Package)) AS package_id,
--     ROUND(2.5 + RAND() * 2.5, 1) AS Rating,  
--     ELT(FLOOR(1 + RAND() * 8),
--         'Excellent experience overall!',
--         'Good value for money.',
--         'Loved the guides and activities.',
--         'Could be better organized.',
--         'Amazing food and accommodation!',
--         'A bit too long, but worth it.',
--         'Enjoyed every moment of the trip.',
--         'Would definitely book again!'
--     ) AS Comments,
--     DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 500) DAY) AS Feedback_Date
-- FROM seq;

/* INSERTING INTO Offer*/

INSERT INTO Offer (title, Discount_Percent, Start_Date, End_Date)
VALUES
('Winter Wonderland Discount', 15.00, '2024-12-01', '2025-02-28'),
('Summer Escape Deal', 20.00, '2025-06-01', '2025-08-31'),
('Spring Adventure Offer', 10.00, '2025-03-01', '2025-04-30'),
('Early Bird Booking', 25.00, '2025-01-01', '2025-01-31'),
('Luxury Getaway Promo', 30.00, '2025-05-01', '2025-06-15'),
('Family Fun Special', 18.00, '2025-07-01', '2025-09-30'),
('Last Minute Saver', 12.50, '2025-10-01', '2025-10-31'),
('Festival Season Sale', 22.00, '2025-11-01', '2025-11-30'),
('Weekend Getaway Offer', 8.00, '2025-02-01', '2025-02-28'),
('Holiday Mega Discount', 35.00, '2024-12-15', '2025-01-15');

-- INSERT INTO Offer (title, Discount_Percent, Start_Date, End_Date)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 200
-- )

-- SELECT
--     CONCAT(
--         ELT(FLOOR(1 + RAND() * 8),
--             'Summer Escape', 'Winter Retreat', 'Adventure Blast', 'Romantic Getaway',
--             'Family Holiday', 'Luxury Stay', 'Weekend Deal', 'Festive Offer'
--         ),
--         ' #', n
--     ) AS title,
--     ROUND(5 + RAND() * 35, 2) AS Discount_Percent,  
--     DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND() * 330) DAY) AS Start_Date,
--     DATE_ADD('2025-01-15', INTERVAL FLOOR(RAND() * 360) DAY) AS End_Date
-- FROM seq
-- HAVING End_Date > Start_Date;  

/* INSERTING INTO Package_Offer*/

INSERT INTO Package_Offer (package_id, offer_id)
VALUES
(1, 1),   
(2, 2),   
(3, 3),   
(4, 4),   
(5, 5),   
(6, 6),   
(7, 7),   
(8, 8),   
(9, 9),   
(10, 10); 

-- INSERT INTO Package_Offer (package_id, offer_id)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 290
-- )
-- SELECT
--     FLOOR(1 + RAND() * (SELECT MAX(package_id) FROM Package)) AS package_id,
--     FLOOR(1 + RAND() * (SELECT MAX(offer_id) FROM Offer)) AS offer_id
-- FROM seq;

/* INSERTING INTO Insurance_Provider*/

INSERT INTO Insurance_Provider (Provider_Name, Contact_No)
VALUES
('Allianz Travel Insurance', '+1-800-555-1201'),
('AXA Global Assistance', '+44-20-7946-1122'),
('Travel Guard by AIG', '+1-800-826-1300'),
('World Nomads Insurance', '+61-2-8263-0400'),
('Bupa Global Travel', '+45-70-23-24-60'),
('InsureMyTrip', '+1-800-487-4722'),
('Travelex Insurance Services', '+1-800-228-9792'),
('Generali Global Assistance', '+1-866-243-3540'),
('Seven Corners Travel Insurance', '+1-317-575-2656'),
('Tokio Marine HCC', '+1-800-605-2282'),
('Chubb Travel Protection', '+1-800-432-4822'),
('IMG Global Insurance', '+1-317-655-4500'),
('CSA Travel Protection', '+1-800-348-9505'),
('Nationwide Travel Insurance', '+1-877-970-9059'),
('Arch RoamRight Insurance', '+1-800-699-3845'),
('Allianz Global Assistance UK', '+44-1737-334-123'),
('Europ Assistance Group', '+33-1-41-85-85-85'),
('AXA Assistance USA', '+1-312-935-3500'),
('Cover-More Travel Insurance', '+61-2-8907-5000'),
('MAPFRE Asistencia', '+34-91-581-1800');

/* INSERTING INTO Travel_Insurance*/

INSERT INTO Travel_Insurance (customer_id, insurance_provider_id, Policy_No, Start_Date, End_Date, Coverage_Amount)
VALUES
(1, 1, 'POL-AZ-001', '2025-01-10', '2025-02-10', 50000.00),
(2, 2, 'POL-AXA-002', '2025-02-05', '2025-03-05', 40000.00),
(3, 3, 'POL-TG-003', '2025-03-01', '2025-03-20', 35000.00),
(4, 4, 'POL-WN-004', '2025-03-15', '2025-04-15', 25000.00),
(5, 5, 'POL-BU-005', '2025-04-01', '2025-05-01', 60000.00),
(6, 6, 'POL-IMT-006', '2025-04-10', '2025-05-20', 30000.00),
(7, 7, 'POL-TRX-007', '2025-05-05', '2025-06-05', 45000.00),
(8, 8, 'POL-GGA-008', '2025-05-20', '2025-06-20', 28000.00),
(9, 9, 'POL-SC-009', '2025-06-01', '2025-07-01', 32000.00),
(10, 10, 'POL-TM-010', '2025-06-15', '2025-07-15', 55000.00);

-- INSERT INTO Travel_Insurance (customer_id, insurance_provider_id, Policy_No, Start_Date, End_Date, Coverage_Amount)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 700
-- )

-- SELECT
--     FLOOR(1 + RAND() * (SELECT MAX(customer_id) FROM Customer)) AS customer_id,
--     FLOOR(1 + RAND() * (SELECT MAX(insurance_provider_id) FROM Insurance_Provider)) AS insurance_provider_id,
--     CONCAT('POL-', LPAD(FLOOR(1 + RAND() * 99999), 5, '0')) AS Policy_No,
--     DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND() * 180) DAY) AS Start_Date,
--     DATE_ADD('2025-01-15', INTERVAL FLOOR(RAND() * 210) DAY) AS End_Date,
--     ROUND(10000 + RAND() * 90000, 2) AS Coverage_Amount 
-- FROM seq
-- HAVING End_Date > Start_Date;

/* INSERTING INTO Custom_Package*/

INSERT INTO Custom_Package (customer_id, Name, Created_Date, Total_Cost)
VALUES
(1,  'Romantic Paris Getaway','2025-01-10', 4200.00),
(2,  'Family Thailand Adventure','2025-01-20', 5200.00),
(3,  'European Highlights Tour','2025-02-05', 6400.00),
(4,  'Japanese Culture Journey','2025-02-15', 4800.00),
(5,  'Luxury Maldives Escape','2025-03-01', 9500.00),
(6,  'Canadian Rockies Explorer','2025-03-10', 7300.00),
(7,  'Greek Island Hopper','2025-03-25', 6100.00),
(8,  'Safari in Kenya','2025-04-05', 8700.00),
(9,  'South American Discovery','2025-04-18', 8200.00),
(10, 'Bali Wellness Retreat','2025-05-01', 5600.00);

-- INSERT INTO Custom_Package (customer_id, Name, Created_Date, Total_Cost)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 290
-- )
-- SELECT
--     FLOOR(1 + RAND() * (SELECT MAX(customer_id) FROM Customer)) AS customer_id,
--     CONCAT(
--         ELT(FLOOR(1 + RAND() * 10),
--             'Adventure Escape', 'Cultural Discovery', 'Luxury Getaway', 'Family Holiday',
--             'Romantic Journey', 'Nature Expedition', 'Historical Trail', 'City Explorer',
--             'Tropical Retreat', 'Winter Wonderland'
--         ),
--         ' #', n
--     ) AS Name,
--     DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND() * 200) DAY) AS Created_Date,
--     ROUND(1500 + RAND() * 8500, 2) AS Total_Cost  
-- FROM seq;

/* INSERTING INTO Custom_Package_Destination*/

INSERT INTO Custom_Package_Destination (custom_pkg_id, destination_id, Sequence_No)
VALUES
(1,  1, 1),   
(2,  2, 1),   
(2,  3, 2),   
(3,  4, 1),   
(3,  5, 2),   
(4,  6, 1),   
(4,  7, 2),   
(5,  8, 1),   
(6,  9, 1),   
(7, 10, 1);   

-- INSERT INTO Custom_Package_Destination (custom_pkg_id, destination_id, Sequence_No)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 490
-- )

-- SELECT
--     FLOOR(1 + RAND() * (SELECT MAX(custom_pkg_id) FROM Custom_Package)) AS custom_pkg_id,
--     FLOOR(1 + RAND() * (SELECT MAX(destination_id) FROM Destination))   AS destination_id,
--     FLOOR(1 + RAND() * 5) AS Sequence_No  
-- FROM seq;

/* INSERTING INTO Support_Ticket*/

INSERT INTO Support_Ticket (customer_id, booking_id, Issue_Type, Description, status, created_at, resolved_at)
VALUES
(1, 1, 'Payment Issue', 'Customer was charged twice for the same booking.', 'Resolved', '2025-01-10 10:00:00', '2025-01-11 14:30:00'),
(2, 2, 'Date Change Request', 'Customer requested to reschedule trip dates.', 'Resolved', '2025-01-15 09:45:00', '2025-01-16 16:00:00'),
(3, 3, 'Refund Request', 'Trip canceled due to illness; refund requested.', 'Pending', '2025-02-01 11:00:00', NULL),
(4, 4, 'Booking Confirmation Delay', 'Customer did not receive confirmation email.', 'Resolved', '2025-02-05 12:15:00', '2025-02-05 17:30:00'),
(5, 5, 'Hotel Quality Issue', 'Hotel was not up to the expected standard.', 'In Progress', '2025-02-10 14:00:00', NULL),
(6, 6, 'Transportation Delay', 'Bus was delayed by more than 3 hours.', 'Resolved', '2025-02-18 09:00:00', '2025-02-19 13:00:00'),
(7, 7, 'Insurance Claim', 'Lost baggage; customer filed insurance claim.', 'Resolved', '2025-03-01 08:30:00', '2025-03-05 11:45:00'),
(8, 8, 'Package Upgrade Request', 'Customer wanted to upgrade to deluxe package.', 'Cancelled', '2025-03-12 15:20:00', '2025-03-13 10:00:00'),
(9, 9, 'Incorrect Invoice', 'Invoice total does not match package cost.', 'Resolved', '2025-03-20 10:45:00', '2025-03-21 12:10:00'),
(10, 10, 'Lost Ticket', 'Customer misplaced travel ticket; needs reissue.', 'Resolved', '2025-03-25 09:15:00', '2025-03-25 15:00:00');

-- INSERT INTO Support_Ticket (customer_id, booking_id, Issue_Type, Description, status, created_at, resolved_at)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 300
-- )
-- SELECT
--     FLOOR(1 + RAND() * (SELECT MAX(customer_id) FROM Customer)) AS customer_id,
--     FLOOR(1 + RAND() * (SELECT MAX(booking_id) FROM Booking))   AS booking_id,
--     ELT(FLOOR(1 + RAND() * 8),
--         'Payment Issue',
--         'Refund Request',
--         'Booking Error',
--         'Hotel Issue',
--         'Transportation Delay',
--         'Package Upgrade Request',
--         'Insurance Claim',
--         'General Inquiry'
--     ) AS Issue_Type,
--     ELT(FLOOR(1 + RAND() * 6),
--         'Customer reported an issue via email.',
--         'Support team contacted the supplier for resolution.',
--         'Awaiting confirmation from customer.',
--         'Refund process initiated.',
--         'Resolved after escalation to manager.',
--         'Pending response from hotel partner.'
--     ) AS Description,
--     ELT(FLOOR(1 + RAND() * 4), 'Pending', 'In Progress', 'Resolved', 'Cancelled') AS status,
--     DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND() * 120) DAY)
--         + INTERVAL FLOOR(RAND() * 24) HOUR AS created_at,
--     CASE
--         WHEN RAND() < 0.7 THEN
--             DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND() * 150) DAY)
--             + INTERVAL FLOOR(RAND() * 24) HOUR
--         ELSE NULL
--     END AS resolved_at;

/* INSERTING INTO Loyalty_Program*/

INSERT INTO Loyalty_Program (name, Points_Per_Rupee, Tier_Levels)
VALUES
('Traveler Rewards', 1.00, 'Silver, Gold, Platinum'),
('FlyHigh Club', 0.75, 'Basic, Premium, Elite'),
('Holiday Plus', 1.25, 'Bronze, Silver, Gold, Diamond'),
('Luxury Escapes Loyalty', 1.50, 'Member, VIP, Royal'),
('Adventure Miles', 0.90, 'Explorer, Adventurer, Trailblazer'),
('Hotel Comfort Points', 1.10, 'Classic, Silver, Gold, Platinum'),
('Global Explorer Program', 1.30, 'Traveler, Voyager, Globetrotter'),
('Eco Traveler Rewards', 0.80, 'Green, Sustainable, Eco Elite'),
('JetSet Loyalty', 1.20, 'Silver, Gold, Black'),
('Sunshine Club', 1.00, 'Blue, Silver, Gold');

/* INSERTING INTO Customer_Loyalty*/

INSERT INTO Customer_Loyalty (customer_id, program_id, Total_Points, Tier_Level)
VALUES
(1, 1, 1200.00, 'Silver'),
(2, 2, 3400.00, 'Gold'),
(3, 3, 600.00, 'Bronze'),
(4, 4, 9800.00, 'Diamond'),
(5, 5, 4500.00, 'Gold'),
(6, 6, 7200.00, 'Platinum'),
(7, 7, 2500.00, 'Silver'),
(8, 8, 890.00, 'Bronze'),
(9, 9, 11500.00, 'Black'),
(10, 10, 1600.00, 'Silver');

-- INSERT INTO Customer_Loyalty (customer_id, program_id, Total_Points, Tier_Level)
-- WITH RECURSIVE seq AS (
--     SELECT 1 AS n
--     UNION ALL
--     SELECT n + 1 FROM seq WHERE n < 290
-- )

-- SELECT
--     FLOOR(1 + RAND() * (SELECT MAX(customer_id) FROM Customer)) AS customer_id,
--     FLOOR(1 + RAND() * (SELECT MAX(program_id) FROM Loyalty_Program)) AS program_id,
--     ROUND(100 + RAND() * 15000, 2) AS Total_Points, 
--     ELT(FLOOR(1 + RAND() * 6),
--         'Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'Black'
--     ) AS Tier_Level
-- FROM seq;

/* INSERTING INTO Loyalty_Transaction*/

INSERT INTO Loyalty_Transaction (cl_id, booking_id, Points_Earned, Points_Redeemed, Txn_Date)
VALUES
(1, 1, 500.00, 0.00, '2025-01-10'),
(2, 2, 300.00, 100.00, '2025-01-15'),
(3, 3, 700.00, 0.00, '2025-02-01'),
(4, 4, 250.00, 50.00, '2025-02-10'),
(5, 5, 1000.00, 0.00, '2025-02-20'),
(6, 6, 450.00, 200.00, '2025-03-05'),
(7, 7, 800.00, 0.00, '2025-03-12'),
(8, 8, 600.00, 150.00, '2025-03-18'),
(9, 9, 900.00, 300.00, '2025-03-25'),
(10, 10, 1200.00, 0.00, '2025-03-30');

INSERT INTO Loyalty_Transaction (cl_id, booking_id, Points_Earned, Points_Redeemed, Txn_Date)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 190
)

-- SELECT
--     FLOOR(1 + RAND() * (SELECT MAX(cl_id) FROM Customer_Loyalty)) AS cl_id,
--     FLOOR(1 + RAND() * (SELECT MAX(booking_id) FROM Booking)) AS booking_id,
--     ROUND(100 + RAND() * 1500, 2) AS Points_Earned,  
--     ROUND(RAND() * 800, 2) AS Points_Redeemed,      
--     DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND() * 150) DAY) AS Txn_Date
-- FROM seq;

-- /* COUNT NUMBER OF ROWS */
-- SELECT 
--     SUM(table_rows) AS total_rows
-- FROM 
--     information_schema.tables
-- WHERE 
--     table_schema = 'Travel_And_Tourism';

/*functionalities*/
/*Suggest packages where destinations are popular among customers of similar nationality.*/

SELECT p.Name AS Recommended_Package, COUNT(b.booking_id) AS Popularity
FROM Booking b
JOIN Customer c ON b.customer_id = c.customer_id
JOIN Package p ON b.package_id = p.package_id
JOIN Package_Destination pd ON p.package_id = pd.package_id
JOIN Destination d ON pd.destination_id = d.destination_id
WHERE c.Nationality = 'India'
GROUP BY p.package_id
ORDER BY Popularity DESC;

/*Display all hotels and their available rooms for a given destination, filtered by availability and rating.*/

SELECT h.Name AS Hotel, r.Room_Type, r.PricePerNight
FROM Hotel h
JOIN Room r ON h.hotel_id = r.hotel_id
WHERE h.destination_id = 10 AND r.Availability_Status = TRUE;

/*Show all currently active offers and the discounted price of each package.*/

SELECT p.Name AS Package, o.title, 
       p.Price, 
       (p.Price - (p.Price * o.Discount_Percent / 100)) AS Discounted_Price
FROM Package_Offer po
JOIN Package p ON po.package_id = p.package_id
JOIN Offer o ON po.offer_id = o.offer_id
WHERE CURDATE() BETWEEN o.Start_Date AND o.End_Date;

/*When creating a booking, automatically calculate the total amount considering any active discount on that package.*/

SELECT p.Price - (p.Price * o.Discount_Percent / 100) AS Final_Amount
FROM Package p
LEFT JOIN Package_Offer po ON p.package_id = po.package_id
LEFT JOIN Offer o ON po.offer_id = o.offer_id
WHERE p.package_id = 3 AND CURDATE() BETWEEN o.Start_Date AND o.End_Date;

/*Count how many bookings were made per package to identify best-selling tours.*/

SELECT p.Name AS Package_Name, COUNT(b.booking_id) AS Total_Bookings
FROM Booking b
JOIN Package p ON b.package_id = p.package_id
GROUP BY p.Name
ORDER BY Total_Bookings DESC;

/*List all running offers that include a particular destination.*/

SELECT o.title AS Offer, p.Name AS Package, o.Discount_Percent
FROM Offer o
JOIN Package_Offer po ON o.offer_id = po.offer_id
JOIN Package p ON po.package_id = p.package_id
JOIN Package_Destination pd ON p.package_id = pd.package_id
JOIN Destination d ON pd.destination_id = d.destination_id
WHERE d.Name = 'Paris' AND CURDATE() BETWEEN o.Start_Date AND o.End_Date;

/*Measure average ticket resolution time to assess service quality.*/

SELECT AVG(TIMESTAMPDIFF(HOUR, created_at, resolved_at)) AS Avg_Hours_To_Resolve
FROM Support_Ticket
WHERE status = 'Resolved';

/*Calculate average customer ratings for destinations based on feedback.*/

SELECT d.Name AS Destination, ROUND(AVG(f.Rating), 1) AS Avg_Rating
FROM Feedback f
JOIN Package p ON f.package_id = p.package_id
JOIN Package_Destination pd ON p.package_id = pd.package_id
JOIN Destination d ON pd.destination_id = d.destination_id
GROUP BY d.destination_id
ORDER BY Avg_Rating DESC;

/*Detect overlapping schedules for the same transport vehicle.*/

SELECT s1.transport_id, s1.schedule_id, s2.schedule_id
FROM Schedule s1
JOIN Schedule s2 
  ON s1.transport_id = s2.transport_id 
 AND s1.schedule_id <> s2.schedule_id
WHERE s1.Departure_Time BETWEEN s2.Departure_Time AND s2.Arrival_Time;

/*Calculate the total commission each agent earned from completed bookings.*/

SELECT a.name AS Agent, 
       SUM(p.Amount * (a.Commission_rate / 100)) AS Commission_Earned
FROM Agent a
JOIN Package pkg ON a.agent_id = pkg.agent_id
JOIN Booking b ON pkg.package_id = b.package_id
JOIN Payment p ON b.booking_id = p.booking_id
WHERE b.status = 'Completed'
GROUP BY a.agent_id;
