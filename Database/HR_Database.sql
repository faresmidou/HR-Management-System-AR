-- =====================================================
-- نظام إدارة الموارد البشرية - قاعدة البيانات
-- HR Management System - Database Script
-- =====================================================

-- =====================================================
-- جدول المستخدمين (Users)
-- =====================================================
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    FullName VARCHAR(200) NOT NULL,
    Email VARCHAR(100),
    PhoneNumber VARCHAR(20),
    UserType VARCHAR(50) NOT NULL DEFAULT 'employee',
    Status VARCHAR(20) DEFAULT 'active',
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- جدول الأقسام (Departments)
-- =====================================================
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(150) NOT NULL UNIQUE,
    DepartmentCode VARCHAR(50) NOT NULL UNIQUE,
    Description TEXT,
    Status VARCHAR(20) DEFAULT 'active',
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- جدول الوحدات (Units)
-- =====================================================
CREATE TABLE Units (
    UnitID INT PRIMARY KEY AUTO_INCREMENT,
    UnitName VARCHAR(150) NOT NULL,
    UnitCode VARCHAR(50) NOT NULL UNIQUE,
    DepartmentID INT NOT NULL,
    Description TEXT,
    Status VARCHAR(20) DEFAULT 'active',
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- =====================================================
-- جدول الرتب الوظيفية (Positions)
-- =====================================================
CREATE TABLE Positions (
    PositionID INT PRIMARY KEY AUTO_INCREMENT,
    PositionName VARCHAR(150) NOT NULL UNIQUE,
    PositionLevel VARCHAR(50),
    Description TEXT,
    Status VARCHAR(20) DEFAULT 'active',
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- جدول الموظفين (Employees)
-- =====================================================
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeNumber VARCHAR(50) NOT NULL UNIQUE,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    DateOfBirth DATE,
    Gender VARCHAR(20),
    MaritalStatus VARCHAR(50),
    NationalID VARCHAR(50),
    RegistrationNumber VARCHAR(50),
    SocialSecurityNumber VARCHAR(50),
    Email VARCHAR(100),
    PhoneNumber VARCHAR(20),
    Address TEXT,
    
    -- بيانات العمل
    DepartmentID INT NOT NULL,
    UnitID INT,
    PositionID INT NOT NULL,
    JobTitle VARCHAR(150),
    HireDate DATE NOT NULL,
    Status VARCHAR(20) DEFAULT 'active',
    
    -- بيانات إضافية
    ProfileImage LONGBLOB,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (UnitID) REFERENCES Units(UnitID),
    FOREIGN KEY (PositionID) REFERENCES Positions(PositionID),
    INDEX idx_employee_number (EmployeeNumber),
    INDEX idx_national_id (NationalID),
    INDEX idx_department (DepartmentID),
    INDEX idx_status (Status)
);

-- =====================================================
-- جدول الحضور والغياب (Attendance)
-- =====================================================
CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    CheckInTime TIME,
    CheckOutTime TIME,
    Status VARCHAR(50) DEFAULT 'present',
    Notes TEXT,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    UNIQUE KEY unique_attendance (EmployeeID, AttendanceDate),
    INDEX idx_date (AttendanceDate)
);

-- =====================================================
-- جدول الإجازات (Leave)
-- =====================================================
CREATE TABLE Leave (
    LeaveID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT NOT NULL,
    LeaveType VARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    NumberOfDays INT,
    Reason TEXT,
    Status VARCHAR(50) DEFAULT 'pending',
    ApprovedBy INT,
    ApprovedDate DATETIME,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ApprovedBy) REFERENCES Users(UserID),
    INDEX idx_employee_id (EmployeeID),
    INDEX idx_status (Status)
);

-- =====================================================
-- جدول رصيد الإجازات (LeaveBalance)
-- =====================================================
CREATE TABLE LeaveBalance (
    LeaveBalanceID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT NOT NULL,
    Year INT NOT NULL,
    LeaveType VARCHAR(100) NOT NULL,
    TotalDays INT DEFAULT 0,
    UsedDays INT DEFAULT 0,
    RemainingDays INT DEFAULT 0,
    LastUpdated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    UNIQUE KEY unique_balance (EmployeeID, Year, LeaveType),
    INDEX idx_employee_year (EmployeeID, Year)
);

