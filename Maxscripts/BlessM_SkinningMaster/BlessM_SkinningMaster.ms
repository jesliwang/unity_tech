/* 
	BlessM SkinningMaster by Jinyeong, Park (Joycity TAD)
	int.v.1.0 [2017-06-09]
	Required MAX 2017 or AVG for MAX 2017+
*/

try(destroyDialog BlessMSkinningMaster) catch()
rollout BlessMSkinningMaster "Skinning Master   |   ver.1.0   |   by JYP" width:320 height:250
(
	local InfoPath = undefined
	local FindName = #("Helmet", "Shoulder", "Upper", "Glove", "Belt", "Lower", "Boots")
	local CheckCharName = "CH"
	local ChangeCharName = "AN"
	local CheckStep = #(false,false,false,false) 
	local MeshName = ""
	local CollapsedMesh = undefined
	local TargetMeshList = #()
	----------------------------------------------------------------------------------------
	-- User Interface
	----------------------------------------------------------------------------------------
	groupBox grp_CheckMeshes "+ Check Meshes" pos:[10,10] width:300 height:160 align:#left
	listBox lbx_Mesh "" pos:[20,30] width:280 height:6 align:#left
	button btn_AddMeshes "Add Meshes" pos:[20,125] width:190 height:35 align:#left
	button btn_Reset "Reset" pos:[215,125] width:85 height:35 align:#left
	groupBox grp_SelProcess "+ Start Process" pos:[10,180] width:300 height:60 align:#left
	button btn_RunAllStep "Run All Step" pos:[20,200] width:280 height:30 align:#left
	
	----------------------------------------------------------------------------------------
	-- Function
	----------------------------------------------------------------------------------------
	fn fn_getBatchInfo sectionStr keyStr = ( outStr = (getIniSetting InfoPath sectionStr keyStr); return outStr; )                                -- ToolSetting Load
	fn fn_setBatchInfo sectionStr keyStr valueStr = ( setIniSetting InfoPath sectionStr keyStr valueStr )

	fn fn_Rename OBJList =
	(
		local AfterRename = #()
		for p=1 to OBJList.count do
		(
			select (getnodebyname(OBJList[p]))
			local CharName = ""
			append CharName $.name[1]
			append CharName $.name[2]
			if ( CharName == "CH" ) then ( $.name = replace $.name 1 2 ChangeCharName ) else ( format "Error Rename : %\n" $.name )
			append AfterRename $.name
			append TargetMeshList $
			for w=1 to FindName.count do
			(
				local CheckName = findstring $.name FindName[w]
				if ( CheckName != undefined ) do
				(
					MeshName = replace $.name (CheckName-1) (FindName[w].count+1) ""
				)
			)
		)
		return AfterRename
	)
	
	fn fn_SelPart SelName i =
	(
		upperSet = #($BaseSkin_Upper)
		gloveSet = #($BaseSkin_Glove)
		lowerSet = #($BaseSkin_Lower)
		bootsSet = #($BaseSkin_Boots)
		beltSet = #($BaseSkin_Belt)
		shoulderSet = #($BaseSkin_Shoulder)
		helmetSet = #($BaseSkin_Helmet)
		select i
		modPanel.addModToSelection (Skin_Wrap ()) ui:on
		SkinWrapMod = i.modifiers[#Skin_Wrap]
		if SelName == "Upper" do (SkinWrapMod.meshlist = upperSet)
		if SelName == "Glove" do (SkinWrapMod.meshList = gloveSet)
		if SelName == "Lower" do (SkinWrapMod.meshlist = lowerSet)
		if SelName == "Boots" do (SkinWrapMod.meshList = bootsSet)
		if SelName == "Belt" do (SkinWrapMod.meshlist = beltSet)
		if SelName == "Shoulder" do (SkinWrapMod.meshList = shoulderSet)
		if SelName == "Helmet" do (SkinWrapMod.meshList = helmetSet)
		SkinWrapMod.weightAllVerts = on
		SkinWrapMod.meshDeformOps.convertToSkin off
		i.modifiers[#Skin].bone_Limit = 4
	)
	
	fn fn_RemoveModIndex arr_sel ModifierName = 
	(
		max modify mode
		for chm in arr_sel do
		(
			if (chm.modifiers[2] != undefined )do
			(	
				modPanel.setCurrentObject chm.modifiers[2]
				if (modPanel.validModifier ModifierName) do
				(
					deleteModifier chm 2
					maxOps.CollapseNodeTo chm 2 off
				)
			)
		)
	)
	
	fn fn_Skinning arr_Sel =
	(
		select $*BaseSkin*
		local BaseSkinMesh = selection as array
		max modify mode
		for s = 1 to BaseSkinMesh.count do ( print BaseSkinMesh[s].name )
		local arr_MeshList = #()
		for p=1 to lbx_Mesh.items.count do ( append arr_MeshList (getnodebyname(lbx_Mesh.items[p])))
		for i in arr_MeshList do
		(
			local SelName = i.name
			local PhasingName = filterString SelName "_"
			if (PhasingName[7]!= undefined) then (SelName = PhasingName[7]) else (SelName = PhasingName[6])
			print SelName
			upperSet = #($BaseSkin_Upper)
			gloveSet = #($BaseSkin_Glove)
			lowerSet = #($BaseSkin_Lower)
			bootsSet = #($BaseSkin_Boots)
			beltSet = #($BaseSkin_Belt)
			shoulderSet = #($BaseSkin_Shoulder)
			helmetSet = #($BaseSkin_Helmet)
			select i
			modPanel.addModToSelection (Skin_Wrap ()) ui:on
			SkinWrapMod = i.modifiers[#Skin_Wrap]
			if SelName == "Upper" do (SkinWrapMod.meshlist = upperSet)
			if SelName == "Glove" do (SkinWrapMod.meshList = gloveSet)
			if SelName == "Lower" do (SkinWrapMod.meshlist = lowerSet)
			if SelName == "Boots" do (SkinWrapMod.meshList = bootsSet)
			if SelName == "Belt" do (SkinWrapMod.meshlist = beltSet)
			if SelName == "Shoulder" do (SkinWrapMod.meshList = shoulderSet)
			if SelName == "Helmet" do (SkinWrapMod.meshList = helmetSet)
			SkinWrapMod.weightAllVerts = on
			SkinWrapMod.meshDeformOps.convertToSkin off
			i.modifiers[#Skin].bone_Limit = 4
			gc()	
		)
		max modify mode
		for chm in arr_MeshList do
		(
			if (chm.modifiers[2] != undefined )do
			(	
				modPanel.setCurrentObject chm.modifiers[2]
				if (modPanel.validModifier (Skin_Wrap())) do
				(
					deleteModifier chm 2
					maxOps.CollapseNodeTo chm 2 off
				)
			)
		)	
	)
	
	fn fn_CollapseMesh arr_Sel =
	(
		local TargetMeshes = #()
		local CopiedMeshes
		local Sel_Meshes = #()	
		for p=1 to arr_Sel.count do ( append Sel_Meshes (getnodebyname(arr_Sel[p])))
		for i=1 to Sel_Meshes.count do
		(
			local TempCount = Sel_Meshes[i].modifiers.count
			if ( TempCount > 0 ) do
			(
				for j=1 to TempCount do
				(
					if ( classof Sel_Meshes[i].modifiers[j] == Skin) do ( append TargetMeshes Sel_Meshes[i] )
				)
			) 
		)
		maxOps.cloneNodes TargetMeshes cloneType:#copy newNodes:&CopiedMeshes #nodialog
		for i=1 to CopiedMeshes.count do
		(
			CopiedMeshes[i].name = TargetMeshes[i].name + "_copied"
			ConvertTo CopiedMeshes[i] Editable_Poly
		)
		local TempCount = CopiedMeshes.count
		for i=1 to TempCount do
		(
			if ( (TempCount - i) > 0 ) do (
				CopiedMeshes[1].EditablePoly.attach CopiedMeshes[TempCount-i+1] CopiedMeshes[1] 
			)
		)
		CollapsedMesh = CopiedMeshes[1]
		CollapsedMesh.name = MeshName
		CollapsedMesh.pivot = [0,0,0]
	)
	
	fn fn_SkinningCopy =
	(
		maxOps.CollapseNodeTo CollapsedMesh 1 off
		addModifier CollapsedMesh (Skin_Wrap())
		CollapsedMesh.modifiers[#Skin_Wrap].meshList = TargetMeshList
		CollapsedMesh.modifiers[#Skin_Wrap].distance = 0.001
		clearselection()
		select CollapsedMesh
		max modify mode
		CollapsedMesh.modifiers[#Skin_Wrap].ConvertToSkin On
		deleteModifier CollapsedMesh (CollapsedMesh.modifiers[#Skin_Wrap])
		delete TargetMeshList
	)
	
	
	----------------------------------------------------------------------------------------
	-- Event
	----------------------------------------------------------------------------------------
	on BlessMSkinningMaster  open do
	(
		InfoPath = (getDir #plugCfg) + "\\" + "BlessM_Info.ini"
		local iniEx = if ((getfiles InfoPath).count != 0 ) then (true) else (false)
		if ( iniEx == true ) do
		(
			try (setDialogPos BlessMSkinningMaster (execute (fn_getBatchInfo "Info_SkinningMaster" "Position" ) ) ) catch ()
		)                   
	)
          
	on BlessMSkinningMaster  close do ( fn_setBatchInfo "Info_SkinningMaster" "Position" (getDialogPOs BlessMSkinningMaster as string) )
	
	on btn_AddMeshes pressed do
	(
		local SelMeshes = selection as array
		if ( SelMeshes != #() ) then 
		(
			local SkinMeshes = #()
			for i=1 to SelMeshes.count do
			(
				local FindSkinName = undefined
				for k=1 to FindName.count do 
				( 
					FindSkinName = findstring SelMeshes[i].name FindName[k] 
					if ( FindSkinName != undefined ) do ( append SkinMeshes SelMeshes[i].name )	
				)
			)
			lbx_Mesh.items = SkinMeshes
		) else ( messagebox "Please Select Meshes!" )
	)
	
	on btn_Reset pressed do ( lbx_Mesh.items = #() )
	
	on lbx_Mesh doubleclicked Itm do
	(
		local arr_Item = lbx_Mesh.items
		deleteItem arr_Item lbx_Mesh.selection
		lbx_Mesh.items = arr_Item
	)
	
	on btn_RunAllStep pressed do
	(
		lbx_Mesh.items = fn_Rename lbx_Mesh.items
		fn_Skinning lbx_Mesh.items
		fn_CollapseMesh lbx_Mesh.items
		fn_SkinningCopy()
		messagebox "Completed!!"
	)
	
)
createdialog BlessMSkinningMaster
