package com.example.hrmanagement

data class Employee(
    val id: Long = 0,
    val firstName: String,
    val lastName: String,
    val registrationNumber: String,
    val nationalId: String,
    val socialSecurityNumber: String,
    val department: String,
    val unit: String,
    val jobTitle: String,
    val rank: String,
    val hireDate: String,
    val phoneNumber: String,
    val email: String,
    val status: String,
    val address: String
) {
    val fullName: String
        get() = "$firstName $lastName"
}
