#pragma rtGlobals=1		// Use modern global access method.

//Suhas Somnath, UIUC 2009

// Version 1.7:
// Can now undo rotate and move
// Length priority defaults to truncate now.

// Version 1.6:
// Replaced all nm references with um. 
// Updated GUI appearance 

Menu "Macros"
	SubMenu "UIUC Lithography"
		"Smart Litho Art Suite", SmartLithoDriver()
	End
End

Function SmartLithoDriver()

	// If the panel is already created, just bring it to the front.
	DoWindow/F SmartLithoPanel
	if (V_Flag != 0)
		return 0
	endif
	
	String dfSave = GetDataFolder(1)
	// Create a data folder in Packages to store globals.
	NewDataFolder/O/S root:packages:SmartLitho
	
	// Create global variables used by the control panel.
	Wave mw = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	Variable scansize = mw[0]*1e+6
	
	// Line variables:
	Variable numlines = NumVarOrDefault(":gnumlines", 10)
	Variable/G gnumlines = numlines
	Variable linelength = NumVarOrDefault(":glinelength", (scansize/4))
	Variable/G glinelength = linelength
	Variable linesp = NumVarOrDefault(":glinesp", (scansize/10))
	Variable/G glinesp = linesp
	Variable lineangle = NumVarOrDefault(":glineangle", 90)
	Variable/G glineangle = lineangle	
	
	// Advanced line variables:
	String /G gLengthNames = "Truncate;Exact"
	Variable/G gLengthPriority = 1 // for Truncate
	String /G gDirNames = "Default;Switch All;Switch alternate"
	Variable/G gDirPriority = 1 // for default - none
	
	// Border Variables:
	Variable Tbord = NumVarOrDefault(":gTbord", (scansize/20))
	Variable/G gTbord = Tbord
	Variable Bbord = NumVarOrDefault(":gBbord", (scansize/20))
	Variable/G gBbord = Bbord
	Variable Lbord = NumVarOrDefault(":gLbord", (scansize/20))
	Variable/G gLbord = Lbord
	Variable Rbord = NumVarOrDefault(":gRbord", (scansize/20))
	Variable/G gRbord = Rbord
	
	// Scaling Variable:
	Variable/G gScale = 1
	
	// Rotation Variable:
	Variable/G gRotateAngle = 0
	
	// Flipping Variables:
	Variable/G gFlipHoriz = 0
	Variable/G gFlipVert = 0
	
	// Text variables:
	String /G gText = ""
	
	Variable textheight = NumVarOrDefault(":gtextheight", (scansize/20))
	Variable/G gtextheight = textheight
	Variable textwidth = NumVarOrDefault(":gtextwidth", (scansize/20))
	Variable/G gtextwidth = textwidth
	Variable textspace = NumVarOrDefault(":gtextspace", (scansize/40))
	Variable/G gtextspace = textspace
	
	// Layer Variables:
	Variable layernum = NumVarorDefault(":gLayernum",0)
	Variable/G gLayerNum = layernum
	String /G gLayernames = StrVarOrDefault(":gLayernames","")
	Variable/G gSelectedLayer = -1
	Variable/G gSingleShow = 1
	Variable/G gAllShow = 1
	Variable/G gSingleSelect = 0
	Variable/G gAllSelect = 0
	Variable/G gWasRedraw = 0
	Variable/G gShiftRight=0
	Variable/G gShiftUp=0
	Make/O /N=(10,5) /D layers

	// Tab variables
	// useful in figuring out the operation on which tab was called
	Variable ChosenTab = NumVarOrDefault(":gChosenTab",0)
	Variable/G gChosenTab = ChosenTab
	
	// Help String:
	String /G gHelp = "Smart Litho Help: \n"
	//gHelp = gHelp + "Lines Tab: Advanced Controls:\n"
	gHelp = gHelp + "Direction - default - left to right and top to bottom.\n"
	gHelp = gHelp + "Length - Truncate - Truncates lines extending outside the boundaries\n"
	gHelp = gHelp + "\t\tExact - Does NOT draw truncated lines\n"
	gHelp = gHelp + "Draw New - erases existing pattern and draws a fresh pattern using current parameters\n"
	gHelp = gHelp + "Undo - Goes back one step. (Warning, can only go back one step)\n"
	gHelp = gHelp + "Append - Appends the pattern using current parameters onto the existing displayed patterns\n"
	gHelp = gHelp + "Load new - Loads a previously saved pattern erasing currently drawn patterns from memory\n"
	gHelp = gHelp + "Clear - Deletes all displayed patterns\n"
	gHelp = gHelp + "Save - Saves the currently displayed pattern to memory(s)\n"
	gHelp = gHelp + "Append Saved - Same as Load new, except, does not erase currently displayed patterns\n"
	gHelp = gHelp + "Load from Disk - Reads a txt file from disk and saves it to memory. Must hit Load new or Append Saved to view pattern.\n"
	gHelp = gHelp + "Save to Disk - Saves currently displayed pattern to disk as a txt file\n"
	gHelp = gHelp + "Note: Scaling is NOT applied to Append and Draw New operations."
	
	// Create the control panel.
	Execute "SmartLithoPanel()"
	//Reset the datafolder to the root / previous folder
	SetDataFolder dfSave

End //SmartLithoDriver

