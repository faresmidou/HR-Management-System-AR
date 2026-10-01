package com.example.hrmanagement

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class EmployeeDbHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        const val DATABASE_NAME = "hr_management.db"
        const val DATABASE_VERSION = 1
        const val TABLE_EMPLOYEES = "employees"

        private const val COL_ID = "id"
        private const val COL_FIRST_NAME = "first_name"
        private const val COL_LAST_NAME = "last_name"
        private const val COL_REGISTRATION_NUMBER = "registration_number"
        private const val COL_NATIONAL_ID = "national_id"
        private const val COL_SOCIAL_SECURITY_NUMBER = "social_security_number"
        private const val COL_DEPARTMENT = "department"
        private const val COL_UNIT = "unit"
        private const val COL_JOB_TITLE = "job_title"
        private const val COL_RANK = "rank"
        private const val COL_HIRE_DATE = "hire_date"
        private const val COL_PHONE_NUMBER = "phone_number"
        private const val COL_EMAIL = "email"
        private const val COL_STATUS = "status"
        private const val COL_ADDRESS = "address"
    }

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            "CREATE TABLE $TABLE_EMPLOYEES (" +
                "$COL_ID INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "$COL_FIRST_NAME TEXT NOT NULL, " +
                "$COL_LAST_NAME TEXT NOT NULL, " +
                "$COL_REGISTRATION_NUMBER TEXT, " +
                "$COL_NATIONAL_ID TEXT, " +
                "$COL_SOCIAL_SECURITY_NUMBER TEXT, " +
                "$COL_DEPARTMENT TEXT, " +
                "$COL_UNIT TEXT, " +
                "$COL_JOB_TITLE TEXT, " +
                "$COL_RANK TEXT, " +
                "$COL_HIRE_DATE TEXT, " +
                "$COL_PHONE_NUMBER TEXT, " +
                "$COL_EMAIL TEXT, " +
                "$COL_STATUS TEXT DEFAULT 'نشط', " +
                "$COL_ADDRESS TEXT)"
        )

        seedSampleEmployees(db)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_EMPLOYEES")
        onCreate(db)
    }

    fun insertEmployee(employee: Employee): Long {
        val values = ContentValues().apply {
            put(COL_FIRST_NAME, employee.firstName)
            put(COL_LAST_NAME, employee.lastName)
            put(COL_REGISTRATION_NUMBER, employee.registrationNumber)
            put(COL_NATIONAL_ID, employee.nationalId)
            put(COL_SOCIAL_SECURITY_NUMBER, employee.socialSecurityNumber)
            put(COL_DEPARTMENT, employee.department)
            put(COL_UNIT, employee.unit)
            put(COL_JOB_TITLE, employee.jobTitle)
            put(COL_RANK, employee.rank)
            put(COL_HIRE_DATE, employee.hireDate)
            put(COL_PHONE_NUMBER, employee.phoneNumber)
            put(COL_EMAIL, employee.email)
            put(COL_STATUS, employee.status)
            put(COL_ADDRESS, employee.address)
        }

        return writableDatabase.insert(TABLE_EMPLOYEES, null, values)
    }

    fun getEmployees(searchQuery: String = ""): MutableList<Employee> {
        val employees = mutableListOf<Employee>()
        val db = readableDatabase
        val query = if (searchQuery.isBlank()) {
            "SELECT * FROM $TABLE_EMPLOYEES ORDER BY $COL_ID DESC"
        } else {
            "SELECT * FROM $TABLE_EMPLOYEES WHERE lower($COL_FIRST_NAME) LIKE ? OR lower($COL_LAST_NAME) LIKE ? OR lower($COL_DEPARTMENT) LIKE ? OR lower($COL_JOB_TITLE) LIKE ? ORDER BY $COL_ID DESC"
        }

        val cursor = if (searchQuery.isBlank()) {
            db.rawQuery(query, null)
        } else {
            val q = "%${searchQuery.lowercase()}%"
            db.rawQuery(query, arrayOf(q, q, q, q))
        }

        while (cursor.moveToNext()) {
            employees.add(
                Employee(
                    id = cursor.getLong(cursor.getColumnIndexOrThrow(COL_ID)),
                    firstName = cursor.getString(cursor.getColumnIndexOrThrow(COL_FIRST_NAME)),
                    lastName = cursor.getString(cursor.getColumnIndexOrThrow(COL_LAST_NAME)),
                    registrationNumber = cursor.getString(cursor.getColumnIndexOrThrow(COL_REGISTRATION_NUMBER)),
                    nationalId = cursor.getString(cursor.getColumnIndexOrThrow(COL_NATIONAL_ID)),
                    socialSecurityNumber = cursor.getString(cursor.getColumnIndexOrThrow(COL_SOCIAL_SECURITY_NUMBER)),
                    department = cursor.getString(cursor.getColumnIndexOrThrow(COL_DEPARTMENT)),
                    unit = cursor.getString(cursor.getColumnIndexOrThrow(COL_UNIT)),
                    jobTitle = cursor.getString(cursor.getColumnIndexOrThrow(COL_JOB_TITLE)),
                    rank = cursor.getString(cursor.getColumnIndexOrThrow(COL_RANK)),
                    hireDate = cursor.getString(cursor.getColumnIndexOrThrow(COL_HIRE_DATE)),
                    phoneNumber = cursor.getString(cursor.getColumnIndexOrThrow(COL_PHONE_NUMBER)),
                    email = cursor.getString(cursor.getColumnIndexOrThrow(COL_EMAIL)),
                    status = cursor.getString(cursor.getColumnIndexOrThrow(COL_STATUS)),
                    address = cursor.getString(cursor.getColumnIndexOrThrow(COL_ADDRESS))
                )
            )
        }

        cursor.close()
        return employees
    }

    fun getEmployeeCount(): Int = readableDatabase.rawQuery("SELECT COUNT(*) FROM $TABLE_EMPLOYEES", null).use { it.moveToFirst(); it.getInt(0) }

    private fun seedSampleEmployees(db: SQLiteDatabase) {
        val sampleEmployees = listOf(
            Employee(
                firstName = "عبدالله",
                lastName = "الحميدي",
                registrationNumber = "REG-001",
                nationalId = "1234567890",
                socialSecurityNumber = "SSN-001",
                department = "الإدارة",
                unit = "الوحدة الأولى",
                jobTitle = "مدير عام",
                rank = "مدير",
                hireDate = "2024-01-15",
                phoneNumber = "966500000001",
                email = "abdullah@example.com",
                status = "نشط",
                address = "الرياض"
            ),
            Employee(
                firstName = "سارة",
                lastName = "الحربي",
                registrationNumber = "REG-002",
                nationalId = "1234567891",
                socialSecurityNumber = "SSN-002",
                department = "الموارد البشرية",
                unit = "فريق التوظيف",
                jobTitle = "مدير قسم",
                rank = "مدير قسم",
                hireDate = "2024-02-10",
                phoneNumber = "966500000002",
                email = "sara@example.com",
                status = "نشط",
                address = "جدة"
            ),
            Employee(
                firstName = "خالد",
                lastName = "النجار",
                registrationNumber = "REG-003",
                nationalId = "1234567892",
                socialSecurityNumber = "SSN-003",
                department = "المالية",
                unit = "فريق الرواتب",
                jobTitle = "موظف",
                rank = "موظف",
                hireDate = "2024-03-20",
                phoneNumber = "966500000003",
                email = "khalid@example.com",
                status = "نشط",
                address = "الدمام"
            )
        )

        sampleEmployees.forEach { insertEmployee(db, it) }
    }

    private fun insertEmployee(db: SQLiteDatabase, employee: Employee) {
        val values = ContentValues().apply {
            put(COL_FIRST_NAME, employee.firstName)
            put(COL_LAST_NAME, employee.lastName)
            put(COL_REGISTRATION_NUMBER, employee.registrationNumber)
            put(COL_NATIONAL_ID, employee.nationalId)
            put(COL_SOCIAL_SECURITY_NUMBER, employee.socialSecurityNumber)
            put(COL_DEPARTMENT, employee.department)
            put(COL_UNIT, employee.unit)
            put(COL_JOB_TITLE, employee.jobTitle)
            put(COL_RANK, employee.rank)
            put(COL_HIRE_DATE, employee.hireDate)
            put(COL_PHONE_NUMBER, employee.phoneNumber)
            put(COL_EMAIL, employee.email)
            put(COL_STATUS, employee.status)
            put(COL_ADDRESS, employee.address)
        }
        db.insert(TABLE_EMPLOYEES, null, values)
    }
}
