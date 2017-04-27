@echo off

SET REV=3.0.0rc1
SET REVISION="%REV%"
SET SETUP_DIR=%~dp0
SET OUT_DIR=%SETUP_DIR%
SET IN_DIR="C:\mect_plugins"
SET PATH=%PATH%;C:\Qt485\desktop\mingw32\bin\

SET TARGET_LIST=TP1043_01_A TP1043_01_B TP1043_01_C TP1057_01_A TP1057_01_B TP1070_01_A TP1070_01_B TP1070_01_C TP1070_01_D TPAC1006 TPAC1007_03 TPAC1007_04_AA TPAC1007_04_AB TPAC1007_04_AC TPAC1008_01 TPAC1008_02_AA TPAC1008_02_AB TPAC1008_02_AC TPAC1008_02_AD TPAC1008_02_AE TPAC1008_02_AF


SET QTPROJECT=1
SET BUILD=1
SET INSTALL=1
SET UPDATE=1
SET MECT_HELP=1
SET CTEBUILD=1
SET CTCBUILD=1

IF %UPDATE% == 1 (
	SET PREPARE_UPDATE=1
) ELSE (
	SET PREPARE_UPDATE=0
)

echo.
echo Mect plugin Revision: %REVISION%
echo MectConfigurator Revision: %MECT_CONFIGURATOR_REVISION%
echo.
echo Building: %BUILD%
echo Install: %INSTALL%
echo.

echo.
echo ----------------------------------------
echo Creating the installer version %REVISION%
echo ----------------------------------------
echo. 

echo Creating the installer version %REVISION% > %OUT_DIR%\error.log

SET ORIGINAL=%CD%

rem ############################################## 
rem Removing Qt485 Directory
rem ############################################## 
IF EXIST %OUT_DIR%\Qt485 RD /S /Q %OUT_DIR%\Qt485

rem ############################################## 
rem MECT SUITE HELP
rem ##############################################
if %MECT_HELP% == 1 (

	echo Generating help files...
	mkdir %OUT_DIR%\Qt485\desktop\doc\qch  >> %OUT_DIR%\error.log
	c:\Qt485\desktop\bin\qhelpgenerator.exe ..\qt_help\tutorial\doc.qhp -o %OUT_DIR%\Qt485\desktop\doc\qch\doc.qch  >> %OUT_DIR%\error.log
	c:\Qt485\desktop\bin\qhelpgenerator.exe ..\qt_help\tutorial\doc_eng.qhp -o %OUT_DIR%\Qt485\desktop\doc\qch\doc_eng.qch  >> %OUT_DIR%\error.log	
)

rem ##############################################
rem BUILDING VERSION
rem ##############################################
IF %BUILD% == 1 (
	SET DLLBUILD=1
	SET TEMPLATE=1
	SET TARGETBUILD=0
) ELSE (
	SET DLLBUILD=0
	SET TEMPLATE=0
	SET TARGETBUILD=0
)

IF %DLLBUILD% == 1 (
	echo Building dll libraries...
	cd /D %IN_DIR%\qt_plugins
	time /t
	"C:\Qt485\desktop\mingw32\bin\mingw32-make.exe" distclean>nul 2>&1
	"C:\Qt485\desktop\bin\qmake.exe" qt_designer_plugins.pro -r -spec win32-g++ "CONFIG+=release" -config store -config trend -config recipe -config alarms "DEFINES += ATCM_VERSION=\"%REVISION%\"" >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during Building dll libraries
		pause
		cd %ORIGINAL%
		exit
	)

	"C:\Qt485\desktop\mingw32\bin\mingw32-make.exe" >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during Building dll libraries
		pause
		cd %ORIGINAL%
		exit
	)

	rem remove the old files
 	del /q C:\Qt485\desktop\plugins\designer\atcm*
	"C:\Qt485\desktop\mingw32\bin\mingw32-make.exe" install >> %OUT_DIR%\error.log 2>&1
 	IF ERRORLEVEL 1 (
		echo problem during installation dll libraries
		pause
		cd %ORIGINAL%
		exit
	)
	"C:\Qt485\desktop\mingw32\bin\mingw32-make.exe" distclean>nul 2>&1
	time /t

)