Window SmartLithoPanel(): Panel

	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(485,145, 845,695) as "Smart Litho"
	SetDrawLayer UserBack
	
	TabControl tabcont, tabLabel(0)="Lines"
	TabControl tabcont, tabLabel(1)="Text"
	TabControl tabcont, tabLabel(2)="Layers", value=root:packages:SmartLitho:gChosenTab
	TabControl tabcont, pos={8,8}, size={345,277}, proc=TabProc
	
	Variable scansize = root:Packages:MFP3D:Main:Variables:MasterVariablesWave[0]*1e+6
	//print "scan size = " + num2str(scansize)
	//PV("ScanSize",35e-6)
	scansize = max(20,scansize)
	//resetting the scansize to the default size:
	//root:Packages:MFP3D:Main:Variables:MasterVariablesWave[0] = 20e-6
	//print "scan size = " + num2str(scansize)
	//Variable scansize = 20000// in nanometers
	
	
	// Tab #0: Lines
	
	SetVariable lineparams, pos={18,42},size={0,18},title="Line Parameters:"
	SetVariable lineparams, fSize=15,fstyle=1, limits={0,0,0}, disable=2, noedit=1	
	
	SetVariable setvarnumlines,pos={40,72},size={114,18},title="Number of"
	SetVariable setvarnumlines,value= root:packages:SmartLitho:gnumlines,live= 1
	SetVariable setvarlinelength,pos={201,72},size={126,18},title="Length (um)", limits={0,(1*scansize),1}	
	SetVariable setvarlinelength,value=root:packages:SmartLitho:glinelength,live= 1
	
	SetVariable setvarangle,pos={35,106},size={119,18},title="Angle (deg)", limits={0,180,1}
	SetVariable setvarangle,value= root:packages:SmartLitho:glineangle,live= 1
	SetVariable setvarlinespace,pos={192,106},size={135,18},title="Spacing (um)", limits={0,(0.5*scansize),1}
	SetVariable setvarlinespace,value= root:packages:SmartLitho:glinesp,live= 1
	
	
	SetVariable advcontrols, pos={18,155},size={0,18},title="Advanced Controls:"
	SetVariable advcontrols, fSize=15,fstyle=1, limits={0,0,0}, disable=2, noedit=1	
	
	Popupmenu dirpriority,pos={24,187},size={135,18},title="Direction", limits={0,(0.5*scansize),1}
	Popupmenu dirpriority,value= root:packages:SmartLitho:gDirNames,live= 1, proc=LineDir
	Popupmenu lengthpriority,pos={205,187},size={135,18},title="Length", limits={0,(0.5*scansize),1}
	Popupmenu lengthpriority,value= root:packages:SmartLitho:gLengthNames,live= 1, proc=LineLength
	
	Checkbox chkShowLineDir, pos = {24, 231}, size={10,10}, title="Show Direction Arrows", proc=ShowLineArrows
	Checkbox chkShowLineDir, live=1

	// Tab #1: Text:
	SetVariable textparams,pos={18,42},size={110,18},title="Text Parameters:"
	SetVariable textparams, fSize=15, fstyle=1, limits={0,0,0}, disable=2, noedit=1	
	
	SetVariable setvartext,pos={35,78},size={291,18},title="Text:"
	SetVariable setvartext,value= root:packages:SmartLitho:gText,live= 1
	
	SetVariable setvartextht,pos={35,115},size={119,18},title="Height (um)", limits={0,(1*scansize),1}
	SetVariable setvartextht,value= root:packages:SmartLitho:gtextheight,live= 1
	SetVariable setvartextwt,pos={211,115},size={116,18},title="Width (um)", limits={0,(1*scansize),1}
	SetVariable setvartextwt,value= root:packages:SmartLitho:gtextwidth,live= 1
	
	SetVariable setvartextsp,pos={35,157},size={119,18},title="Space (um)", limits={0,(1*scansize),1}
	SetVariable setvartextsp,value= root:packages:SmartLitho:gtextspace,live= 1
	
	// Tab #2: Layers:
	Popupmenu layerselector, fstyle=1, fsize= 15, pos={18,57},size={135,18},title="Layer", proc=LayerSelectorPM
	Popupmenu layerselector,value= root:packages:SmartLitho:gLayernames,live= 1
	
	Checkbox allvisiblecheck, pos = {130, 42}, size={10,10}, title="Show all", proc=ShowAllLayersCB
	Checkbox allvisiblecheck, value= root:packages:SmartLitho:gAllShow, live=1
	
	Checkbox allselectcheck, pos = {241, 42}, size={10,10}, title="Select all"
	Checkbox allselectcheck, value= root:packages:SmartLitho:gAllSelect, live=1
	
	Checkbox layervisiblecheck, pos={129,75},size={10,10}, title="Show", proc=showSingleLayerCB
	Checkbox layervisiblecheck, value= root:packages:SmartLitho:gSingleShow, live=1
	
	Checkbox layerselectcheck, pos={198,75},size={10,10}, title="Select"
	Checkbox layerselectcheck, value= root:packages:SmartLitho:gSingleSelect, live=1
	
	Button buttonDeleteLayer,pos={268,70},size={65,25},title="Delete",proc=deleteLayerButton
	
	
	
	SetVariable setvarRShift,pos={18,114},size={126,18},title="Right (um)", limits={(-1*scansize),(1*scansize),1}
	SetVariable setvarRShift,value= root:packages:SmartLitho:gShiftRight,live= 1
	
	SetVariable setvarDShift,pos={155,114},size={117,18},title="Up (um)", limits={(-1*scansize),(1*scansize),1}
	SetVariable setvarDShift,value= root:packages:SmartLitho:gShiftUp,live= 1
	
	Button buttonShiftLayer,pos={282,112},size={52,25},title="Move",proc=ShiftLayer
	
	
	
	SetVariable setvarRotate,pos={18,160},size={160,18},title="Rotate ccw (deg)", limits={-179,180,1}
	SetVariable setvarRotate,value= root:packages:SmartLitho:gRotateAngle,live= 1
	
	Button buttonRotateLayer,pos={200,158},size={60,25},title="Rotate",proc=RotateLayer
	
	
	
	SetVariable setvarScale,pos={18,201},size={91,18},title="Scale", limits={0,inf,1}
	SetVariable setvarScale,value= root:packages:SmartLitho:gScale,live= 1
	
	Button buttonScaleLayer,pos={145,199},size={185,25},title="Re-Position & Re-Scale", proc=reScaleAndPosition
	
	
	
	Checkbox checkfliphoriz, pos={17,245},size={10,10}, title="Flip Horizontally", proc=FlipCB
	Checkbox checkfliphoriz, value= root:packages:SmartLitho:gFlipHoriz, live=1
	
	Checkbox checkflipvert, pos={157,245},size={10,10}, title="Vertically", proc=FlipCB
	Checkbox checkflipvert, value= root:packages:SmartLitho:gFlipVert, live=1
	
	Button buttonFlipLayer,pos={270,243},size={50,25},title="Flip", proc=flipLayer
	
	
	
	// Global Parameters:
	SetDrawEnv fstyle= 1,fsize= 15
	DrawText 18,310, "Borders:"
		
	SetVariable setvarTbord,pos={44,315},size={108,18},title="Top (um)", limits={0,(1*scansize),1}
	SetVariable setvarTbord,value= root:packages:SmartLitho:gTbord,live= 1
	SetVariable setvarBbord,pos={203,315},size={126,18},title="Bottom (um)", limits={0,(1*scansize),1}
	SetVariable setvarBbord,value= root:packages:SmartLitho:gBbord,live= 1
	
	SetVariable setvarLbord,pos={45,349},size={106,18},title="Left (um)", limits={0,(1*scansize),1}
	SetVariable setvarLbord,value= root:packages:SmartLitho:gLbord,live= 1
	SetVariable setvarRbord,pos={213,349},size={117,18},title="Right (um)", limits={0,(1*scansize),1}
	SetVariable setvarRbord,value= root:packages:SmartLitho:gRbord,live= 1
	
	
	// Global buttons:
	SetDrawEnv fstyle= 1,fsize= 15
	DrawText 14,405, "General Functions:"
	
	Button buttonDrawPattern,pos={21,418},size={100,25},title="Draw New", proc=drawNew
	Button buttonUndo,pos={149,418},size={70,25},title="Undo", proc=undoLastPattern
	Button buttonAppendPattern,pos={246,418},size={100,25},title="Append", proc=appendPattern
	
	Button buttonLoadPattern,pos={21,454},size={100,25},title="Load New", proc=loadPattern
	Button buttonClearPattern,pos={149,454},size={70,25},title="Clear", proc=clearPattern
	Button buttonSavePattern,pos={246,454},size={100,25},title="Save", proc=savePattern
	
	Button buttonAppendSaved,pos={21,489},size={105,25},title="Append Saved", proc=addExternalPattern
	Button buttonLoadFromDisk,pos={133,489},size={106,25},title="Load from Disk", proc=LoadWavesFromDisk
	Button buttonSaveToDisk,pos={246,489},size={100,25},title="Save to Disk", proc=savePatternToDisk
	
	Button buttonHelp,pos={276,7},size={74,20},title="Help", proc=SmartLithoHelp
	
	SetDrawEnv textrgb= (0,0,65280),fstyle= 1,fsize= 15
	DrawText 153, 541, "Suhas Somnath, UIUC 2009"
	
	// Making only the tab gChosenTab things show up on startup
	TabProc ("dummy", root:packages:SmartLitho:gChosenTab)
	
EndMacro //SmartLithoPanel

Function TabProc (ctrlName, tabNum) : TabControl
	String ctrlName
	Variable tabNum
	
	// Setting the chosen tab to help in
	// checking what tab's operation to perform
	// when a button is clicked
	
	// Storing the old working folder:
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gChosenTab
	gChosenTab = tabnum
	SetDataFolder dfSave
			
	Variable isTab0= tabNum==0
	Variable isTab1= tabNum==1
	Variable isTab2= tabNum==2
	//disable=0 means show, disable=1 means hide
	
	//more details - refer to 
	// http://wavemetrics.net/doc/III-14 Control Panels.pdf
	
	//Tab 0: Lines
	ModifyControl lineparams disable= !isTab0
	ModifyControl setvarnumlines disable= !isTab0 // hide if not Tab0
	ModifyControl setvarlinelength disable= !isTab0 // hide if not Tab 0
	ModifyControl setvarlinespace disable= !isTab0 // hide if not Tab 0
	ModifyControl setvarangle disable= !isTab0 // hide if not Tab 0
	
	ModifyControl advcontrols disable= !isTab0 // hide if not Tab 0
	ModifyControl dirpriority disable= !isTab0 // hide if not Tab 0
	ModifyControl lengthpriority disable= !isTab0 // hide if not Tab 0
	ModifyControl chkShowLineDir disable= !isTab0 // hide if not Tab 0
	
		
	//Tab 1: Text:
	ModifyControl textparams disable= !isTab1 // hide if not Tab 1
	ModifyControl setvartext disable= !isTab1 // hide if not Tab 1
	ModifyControl setvartextht disable= !isTab1 // hide if not Tab 1
	ModifyControl setvartextwt disable= !isTab1 // hide if not Tab 1
	ModifyControl setvartextsp disable= !isTab1 // hide if not Tab 1
	
	//Tab 2: Layers
	ModifyControl buttonDrawPattern disable= isTab2 // hide if not Tab 2	
	ModifyControl buttonAppendPattern disable= isTab2 // hide if not Tab 2	
	
	ModifyControl allvisiblecheck disable= !isTab2 // hide if not Tab 2	
	ModifyControl allselectcheck disable= !isTab2 // hide if not Tab 2	
	
	ModifyControl layerselector disable= !isTab2 // hide if not Tab 2
	ModifyControl layervisiblecheck disable= !isTab2 // hide if not Tab 2
	ModifyControl layerselectcheck disable= !isTab2 // hide if not Tab 2
	
	ModifyControl buttondeletelayer disable= !isTab2 // hide if not Tab 2
	ModifyControl buttonFlipLayer disable= !isTab2 // hide if not Tab 2
	ModifyControl buttonScaleLayer disable= !isTab2 // hide if not Tab 2
	
	ModifyControl setvarRShift disable= !isTab2 // hide if not Tab 2
	ModifyControl setvarDShift disable= !isTab2 // hide if not Tab 2
	ModifyControl buttonShiftLayer disable= !isTab2 // hide if not Tab 2
	
	ModifyControl setvarRotate disable= !isTab2 // hide if not Tab 2
	ModifyControl Setvarscale disable= !isTab2 // hide if not Tab 2
	ModifyControl checkfliphoriz disable= !isTab2 // hide if not Tab 2
	ModifyControl checkflipvert disable= !isTab2 // hide if not Tab 2
	
	ModifyControl buttonRotateLayer disable= !isTab2 // hide if not Tab 2
	
	return 0	
	
End // TabProc

