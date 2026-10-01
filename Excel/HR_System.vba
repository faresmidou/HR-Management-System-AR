' =====================================================
' نظام إدارة الموارد البشرية - VBA/VBScript
' HR Management System - Excel Macro
' =====================================================

' =====================================================
' Sub: إضافة موظف جديد
' =====================================================
Sub AddEmployee()
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim employeeID As String
    Dim firstName As String
    Dim lastName As String
    Dim registrationNumber As String
    Dim nationalID As String
    Dim socialSecurityNumber As String
    Dim department As String
    Dim unit As String
    Dim jobTitle As String
    Dim rank As String
    Dim hireDate As String
    Dim phoneNumber As String
    Dim email As String
    Dim status As String
    Dim address As String
    
    Set ws = ThisWorkbook.Sheets("Employees")
    
    ' الحصول على آخر صف
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row + 1
    
    ' إدخال البيانات من نموذج الإدخال
    employeeID = ws.Range("AddForm_EmployeeID").Value
    firstName = ws.Range("AddForm_FirstName").Value
    lastName = ws.Range("AddForm_LastName").Value
    registrationNumber = ws.Range("AddForm_RegistrationNumber").Value
    nationalID = ws.Range("AddForm_NationalID").Value
    socialSecurityNumber = ws.Range("AddForm_SocialSecurityNumber").Value
    department = ws.Range("AddForm_Department").Value
    unit = ws.Range("AddForm_Unit").Value
    jobTitle = ws.Range("AddForm_JobTitle").Value
    rank = ws.Range("AddForm_Rank").Value
    hireDate = ws.Range("AddForm_HireDate").Value
    phoneNumber = ws.Range("AddForm_PhoneNumber").Value
    email = ws.Range("AddForm_Email").Value
    status = ws.Range("AddForm_Status").Value
    address = ws.Range("AddForm_Address").Value
    
    ' التحقق من ملء جميع الحقول المطلوبة
    If employeeID = "" Or firstName = "" Or lastName = "" Then
        MsgBox "الرجاء ملء جميع الحقول المطلوبة!", vbExclamation, "خطأ في الإدخال"
        Exit Sub
    End If
    
    ' إدراج البيانات في الجدول
    With ws
        .Cells(lastRow, 1).Value = employeeID
        .Cells(lastRow, 2).Value = firstName
        .Cells(lastRow, 3).Value = lastName
        .Cells(lastRow, 4).Value = registrationNumber
        .Cells(lastRow, 5).Value = nationalID
        .Cells(lastRow, 6).Value = socialSecurityNumber
        .Cells(lastRow, 7).Value = department
        .Cells(lastRow, 8).Value = unit
        .Cells(lastRow, 9).Value = jobTitle
        .Cells(lastRow, 10).Value = rank
        .Cells(lastRow, 11).Value = hireDate
        .Cells(lastRow, 12).Value = phoneNumber
        .Cells(lastRow, 13).Value = email
        .Cells(lastRow, 14).Value = status
        .Cells(lastRow, 15).Value = address
    End With
    
    ' تسجيل العملية في سجل التدقيق
    LogAction "إضافة موظف: " & employeeID & " - " & firstName & " " & lastName
    
    ' مسح النموذج
    ClearAddForm
    
    MsgBox "تم إضافة الموظف بنجاح!", vbInformation, "نجاح"
    
    ' تحديث الإحصائيات
    UpdateDashboard
End Sub

' =====================================================
' Sub: حذف موظف
' =====================================================
Sub DeleteEmployee()
    Dim ws As Worksheet
    Dim selectedRow As Long
    Dim employeeID As String
    
    Set ws = ThisWorkbook.Sheets("Employees")
    selectedRow = ActiveCell.Row
    
    ' التأكد من اختيار صف من البيانات
    If selectedRow < 2 Then
        MsgBox "الرجاء اختيار موظف!", vbExclamation, "خطأ"
        Exit Sub
    End If
    
    employeeID = ws.Cells(selectedRow, 1).Value
    
    ' التأكيد على الحذف
    If MsgBox("هل أنت متأكد من حذف الموظف " & employeeID & "؟", vbYesNo, "تأكيد الحذف") = vbYes Then
        ws.Rows(selectedRow).Delete
        LogAction "حذف موظف: " & employeeID
        MsgBox "تم حذف الموظف بنجاح!", vbInformation, "نجاح"
        UpdateDashboard
    End If
