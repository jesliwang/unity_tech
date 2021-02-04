/*----------------------------------------
Created By: Jin-yeong, Park
E-Mail: hiccupturtle@hotmail.com
Site: http://blog.naver.com/hiccupturtle
Start Date: 2015-09-21

Purpose:
Max version 2014 or +
Batch processes Max files with Max scripts. 

Updated:

Bugs:

ToDo:
----------------------------------------*/

if (JYP_Batch != undefined ) do (destroyDialog JYP_Batch)
rollout JYP_Batch "BlessM_Batch   |   Ver.1.1" width:670 height:400 
(
	local InfoPath = undefined
	local ScriptPath = undefined
	local TargetFilePath = undefined
	local LogPath = undefined
	local LogState = undefined
	
	groupBox grp_Scripts "Scripts" pos:[10,5] width:650 height:50
	button btn_SelScriptPath "Select" pos:[20,25] width:60 height:18
	editText edt_ScriptPath "" pos:[80,25] width:525 height:19
	button btn_OpenScript "Open" pos:[608,25] width:42 height:18
	
	groupBox grp_MaxFiles "Max Files" pos:[10,60] width:650 height:275
	button btn_SelectTargetPath "Select" pos:[20,80] width:60 height:18
	editText edt_TargetPath "" pos:[80,80] width:495 height:19
	button btn_RefreshTargetList "R" pos:[578,80] width:27 height:18
	button btn_OpenFile "Open" pos:[608,80] width:42 height:18
	
	label lbl_max "*.max | Target Files" pos:[20,107] width:129 height:13
	checkbox chk_SubFolder "Include Subfolders" pos:[166,105] width:114 height:17 Checked:false
	label lbl_MaxFilesTotal "Total --- " pos:[580,107] width:45 height:13
	label lbl_TargetTotal "0000" pos:[625,107] width:33 height:13
	listBox lbx_Targets "" pos:[21,125] width:630 height:15
	
	groupBox grp_Log "Error Log" pos:[10,340] width:150 height:39
	checkbox chk_SaveLog "Save Log File" pos:[20,355] width:90 height:18
	button btn_ViewLog "View" pos:[115,354] width:35 height:18
	
	groupBox grp_Save "Save" pos:[165,340] width:250 height:39
	radioButtons rdo_Save "" pos:[175,355] width:174 height:16 labels:#("Overwrite", "SubFolder") columns:2  Default:2
	editText edt_FolderName "" pos:[315,353] width:90 height:19 text:"[Edited]"
	
	button btn_Start "Start" pos:[420,345] width:240 height:34
	progressBar pb_TotalProgress "ProgressBar" pos:[10,385] width:650 height:8 color:(color 0 255 255)
	
	/*-------------------- [Function] --------------------*/
	fn fn_setBatchInfo sectionStr keyStr valueStr = ( setIniSetting InfoPath sectionStr keyStr valueStr )
	fn fn_getBatchInfo sectionStr keyStr = ( outStr = (getIniSetting InfoPath sectionStr keyStr); return outStr )
	
	fn fn_getScripts SelPath = (
		local files = #()
		if SelPath != "" then (
			allFiles = (getFiles (SelPath + "\\" + "*.ms"))
			for x in allFiles do ( append files (fileNameFromPath x) )
		)
		
		
		
		
		return files
	)
	fn fn_getMaxFiles selPath = (
		if (chk_SubFolder.checked == true ) then (
			local allPath = getDirectories (selPath + "*")			
			for P in allPath do ( join allPath (getDirectories ( P + "*" ) ) )
			local files = #()
			for F in allPath do ( join files ( getFiles ( F + "/*.max" ) ) )
			return files
		) else ( files = ( getFiles ( selPath + "\*.max")); return files; )
	)
	
	fn fn_LogFile OpenFileInfo = (
		format "OpenFileInfo: %\n" OpenFileInfo
		format "LogPath: %\n" LogPath
		BatchLogFile = openFile LogPath
		format "% \n" OpenFileInfo to:BatchLogFile
		Close LogPath
	)
	fn fn_setLogPath = (
		if ( chk_SaveLog.checked == true ) then (
			TempPath = getSaveFileName caption:"Select Log File" \
							fileName:"MaxBatchLog.log" \
							types:"Log Data (*.log)|*.log"
			
			TempPath = edt_TargetPath.text  + "BatchLog.log"
			
			if TempPath != undefined then (
				--Write log path to Ini file
				fn_setBatchInfo "Info_Batch" "LogPath" TempPath
				logFile = createFile TempPath
			)
		)
	)
	/*-------------------- [Events] ---------------------*/
	on JYP_Batch open do (
	)
	
	on JYP_Batch close do (
		
	)
	
	on btn_SelScriptPath pressed do (
		try
		(
			local get_File = undefined
			if ( edt_ScriptPath.text != undefined ) then 
			(
				get_File = getOpenFilename filename:edt_ScriptPath.text types:"maxScript(*.ms)|*.ms"
			) else (
				get_File = getOpenFilename types:"maxScript(*.ms)|*.ms"
			)
			if ( get_File != undefined ) do
			(
				edt_ScriptPath.text = get_File
				--lbx_Scripts.items = ( fn_getScripts edt_ScriptPath.text)
			)
		) catch( messageBox "Failed")
		
		
		
	)
	
	on btn_OpenScript pressed do ( shellLaunch "explorer.exe" edt_ScriptPath.text )
	
	
	
	on btn_SelectTargetPath pressed do (
		if ( edt_TargetPath.text != undefined ) then ( TempPath = (getSavePath caption: "Select the Maxfiles path" initialDir: edt_TargetPath.text )
		) else ( TempPath = (getSavePath caption: "Select the Maxfiles path") )
		if ( TempPath != undefined ) then (
			edt_TargetPath.text = TempPath
			lbx_Targets.items = ( fn_getMaxFiles TempPath)
			lbl_TargetTotal.text = lbx_Targets.items.count as string
		)
	)

	on btn_RefreshTargetList pressed do ( 
		if ( edt_TargetPath.text != undefined ) do (
			lbx_Targets.items = ( fn_getMaxFiles edt_TargetPath.text )
			lbl_TargetTotal.text = ( lbx_Targets.items.count as string )
		)
	)
	
	on btn_OpenFile pressed do ( shellLaunch "explorer.exe" edt_TargetPath.text )
	
	on chk_SubFolder changed theState do (
		if ( edt_TargetPath.text != undefined ) do (
			lbx_Targets.items = ( fn_getMaxFiles edt_TargetPath.text )
			lbl_TargetTotal.text = ( lbx_Targets.items.count as string )
		)
	)
	
	on btn_ViewLog pressed do (
		SavedLog = edt_TargetPath.text  + "\BatchLog.txt"
		SearchLog = getFiles SavedLog
		if ( SearchLog.count != 0 ) then ( shellLaunch "notepad.exe" SavedLog 
		) else ( Messagebox "The Log don't exist.")
	)
	
	on btn_Start pressed do (
		
		if (edt_ScriptPath.text == "" ) then
		(
			messagebox "No scripts selected."
		) else (
			escapeEnable = true
			scriptSel = 0
			LogState = undefined
			pb_TotalProgress.color = color 255 0 0
			
			pb_TotalProgress.value = 0
			num = 0
			MaxFileNum = lbx_Targets.items.count
			if ( chk_SaveLog.checked == true ) do ( LogPath = edt_TargetPath.text  + "\BatchLog.txt"; createFile LogPath; )
			for i = 1 to MaxFileNum do (
				try (
					loadMaxFile lbx_Targets.items[i] useFileUnits:true quiet:true
					try (
						fileIn (edt_ScriptPath.text)
					) catch ()
							
					local TempPath = ""
					if ( rdo_Save.state == 1) then ( 
						TempPath = lbx_Targets.items[i] 
						saveMaxFile TempPath
					) else (
						TempPath = (getFilenamePath lbx_Targets.items[i]) + edt_FolderName.text
						makeDir TempPath all:true
						if ( TempPath.count == 0 ) do ( makeDir TempPath all:true ) 
						TempFile = fileNameFromPath lbx_Targets.items[i]
						saveMaxFile (TempPath + "\\" + TempFile )
					)
				) catch ( 
					format "Error : lbx_Targets.items[i]\n" to:LogPath
				)
				pb_TotalProgress.value = ((100.0 * (num += 1)) / MaxFileNum)
				gc()
			)
			if ( LogState == false) do ( deleteFile LogPath )
			pb_TotalProgress.color = (color 0 255 255)
			MessageBox "Completed."
		)
	)
)
createdialog JYP_Batch
