/* 
	Bless AniCopyMaster by Jinyeong, Park (Joycity TAD) with TK
	int.v.1.0 [2015-04-28] 
	int.v.1.2 [2015-06-24] 
	curr.v.2.0 [2017-05-26]
	curr.v.2.1 [2019-10-15]
	Required MAX 2014 or AVG for MAX 2014+
*/
 
try(destroyDialog BlessAniCopyMaster) catch()
rollout BlessAniCopyMaster "Bless AniCopyMaster   |  ver.2.1  |  TF-TA" width:345 height:855
(
	local InfoPath = undefined
	local MaxList = #()
	local MaxList_Dummy = #()
	local SaveDataPath = ""
	----------------------------------------------------------------------------------------
	-- User Interface
	----------------------------------------------------------------------------------------
	groupBox grp1 "Step1. Select Animation" pos:[10,10] width:325 height:455 align:#left
	editText edt_SelTargetPath "" pos:[15,32] width:310 height:20 text:"-- Please select a source path --"
	button btn_SetCurrSrc "Current" pos:[20,60] width:120 height:25
	button btn_AddSrcFolder "Add" pos:[145,60] width:120 height:25
	button btn_SrcOpen "Open" pos:[270,60] width:55 height:25 
	groupBox grp_SubElements "Elements to copy" pos:[20,90] width:305 height:45 align:#left
	checkbox chk_SceneInfo "" pos:[40,110] width:15 height:20 checked:true enabled:false
	label lbl_chk1 "Scene Infomation" pos:[60,112] width:90 height:15 align:#left enabled:false
	checkbox chk_BipData "" pos:[175,110] width:15 height:20 checked:true enabled:false
	label lbl_chk2 "Biped" pos:[195,112] width:50 height:15 align:#left enabled:false
	checkbox chk_BNData "" pos:[260,110] width:15 height:20 checked:false enabled:false
	label lbl_chk3 "Bone" pos:[280,112] width:50 height:15 align:#left enabled:false
	label lbl2 "Total ---" pos:[20,140] width:60 height:15 align:#left enabled:false
	label lbl21 "[[  Double Click - Delete Item in the List  ]]" pos:[90,140] width:200 height:15 align:#left enabled:false
	listBox lbx_Files "" pos:[20,160] width:305 height:20 align:#left enabled:false
	label lbl_BipName "+ Biped Name :" pos:[20,437] width:75 height:15 align:#left enabled:false
	editText edt_BipName"" pos:[95,435] width:65 height:20 text:"Bip01" enabled:false
	button btn_Reset "Reset" pos:[175,435] width:150 height:20 enabled:false
           
	groupBox grp2 "Step2. Select Rigging" pos:[10,470] width:325 height:90 align:#left
	editText edt_SelNewTarget "" pos:[15,495] width:310 height:20 text:"-- Please select a target model --" enabled:false
	button btn_SetCurrTarget "Current" pos:[20,525] width:150 height:25 enabled:false
	button btn_SelectTarget "Select" pos:[175,525] width:150 height:25 enabled:false
	
	groupBox grp3 "Step3. Select Save Path" pos:[10,565] width:325 height:90 align:#left 
	editText edt_SelSavePath "" pos:[15,590] width:310 height:17 text:"-- Select the path to save --" enabled:false
	button btn_SetCurrPath "Current" pos:[20,620] width:120 height:25 enabled:false
	button btn_SelectPath "Select" pos:[145,620] width:120 height:25 enabled:false
	button btn_OpenSave "Open" pos:[270,620] width:55 height:25 enabled:false
	
	groupBox grp4 "Step4. Set Filename" pos:[10,660] width:325 height:85 align:#left
	label lbl_EditFileName "+ Add Text :" pos:[20,687] width:100 height:15 align:#left enabled:false
	editText edt_EditFileName "" pos:[90,685] width:160 height:20 text:"" enabled:false
	radiobuttons rdo_SetName "" pos:[260,687] labels:#("P", "S") default:1 enabled:false
          
	--groupBox grp_FilenameFinal "" pos:[40,705] width:265 height:30 align:#left enabled:false
	label lbl_EditResult " [File Name].max" pos:[50,715] width:240 height:20 style_sunkenedge:true enabled:false
	label lbl3 "- Source Copy :" pos:[10,760] width:90 height:15 align:#left enabled:false
	progressbar pgb_SrcCopy pos:[90,760] width:205 height:14 enabled:false color:(color 225 87 143)
	label lbl_SrcPg " 00 %" pos:[300,760] width:90 height:15 align:#left enabled:false
	label lbl4 "- Target Paste :" pos:[10,780] width:90 height:15 align:#left enabled:false
	progressbar pgb_TargetPaste pos:[90,780] width:205 height:14 enabled:false color:(color 87 225 198)
	label lbl_TargetPg " 00 %" pos:[300,780] width:90 height:15 align:#left enabled:false
	button btn_AniCopyStart "Start" pos:[10,805] width:325 height:40 enabled:false
	----------------------------------------------------------------------------------------
	-- Function
	----------------------------------------------------------------------------------------
	fn fn_getBatchInfo sectionStr keyStr = ( outStr = (getIniSetting InfoPath sectionStr keyStr); return outStr; )			-- ToolSetting Load
	fn fn_setBatchInfo sectionStr keyStr valueStr = ( setIniSetting InfoPath sectionStr keyStr valueStr )
		   
	fn fn_MaxListReset = 
	(
		MaxList = #()
		MaxList_Dummy = #()
		lbx_Files.items = MaxList
		lbl2.text = "Total ---"
		edt_SelTargetPath.text = "-- Please select a source path --"
		btn_SetCurrSrc.enabled = true
		btn_AddSrcFolder.enabled = true
		chk_SceneInfo.enabled = false
		lbl_chk1.enabled = false
		chk_BipData.enabled = false
		lbl_chk2.enabled = false
		chk_BNData.enabled = false
		lbl_chk3.enabled = false
		lbl2.enabled = false
		btn_Reset.enabled = false
		lbx_Files.enabled = false
		lbl_BipName.enabled = false
		edt_BipName.enabled = false
		edt_BipName.text = "Bip01"
		edt_SelNewTarget.enabled = false
		btn_SetCurrTarget.enabled = false
		btn_SelectTarget.enabled = false
		edt_SelSavePath.enabled = false
		edt_SelSavePath.text = "-- Select the path to save --"
		btn_SetCurrPath.enabled = false
		btn_SelectPath.enabled = false
		btn_OpenSave.enabled = false
		edt_EditFileName.enabled = false
		edt_EditFileName.text = ""
		rdo_SetName.enabled = false
		lbl_EditResult.enabled = false
		lbl_EditResult.text = "[File Name].max"
        
		lbl3.enabled = false
		pgb_SrcCopy.enabled = false
		lbl_SrcPg.enabled = false
		lbl4.enabled = false
		pgb_TargetPaste.enabled = false
		lbl_TargetPg.enabled = false
		
		btn_AniCopyStart.enabled = false
	)

	fn fn_SaveAni =
	(
		MaxList = lbx_Files.items
		for i = 1 to MaxList.count do
		(
			local SaveAniPath = edt_SelTargetPath.text + "\\" + MaxList[i]
			loadMaxFile SaveAniPath quiet:true
			local InputBip = getnodebyname (edt_BipName.text)
			if ( InputBip != undefined ) then 
			(
				if (InputBip.controller.figureMode == true) do ( InputBip.controller.figureMode = false)
				SaveDataPath = "C:\BlessM_Tools\Animation_Copy\\"
				makeDir SaveDataPath all:true
				SaveBipPath = SaveDataPath + maxFileName
				--local SaveBipPath = (getDir #animations) + "\\" + maxFileName
				local FindExtention_A = findstring SaveBipPath ".max"

				-- Save Bip Data
				if(chk_BipData.checked == true) do
				(
					-- Collapse Biped Layers
					local BipLayerCheck = biped.Numlayers InputBip.controller
					if BipLayerCheck == 0 then 
					(
						try(biped.collapseMoveAllMode InputBip.controller) catch (print (maxfilename+": Error while Moveallmode Callapse"))
					) else ( 
						if BipLayerCheck > 1 then 
						(
							for j in 1 to BipLayerCheck.count do ( biped.collapseAtLayer InputBip.controller (j-1) )
							try ( biped.collapseMoveAllMode InputBip.controller ) catch ( print ( maxfilename+": Error while Moveallmode Callapse") )
						) else (
							biped.collapseAtLayer InputBip.controller 0
                            try(biped.collapseMoveAllMode InputBip.controller ) catch ( print (maxfilename+": Error while Moveallmode Callapse"))
						)
					)
                    local EditBipName = replace SaveBipPath FindExtention_A 4 ".bip"
                    biped.saveBipFile InputBip.controller EditBipName
				)
                -- Save Bone Data
                local BoneNumber = 0
                If ( chk_BNData.checked == true ) do 
				(
                    select $*
					local SelectionArray = selection as array
					local List_SceneBN = #()
					for j=1 to SelectionArray.count do
					(
						if ( classOf SelectionArray[j] == BoneGeometry ) do 
						(
							BoneNumber += 1
							append List_SceneBN SelectionArray[j]
							try
							(
								with animate on
								(
									addNewKey SelectionArray[j].controller animationRange.start
									addNewKey SelectionArray[j].controller animationRange.end
								)
							) catch()
						)
					)
					select List_SceneBN
					local Path_Xaf = replace SaveBipPath FindExtention_A 4 ".xaf"
					LoadSaveAnimation.saveAnimation Path_Xaf selection #("") #("") animatedTracks:true includeConstraints:true keyableTracks:true SaveSegment:true segInterval:(interval animationRange.start      animationRange.end )
				)
				-- Save Animation Info
				if(chk_SceneInfo.checked == true) do
				(
					local Info_FrameRate = framerate                                                                                                  
					local Info_StartFrame = animationRange.start                                                                         
					local Info_EndFrame = animationRange.end                                                                
					local BipPos = biped.getTransform InputBip #pos    
					local EditTxtName = replace SaveBipPath FindExtention_A 4 ".txt"
					local InfoFile = createFile EditTxtName
					format "%\n" Info_FrameRate      to:InfoFile                                                                                                                    -- Frame Rate
					format "%\n" Info_StartFrame      to:InfoFile                                                                                                                    -- Start Frame
					format "%\n" Info_EndFrame       to:InfoFile                                                                                                                    -- End Frame
					format "%\n" BoneNumber to:InfoFile                                                                                                                            -- BN_Number
					close InfoFile
				)                                                     
			) else ( format "Biped Name Error\n")
			p = MaxList.count as float
			k = i as float
			ProgressValue = 100. * k / p
			pgb_SrcCopy.value = ProgressValue
			lbl_SrcPg.text = ((ProgressValue as integer) as String) + " %"
			gc()
		)
	)

	fn fn_SaveMax = 
	(
		local LoadList = lbx_Files.items
		for j = 1 to LoadList.count do 
		(
			loadMaxFile edt_SelNewTarget.text quiet:true
			local GetTargetFile = SaveDataPath + "\\" + LoadList[j]
			local FindExtentionMAX = findstring GetTargetFile ".max"
			GetTargetFile = replace GetTargetFile FindExtentionMAX 4 ""

			-- Load Infomation
			local AnimationInfo = #()
			if(chk_SceneInfo.checked == true) do
			(
				local GetTxtFile = GetTargetFile + ".txt"
				local Open_Text = openFile GetTxtFile
				while not eof Open_Text do
				(
					local Temp = readLine Open_Text
					append AnimationInfo Temp
				)
				close Open_Text
				framerate = AnimationInfo[1] as integer     
			)
			-- Load Bip
			if(chk_BipData.checked == true) do
			(
				local GetBipFile = GetTargetFile + ".bip"
				local OutputBip = getnodebyname (edt_BipName.text)
				local CheckBipName = select OutputBip
				if (CheckBipName != undefined ) then 
				(
					OutputBip.controller.figureMode = false     
					biped.loadBipFile OutputBip.controller GetBipFile
				) else ( format "BipedName Error!! %\n" maxFilename )
			)
			
			if(chk_SceneInfo.checked == true) do
			(
				animationRange = interval (AnimationInfo[2] as time) (AnimationInfo[3] as time)
			)

			-- Load Bone
			if ( chk_BNData.checked == true ) do 
			(
				select $*
				local SelectionArray = selection as array
				local List_SceneBN = #()
				local BoneNumber = 0
				select List_SceneBN
				local Open_Bone = GetTargetFile + ".xaf" 
				local PasteFrm = AnimationInfo[2] as time
				LoadSaveAnimation.loadAnimation Open_Bone selection  insert:false relative:false insertTime:PasteFrm stripLayers:false
			)
			-- Save Max
			local FindExtentionMAX = findstring LoadList[j] ".max"
			SaveMaxFilename = replace LoadList[j] FindExtentionMAX 4 ""
			local Path_SaveMAX = ""
			if ( rdo_SetName.state == 1 ) then 
			(
				Path_SaveMAX = edt_SelSavePath.text + edt_EditFileName.text + SaveMaxFilename + ".max"
			) else (
				Path_SaveMAX = edt_SelSavePath.text + SaveMaxFilename + edt_EditFileName.text + ".max"
			)
			saveMaxFile Path_SaveMAX
			
			p = LoadList.count as float
			k = j as float
			ProgressValue = 100. * k / p
			pgb_TargetPaste.value = ProgressValue
			lbl_TargetPg.text = ((ProgressValue as integer) as String) + " %"
			gc()
		)          
	)
	----------------------------------------------------------------------------------------
	-- Event
	----------------------------------------------------------------------------------------
	on BlessAniCopyMaster open do
	(
		InfoPath = (getDir #plugCfg) + "\\" + "BlessM_Info.ini"
		local iniEx = if ((getfiles InfoPath).count != 0 ) then (true) else (false)
		if ( iniEx == true ) do 
		( 
			setDialogPos BlessAniCopyMaster (execute (fn_getBatchInfo "Info_AniCopyMaster" "Position"))
			try ( edt_SelTargetPath.text = ((fn_getBatchInfo "Info_AniCopyMaster" "SelectedAnimation" ) as string ) ) catch ()
			try ( edt_SelNewTarget.text = ((fn_getBatchInfo "Info_AniCopyMaster" "SelectedNewTarget" ) as string ) ) catch ()
		)		
	)

	on BlessAniCopyMaster close do
	(
		fn_setBatchInfo "Info_AniCopyMaster" "Position" (getDialogPOs BlessAniCopyMaster as string)
		fn_setBatchInfo "Info_AniCopyMaster" "SelectedAnimation" (edt_SelTargetPath.text as string)
		fn_setBatchInfo "Info_AniCopyMaster" "SelectedNewTarget" (edt_SelNewTarget.text as string)
	)
	
	on btn_SetCurrSrc pressed do 
	(
		try
		(
			fn_MaxListReset()
			local TempFilePath = replace maxFilePath (maxFilePath.count) 1 ""
			edt_SelTargetPath.text = TempFilePath 
			append TempFilePath maxFileName
			append MaxList TempFilePath
			MaxList_Dummy = MaxList
			local TempCurrList = #()
			append TempCurrList maxFileName
			lbx_Files.items = TempCurrList
			lbl2.text = "Total --- 1"
			chk_SceneInfo.enabled = true
			lbl_chk1.enabled = true
			chk_BipData.enabled = true
			lbl_chk2.enabled = true
			chk_BNData.enabled = true
			lbl_chk3.enabled = true
			lbl2.enabled = true
			btn_Reset.enabled = true
			lbx_Files.enabled = true              
			lbl_BipName.enabled = true
			edt_BipName.enabled = true
			btn_SetCurrTarget.enabled = true
			btn_SelectTarget.enabled = true
			edt_SelSavePath.text = TempFilePath 
		) catch( messageBox "Please save your current scene!")
	)
   
	
	on lbx_Files doubleClicked itm do -- 리스트박스 항목 삭제
	(
		deleteItem MaxList_Dummy lbx_Files.selection 
		lbx_Files.items = MaxList_Dummy
		lbl2.text = "Total --- " +  (lbx_Files.items.count as string)
	)
	
	
	on btn_AddSrcFolder pressed do
	(
		local get_Folder = getSavePath initialDir:edt_SelTargetPath.text
		if get_Folder != undefined do 
		(
			fn_MaxListReset()
			edt_SelTargetPath.text = get_Folder
			for filePathString in getfiles (get_Folder + "/*.max") do 
			( 
				append MaxList filePathString
				append MaxList_Dummy filePathString
				local Temp_Path = get_Folder
				local TempCal = Temp_Path.count + 1
				local FileCount = MaxList_Dummy.count     
				MaxList_Dummy[FileCount] = replace MaxList_Dummy[FileCount] 1 TempCal ""            
				lbx_Files.items =MaxList_Dummy
			)
			lbl2.text = "Total --- " +  (lbx_Files.items.count as string)
			chk_SceneInfo.enabled = true
			lbl_chk1.enabled = true
			chk_BipData.enabled = true
			lbl_chk2.enabled = true
			chk_BNData.enabled = true
			lbl_chk3.enabled = true
			lbl2.enabled = true
			btn_Reset.enabled = true
			lbx_Files.enabled = true   
			lbl_BipName.enabled = true
			edt_BipName.enabled = true
			btn_SetCurrTarget.enabled = true
			btn_SelectTarget.enabled = true
			edt_SelSavePath.text = get_Folder
		)
	)
	
	on btn_SrcOpen pressed do ( ShellLaunch "explorer.exe" edt_SelTargetPath.text )
	
	on btn_Reset pressed do 
	( 
		fn_MaxListReset() 
		edt_SelNewTarget.text = "-- Please select a target model --"
	)
           
	on btn_SetCurrTarget pressed do 
	(
		try
		(
			edt_SelNewTarget.text = maxFilePath + maxFileName
			edt_SelNewTarget.enabled = true
			btn_AniCopyStart.enabled = true
			btn_SetCurrPath.enabled = true
			btn_SelectPath.enabled = true
			btn_OpenSave.enabled = true
		) catch ( messageBox "Please check your current scene." )
	)
           
	on btn_SelectTarget pressed do 
	(
		try
		(
			edt_SelNewTarget.text = getOpenFileName caption:"Open A Reference File" types:"MAX(*.max) | *.max" filename:edt_SelNewTarget.text
			edt_SelNewTarget.enabled = true
			btn_AniCopyStart.enabled = true
			btn_SetCurrPath.enabled = true
			btn_SelectPath.enabled = true
			btn_OpenSave.enabled = true
		) catch( messageBox "Please check the file selection.")
	)
	
	on btn_SetCurrPath pressed do
	(
		edt_SelSavePath.text = maxFilePath
		edt_SelSavePath.enabled = true
		edt_EditFileName.enabled = true
		rdo_SetName.enabled = true
		lbl_EditResult.enabled = true
		btn_AniCopyStart.enabled = true
		lbl3.enabled = true
		pgb_SrcCopy.enabled = true
		lbl_SrcPg.enabled = true
		lbl4.enabled = true
		pgb_TargetPaste.enabled = true
		lbl_TargetPg.enabled = true
	)	
           
	on btn_SelectPath pressed do
	(
		local get_Folder = getSavePath initialDir:edt_SelSavePath.text
		edt_SelSavePath.text =  get_Folder + "\\"
		edt_SelSavePath.enabled = true
		edt_EditFileName.enabled = true
		rdo_SetName.enabled = true
		lbl_EditResult.enabled = true
		btn_AniCopyStart.enabled = true
		lbl3.enabled = true
		pgb_SrcCopy.enabled = true
		lbl_SrcPg.enabled = true
		lbl4.enabled = true
		pgb_TargetPaste.enabled = true
		lbl_TargetPg.enabled = true
	)
	
	on btn_OpenSave pressed do ( ShellLaunch "explorer.exe" edt_SelSavePath.text )
		
	on edt_EditFileName changed txt do
	(
		if ( rdo_SetName.state == 1 ) then 
		(
			lbl_EditResult.text = edt_EditFileName.text + "[File Name].max"
		) else (
			lbl_EditResult.text = "[File Name]" + edt_EditFileName.text + ".max"
		)
	)
           
	on rdo_SetName changed Val do
	(
		if ( Val == 1 ) then
		(
			lbl_EditResult.text = edt_EditFileName.text + "[File Name].max"
		) else (
			lbl_EditResult.text = "[File Name]" + edt_EditFileName.text + ".max"
		)
	)
           
	on btn_AniCopyStart pressed do
	(
		fn_SaveAni()
		format "Save Complete!!\n"
		fn_SaveMax()
		messagebox "Complete!!"
	)          
	
) createdialog BlessAniCopyMaster
