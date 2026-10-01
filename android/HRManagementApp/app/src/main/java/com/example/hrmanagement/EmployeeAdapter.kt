package com.example.hrmanagement

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class EmployeeAdapter(
    private val employees: MutableList<Employee>
) : RecyclerView.Adapter<EmployeeAdapter.EmployeeViewHolder>() {

    class EmployeeViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val nameText: TextView = itemView.findViewById(R.id.employeeName)
        val departmentText: TextView = itemView.findViewById(R.id.employeeDepartment)
        val jobText: TextView = itemView.findViewById(R.id.employeeJob)
        val statusText: TextView = itemView.findViewById(R.id.employeeStatus)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): EmployeeViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_employee, parent, false)
        return EmployeeViewHolder(view)
    }

    override fun onBindViewHolder(holder: EmployeeViewHolder, position: Int) {
        val employee = employees[position]
        holder.nameText.text = employee.fullName
        holder.departmentText.text = employee.department
        holder.jobText.text = employee.jobTitle
        holder.statusText.text = employee.status

        when (employee.status) {
            "نشط" -> holder.statusText.setTextColor(holder.itemView.context.getColor(android.R.color.holo_green_dark))
            "معطل" -> holder.statusText.setTextColor(holder.itemView.context.getColor(android.R.color.holo_orange_dark))
            else -> holder.statusText.setTextColor(holder.itemView.context.getColor(android.R.color.holo_blue_dark))
        }
    }

    override fun getItemCount(): Int = employees.size

    fun submitList(newEmployees: List<Employee>) {
        employees.clear()
        employees.addAll(newEmployees)
        notifyDataSetChanged()
    }
}
