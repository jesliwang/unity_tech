/* 
	SkinWeightEditMaster by Jinyeong, Park
	int.v.1.0 [2018-06-28] 
	Tested in MAX 2017
*/
try( destroyDialog SkinWeightEditMaster ) catch()
rollout SkinWeightEditMaster "SkinEditMaster | ver.1.0" width:200 height:560
(
	----------------------------------------------------------------------
	-- Variable
	----------------------------------------------------------------------	
	local ObjSkin
	local arr_OverVert = #()
	local arr_OverBoneNum = #()
	local arr_ListDropdown = #()
	local arr_ddList = #()
	local arr_VertList = #()
	local arr_VertList_String = #()
	local list_WeightBoneName = #()
	local list_WeightBoneID = #()
	local list_WeightValue = #()
	local list_WeightText = #()
	local SelVertex
	local SelWeight = 1

	----------------------------------------------------------------------
	-- User Interface
	----------------------------------------------------------------------	
	label lbl1 "+ Bone Affect Limit : " pos:[10,10] width:115 height:20 align:#left
	spinner spn_WeightCount "" pos:[120,9] width:64 height:16 range:[0,20,3] type:#integer scale:1 align:#left
	button btn_Check "Check" pos:[15,28] width:170 height:30 align:#left
	
	groupBox grp1 "+ Skin Vertices" pos:[5,65] width:190 height:267 align:#left 
	dropDownList ddl_VerticesNum "" pos:[15,85] width:170 items:#("----------") 
	label lbl_VertNum "------------" pos:[15,110] width:60 height:20
	checkbox chk_Zoom "" pos:[100,112] width:10 height:10 checked:false
	label lbl_Zoom "Zoom Extend" pos:[115,110] width:70 height:20 
	listBox lbx_ViewVertices "" pos:[15,125] width:170 height:15 align:#left 
	
	groupBox grp2 "+ Set Weight" pos:[5,335] width:190 height:220 align:#left 
	button btn_SkinWT_000 "0" pos:[15,355] width:22 height:25 
	button btn_SkinWT_010 ".1" pos:[39,355] width:22 height:25 
	button btn_SkinWT_025 ".25" pos:[63,355] width:24 height:25 
	button btn_SkinWT_050 ".5" pos:[89,355] width:22 height:25 
	button btn_SkinWT_075 ".75" pos:[113,355] width:24 height:25
	button btn_SkinWT_090 ".9" pos:[139,355] width:22 height:25
	button btn_SkinWT_100 "1" pos:[163,355] width:22 height:25
	button btn_SkinWT_SetVal "Set Weight" pos:[15,380] width:70 height:25 
	spinner spn_SetWeight "" pos:[87,385] width:43 height:16 range:[0.0,1.0,0.1] type:#float scale:0.1 
	button btn_SkinWT_Plus "+" pos:[133,380] width:26 height:25 
	button btn_SkinWT_Minus "-" pos:[159,380] width:26 height:25 

	listBox lbx_SkinWT_Vertices "" pos:[15,410] width:170 height:6 align:#left 
	label lbl_WeightLabel "Total: " pos:[20,500] width:30 height:20 
	label lbl_WeightCalc "" pos:[50,500] width:50 height:20 
	button btn_SkinWT_Confirm "Confirm" pos:[15,520] width:170 height:30 enabled:false
	
	----------------------------------------------------------------------
	-- Function
	----------------------------------------------------------------------
	fn fn_RoundFloat Val Dp = --rounds a float to a set number of decimal places
	(
		mul = 10.0^Dp
		a = floor((Val * mul) + 0.5) / mul
		return a
	)
	
	fn fn_CheckWeight SkinMod SelVert =
	(
		local WeightBoneNum = skinOps.getVertexWeightCount SkinMod SelVert
		if (WeightBoneNum > spn_WeightCount.value) do 
		( 
			append arr_OverVert SelVert
			append arr_OverBoneNum WeightBoneNum
		)
	)	
	
	fn fn_SelDDListItem SelNum =
	(
		arr_VertList = #()
		arr_VertList_String = #()
		local TempNum = arr_ddList[SelNum]
		for i=1 to arr_OverBoneNum.count do
		(
			if (arr_OverBoneNum[i] == TempNum) do
			(
				append arr_VertList arr_OverVert[i]
				append arr_VertList_String (arr_OverVert[i] as string)
			)
		)
	)

	fn fn_ReadWeightInfo Selitem =
	(
		list_WeightValue = #()
		list_WeightBoneName = #()
		list_WeightBoneID = #()
		list_WeightText = #()
		
		skinOps.selectVertices ObjSkin arr_VertList[Selitem] 
		if (chk_Zoom.checked == true ) do ( max zoomext sel )
		local WeightCount = skinOps.GetVertexWeightCount ObjSkin arr_VertList[Selitem]
		for i=1 to WeightCount do
		(
			local TempWeight = skinOps.GetVertexWeight ObjSkin arr_VertList[Selitem] i
			append list_WeightValue TempWeight
			local TempBoneID = skinOps.GetVertexWeightBoneID ObjSkin arr_VertList[Selitem] i
			append list_WeightBoneID TempBoneID
			local TempBoneName = skinOps.GetBoneName ObjSkin TempBoneID 0
			append list_WeightBoneName TempBoneName
			append list_WeightText (((fn_RoundFloat TempWeight 3 )as String) + " : " + (TempBoneName as String))
		)
		lbx_SkinWT_Vertices.items = list_WeightText
		
		local TempSum = 0.0
		for i=1 to list_WeightText.count do
		(
			local TempA = list_WeightText[i]
			local TempNum = findstring TempA " : "
			local Templength = TempA.count - TempNum + 1
			local TempValue = replace TempA TempNum Templength ""
			TempSum += TempValue as float
		)
		lbl_WeightCalc.text = (TempSum as String)
		skinOps.SelectBone ObjSkin list_WeightBoneID[1]
	)
	
	fn fn_EditWeight SetVal =			-- Only Edit 'ListBox Value'
	(
		local Temp_SelBone = skinOps.GetSelectedBone ObjSkin
		Temp_SelBone = skinOps.GetBoneName ObjSkin Temp_SelBone 0
		local Temp_List = lbx_SkinWT_Vertices.items
		-- Get WeightBone List : Name
		local Temp_ListName = #()
		for i=1 to Temp_List.count do
		(
			
			local Temp_ViewString = Temp_List[i]
			local TempNumStart = findstring Temp_ViewString " : "
			local Temp_ViewBoneName = replace Temp_ViewString 1 (TempNumStart+2) ""
			append Temp_ListName Temp_ViewBoneName
		)
		-- Check Selected Bone
		-- If ,not existing, add to the list.
		local CheckID = findItem Temp_ListName Temp_SelBone
		if ( CheckID == 0 ) then 
		(
			if ( SetVal == "Plus" ) do ( SetVal = spn_SetWeight.value )
			if ( SetVal != "Minus" )  do
			( 
				local TempItem = (SetVal as String) + " : " + Temp_SelBone
				append Temp_List TempItem
				lbx_SkinWT_Vertices.items = Temp_List
				lbx_SkinWT_Vertices.selection = Temp_List.count
			)
		) else (
			local Temp_ViewString = Temp_List[lbx_SkinWT_Vertices.selection]
			local TempNumStart = findstring Temp_ViewString " : "
			local Temp_ViewBoneName = replace Temp_ViewString 1 (TempNumStart+2) ""
			
			if ( SetVal == "Plus" ) do (
				local Templength = Temp_ViewString.count - TempNumStart + 1
				local TempValue = replace Temp_ViewString TempNumStart Templength ""
				SetVal = (TempValue as float) + spn_SetWeight.value
			)
			local CheckMinus = false
			if ( SetVal == "Minus" ) do (
				local Templength = Temp_ViewString.count - TempNumStart + 1
				local TempValue = replace Temp_ViewString TempNumStart Templength ""
				local TempMinus = (TempValue as float) - spn_SetWeight.value
				SetVal = TempMinus
				CheckMinus = true
			)
			Temp_ViewString = (SetVal as String) + " : " + Temp_ViewBoneName
			Temp_List[lbx_SkinWT_Vertices.selection] = Temp_ViewString
			if ( (CheckMinus == true) and (SetVal < 0.0) ) do ( Temp_List = deleteItem Temp_List SelWeight )
			lbx_SkinWT_Vertices.items = Temp_List
		)
		-- Sum of weights
		local TempSum = 0.0
		for i=1 to Temp_List.count do
		(
			local TempA = Temp_List[i]
			local TempNum = findstring TempA " : "
			local Templength = TempA.count - TempNum + 1
			local TempValue = replace TempA TempNum Templength ""
			TempSum += TempValue as float
		)
		TempSum = fn_RoundFloat TempSum 3 
		lbl_WeightCalc.text = (TempSum as String)
		if ( TempSum > 0.999 and TempSum < 1.001 ) then ( btn_SkinWT_Confirm.enabled = true ) 
		else ( btn_SkinWT_Confirm.enabled = false )
	)
	
	fn fn_EditMinus =
	(
		local Temp_SelBone = skinOps.GetSelectedBone ObjSkin
		Temp_SelBone = skinOps.GetBoneName ObjSkin Temp_SelBone 0
		local Temp_List = lbx_SkinWT_Vertices.items
		-- Get WeightBone List : Name
		local Temp_ListName = #()
		for i=1 to Temp_List.count do
		(
			
			local Temp_ViewString = Temp_List[i]
			local TempNumStart = findstring Temp_ViewString " : "
			local Temp_ViewBoneName = replace Temp_ViewString 1 (TempNumStart+2) ""
			append Temp_ListName Temp_ViewBoneName
		)
		local CheckID = findItem Temp_ListName Temp_SelBone
		if ( CheckID != 0 ) do
		(
			Temp_List = deleteItem Temp_List SelWeight
			lbx_SkinWT_Vertices.items = Temp_List
		)
		-- Sum of weights
		local TempSum = 0.0
		for i=1 to list_WeightText.count do
		(
			local TempA = list_WeightText[i]
			local TempNum = findstring TempA " : "
			local Templength = TempA.count - TempNum + 1
			local TempValue = replace TempA TempNum Templength ""
			TempSum += TempValue as float
		)
		TempSum = fn_RoundFloat TempSum 3 
		lbl_WeightCalc.text = (TempSum as String)
		if ( TempSum > 0.999 and TempSum < 1.001 ) then ( btn_SkinWT_Confirm.enabled = true ) 
		else ( btn_SkinWT_Confirm.enabled = false )			
	)
	----------------------------------------------------------------------
	-- Event
	----------------------------------------------------------------------
	on btn_Check pressed do
	(
		if ( $ != undefined ) then
		(
			max modify mode
			ObjSkin = $.modifiers[#skin]
			if ( ObjSkin != undefined ) then 
			(
				arr_OverVert = #()
				arr_OverBoneNum = #()
				subobjectLevel = 1
				TotalVertNum = skinOps.getNumberVertices ObjSkin
				skinOps.RemoveZeroWeights ObjSkin
				for i=1 to TotalVertNum do ( fn_CheckWeight ObjSkin i )			
				arr_ddList = arr_OverBoneNum
				arr_ddList = makeUniqueArray arr_ddList
				arr_ddList = sort arr_ddList
				if (arr_ddList.count != 0 ) then
				(
					local TempArray = #()
					for i=1 to arr_ddList.count do ( append TempArray ( "Bone Affect : " + arr_ddList[i] as string) )
					ddl_VerticesNum.items = TempArray
					fn_SelDDListItem 1
					lbx_ViewVertices.items = arr_VertList_String
					lbl_VertNum.text = arr_VertList_String.count as string
					fn_ReadWeightInfo 1
				) else ( messagebox "No vertices exceeding." )
				
			) else ( messagebox "Check Modifier[Skin]!!!" )
		) else ( messagebox "Select SkinObject!!!" )
	)
	
	on ddl_VerticesNum selected SelNum do
	(
		fn_SelDDListItem SelNum 
		lbx_ViewVertices.items = arr_VertList_String
		lbl_VertNum.text = arr_VertList_String.count as string
	)
	
	on lbx_ViewVertices selected Selitem do
	(
		SelVertex = arr_VertList[Selitem] 
		fn_ReadWeightInfo SelItem
	)
	
	
	on lbx_SkinWT_Vertices selected SelItem do 
	( 
		SelWeight = SelItem 
		skinOps.SelectBone ObjSkin list_WeightBoneID[SelItem]
	)
	on btn_SkinWT_000 pressed do ( fn_EditWeight 0.0 )
	on btn_SkinWT_010 pressed do ( fn_EditWeight 0.1 )
	on btn_SkinWT_025 pressed do ( fn_EditWeight 0.25 )
	on btn_SkinWT_050 pressed do ( fn_EditWeight 0.5 )
	on btn_SkinWT_075 pressed do ( fn_EditWeight 0.75 )
	on btn_SkinWT_090 pressed do ( fn_EditWeight 0.9 )
	on btn_SkinWT_100 pressed do ( fn_EditWeight 1.0 )
	on btn_SkinWT_SetVal pressed do ( fn_EditWeight spn_SetWeight.value)
	on btn_SkinWT_Plus pressed do ( fn_EditWeight "Plus" )
	on btn_SkinWT_Minus pressed do ( fn_EditWeight "Minus" )	
	on btn_SkinWT_Confirm pressed do
	(
		local Temp_List = lbx_SkinWT_Vertices.items
		local Temp_ListName = #()
		local Temp_ListValue = #()
		for i=1 to Temp_List.count do
		(
			local TempNumStart = findstring Temp_List[i] " : "
			local Temp_ViewBoneName = replace Temp_List[i] 1 (TempNumStart+2) ""
			append Temp_ListName Temp_ViewBoneName
			local Temp_Viewlength = Temp_List[i].count +1 - TempNumStart
			local Temp_ViewWeight = replace Temp_List[i] TempNumStart Temp_Viewlength ""
			append Temp_ListValue ( Temp_ViewWeight as float)
		)
		local AllListBoneIDs = #()
		local AllListBoneNames = #()
		for i=1 to (skinOps.GetNumberBones ObjSkin) do
		(
			append AllListBoneNames ( skinOps.GetBoneName ObjSkin i 0)
			append AllListBoneIDs (skinOps.GetBoneIDByListID ObjSkin i)
		)
		local ListBoneIDs = #()
		for i=1 to Temp_ListName.count do
		(
			local CheckArrNum = finditem AllListBoneNames Temp_ListName[i]
			append ListBoneIDs CheckArrNum
		)
		skinOps.ReplaceVertexWeights ObjSkin SelVertex ListBoneIDs Temp_ListValue
		fn_ReadWeightInfo lbx_ViewVertices.selection
	)
)
createdialog SkinWeightEditMaster