IF %CTEBUILD% == 1 (
	echo Building cte dll libraries...
	cd /D %IN_DIR%\cte
	time /t
	"C:\Qt485\desktop\mingw32\bin\mingw32-make.exe" distclean>nul 2>&1
	"C:\Qt485\desktop\bin\qmake.exe" cte.pro -r -spec win32-g++ "CONFIG+=release"  "DEFINES += ATCM_VERSION=\"%REVISION%\"" >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during Building cte dll libraries
		pause
		cd %ORIGINAL%
		exit
	)

	"C:\Qt485\desktop\mingw32\bin\mingw32-make.exe" >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during Building cte dll libraries
		pause
		cd %ORIGINAL%
		exit
	)

	rem remove the old files
 	del /q C:\Qt485\desktop\lib\qtcreator\plugins\QtProject\cte.dll
	del /q C:\Qt485\desktop\lib\qtcreator\plugins\QtProject\CTE.pluginspec
	rem copy new files from build directory to Qt Creator Plugin directory
	copy %IN_DIR%\cte\destdir\CTE.dll C:\Qt485\desktop\lib\qtcreator\plugins\QtProject\CTE.dll /Y >> %OUT_DIR%\error.log
	copy %IN_DIR%\cte\CTE.pluginspec  C:\Qt485\desktop\lib\qtcreator\plugins\QtProject\CTE.pluginspec /Y >> %OUT_DIR%\error.log
 	IF ERRORLEVEL 1 (
		echo problem during installation cte dll libraries
		pause
		cd %ORIGINAL%
		exit
	)
	rem Cleaning builded files	
	"C:\Qt485\desktop\mingw32\bin\mingw32-make.exe" distclean>nul 2>&1
	time /t

)

IF %CTCBUILD% == 1 (
	echo Building ctc.exe...
	cd /D %IN_DIR%\ctc
	time /t
	"C:\Qt485\desktop\mingw32\bin\mingw32-make.exe" distclean>nul 2>&1
	"C:\Qt485\desktop\bin\qmake.exe" ctc.pro -r -spec win32-g++ "CONFIG+=release"  "DEFINES += ATCM_VERSION=\"%REVISION%\"" >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during Building ctc.exe 
		pause
		cd %ORIGINAL%
		exit
	)

	"C:\Qt485\desktop\mingw32\bin\mingw32-make.exe" >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during Building ctc.exe 
		pause
		cd %ORIGINAL%
		exit
	)

	rem remove the old files
 	del /q C:\Qt485\desktop\bin\ctc.exe
	rem copy new files	
	copy %IN_DIR%\ctc\release\ctc.exe C:\Qt485\desktop\bin\ctc.exe /Y >> %OUT_DIR%\error.log
 	IF ERRORLEVEL 1 (
		echo problem during installation ctc.exe 
		pause
		cd %ORIGINAL%
		exit
	)
	"C:\Qt485\desktop\mingw32\bin\mingw32-make.exe" distclean>nul 2>&1
	time /t

)

IF %TEMPLATE% == 1 (
	echo Installing templates...
	time /t
	for /d %%a in ("C:\Qt485\desktop\share\qtcreator\templates\wizards\ATCM-*") do rd /s /q "%%~a"
	mkdir %OUT_DIR%\Qt485\desktop\share\qtcreator\templates\wizards
	
	xcopy %IN_DIR%\qt_templates\ATCM-template-project C:\Qt485\desktop\share\qtcreator\templates\wizards\ATCM-template-project /Q /Y /E /S /I >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during template.
		pause
		cd %ORIGINAL%
		exit
	)

	xcopy %IN_DIR%\qt_templates\ATCM-template-form-class C:\Qt485\desktop\share\qtcreator\templates\wizards\ATCM-template-form-class /Q /Y /E /S /I >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during template.
		pause
		cd %ORIGINAL%
		exit
	)

	for /d %%a in (%TARGET_LIST%) do (
		echo 	Installing %%~a...
		xcopy "%IN_DIR%\qt_templates\ATCM-template-project-%%~a" "C:\Qt485\desktop\share\qtcreator\templates\wizards\ATCM-template-project-%%~a" /Q /Y /E /S /I >> %OUT_DIR%\error.log 2>&1
		IF ERRORLEVEL 1 (
			echo problem during template.
			pause
			cd %ORIGINAL%
			exit
		)
	)

	time /t
)

IF %TARGETBUILD% == 1 (
	echo Building target libraries...
	cd /D "%IN_DIR%"
	time /t
	"C:\Qt485\imx28\mingw\bin\mingw32-make.exe" distclean>nul 2>&1
	"C:\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\bin\qmake.exe" qt_atcm.pro -r -spec linux-arm-gnueabi-g++ -config release -config store -config trend -config recipe -config alarms >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during crating make file for target libraries
		pause
		cd %ORIGINAL%
		exit
	)
	
	"C:\Qt485\imx28\mingw\bin\mingw32-make.exe" >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during building target libraries
		pause
		cd %ORIGINAL%
		exit
	)

	"C:\Qt485\imx28\mingw\bin\mingw32-make.exe" install >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during install target libraries
		pause
		cd %ORIGINAL%
		exit
	)

	"C:\Qt485\imx28\mingw\bin\mingw32-make.exe" distclean>nul 2>&1
	time /t
)