End Sub

' =====================================================
' Sub: البحث عن موظف
' =====================================================
Sub SearchEmployee()
    Dim ws As Worksheet
    Dim searchTerm As String
    Dim lastRow As Long
    Dim i As Long
    Dim found As Boolean
    
    Set ws = ThisWorkbook.Sheets("Employees")
    searchTerm = ws.Range("SearchBox").Value
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    found = False
    
    If searchTerm = "" Then
        MsgBox "الرجاء إدخال بيانات للبحث!", vbExclamation, "بحث فارغ"
        Exit Sub
    End If
    
    ' البحث في جميع الأعمدة
    For i = 2 To lastRow
        If InStr(ws.Cells(i, 1).Value, searchTerm) > 0 Or _
           InStr(ws.Cells(i, 2).Value, searchTerm) > 0 Or _
           InStr(ws.Cells(i, 3).Value, searchTerm) > 0 Then
            ws.Cells(i, 1).Interior.Color = RGB(255, 255, 0)
            found = True
        End If
    Next i
    
    If found Then
        MsgBox "تم العثور على النتائج!", vbInformation, "بحث"
    Else
        MsgBox "لم يتم العثور على نتائج!", vbInformation, "بحث"
    End If
End Sub

' =====================================================
' Sub: مسح الفلتر
' =====================================================
Sub ClearSearch()
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    
    Set ws = ThisWorkbook.Sheets("Employees")
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' مسح التلوين
    For i = 2 To lastRow
        ws.Cells(i, 1).Interior.ColorIndex = xlNone
    Next i
    
    ws.Range("SearchBox").Value = ""
    MsgBox "تم مسح البحث!", vbInformation, "مسح"
End Sub

' =====================================================
' Sub: تحديث لوحة التحكم
' =====================================================
Sub UpdateDashboard()
    Dim wsDash As Worksheet
    Dim wsEmp As Worksheet
    Dim lastRow As Long
    Dim totalEmp As Long
    Dim activeEmp As Long
    Dim inactiveEmp As Long
    Dim onLeaveEmp As Long
    
    Set wsDash = ThisWorkbook.Sheets("Dashboard")
    Set wsEmp = ThisWorkbook.Sheets("Employees")
    
    lastRow = wsEmp.Cells(wsEmp.Rows.Count, "A").End(xlUp).Row
    
    ' حساب الإحصائيات
    totalEmp = lastRow - 1
    activeEmp = Application.WorksheetFunction.CountIf(wsEmp.Range("N:N"), "نشط")
    inactiveEmp = Application.WorksheetFunction.CountIf(wsEmp.Range("N:N"), "معطل")
    onLeaveEmp = Application.WorksheetFunction.CountIf(wsEmp.Range("N:N"), "مجازي")
    
    ' تحديث الأرقام في Dashboard
    wsDash.Range("DashTotalEmployees").Value = totalEmp
    wsDash.Range("DashActiveEmployees").Value = activeEmp
    wsDash.Range("DashInactiveEmployees").Value = inactiveEmp
    wsDash.Range("DashOnLeaveEmployees").Value = onLeaveEmp
End Sub

' =====================================================
' Sub: مسح نموذج الإدخال
' =====================================================
Sub ClearAddForm()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Employees")
    
    ws.Range("AddForm_EmployeeID").Value = ""
    ws.Range("AddForm_FirstName").Value = ""
    ws.Range("AddForm_LastName").Value = ""
    ws.Range("AddForm_RegistrationNumber").Value = ""
    ws.Range("AddForm_NationalID").Value = ""
    ws.Range("AddForm_SocialSecurityNumber").Value = ""
    ws.Range("AddForm_Department").Value = ""
    ws.Range("AddForm_Unit").Value = ""
    ws.Range("AddForm_JobTitle").Value = ""
    ws.Range("AddForm_Rank").Value = ""
    ws.Range("AddForm_HireDate").Value = ""
    ws.Range("AddForm_PhoneNumber").Value = ""
    ws.Range("AddForm_Email").Value = ""
    ws.Range("AddForm_Status").Value = ""
    ws.Range("AddForm_Address").Value = ""
