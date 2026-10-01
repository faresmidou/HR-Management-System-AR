@echo off
REM ملف بدء تشغيل برنامج نظام إدارة الموارد البشرية
REM HR Management System Start Script

setlocal enabledelayedexpansion

REM تعيين المتغيرات
set APP_NAME=نظام إدارة الموارد البشرية
set APP_VERSION=v1.0
set APP_DIR=%~dp0

REM مسح الشاشة
cls

REM طباعة الرسالة الترحيبية
echo.
echo ================================================================================
echo                    %APP_NAME%
echo                    HR Management System - %APP_VERSION%
echo ================================================================================
echo.
echo جارٍ تحميل البرنامج...
echo.

REM التحقق من وجود ملف الدخول
if not exist "%APP_DIR%Login.hta" (
    echo خطأ: لم يتم العثور على ملف Login.hta
    echo الرجاء التأكد من وجود جميع ملفات البرنامج في نفس المجلد
    pause
    exit /b 1
)

REM بدء تشغيل البرنامج
echo جارٍ تشغيل واجهة الدخول...
echo.

start mshta.exe "%APP_DIR%Login.hta"

echo.
echo ✓ تم بدء البرنامج بنجاح
echo.
echo إذا لم تظهر نافذة البرنامج، تأكد من أن:
echo 1. Windows Script Host مثبت على النظام
echo 2. لديك صلاحيات المشرف لتشغيل البرنامج
echo.
pause

endlocal
