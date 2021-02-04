(
	
	local CurrFile = maxFilePath + maxFileName
	local CheckStep1 = false
	local Check_BNWeapon = undefined
	local BN_Breast = #($BN_breast_R_02, $BN_breast_L_02, $Root)
	local BN_BreastNewName = #("BN_breast_R_end", "BN_breast_L_end", "Root_end")
	local BN_WeaponName = #("Bip01 L Hand", "BN_Weapon_L", "Bip01 R Hand", "BN_Weapon_R")
	local AnimRange = #(undefined, undefined)

	-- Save Source Animation Range
	AnimRange[1] = animationRange.start
	AnimRange[2] = animationRange.end
	-- Create EndBone
	for i=1 to 3 do
	( 
		if (BN_Breast[i] != undefined and getNodeByName BN_BreastNewName[i] == undefined) do
		(
			BN_Breast[i].boneEnable = false
			BN_Breast[i].boneEnable = true
			local ParentLength = BN_Breast[i].length
			local BN_NewUpper = BoneSys.createBone [0,0,0] [0,1,0] [0,0,1]
			BN_NewUpper.width = 1
			BN_NewUpper.height = 1
			
			BN_NewUpper.rotation = BN_Breast[i].rotation
			BN_NewUpper.pos = BN_Breast[i].pos + (BN_Breast[i].transform.row1 * BN_Breast[i].length)
			BN_NewUpper.parent = BN_Breast[i]
				
			BN_NewUpper.name = BN_BreastNewName[i]
		)
		
	)
	-- Modify Bone Properties
	select $*
	local List_SceneObjAll = selection as array
	local List_SceneBN = #()
	for i=1 to List_SceneObjAll.count do
	(
		if (classOf List_SceneObjAll[i] == BoneGeometry ) do 
		( 
			append List_SceneBN List_SceneObjAll[i] 
			if (List_SceneObjAll[i].boneEnable == true) do
			(
				List_SceneObjAll[i].boneEnable = false
				List_SceneObjAll[i].boneEnable = true
			)
		)
	)
	
	-- Create WeaponPosition Dummy
	local BN_Weapon = #()
	local Point_BNWeapon = #()
	for i=1 to BN_WeaponName.count do ( append BN_Weapon (GetNodeByName BN_WeaponName[i]) )
	format "BN_Weapon: %\n" BN_Weapon
	if ((finditem BN_Weapon undefined) == 0 ) then 
	(
		for k=1 to BN_Weapon.count do
		(
			local TempPoint = Point size:1 centermarker:false axistripod:true cross:false Box:false
			TempPoint.wirecolor = color 255 177 2
			TempPoint.name = "TempPoint_" + BN_Weapon[k].name
			TempPoint.transform = BN_Weapon[k].transform
			append Point_BNWeapon TempPoint
		)
		Point_BNWeapon[1].parent = BN_Weapon[1]
		Point_BNWeapon[3].parent = BN_Weapon[3]
		
		Point_BNWeapon[2].parent = Point_BNWeapon[1]
		Point_BNWeapon[4].parent = Point_BNWeapon[3]

		for p=animationRange.start to animationRange.end do
		(
			With animate on
			(
				slidertime = p
				
				Point_BNWeapon[2].position = BN_Weapon[2].position
				Point_BNWeapon[2].rotation = BN_Weapon[2].rotation
				Point_BNWeapon[4].position = BN_Weapon[4].position
				Point_BNWeapon[4].rotation = BN_Weapon[4].rotation
			)
		)
		Check_BNWeapon = true
	) else (
		Check_BNWeapon = false
	)
	
	
	-- Save EditedScene
	saveMaxFile (CurrFile + "_Step1") quiet:true
	
	-- Reset Max UnitSetup
	resetMaxFile #noprompt
	units.MetricType = #Centimeters
	units.SystemType = #Centimeters
	units.SystemScale  = 1.0
	units.DisplayType = #Metric
	units.MetricType = #Centimeters
	local MergePath = undefined
	-- Merage SourceMaxFile
	MergePath = CurrFile + "_Step1"
	mergemaxfile MergePath quiet:true
	animationRange = interval AnimRange[1] AnimRange[2]
	-- Modify Bone Properties
	select $*
	local List_SceneObjAll = selection as array
	local List_SceneBN = #()
	for i=1 to List_SceneObjAll.count do
	(
		if (classOf List_SceneObjAll[i] == BoneGeometry ) do 
		( 
			append List_SceneBN List_SceneObjAll[i] 
			if (List_SceneObjAll[i].boneEnable == true) do
			(
				List_SceneObjAll[i].boneEnable = false
				List_SceneObjAll[i].boneEnable = true
				List_SceneObjAll[i].resetBoneStretch() 
			)
		)
	)
	-- Align BNWeapon
	BN_Weapon = #()
	Point_BNWeapon = #()
	for i=1 to BN_WeaponName.count do 
	( 
		append BN_Weapon (GetNodeByName BN_WeaponName[i]) 
		append Point_BNWeapon (GetNodeByName ("TempPoint_" + BN_Weapon[i].name))
	)
	
	for i=animationRange.start to animationRange.end do
	(
		With animate on
		(
			slidertime = i
			BN_Weapon[2].position = Point_BNWeapon[2].position
			BN_Weapon[2].rotation = Point_BNWeapon[2].rotation
			BN_Weapon[4].position = Point_BNWeapon[4].position
			BN_Weapon[4].rotation = Point_BNWeapon[4].rotation
		)
	)
	delete Point_BNWeapon
	
	-- Cleanup Max
	for i=1 to BN_BreastNewName.count do
	(
		local GetNode = getNodeByName BN_BreastNewName[i]
		if (GetNode != undefined) do (delete GetNode)
	)
	deleteFile MergePath

)