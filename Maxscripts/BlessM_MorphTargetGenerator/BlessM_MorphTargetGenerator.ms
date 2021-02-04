/*****************************************************************
	JYP_MorphTargetGenerator
	int.v.1.0 [2019-06-24] 
*****************************************************************/

try( destroyDialog MorphTargetGenerator ) catch()
rollout MorphTargetGenerator "Morph Gen / ver.1.0 / by JYP(JoycityTAD)" width:200 height:560
(
	local DeformObjName = #("DM_Hair", "DM_Head")
	local DeformMeshes = #()
	local DeformMeshTypes = #()
	local SourceMesh = undefined
	local DeformMesh_Src = undefined
	local DeformMesh_Target = undefined
	
	------------------------------------------------------------------------------------------------------------------------
	-- User Interface
	------------------------------------------------------------------------------------------------------------------------	
	groupBox 'grp1' "[ Step1. Select MeshType ]" pos:[5,5] width:190 height:45 align:#left
		radiobuttons 'rdo_MeshType' labels:#("Hair", "Head:LOD") pos:[35,25] offsets:#([0,0], [10,0])
	groupBox 'grp2' "[ Step2. Check Deform Mesh ]" pos:[5,55] width:190 height:160 align:#left
		button 'btn_CheckReferMesh' "Check" pos:[15,75] width:170 height:35 align:#left
		label 'lbl4' "+ Total: " pos:[15,120] width:40 height:15 align:#left
		label 'lbl_Total' "0" pos:[60,120] width:15 height:15 align:#left
		listBox 'lbx_Target' "" pos:[15,135] width:170 height:5 align:#left
	groupBox 'grp3' "[ Step3. Set Source Mesh ]" pos:[5,220] width:190 height:140 align:#left
		pickButton 'pbtn_SelSourceMesh' "Pick" pos:[15,240] width:170 height:35 align:#left
		groupBox 'grp_SetMorphType' "+ Set MorphType" pos:[15,280] width:170 height:70 align:#left
			label 'lb_SetSource' "- Source" pos:[30,300] width:120 height:15 align:#left
			dropDownList 'ddl_SourceType' "" pos:[80,298] width:95 height:25 align:#left
			label 'lbl_SetTarget' "- Target" pos:[30,325] width:120 height:15 align:#left
			dropDownList 'ddl_TargetType' "" pos:[80,323] width:95 height:25 align:#left
	groupBox 'grp4' "[ Step4. Create Mesh ]" pos:[5,365] width:190 height:190 align:#left
		button 'btn_SetMorph' "Set Morph Setting" pos:[15,385] width:170 height:35 enabled:true align:#left
		groupBox 'grp_MorphValue' "+ Morph Value" pos:[15,425] width:170 height:80 align:#left
			slider sld_CtrlMorph "" pos:[30,440] width:150 height:45 range:[0, 100, 0] type:#float enabled:false
			button btn_MorphMin " Source" pos:[25,480] width:50 height:20 highlightColor:(color 0 168 255) enabled:false
			label lbl_CtrlMorph "  0 %" pos:[85,485] width:48 height:15 enabled:false
			button btn_MorphMax " Target" pos:[125,480] width:50 height:20 highlightColor:(color 0 168 255) enabled:false	
		button 'btn_Complete' "Apply" pos:[15,510] width:170 height:35 enabled:true align:#left
	------------------------------------------------------------------------------------------------------------------------
	-- Event
	------------------------------------------------------------------------------------------------------------------------
	on btn_CheckReferMesh pressed do
	(
		clearSelection()
		select (execute("$" + DeformObjName[rdo_MeshType.state] + "_*"))
		DeformMeshes = selection as array
		local TempList = #()
		for i=1 to DeformMeshes.count do
		(
			local TempName = replace DeformMeshes[i].name 1 (DeformObjName[rdo_MeshType.state].count+1) ""
			append TempList TempName
		)
		lbx_Target.items = TempList
		lbl_Total.text = TempList.count as String
		sld_CtrlMorph.value = 0
		lbl_CtrlMorph.text = "0 %"
		ddl_TargetType.items = #()
	)
	
	on pbtn_SelSourceMesh picked OBJ do 
	(
		pbtn_SelSourceMesh.text = OBJ.name
		SourceMesh = OBJ
		local TempList = #()
		for i=1 to DeformMeshes.count do
		(
			local TempString = replace (DeformMeshes[i].name) 1 (DeformObjName[rdo_MeshType.state].count + 1) ""
			append TempList TempString
		)
		ddl_SourceType.items = TempList
		DeformMeshTypes = TempList
	)
	
	on ddl_SourceType selected Val do
	(
		local TempList = copy ddl_SourceType.items #nomap
		deleteItem TempList Val
		ddl_TargetType.items = TempList
	)
	
	on btn_SetMorph pressed do
	(
		select SourceMesh
		local TempMesh = #()
		local TempName = SourceMesh.name
		maxOps.cloneNodes SourceMesh cloneType:#copy newNodes:&TempMesh
		SourceMesh.isHidden = true
		SourceMesh = TempMesh[1]		
		SourceMesh.name = TempName + "_" + ddl_TargetType.selected
		-- Set DeformMesh (Morpher)
		DeformMesh_Src = execute("$" + DeformObjName[rdo_MeshType.state] + "_" + ddl_SourceType.selected)
		MP = Morpher()
		addModifier DeformMesh_Src MP
		DeformMesh_Target = execute("$" + DeformObjName[rdo_MeshType.state] + "_" + ddl_TargetType.selected) 
		WM3_MC_BuildFromNode DeformMesh_Src.morpher 1 DeformMesh_Target
		DeformMesh_Src.modifiers[#Morpher].Autoload_of_targets = 1
		TempTargetName = WM3_MC_GetTarget DeformMesh_Src.morpher  1
		WM3_MC_SetValue DeformMesh_Src.morpher 1 0.0	
		
		-- Set SourceMesh(Skin_Wrap)
		SourceMesh.position = DeformMesh_Src.position
		SW = Skin_Wrap()
		addModifier SourceMesh SW
		SourceMesh.modifiers[#Skin_Wrap].engine = 1
		SourceMesh.modifiers[#Skin_Wrap].falloff = 10
		SourceMesh.modifiers[#Skin_Wrap].distance = 4.5
		SourceMesh.modifiers[#Skin_Wrap].faceLimit = 8
		SourceMesh.modifiers[#Skin_Wrap].weightAllVerts = on
		SourceMesh.modifiers[#Skin_Wrap].meshlist = #(DeformMesh_Src)
		SourceMesh.modifiers[#Skin_Wrap].Blend = on
		SourceMesh.modifiers[#Skin_Wrap].blendDistance = 10
		
		sld_CtrlMorph.enabled = true
		btn_MorphMin.enabled = true
		btn_MorphMax.enabled = true
	)
	
	on btn_MorphMin pressed do
	(
		WM3_MC_SetValue DeformMesh_Src.morpher 1 0.0
		sld_CtrlMorph.value = 0
		lbl_CtrlMorph.text = "  0 %"
	)
	
	on btn_MorphMax pressed do
	(
		WM3_MC_SetValue DeformMesh_Src.morpher 1 100.0
		sld_CtrlMorph.value = 100
		lbl_CtrlMorph.text = "100 %"
	)
	
	on sld_CtrlMorph changed val do 
	(
		WM3_MC_SetValue DeformMesh_Src.morpher 1 val 
		lbl_CtrlMorph.text = ((val as integer) as string) + " %"
	)
	
	on btn_Complete pressed do 
	( 		
		ConvertTo SourceMesh Editable_Poly
		deleteModifier DeformMesh_Src 1
	)
)

createDialog MorphTargetGenerator