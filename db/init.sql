CREATE SCHEMA IF NOT EXISTS "prod";
CREATE SCHEMA IF NOT EXISTS "pre-prod";

-- 1️⃣ יצירת טבלת סוגי משתמשים
CREATE TABLE User_Types (
    id SERIAL PRIMARY KEY,
    type_name VARCHAR(20) UNIQUE NOT NULL
);

INSERT INTO User_Types (type_name) VALUES
('family'),
('volunteer'),
('admin');

-- 2️⃣ יצירת טבלת ערים
CREATE TABLE Cities (
    id SERIAL PRIMARY KEY,
    city_name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO Cities (city_name) VALUES
('תל אביב'),
('ירושלים'),
('חיפה'),
('ראשון לציון'),
('פתח תקווה'),
('אשדוד'),
('נתניה'),
('באר שבע'),
('חולון'),
('בת ים');

-- 3️⃣ יצירת טבלת משתמשים
CREATE TABLE Users (
    id CHAR(9) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    address TEXT,
    city INT NOT NULL,
    user_type INT NOT NULL,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_type) REFERENCES User_Types(id) ON DELETE CASCADE,
    FOREIGN KEY (city) REFERENCES Cities(id) ON DELETE CASCADE
);

-- 4️⃣ יצירת טבלת אימות משתמשים
CREATE TABLE Authentication (
    user_id CHAR(9) PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- 5️⃣ יצירת טבלת משפחות
CREATE TABLE Families (
    user_id CHAR(9) PRIMARY KEY,
    building_type VARCHAR(50),
    floor_number INT,
    has_parking BOOLEAN DEFAULT FALSE,
    has_elevator BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- 6️⃣ יצירת טבלת סוגי בקשות (משימות אפשריות למתנדבים)
CREATE TABLE Request_Types (
    id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO Request_Types (type_name) VALUES
('shopping_help'),
('building_issue'),
('electricity_work'),
('water_leak'),
('gas_issue');

-- 7️⃣ יצירת טבלת מתנדבים (כולל מיומנויות ועיר מועדפת)
CREATE TABLE Volunteers (
    user_id CHAR(9) PRIMARY KEY,
    preferred_city INT NOT NULL,
    preferred_skill INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (preferred_city) REFERENCES Cities(id) ON DELETE CASCADE,
    FOREIGN KEY (preferred_skill) REFERENCES Request_Types(id) ON DELETE CASCADE
);

-- 8️⃣ יצירת טבלת סטטוסי בקשות
CREATE TABLE Request_Status (
    id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO Request_Status (status_name) VALUES
('מחפש מתנדב'),
('ממתין לאישור המשפחה'),
('בטיפול'),
('טופל');

-- 9️⃣ יצירת טבלת בקשות (כולל דחיפות הבקשה)
CREATE TABLE Requests (
    id CHAR(9) PRIMARY KEY,
    family_id CHAR(9) NOT NULL,
    request_type INT NOT NULL,
    description TEXT NULL,
    city INT NOT NULL,
    status INT DEFAULT 1,
    is_urgent BOOLEAN DEFAULT FALSE, -- בקשה דחופה או לא
    assigned_volunteer_id CHAR(9) NULL,
    expected_completion TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (family_id) REFERENCES Families(user_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_volunteer_id) REFERENCES Volunteers(user_id) ON DELETE SET NULL,
    FOREIGN KEY (request_type) REFERENCES Request_Types(id) ON DELETE CASCADE,
    FOREIGN KEY (status) REFERENCES Request_Status(id) ON DELETE CASCADE,
    FOREIGN KEY (city) REFERENCES Cities(id) ON DELETE CASCADE
);

-- 🔟 יצירת טבלת תהליך הטיפול בבקשה
CREATE TABLE Request_Process (
    id SERIAL PRIMARY KEY,
    request_id CHAR(9) NOT NULL,
    volunteer_id CHAR(9) NOT NULL,
    status INT DEFAULT 1,
    family_approval BOOLEAN DEFAULT FALSE,
    estimated_arrival TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (request_id) REFERENCES Requests(id) ON DELETE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES Volunteers(user_id) ON DELETE CASCADE,
    FOREIGN KEY (status) REFERENCES Request_Status(id) ON DELETE CASCADE
);

-- 1️⃣1️⃣ יצירת טבלת תהליך אישור משתמשים
CREATE TABLE User_Approval (
    id SERIAL PRIMARY KEY,
    user_id CHAR(9) NOT NULL,
    admin_id CHAR(9) NOT NULL,
    status INT DEFAULT 1,
    reason TEXT NULL,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (status) REFERENCES Request_Status(id) ON DELETE CASCADE
);