/* 	
	Bless_Exporter by Jinyeong, Park
	+ Previous version
		int.v.beta [2015-08-07]
		int v.2.0 [2016-02-22]
		int v.2.1 [2016-07-06]
	+ New version
		int v.0.7 [2017-06-13]
	Required MAX 2015
*/

try ( destroyDialog BlessM_Exporter ) catch ()
rollout BlessM_Exporter "BlessM FBX Exporter   |   ver.0.7 (2017.06.13)   |   by JYP" width:605 height:360
(
	local InfoPath = undefined
	local TargetPath = undefined
	local onoff = undefined
	local arr_Filename = undefined
	local Dialog_StartFBX = true
	local WPName = #("BN_Weapon_R", "BN_Weapon_L")
	local EpBNList_ElfA  = #( 
		"Bip01", "Bip01 Pelvis", "Bip01 Spine", "Bip01 Spine1", "Bip01 Spine2", 
		"Bip01 Neck", "BN_Skirt_BL_02_T1", "BN_Hair_UR_2", "BN_Hair_UR_3", "BN_Hair_UL_2", 
		"BN_Hair_UL_3", "BN_Hair_B_1", "BN_Hair_B_2", "BN_Hair_B_3", "Bip01 L Clavicle", 
		"Bip01 L UpperArm", "Bip01 L Forearm", "Bip01 L Hand", "Bip01 L Finger0", "Bip01 L Finger01", 
		"Bip01 L Finger1", "Bip01 L Finger11", "Bip01 L Finger2", "Bip01 L Finger21", "BN_Weapon_L", 
		"Bip01 R Clavicle", "Bip01 R UpperArm", "Bip01 R Forearm", "Bip01 R Hand", "Bip01 R Finger0", 
		"Bip01 R Finger01", "Bip01 R Finger1", "Bip01 R Finger11", "Bip01 R Finger2", "Bip01 R Finger21", 
		"BN_Weapon_R", "BN_breast_L_02", "BN_breast_R_02", "Bip01 L Thigh", "Bip01 L Calf", 
		"Bip01 L Foot", "Bip01 L Toe0", "Bip01 R Thigh", "Bip01 R Calf", "Bip01 R Foot", 
		"Bip01 R Toe0", "BN_Skirt_B_01_T1", "BN_Skirt_B_02_T1", "BN_Skirt_B_03_T1", "BN_Skirt_F_01_T1", 
		"BN_Skirt_F_02_T1", "BN_Skirt_F_03_T1", "BN_Skirt_BR_01_T1", "BN_Skirt_BR_02_T1", "BN_Skirt_BR_03_T1", 
		"BN_Skirt_R_01_T1", "BN_Skirt_R_02_T1", "BN_Skirt_R_03_T1", "BN_Skirt_FR_01_T1", "BN_Skirt_FR_02_T1", 
		"BN_Skirt_FR_03_T1", "BN_Skirt_L_01_T1", "BN_Skirt_L_02_T1", "BN_Skirt_L_03_T1", "BN_Skirt_FL_01_T1", 
		"BN_Skirt_FL_02_T1", "BN_Skirt_FL_03_T1", "BN_Skirt_BL_01_T1", "BN_Skirt_BL_03_T1", "Bip01 Head"
	)
	local EpBNList_HumH = #()
	local EpBNList_Masq = #()
	local EpBNList_Pant = #()
	local SelectedBN = #()
	----------------------------------------------------------------
	groupBox grp_AddFile "Step1. Files" pos:[10,10] width:255 height:80
	button btn_CurrFile "Curr" pos:[20,30] width:35 height:23
	button btn_SelFile "File" pos:[55,30] width:35 height:23
	button btn_AddFiles "Folder" pos:[90,30] width:50 height:23
	checkbox chk_Sub "SubPath" pos:[145,33] width:60 height:18 checked:true
	button btn_SrcOpen "Open" pos:[220,30] width:35 height:23
	editText edt_SrcPath "" pos:[15,60] width:240 height:20 text:"-- select a source path --"
	groupBox grp_Type "Step2. Type" pos:[270,10] width:90 height:80 enabled:false
	radioButtons rdo_Output "" pos:[280,35] width:100 height:48 labels:#("Animation", "Costume") default:1 columns:1 offsets:#([0,0], [0,10]) enabled:false
	groupBox grp_Tribe "Step3. Tribe" pos:[365,10] width:90 height:80
	dropDownList ddl_SelTribe "" pos:[375,45] width:70 height:41 items:#("----------", "HumH_M", "ElfA_F", "Pant_M", "Masq_F") align:#left
	button btn_Run "Run" pos:[460,15] width:135 height:50
	button btn_Reset "Reset" pos:[460,60] width:135 height:30
	label lbl_ExpPath "Export to :" pos:[13,98] width:60 height:22
	editText edt_Path "" pos:[67,96] width:350 height:18 text:"<Without Any Changes Files Save to Each Folder>"
	button btn_ExportPath "..." pos:[420,94] width:24 height:22
	button btn_Open "Open" pos:[444,94] width:50 height:22
	button btn_ExpPathReset "R" pos:[494,94] width:24 height:22
	label lbl_Total "Total -" pos:[525,98] width:36 height:18
	label lbl_Count "None" pos:[565,98] width:31 height:18
	listBox lbx_Files "" pos:[10,120] width:585 height:16
	progressBar pb_Progress "" pos:[10,342] width:540 height:9 color:(color 255 0 255)
	label lbl_Progress "00"  pos:[560,340] width:20 height:12
	label lbl_Percent "%" pos:[580,340] width:30 height:12
	-----------------------------------------------------------------
	-- Function
	----------------------------------------------------------------
	fn fn_getBatchInfo sectionStr keyStr = ( outStr = (getIniSetting InfoPath sectionStr keyStr); return outStr; )
	fn fn_setBatchInfo sectionStr keyStr valueStr = ( setIniSetting InfoPath sectionStr keyStr valueStr )
	
	fn fn_CurrentFile = 
	( 
		local FilePath = maxFilePath + maxFileName
		return FilePath
	)
	
	fn fn_AddFile ReferFile =
	(
		local CheckCharMax = findstring ReferFile ".max"
		local CheckSlash = true
		local IndexSlash = undefined
		for i=1 to CheckCharMax while CheckSlash do
		(
			if ( ReferFile[CheckCharMax - i] == "\\" ) do
			(
				IndexSlash = CheckCharMax - i
				CheckSlash = false
			)
		)
		local FileInfo = #("", "")
		FileInfo[1] = replace ReferFile IndexSlash (ReferFile.count - IndexSlash + 1) ""
		local SelFileName = replace ReferFile CheckCharMax 4 ""
		FileInfo[2] = ReferFile
		return FileInfo
	)	
		
	fn fn_AddMaxFiles = 
	(
		local my_files = #()
		local theMax_Path = undefined
		if (TargetPath != undefined ) then (
			theMax_Path = getSavePath initialDir:TargetPath
		) else ( theMax_Path = getSavePath() )
		TargetPath = theMax_Path
		if theMax_Path != undefined do (
			if (chk_Sub.checked == true ) then (
				my_files = getfiles (theMax_Path+"\\*.max")
				local arr_Dir = GetDirectories ( theMax_Path + "/*" )	
				for d in arr_Dir do ( 	join arr_Dir (GetDirectories (d+"/*")) )
				my_AddFiles = #()
				for f in arr_Dir do ( join my_AddFiles ( getFiles (f + "*.max") ) )
				my_files = my_files + my_AddFiles
			) else ( my_files = getfiles (theMax_Path+"\\*.max") )		
		)
		local TempArr = #(my_files, theMax_Path)
		return TempArr		
	)
	
	fn fn_SysUnitSetup = 
	(
		try
		(
			units.SystemScale = 5
			units.SystemType = #centimeters
		) catch ( print "Checked System Unit" )
	)	

	fn fn_SelectBodyBones SelectedTribe = 
	(
		clearselection()
		SelectedBN = #()
		for i=1 to SelectedTribe.count do
		(
			append SelectedBN (getnodebyname SelectedTribe[i] )
		)
		local CheckItem = finditem SelectedBN undefined
		if ( CheckItem == 0 ) then 
		( 
			select SelectedBN
			return true 
		) else ( return false )
	)

	fn fn_SwitchBipedMode onoff = 
	(
		try with redraw off (
			clearselection()
			max motion mode
			select $bip01
			biped_ctrl = $.transform.controller
			biped_ctrl.figureMode = onoff
			clearselection()
		) catch (print "failed to set to FigureMode")
	)
	
	fn fn_ExportMeshOption = 
	(
		if ( rdo_Output.state == 2 ) then (hideByCategory.geometry = false)
		else ( hideByCategory.geometry = true )
	)

	----------------------------------------------------------------
	-- Event
	----------------------------------------------------------------
	on BlessM_Exporter open do (
		InfoPath = (getDir #plugCfg) + "\\" + "BlessM_Info.ini"
		iniEx = if ((getfiles InfoPath).count != 0 ) then (true) else (false)
		if ( iniEx == true ) do
		(
			try ( TargetPath = ( fn_getBatchInfo "Info_Exporter" "MaxPath") as string) catch ()
			try ( chk_Sub.checked = ( fn_getBatchInfo "Info_Exporter" "SubFolder") as booleanClass ) catch ()
			try ( rdo_Output.state = (fn_getBatchInfo "Info_Exporter" "OutputType") as integer ) catch ()
			try ( ddl_SelTribe.selection = (fn_getBatchInfo "Info_Exporter" "SelTribe") as integer ) catch (1)
			try ( setDialogPos BlessM_Exporter (execute (fn_getBatchInfo "Info_Exporter" "Position")) ) catch ()
		)
	)

	on BlessM_Exporter close do (
		fn_setBatchInfo "Info_Exporter" "MaxPath" ( TargetPath as string )
		fn_setBatchInfo "Info_Exporter" "SubFolder" (chk_Sub.checked as string)
		fn_setBatchInfo "Info_Exporter" "OutputType" (rdo_Output.state as string)
		fn_setBatchInfo "Info_Exporter" "SelTribe" (ddl_SelTribe.selection as string) 
		fn_setBatchInfo "Info_Exporter" "Position" (getDialogPOs BlessM_Exporter as string)
	)

	on btn_CurrFile pressed do 
	(
		try
		(
			local TempName = maxFilePath + maxFileName
			if ( TempName != "" ) then (
				local List_Files = #()
				append List_Files (maxFilePath + maxFileName)
				lbx_Files.items = List_Files
				edt_SrcPath.text = List_Files
				lbl_Count.text = lbx_Files.items.count as string
			) else ( messagebox "Save Required!" )
			
		) catch( messageBox "Failed")
	)
	
	on btn_SelFile pressed do
	(
		try
		(
			local get_File = getOpenFilename filename:edt_SrcPath.text types:"max(*.max)|*.max"
			if ( get_File != undefined ) do
			(
				local FileInfo = fn_AddFile get_File
				edt_SrcPath.text = FileInfo[1]
				lbx_Files.items = #(FileInfo[2])
				lbl_Count.text =  "+ Total - 1"
			)
		) catch( messageBox "Failed")
	)
	
	on btn_AddFiles pressed do (
		try (
			local TempPath = fn_AddMaxFiles()
			lbx_Files.items = TempPath[1]
			edt_SrcPath.text = TempPath[2]
			lbl_Count.text = lbx_Files.items.count as string
		) catch ( messageBox "Cancled")
	)

	on btn_SrcOpen pressed do	( shellLaunch "explorer.exe" edt_SrcPath.text )

	on btn_ExportPath pressed do (
		Dialog_StartFBX = true
		local Temp_Dir = getSavePath caption:"FBX저장경로" initialDir:maxFilePath
		if (Temp_Dir != undefined ) do (
			edt_Path.text = Temp_Dir
			return true
		)
	)
	
	on btn_Open pressed do 
	( 
		if ( edt_Path.text == "<Without Any Changes Files Save to Each Folder>" )  then 
		(
			shellLaunch "explorer.exe" edt_SrcPath.text
		) else (
			shellLaunch "explorer.exe" edt_Path.text 
		)
	)
	
	on btn_ExpPathReset pressed do ( edt_Path.text = "<Without Any Changes Files Save to Each Folder>" )
	
	on btn_Run pressed do 
	(
		if ( ddl_SelTribe.selection == 1 ) then ( messagebox "Select Tribe" ) else 
		(
			local ExportStatus = #(0,0)
			pb_Progress.value = 1
			lbl_Progress.text = "00 %"
			arr_Filename = #()
			fn_SysUnitSetup()
			WorkTime_Start = localTime
			disableSceneRedraw()
			for i = 1 to lbx_Files.items.count do with redraw off (
				loadMaxFile lbx_Files.items[i] missingExtFilesAction:#logmsg useFileUnits:true quiet:true
				if keyboard.escPressed then(
					exit with(pb_Progress.value = 0; MessageBox "Cancled!")
				)else(
					local Path_MaxFile = undefined
					if ( edt_Path.text == "<Without Any Changes Files Save to Each Folder>" ) then ( Path_MaxFile = getFilenamePath lbx_Files.items[i]
					) else ( Path_MaxFile = edt_Path.text )
					local Name_File = getFilenameFile lbx_Files.items[i]
					local Path_FBX = Path_MaxFile + "\\" + Name_File + ".FBX"
					local Temp_Facial = Path_MaxFile + "\\" + "Facial" + "\\"
					local Path_Facial =  Temp_Facial + Name_File + ".FBX"

		
						local CheckExistBN = undefined
						clearselection()
						onoff = false
						fn_SwitchBipedMode onoff
						if ( ddl_SelTribe.selected == "HumH_M") do 
						(
							CheckExistBN = fn_SelectBodyBones EpBNList_HumH 
							if (CheckExistBN != true) do ( format "BNError - %\n" lbx_Files.items[i] )
						)
						if ( ddl_SelTribe.selected == "ElfA_F") do 
						(
							CheckExistBN = fn_SelectBodyBones EpBNList_ElfA 
							if (CheckExistBN != true) do ( format "BNError - %\n" lbx_Files.items[i] )
						)
						if ( ddl_SelTribe.selected == "Pant_M") do 
						(
							CheckExistBN = fn_SelectBodyBones EpBNList_Pant 
							if (CheckExistBN != true) do ( format "BNError - %\n" lbx_Files.items[i] )
						)
						if ( ddl_SelTribe.selected == "Masq_F") do 
						(
							CheckExistBN = fn_SelectBodyBones EpBNList_Masq
							if (CheckExistBN != true) do ( format "BNError - %\n" lbx_Files.items[i] )
						)
						
						if ( CheckExistBN == true ) then
						(
							if ( i == 1) then ( exportfile Path_FBX selectedOnly:true )
							else ( exportfile Path_FBX #noPrompt selectedOnly:true )
							ExportStatus[1] +=  1
						) else (
							ExportStatus[2] +=  1
						)

				)
				p = lbx_Files.items.count as float
				k = i as float
				ProgressValue = 100. * k / p
				pb_Progress.value = ProgressValue
				lbl_Progress.text = ((ProgressValue as integer) as String) + " %"
				gc()
				freescenebitmaps()
				clearUndoBuffer()
			)
			EnableSceneRedraw() 
			if ( pb_Progress.value == 100 ) do (
				WorkTime_End = localTime
				TempBoard = "-------------------------\n!! FBX Export완료 !!\n-------------------------\n총 파일 수: " + lbl_Count.text + "\n - 성공: " + ExportStatus[1] as string + " / 실패: " +  ExportStatus[2] as string + "\n시작시각: " + WorkTime_Start as string + "\n완료시각: " + WorkTime_End as string
				messagebox TempBoard title:"알림"
				Dialog_StartFBX = true
			)
		)
	)
	
	on btn_Reset pressed do 
	( 
		edt_SrcPath.text = "-- select a source path --"
		edt_Path.text = "<Without Any Changes Files Save to Each Folder>"
		lbx_Files.items = #()
		chk_Sub.checked = true
		rdo_Output.state = 1
		ddl_SelTribe.selection = 1
		lbl_Count.text = "None"
		ProgressValue = 0
		pb_Progress.value = 0
	)
	
	on lbx_Files doubleclicked Itm do
	(
		local arr_Item = lbx_Files.items
		deleteItem arr_Item lbx_Files.selection
		lbx_Files.items = arr_Item
		lbl_Count.text = lbx_Files.items.count as string
	)
)

createDialog BlessM_Exporter