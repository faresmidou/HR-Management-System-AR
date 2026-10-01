package com.example.hrmanagement

import android.app.AlertDialog
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.floatingactionbutton.FloatingActionButton

class MainActivity : AppCompatActivity() {

    private lateinit var dbHelper: EmployeeDbHelper
    private lateinit var adapter: EmployeeAdapter
    private lateinit var recyclerView: RecyclerView
    private lateinit var searchField: EditText
    private lateinit var totalEmployees: TextView
    private lateinit var activeEmployees: TextView
    private lateinit var inactiveEmployees: TextView
    private lateinit var leaveEmployees: TextView
    private lateinit var addButton: FloatingActionButton

    private val employees = mutableListOf<Employee>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        dbHelper = EmployeeDbHelper(this)

        recyclerView = findViewById(R.id.employeeRecyclerView)
        searchField = findViewById(R.id.searchField)
        totalEmployees = findViewById(R.id.totalEmployees)
        activeEmployees = findViewById(R.id.activeEmployees)
        inactiveEmployees = findViewById(R.id.inactiveEmployees)
        leaveEmployees = findViewById(R.id.leaveEmployees)
        addButton = findViewById(R.id.addEmployeeButton)

        adapter = EmployeeAdapter(employees)
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = adapter

        searchField.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                loadEmployees(s.toString())
            }
            override fun afterTextChanged(s: Editable?) = Unit
        })

        addButton.setOnClickListener {
            showAddEmployeeDialog()
        }

        loadEmployees()
    }

    private fun loadEmployees(searchQuery: String = "") {
        val result = dbHelper.getEmployees(searchQuery)
        employees.clear()
        employees.addAll(result)
        adapter.submitList(result)
        updateStats(result)
    }

    private fun updateStats(list: List<Employee>) {
        totalEmployees.text = list.size.toString()
        activeEmployees.text = list.count { it.status == "نشط" }.toString()
        inactiveEmployees.text = list.count { it.status == "معطل" }.toString()
        leaveEmployees.text = list.count { it.status == "مجازي" }.toString()
    }

    private fun showAddEmployeeDialog() {
        val dialogView = layoutInflater.inflate(R.layout.dialog_add_employee, null)

        val firstName = dialogView.findViewById<EditText>(R.id.firstNameInput)
        val lastName = dialogView.findViewById<EditText>(R.id.lastNameInput)
        val registrationNumber = dialogView.findViewById<EditText>(R.id.registrationInput)
        val nationalId = dialogView.findViewById<EditText>(R.id.nationalIdInput)
        val socialSecurityNumber = dialogView.findViewById<EditText>(R.id.socialSecurityInput)
        val department = dialogView.findViewById<EditText>(R.id.departmentInput)
        val unit = dialogView.findViewById<EditText>(R.id.unitInput)
        val jobTitle = dialogView.findViewById<EditText>(R.id.jobTitleInput)
        val rank = dialogView.findViewById<EditText>(R.id.rankInput)
        val hireDate = dialogView.findViewById<EditText>(R.id.hireDateInput)
        val phoneNumber = dialogView.findViewById<EditText>(R.id.phoneInput)
        val email = dialogView.findViewById<EditText>(R.id.emailInput)
        val status = dialogView.findViewById<EditText>(R.id.statusInput)
        val address = dialogView.findViewById<EditText>(R.id.addressInput)

        AlertDialog.Builder(this)
            .setTitle("إضافة موظف جديد")
            .setView(dialogView)
            .setPositiveButton("حفظ") { _, _ ->
                val employee = Employee(
                    firstName = firstName.text.toString().trim(),
                    lastName = lastName.text.toString().trim(),
                    registrationNumber = registrationNumber.text.toString().trim(),
                    nationalId = nationalId.text.toString().trim(),
                    socialSecurityNumber = socialSecurityNumber.text.toString().trim(),
                    department = department.text.toString().trim(),
                    unit = unit.text.toString().trim(),
                    jobTitle = jobTitle.text.toString().trim(),
                    rank = rank.text.toString().trim(),
                    hireDate = hireDate.text.toString().trim(),
                    phoneNumber = phoneNumber.text.toString().trim(),
                    email = email.text.toString().trim(),
                    status = if (status.text.toString().trim().isEmpty()) "نشط" else status.text.toString().trim(),
                    address = address.text.toString().trim()
                )

                if (employee.firstName.isEmpty() || employee.lastName.isEmpty()) {
                    android.widget.Toast.makeText(this, "الاسم الأول واللقب مطلوبان", android.widget.Toast.LENGTH_SHORT).show()
                    return@setPositiveButton
                }

                dbHelper.insertEmployee(employee)
                loadEmployees(searchField.text.toString())
            }
            .setNegativeButton("إلغاء", null)
            .show()
    }
}