End Sub

' =====================================================
' Sub: تسجيل العمليات في سجل التدقيق
' =====================================================
Sub LogAction(action As String)
    Dim wsLog As Worksheet
    Dim lastRow As Long
    Dim logTime As String
    
    On Error Resume Next
    Set wsLog = ThisWorkbook.Sheets("AuditLog")
    On Error GoTo 0
    
    If wsLog Is Nothing Then
        ' إنشاء ورقة جديدة إذا لم تكن موجودة
        Set wsLog = ThisWorkbook.Sheets.Add
        wsLog.Name = "AuditLog"
        wsLog.Range("A1").Value = "التاريخ والوقت"
        wsLog.Range("B1").Value = "العملية"
    End If
    
    lastRow = wsLog.Cells(wsLog.Rows.Count, "A").End(xlUp).Row + 1
    logTime = Format(Now(), "yyyy-mm-dd hh:mm:ss")
    
    With wsLog
        .Cells(lastRow, 1).Value = logTime
        .Cells(lastRow, 2).Value = action
    End With
End Sub

' =====================================================
' Sub: طباعة التقرير
' =====================================================
Sub PrintReport()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Reports")
    
    ws.PrintPreview
End Sub

' =====================================================
' Sub: تصدير إلى PDF
' =====================================================
Sub ExportToPDF()
    Dim ws As Worksheet
    Dim filePath As String
    
    Set ws = ThisWorkbook.Sheets("Employees")
    filePath = Application.GetSaveAsFilename(fileFilter:="PDF Files (*.pdf), *.pdf")
    
    If filePath <> "False" Then
        ws.ExportAsFixedFormat Type:=xlTypePDF, Filename:=filePath, Quality:=xlQualityStandard
        MsgBox "تم التصدير بنجاح!", vbInformation, "تصدير PDF"
    End If
End Sub

' =====================================================
' Sub: إنشاء نسخة احتياطية
' =====================================================
Sub CreateBackup()
    Dim filePath As String
    Dim backupName As String
    Dim sourceFile As String
    Dim fso As Object
    
    sourceFile = ThisWorkbook.FullName
    backupName = "Backup_" & Format(Now(), "yyyy-mm-dd_hh-mm-ss") & ".xlsx"
    filePath = ThisWorkbook.Path & "\" & backupName
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    fso.CopyFile sourceFile, filePath
    
    MsgBox "تم إنشاء نسخة احتياطية: " & backupName, vbInformation, "نسخة احتياطية"
End Sub

' =====================================================
' Sub: عند فتح الكتاب
' =====================================================
Sub Workbook_Open()
    UpdateDashboard
    MsgBox "مرحباً بك في نظام إدارة الموارد البشرية!", vbInformation, "ترحيب"
End Sub

' =====================================================
' Function: التحقق من البريد الإلكتروني
' =====================================================
Function IsValidEmail(email As String) As Boolean
    Dim atPos As Long
    Dim dotPos As Long
    
    atPos = InStr(email, "@")
    dotPos = InStr(atPos, email, ".")
    
    If atPos > 1 And dotPos > atPos + 1 And dotPos < Len(email) Then
        IsValidEmail = True
    Else
        IsValidEmail = False
    End If
End Function

' =====================================================
' Function: التحقق من رقم الهاتف
' =====================================================
Function IsValidPhone(phone As String) As Boolean
    Dim i As Long
    IsValidPhone = True
    
    If Len(phone) < 9 Then
        IsValidPhone = False
    End If
    
    For i = 1 To Len(phone)
        If Not IsNumeric(Mid(phone, i, 1)) And Mid(phone, i, 1) <> "+" And Mid(phone, i, 1) <> "-" Then
            IsValidPhone = False
            Exit Function
        End If
    Next i
End Function

' =====================================================
' Function: التحقق من أن الحقل رقمي
' =====================================================
Function IsNumeric(str As String) As Boolean
    IsNumeric = Not IsError(Value(str))
End Function

' =====================================================
' نهاية كود VBA
' =====================================================