rem ##############################################
rem CONFIGURATION QTPROJECT
rem ##############################################
IF %QTPROJECT% == 1 (
	echo Preparing Configuration into QtProject...
	time /t
	rem "c:\Program Files\7-Zip\7z.exe" u -r -mx1 "%OUT_DIR%\QtProject.7z" "%APPDATA%\QtProject\qtcreator\devices.xml" "%APPDATA%\QtProject\qtcreator\profiles.xml" "%APPDATA%\QtProject\qtcreator\qtversion.xml" "%APPDATA%\QtProject\qtcreator\toolchains.xml" "%APPDATA%\QtProject\qtcreator\externaltools\lupdate.xml" >> %OUT_DIR%\error.log
	del /q "%OUT_DIR%\QtProject.7z"
	rem "c:\Program Files\7-Zip\7z.exe" u -r -mx1 "%OUT_DIR%\QtProject.7z" "%APPDATA%\QtProject" -x!QtCreator.db -x!QtCreator.ini -xr!"qtcreator\generic-highlighter" -xr!"qtcreator\json" -xr!qtcreator\macros -x!qtcreator\default.qws -x!qtcreator\helpcollection.qhc >> %OUT_DIR%\error.log
	"c:\Program Files\7-Zip\7z.exe" u -r -mx1 "%OUT_DIR%\QtProject.7z" "%OUT_DIR%\QtProject" >> %OUT_DIR%\error.log
	IF ERRORLEVEL 1 (
	 	echo problem during creation 7z file
	 	pause
		cd %ORIGINAL%
	 	exit
	)
)

rem ##############################################
rem UPDATE
rem ##############################################
IF %INSTALL% == 1 (
	SET PREPARE_UPDATE=1
)

IF %PREPARE_UPDATE% == 1 (
	echo Creating the update
	time /t
	echo Copying dll...
	mkdir %OUT_DIR%\Qt485\desktop\plugins\designer
	xcopy C:\Qt485\desktop\plugins\designer\*.dll %OUT_DIR%\Qt485\desktop\plugins\designer /Q /Y >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during .dll copy.
		pause
		cd %ORIGINAL%
		exit
	)

	echo Copying template...
	mkdir %OUT_DIR%\Qt485\desktop\share\qtcreator\templates\wizards
	xcopy C:\Qt485\desktop\share\qtcreator\templates\wizards\ATCM-template-project %OUT_DIR%\Qt485\desktop\share\qtcreator\templates\wizards\ATCM-template-project				/Q /Y /E /S /I >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during template.
		pause
		cd %ORIGINAL%
		exit
	)

	xcopy C:\Qt485\desktop\share\qtcreator\templates\wizards\ATCM-template-form-class %OUT_DIR%\Qt485\desktop\share\qtcreator\templates\wizards\ATCM-template-form-class	/Q /Y /E /S /I >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during template.
		pause
		cd %ORIGINAL%
		exit
	)

	for /d %%a in (%TARGET_LIST%) do (
		echo Installing %%~a...
		xcopy C:\Qt485\desktop\share\qtcreator\templates\wizards\ATCM-template-project-%%~a %OUT_DIR%\Qt485\desktop\share\qtcreator\templates\wizards\ATCM-template-project-%%~a				/Q /Y /E /S /I >> %OUT_DIR%\error.log 2>&1
		IF ERRORLEVEL 1 (
			echo problem during template.
			pause
			cd %ORIGINAL%
			exit
		)
	)
	
	echo Copying Cross Table Editor and Compiler
	mkdir %OUT_DIR%\Qt485\desktop\lib\qtcreator\plugins\QtProject
	mkdir %OUT_DIR%\Qt485\desktop\bin
	copy C:\Qt485\desktop\lib\qtcreator\plugins\QtProject\CTE.dll %OUT_DIR%\Qt485\desktop\lib\qtcreator\plugins\QtProject\ /Y >> %OUT_DIR%\error.log
	copy C:\Qt485\desktop\lib\qtcreator\plugins\QtProject\CTE.pluginspec %OUT_DIR%\Qt485\desktop\lib\qtcreator\plugins\QtProject\ /Y >> %OUT_DIR%\error.log
	copy C:\Qt485\desktop\bin\ctc.exe %OUT_DIR%\Qt485\desktop\bin\ /Y >> %OUT_DIR%\error.log

	echo Copying rootfs...
	mkdir %OUT_DIR%\Qt485\imx28
	xcopy C:\Qt485\imx28\rootfs %OUT_DIR%\Qt485\imx28\rootfs	/Q /Y /E /S /I >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during template.
		pause
		cd %ORIGINAL%
		exit
	)

	echo Copying conf files...
	mkdir %OUT_DIR%\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++
	mkdir %OUT_DIR%\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\common
	xcopy C:\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++\qmake.conf %OUT_DIR%\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++	/Q /Y /E /S /I >> %OUT_DIR%\error.log 2>&1
	xcopy C:\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\common\mect.conf %OUT_DIR%\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\common	/Q /Y /E /S /I >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during template.
		pause
		cd %ORIGINAL%
		exit
	)

	echo Cleaning svn files...
	cd /D %OUT_DIR%\Qt485
	for /d /r . %%d in (.svn) do @if exist "%%d" rd /s/q "%%d"
	cd ..

	echo Cleaning bak files...
	cd /D %OUT_DIR%\Qt485
	for /d /r . %%d in (*.bak) do @if exist "%%d" rd /s/q "%%d"
	cd ..

	echo Creating archive...
	IF EXIST Qt485_upd_rev%REVISION%.7z del /q Qt485_upd_rev%REVISION%.7z

	"c:\Program Files\7-Zip\7z.exe" u -r -mx9 %OUT_DIR%\Qt485_upd_rev%REVISION%.7z %OUT_DIR%\Qt485\imx28 >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during creation of 7z update archive.
		pause
		cd %ORIGINAL%
		exit
	)

	"c:\Program Files\7-Zip\7z.exe" u -r -mx9 %OUT_DIR%\Qt485_upd_rev%REVISION%.7z %OUT_DIR%\Qt485\desktop >> %OUT_DIR%\error.log 2>&1
	IF ERRORLEVEL 1 (
		echo problem during creation of 7z update archive.
		pause
		cd %ORIGINAL%
		exit
	)

	RD /S /Q Qt485
	time /t

)

