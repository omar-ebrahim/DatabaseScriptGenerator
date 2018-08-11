# DatabaseScriptGenerator
PowerShell scripts to create database SQL scripts

## Usage
.\generate-inserts.ps1 -serverName "Omar\SQLEXPRESS" -databaseName "SCHOOL" -tableNames "GRADUATION","STUDENT" -savePath = "C:\Documents\Databases\"

The -tableNames and - savePath are optional.

If -tableNames isn't given then insert scripts for all tables that aren't system tables are created.
If -savePath isn't given then a default of C:\Temp\ is use

The saved file will be DATABASENAME_inserts.sql, where DATABASENAME is the name of the database used, so for the "SCHOOL" database the filename will be SCHOOL_inserts.sql
