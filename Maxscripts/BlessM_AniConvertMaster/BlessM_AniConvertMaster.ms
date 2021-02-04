try(destroyDialog BlessMAniConvertMaster) catch()
rollout BlessMAniConvertMaster "BlessM AniConvertMaster   |   ver.1.0   |   by JYP" width:650 height:550
(
	local InfoPath = undefined
	local List_BNSkirtName = #(
		"BN_Skirt_F_01_T1", "BN_Skirt_F_02_T1", "BN_Skirt_F_03_T1", "BN_Skirt_F_04_T1",
		"BN_Skirt_FL_01_T1", "BN_Skirt_FL_02_T1", "BN_Skirt_FL_03_T1", "BN_Skirt_FL_04_T1",
		"BN_Skirt_FR_01_T1", "BN_Skirt_FR_02_T1", "BN_Skirt_FR_03_T1", "BN_Skirt_FR_04_T1",
		"BN_Skirt_B_01_T1", "BN_Skirt_B_02_T1", "BN_Skirt_B_03_T1", "BN_Skirt_B_04_T1",
		"BN_Skirt_BL_01_T1", "BN_Skirt_BL_02_T1", "BN_Skirt_BL_03_T1", "BN_Skirt_BL_04_T1",
		"BN_Skirt_BR_01_T1", "BN_Skirt_BR_02_T1", "BN_Skirt_BR_03_T1", "BN_Skirt_BR_04_T1",
		"BN_Skirt_L_01_T1", "BN_Skirt_L_02_T1", "BN_Skirt_L_03_T1", "BN_Skirt_L_04_T1",
		"BN_Skirt_R_01_T1", "BN_Skirt_R_02_T1", "BN_Skirt_R_03_T1", "BN_Skirt_R_04_T1"
	)
	local Selected_BNHairList = undefined
	local List_BNHairNameElf = #(
		"BN_Hair_B_1", "BN_Hair_B_2", "BN_Hair_B_3",
		"BN_Hair_UL_2", "BN_Hair_UL_3",
		"BN_Hair_UR_2", "BN_Hair_UR_3"
	)
	local List_BNHairNameMasq = #(
		"BN_Hair_B_1", "BN_Hair_B_2",
		"BN_Hair_UL_2", "BN_Hair_UL_3", "BN_Hair_UL_4",
		"BN_Hair_UR_2", "BN_Hair_UR_3", "BN_Hair_UR_4"
	)
	local ErrorBN_Elf = #( "Convert_BN_Skirt_BL_01_T1", "Convert_BN_Skirt_BL_02_T1", "Convert_BN_Skirt_BL_03_T1", "Convert_BN_Skirt_BL_04_T1" )
	local MaxList = #()
	local arr_BNSkirt = #()
	local arr_BNHair = #()
	local DNSkirt = "Bip01 Pelvis"
	local DNHair = "Bip01 Head"
	local SaveDataPath = "C:\BlessM_Tools\Animation_Copy\\"
	local SaveDataName = "AniConvertData.max"
	----------------------------------------------------------------------------------------
	-- User Interface
	----------------------------------------------------------------------------------------
	groupBox grp1 "Step1. Source" pos:[10,10] width:220 height:495 align:#left
	label lbl1 "+ Select" pos:[20,35] width:50 height:18 align:#left
	button btn_SrcFolder "Folder" pos:[70,30] width:45 height:24 align:#left
	button btn_SrcFile "File" pos:[115,30] width:35 height:24 align:#left
	button btn_SrcCurrent "Curr" pos:[150,30] width:35 height:24 align:#left
	editText edt_SrcPath "" pos:[16,60] width:204 height:20 text:"-- select a source path --"
	button btn_SrcOpen "Open" pos:[185,30] width:35 height:24 align:#left
	label lbl_SrcTotal "+ Total - 0" pos:[20,85] width:100 height:18 align:#left
	listBox lbx_Src "" pos:[20,103] width:200 height:30 align:#left
          
	groupBox grp2 "Step2. Target" pos:[240,10] width:220 height:495 align:#left
	label lbl2 "+ Select" pos:[250,35] width:50 height:22 align:#left
	button btn_TargetFolder "Folder" pos:[300,30] width:45 height:24 align:#left
	button btn_TargetFile "File" pos:[345,30] width:35 height:24 align:#left
	button btn_TargetCurrent "Curr" pos:[380,30] width:35 height:24 align:#left
	button btn_TargetOpen "Open" pos:[415,30] width:35 height:24 align:#left
	editText edt_TargetPath "" pos:[246,60] width:204 height:20 text:"-- select a target path --"
	label lbl_TargetTotal "+ Total - 0" pos:[250,85] width:100 height:18 align:#left
	listBox lbx_Target "" pos:[250,103] width:200 height:30 align:#left
                    
	groupBox grp3 "Step3. Setting" pos:[470,10] width:170 height:125 align:#left
	dropDownList ddl_SelChar "+ Character" pos:[480,35] width:150 height:41 items:#("-- select --", "Hum_M", "Elf_F", "Pant_M", "Masq_F") align:#left
	label lbl3 "+ Element" pos:[480,90] width:120 height:16 align:#left
	checkbox chk_Skirt "Skirt Ani" pos:[490,110] width:60 height:20 align:#left checked:true
	checkbox chk_Hair "Hair Ani" pos:[560,110] width:60 height:20 align:#left checked:true
	button btn_Convert "Convert" pos:[470,140] width:170 height:145 align:#left
	button btn_Reset "Reset" pos:[470,290] width:170 height:25 align:#left
 
	listBox lbx_Log "Log" pos:[470,320] width:170 height:12 align:#left
	progressBar pb_Convert "" pos:[10,510] width:630 height:12 align:#left color:(color 225 88 199)
	progressBar pb_Total "" pos:[10,525] width:630 height:12 align:#left color:(color 87 225 87)
	----------------------------------------------------------------------------------------
	-- Function
	----------------------------------------------------------------------------------------
	fn fn_getBatchInfo sectionStr keyStr = ( outStr = (getIniSetting InfoPath sectionStr keyStr); return outStr; )                                -- ToolSetting Load
	fn fn_setBatchInfo sectionStr keyStr valueStr = ( setIniSetting InfoPath sectionStr keyStr valueStr )
          
	fn fn_AddPath ReferPath =
	(
		local FileList = #()
		for filePathString in getfiles (ReferPath + "/*.max") do
		(
			append FileList filePathString
			local TempPath = ReferPath
			local TempCal = TempPath.count + 1
			local FileCount = FileList.count    
			FileList[FileCount] = replace FileList[FileCount] 1 TempCal ""
			local CheckCharMax = findstring FileList[FileCount] ".max"
			FileList[FileCount] =  replace FileList[FileCount] CheckCharMax 4 ""
		)
		return FileList
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
		FileInfo[2] = replace SelFileName 1 IndexSlash ""
		return FileInfo
	)
          
	fn fn_Align BNList ProcessNum =
	(
		select BNList
		local TargetedObj = #()
		-- Point? ? Object? name? ??? ??
		for p in 1 to BNList.count do
		(
			local TempName = replace BNList[p].name 1 8 ""
			local TempSymbol = "'"
			local TempText = execute("$" + TempSymbol + TempName + TempSymbol)
			append TargetedObj TempText
		)
		
		for p in 1 to BNList.count do
		(
			With animate on
			(
				if (ProcessNum == 1) then 
				(	
					local TempTM = TargetedObj[p].transform
					BNList[p].transform = TempTM	
					-- Case Elf_F
					if ( ddl_SelChar.selected == "Elf_F") do 
					(
						if ( (finditem ErrorBN_Elf BNList[p].name) != 0 ) do ( BNList[p].transform = (rotateXmatrix 180) * BNList[p].transform )
					)
				) else (
					if ( TargetedObj[p] != undefined ) then
					(
						local TempPos = TargetedObj[p].position
						in coordsys world (TargetedObj[p].rotation = BNList[p].rotation)
						TargetedObj[p].position = TempPos
					) else ( format "Not existing - % (Original BN)\n" BNList[p].name )
				)
			)
		)         
	)
          
	----------------------------------------------------------------------------------------
	-- Event
	----------------------------------------------------------------------------------------
	on BlessMAniConvertMaster  open do
	(
		InfoPath = (getDir #plugCfg) + "\\" + "BlessM_Info.ini"
		local iniEx = if ((getfiles InfoPath).count != 0 ) then (true) else (false)
		if ( iniEx == true ) do
		(
			try (setDialogPos BlessMAniConvertMaster (execute (fn_getBatchInfo "Info_AniConvertMaster" "Position" ) ) ) catch ()
		)                   
	)
          
	on BlessMAniConvertMaster  close do
	(
		fn_setBatchInfo "Info_AniConvertMaster" "Position" (getDialogPOs BlessMAniConvertMaster as string)
	)
          
	on btn_SrcFolder pressed do
	(
		local get_Folder = getSavePath initialDir:edt_SrcPath.text
		if get_Folder != undefined do
		(
			edt_SrcPath.text = get_Folder
			lbx_Src.items = fn_AddPath get_Folder
			lbl_SrcTotal.text =  "+ Total - " + (lbx_Src.items.count as string)                            
		)
	)
          
	on btn_SrcFile pressed do
	(
		local get_File = getOpenFilename filename:edt_SrcPath.text types:"max(*.max)|*.max"
		if ( get_File != undefined ) do
		(
			local FileInfo = fn_AddFile get_File
			edt_SrcPath.text = FileInfo[1]
			lbx_Src.items = #(FileInfo[2])
			lbl_SrcTotal.text =  "+ Total - 1"
		)
	)
          
	on btn_SrcCurrent pressed do
	(
		edt_SrcPath.text  = maxfilepath
		local SelFileName = maxfilename
		local CheckCharMax = findstring SelFileName ".max"
		SelFileName = replace SelFileName CheckCharMax 4 ""
		local arr_FileName = #(SelFileName)
		lbx_Src.items = arr_FileName
		lbl_SrcTotal.text =  "+ Total - 1"
	)
          
	on btn_SrcOpen pressed do ( ShellLaunch "explorer.exe" edt_SrcPath.text )
          
	on lbx_Src doubleclicked Itm do
	(
		local arr_Item = lbx_Src.items
		deleteItem arr_Item lbx_Src.selection
		lbx_Src.items = arr_Item
		lbl_SrcTotal.text = "+ Total - " + (lbx_Src.items.count as string)
	)
                    
	on btn_TargetFolder pressed do
	(
		local get_Folder = getSavePath initialDir:edt_TargetPath.text
		if get_Folder != undefined do
		(
			edt_TargetPath.text = get_Folder
			lbx_Target.items = fn_AddPath get_Folder
			lbl_TargetTotal.text =  "+ Total - " + (lbx_Target.items.count as string)                               
		)
	)
          
	on btn_TargetFile pressed do
	(
		local get_File = getOpenFilename filename:edt_TargetPath.text types:"max(*.max)|*.max"
		if ( get_File != undefined ) do
		(
			local FileInfo = fn_AddFile get_File
			edt_TargetPath.text = FileInfo[1]
			lbx_Target.items = #(FileInfo[2])
			lbl_TargetTotal.text =  "+ Total - 1"
		)
	)
          
	on btn_TargetCurrent pressed do
	(
		edt_TargetPath.text  = maxfilepath
		local SelFileName = maxfilename
		local CheckCharMax = findstring SelFileName ".max"
		SelFileName = replace SelFileName CheckCharMax 4 ""
		lbx_Target.items = #(SelFileName)
		lbl_TargetTotal.text =  "+ Total - 1"
	)
          
	on btn_TargetOpen pressed do ( ShellLaunch "explorer.exe" edt_TargetPath.text )
          
	on lbx_Target doubleclicked Itm do
	(
		local arr_Item = lbx_Target.items
		deleteItem arr_Item lbx_Target.selection
		lbx_Target.items = arr_Item
		lbl_TargetTotal.text = "+ Total - " + (lbx_Target.items.count as string)
	)
          
	on btn_Convert pressed do
	(
		local CheckStep = false
		if ( ddl_SelChar.selection == 1 ) then
		(
			messagebox "Please choose a character."
			CheckStep = false
		) else (
			lbx_Log.items = append lbx_Log.items "Check Character -- OK"
			CheckStep = true
		)
                    
		if ( CheckStep == true ) do
		(
			if ( chk_Skirt.checked == false and chk_Hair.checked == false ) then
			(
				messagebox "must select at least one item."
				CheckStep = false
			) else (
				lbx_Log.items = append lbx_Log.items "Check Element -- OK"
				CheckStep = true
			)
		)
                    
		if ( CheckStep == true ) do
		(
			if (lbx_Target.items.count == lbx_Src.items.count) then
			(
				CheckStep = true
				lbx_Log.items = append lbx_Log.items "File count -- OK"
			) else (
				messagebox "source and target file numbers do not match."
				CheckStep = false
			)
		)
		pb_Convert.value = 5.0		
		if ( CheckStep == true ) do
		(
			for i = 1 to lbx_Src.items.count do
			(
				arr_BNSkirt = #()
				arr_BNHair = #()
				lbx_Log.items = append lbx_Log.items ("+ " + lbx_Src.items[i])
				local SrcFile = edt_SrcPath.text + "\\" + lbx_Src.items[i] + ".max"
				loadMaxFile SrcFile quiet:true
				-- Step1. Check Additional Bone
				local CheckExist_BNSkirt = true
				if (chk_Skirt.checked == true ) do
				(
					for k=1 to List_BNSkirtName.count do
					(
						if (getnodebyname(List_BNSkirtName[k]) == undefined) do
						(
							lbx_Log.items = append lbx_Log.items ("Not existing - " + List_BNSkirtName[k])
							CheckExist_BNSkirt = false
						)
					)
				)
				local CheckExist_BNHair= true
				if (chk_Hair.checked == true ) do
				(
					if ( ddl_SelChar.selected == "Elf_F" ) do ( Selected_BNHairList = List_BNHairNameElf ) 
					if ( ddl_SelChar.selected == "Masq_F" ) do ( Selected_BNHairList = List_BNHairNameElf ) 
					
					for k=1 to Selected_BNHairList.count do
					(
						if (getnodebyname(Selected_BNHairList[k]) == undefined) do
						(
							lbx_Log.items = append lbx_Log.items ("Not existing - " + Selected_BNHairList[k] )
							CheckExist_BNHair = false
						)
					)  
				)
				pb_Convert.value = 10.0
				lbx_Log.items = append lbx_Log.items "Bone Check -- OK"
				-- Step2. Create Pointer
				if (chk_Skirt.checked == true and CheckExist_BNSkirt == true ) do
				(
					for k=1 to List_BNSkirtName.count do
					(
						local CurrBN = getnodebyname (List_BNSkirtName[k])
						local TempPoint = Point size:1 centermarker:false axistripod:true cross:false Box:false
						TempPoint.wirecolor = color 255 177 2
						TempPoint.name = "Convert_" + CurrBN.name
						TempPoint.transform = CurrBN.transform
						append arr_BNSkirt TempPoint
					)	
				)
				if (chk_Hair.checked == true and CheckExist_BNHair == true ) do
				(
					for k=1 to Selected_BNHairList.count do
					(
						local CurrBN = getnodebyname (Selected_BNHairList[k])
						local TempPoint = Point size:1 centermarker:false axistripod:true cross:false Box:false
						TempPoint.wirecolor = color 0 255 255
						TempPoint.name = "Convert_" + CurrBN.name
						TempPoint.transform = CurrBN.transform
						append arr_BNHair TempPoint
					)
				)
				pb_Convert.value = 15.0
				lbx_Log.items = append lbx_Log.items "Creaate Pointer -- OK"
				-- Step3. Bake SrcAnimation
				for k in animationRange.start to animationRange.end do
				(
					sliderTime = k
					if (chk_Skirt.checked == true and CheckExist_BNSkirt == true ) do ( fn_Align arr_BNSkirt 1 )
					if (chk_Hair.checked == true and CheckExist_BNHair == true ) do ( fn_Align arr_BNHair 1 )
					format "Checke1\n"
				)
				pb_Convert.value = 40.0
				-- Step4. Save BakedPointer
				local SavePoint = #()
				if (chk_Skirt.checked == true and CheckExist_BNSkirt == true ) do
				(
					SavePoint = SavePoint + arr_BNSkirt
					for k=1 to arr_BNSkirt.count do ( arr_BNSkirt[k] = arr_BNSkirt[k].name )
				)
				if (chk_Hair.checked == true and CheckExist_BNHair == true ) do
				(
					SavePoint = SavePoint + arr_BNHair
					for k=1 to arr_BNHair.count do ( arr_BNHair[k] = arr_BNHair[k].name )
				)
				format "Checke2\n"
				local CheckDir = doesFileExist SaveDataPath
				if (doesFileExist SaveDataPath == false )  do ( MakeDir SaveDataPath all:true )
				select SavePoint
				saveNodes selection (SaveDataPath + SaveDataName) quiet:true
				pb_Convert.value = 45.0
				lbx_Log.items = append lbx_Log.items "Bake Source -- OK"
				-- Step5. Load TargetFile
				loadMaxFile (edt_TargetPath.text + "\\" + lbx_Target.items[i] + ".max") quiet:true
				mergeMAXFile (SaveDataPath + SaveDataName)
				pb_Convert.value = 50.0
				lbx_Log.items = append lbx_Log.items "Load TargetFile -- OK"
				-- Step6. Align to Pointer
				if (chk_Skirt.checked == true and CheckExist_BNSkirt == true ) do ( for k=1 to arr_BNSkirt.count do ( arr_BNSkirt[k] = getnodebyname (arr_BNSkirt[k]) ) )
				if (chk_Hair.checked == true and CheckExist_BNHair == true ) do ( for k=1 to arr_BNHair.count do ( arr_BNHair[k] = getnodebyname (arr_BNHair[k]) ) )
				for k in animationRange.start to animationRange.end do
				(
					sliderTime = k
					if (chk_Skirt.checked == true and CheckExist_BNSkirt == true ) do ( fn_Align arr_BNSkirt 2 )
					if (chk_Hair.checked == true and CheckExist_BNHair == true ) do ( fn_Align arr_BNHair 2 )
				)
				pb_Convert.value = 95.0
				lbx_Log.items = append lbx_Log.items "Paste Animation -- OK"
				-- Step7. Delete Pointer
				try (delete arr_BNSkirt ) catch ()
				try (delete arr_BNHair ) catch ()
				-- Step8. Save Max
				if (lbx_Src.items.count != 1 ) do ( saveMaxFile (edt_TargetPath.text + "\\" + lbx_Target.items[i] + ".max") quiet:true )
				gc()
				
				pb_Convert.value = 100.0
				lbx_Log.items = append lbx_Log.items "-- Completed --"
				local ProcessNum = lbx_Src.items.count
				local CurrNum = 100.0 * i / ProcessNum
				pb_Total.value = CurrNum
			)
			pb_Total.value = 100.0
			messagebox "Completed!"
		)
		
	)
	
	on btn_Reset pressed do
	(
		edt_SrcPath.text = "-- select a source path --"
		lbl_SrcTotal.text =  "+ Total - 0"
		lbx_Src.items = #()
		edt_TargetPath.text = "-- select a target path --"
		lbl_TargetTotal.text =  "+ Total - 0"
		lbx_Target.items = #()	  
		ddl_SelChar.selection = 1
		chk_Skirt.checked = true
		chk_Hair.checked = true
		lbx_Log.items = #("-- Reset --")
		pb_Convert.value = 0
		pb_Total.value = 0
	)
)
createdialog BlessMAniConvertMaster