rem ##############################################
rem INSTALLATION
rem ##############################################
IF %INSTALL% == 1 (
	echo Please check if you have rebuild the Target library and the Desktop library
	echo. 

	echo Preparing files...
	time /t
	echo   Target files...
	"c:\Program Files\7-Zip\7z.exe" u -r -mx9 "%OUT_DIR%\Qt485.7z" "C:\Qt485\imx28" -xr!rootfs -x!qt-everywhere-opensource-src-4.8.5\mkspecs\common\mect.conf -x!qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++\qmake.conf  >> %OUT_DIR%\error.log
	IF ERRORLEVEL 1 (
	 	echo problem during creation 7z file
	 	pause
		cd %ORIGINAL%
	  	exit
	)
	echo   PC files...
	copy "C:\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++\qmake.conf" "C:\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++\qmake.conf.mect"
	copy "C:\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++\qmake.conf.ori" "C:\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++\qmake.conf"
	"c:\Program Files\7-Zip\7z.exe" u -r -mx9 "%OUT_DIR%\Qt485.7z" "C:\Qt485\desktop"  -xr!atcm*.dll -xr!ATCM-template-* -xr!CTE.dll -xr!CTE.pluginspec -xr!ctc.exe >> %OUT_DIR%\error.log
	IF ERRORLEVEL 1 (
		copy "C:\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++\qmake.conf.mect" "C:\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++\qmake.conf"
		echo problem during creation 7z file
		pause
		cd %ORIGINAL%
		exit
	)
	copy "C:\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++\qmake.conf.mect" "C:\Qt485\imx28\qt-everywhere-opensource-src-4.8.5\mkspecs\linux-arm-gnueabi-g++\qmake.conf"

	echo   Fonts files...
	del /q "%OUT_DIR%\Fonts.7z"
	"c:\Program Files\7-Zip\7z.exe" u -r -mx9 "%OUT_DIR%\Fonts.7z" "%OUT_DIR%\Fonts" >> %OUT_DIR%\error.log
	IF ERRORLEVEL 1 (
	 	echo problem during creation of Fonts.7z file
	 	pause
		cd %ORIGINAL%
	  	exit
	)
	time /t

)


rem IF EXIST %OUT_DIR%\Qt485.7z del /q %OUT_DIR%\Qt485.7z

rem IF EXIST %OUT_DIR%\MectConfigurator.7z del /q %OUT_DIR%\MectConfigurator.7z

rem IF EXIST %OUT_DIR%\Qt485 RD /S /Q %OUT_DIR%\Qt485

rem IF EXIST %OUT_DIR%\Qt485_upd_rev%REVISION%.7z del /q %OUT_DIR%\Qt485_upd_rev%REVISION%.7z

cd %ORIGINAL%

echo Setup done.
@echo on

pause