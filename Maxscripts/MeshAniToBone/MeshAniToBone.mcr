macroScript MeshAniToBone category:"BlessM" buttonText:"AniToBone" toolTip:"MeshAni to BoneAni"

(
	if (queryBox "Do you want to create a dummy, then bake the animation, after the skin?" title:"MeshAniSkinner") do
	(
		local MeshObjs = Selection as array
		local MeshDM = undefined
		local DM_Objs = #()
		local DM_Root = Point pos:[0,0,0] size:20 centermarker:false axistripod:true cross:false Box:true wirecolor:[0,255,0] name:"DM_Root"
		
		if (MeshObjs.count != 0 ) then
		(
				for i=1 to MeshObjs.count do
			(
				select MeshObjs[i]
				MeshDM = Point pos:MeshObjs[i].pos size:5 centermarker:false axistripod:true cross:false Box:true wirecolor:[255,10,0]
				MeshDM.name = "DM_" + MeshObjs[i].name
				MeshDM.parent = DM_Root 
				MeshDM.boneEnable = true
				append DM_Objs MeshDM
			)	
			
			for k in animationRange.start to animationRange.end do
			(
				sliderTime = k
				for i=1 to MeshObjs.count do
				(
					With animate on
					(
						DM_Objs[i].transform = MeshObjs[i].transform
					)
				)
			)

			for i=1 to MeshObjs.count do
			(
				selectkeys MeshObjs[i].pos.controller (interval animationRange.start animationRange.end)
				deleteKeys MeshObjs[i].pos.controller #selection
				selectkeys MeshObjs[i].rotation.controller (interval animationRange.start animationRange.end)
				deleteKeys MeshObjs[i].rotation.controller #selection
				selectkeys MeshObjs[i].scale.controller (interval animationRange.start animationRange.end)
				deleteKeys MeshObjs[i].scale.controller #selection
				selectkeys DM_Objs[i].scale.controller (interval animationRange.start animationRange.end)
				deleteKeys DM_Objs[i].scale.controller #selection
				
				select MeshObjs[i]
				max modify mode
				modPanel.addModToSelection (Skin ()) ui:on
				skinOps.AddBone $.modifiers[#Skin] DM_Objs[i] 1
			)	
			clearSelection()
			messagebox "Completed!"
		) else ( messagebox "Select Meshes!!")
	)
)