/* 
	AniConvertMaster 
	int.v.1.0[2018-08-09] by JYP (Joycity TAD)
	Tested MAX 2017
*/
if (AniConvertMaster  != undefined ) do (destroyDialog AniConvertMaster )
rollout AniConvertMaster  "AniConvert Master | by JYP | ver.1.0" width:955 height:500
(
	------------------------------------------------------------------------------------------------------------------------
	-- Variable
	------------------------------------------------------------------------------------------------------------------------
	local InfoPath = "D:\[JYPTools]\BipBoneMatchList.ini"
	local iniFile = undefined
	local Angles = #( "0", "90", "180", "270" )
	local NewBiped = undefined
	local NewBipList = #()
	local SetBipList = #()
	local MatchLink = " ----------> "
	local BipRoot = undefined
	local NodeInfoList = #()
	local BipNodeTypes = #()
	local DMList = #()
	struct NodeInfo 
	(
		BipNode,
		BipType,
		BoneNode
	)
	------------------------------------------------------------------------------------------------------------------------
	-- User Interface
	------------------------------------------------------------------------------------------------------------------------	
	groupBox grp_Setup "1. Biped Creation"  pos:[10,10] width:165 height:495
		label lbl_BipName "Bip Name:" pos:[20,35] width:50 height:15 
		edittext edt_BipName "" pos:[70,32] width:95 height:20 text:"Bip002"
		label lbl_BipBar "-------------------------------------" pos:[20,53] width:145 height:15 enabled:false
		label lbl_Arm "Arm:" pos:[98,70] width:25 height:15
		checkbox chk_Arm "" pos:[144,70] width:15 height:16 checked:true	
		label lbl2 "Neck Links:" pos:[68,90] width:55 height:15
		label lbl3 "Spine Links:" pos:[65,110] width:61 height:15
		label lbl4 "Leg Links:" pos:[74,130] width:48 height:15
		label lbl5 "Tail Links:" pos:[75,150] width:50 height:15
		label lbl6 "Ponytail1 Links:" pos:[47,170] width:77 height:15
		label lbl7 "Ponytail2 Links:" pos:[47,190] width:76 height:15
		label lbl8 "Fingers:" pos:[83,210] width:42 height:15
		label lbl9 "Finger Links:" pos:[62,230] width:62 height:15
		label lbl10 "Toes:" pos:[95,250] width:29 height:15
		label lbl11 "Toe Links:" pos:[74,270] width:52 height:15
		spinner spn_Neck "" pos:[127,89] width:40 height:16 range:[1,5,1] type:#integer
		spinner spn_Spine "" pos:[127,109] width:40 height:16 range:[1,10,4] type:#integer 
		spinner spn_Leg "" pos:[127,129] width:40 height:16 range:[1,4,3] type:#integer
		spinner spn_Tail "" pos:[127,149] width:40 height:16 range:[0,10,0] type:#integer
		spinner spn_Pony1 "" pos:[127,169] width:40 height:16 range:[0,5,0] type:#integer
		spinner spn_Pony2 "" pos:[127,189] width:40 height:16 range:[0,5,0] type:#integer
		spinner spn_Fingers "" pos:[127,209] width:40 height:16 range:[0,5,5] type:#integer
		spinner spn_FingerLinks "" pos:[127,229] width:40 height:16 range:[1,3,3] type:#integer
		spinner spn_Toe "" pos:[127,249] width:40 height:16 range:[0,5,1] type:#integer
		spinner spn_ToeLinks "" pos:[127,269] width:40 height:16 range:[1,3,1] type:#integer
		label lbl12 "Props:" pos:[43,290] width:35 height:15
		checkbox chk_Prop1 "1" pos:[78,289] width:28 height:18 checked:false
		checkbox chk_Prop2 "2" pos:[109,289] width:28 height:18 checked:false
		checkbox chk_Prop3 "3" pos:[140,289] width:28 height:18 checked:false
		label lbl13 "Ankle Attach:" pos:[31,310] width:76 height:15
		spinner spn_Ankle "" pos:[102,309] width:65 height:16 range:[0,10,0.2]
		label lbl14 "Height:" pos:[61,330] width:39 height:15
		spinner spn_Height "" pos:[102,329] width:65 height:16 range:[0,500,150.0]
		label lbl15 "Triangle Pelvis:" pos:[77,350] width:75 height:15
		checkbox chk_TriPelvis "" pos:[154,349] width:15 height:16 checked:true
		label lbl16 "Triangle Neck:" pos:[81,370] width:71 height:15
		checkbox chk_TriNeck "" pos:[154,369] width:15 height:16 checked:false
		button btn_BipCreate "Create Biped" pos:[20,410] width:145 height:40
		button btn_BipRemove "Remove Biped" pos:[20,450] width:145 height:30
		
	groupBox grp_Sync "2. Matching" pos:[180,10] width:255 height:480
		button btn_BoneSet "Set Node" pos:[190,30] width:180 height:35
		button btn_Reset "Reset" pos:[375,30] width:50 height:35
		listBox lbx_BipList "" pos:[190,70] width:235 height:21
		groupBox grp_statistics "" pos:[190,350] width:235 height:40
			label lbl_SetBipTag "Biped:" pos:[200,366] width:40 height:15
			label lbl_SetBipNum "----------" pos:[240,366] width:50 height:15
			label lbl_SetBoneTag "Bone:" pos:[315,366] width:40 height:15
			label lbl_SetBoneNum "----------" pos:[355,366] width:50 height:15
		checkbox chk_DonotExistCom "" pos:[190,400] width:15 height:16 checked:false
		label lbl_DonotExistCom "Exclude 'COM'" pos:[210,401] width:100 height:18
		button btn_LoadList "Load" pos:[290,395] width:65 height:25
		button btn_SaveList "Save" pos:[360,395] width:65 height:25
		button btn_Match "Matching" pos:[190,425] width:235 height:40
		progressBar pgb_Match pos:[190,470] width:235 height:10
		
	groupBox grp_Axis "3. Pivot" pos:[440,10] width:250 height:485
		groupBox grp_Axis_Main "+ Main" pos:[450,30] width:230 height:165
			button btn_MainAll "All" pos:[460,50] width:47 height:20
			button btn_MainReset "Reset" pos:[508,50] width:47 height:20
			label lbl_RotX "X" pos:[540,80] width:46 height:15
			label lbl_RotY "Y" pos:[590,80] width:25 height:15
			label lbl_RotZ "Z" pos:[640,80] width:25 height:15
			label lbl_Axis_com "COM: " pos:[480,100] width:30 height:18
			checkbox chk_Change_com "" pos:[460,99] width:15 height:16 checked:false
			dropDownList ddl_AxisX_com "" pos:[520,96] width:50 height:22 items:Angles selection:1
			dropDownList ddl_AxisY_com "" pos:[570,96] width:50 height:22 items:Angles selection:1
			dropDownList ddl_AxisZ_com "" pos:[620,96] width:50 height:22 items:Angles selection:1
			label lbl_Axis_pelvis "Pelvis:" pos:[480,125] width:30 height:18
			checkbox chk_Change_pelvis "" pos:[460,124] width:15 height:16 checked:false
			dropDownList ddl_AxisX_pelvis "" pos:[520,121] width:50 height:22 items:Angles selection:1
			dropDownList ddl_AxisY_pelvis "" pos:[570,121] width:50 height:22 items:Angles selection:1
			dropDownList ddl_AxisZ_pelvis "" pos:[620,121] width:50 height:22 items:Angles selection:1
			label lbl_Axis_spine "Spine" pos:[480,150] width:30 height:18
			checkbox chk_Change_spine "" pos:[460,149] width:15 height:16 checked:false
			dropDownList ddl_AxisX_spine "" pos:[520,146] width:50 height:22 items:Angles selection:1
			dropDownList ddl_AxisY_spine "" pos:[570,146] width:50 height:22 items:Angles selection:1
			dropDownList ddl_AxisZ_spine "" pos:[620,146] width:50 height:22 items:Angles selection:1
			label lbl_Axis_neck "Neck" pos:[480,175] width:30 height:18
			checkbox chk_Change_neck "" pos:[460,174] width:15 height:16 checked:false
			label lbl_Axis_head "Head" pos:[595,175] width:30 height:18
			checkbox chk_Change_head "" pos:[575,174] width:15 height:16 checked:false
		groupBox grp_Axis_Arm "+ Arm" pos:[450,200] width:112 height:135
			button btn_Axis_ArmAll "All" pos:[460,220] width:47 height:20
			button btn_Axis_ArmReset "Reset" pos:[508,220] width:47 height:20
			label lbl_Axis_Clavicle "Calvicle" pos:[480,250] width:45 height:18
			checkbox chk_Change_Clavicle "" pos:[460,249] width:15 height:16 checked:false
			label lbl_Axis_UpperArm "UpperArm" pos:[480,270] width:50 height:18
			checkbox chk_Change_UpperArm "" pos:[460,269] width:15 height:16 checked:false
			label lbl_Axis_ForeArm "ForeArm" pos:[480,290] width:50 height:18
			checkbox chk_Change_ForeArm "" pos:[460,289] width:15 height:16 checked:false
			label lbl_Axis_Hand "Hand" pos:[480,310] width:37 height:18
			checkbox chk_Change_Hand "" pos:[460,309] width:15 height:16 checked:false
		groupBox grp_Axis_Leg "+ Leg" pos:[568,200] width:112 height:135
			button btn_Axis_LegAll "All" pos:[578,220] width:47 height:20
			button btn_Axis_LegReset "Reset" pos:[626,220] width:47 height:20
			label lbl_Axis_Thigh "Thigh" pos:[598,250] width:33 height:18
			checkbox chk_Change_Thigh "" pos:[578,249] width:15 height:16 checked:false
			label lbl_Axis_Calf "Calf" pos:[598,270] width:33 height:18
			checkbox chk_Change_Calf "" pos:[578,269] width:15 height:16 checked:false
			label lbl_Axis_Foot "Foot" pos:[598,290] width:37 height:18
			checkbox chk_Change_Foot "" pos:[578,289] width:15 height:16 checked:false
		groupBox grp_Axis_Addtional "+ Additional" pos:[450,340] width:230 height:85
			label lbl49 "Tail" pos:[480,360] width:23 height:18
			checkbox chk_Change_Tail "" pos:[460,359] width:15 height:16 checked:false
			label lbl50 "PonyTail1" pos:[480,380] width:50 height:18
			checkbox chk_Change_Pony1 "" pos:[460,379] width:15 height:16 checked:false
			label lbl51 "PonyTail2" pos:[480,400] width:50 height:18
			checkbox chk_Change_Pony2 "" pos:[460,399] width:15 height:16 checked:false
			label lbl52 "Prop1" pos:[595,360] width:50 height:18
			checkbox chk_Change_Prop1 "" pos:[575,359] width:15 height:16 checked:false
			label lbl53 "Prop2" pos:[595,380] width:50 height:18
			checkbox chk_Change_Prop2 "" pos:[575,379] width:15 height:16 checked:false
			label lbl54 "Prop3" pos:[595,400] width:50 height:18
			checkbox chk_Change_Prop3 "" pos:[575,399] width:15 height:16 checked:false
			button btn_EditAxis "Create Dummy" pos:[450,430] width:230 height:40
			button btn_RemoveAxis "Remove" pos:[450,470] width:115 height:20
			button btn_SelectAxis "Select" pos:[565,470] width:115 height:20
		
	groupBox grp_Animation "4. Animation" pos:[695,10] width:250 height:235
		groupBox grp_AnimRange "+ Range" pos:[705,30] width:230 height:45
			radiobuttons rbn_AnimRange labels:#("All     ", "Start-End     ", "Current") pos:[725,50]
		groupBox grp_AnimKey "+ Key" pos:[705,80] width:230 height:45
			radiobuttons rbn_AnimKey labels:#("Frame that key exists", "Every Frame") pos:[715,100]
		button btn_CopyAni "Copy Animation" pos:[705,135] width:230 height:40
		button btn_RemoveAni "Remove" pos:[705,175] width:230 height:20
		button btn_ExportAni "Export .Bip" pos:[705,195] width:230 height:40

	------------------------------------------------------------------------------------------------------------------------
	-- Function
	------------------------------------------------------------------------------------------------------------------------	
	function fn_ListupSingle TypeName =
	(
		TempNodeStruct = NodeInfo()
		TempNodeStruct.BipNode = biped.getNode $ (execute("#" + TypeName))
		TempNodeStruct.BipType = TypeName
		append NodeInfoList TempNodeStruct
	)
	
	function fn_ListupMulty TypeName LinkNum=
	(
		TempNodeStruct = NodeInfo()
		TempNodeStruct.BipNode = biped.getNode $ (execute("#" + TypeName)) link:LinkNum
		TempNodeStruct.BipType = TypeName
		append NodeInfoList TempNodeStruct
	)
	
	function fnGetAllChildren obj = (
		if ( obj == undefined ) do return undefined
		
		local tAllChildren = #()
		if ( obj.children.count != 0 ) do (
			for o in obj.children do (
				append tAllChildren o
				if ( o.children.count != 0 ) do (
					tAllChildren = tAllChildren +  (fnGetAllChildren o)		-- recursive
				)
			)
		)
		
		return tAllChildren
	)
	
	function fn_UpdateMatchList =
	(
		local TempList = #()
		local BoneNodeCount = 0
		for i=1 to NodeInfoList.count do
		(
			local TempBoneName = undefined
			if (NodeInfoList[i].BoneNode == undefined) then ( TempBoneName = "" ) else 
			( 
				TempBoneName = NodeInfoList[i].BoneNode.name 
				BoneNodeCount += 1
			)
			local TempString = NodeInfoList[i].BipNode.name + " -----> " + TempBoneName
			append TempList TempString
		)
		lbx_BipList.items = TempList
		lbl_SetBipNum.text = NodeInfoList.count as string
		lbl_SetBoneNum.text = BoneNodeCount as string
	)
	
	function fn_CheckList = ( for i=1 to NodeInfoList.count do ( if ( NodeInfoList[i].BoneNode == $ ) do ( return false ) ); return true; )
	function fn_FindNodeInList FindName = ( for i=1 to NodeInfoList.count do ( if ( NodeInfoList[i].BipType == FindName ) do ( return i) ); return 0; )
	function fn_FindBipInList FindName = ( for i=1 to NodeInfoList.count do ( if ( NodeInfoList[i].BipNode.name == FindName ) do ( return i) ); return 0; )
	function fn_FindBoneInList BoneName = ( for i=1 to NodeInfoList.count do ( if ( NodeInfoList[i].BoneNode.name == BoneName ) do ( return i) ); return 0; )
	
	function fn_NodeCountInList FindName = 
	(
		local FindCount = 0
		for i=1 to NodeInfoList.count do ( if ( NodeInfoList[i].BipType == FindName ) do ( FindCount += 1) )
		return FindCount
	)
	
	function fnGetLocalScaleXWorldPos BipObj = (
		tScale = biped.getTransform BipObj #scale
		tMatrix = matrix3 1
		tMatrix.pos = [tScale.x, 0, 0]
		tMatrix = tMatrix * BipObj.transform
		return tMatrix.pos
	)
	
	function fnGetChildByScalePos BipObj = 
	(
		if ( (classof BipObj) != Biped_Object ) do return undefined
		if ( BipObj.children.count == 1 ) do return BipObj.children[1]
		if ( BipObj.children.count == 0 ) do return undefined
		
		tDestPos = fnGetLocalScaleXWorldPos BipObj		-- 이 위치에 가까운 자식이 스케일의 기준이 되는 자식
		
		childDistArr = #()
		tIndex = 0
		for i = 1 to BipObj.children.count do (
			append childDistArr ( distance BipObj.children[i].transform.position tDestPos )
			tMinDist = amin childDistArr
			tIndex = finditem childDistArr tMinDist
		)
		return BipObj.children[tIndex]
	)
	
	function fnGetLocalTransform trParent trChild = -- 입력 값은 matrix3, 리턴 값은 matrix3,
	(
		return trChild*(inverse trParent)
	)
	
	function fn_AlignNode = 
	(
		undo on 
		(
			for i=1 to NodeInfoList.count do
			(
				BipRoot.controller.rootnode.controller.figuremode = true
				
				tChildForScale = fnGetChildByScalePos NodeInfoList[i].BipNode
				tOriginalScale = biped.getTransform NodeInfoList[i].BipNode #scale
				
				case of
				(
					( NodeInfoList[i].BipType == "com"):(
						NewBiped.controller.figuremode = true
						biped.setTransform NodeInfoList[i].BipNode #pos NodeInfoList[i].BoneNode.transform.pos false
						biped.setTransform NodeInfoList[i].BipNode #rotation NodeInfoList[i].BoneNode.transform.rotation false
					)
					( NodeInfoList[i].BipType == "pelvis"):(
						if ( chk_DonotExistCom.checked == true ) then 
						(
							local BipRoot = NodeInfoList[i].BipNode.controller.rootNode
							local PelIndex = fn_FindNodeInList "pelvis"
							biped.setTransform BipRoot #pos NodeInfoList[PelIndex].BoneNode.transform.pos false
							biped.setTransform BipRoot #rotation NodeInfoList[PelIndex].BoneNode.transform.rotation false
						) else ( biped.setTransform NodeInfoList[i].BipNode #rotation ( NodeInfoList[i].BoneNode.transform.rotation ) false )
						iLLeg = fn_FindNodeInList "lleg"
						iRLeg = fn_FindNodeInList "rleg"
						TargetScale = Distance NodeInfoList[iLLeg].BoneNode.transform.pos NodeInfoList[iRLeg].BoneNode.transform.pos
						NodeScale = biped.getTransform NodeInfoList[i].BipNode #scale
						biped.setTransform NodeInfoList[i].BipNode #scale [NodeScale.x, NodeScale.y, TargetScale] false
					)
					default: (
						if (NodeInfoList[i].BipType == "larm" or NodeInfoList[i].BipType == "rarm") then (
							
							local FindClavicle = findstring NodeInfoList[i].BipNode.name "Clavicle"
							if (FindClavicle != undefined ) then (
								NewBiped.controller.figuremode = false
								biped.setTransform NodeInfoList[i].BipNode #rotation NodeInfoList[i].BoneNode.transform.rotation false
								local SelArray = #()
								append SelArray NodeInfoList[i].BipNode
								biped.createCopyCollection NewBiped.controller "Col01"
								CopyCol= biped.getcopycollection NewBiped.controller 1
								BipPosture = biped.copyBipPosture NewBiped.controller CopyCol SelArray #snapAuto
								NewBiped.controller.figuremode = true
								biped.pasteBipPosture NewBiped.controller BipPosture false #pstdefault true true true false
								biped.deleteAllCopyCollections NewBiped.controller
								biped.setTransform NodeInfoList[i].BipNode #pos NodeInfoList[i].BoneNode.transform.Pos false
							) else (
									biped.setTransform NodeInfoList[i].BipNode #rotation NodeInfoList[i].BoneNode.transform.rotation false
									biped.setTransform NodeInfoList[i].BipNode #pos NodeInfoList[i].BoneNode.transform.pos false
							)
						) else (
							biped.setTransform NodeInfoList[i].BipNode #pos NodeInfoList[i].BoneNode.transform.Pos false
							biped.setTransform NodeInfoList[i].BipNode #rotation NodeInfoList[i].BoneNode.transform.rotation false
						)
						
						tChildIndex = fn_FindBipInList tChildForScale.name
						
						if ( tChildIndex != 0 ) do
						(
							tDist = Distance NodeInfoList[i].BoneNode.transform.position NodeInfoList[tChildIndex].BoneNode.transform.position
							OriginalScale = biped.getTransform NodeInfoList[i].BipNode #scale
							
							if ( NodeInfoList[i].BipType == "lleg" or NodeInfoList[i].BipType == "rleg") then 
							(
								
								local MaxCount = fn_NodeCountInList NodeInfoList[i].BipType
								local MaxBipNode = biped.getNode NodeInfoList[i].BipNode (execute ("#" + NodeInfoList[i].BipType)) link:MaxCount
								if ( NodeInfoList[i].BipNode == MaxBipNode ) then (
									tLocalDistM3 = fnGetLocalTransform NodeInfoList[i].BoneNode.transform NodeInfoList[tChildIndex].BoneNode.transform
									biped.setTransform NodeInfoList[i].BipNode #scale [tLocalDistM3.position.x, OriginalScale.y, OriginalScale.z] false	
								) else ( biped.setTransform NodeInfoList[i].BipNode #scale [tDist, OriginalScale.y, OriginalScale.z] false	)
							) else ( biped.setTransform NodeInfoList[i].BipNode #scale [tDist, OriginalScale.y, OriginalScale.z] false	)
						)
					)					
				)
			)
		)		
	)

	function fn_setInfo sectionStr keyStr valueStr = ( setIniSetting InfoPath sectionStr keyStr valueStr )
	function fn_getInfo sectionStr keyStr = ( outStr = (getIniSetting InfoPath sectionStr keyStr); return outStr; )
	
	function fn_GetAllChild OBJ = 
	(
		local AllChild = #()
		if ( Obj.children.count != 0 ) do 
		(
			for o in obj.children do 
			(
				append AllChild o
				if ( o.children.count != 0 ) do ( AllChild = AllChild + (fn_GetAllChild o) )
			)
		)
		return AllChild
	)
	
	function fn_SortHierarchy =
	(
		local AllChild = fn_GetAllChild BipRoot
		local AllBips = #()
		for i=1 to NodeInfoList.count do ( append AllBips NodeInfoList[i].BipNode )
		for i = AllChild.count to 1 by -1 do ( if ( (finditem AllBips AllChild[i] ) == 0 ) do ( AllChild = deleteitem AllChild i ) )
		local TempArray = #()
		for i=1 to AllChild.count do ( append TempArray NodeInfoList[(finditem AllBips Allchild[i])] )
		NodeInfoList = deepcopy TempArray
	)
	
	function fn_SetList =
	(
		fn_SortHierarchy()
		fn_UpdateMatchList()
		
	)
	
	function fn_ChangeAxis BoneIndex RotValue =
	(
		if ( classof NodeInfoList[BoneIndex].BoneNode != Point ) do
		(
			local AxisDummy = Point axistripod:on cross:off size:5
			AxisDummy.name = "DM_" + NodeInfoList[BoneIndex].BoneNode.name
			AxisDummy.parent = NodeInfoList[BoneIndex].BoneNode
			AxisDummy.transform = NodeInfoList[BoneIndex].BoneNode.transform
			NodeInfoList[BoneIndex].BoneNode = AxisDummy
			append DMList AxisDummy
		)
		in coordsys local rotate NodeInfoList[BoneIndex].BoneNode (angleaxis RotValue[1] [1,0,0])
		in coordsys local rotate NodeInfoList[BoneIndex].BoneNode (angleaxis RotValue[2] [0,1,0])
		in coordsys local rotate NodeInfoList[BoneIndex].BoneNode (angleaxis RotValue[3] [0,0,1])
	)
	
	function fn_ChangeAxisForClavicle BoneIndex BoneSide =
	(
		if ( classof NodeInfoList[BoneIndex].BoneNode != Point ) do
		(
			local AxisDummy = Point axistripod:on cross:off size:5
			AxisDummy.name = "DM_" + NodeInfoList[BoneIndex].BoneNode.name
			AxisDummy.parent = NodeInfoList[BoneIndex].BoneNode
			local RotType = fn_FindNodeInList "spine"
			local CountSpine = fn_NodeCountInList "spine"
			AxisDummy.rotation = NodeInfoList[(RotType + CountSpine - 1)].BoneNode.rotation
			AxisDummy.pos = NodeInfoList[BoneIndex].BoneNode.pos
			NodeInfoList[BoneIndex].BoneNode = AxisDummy
			append DMList AxisDummy
		)
		
		if (BoneSide == "Left" ) then 
		(
			in coordsys local rotate NodeInfoList[BoneIndex].BoneNode (angleaxis 180 [1,0,0])
			in coordsys local rotate NodeInfoList[BoneIndex].BoneNode (angleaxis 90 [0,1,0])
			AxisDummy.rotation.controller = LookAt_Constraint ()
			AxisDummy.rotation.controller.appendTarget NodeInfoList[BoneIndex+1].BoneNode 100
			AxisDummy.rotation.controller.upnode_world = off
			AxisDummy.rotation.controller.pickUpNode = NodeInfoList[(RotType + CountSpine - 1)].BoneNode
			AxisDummy.rotation.controller.upnode_ctrl = 1
			AxisDummy.rotation.controller.StoUP_axis = 2
			AxisDummy.rotation.controller.upnode_axis = 0
		) else (
			in coordsys local rotate NodeInfoList[BoneIndex].BoneNode (angleaxis 180 [1,0,0])
			in coordsys local rotate NodeInfoList[BoneIndex].BoneNode (angleaxis 270 [0,1,0])
			AxisDummy.rotation.controller = LookAt_Constraint ()
			AxisDummy.rotation.controller.appendTarget NodeInfoList[BoneIndex+1].BoneNode 100
			AxisDummy.rotation.controller.upnode_world = off
			AxisDummy.rotation.controller.pickUpNode = NodeInfoList[(RotType + CountSpine - 1)].BoneNode
			AxisDummy.rotation.controller.upnode_ctrl = 1
			AxisDummy.rotation.controller.StoUP_axisFlip = on
			AxisDummy.rotation.controller.StoUP_axis = 2
			AxisDummy.rotation.controller.upnode_axis = 0
		)
	)
	
	
	
	
	function fn_CheckNodeAxis =
	(
		local RotateValue = #(0,0,0)
		if (chk_Change_com.checked == true ) do (
			local BoneIndex = fn_FindNodeInList "com"
			RotateValue = #((ddl_AxisX_com.selected as integer), (ddl_AxisY_com.selected as integer), (ddl_AxisZ_com.selected as integer))
			fn_ChangeAxis BoneIndex RotateValue
		)
		if (chk_Change_pelvis.checked == true ) do (
			local BoneIndex = fn_FindNodeInList "pelvis"
			RotateValue = #((ddl_AxisX_pelvis.selected as integer), (ddl_AxisY_pelvis.selected as integer), (ddl_AxisZ_pelvis.selected as integer))
			fn_ChangeAxis BoneIndex RotateValue
		)
		if (chk_Change_spine.checked == true ) do (
			local BoneIndex = fn_FindNodeInList "spine"
			local CountSpine = fn_NodeCountInList "spine"
			RotateValue = #((ddl_AxisX_spine.selected as integer), (ddl_AxisY_spine.selected as integer), (ddl_AxisZ_spine.selected as integer))
			for i=1 to CountSpine do ( fn_ChangeAxis (BoneIndex + i - 1) RotateValue )
		)
		if (chk_Change_neck.checked == true ) do (
			local BoneIndex = fn_FindNodeInList "neck"
			local CountNeck = fn_NodeCountInList "neck"
			for i=1 to CountNeck do ( fn_ChangeAxis (BoneIndex + i - 1) RotateValue )
		)
		if (chk_Change_Clavicle.checked == true ) do (
			local BoneIndexL = fn_FindNodeInList "larm"
			fn_ChangeAxisForClavicle BoneIndexL "Left"
			local BoneIndexR = fn_FindNodeInList "rarm"
			fn_ChangeAxisForClavicle BoneIndexR "Right"
		)
		if (chk_Change_UpperArm.checked == true ) do (
			local BoneIndexL = fn_FindNodeInList "larm"
			fn_ChangeAxis (BoneIndexL + 1) RotateValue
			local BoneIndexR = fn_FindNodeInList "rarm"
			fn_ChangeAxis (BoneIndexR + 1) RotateValue
		)
		if (chk_Change_ForeArm.checked == true ) do (
			local BoneIndexL = fn_FindNodeInList "larm"
			fn_ChangeAxis (BoneIndexL + 2) RotateValue
			local BoneIndexR = fn_FindNodeInList "rarm"
			fn_ChangeAxis (BoneIndexR + 2) RotateValue
		)
		if (chk_Change_Hand.checked == true ) do (
			local BoneIndexL = fn_FindNodeInList "larm"
			fn_ChangeAxis (BoneIndexL + 3) RotateValue
			local BoneIndexR = fn_FindNodeInList "rarm"
			fn_ChangeAxis (BoneIndexR + 3) RotateValue
		)
		if (chk_Change_head.checked == true ) do (
			local BoneIndex = fn_FindNodeInList "head"
			fn_ChangeAxis BoneIndex RotateValue
		)		
		if (chk_Change_Thigh.checked == true ) do (
			local BoneIndexL = fn_FindNodeInList "lleg"
			fn_ChangeAxis BoneIndexL RotateValue
			local BoneIndexR = fn_FindNodeInList "rleg"
			fn_ChangeAxis BoneIndexR RotateValue
		)
		if (chk_Change_Calf.checked == true ) do (
			local BoneIndexL = fn_FindNodeInList "lleg"
			fn_ChangeAxis (BoneIndexL + 1) RotateValue
			local BoneIndexR = fn_FindNodeInList "rleg"
			fn_ChangeAxis (BoneIndexR + 1) RotateValue
		)
		if (chk_Change_Foot.checked == true ) do (
			local BoneIndexL = fn_FindNodeInList "lleg"
			fn_ChangeAxis (BoneIndexL + 2) RotateValue
			local BoneIndexR = fn_FindNodeInList "rleg"
			fn_ChangeAxis (BoneIndexR + 2) RotateValue
		)
		if (chk_Change_Tail.checked == true ) do (
			local BoneIndex = fn_FindNodeInList "tail"
			local CountTail = fn_NodeCountInList "tail"
			for i=1 to CountTail do ( fn_ChangeAxis (BoneIndex + i - 1) RotateValue )
		)
		if (chk_Change_Pony1.checked == true ) do (
			local BoneIndex = fn_FindNodeInList "pony1"
			local CountPony1 = fn_NodeCountInList "pony1"
			for i=1 to CountPony1 do ( fn_ChangeAxis (BoneIndex + i - 1) RotateValue )
		)
		if (chk_Change_Pony2.checked == true ) do (
			local BoneIndex = fn_FindNodeInList "pony2"
			local CountPony2 = fn_NodeCountInList "pony2"
			for i=1 to CountPony2 do ( fn_ChangeAxis (BoneIndex + i - 1) RotateValue )
		)
		if (chk_Change_Prop1.checked == true ) do (
			local BoneIndex = fn_FindNodeInList "prop1"
			fn_ChangeAxis BoneIndex RotateValue
		)	
		if (chk_Change_Prop2.checked == true ) do (
			local BoneIndex = fn_FindNodeInList "prop2"
			fn_ChangeAxis BoneIndex RotateValue
		)	
		if (chk_Change_Prop3.checked == true ) do (
			local BoneIndex = fn_FindNodeInList "prop3"
			fn_ChangeAxis BoneIndex RotateValue 
		)	
	)
		
	function fn_CountAniKeys BoneNode =
	(
		local CountFrame = #()
		local CountKeyNums = 0
		CountKeyNums = numKeys BoneNode.position.controller
		if ( CountKeyNums != 0 ) do 
		(
			for i=1 to CountKeyNums do
			(
				local KeyTime = getKeyTime BoneNode.position.controller i
				append CountFrame KeyTime
			)
		)
		CountKeyNums = numKeys BoneNode.rotation.controller
		if ( CountKeyNums != 0 ) do 
		(
			for i=1 to CountKeyNums do
			(
				local KeyTime = getKeyTime BoneNode.rotation.controller i
				append CountFrame KeyTime
			)
		)
		makeUniqueArray CountFrame
		return CountFrame
	)
	
	function fn_CopyAnimationKey BipType =
	(
		BoneIndex = fn_FindNodeInList BipType
		KeyFrames = #()
		local CountType = fn_NodeCountInList BipType
		for i=1 to CountType do 
		( 
			local BoneNode = NodeInfoList[BoneIndex + i - 1].BoneNode
			local CheckDM = undefined
			CheckDM = findstring NodeInfoList[BoneIndex + i - 1].BoneNode.name "DM_"
			if (CheckDM != undefined ) do 
			( 
				local DMNodeName = replace NodeInfoList[BoneIndex + i - 1].BoneNode.name 1 3 ""
				BoneNode = getNodebyName(DMNodeName)
			)
			KeyFrames = KeyFrames + (fn_CountAniKeys BoneNode)
		)		
		KeyFrames = makeUniqueArray KeyFrames
		keyFrames = sort KeyFrames
		if ( rbn_AnimRange.state == 2) do 
		(
			local TempArray = #()
			for i=1 to KeyFrames.count do ( if ( KeyFrames[i] >= animationRange.start and KeyFrames[i] <= animationRange.end ) do (append TempArray KeyFrames[i]) )
			KeyFrame = TempArray
		)
		for t=1 to KeyFrames.count do
		(
			slidertime = KeyFrames[t]
			for k=1 to CountType do (  biped.setTransform NodeInfoList[BoneIndex + k - 1].BipNode #rotation NodeInfoList[BoneIndex + k - 1].BoneNode.transform.rotation true )
		)
	)
	
	function fn_CopyAnimationEvey BipType =
	(
		BoneIndex = fn_FindNodeInList BipType
		local CountType = fn_NodeCountInList BipType
		for k=1 to CountType do 
		(	 
			local BoneNode = NodeInfoList[BoneIndex + k - 1].BoneNode
			for k=1 to CountType do (  biped.setTransform NodeInfoList[BoneIndex + k - 1].BipNode #rotation NodeInfoList[BoneIndex + k - 1].BoneNode.transform.rotation true )		
		)
	)
	
	function fn_CopyAnimationFrame =
	(
		if (chk_DonotExistCom.checked == false ) then 
		(
			BoneIndex = fn_FindNodeInList "com"
			biped.setTransform NodeInfoList[BoneIndex].BipNode #pos NodeInfoList[BoneIndex].BoneNode.transform.pos true
			biped.setTransform NodeInfoList[BoneIndex].BipNode #rotation NodeInfoList[BoneIndex].BoneNode.transform.rotation true
			biped.setKey NodeInfoList[BoneIndex].BipNode copyHor:true copyVer:true copyTrn:true
			BoneIndex = fn_FindNodeInList "pelvis"
			biped.setTransform NodeInfoList[BoneIndex].BipNode #pos NodeInfoList[BoneIndex].BoneNode.transform.pos true
			biped.setTransform NodeInfoList[BoneIndex].BipNode #rotation NodeInfoList[BoneIndex].BoneNode.transform.rotation true
		) else (
			BoneIndex = fn_FindNodeInList "pelvis"
			biped.setTransform NewBiped.controller.rootNode #pos NodeInfoList[BoneIndex].BoneNode.transform.pos true
			biped.setTransform NewBiped.controller.rootNode #rotation NodeInfoList[BoneIndex].BoneNode.transform.rotation true
			biped.setKey NewBiped.controller.rootNode true true true
		)
		fn_CopyAnimationEvey "spine"
		fn_CopyAnimationEvey "neck"
		fn_CopyAnimationEvey "head"
		if (chk_Arm.checked == true) do 
		(
			fn_CopyAnimationEvey "larm"
--			fn_CopyAnimationEvey "lfingers"
			fn_CopyAnimationEvey "rarm"
--			fn_CopyAnimationEvey "rfingers"
		)
		fn_CopyAnimationEvey "lleg"
		fn_CopyAnimationEvey "ltoes"
		fn_CopyAnimationEvey "rleg"
		fn_CopyAnimationEvey "rtoes"
		if (spn_Tail.value != 0 ) do ( for i=1 to spn_Tail.value do ( fn_CopyAnimationEvey "tail" i ) )
		if (spn_Pony1.value != 0 ) do ( for i=1 to spn_Pony1.value do ( fn_CopyAnimationEvey "pony1" i ) )
		if (spn_Pony2.value != 0 ) do ( for i=1 to spn_Pony2.value do ( fn_CopyAnimationEvey "pony2" i ) )
		if (chk_Prop1.checked == true ) do ( fn_CopyAnimationEvey "prop1" )
		if (chk_Prop2.checked == true ) do ( fn_CopyAnimationEvey "prop2" )
		if (chk_Prop3.checked == true ) do ( fn_CopyAnimationEvey "prop3" )	
	)
	------------------------------------------------------------------------------------------------------------------------
	-- Event
	------------------------------------------------------------------------------------------------------------------------	
	on chk_DonotExistCom changed State do
	(
		if (State == true) then
		(
			lbl_Axis_com.enabled = false
			ddl_AxisX_com.enabled = false
			ddl_AxisY_com.enabled = false
			ddl_AxisZ_com.enabled = false
			local DelIndex = fn_FindNodeInList "com"
			deleteItem NodeInfoList DelIndex
			
		) else (
			lbl_Axis_com.enabled = true
			ddl_AxisX_com.enabled = true
			ddl_AxisY_com.enabled = true
			ddl_AxisZ_com.enabled = true
			select NewBiped
			local TempNodeStruct = undefined
			TempNodeStruct = NodeInfo()		
			TempNodeStruct.BipNode = NewBiped.controller.rootNode
			BipRoot = NewBiped.controller.rootNode
			TempNodeStruct.BipType = "com"
			local TempArray = #()
			append TempArray TempNodeStruct
			NodeInfoList = TempArray + NodeInfoList
		)
		fn_UpdateMatchList()
		format "count: %\n" NodeInfoList.count
	)
	
	on btn_BipCreate pressed do
	(
		NewBiped = biped.createNew spn_Height.value -90 [0,0,spn_Height.value] \
		arms:chk_Arm.checked neckLinks:spn_Neck.value spineLinks:spn_Spine.value legLinks:spn_Leg.value tailLinks:spn_Tail.value \
		ponytail1Links:spn_Pony1.value ponytail2Links:spn_Pony2.value fingers:spn_Fingers.value fingerLinks:spn_FingerLinks.value toes:spn_Toe.value \
		toeLinks:spn_ToeLinks.value ankleAttach:spn_Ankle.value trianglePelvis:chk_TriPelvis.checked triangleNeck:chk_TriNeck.checked \
		prop1Exists:chk_Prop1.checked prop2Exists:chk_Prop2.checked prop3Exists:chk_Prop3.checked

		local TempChildrenArray = fnGetAllChildren NewBiped
		local TempBipRootName = NewBiped.name
		for i=1 to TempChildrenArray.count do
		(
			local TempNodeName = TempChildrenArray[i].name
			local TempIndex = findstring TempNodeName TempBipRootName
			TempChildrenArray[i].name = replace TempNodeName TempIndex TempBipRootName.count edt_BipName.text
		)
		NewBiped.name = edt_BipName.text		
		select (execute("$" + NewBiped.name + "*"))
		SelArray = selection as array
		
		-- Listup biped Node
		select NewBiped
		local TempNodeStruct = undefined
		TempNodeStruct = NodeInfo()		
		TempNodeStruct.BipNode = NewBiped.controller.rootNode
		BipRoot = NewBiped.controller.rootNode
			
			
		TempNodeStruct.BipType = "com"
		append NodeInfoList TempNodeStruct
			
			
		fn_ListupSingle "pelvis" 	
		for i=1 to spn_Spine.value do ( fn_ListupMulty "spine" i )
		for i=1 to spn_Neck.value do ( fn_ListupMulty "neck" i )
		if (chk_Arm.checked == true) do 
		(
			MaxNum = spn_Fingers.value * spn_FingerLinks.value
			for i=1 to 4 do ( fn_ListupMulty "larm" i )
			for i=1 to MaxNum do ( fn_ListupMulty "lfingers" i )
			for i=1 to 4 do ( fn_ListupMulty "rarm" i )			
			for i=1 to MaxNum do ( fn_ListupMulty "rfingers" i )
		)
		fn_ListupSingle "head"
		for i=1 to spn_Leg.value do ( fn_ListupMulty "lleg" i )
		MaxNum = spn_Toe.value * spn_ToeLinks.value
		for i=1 to MaxNum do ( fn_ListupMulty "ltoes" i )
		for i=1 to spn_Leg.value do ( fn_ListupMulty "rleg" i )
		for i=1 to MaxNum do (fn_ListupMulty "rtoes" i )
		
		if (spn_Tail.value != 0 ) do ( for i=1 to spn_Tail.value do ( fn_ListupMulty "tail" i ) )
		if (spn_Pony1.value != 0 ) do ( for i=1 to spn_Pony1.value do ( fn_ListupMulty "pony1" i ) )
		if (spn_Pony2.value != 0 ) do ( for i=1 to spn_Pony2.value do ( fn_ListupMulty "pony2" i ) )
		if (chk_Prop1.checked == true ) do ( fn_ListupSingle "prop1" )
		if (chk_Prop2.checked == true ) do ( fn_ListupSingle "prop2" )
		if (chk_Prop3.checked == true ) do ( fn_ListupSingle "prop3" )
		
		fn_UpdateMatchList()
	)
	
	on btn_BipRemove pressed do
	(
		try (
		local TempChildrenArray = fnGetAllChildren NewBiped
		delete TempChildrenArray
		NodeInfoList = #()
		fn_UpdateMatchList()
		chk_DonotExistCom.checked = false
		) catch ()
	)
	
	on btn_EditAxis pressed do
	(
		fn_CheckNodeAxis()
		fn_UpdateMatchList()
		messagebox "Dummies have been created.\nRotate in the right direction."
	)
	
	on btn_SelectAxis pressed do ( select DMList ) 
	on btn_RemoveAxis pressed do 
	( 
		for i=1 to DMList.count do
		(
			local BoneIndex = fn_FindBoneInList DMList[i].name
			local NodeName = replace DMList[i].name 1 3 ""
			NodeInfoList[BoneIndex].BoneNode = getNodeByName(NodeName)
		)
		delete DMList
		DMList = #()
		fn_UpdateMatchList()
	) 
	
	
	on btn_BoneSet pressed do
	(
		if (fn_CheckList() == false ) then ( messagebox "already existing!!" ) else (
			NodeInfoList[lbx_BipList.selection].BoneNode = $
			fn_UpdateMatchList()
		)
		lbx_BipList.selection = lbx_BipList.selection + 1
	)
	
	on lbx_BipList doubleClicked itm do
	(
		NodeInfoList[lbx_BipList.selection].BoneNode = undefined
		fn_UpdateMatchList()
	)
		
	on btn_Match pressed do 
	(
		try ( fn_AlignNode() ) catch (messagebox "Error occurred")
	)
	
	on btn_SaveList pressed do
	(
		for i=1 to NodeInfoList.count do
		(
			fn_setInfo (i as string) "BipNode" NodeInfoList[i].BipNode.name
			fn_setInfo (i as string) "BipType" NodeInfoList[i].BipType as string
			try
			(
				fn_setInfo (i as string) "BoneNode" NodeInfoList[i].BoneNode.name
			) catch (
				fn_setInfo (i as string) "BoneNode" "undefined"
			)
		)
		messagebox "Saved the Match List."
	)
	
	on btn_LoadList pressed do
	(
		try(
			for i=1 to NodeInfoList.count do
			(
				NodeInfoList[i].BipNode = getnodebyname (fn_getInfo (i as string) "BipNode")
				NodeInfoList[i].BipType = fn_getInfo (i as string) "BipType"
				NodeInfoList[i].BoneNode = getnodebyname (fn_getInfo (i as string) "BoneNode")
			)
			fn_UpdateMatchList()
			messagebox "Loaded the Match List."
		) catch()
	)
	
	on btn_MainAll pressed do 
	( 
		if (chk_DonotExistCom.checked == true ) then ( chk_Change_com.checked = false ) else (chk_Change_com.checked = true );
		chk_Change_pelvis.checked = true; chk_Change_spine.checked = true; chk_Change_neck.checked = true; chk_Change_head.checked = true;
	)
	on btn_MainReset pressed do ( chk_Change_com.checked = false; chk_Change_pelvis.checked = false; chk_Change_spine.checked = false; chk_Change_neck.checked = false; chk_Change_head.checked = false; )
	on btn_Axis_ArmAll pressed do ( chk_Change_Clavicle.checked = true; chk_Change_UpperArm.checked = true; chk_Change_ForeArm.checked = true; chk_Change_Hand.checked = true )
	on btn_Axis_ArmReset pressed do ( chk_Change_Clavicle.checked = false; chk_Change_UpperArm.checked = false; chk_Change_ForeArm.checked = false; chk_Change_Hand.checked = false )
	on btn_Axis_LegAll pressed do ( chk_Change_Thigh.checked = true; chk_Change_Calf.checked = true; chk_Change_Foot.checked = true; )
	on btn_Axis_LegReset pressed do ( chk_Change_Thigh.checked = false; chk_Change_Calf.checked = false; chk_Change_Foot.checked = false; )
	
	on btn_CopyAni pressed do
	(
		local BoneIndex = 0
		local AllAniFrames = #()
		local KeyFrames = #()
		NewBiped.controller.figuremode = false
		if (rbn_AnimRange.state != 3 ) then (
			if (rbn_AnimKey.state == 1 ) then (
				if (chk_DonotExistCom.checked == false ) then 
				(
					BoneIndex = fn_FindNodeInList "com"
					if (BoneIndex != 0 ) do ( KeyFrames = KeyFrames + (fn_CountAniKeys NodeInfoList[BoneIndex].BoneNode) )
					KeyFrames = makeUniqueArray KeyFrames
					keyFrames = sort KeyFrames
					if ( rbn_AnimRange.state == 2) do 
					(
						local TempArray = #()
						for i=1 to KeyFrames.count do ( if ( KeyFrames[i] >= animationRange.start and KeyFrames[i] <= animationRange.end ) do (append TempArray KeyFrames[i]) )
						KeyFrame = TempArray
					)
					for t=1 to KeyFrames.count do
					(
						slidertime = KeyFrames[t]
						biped.setTransform NodeInfoList[BoneIndex].BipNode #pos NodeInfoList[BoneIndex].BoneNode.transform.pos true
						biped.setTransform NodeInfoList[BoneIndex].BipNode #rotation NodeInfoList[BoneIndex].BoneNode.transform.rotation true
						biped.setKey NodeInfoList[BoneIndex].BipNode copyHor:true copyVer:true copyTrn:true
					)
					BoneIndex = fn_FindNodeInList "pelvis"
					if (BoneIndex != 0 ) do ( KeyFrames  = KeyFrames + (fn_CountAniKeys NodeInfoList[BoneIndex].BoneNode) )
					KeyFrames = makeUniqueArray KeyFrames
					keyFrames = sort KeyFrames
					if ( rbn_AnimRange.state == 2) do 
					(
						local TempArray = #()
						for i=1 to KeyFrames.count do ( if ( KeyFrames[i] >= animationRange.start and KeyFrames[i] <= animationRange.end ) do (append TempArray KeyFrames[i]) )
						KeyFrame = TempArray
					)
					for t=1 to KeyFrames.count do
					(
						slidertime = KeyFrames[t]
						biped.setTransform NodeInfoList[BoneIndex].BipNode #pos NodeInfoList[BoneIndex].BoneNode.transform.pos true
						biped.setTransform NodeInfoList[BoneIndex].BipNode #rotation NodeInfoList[BoneIndex].BoneNode.transform.rotation true
					)
				) else (
					KeyFrames = #()
					BoneIndex = fn_FindNodeInList "pelvis"
					if (BoneIndex != 0 ) do 
					( 
						local BoneNode = NodeInfoList[BoneIndex].BoneNode
						local CheckDM = undefined
						CheckDM = findstring NodeInfoList[BoneIndex].BoneNode.name "DM_"
						if (CheckDM != undefined ) do ( 
							local DMNodeName = replace NodeInfoList[BoneIndex].BoneNode.name 1 3 ""
							BoneNode = getNodebyName(DMNodeName)
						)
						KeyFrames  = KeyFrames + (fn_CountAniKeys BoneNode) 
					)
					KeyFrames = makeUniqueArray KeyFrames
					KeyFrames = makeUniqueArray KeyFrames
					keyFrames = sort KeyFrames
					if ( rbn_AnimRange.state == 2) do 
					(
						local TempArray = #()
						for i=1 to KeyFrames.count do ( if ( KeyFrames[i] >= animationRange.start and KeyFrames[i] <= animationRange.end ) do (append TempArray KeyFrames[i]) )
						KeyFrame = TempArray
					)
					for t=1 to KeyFrames.count do
					(
						slidertime = KeyFrames[t]
						biped.setTransform NewBiped.controller.rootNode #pos NodeInfoList[BoneIndex].BoneNode.transform.pos true
						biped.setTransform NewBiped.controller.rootNode #rotation NodeInfoList[BoneIndex].BoneNode.transform.rotation true
						biped.setKey NewBiped.controller.rootNode true true true
					)
				)
				fn_CopyAnimationKey "spine"
				fn_CopyAnimationKey "neck"
				fn_CopyAnimationKey "head"
				if (chk_Arm.checked == true) do 
				(
					fn_CopyAnimationKey "larm"
--					fn_CopyAnimationKey "lfingers"
					fn_CopyAnimationKey "rarm"
--					fn_CopyAnimationKey "rfingers"
				)
				fn_CopyAnimationKey "lleg"
				fn_CopyAnimationKey "ltoes"
				fn_CopyAnimationKey "rleg"
				fn_CopyAnimationKey "rtoes"
				if (spn_Tail.value != 0 ) do ( for i=1 to spn_Tail.value do ( fn_CopyAnimationKey "tail" i ) )
				if (spn_Pony1.value != 0 ) do ( for i=1 to spn_Pony1.value do ( fn_CopyAnimationKey "pony1" i ) )
				if (spn_Pony2.value != 0 ) do ( for i=1 to spn_Pony2.value do ( fn_CopyAnimationKey "pony2" i ) )
				if (chk_Prop1.checked == true ) do ( fn_CopyAnimationKey "prop1" )
				if (chk_Prop2.checked == true ) do ( fn_CopyAnimationKey "prop2" )
				if (chk_Prop3.checked == true ) do ( fn_CopyAnimationKey "prop3" )	
			) else (
				for t=animationRange.start to animationRange.end do
				(
					sliderTime = t
					fn_CopyAnimationFrame()
				)
			)
		) else (
			fn_CopyAnimationFrame()
		)
	)
	
	on btn_RemoveAni pressed do ( for i=1 to NodeInfoList.count do ( biped.deleteKeys NodeInfoList[i].BipNode #allKeys ) )
	
	on btn_ExportAni pressed do ( biped.saveBipFileDlg NewBiped.controller )
)
createdialog AniConvertMaster 