Function ShowLineArrows(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			ToggleLithoArrows("ShowArrowBox_0",checked)
			
			break
	endswitch

	return 0
End

Function FlipCB(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gFlipHoriz, gFlipVert

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if( !cmpstr("checkfliphoriz",cba.ctrlName))
				gFlipHoriz = checked
			else
				gFlipVert = checked
			endif
			break
	endswitch
	
	SetDataFolder dfSave

	return 0
End

Function LayerSelectorPM(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gSelectedLayer, gSingleSelect, gSingleShow
	Wave Layers
	
	switch( pa.eventCode )
		case 2: // mouse up
			gSelectedLayer = pa.popNum-1
			// updating the  checkboxes for the selected layer
			gSingleSelect = layers[gSelectedLayer][4]
			gSingleShow = layers[gSelectedLayer][3]
			String ControlName = "layervisiblecheck"
			Checkbox $ControlName, Value=gSingleShow
			ControlName = "layerselectcheck"
			Checkbox $ControlName, Value=gSingleSelect
			break
	endswitch
	
	SetDataFolder dfSave
	
End //LineDir

Function addNewLayer(startindex,endindex)

	Variable startindex,endindex
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	NVAR gLayernum
	SVAR gLayernames
	Wave layers
	
	gLayerNum += 1
	
	if (glayernum == 1)
		gLayernames = "1"
	else
		gLayernames += ";" + num2str(gLayerNum)
	endif
	
	gLayerNum -= 1
	
	layers[gLayerNum][0] = gLayerNum+1
	layers[gLayerNum][1] = startindex
	layers[gLayerNum][2] = endindex
	layers[gLayerNum][3] = 1 // Show
	layers[gLayerNum][4] = 0 // Selected
	
	gLayerNum += 1
	
	SetDataFolder dfSave
End

Function updateMasterWaves(mode)
	Variable mode
	// Make copy to master:
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gWasRedraw
	
	if( mode == 0)
		// case = freshly drawn
		//MFP waves must be same as Master
		Duplicate/O root:packages:MFP3D:Litho:XLitho, master_XLitho
		Duplicate/O root:packages:MFP3D:Litho:YLitho, master_YLitho
	elseif( mode == 1 || mode == 2)
		
		// MFP waves may / may NOT be displaying some of the layers in master
		// append the newly drawn stuff to the master as well:
		
		// Appending the waves to a temporary location:
		if (mode == 1)
			// case = appending Loaded pattern
			appendWaves(master_XLitho, root:packages:MFP3D:Litho:XLitho, "appendedX2")
			appendWaves(master_YLitho, root:packages:MFP3D:Litho:YLitho, "appendedY2")
		else 
			//Case = Appending drawn pattern
			appendWaves(master_XLitho, XLitho, "appendedX2")
			appendWaves(master_YLitho, YLitho, "appendedY2")
		endif
		
		// Duplicate the temporary wave to the Master wave
		Duplicate/O appendedX2, master_XLitho
		Duplicate/O appendedY2, master_YLitho
	
		// Clean up:
		KillWaves appendedX2, appendedY2
		
	elseif( mode == 3 && gWasRedraw == 0)
		// case = undo-ing last pattern
		// Need to remove the last layer from master	
		NVAR gLayernum
		Wave Layers
		// The layers wave has already been updated to remove the last layer.
		// Need to take the end position of the last layer and add one to get the right size
		if(gLayernum == 0)
			Redimension /N=(0) Master_XLitho, Master_XLitho
		else
			Redimension /N=(Layers[gLayernum-1][2]+1) Master_XLitho, Master_XLitho
		endif
	elseif( mode == 3 && gWasRedraw == 1)
	
		Duplicate/O old_Master_XLitho, Master_XLitho
		Duplicate/O old_Master_YLitho, Master_YLitho 
		
		gWasRedraw = 0
		
	endif
	
	SetDataFolder dfSave

End 

Function eraseAllLayers()
	// resetting all layers:
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	NVAR gLayerNum
	SVAR gLayerNames
	
	Make/O/N=(10,5) layers
	Variable i,j
	for(i=0; i<10; i+=1)
		for(j=0; j<5; j+=1)
			layers[i][j]=0
		endfor
	endfor
	gLayerNum = 0
	gLayerNames = ""
	
	SetDataFolder dfSave
End

Function reWriteLayerNames()
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	Wave layers
	NVAR gLayerNum
	SVAR gLayerNames
	Variable i
	
	if(gLayerNum > 0)
		gLayerNames = "" + num2str(layers[0][0])
		
		for(i=1;i<gLayerNum;i+=1)
			if(layers[i][0] != 0)
				gLayerNames += ";" + num2str(layers[i][0])
			endif 							
		endfor	
	else
		gLayerNames = ""
	endif
	
	SetDataFolder dfSave
End

Function showSingleLayerCB(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	Wave layers
	NVAR gSelectedLayer

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(gSelectedLayer > -1)
				//print "Layers["+num2str(gSelectedLayer)+"][3] = " + num2str(checked)
				layers[gSelectedLayer][3] = checked
				refreshRender()
			endif
			break
	endswitch
	
	SetDataFolder dfSave

	return 0
End

Function showAllLayersCB(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	Wave layers, Master_XLitho, Master_YLitho
	NVAR gLayerNum
	
	Wave mfpX = root:packages:MFP3D:Litho:XLitho
	Wave mfpY = root:packages:MFP3D:Litho:YLitho
	
	Variable i

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			for(i=0; i<gLayerNum; i+=1)
				Layers[i][3] = checked
			endfor
			
			String ControlName = "layervisiblecheck"
			Checkbox $ControlName, Value=checked
			
			if(checked)
				//Duplicate Master into MFP
				Duplicate/O Master_XLitho, mfpx
				Duplicate/O Master_YLitho, mfpy
			else
				//Redimension MFP waves to 0
				Redimension /N=(0) mfpx,mfpy
			endif
			
			break
	endswitch
	
	SetDataFolder dfSave

	return 0
End

Function refreshRender()
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	Wave layers, Master_XLitho, Master_YLitho
	NVAR gLayerNum
	
	// For simplicity sake completely rewrite the entire MFP waves
	// according to the layer plans
	// This should work for both deletes and show/hides
	
	// First find out the size of the X and Y Litho waves:
	Variable i, size=0
	for (i=0; i<gLayerNum; i+=1)
		if(Layers[i][3] == 1)// Show
			//Add its size to total:
			// 0 -> 2 = 3 not 2
			size += Layers[i][2] + 1 - Layers[i][1]
		endif
	endfor
	
	//print "new size is going to be = " + num2str(size)
	
	Make/O/N=(size) root:packages:MFP3D:Litho:XLitho, root:packages:MFP3D:Litho:YLitho, XLitho, YLitho
	
	Wave mfpX = root:packages:MFP3D:Litho:XLitho
	Wave mfpY = root:packages:MFP3D:Litho:YLitho
	
	// Go through layers and master waves copying only those layers that are to be shown:
	Variable mfpindex=0
	for (i=0; i<gLayerNum; i+=1)
		if(Layers[i][3] == 1)// Show
			//copying 
			for(size=Layers[i][1]; size <= Layers[i][2]; size +=1)
				mfpX[mfpindex] = Master_XLitho[size]
				mfpY[mfpindex] = Master_YLitho[size]
				mfpindex += 1
			endfor
		endif
	endfor
	
	SetDataFolder dfSave
End

Function deleteLayerButton(ctrlname) : ButtonControl
	String ctrlname	
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gSelectedLayer
	
	deleteLayer(gSelectedLayer)
	
	SetDataFolder dfSave
	
End // savePattern

Function deleteLayer(layerindex)
	Variable layerindex
	
	// Following must be updated IN ORDER each time this method is called:
	// 1. Master wave
	// 2. layers wave 
	// 3. LayerNum - subtract by 1
	// 4. LayerNames - reWriteLayerNames
	// 5. rerendering litho waves - call refreshRender
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	Wave layers, Master_XLitho, Master_YLitho
	NVAR gLayerNum
	
	if(layerindex >= gLayerNum || layerindex < 0)
		return -1
	endif
	
	// Two easy cases exist :
	// 1 - deleting the only layer or the last layer
	if(layerindex ==  (gLayerNum - 1)) 
		
		if(gLayernum == 1)
			// Only layer case
			Redimension /N=(0) Master_XLitho, Master_XLitho
			Make/O /N=(10,5) layers
			Variable p,q
			for(p=0; p<10; p+=1)
				for(q=0; q<5; q+=1)
					layers[p][q]=0
				endfor
			endfor
			
		else
			// Last layer case
			Redimension /N=(Layers[gLayernum-1][2]+1) Master_XLitho, Master_XLitho
			Redimension /N=(gLayerNum-1,5) Layers
		endif
		
	else
		
		// Part 1 - Deleting the pattern in the Master wave:
		// First find out the new size of the master waves:
		Variable size = numpnts(Master_XLitho) - (Layers[layerindex][2] + 1 - Layers[layerindex][1])
		
		// Making new temporary waves
		Make/O/N=(size) new_Master_X, new_Master_Y
		Make/O/N=(gLayerNum-1,5) New_Layers
		
		//Copying the stuff until layerindex
		Variable i=0,j=0,mindex=0
		if (layerindex != 0)
			//Nothing to copy if the layer to be
			//deleted was the first layer
			for (i=0; i<layerindex; i+=1)
			
				//Copying the layers wave from the original
				for (j=0; j<5; j += 1)
					New_Layers[i][j] = Layers[i][j]
				endfor
				
				//Copying the coordinates in the master waves:
				for(j=Layers[i][1]; j <=Layers[i][2]; j+=1)
					new_Master_X[mindex] = Master_XLitho[j]
					new_Master_Y[mindex] = Master_YLitho[j]
					mindex += 1
				endfor
			endfor
		endif
		
		//Copying the stuff after layerindex
		for (i=layerindex+1; i<gLayerNum; i+=1)
		
			//Copying the layers wave from the original
			for (j=3; j<5; j += 1)
				New_Layers[i-1][j] = Layers[i][j]
			endfor
			New_Layers[i-1][0] = Layers[i][0] - 1
			New_Layers[i-1][1] = mindex
		
			//Copying the coordinates in the master waves:
			for(j=Layers[i][1]; j <=Layers[i][2]; j+=1)
			new_Master_X[mindex] = Master_XLitho[j]
			new_Master_Y[mindex] = Master_YLitho[j]
				mindex += 1
			endfor
			
			New_Layers[i-1][2] = mindex-1
			
		endfor
	
		
		// Getting rid of old waves:
		Duplicate/O new_Master_X, Master_XLitho; KillWaves new_Master_X	
		Duplicate/O new_Master_Y, Master_YLitho; KillWaves new_Master_Y	
		Duplicate/O new_Layers, Layers; KillWaves new_Layers	
	endif
	
	// Part 3:
	gLayerNum -= 1
	
	//Part 4:
	reWriteLayerNames()
	
	//Part 5:
	refreshRender()	
	
	SetDataFolder dfSave
End

Function flipLayer(ctrlname) : ButtonControl
	String ctrlname
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gFlipHoriz, gFlipVert, gSelectedLayer, gWasRedraw
	Wave Layers, Master_XLitho, Master_YLitho
		
	if(gFlipHoriz == 0 && gFlipVert == 0)
		return 0
	Endif
	
	// Making appropriate backups
	Duplicate/O Master_XLitho, old_Master_XLitho
	Duplicate/O Master_YLitho, old_Master_YLitho
	
	// Finding max and min for that layer first:
	Variable xmin = wavemin(Master_XLitho,Layers[gSelectedLayer][1],Layers[gSelectedLayer][2])
	Variable xmax = wavemax(Master_XLitho,Layers[gSelectedLayer][1],Layers[gSelectedLayer][2])
	
	Variable i=0

	if(gFlipHoriz == 1)
	
		for(i=Layers[gSelectedLayer][1]; i <=Layers[gSelectedLayer][2]; i+=1)
			Master_XLitho[i] =  xmax + xmin - Master_XLitho[i]
		endfor
		
	endif
	
	Variable ymin = wavemin(Master_YLitho,Layers[gSelectedLayer][1],Layers[gSelectedLayer][2])
	Variable ymax = wavemax(Master_YLitho,Layers[gSelectedLayer][1],Layers[gSelectedLayer][2])
	
	if(gFlipVert == 1)
	
		for(i=Layers[gSelectedLayer][1]; i <=Layers[gSelectedLayer][2]; i+=1)
			Master_YLitho[i] =  ymax + ymin - Master_YLitho[i]
		endfor
		
	endif	
	
	
	gFlipHoriz = 0
	gFlipVert = 0
	String ControlName = "checkfliphoriz"
	Checkbox $ControlName, Value=gFlipHoriz
	ControlName = "checkflipvert"
	Checkbox $ControlName, Value=gFlipVert
	gWasRedraw = 1
	
	refreshRender()	
	
	SetDataFolder dfSave
	
End

Function ShiftLayer(ctrlname) : ButtonControl
	String ctrlname
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gShiftRight, gShiftUp, gSelectedLayer, gWasRedraw
	Wave Layers, Master_XLitho, Master_YLitho
	
	Variable scansize = GV("ScanSize")
	
	NVAR gScale, gTbord, gBbord, gLbord, gRbord	
	// Coordinates of the actual writing box:
	Variable leftlimit = gLbord * 1e-6
	Variable rightlimit = scansize - (gRbord * 1e-6)
	Variable toplimit =scansize - (gTbord * 1e-6)
	Variable bottomlimit =gBbord * 1e-6
	
	//print "gShiftUp = " + num2str(gShiftUp) + ", gShiftRight = " + num2str(gShiftRight)
	
	if(!gShiftUp && !gShiftRight)
		print "ended here"
		return 0
	endif
	
	backupState()
	Duplicate/O Master_XLitho, old_Master_XLitho
	Duplicate/O Master_YLitho, old_Master_YLitho
	
	Variable UpShift = gShiftUp * 1e-6
	Variable RightShift = gShiftRight * 1e-6
	
	Variable i=0
	
	if(gShiftRight)
		
		// Finding max and min for that layer first:
		Variable xmin = wavemin(Master_XLitho,Layers[gSelectedLayer][1],Layers[gSelectedLayer][2])
		Variable xmax = wavemax(Master_XLitho,Layers[gSelectedLayer][1],Layers[gSelectedLayer][2])
		
		if( RightShift > 0)
			if( RightShift > rightlimit - xmax)
				RightShift = rightLimit - xMax
			endif
		else
			if( RightShift < leftlimit - xmin)
				RightShift = leftlimit - xmin
			endif
		endif
				
		for(i=Layers[gSelectedLayer][1]; i <=Layers[gSelectedLayer][2]; i+=1)
			Master_XLitho[i] +=  RightShift
		endfor
		
	endif
	
	if(gShiftUp)
		
		// Finding max and min for that layer first:
		Variable ymin = wavemin(Master_YLitho,Layers[gSelectedLayer][1],Layers[gSelectedLayer][2])
		Variable ymax = wavemax(Master_YLitho,Layers[gSelectedLayer][1],Layers[gSelectedLayer][2])
		
		if( UpShift > 0)
			if( UpShift > toplimit - ymax)
				UpShift = toplimit - ymax
			endif
		else
			if( UpShift < bottomlimit - ymin)
				UpShift = bottomlimit - ymin
			endif
		endif
		
		for(i=Layers[gSelectedLayer][1]; i <=Layers[gSelectedLayer][2]; i+=1)
			Master_YLitho[i] +=  UpShift
		endfor
		
	endif
	
	//gShiftRight = 0
	//gshiftUp = 0
	gWasRedraw = 1
	
	refreshRender()	
	
	SetDataFolder dfSave	
End

Function rotateLayer(ctrlname) : ButtonControl
	String ctrlname
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gRotateAngle, gSelectedLayer, gWasRedraw
	Wave Layers, Master_XLitho, Master_YLitho
	
	// 1. Copy only that layer onto the MFP waves
	// 2. Rotate waves
	// 3. Apply scale of 1 (makes sure that the rotated image still fits although repositioned)
	// 4. Copy contents of MFP wave onto master
	// 5. rerender
	
	if(gRotateAngle == 0 || gRotateAngle == 360)
		return 0
	endif
	
	Variable angle = (pi/180)*gRotateAngle
	
	backupState()
	Duplicate/O Master_XLitho, old_Master_XLitho
	Duplicate/O Master_YLitho, old_Master_YLitho
	
	//Part 1:Copy only that layer onto the MFP waves
	Make/O/N=(Layers[gSelectedLayer][2] + 1 - Layers[gSelectedLayer][1]) root:packages:MFP3D:Litho:XLitho, root:packages:MFP3D:Litho:YLitho
	
	Wave mfpX = root:packages:MFP3D:Litho:XLitho
	Wave mfpY = root:packages:MFP3D:Litho:YLitho
	
	Variable i
	for(i=Layers[gSelectedLayer][1]; i <=Layers[gSelectedLayer][2]; i+=1)
		mfpX[(i-Layers[gSelectedLayer][1])] = Master_XLitho[i]
		mfpY[(i-Layers[gSelectedLayer][1])] = Master_YLitho[i]
	endfor
	
	//Part 2: Rotating:
	
	//making two duplicate waves of the same size as the MFPs:
	Duplicate/O mfpX, oldX
	Duplicate/O mfpY, oldY
	
	for(i=0; i< numpnts(mfpX); i+=1)
		if(mfpX[i] != Nan)
			mfpX[i] = OldX[i]*cos(angle) + OldY[i]*sin(angle)	
			mfpY[i] =OldY[i]*cos(angle) - OldX[i]*sin(angle)	
		endif
	endfor
	
	KillWaves oldX, oldY
	
	//Part 3: scaling
	scaleCurrentPattern()
	
	//Part 4: Copy contents of MFP back into Master
	for(i=Layers[gSelectedLayer][1]; i <=Layers[gSelectedLayer][2]; i+=1)
		Master_XLitho[i] = mfpX[(i-Layers[gSelectedLayer][1])]
		Master_YLitho[i] = mfpY[(i-Layers[gSelectedLayer][1])]
	endfor
	
	gWasRedraw = 1
	
	//Part 5:
	refreshRender()	
		
	SetDataFolder dfSave
End

Function reScaleAndPosition(ctrlname) : ButtonControl
	String ctrlname	
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gScale
	
	if(gScale == 1)
		return 0
	endif
	
	backupState()
		
	// 1. Copy only that layer onto the MFP waves
	// 2. Apply scale
	// 3. Copy contents of MFP wave onto master
	// 4. rerender
	
	NVAR gSelectedLayer, gWasRedraw
	Wave Layers, Master_XLitho, Master_YLitho
	
	Duplicate/O Master_XLitho, old_Master_XLitho
	Duplicate/O Master_YLitho, old_Master_YLitho
	
	//Part 1:Copy only that layer onto the MFP waves
	Make/O/N=(Layers[gSelectedLayer][2] + 1 - Layers[gSelectedLayer][1]) root:packages:MFP3D:Litho:XLitho, root:packages:MFP3D:Litho:YLitho
	
	Wave mfpX = root:packages:MFP3D:Litho:XLitho
	Wave mfpY = root:packages:MFP3D:Litho:YLitho
	
	Variable i
	for(i=Layers[gSelectedLayer][1]; i <=Layers[gSelectedLayer][2]; i+=1)
		mfpX[(i-Layers[gSelectedLayer][1])] = Master_XLitho[i]
		mfpY[(i-Layers[gSelectedLayer][1])] = Master_YLitho[i]
	endfor
	
	//Part 2: scaling
	scaleCurrentPattern()
	
	//Part 3: Copy contents of MFP back into Master
	for(i=Layers[gSelectedLayer][1]; i <=Layers[gSelectedLayer][2]; i+=1)
		Master_XLitho[i] = mfpX[(i-Layers[gSelectedLayer][1])]
		Master_YLitho[i] = mfpY[(i-Layers[gSelectedLayer][1])]
	endfor
	
	gWasRedraw = 1
	
	//Part 4:
	refreshRender()	
	
	SetDataFolder dfSave
	
End

Function LineDir(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gDirPriority
	
	switch( pa.eventCode )
		case 2: // mouse up
			gDirPriority = pa.popNum
			break
	endswitch
	
	SetDataFolder dfSave
	
End //LineDir

Function LineLength(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gLengthPriority
	
	switch( pa.eventCode )
		case 2: // mouse up
			gLengthPriority = pa.popNum
			//print "Chosen selection number = " + num2str(gLengthPriority)
			//String popStr = pa.popStr
			break
	endswitch
	
	SetDataFolder dfSave
	
End //LineLength

Function clearPattern(ctrlname) : ButtonControl
	String ctrlname
	// backing up the current state of the MFP waves:
	backupState()
	
	eraseAllLayers()
	
	DrawLithoFunc("EraseAll")	
	
	updateMasterWaves(0)
	
	DrawLithoFunc("StopDraw_0")
	
End // endPattern

Function savePattern(ctrlname) : ButtonControl
	String ctrlname	
	LithoGroupFunc("SaveWave")
End // savePattern

Function loadPattern(ctrlname) : ButtonControl
	String ctrlname
	
	// backing up the current state of the MFP waves:
	backupState()
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gLayerNum
	
	
	//Loading the waves into the Litho waves
	Variable retval = LithoGroupFunc("LoadWave")

	if(retval != 0)
		// Wave WAS loaded!
		eraseAllLayers()
		addNewLayer(0, numpnts(root:packages:MFP3D:Litho:XLitho)-1)
		updateMasterWaves(0)
	endif
	
	// Scaling, rotating, flipping and positioning
	applySpecial(1)
	
	DrawLithoFunc("StopDraw_0")
	
End // loadPattern

Function undoLastPattern(ctrlname) : ButtonControl
	String ctrlname
	
	// Pretty much doing the reverse of what is done in 
	// backupState:
	
	// Storing the old working folder:
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	if( exists("XLitho") != 1 || exists("YLitho") != 1)
		// If the litho was not performed at all such waves
		// will not exist. Abort!!!
		print "Error: Undo - Check parameters, especially wrt scansize"
		return -1;
	endif
		
	// Duplicate the MFP waves that are used for rendering:
	// Will assume that the old_Litho waves exist becuase before any drawing / loading is
	// done, the backupState() function MUST be called
	Duplicate/O root:packages:SmartLitho:old_XLitho, root:packages:MFP3D:Litho:XLitho
	Duplicate/O root:packages:SmartLitho:old_YLitho, root:packages:MFP3D:Litho:YLitho
	
	Duplicate/O old_layers, layers
	NVAR old_gLayernum, gLayernum
	gLayernum = old_gLayernum
	reWriteLayerNames()	
	
	updateMasterWaves(3)										
	
	//Lines not rendering for the first time-> Save and then load for now???
	DrawLithoFunc("DrawWave")	
	
	// Resetting the data folder
	SetDataFolder dfsave
	
End // UndoLastPattern

Function backupState()
	
	// Storing the old working folder:
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	// Make two dummy waves in the SmartLitho folder:
	Make/O/N=1 old_XLitho
	Make/O/N=1 old_YLitho
	
	Make/O/N=1 old_layers
	Duplicate/O layers, old_layers
	NVAR gLayernum
	Variable/G old_gLayernum = gLayernum
	
	// Duplicate the MFP waves that are used for rendering
	Duplicate/O root:packages:MFP3D:Litho:XLitho, root:packages:SmartLitho:old_XLitho
	Duplicate/O root:packages:MFP3D:Litho:YLitho, root:packages:SmartLitho:old_YLitho
	
	// Resetting the data folder
	SetDataFolder dfsave
	
End // backupState

Function savePatternToDisk(ctrlname) : ButtonControl
	String ctrlname
	String oldSaveFolder = GetDataFolder(1)
	// Grabbing the current Lithos that are being displayed to the user
	setdatafolder root:packages:MFP3D:Litho
	
	//Also writing the length of the waves to make it easy to read
	Make /O /N=1 wavelength
	wavelength[0] = numpnts(XLitho)
	
	// O - overwrite ok, J - tab limted, W - save wave name, I - provides dialog
	Save /O/J/W/I XLitho,YLitho,wavelength
	
	killwaves wavelength
	setdatafolder oldSaveFolder
End //SaveWavesToDisk

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////// SMART LITHO HELP /////////////////////////////////////////////////////////////
							///////////////////////////////////////
// Makes an alert pop up with the help information string.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function SmartLithoHelp(ctrlname) : ButtonControl
	String ctrlname
	
	//Dont know yet how to open up an ihf file
	// for right now, make do with an alert
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	SVAR gHelp
	
	DoAlert 0, gHelp
		
	SetDataFolder dfSave
	
End // end of SmartLithoHelp

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////// APPLY SPECIAL ////////////////////////////////////////////////////////////
						////////////////////////////////////////////////
// Applies the scaling, flipping and rotation operations
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function applySpecial(performBackup)
	Variable performBackup 

	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	NVAR gScale, gFlipHoriz, gFlipVert
	
	if(performBackup)
		backupState()
	endif
	
	if(gscale != 1 && gScale != 0)
		scaleCurrentPattern()
	endif
	
	if(gFlipHoriz)
		 flipHorizontal() 
	endif
	
	if(gFlipVert)
		flipVertical()
	endif
	
	gflipHoriz = 0
	gFlipVert = 0
	String ControlName = "checkfliphoriz"
	Checkbox $ControlName, Value=gFlipHoriz
	ControlName = "checkflipvert"
	Checkbox $ControlName, Value=gFlipVert
	
	SetDataFolder dfSave	
	
End // applySpecial


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////// FLIP HORIZONTAL ////////////////////////////////////////////////////////////
						////////////////////////////////////////////////
// Only flips the current pattern horizontally. No scaling, movement applied
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function flipHorizontal() 

	String dfSave = GetDataFolder(1)
	
	SetDataFolder root:packages:MFP3D:Litho
	
	Wave XLitho
	
	Variable xmin = wavemin(XLitho)
	Variable xmax = wavemax(XLitho)
	
	XLitho = xmax + xmin - XLitho
		
	// Resetting the data folder
	SetDataFolder dfsave
	
End // flipHorizontal

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////// FLIP VERTICAL /////////////////////////////////////////////////////////////////
						////////////////////////////////////////////////
// Only flips the current pattern vertically. No scaling, movement applied
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function flipVertical() 

	String dfSave = GetDataFolder(1)
	
	SetDataFolder root:packages:MFP3D:Litho
	
	Wave YLitho
	
	Variable ymin = wavemin(YLitho)
	Variable ymax = wavemax(YLitho)
	
	YLitho = ymax + ymin - YLitho
	
	// Resetting the data folder
	SetDataFolder dfsave
	
End // flipVertical

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////// SCALE CURRENT PATTERN ////////////////////////////////////////////////////////
						////////////////////////////////////////////////
// Scales and positions the present pattern in the X and Y Litho waves. Makes sure keep the image
// within the borders prescribed keeping the original aspect ratio intact
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function scaleCurrentPattern() 
	
	// Use temporary waves to see if everything is within limits
	// Only if the rightmost and bottommost are within boundaries
	// duplicate to actual rendering waves
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	Wave mw = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	Variable scansize = mw[0]
	
	NVAR gScale, gTbord, gBbord, gLbord, gRbord	
	// Coordinates of the actual writing box:
	Variable leftlimit = gLbord * 1e-6
	Variable rightlimit = scansize - (gRbord * 1e-6)
	Variable toplimit =scansize - (gTbord * 1e-6)
	Variable bottomlimit =gBbord * 1e-6
	
	if(leftlimit > rightlimit || toplimit < bottomlimit)
		return -1
	endif
	
	SetDataFolder root:packages:MFP3D:Litho
	
	Wave XLitho, YLitho
	
	// use the borders to move it automatically
	// Also use the borders to limit the maximum scale
	// to fit the borders
	Variable xmin = wavemin(XLitho)
	Variable ymin = wavemin(YLitho)
	Variable xmax = wavemax(XLitho)
	Variable ymax = wavemax(YLitho)
	
	Variable isWider = (rightlimit - leftlimit < gscale * (xmax - xmin))
	Variable isTaller = (toplimit - bottomlimit < gscale * (ymax - ymin))
	
	//print "is Wider  = " + num2str(isWider) + ", is taller = " + num2str(isTaller)
	//print num2str(rightlimit - leftlimit) + " <- box size. After scale size -> " + num2str(gscale * (xmax - xmin))
	
	if(isWider || isTaller)
		if(isWider && isTaller)
			// Simply too large in both axes
			if( xmax - xmin > ymax - ymin)
				// wider than taller => gscale from horizontal size
				gscale = (rightlimit - leftlimit) / (xmax - xmin)
			else
				// taller than wider => gscale from vertical size
				gscale = (toplimit - bottomlimit) / (ymax - ymin)
			endif
		elseif(isWider && !isTaller)
			// is wider but not taller.
			gscale = (rightlimit - leftlimit) / (xmax - xmin)
		elseif(isTaller && !isWider)
			// is taller not wider
			gscale = (toplimit - bottomlimit) / (ymax - ymin)
		endif
		DoAlert 0, "Image going out of bounds. Scale reduced to " + num2str(gscale)
	endif
	
	// Move to bottom left
	XLitho = XLitho - xmin
	YLitho = YLitho - ymin
	
	// Scale up safely
	XLitho = XLitho * gscale
	YLitho = YLitho * gscale
	
	// Move to top left within borders
	XLitho = XLitho + leftlimit
	Variable yoffset = (toplimit - wavemax(YLitho))
	YLitho = YLitho + yoffset
	
	SetDataFolder root:packages:SmartLitho
	NVAR gScale
	gScale = 1
	
	// Resetting the data folder
	SetDataFolder dfsave
	
End // scaleCurrentPattern

Function readWaves(filePointer,name)
	Variable filePointer
	String name
	
	// storing the waves directly into the LithoWaves
	String oldSaveFolder = GetDataFolder(1)
	SetDataFolder root:packages:MFP3D:Litho:LithoWaves
	
	String str
	//Ignore the first line - it has the names of the columns
	FReadLine filePointer, str
	//Second line has the size of the waves:
	FReadLine filePointer, str
	Variable firstx, firsty, wavesize, i
	String tempx, tempy
	sscanf str, "%s\t%s\t%d", tempx, tempy, wavesize
	
	tempx = ReplaceString(" ",tempx,"",1)
		tempy = ReplaceString(" ",tempy,"",1)
		if(cmpstr(tempx,"")==0)
			firstx = nan
		else
			firstx = str2num(tempx)
		endif
		if(cmpstr(tempy,"")==0)
			firsty = nan
		else
			firsty = str2num(tempy)
		endif
		
	//print "# of lines" + num2str(wavesize) + ">> X = " + num2str(firstx) + ", Y = " + num2str(firsty)
	
	Make /N=(wavesize) wave0
	
	Duplicate/O wave0, $("Y"+name), $("X"+name)
	
	// Providing a handle now
	Wave Xwave = $("X"+name)
	Wave Ywave = $("Y"+name)
	killwaves wave0
	
	// Adding the first two coordinates:
	Xwave[0] = firstx
	Ywave[0] = firsty
	
	//Now looping over the remaining size to start filling in the waves:
	for (i=1; i<wavesize; i= i+1)
		FReadLine filePointer, str
		sscanf str, "%s\t%s", tempx, tempy
		//print "line " + num2str(i) + ">> x = " + tempx + ", y = " + tempy
		tempx = ReplaceString(" ",tempx,"",1)
		tempy = ReplaceString(" ",tempy,"",1)
		if(cmpstr(tempx,"")==0)
			firstx = nan
		else
			firstx = str2num(tempx)
		endif
		if(cmpstr(tempy,"")==0)
			firsty = nan
		else
			firsty = str2num(tempy)
		endif
		//print "Line #" + num2str(i) + ">> X = " + num2str(firstx) + ", Y = " + num2str(firsty)
		Xwave[i] = firstx
		Ywave[i] = firsty
	endfor
	
	SetDataFolder oldSaveFolder
	
	Close filePointer
	return 0
End //End of ReadWaves

Function LoadWavesFromDisk(ctrlname): ButtonControl
	String ctrlname
	String oldSaveFolder = GetDataFolder(1)
	setdatafolder root:packages:SmartLitho
	Variable refNum
	String outputPath
	Open /R /Z=2 /M="Select the text file containing the litho coordinates" refNum as ""
	if(refNum == 0)
		print "No file was open!"
		//return -1
	endif
	if (V_flag == -1)
		Print "Open cancelled by user."
		return -1
	endif
	if (V_flag != 0)
		DoAlert 0, "Error Opening file"
		return V_flag
	endif
	outputPath = S_fileName
	
	
	//Lets extract the pattern's name from its filename
	String filename = outputpath
	Variable enditer = FindLast(filename,":")
	filename = filename[enditer+1,strlen(filename)-1]
	//removing the .txt
	filename = RemoveEnding(filename , ".TXT")	
	//We cant allow any spaces within the wave's name:
	filename = ReplaceString(" ",filename,"_",1)
	
	if(cmpstr(outputPath,"")==0)
		DoAlert 0, "\t\tError!!\n\n\tYou did not choose any file!"
		return -1
	else
		//print "Wave name = " + filename
		readWaves(refNum,filename)
	endif
	setdatafolder oldSaveFolder
	
	DrawLithoFunc("StopDraw_0")
End //LoadWavesFromDisk

Function addExternalPattern(ctrlname) : ButtonControl
	String ctrlname

	// backing up the current state of the MFP waves:
	// So we have what has already been drawn.
	backupState()
	
	// Load the new waves freshly
	Variable retval = LithoGroupFunc("LoadWave")
	
	if (retval == 0)
		// Load did not happen. Ignore rest of code:
		return -1
	endif
	
	// Scaling, rotation, flipping and positioning this newly added patttern ONLY
	applySpecial(0)
	
	//Now appending what was earlier there in the Litho waves:
	
	// Storing the old working folder:
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	addNewLayer(numpnts(master_XLitho), numpnts(root:packages:MFP3D:Litho:XLitho) + numpnts(master_XLitho)-1)
			
	// Appending the waves:
	appendWaves(old_XLitho, root:packages:MFP3D:Litho:XLitho, "appendedX")
	appendWaves(old_YLitho, root:packages:MFP3D:Litho:YLitho, "appendedY")
	
	// Append MFP waves to Master waves
	updateMasterWaves(1)
	
	// Duplicate the right waves that are used for rendering
	Duplicate/O root:packages:SmartLitho:appendedX, root:packages:MFP3D:Litho:XLitho
	Duplicate/O root:packages:SmartLitho:appendedY, root:packages:MFP3D:Litho:YLitho
	
	// Clean up:
	KillWaves appendedX, appendedY
		
	// restoring directory structure:
	SetDataFolder dfSave
	
	//Lines not rendering for the first time-> Save and then load for now???
	DrawLithoFunc("DrawWave")	
	
	// Calculating the total time to litho:
	CalcLithoTime()
	
	DrawLithoFunc("StopDraw_0")
	
End // addExternalPattern

Function drawCurrentText()
	String ctrlname
	//print "drawCurrentText called!"
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
		
	SVAR gText
	//gText = ReplaceString(" ",gText,"_",1)		//fight the users urge to use spaces.
	//print "global text val = " + gText
	
	if(strlen(gText) == 0)
		DoAlert 0, "\t\tError!! \n\n\tNothing to write. \n\t\tAborting!"
		return -1
	endif
	
	NVAR gtextwidth, gtextheight, gtextspace, gTbord, gBbord, gLbord, gRbord	
	Wave masterwave = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	Variable scansize = masterwave[0]
	
	// setting the scale of the variables correctly to meters:
	Variable textheight = gtextheight * 1e-6
	Variable textwidth = gtextwidth * 1e-6
	Variable textspace = gtextspace * 1e-6
	
	// Coordinates of the actual writing box:
	Variable leftlimit = gLbord * 1e-6
	Variable rightlimit = scansize - (gRbord * 1e-6)
	Variable toplimit =scansize - (gTbord * 1e-6)
	Variable bottomlimit =gBbord * 1e-6
	
	if(leftlimit > rightlimit || toplimit < bottomlimit)
		return -1
	endif
	
	Make/O /N=0 XLitho, YLitho
	
	// Number of chars that can be written in one line:
	// Assumes space between each char is half the char width
	Variable linelimit = (rightlimit - leftlimit) / (textwidth + textspace)
	//print "Char limit = " + num2str(linelimit)
	if(linelimit < strlen(gText))
		DoAlert 0, "\t\tWarning!\n\nFew characters cannot fit within boundary"
	endif
	linelimit = min(strlen(gText),linelimit)
	//print "Reduced char limit = " + num2str(linelimit)
	
	//print "---------------------------------------------------------------------------------------"
	//print "box coordinates: start : (" + num2str(leftlimit) + ", " + num2str(toplimit) + "), end: (" + num2str(rightlimit) + ", " + num2str(bottomlimit) + ")"
	//print "font stats: height = " + num2str(textheight) + ", width = " + num2str(textwidth)
	
	Variable i = 0
	Variable xstart = leftlimit
	
	for(i=0; i<linelimit; i+=1)
		
		//Printing stats:
		//print "Char stats: char = '" + gText[i] + "', xstart = " + num2str(xstart) + ", ystart = " + num2str(toplimit - textheight)
		
		// handling spaces:
		// just move, do nothing.
		if(cmpstr(gText[i]," ") == 0)
			xstart = xstart + (textspace + textwidth)
			continue
		endif
	
		drawAlphabet(Upperstr(gText[i]), xstart, (toplimit - textheight), textheight, textwidth)
		xstart = xstart + (textspace + textwidth)
		
		// Appending the waves:
		appendWaves(XAlpha, XLitho,"appendedX")
		appendWaves(YAlpha, YLitho,"appendedY")
	
		// Just keep refreshing the local Litho waves
		// No rendering done here
		Duplicate/O appendedX, XLitho
		Duplicate/O appendedY, YLitho
	
		// Clean up:
		// Avoid appending
		KillWaves appendedX, appendedY	
	endfor
	
	//print "---------------------------------------------------------------------------------------"	
	
	SetDataFolder dfSave
	
End // drawCurrentText

Function appendPattern(ctrlname) : ButtonControl
	String ctrlname
	// Needs to go one step beyond just the fresh draw
	// 1. take a backup of the current XLitho, YLitho
	// 2. instead of duplicating the SmartLitho waves of the
	// 	current form, need to append to the Litho waves
	
	// backing up the current state of the MFP waves:
	backupState()
	
	// Storing the old working folder:
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	// Drawing this NEW pattern onto the home Litho waves.
	// but NOT rendering it yet.
	
	NVAR gChosenTab

	if(gChosenTab == 0)
		drawCurrentLines()
	elseif(gChosenTab == 1)
		drawCurrentText()
	endif
	
	if( exists("XLitho") != 1 || exists("YLitho") != 1)
		// If the litho was not performed at all such waves
		// will not exist. Abort!!!
		DoAlert 0, "\t\tError!! \n\nCheck parameters, especially wrt scansize"
		return -1;
	endif
	
	addNewLayer(numpnts(master_XLitho), numpnts(master_XLitho) + numpnts(XLitho)-1)
		
	// Appending the waves:
	appendWaves(root:packages:MFP3D:Litho:XLitho, XLitho,"appendedX")
	appendWaves(root:packages:MFP3D:Litho:YLitho, YLitho,"appendedY")
	
	updateMasterWaves(2)
	
	// Duplicate the right waves that are used for rendering
	Duplicate/O root:packages:SmartLitho:appendedX, root:packages:MFP3D:Litho:XLitho
	Duplicate/O root:packages:SmartLitho:appendedY, root:packages:MFP3D:Litho:YLitho

	// Clean up:
	KillWaves appendedX, appendedY
	// Avoiding appending instead of overwriting
	Redimension /N=0 XLitho, YLitho
	
	// restoring directory structure:
	SetDataFolder dfSave
	
	//Lines not rendering for the first time-> Save and then load for now???
	DrawLithoFunc("DrawWave")	
	
	// Calculating the total time to litho:
	CalcLithoTime()
	
	DrawLithoFunc("StopDraw_0")
	
End // appendPattern

Function appendWaves(wave0, wave1, outname)
	Wave wave0, wave1
	String outname

	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho

	// Not interefering with wave0's stuff
	Duplicate/O wave0, $outname
	
	// Providing a handle now
	Wave wave2 = $outname
	
	// Resize it to hold both waves' stuff
	Redimension /N=(numpnts(wave0)+numpnts(wave1)) wave2
	Variable len0 = numpnts(wave0)
	Variable len1 = numpnts(wave1)
	
	// Use DimSize(wavename, property) to get more information about the wave
	//print DimSize(wave0,0)
	
	Variable i=0
	for(i=len0; i<len0+len1; i+=1)
		wave2[i] = wave1[i-len0]
	endfor
	
	SetDataFolder dfSave
	
	//return wave2
End


Function drawNew(ctrlname) : ButtonControl
	String ctrlname
	
	// backing up the current state of the MFP waves:
	backupState()
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	NVAR gChosenTab
	
	if(gChosenTab == 0)
		//print "Calling currentLines"
		drawCurrentLines()
	elseif(gChosenTab == 1)
		//print "Calling currentText"
		drawCurrentText()
	endif
	
	if( exists("XLitho") != 1 || exists("YLitho") != 1)
		// If the litho was not performed at all such waves
		// will not exist. Abort!!!
		print "X, Y Litho waves not found!!!"
		return -1;
	endif
	
	eraseAllLayers()
	
	addNewLayer(0,numpnts(XLitho) -1)
	
	// Drawing completed by now:
	// Duplicate the right waves that are used for rendering
	Duplicate/O root:packages:SmartLitho:XLitho, root:packages:MFP3D:Litho:XLitho
	Duplicate/O root:packages:SmartLitho:YLitho, root:packages:MFP3D:Litho:YLitho
	
	updateMasterWaves(0)
	
	// Avoiding appending instead of overwriting
	Redimension /N=0 XLitho, YLitho
	
	//Lines not rendering for the first time-> Save and then load for now???
	DrawLithoFunc("DrawWave")	
	
	// Calculating the total time to litho:
	CalcLithoTime()
	
	SetDataFolder dfSave
	
	DrawLithoFunc("StopDraw_0")
	
End // drawFreshly

Function drawCurrentLines() 

	//print "drawCurrentLines called"

	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	Wave masterwave = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	Variable scansize = masterwave[0]
	// Note: keep in mind that the scan size will change if the ratio width: height is changed
	// Can assume for now that that is set to 1:1
	
	NVAR gnumlines,glinelength,glinesp,glineangle,gTbord, gBbord, gLbord, gRbord
	
	// setting the scale of the variables correctly to meters:
	Variable linelength = glinelength * 1e-6
	Variable linesp = glinesp * 1e-6
	
	// Coordinates of the actual writing box:
	Variable leftlimit = gLbord * 1e-6
	Variable rightlimit = scansize - (gRbord * 1e-6)
	Variable toplimit =scansize - (gTbord * 1e-6)
	Variable bottomlimit =gBbord * 1e-6
	
	if(leftlimit > rightlimit || toplimit < bottomlimit)
		return -1
	endif
	
	//Pass on these parameters to the actual drawing function:
	drawLines(leftlimit,rightlimit,bottomlimit,toplimit,   gnumlines, linelength, glineangle,linesp)
	
	// Resetting the data folder
	SetDataFolder dfsave
				
End // drawPattern

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////  Main Draw Lines ///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
Function drawLines(xstart,xend,ystart,yend,   numlines, length, dangle,space)
	Variable xstart, xend,ystart,yend,   numlines, length,dangle,space
	
	//print "-------------------------------------------------------------------------------------------------------------------------"
	//print "box coordinates: start : (" + num2str(xstart) + ", " + num2str(ystart) + "), end: (" + num2str(xend) + ", " + num2str(yend) + ")"
	//print "line parameters: " + num2str(numlines) + " lines, angle = " + num2str(dangle) + " degrees, spacing = "+ num2str(space)  + ""
	//print "-------------------------------------------------------------------------------------------------------------------------"
	
	//Convert the angle to radians:
	Variable angle = dangle * (pi/180)
	
	//Check if we're drawing from left-to-right or top-to-bottom using the angle:
	if (dangle >= 15 && dangle <= 165)
       	 // Writing left to right from ceiling
        	// calculate horizontal dist between lines:
        	Variable hspace = space * sin(angle)
        	drawLtoR(xstart, xend, ystart, yend, numlines, length, angle, hspace)
        
    	elseif ((dangle < 15 && dangle >= 0) || (dangle > 165 && dangle <= 180))
       	// Writing top to bottom on the left wall
        	// calculate vertical dist between lines:
        	Variable vspace = abs(space * cos(angle))
        	drawTtoB(xstart, xend, ystart, yend, numlines, length, angle, vspace)
        
    	else
        	return -1
    	endif
End//drawLines

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////Draw Left to Right ///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
Function drawLtoR(xstart, xend, ystart, yend, numlines, length, angle, space)
	Variable xstart, xend, ystart, yend, numlines, length, angle, space
	
	// Still within SmartLitho folder:
	NVAR gLengthPriority,gDirPriority
    
    	Variable ydecrement = abs(length * sin(angle))
    	if(angle == pi/2)
    		ydecrement = min(length,yend-ystart)
    		print ydecrement
    	endif
    	
    	// until now, space was the 
    	// perpendicular distance between the lines.
    	space = space/sin(angle) // sin(x) = sin(pi-x)
    
    	// Accounting for lines jumping outside the bottommost limit
    	if ((yend - ydecrement) < ystart)
    		// if willing to work with whatever max length is fine:
    		if(gLengthPriority == 1) 
        			ydecrement = ystart - yend;
        		elseif(gLengthPriority == 2) 
        			// If very worried about exact length:
        			DoAlert 0, "\t\tError!!\n\n\tLength prescribed > scansize. \n\tNOT drawing pattern"
        			return -1
        		endif
    	endif
    	
    	Variable firstspace = space
    	if(gLengthPriority == 2 || (angle > (5*pi/12) && angle < (7*pi/12)))
    		firstspace = abs(length * cos(angle))
    	endif
    	
    	Variable quant1 = 1+floor((xend-(xstart+firstspace))/space));
    	Variable lastlinecoord = firstspace + (quant1-1)*space - abs(length*cos(angle))
    	Variable quant2 = floor(((xend-xstart)-lastlinecoord)/space)
    	
    	//print "Can draw  " + num2str(quant1) + " lines in first pass and " + num2str(quant2) + " in second pass"
    	
    	Variable tempnum = numlines
    	if(gLengthPriority == 1)
    		numlines = min(quant1+quant2,numlines)
    	else
    		numlines = min(quant1,numlines)
    	endif
    	
    	print "Can draw "+ num2str(numlines) + " of " + num2str(tempnum) + " requested lines"
    	
    	//Make the data holding waves
	Make/O/N=(numlines*3) XLitho
	Make/O/N=(numlines*3) YLitho
	
	// Pass one angle and y position
	Variable ycurrent = yend-ydecrement
	if(angle < (pi/2))
		angle = angle-pi;
		ycurrent = yend		
	endif
	
	//Starting the coordinates  calculation part:
	Variable i = 0
	// Change this variable to allow swapping of starts and ends alternating for lines:
	
	Variable swapstart = 0
	Variable xcurrent = xstart+firstspace
	
	for (i=0; i<3*min(numlines,quant1); i+=3)
	
		// Adding intelligence to swap the start and 
		// end points to cut down the drawing time:
		Variable stpt = i
		Variable endpt = i+1
		
		if ((swapstart == 1 && gDirPriority == 3) || gDirPriority == 2)
			stpt = i+1
			endpt = i
		endif
		
		//Begin point:
		XLitho[stpt] = xcurrent;
        		YLitho[stpt] = ycurrent;
        		
        		//End point:
        		// lines shooting leftward
        		XLitho[endpt] = max(xstart, xcurrent + length*cos(angle))
        		if(angle == pi/2)
    			YLitho[endpt] = yend
    		else
    			YLitho[endpt] = tan(angle)*(XLitho[endpt]-XLitho[stpt]) + YLitho[stpt]
    		endif
        	
        		// Setting the swap:
        		if (swapstart == 0 && gDirPriority == 3)
        			swapstart = 1
       	 	else
        			swapstart = 0
        		endif
        	
        		//Empy space:
        		XLitho[i+2] = nan
		YLitho[i+2] = nan
		
		xcurrent = xcurrent + space;
      
	endfor
	
	if(numlines - min(numlines,quant1) == 0)
		//print "No pass 2 requested"
		return 0; // done here
	endif
	
	// Now drawing pass #2:
	
	xcurrent = xcurrent + length*cos(angle)
	
	if(angle < 0)
		angle = angle+pi // bring back to original
		ycurrent = yend-ydecrement
	else
		// for angle > pi/2
		ycurrent = yend
		angle = angle-pi
	endif
	
	Variable j=i

	for (i=j; i<3*numlines; i+=3)
	
		// Adding intelligence to swap the start and 
		// end points to cut down the drawing time:
		stpt = i+1
		endpt = i
		
		if ((swapstart == 1 && gDirPriority == 3) || gDirPriority == 2)
			stpt = i
			endpt = i+1
		endif
		
		//Begin point:
		XLitho[stpt] = xcurrent;
        		YLitho[stpt] = ycurrent;
        		
        		//End point:
        		// lines shooting rightward
        		XLitho[endpt] = min(xend, xcurrent + length*cos(angle))
        		if(angle == pi/2)
    			YLitho[endpt] = yend-ydecrement // won't be coming here anyway.
    		else
    			YLitho[endpt] = tan(angle)*(XLitho[endpt]-XLitho[stpt]) + YLitho[stpt]
    		endif
        	
        		// Setting the swap:
        		if (swapstart == 0 && gDirPriority == 3)
        			swapstart = 1
       	 	else
        			swapstart = 0
        		endif
        	
        		//Empy space:
        		XLitho[i+2] = nan
		YLitho[i+2] = nan
		
		xcurrent = xcurrent + space;
		
	endfor
	
End //drawLtoR

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////Draw Top to Bottom ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function drawTtoB(xstart, xend, ystart, yend, numlines, length, angle, space)
	Variable xstart, xend, ystart, yend, numlines, length, angle, space
	   	
    	Variable xincrement = abs(length * cos(angle));
    	
    	// Still within SmartLitho folder:
	NVAR gLengthPriority,gDirPriority
    	
    	// Accounting for lines jumping outside the rightmost limit
    	if((xstart + xincrement) > xend)
        	// if willing to work with whatever max length is fine:
    		if(gLengthPriority == 1) 
        		xincrement = xend - xstart;
        	elseif(gLengthPriority == 2) 
        		//more stringent requirements of EXACT line 
        		// lengths only:
        		DoAlert 0, "\t\tError!!\n\n\tLines too long. \n\tLitho aborting"
        		return -1
        	endif
    	endif
    	
    	// Similar simple limit cannot be placed yet
    	// y truncation must be done at time of addition
    	// to matrix
    	Variable yincrement = abs(length * sin(angle));
    	
    	// default: angles in 1st quadrant:
    	// step down one step:
    	Variable ycurrent = yend - yincrement;
    	
    	if((angle * (180/pi)) > 90 || angle == 0)
    	
    		//bringing back the default start y:
    		// for 2nd quadrant angles:
    		ycurrent = ycurrent + yincrement;
    		
    		// Only for angles in the III quadrant:
        	yincrement = yincrement * -1;
        	// Accounts for the first line completely
        	// going outside the the field in case
        	// of small angles
    	endif
    
    	// Check how many lines can actually be drawn with the
    	// given gap:
    	Variable tempnum = numlines
    	
    	if(gLengthPriority == 1) 
    		//allowing truncation of lines:
    		numlines = min( numlines,abs( floor( (ystart - ycurrent)/space)));
    	elseif(gLengthPriority == 2) 
    		// For more stringent requirements - no truncated lines may be drawn:
    	    	numlines = min (numlines, floor(abs((    (     abs(ystart - yend) - abs(yincrement)    ) / space  ) + 1)))
    	endif
    	
    	if(tempnum != numlines)
    		DoAlert 0, "\t\tWarning!\n\nNumber of lines now changed from " + num2str(tempnum) + " to "+ num2str(numlines) + "\nClick 'Undo' if not desirable"
    	endif
    	
    	//Make the data holding waves
	Make/O/N=(numlines*3) XLitho
	Make/O/N=(numlines*3) YLitho

	//Starting the coordinates  calculation part:
	Variable i = 0
	
	Variable swapstart = 0
	
	for (i=0; i<3*numlines; i+=3)
	
		// Adding intelligence to swap the start and 
		// end points to cut down the drawing time:
		Variable stpt = i
		Variable endpt = i+1
		
		if ((swapstart == 1 && gDirPriority == 3) || gDirPriority == 2)
			stpt = i+1
			endpt = i
		endif
	
		// Begin point
        	XLitho[stpt] = xstart;
        	YLitho[stpt] = ycurrent;
            
            // End point
        	if((yincrement + ycurrent) < ystart)
            		// This happens for angles > 165 only:
            		// the end point is dipping below the
            		// allowable frame. Must truncate the
            		// end point:
            
            		// Using point slope method to determine
            		// ending x position:
            		XLitho[endpt] = ((ystart - ycurrent)/tan(angle)) + xstart;
            		YLitho[endpt] = ystart;
        	elseif (yincrement + ycurrent > yend)
            		// This happens for angles <15 only:
            		// The end point is above the top limit
            		XLitho[endpt] = ((yend - ycurrent)/tan(angle)) + xstart;
            		YLitho[endpt] = yend;
        	else
            		XLitho[endpt] = xstart + xincrement;
            		YLitho[endpt] = ycurrent + yincrement;
        	endif
           
        	ycurrent = ycurrent - space;
        	
        	// Setting the swap:
        	if (swapstart == 0 && gDirPriority == 3)
        		swapstart = 1
        	else
        		swapstart = 0
        	endif
        	
        	//Empy space:
        	XLitho[i+2] = nan
		YLitho[i+2] = nan
        
        	// Y position cut off:
        	if(ycurrent <= ystart)
            		break;
        	endif
    endfor

End//drawToB