-- =====================================================
-- جدول سجل التدقيق (Audit Log)
-- =====================================================
CREATE TABLE AuditLog (
    AuditID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Action VARCHAR(200) NOT NULL,
    TableName VARCHAR(100),
    RecordID INT,
    OldValue TEXT,
    NewValue TEXT,
    ActionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    IPAddress VARCHAR(50),
    
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    INDEX idx_action_date (ActionDate),
    INDEX idx_user_id (UserID)
);

-- =====================================================
-- إدراج البيانات الافتراضية
-- =====================================================

-- إدراج المستخدم المشرف
INSERT INTO Users (Username, Password, FullName, Email, UserType, Status) VALUES
('admin', MD5('admin123'), 'مشرف النظام', 'admin@example.com', 'admin', 'active');

-- إدراج الأقسام
INSERT INTO Departments (DepartmentName, DepartmentCode, Description) VALUES
('الإدارة العليا', 'ADM', 'قسم الإدارة العليا'),
('الموارد البشرية', 'HR', 'قسم الموارد البشرية'),
('المالية', 'FIN', 'قسم المالية والحسابات'),
('المبيعات', 'SALES', 'قسم المبيعات'),
('التسويق', 'MKT', 'قسم التسويق'),
('تكنولوجيا المعلومات', 'IT', 'قسم تكنولوجيا المعلومات');

-- إدراج الوحدات
INSERT INTO Units (UnitName, UnitCode, DepartmentID, Description) VALUES
('الوحدة الأولى', 'U001', 1, 'الوحدة الإدارية الأولى'),
('الوحدة الثانية', 'U002', 1, 'الوحدة الإدارية الثانية'),
('فريق التوظيف', 'HR001', 2, 'فريق التوظيف والتطوير'),
('فريق الرواتب', 'HR002', 2, 'فريق الرواتب والمستحقات'),
('فريق المبيعات الأول', 'SALES001', 4, 'فريق المبيعات الأول'),
('فريق المبيعات الثاني', 'SALES002', 4, 'فريق المبيعات الثاني');

-- إدراج الرتب الوظيفية
INSERT INTO Positions (PositionName, PositionLevel, Description) VALUES
('مدير عام', 'Level1', 'المدير العام للشركة'),
('مدير قسم', 'Level2', 'مدير قسم'),
('رئيس فريق', 'Level3', 'رئيس فريق العمل'),
('موظف', 'Level4', 'موظف عادي'),
('متدرب', 'Level5', 'متدرب');

-- =====================================================
-- إنشاء طريقة عرض لبيانات الموظفين الكاملة
-- =====================================================
CREATE VIEW EmployeeFullInfo AS
SELECT 
    e.EmployeeID,
    e.EmployeeNumber,
    CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
    e.DateOfBirth,
    e.Gender,
    e.NationalID,
    e.RegistrationNumber,
    e.SocialSecurityNumber,
    d.DepartmentName,
    u.UnitName,
    p.PositionName,
    e.JobTitle,
    e.Email,
    e.PhoneNumber,
    e.Address,
    e.HireDate,
    e.Status,
    e.CreatedDate
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN Units u ON e.UnitID = u.UnitID
LEFT JOIN Positions p ON e.PositionID = p.PositionID;

-- =====================================================
-- إنشاء مفاتيح إضافية للأداء
-- =====================================================
CREATE INDEX idx_employee_status ON Employees(Status);
CREATE INDEX idx_employee_hire_date ON Employees(HireDate);
CREATE INDEX idx_attendance_employee ON Attendance(EmployeeID);
CREATE INDEX idx_leave_employee ON Leave(EmployeeID);
CREATE INDEX idx_audit_date ON AuditLog(ActionDate);

-- =====================================================
-- انتهى سكريبت قاعدة البيانات
-- =====================================================
