#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
نظام إدارة الموارد البشرية - HR Management System
برنامج Windows احترافي لإدارة الموظفين
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import sqlite3
import os
from datetime import datetime
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side

class EmployeeDB:
    def __init__(self):
        self.conn = sqlite3.connect('hr_management.db')
        self.cursor = self.conn.cursor()
        self.create_table()
        self.seed_data()

    def create_table(self):
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS employees (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                first_name TEXT NOT NULL,
                last_name TEXT NOT NULL,
                registration_number TEXT,
                national_id TEXT,
                social_security_number TEXT,
                department TEXT,
                unit TEXT,
                job_title TEXT,
                rank TEXT,
                hire_date TEXT,
                phone_number TEXT,
                email TEXT,
                status TEXT DEFAULT 'نشط',
                address TEXT
            )
        ''')
        self.conn.commit()

    def seed_data(self):
        self.cursor.execute('SELECT COUNT(*) FROM employees')
        if self.cursor.fetchone()[0] == 0:
            employees = [
                ('عبدالله', 'الحميدي', 'REG-001', '1234567890', 'SSN-001', 'الإدارة', 'الوحدة الأولى', 'مدير عام', 'مدير', '2024-01-15', '966500000001', 'abdullah@example.com', 'نشط', 'الرياض'),
                ('سارة', 'الحربي', 'REG-002', '1234567891', 'SSN-002', 'الموارد البشرية', 'فريق التوظيف', 'مدير قسم', 'مدير قسم', '2024-02-10', '966500000002', 'sara@example.com', 'نشط', 'جدة'),
                ('خالد', 'النجار', 'REG-003', '1234567892', 'SSN-003', 'المالية', 'فريق الرواتب', 'موظف', 'موظف', '2024-03-20', '966500000003', 'khalid@example.com', 'نشط', 'الدمام'),
                ('فاطمة', 'الشمري', 'REG-004', '1234567893', 'SSN-004', 'المبيعات', 'فريق المبيعات الأول', 'رئيس فريق', 'رئيس فريق', '2024-04-05', '966500000004', 'fatima@example.com', 'نشط', 'المدينة المنورة'),
                ('يوسف', 'السلطي', 'REG-005', '1234567894', 'SSN-005', 'التسويق', 'الوحدة الثانية', 'موظف', 'موظف', '2024-05-18', '966500000005', 'yousef@example.com', 'مجازي', 'الخبر'),
            ]
            for emp in employees:
                self.cursor.execute('''
                    INSERT INTO employees 
                    (first_name, last_name, registration_number, national_id, social_security_number, 
                     department, unit, job_title, rank, hire_date, phone_number, email, status, address)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', emp)
            self.conn.commit()

    def add_employee(self, emp_data):
        self.cursor.execute('''
            INSERT INTO employees 
            (first_name, last_name, registration_number, national_id, social_security_number, 
             department, unit, job_title, rank, hire_date, phone_number, email, status, address)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', emp_data)
        self.conn.commit()

    def get_all_employees(self, search=''):
        if search:
            query = '''
                SELECT * FROM employees 
                WHERE first_name LIKE ? OR last_name LIKE ? OR department LIKE ? OR job_title LIKE ?
                ORDER BY id DESC
            '''
            pattern = f'%{search}%'
            self.cursor.execute(query, (pattern, pattern, pattern, pattern))
        else:
            self.cursor.execute('SELECT * FROM employees ORDER BY id DESC')
        return self.cursor.fetchall()

    def delete_employee(self, emp_id):
        self.cursor.execute('DELETE FROM employees WHERE id = ?', (emp_id,))
        self.conn.commit()

    def get_stats(self):
        self.cursor.execute('SELECT COUNT(*) FROM employees')
        total = self.cursor.fetchone()[0]
        self.cursor.execute("SELECT COUNT(*) FROM employees WHERE status = 'نشط'")
        active = self.cursor.fetchone()[0]
        self.cursor.execute("SELECT COUNT(*) FROM employees WHERE status = 'معطل'")
        inactive = self.cursor.fetchone()[0]
        self.cursor.execute("SELECT COUNT(*) FROM employees WHERE status = 'مجازي'")
        leave = self.cursor.fetchone()[0]
        return total, active, inactive, leave

class HRApp:
    def __init__(self, root):
        self.root = root
        self.root.title('نظام إدارة الموارد البشرية')
        self.root.geometry('1000x600')
        self.root.configure(bg='#F5F7FB')
        
        self.db = EmployeeDB()
        
        # Set RTL
        self.root.tk.call('tk', 'scaling', 2.0)
        
        self.setup_ui()
        self.load_employees()

    def setup_ui(self):
        # Header
        header = tk.Frame(self.root, bg='#2563EB', height=60)
        header.pack(fill=tk.X)
        
        title = tk.Label(header, text='نظام إدارة الموارد البشرية', font=('Arial', 18, 'bold'), 
                         bg='#2563EB', fg='white')
        title.pack(pady=10)

        # Control Panel
        control = tk.Frame(self.root, bg='#FFFFFF')
        control.pack(fill=tk.X, padx=10, pady=10)

        # Search
        tk.Label(control, text='بحث:', bg='#FFFFFF', font=('Arial', 10)).pack(side=tk.LEFT, padx=5)
        self.search_var = tk.StringVar()
        self.search_var.trace('w', lambda *args: self.load_employees())
        search_entry = tk.Entry(control, textvariable=self.search_var, font=('Arial', 10), width=30)
        search_entry.pack(side=tk.LEFT, padx=5)

        # Buttons
        add_btn = tk.Button(control, text='إضافة موظف', bg='#16A34A', fg='white', 
                            font=('Arial', 10), command=self.add_employee_dialog)
        add_btn.pack(side=tk.LEFT, padx=5)

        delete_btn = tk.Button(control, text='حذف الموظف', bg='#DC2626', fg='white',
                               font=('Arial', 10), command=self.delete_employee)
        delete_btn.pack(side=tk.LEFT, padx=5)

        export_btn = tk.Button(control, text='تصدير Excel', bg='#0891B2', fg='white',
                               font=('Arial', 10), command=self.export_to_excel)
        export_btn.pack(side=tk.LEFT, padx=5)

        # Stats
        stats_frame = tk.Frame(self.root, bg='#FFFFFF')
        stats_frame.pack(fill=tk.X, padx=10, pady=5)

        self.total_label = tk.Label(stats_frame, text='الإجمالي: 0', font=('Arial', 10, 'bold'), bg='#E0E7FF', fg='#1D4ED8', width=15)
        self.total_label.pack(side=tk.LEFT, padx=5, pady=5)

        self.active_label = tk.Label(stats_frame, text='نشط: 0', font=('Arial', 10, 'bold'), bg='#DCFCE7', fg='#16A34A', width=15)
        self.active_label.pack(side=tk.LEFT, padx=5, pady=5)

        self.inactive_label = tk.Label(stats_frame, text='معطل: 0', font=('Arial', 10, 'bold'), bg='#FEF3C7', fg='#F59E0B', width=15)
        self.inactive_label.pack(side=tk.LEFT, padx=5, pady=5)

        self.leave_label = tk.Label(stats_frame, text='مجازي: 0', font=('Arial', 10, 'bold'), bg='#DBEAFE', fg='#2563EB', width=15)
        self.leave_label.pack(side=tk.LEFT, padx=5, pady=5)

        # Table
        table_frame = tk.Frame(self.root)
        table_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # Scrollbar
        scrollbar = ttk.Scrollbar(table_frame)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        # Treeview
        self.tree = ttk.Treeview(table_frame, columns=('ID', 'الاسم', 'القسم', 'الوظيفة', 'الحالة', 'الهاتف', 'البريد'), 
                                  height=15, yscrollcommand=scrollbar.set)
        self.tree.column('#0', width=0, stretch=tk.NO)
        self.tree.column('ID', anchor=tk.CENTER, width=50)
        self.tree.column('الاسم', anchor=tk.CENTER, width=150)
        self.tree.column('القسم', anchor=tk.CENTER, width=120)
        self.tree.column('الوظيفة', anchor=tk.CENTER, width=120)
        self.tree.column('الحالة', anchor=tk.CENTER, width=80)
        self.tree.column('الهاتف', anchor=tk.CENTER, width=100)
        self.tree.column('البريد', anchor=tk.CENTER, width=180)

        self.tree.heading('#0', text='', anchor=tk.W)
        self.tree.heading('ID', text='ID', anchor=tk.CENTER)
        self.tree.heading('الاسم', text='الاسم', anchor=tk.CENTER)
        self.tree.heading('القسم', text='القسم', anchor=tk.CENTER)
        self.tree.heading('الوظيفة', text='الوظيفة', anchor=tk.CENTER)
        self.tree.heading('الحالة', text='الحالة', anchor=tk.CENTER)
        self.tree.heading('الهاتف', text='الهاتف', anchor=tk.CENTER)
        self.tree.heading('البريد', text='البريد', anchor=tk.CENTER)

        self.tree.pack(fill=tk.BOTH, expand=True)
        scrollbar.config(command=self.tree.yview)

    def load_employees(self):
        search_term = self.search_var.get() if hasattr(self, 'search_var') else ''
        employees = self.db.get_all_employees(search_term)
        
        # Clear tree
        for item in self.tree.get_children():
            self.tree.delete(item)

        # Add employees
        for emp in employees:
            full_name = f"{emp[1]} {emp[2]}"
            self.tree.insert('', 0, values=(emp[0], full_name, emp[6], emp[8], emp[13], emp[11], emp[12]))

        # Update stats
        total, active, inactive, leave = self.db.get_stats()
        self.total_label.config(text=f'الإجمالي: {total}')
        self.active_label.config(text=f'نشط: {active}')
        self.inactive_label.config(text=f'معطل: {inactive}')
        self.leave_label.config(text=f'مجازي: {leave}')

    def add_employee_dialog(self):
        dialog = tk.Toplevel(self.root)
        dialog.title('إضافة موظف جديد')
        dialog.geometry('400x500')
        
        fields = [
            ('الاسم الأول', 'first_name'),
            ('اللقب', 'last_name'),
            ('رقم التسجيل', 'registration_number'),
            ('الرقم الوطني', 'national_id'),
            ('رقم الضمان الاجتماعي', 'social_security_number'),
            ('القسم', 'department'),
            ('الوحدة', 'unit'),
            ('المسمى الوظيفي', 'job_title'),
            ('الرتبة', 'rank'),
            ('تاريخ الالتحاق', 'hire_date'),
            ('الهاتف', 'phone_number'),
            ('البريد', 'email'),
            ('الحالة', 'status'),
            ('العنوان', 'address')
        ]
        
        entries = {}
        for label, key in fields:
            tk.Label(dialog, text=label, font=('Arial', 10)).pack()
            entry = tk.Entry(dialog, font=('Arial', 10), width=40)
            entry.pack(padx=10, pady=5)
            entries[key] = entry

        def save():
            data = tuple([entries[key].get() for label, key in fields])
            if not data[0] or not data[1]:
                messagebox.showerror('خطأ', 'الاسم الأول واللقب مطلوبان')
                return
            self.db.add_employee(data)
            self.load_employees()
            dialog.destroy()
            messagebox.showinfo('نجاح', 'تم إضافة الموظف بنجاح')

        tk.Button(dialog, text='حفظ', bg='#16A34A', fg='white', font=('Arial', 10), command=save).pack(pady=10)

    def delete_employee(self):
        selected = self.tree.selection()
        if not selected:
            messagebox.showerror('خطأ', 'اختر موظف للحذف')
            return
        
        if messagebox.askyesno('تأكيد', 'هل أنت متأكد من حذف الموظف؟'):
            emp_id = self.tree.item(selected[0])['values'][0]
            self.db.delete_employee(emp_id)
            self.load_employees()
            messagebox.showinfo('نجاح', 'تم حذف الموظف بنجاح')

    def export_to_excel(self):
        file_path = filedialog.asksaveasfilename(defaultextension='.xlsx', filetypes=[('Excel files', '*.xlsx')])
        if not file_path:
            return

        wb = Workbook()
        ws = wb.active
        ws.title = 'الموظفين'

        # Headers
        headers = ['ID', 'الاسم الأول', 'اللقب', 'رقم التسجيل', 'الرقم الوطني', 'رقم الضمان الاجتماعي',
                   'القسم', 'الوحدة', 'المسمى الوظيفي', 'الرتبة', 'تاريخ الالتحاق', 'الهاتف', 'البريد', 'الحالة', 'العنوان']
        
        header_fill = PatternFill(start_color='2563EB', end_color='2563EB', fill_type='solid')
        header_font = Font(bold=True, color='FFFFFF')
        
        for col, header in enumerate(headers, 1):
            cell = ws.cell(row=1, column=col)
            cell.value = header
            cell.fill = header_fill
            cell.font = header_font
            cell.alignment = Alignment(horizontal='center', vertical='center')

        # Data
        employees = self.db.get_all_employees()
        for row, emp in enumerate(employees, 2):
            for col, value in enumerate(emp, 1):
                cell = ws.cell(row=row, column=col)
                cell.value = value
                cell.alignment = Alignment(horizontal='center', vertical='center')

        wb.save(file_path)
        messagebox.showinfo('نجاح', f'تم التصدير إلى {file_path}')

if __name__ == '__main__':
    root = tk.Tk()
    app = HRApp(root)
    root.mainloop()
