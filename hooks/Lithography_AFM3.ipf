#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=5.00				//WaveStats/M=1
#pragma ModuleName=Lithography


StrConstant cGDSPN = "GDSGraph"
StrConstant cGDSTN = "GDSTable"
constant cLithoSleepTics = 30		//we will often sleep for 30 tics
StrConstant cLithoBitMapFolder = "Root:Packages:MFP3D:LithoBitMap:"
StrConstant cPlotterManagerName = "PlotterManagerPanel"


Function MakeMasterLithoPanel()

	Variable ScrRes = 72/ScreenResolution			//compensation factor for screen resolution
	String GraphStr = "MasterLithoPanel"
	Wave PanelParm = root:Packages:MFP3D:Main:Windows:MasterLithoPanelParms		//grab the panel parm Wave
	
	
	Struct ARWindowStruct WindowStruct
	WindowStruct.Left = PanelParm[%WindowLeft][0]
	WindowStruct.Right = PanelParm[%WindowRight][0]
	WindowStruct.Top = PanelParm[%WindowTop][0]
	WindowStruct.Bottom = PanelParm[%WindowBottom][0]
	WindowStruct.GraphStr = GraphStr
	WindowStruct.HookFunc = "PanelHook"
	WindowStruct.KillFlag = 1
	WindowStruct.TitleStr = "Master Litho Panel"
	
	ARSafeNewWindow(WindowStruct)
	GraphStr = WindowStruct.GraphStr

	
	Variable FontSize = 13
	String ControlName = ARPanelMasterLookup(GraphStr,IsTab=1)
	
	TabControl $ControlName,win=$GraphStr,tabLabel(0)="MicroAngelo™",tabLabel(1)="Groups",tabLabel(2)="Step",TabLabel(3)="Bitmap"
	TabControl $ControlName,win=$GraphStr,pos={6,10},proc=PreTabFunc,size={GetMinTabSize(GraphStr,ControlName),20},font="Arial",fsize=FontSize

	MakeLithoPanel(0)
	MakeLithoGroupPanel(0)
	MakeLithoStepPanel(0)
	MakeLithoBitmapPanel(0)

	TabFunc(ControlName,GraphStr,PanelParm[%LastTab][0],PanelParm[%LastTab][0])		//set the visible panel to what the LastTab is
	PanelParm[%ShowPanel][0] = 1		//let 'em know that we are up

End //MakeMasterLithoPanel


Function MakeLithoStepPanel(Var)		//make the litho panel
	Variable Var		//used
	
	String DataFolder = GetDF("Windows")
	
	String GraphStr = GetFuncName()
	GraphStr = GraphStr[4,Strlen(GraphStr)-1]
	Wave PanelParms = $DataFolder+GraphStr+"Parms"
	String MasterPanel = ARPanelMasterLookup(GraphStr)
	Wave MasterParms = $DataFolder+MasterPanel+"Parms"
	

	Variable TabNum = ARPanelTabNumLookup(GraphStr)
	String TabStr = "_"+num2str(TabNum)
	String SetupTabStr =  TabStr+"9"
	
	
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(GetDF("Litho"))
	Make/O LithoTimeWave, LithoStepX, LithoStepY, LithoStepVoltX, LithoStepVoltY
	SetDataFolder(SavedDataFolder)

	
	Variable CurrentTop, Enab = 0
	String SetupFunc = "", MakeTitle = "", MakeName = "", SetupName = ""
	if (Var == 0)		//MasterLithoPanel
		GraphStr = MasterPanel
		CurrentTop = 40
		SetupName = GraphStr+"Setup"+TabStr
		MakeTitle = "Make Litho Step Panel"
		MakeName = "LithoStepButton"+TabStr
		Enab = 1		//Tabfunc, you are in charge!
	elseif (Var == 1)		//LithoStepPanel
		CurrentTop = 10
		SetupName = "LithoStepPanelSetup"+TabStr
		MakeName = "MasterLitho"+Tabstr
		MakeTitle = "Make Master Litho Panel"
	endif
	SetupFunc = "ARSetupPanel"
	
	Variable DisableHelp = 0				//OK, so we finally have a help file.
	
	Variable FirstSetVar = PanelParms[%FirstSetVar][0]
	Variable SetVarWidth = PanelParms[%SetVarWidth][0]
	Variable FirstText = PanelParms[%FirstText][0]
	Variable TextWidth = PanelParms[%TextWidth][0]
	Variable TitleWidth = PanelParms[%TitleWidth][0]
	Variable HelpPos = PanelParms[%HelpPos][0]
	Variable Control1Bit = PanelParms[%Control1Bit][0]
	Variable oldControl1Bit = PanelParms[%oldControl1Bit][0]
	Variable SetupLeft = PanelParms[%SetupLeft][0]
	Variable BodyWidth = PanelParms[%BodyWidth][0]
	String HelpFuncStr = "ARHelpFunc"
	Variable StepSize = 25
	
	Variable FontSize = 14
	Struct ARImagingModeStruct ImagingModeParms
	ARGetImagingMode(ImagingModeParms)
	
	
	String ControlName = "", ParmName = ""
	ParmName = ImagingModeParms.SetpointParm
	
	//All of the controls have either a _2 or _29 at the end so that they show up at the correct times. The _29 are setup controls and only show up then.
	Variable bit = 0
	if (2^bit & Control1Bit)
		ControlName = "SetpointSetVar"+TabStr
		MakeSetVar(GraphStr,ControlName,ParmName,"Normal Set Point","LithoStepSetVarFunc","",FirstSetVar,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"Setpoint"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1
	
	if (2^bit & Control1Bit)
		MakeSetVar(GraphStr,"","LithoSetpointVolts","Litho Set Point","LithoStepSetVarFunc","",FirstSetVar,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"Litho_Setpoint"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	if (2^bit & Control1Bit)
		MakeSetVar(GraphStr,"","LithoXCount","X Count","LithoStepSetVarFunc","",FirstSetVar,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"LithoXCount"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1
	
	if (2^bit & Control1Bit)
		MakeSetVar(GraphStr,"","LithoYCount","Y Count","LithoStepSetVarFunc","",FirstSetVar,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"LithoYCount"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1
	
	if (2^bit & Control1Bit)
		MakeSetVar(GraphStr,"","LithoXStep","X Step","LithoStepSetVarFunc","",FirstSetVar,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"Litho_Xstep"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	if (2^bit & Control1Bit)
		MakeSetVar(GraphStr,"","LithoYStep","Y Step","LithoStepSetVarFunc","",FirstSetVar,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"Litho_Ystep"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	if (2^bit & Control1Bit)
		MakeSetVar(GraphStr,"","LithoTimeStart","Time Start","LithoStepSetVarFunc","",FirstSetVar,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"LithoTimeStart"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	if (2^bit & Control1Bit)
		MakeSetVar(GraphStr,"","LithoTimeStep","Time Step","LithoStepSetVarFunc","",FirstSetVar,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"LithoTimeStep"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	if (2^bit & Control1Bit)
		MakeButton(GraphStr,"UpdateTime"+TabStr,"Update Time",100,20,FirstText,CurrentTop,"LithoStepFunc",Enab)
		MakeButton(GraphStr,"EditTime"+TabStr,"Edit Time",100,20,FirstSetVar+20,CurrentTop,"LithoStepFunc",Enab)
		
		MakeButton(GraphStr,"Update_Time"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	//Mode popup
	if (2^bit & Control1Bit)
		ControlName = "ImagingModePopup"+TabStr
		UpdatePopup(GraphStr,ControlName,"Litho Mode",45,CurrentTop,"MainPopupFunc","ImageModeList()",ImagingModeParms.ImagingMode+1,Enab)
		
		MakeButton(GraphStr,"Litho_Mode"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += 30
	endif
	bit += 1
	

	//Bias
	if (2^bit & Control1Bit)

		ControlName = "LithoStepUseBiasCheck"+TabStr
		UpdateCheckBox(GraphStr,ControlName,"Use Bias",FirstSetVar-20,CurrentTop,"LithoBoxFunc",GV("LithoStepUseBias"),0,Enab)

		MakeButton(GraphStr,"LithoStepUseBias"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1
	
	
	//use Wave
	if (2^bit & Control1Bit)

		ControlName = "LithoStepUseWaveCheck"+TabStr
		UpdateCheckBox(GraphStr,ControlName,"Use Wave",FirstSetVar-20,CurrentTop,"LithoBoxFunc",GV("LithoStepUseWave"),0,Enab)

		MakeButton(GraphStr,"LithoStepUseWave"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1
	
	
	

	if (2^bit & Control1Bit)

		MakeSetVar(GraphStr,"","LithoStartVolts","Volt Start","LithoStepSetVarFunc","",FirstSetVar,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"LithoStartVolts"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	if (2^bit & Control1Bit)
		MakeSetVar(GraphStr,"","LithoEndVolts","Volt End","LithoStepSetVarFunc","",FirstSetVar,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"LithoEndVolts"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	if (2^bit & Control1Bit)
		MakeButton(GraphStr,"UpdateVolts"+TabStr,"Update Volts",100,20,FirstText,CurrentTop,"LithoStepFunc",Enab)
		MakeButton(GraphStr,"EditVolts"+TabStr,"Edit Volts",100,20,FirstSetVar+20,CurrentTop,"LithoStepFunc",Enab)
		
		MakeButton(GraphStr,"Update_Volts"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	if (2^bit & Control1Bit)
		MakeButton(GraphStr,"AppendGrid"+TabStr,"Append Grid",100,20,FirstText,CurrentTop,"LithoStepFunc",Enab)
		MakeButton(GraphStr,"RemoveGrid"+TabStr,"Remove Grid",100,20,FirstSetVar+20,CurrentTop,"LithoStepFunc",Enab)
		
		MakeButton(GraphStr,"Append_Grid"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	if (2^bit & Control1Bit)
		MakeButton(GraphStr,"DoStepLitho"+TabStr,"Do It",80,20,(HelpPos-FirstText)/2-40,CurrentTop,"LithoStepFunc",Enab)
		MakeButton(GraphStr,"StopStepLitho"+TabStr,"Stop",80,20,(HelpPos-FirstText)/2-40,CurrentTop,"LithoStepFunc",Enab)
		
		MakeButton(GraphStr,"Do_Step_Litho"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1


	if (2^bit & Control1Bit)
		MakeButton(GraphStr,MakeName,MakeTitle,180,20,(HelpPos-FirstText)/2-90,CurrentTop,"MakePanelProc",Enab)
	
		MakeButton(GraphStr,"Make_Other_Litho_Step_Panel"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoStepBit_"+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1


	MakeButton(GraphStr,SetupName,"Setup",80,20,(HelpPos-FirstText)/2-40,CurrentTop,SetupFunc,Enab)
	MakeButton(GraphStr,"Litho_Step_Setup"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
	
	CurrentTop += StepSize
	
	PanelParms[%CurrentBottom][0] = CurrentTop		//save the bottom position of the controls
	
End //MakeLithoStepPanel


Function LithoStepSetVarFunc(ctrlName,varNum,varStr,varName)
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	
	if (!Strlen(VarName))
		DoAlert 0,"You can no longer pass empty string for VarName to "+GetFuncName()
		return(0)
	endif
	
	String ParmStr = ARConvertVarName2ParmName(VarName)
	
	
	
	UnitsCalcFunc(ParmStr+"SetVar",varNum,varStr,varName)		//this calculates any typed in units and also returns the new varNum
	varNum = Safelimit(varNum,GVL(ParmStr),GVH(ParmStr))		//make sure that the number is in its limits
	PV(ParmStr,varNum)			//put the value where it belongs
	newUpdateFormat(ParmStr)
	if (!StringMatch(CtrlName,"*Count*"))
		NewUpdateClickVar(ParmStr,varNum)
		newUpdateFormat(ParmStr)
	endif
	UpdateUnits(ParmStr,varNum)
	
	
	String GraphStr = StringFromList(0,WinList("Channel*Image*",";","WIN:4097"),";")
	if (!Strlen(GraphStr))
		print "Please bring up a realtime image"
		DoWindow/H
		return(0)
	endif
	if (WinType(GraphStr) == 13)		//argyle
		Wave ImageWave = $ArGL_ReadString(GraphStr,"wave")
	else
		Wave ImageWave = ImageNameToWaveRef(GraphStr,StringFromList(0,ImageNameList(graphStr,";"),";"))
	endif
	Variable MaxX = DimSize(ImageWave,0)*DimDelta(ImageWave,0)
	Variable MaxY = DimSize(ImageWave,1)*DimDelta(ImageWave,1)
	
	Variable LithoYCount = GV("LithoYCount")
	Variable LithoXCount = GV("LithoXCount")
	Variable LithoXStep = GV("LithoXStep")
	Variable LithoYStep = GV("LithoYStep")
	Variable NewMax
	
	Wave LithoStepY = root:Packages:MFP3D:Litho:LithoStepY
	Wave LithoStepX = root:Packages:MFP3D:Litho:LithoStepX
	Wave LithoTimeWave = root:Packages:MFP3D:Litho:LithoTimeWave
	Wave LithoVolts = root:Packages:MFP3D:Litho:LithoVolts

	strswitch (ParmStr)
		
		case "LithoYCount":
			VarNum = Round(VarNum)
			NewMax = min(MaxY/(varNum-1),1e5)		//10 µm
			LithoYStep = Limit(LithoYStep,GVL("LithoYStep"),NewMax)
			PV("LithoYStep",LithoYStep)
			PV(ParmStr,varNum)
			Redimension/N=(varNum*GV("LithoXCount")) LithoStepY, LithoStepX, LithoTimeWave, LithoVolts
			DoStepLithoWaves()
			break
			
		case "LithoXCount":
			VarNum = Round(VarNum)
			NewMax = min(MaxX/(varNum-1),1e5)
			LithoXStep = Limit(LithoXStep,GVL("LithoXStep"),NewMax)
			PV("LithoXStep",LithoXStep)
			PV(ParmStr,varNum)
			Redimension/N=(GV("LithoYCount")*varNum) LithoStepY, LithoStepX, LithoTimeWave, LithoVolts
			DoStepLithoWaves()
			break
			
		case "LithoYStep":
			newMax = limit(floor(MaxY/Varnum)+1,1,25)
			LithoYCount = Limit(LithoYCount,GVL("LithoYCount"),newMax)
			PV("LithoYCount",LithoYCount)
			PV(ParmStr,VarNum)
			Redimension/N=(LithoYCount*LithoXCount) LithoStepY, LithoStepX, LithoTimeWave, LithoVolts
			DoStepLithoWaves()
			break
			
		case "LithoXStep":
			NewMax = limit(floor(MaxX/Varnum)+1,1,25)
			LithoXCount = Limit(LithoXCount,GVL("LithoXCount"),NewMax)
			PV("LithoXCount",LithoXCount)
			PV(ParmStr,VarNum)
			Redimension/N=(LithoYCount*LithoXCount) LithoStepY, LithoStepX, LithoTimeWave, LithoVolts
			DoStepLithoWaves()
			break
	
	endswitch

End //LithoStepSetVarFunc


Function LithoStepFunc(ctrlName)
	String ctrlName
	
	
	//let make sure the user has set at least 1 parameter so that we have enforeced limits.
	
	Variable TabNum = ARPanelTabNumLookup("LithoStep")
	String TabStr = "_"+Num2str(TabNum)
	
	LithoStepSetVarFunc("LithoXCountSetVar"+TabStr,GV("LithoXCount"),num2str(GV("LithoXCount")),":LithoVariablesWave[%LithoXCount]")
	LithoStepSetVarFunc("LithoYCountSetVar"+TabStr,GV("LithoYCount"),num2str(GV("LithoYCount")),":LithoVariablesWave[%LithoYCount]")
	
	
	Variable RemInd = FindLast(CtrlName,"_")
	if (RemInd > -1)
		CtrlName = CtrlName[0,RemInd-1]
	endif
	
	Variable ScrRes = 72/ScreenResolution
	Variable Width,height
	ARScreenSize(Width,Height)

	String graphStr
	strswitch (ctrlName)
		
		case "UpdateTime":
			UpdateStepLithoTime()
			break
		
		case "EditTime":
			DoWindow/F LithoStepTime
			if (V_flag)
				return 0
			endif
			Edit/K=1/N=LithoStepTime/W=(3,44,175,Height*ScrRes) root:Packages:MFP3D:Litho:LithoTimeWave
			break

		case "UpdateVolts":
			UpdateStepLithoVolts()
			break
		
		case "EditVolts":
			DoWindow/F LithoVoltsTable
			if (V_flag)
				return 0
			endif
			Edit/K=1/N=LithoVoltsTable/W=(3,44,175,Height*ScrRes) root:Packages:MFP3D:Litho:LithoVolts
			break

		case "AppendGrid":
			graphStr = StringFromList(0,WinList("Channel*Image*",";","WIN:1"),";")		//get the top realtime graph
			if ((strlen(graphStr) == 0) && GV("RealArgyleReal"))
				ImageChannelCheckFunc("RealArgyleRealBox_1",0)
				graphStr = StringFromList(0,WinList("Channel*Image*",";","WIN:1"),";")		//get the top realtime graph
			endif
			if (strlen(graphStr) == 0)
				DoAlert 0, "There doesn't seem to be an appropriate graph."			//there isn't one!
				return 1
			endif
			DoWindow/F $graphStr
			if (!Stringmatch(TraceNameList(graphStr,";",1),"*LithoStepY*"))	//see if the litho Wave is already displayed
				DoStepLithoWaves()
				AppendToGraph root:Packages:MFP3D:Litho:LithoStepY Vs root:Packages:MFP3D:Litho:LithoStepX						//if not, add it
				ModifyGraph rgb(LithoStepY)=(0,0,65535),mode(LithoStepY)=3,marker(LithoStepY)=19					//and make it blue
				Wave ImageWave = ImageNameToWaveRef(graphStr,StringFromList(0,ImageNameList(graphStr,";")))	//reference the image Wave
				UpdateLithoSize(ImageWave)
			endif
			break
			
		case "RemoveGrid":
			graphStr = StringFromList(0,WinList("Channel*Image*",";","WIN:1"))		//get the top realtime graph
			if (strlen(graphStr) == 0)
				return 1
			endif
			RemoveFromGraph/Z/W=$graphStr LithoStepY
			break	

		case "DoStepLitho":
			AR_Stop(OKList="FreqFB;")
			ARManageRunning("Litho",1)
			DoStepLitho()
			//UpdateAllControls("DoStepLitho"+TabStr,"Stop!!","StopLitho"+TabStr,"DrawLithoFunc",DropEnd=1)
			//GhostLithoStepPanel()
			break
			
		case "StopStepLitho":
			DoLithoFunc("StopLitho_0")
			break

	endswitch

End //LithoStepFunc


Function DoStepLithoWaves()

	Wave RVW = $GetDF("Variables")+"RealVariablesWave"
	Variable yCount = GV("LithoYCount")
	Variable xCount = GV("LithoXCount")
	Variable yStep = GV("LithoYStep")
	Variable xStep = GV("LithoXStep")
	Variable yStart = RVW[%SlowScanSize][0]/2-yStep*(yCount-1)/2
	Variable xStart = RVW[%FastScanSize][0]/2-xStep*(xCount-1)/2

	Wave LithoStepY = root:Packages:MFP3D:Litho:LithoStepY
	Wave LithoStepX = root:Packages:MFP3D:Litho:LithoStepX

	LithoStepY = yStart+floor(p/xCount)*yStep
	LithoStepX = xStart+mod(p,xCount)*xStep

End //DoStepLithoWaves


Function UpdateStepLithoTime()

	Wave LithoTimeWave = root:Packages:MFP3D:Litho:LithoTimeWave
	Variable start = GV("LithoTimeStart")
	Variable step = GV("LithoTimeStep")
	LithoTimeWave = start+p*step
	
End //UpdateStepLithoTime


Function UpdateStepLithoVolts()

	Wave LithoVolts = root:Packages:MFP3D:Litho:LithoVolts
	Variable start = GV("LithoStartVolts")
	Variable stop = GV("LithoEndVolts")
	Variable step = (stop-start)/(DimSize(LithoVolts,0)-1)
	LithoVolts = start+p*step
	
End //UpdateStepLithoTime


Function DoStepLitho()
	

	if (GV("DoThermal"))
		DoThermalFunc("StopThermalButton_1")
	endif

	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(GetDF("Litho"))		//it all happens in here

	String ErrorStr = ""
	ErrorStr += num2str(td_StopOutWaveBank(-1))+","
	ErrorStr += IR_StopInWaveBank(-1)
	
	
	Wave RVW = $GetDF("Variables")+"RealVariablesWave"
	
	Variable ScanSpeed = RVW[%FastScanSize][0]*RVW[%ScanRate][0]*2.5
	Variable XOffset = RVW[%XOffset][0]
	Variable YOffset = RVW[%YOffset][0]
	Variable XLVDTSens = GV("XLVDTSens")
	Variable YLVDTSens = GV("YLVDTSens")
	Variable xLVDTOffset = GV("XLVDTOffset")
	Variable yLVDTOffset = GV("YLVDTOffset")
	Variable UseBias = GV("LithoStepUseBias")
	Struct ARImagingModeStruct ImagingModeParms
	ARGetImagingMode(ImagingModeParms)
	Variable ScanAngle = RVW[%ScanAngle][0]*pi/180
	PV("ElectricTune",0)

	
	SetScanBandwidth()
	
	//clear the bias always.
	LoadXPTState("Litho")
	
	String WeDriveThis = ""
	Struct ARTipHolderParms TipParms
	ARGetTipParms(TipParms)
	if (TipParms.IsOrca)
		WeDriveThis = "SurfaceBias"		//can't believe this would work.
	elseif (TipParms.IsDiffDrive)
		WeDriveThis = "TipHeaterDrive"
	else
		WeDriveThis = "TipBias"
	endif
	
	if (UseBias)
		ErrorStr += num2str(ir_WriteValue(WeDriveThis,0))+","		//Set after xpt is setup?
	endif
	
	//startup the Z feedback
	//ErrorStr += InitZFeedback(2,"Always")
	ErrorStr += InitZFeedback(ImagingModeParms)
	


	String graphStr = StringFromList(0,WinList("Channel*Image*",";","WIN:1"),";")		//get the top realtime graph
	Wave ImageWave = ImageNameToWaveRef(graphStr,StringFromList(0,ImageNameList(graphStr,";")))	//reference the image Wave
	UpdateLithoSize(ImageWave)




	Struct ARFeedbackStruct FB
	ARGetFeedbackParms(FB,"outputX")
	FB.SetpointOffset = XOffset/abs(XLVDTSens)+xLVDTOffset
	FB.Setpoint = td_ReadValue(FB.Input)-FB.SetpointOffset
	Variable XStart = FB.Setpoint
	IR_WritePIDSloop(FB)

	ARGetFeedbackParms(FB,"outputY")
	FB.SetpointOffset = YOffset/abs(YLVDTSens)+yLVDTOffset
	FB.Setpoint = td_ReadValue(FB.Input)-FB.SetpointOffset
	Variable YStart = FB.Setpoint
	IR_WritePIDSloop(FB)


	Sleep/T cLithoSleepTics												//wait for things to settle

	Wave LithoStepY, LithoStepX, LithoStepVoltY, LithoStepVoltX										//these are the litho Waves
	Wave/C AngleWave = $InitOrDefaultWave("AngleWave",0)
	Redimension/N=(DimSize(LithoStepY,0)) LithoStepVoltY, LithoStepVoltX
	Redimension/N=(DimSize(LithoStepY,0))/C AngleWave
		
	AngleWave[] = cmplx(LithoStepX[P]-RVW[%FastScanSize][0]/2,LithoStepY[P]-RVW[%SlowScanSize][0]/2)
	AngleWave = r2Polar(AngleWave)-cmplx(0,ScanAngle)
	LithoStepVoltY[] = (Imag(P2Rect(AngleWave[P])))/abs(YLVDTSens)//+YLVDTOffset
	LithoStepVoltX[] = (Real(P2Rect(AngleWave[P])))/abs(XLVDTSens)//+XLVDTOffset
	
//		AngleWave = cmplx(xTemp,yTemp)
//		AngleWave = r2polar(AngleWave)-cmplx(0,scanAngle)
//		yEnd = (YOffset+Imag(p2rect(AngleWave[0])))/YLVDTSens+YLVDTOffset
//		xEnd = (XOffset+Real(p2rect(AngleWave[0])))/XLVDTSens+XLVDTOffset
//
//
//
//FindThis
//	LithoStepVoltY = (LithoStepY-ScanSize/2)/YLVDTSens
//	LithoStepVoltX = (LithoStepX-ScanSize/2)/xLVDTSens
	
	PV("LithoIndex",0)										//reset the index to 0
	PV("LithoRunning",3)
	GhostLithoPanel()
	
	Make/O/N=1 YPoint, XPoint, DisplayHeight, DisplayDeflection

	Make/O/N=1 YPoint, XPoint
	if (Stringmatch(TraceNameList(graphStr,";",1),"*YPoint*") == 0)
		AppendToGraph/W=$graphStr YPoint vs XPoint
		ModifyGraph/W=$graphStr mode(YPoint)=3,marker(YPoint)=19,msize(YPoint)=3
		MoveTrace2Top(GraphStr,"YPoint")
	endif

	ARBackground("RedSpotBackground",0,"")		//stop the red spot, we are in control
	ARBackground("LithoBackground",60,"")
	
	Variable rampInterpX, rampInterpY, rampInterp		//make interpolation Variables
	Variable DoX = MakeRamp(0,"$OutputXLoop.Setpoint",XStart,(LithoStepVoltX[0]),ScanSpeed/(abs(XLVDTSens)*4),1,rampInterpX)	//now with a 5um/S lowest speed
	Variable DoY = MakeRamp(1,"$OutputYLoop.Setpoint",YStart,(LithoStepVoltY[0]),ScanSpeed/(abs(YLVDTSens)*4),1,rampInterpY)
	if (DoX || DoY)							//check if we have to run the ramp
		Make/O/N=(256) dummyWave
		ErrorStr += IR_StopInWaveBank(-1)

		if (rampInterpX < rampInterpY)		//we want the big one
			rampInterp = rampInterpY			//use the big one
		else
			rampInterp = rampInterpX
		endif

		//this will call ActualLitho when the ramp is through
		ErrorStr += IR_XSetInWave(0,"0","output.Dummy",DummyWave,"ActualStepLitho(0)",rampInterp)
		//start the ramp
		ErrorStr += num2str(td_WriteString("Event.0","Once"))+","
	else
		ErrorStr += num2str(ir_WriteValue("$OutputXLoop.Setpoint",LithoStepVoltX[0]))+","
		ErrorStr += num2str(ir_WriteValue("$OutputYLoop.Setpoint",LithoStepVoltY[0]))+","
		ActualStepLitho(0)										//the ramp didn't need to run, call ActualLitho
	endif

	SetDataFolder(SavedDataFolder)
	if (ImagingModeParms.ImagingMode == 0)
		NVAR Amplitude = root:Packages:MFP3D:Meter:Amplitude
		Amplitude = 0
	endif
	ARReportError(ErrorStr)

	return(0)

End //DoStepLitho


Function ActualStepLitho(LithoCount)			//this does the actual lithography
	Variable LithoCount
	
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(GetDF("Litho"))		//it all happens in here

	Variable LithoIndex = GV("LithoIndex")			//this is the start of the current segment
	Variable XLVDTSens = GV("XLVDTSens")
	Variable YLVDTSens = GV("YLVDTSens")
	Variable LithoFastScanSize = GV("LithoFastScanSize")
	Variable LithoSlowScanSize = GV("LithoSlowScanSize")
	Variable LithoMax = GV("LithoMax")
	Variable Interpolation = 3330*2
	Variable decimation = 100
	Wave LithoStepVoltY, LithoStepVoltX, LithoTimeWave, LithoVolts
	Variable i
	Variable UseBias = GV("LithoStepUseBias")
	Variable UseStepWave = GV("LithoStepUseWave")
	Variable LithoSetpoint = GV("LithoSetpointVolts")
	
	
	Variable inputPoints = round(LithoTimeWave[LithoCount]*1000)
	Variable extra = 32-mod(inputPoints,32)
	inputPoints += extra			//extra is the difference from being divisible by 32
	PV("LithoExtra",extra)
	Make/O/N=(inputPoints) Deflection, Height, Lateral, Amplitude, Current
	Wave Deflection = Deflection
	Wave Height = Height
	SetDataFolder(SavedDataFolder)

	
	String ErrorStr = ""
	//stop before setting the out Waves
	ErrorStr += num2str(td_StopOutWaveBank(-1))+","
	//stop before setting the in Waves
	ErrorStr += IR_StopInWaveBank(-1)

	
	LithoBackground()
	
	String WeDriveThis = ""
	Struct ARTipHolderParms TipParms
	ARGetTipParms(TipParms)
	if (TipParms.IsOrca)
		WeDriveThis = "SurfaceBias"		//can't believe this would work.
	elseif (TipParms.IsDiffDrive)
		WeDriveThis = "TipHeaterDrive"
	else
		WeDriveThis = "TipBias"
	endif
	
	
	
	if (UseStepWave)
		if (UseBias)
			//set the litho bias
			ErrorStr += num2str(ir_WriteValue(WeDriveThis,LithoVolts[LithoCount]))+","
			ErrorStr += num2str(ir_WriteValue("$HeightLoop.Setpoint",LithoSetpoint))+","
		else
			//set the litho setpoint
			ErrorStr += num2str(ir_WriteValue("$HeightLoop.Setpoint",LithoVolts[LithoCount]))+","
		endif
	else
		//set the litho bias
		if (UseBias)
			ErrorStr += num2str(ir_WriteValue(WeDriveThis,GV("LithoStartVolts")))+","
		endif
		//set the litho setpoint
		ErrorStr += num2str(ir_WriteValue("$HeightLoop.Setpoint",LithoSetpoint))+","
	endif
	
	Sleep/T cLithoSleepTics																	//wait for things to settle
	LithoBackground()



//	ErrorStr += IR_XSetInWavePair(0,"0","Fast%Input",Deflection,"ZSensor",Height,"LithoStepRamp("+num2str(LithoCount+1)+")",decimation)
//this calls the next part	
	
	//this calls the next part	
	//the deflection is NOT the alias.  In AC mode, Input.Fast is ACDefl
	//just read it anyway.  Not right, but not entirly wrong (no errors)
	ErrorStr += IR_XSetInWavePair(0,"0","input.Fast",Deflection,"ZSensor",Height,"LithoStepRamp("+num2str(LithoCount+1)+")",Decimation)
	ErrorStr += IR_XSetInWavePair(1,"0","Lateral",Lateral,"Amplitude",Amplitude,"",Decimation)
	ErrorStr += IR_XSetInWave(2,"0","Current",Current,"",Decimation)
	
	
 
	//set everything going
	ErrorStr += num2str(td_WriteString("Event.0","Once"))+","


	ARReportError(ErrorStr)
	return(0)
	
End //ActualStepLitho


Function LithoStepRamp(LithoCount)		//this function moves between litho segments
	Variable LithoCount

	String ErrorStr = ""
	//reset the setpoint to normal
	
	
	Struct ARImagingModeStruct ImagingModeParms
	ARGetImagingMode(ImagingModeParms)
	Variable Setpoint = ImagingModeParms.Feedback[0].Setpoint
	ErrorStr += num2str(ir_WriteValue("$HeightLoop.Setpoint",Setpoint))+","
	
	Variable UseBias = GV("LithoStepUseBias")
	Variable UseStepWave = GV("LithoStepUseWave")
	String WeDriveThis = ""
	Struct ARTipHolderParms TipParms
	ARGetTipParms(TipParms)
	if (TipParms.IsOrca)
		WeDriveThis = "SurfaceBias"		//can't believe this would work.
	elseif (TipParms.IsDiffDrive)
		WeDriveThis = "TipHeaterDrive"
	else
		WeDriveThis = "TipBias"
	endif
	
	if (UseBias)
		//set the litho Bias
		ErrorStr += num2str(ir_WriteValue(WeDriveThis,0))+","
	endif
	
	
	
	NVAR Sum = root:Packages:MFP3D:Meter:Sum
	Sum = td_ReadValue("DetectorSum")
	ErrorStr += num2str(td_StopOutWaveBank(-1))+","

	Sleep/T cLithoSleepTics																//wait for things to settle

	Wave LithoStepVoltY = root:Packages:MFP3D:Litho:LithoStepVoltY
	Wave LithoStepVoltX = root:Packages:MFP3D:Litho:LithoStepVoltX
	Wave RVW = $GetDF("Variables")+"RealVariablesWave"

	
//	ErrorStr += IR_StopInWaveBank(-1)
	
	
	if (LithoCount >= DimSize(LithoStepVoltY,0))						//if the index is past the Wave, we are through
		ARBackground("LithoBackground",0,"")
		if (GV("ShowXYSpot"))
			ShowXYSpotFunc("ShowXYSpotCheck_2",1)
		endif
		StartMeter("")
		ControlInfo/W=MeterPanel MeterSetup
		if (v_flag)
			Button MeterSetup,Win=MeterPanel,Disable=0
		endif
		DoScanFunc("StopScan_0")
		RemoveRedLithoPoint()
		return 0
	endif
	
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(GetDF("Litho"))		//it all happens in here
	
	Variable ScanSpeed = RVW[%FastScanSize][0]*RVW[%ScanRate][0]*2.5
	Variable XLVDTSens = GV("XLVDTSens")
	Variable YLVDTSens = GV("YLVDTSens")

	Variable rampInterpX, rampInterpY, rampInterp		//make the interpolation Variables
	
	Variable XDist, YDist, XSpeed, YSpeed, XTime, YTime
	XDist = abs(LithoStepVoltX[LithoCount]-LithoStepVoltX[LithoCount-1])
	YDist = abs(LithoStepVoltY[LithoCount]-LithoStepVoltY[LithoCount-1])
	XSpeed = (ScanSpeed/(abs(XLVDTSens)*4))
	YSpeed = (ScanSpeed/(abs(YLVDTSens)*4))
	XTime = XDist/XSpeed
	YTime = YDist/YSpeed
	if (XTime > YTime)
		YTime = XTime
		YSpeed = YDist/YTime
	elseif (YTime < XTime)
		XTime = YTime
		XSpeed = XDist/XTime
	endif
	
	
	Variable DoX = MakeRamp(0,"$OutputXLoop.Setpoint",LithoStepVoltX[LithoCount-1],LithoStepVoltX[LithoCount],XSpeed,1,rampInterpX)	//now with a 5um/S lowest speed
	Variable DoY = MakeRamp(1,"$OutputYLoop.Setpoint",LithoStepVoltY[LithoCount-1],LithoStepVoltY[LithoCount],YSpeed,1,rampInterpY)
	if (DoX || DoY)										//do we need to ramp?
		Make/O/N=(256) dummyWave
		//use the bigger value
		ErrorStr += IR_StopInWaveBank(-1)
		if (rampInterpX < rampInterpY)
			rampInterp = rampInterpY
		else
			rampInterp = rampInterpX
		endif
		//call actuallitho after the ramp
		ErrorStr += IR_XSetInWave(0,"0","output.Dummy",DummyWave,"ActualStepLitho("+num2str(LithoCount)+")",rampInterp)
		ErrorStr += num2str(td_WriteString("Event.0","Once"))+","
	else
		ErrorStr += num2str(ir_WriteValue("$OutputXLoop.Setpoint",LithoStepVoltX[LithoCount]))+","
		ErrorStr += num2str(ir_WriteValue("$OutputYLoop.Setpoint",LithoStepVoltY[LithoCount]))+","
		
		ActualStepLitho(LithoCount)
	endif

	SetDataFolder(SavedDataFolder)
	ARReportError(ErrorStr)

	return(0)
End //LithoStepRamp


Function DoLithoFunc(ctrlName)			//the litho function
	String ctrlName			//used!
	
	
	
	Variable RemIndex = FindLast(CtrlName,"_")
	if (RemIndex >= 0)
		CtrlName = CtrlName[0,RemIndex-1]
	endif
	RemIndex = FindLast(CtrlName,"Button")
	if (RemIndex >= 0)
		CtrlName = CtrlName[0,RemIndex-1]
	endif
		
	strswitch (CtrlName)
		case "StopLitho":
			ARManageRunning("Litho",0)
			DoScanFunc("StopScan_0")
			Execute/P/Q "LithoCleanUp()"		//this can switch modes
			//so we have to do it a after the tip has left the surface.
			
			// Start of Modification by Suhas
			// We want the cantilever to be cooled now.
			LithoInterfacer("StopPID()")
			//End of Modification by Suhas
			
			return 0
					
		case "DoLitho":
			//Don't break
		default:		//DoLitho
			//really just go on to the rest of the function....
	endswitch
	
	
//print td_ReadValue("ZSensor")*-GV("ZLVDTSens"),GetFuncName()
	if (GV("DoThermal"))
		DoThermalFunc("StopThermalButton_1")
	endif
	
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(GetDF("Litho"))		//it all happens in here

	Wave YLitho, XLitho										//these are the litho Waves
	if (DimSize(YLitho,0) == 0)
		DoAlert 0, "There has to be a lithography Wave first"
		SetDataFolder(SavedDataFolder)
		return 1
	endif
	AR_Stop(OKList="FreqFB;")
	ARManageRunning("Litho",1)
	Variable LithoAction = GV("LithoRunning")
	PV("LithoRunning",1)
	PV("ElectricTune",0)


//	Variable IsStopDraw = 0
	String CtrlName2Find = "StopDraw_*"
//	String PassByRefStr = ""
//	IsStopDraw = ItemsInList(FindControls2(CtrlName2Find,-1,PassByRefStr),";")
	

	if (LithoAction == 2)		//we were drawing
		DrawLithoFunc(CtrlName2Find)		//clear the hooks, and various other things
		//this will also ghost things for us.
	else
		GhostLithoPanel()
	endif

	//UpdateAllControls("DrawWave_0","Stop Litho","StopLitho_0","",DropEnd=1)	//change the button to stop
	

	String ErrorStr = ""
	ErrorStr += num2str(td_StopOutWaveBank(-1))+","
	ErrorStr += IR_StopInWaveBank(-1)
	ErrorStr += num2str(td_WriteString("ScanEngine.XDestination","Output.Dummy"))+","
	ErrorStr += num2str(td_WriteString("ScanEngine.YDestination","Output.Dummy"))+","
	
	//UpdateAllControls("DoLitho_0","0","","NoProc",DropEnd=1)		//reset the button
	Wave RVW = $GetDF("Variables")+"RealVariablesWave"

	Variable ScanSpeed = RVW[%FastScanSize][0]*RVW[%ScanRate][0]*2.5
	Variable XOffset = RVW[%XOffset][0]
	Variable YOffset = RVW[%YOffset][0]
	Variable ScanAngle = RVW[%ScanAngle][0]
	Variable XLVDTSens = GV("XLVDTSens")
	Variable YLVDTSens = GV("YLVDTSens")
	Variable xLVDTOffset = GV("XLVDTOffset")
	Variable yLVDTOffset = GV("YLVDTOffset")
	Variable UseBias = GV("LithoUseBias")
	Variable LithoSnap = GV("LithoSnap")
	String ZStr = ""
	Variable ZDest = 0
	Variable ZSpeed = 0
	Variable TriggeredSnap = GV("LithoTrigSnap")
	
	SetScanBandwidth()
	
//	ErrorStr += num2str(ir_WriteValue("Output.A",0))+","		//*alias* //checkme
	LoadXPTState("Litho")
	String EventStr = "1"
	
	
	Struct ARFeedbackstruct FB
	if (LithoSnap)
		ZStr = "$outputZloop.Setpoint"
		
		//this is the feedback loop that the trigger will turn on.
		//It is not on until the trigger hits.
		//once it is on, it is on, no adjustments.
		ARGetFeedbackParms(FB,"Height",ImagingMode=0)
		FB.StartEvent = "3"
		FB.StopEvent = "2"
		FB.LoopName = "LithoSnap"		//remove confussion, this is not your standard height
		FB.Bank = 4

		if (TriggeredSnap)
			Ir_WritePIDSLoop(FB)

			EventStr = "2,3"
		else
			EventStr += ",Never"		//just to be clear
		endif

		ARGetFeedbackParms(FB,"ZSensor")
		FB.PGain = 0
		FB.SGain = 0
		FB.StartEvent = StringFromList(0,EventStr,",")
		FB.StopEvent = StringFromList(1,EventStr,",")
		IR_WritePIDSloop(FB)
//		ErrorStr += num2str(ir_SetPISLoop(2,EventStr,"ZSensor",td_ReadValue("ZSensor"),0,10^GV("ZIGain")*GV("zLVDTSens"),0,"Height",-inf,inf))+","
//		ErrorStr += num2str(ir_WriteValue(ZStr,0))+","
//		ErrorStr += num2str(ir_WriteValue(ZStr,1))+","
		Wave LithoSnapPath = LithoSnapPath
		ZDest = LithoSnapPath[0]/-GV("ZLVDTSens")
		td_WriteString("Event.2","Once")
		
		
	else
		//ErrorStr += InitZFeedback0(2,"Always")
		Struct ARImagingModeStruct ImagingModeParms
		ErrorStr += InitZFeedback(ImagingModeParms)		//also fills in info

	endif
	
	ErrorStr += num2str(ir_StopPISLoop(NaN,LoopName="outputXLoop"))+","
	ErrorStr += num2str(ir_StopPISLoop(NaN,LoopName="outputYLoop"))+","
	
	
	ARGetFeedbackParms(FB,"outputX")
	FB.SetpointOffset = XOffset/abs(XLVDTSens)+xLVDTOffset
	FB.Setpoint = td_ReadValue(FB.input)-FB.SetpointOffset
	Variable XStart = FB.Setpoint
	IR_WritePIDSloop(FB)

	ARGetFeedbackParms(FB,"outputY")
	FB.SetpointOffset = YOffset/abs(YLVDTSens)+yLVDTOffset
	FB.Setpoint = td_ReadValue(FB.Input)-FB.SetpointOffset
	Variable YStart = FB.Setpoint
	IR_WritePIDSloop(FB)



	Sleep/T cLithoSleepTics												//wait for things to settle

	CheckLithoWaves(YLitho,XLitho)						//make sure that their sections are not too long
	Variable lithoFastScanSize = GV("LithoFastScanSize")		//get the scan size
	Variable lithoSlowScanSize = GV("LithoSlowScanSize")		//get the scan size
	PV("LithoIndex",0)										//reset the index to 0
	WaveStats/Q/M=1 YLitho										//Wavestats
	PV("LithoTotal",V_numNaNs)								//for the number of NaNs
	
	Make/O/C/N=1 AngleWave
	Make/O/N=1 DisplayHeight, DisplayDeflection
	Make/O/N=0 TimeWave
	PutOnXYSpot(1)

	ARBackground("RedSpotBackground",0,"")			//stop the red spot background task, we are in charge.
	ARbackground("LithoBackground",60,"")
	
	Variable/C tempBoth = RotateWave(YLitho[0]-lithoSlowScanSize/2,XLitho[0]-lithoFastScanSize/2,ScanAngle)
//	Variable XStart = td_ReadValue("XSensor")
	Variable XStop = imag(tempBoth)/abs(XLVDTSens)
	Variable XSpeed = abs(ScanSpeed/(abs(XLVDTSens)*4))
	Variable XDist = abs(XStop-XStart)
	Variable XTime = XDist/XSpeed
	
//	Variable YStart = td_ReadValue("YSensor")
	Variable YStop = real(tempBoth)/abs(YLVDTSens)
	Variable YSpeed = abs(ScanSpeed/(abs(YLVDTSens)*4))
	Variable YDist = abs(YStop-YStart)
	Variable YTime = YDist/YSpeed
	if (XTime > 10)
		XSpeed = 0
		XTime = 10
	endif
	if (YTime > 10)
		YSpeed = 0
		YTime = 10
	endif
	
	ErrorStr += num2str(td_SetRamp(Min(max(XTime,YTime)+.1,10),"$outputXLoop.Setpoint",XSpeed,XStop,"$outputYLoop.Setpoint",YSpeed,YStop,ZStr,ZSpeed,ZDest,"ActualLitho(0)"))+","

	SetDataFolder(SavedDataFolder)
	NVAR Amplitude = root:Packages:MFP3D:Meter:Amplitude
	Amplitude = 0
	ARReportError(ErrorStr)
	
	// Start of Modification by Suhas
	// Assuming that the Litho is completed by now
	// We want the cantilever to be cooled now.
	LithoInterfacer("StopPID()")
	//End of Modification by Suhas

	return(0)
End //DoLithoFunc

// Added by Suhas
// This section was being repeated over and over again.
// This will allow the Lithography.ipf to remain neat with the least
// of my code in it.
// This will automatically check if some heating function should or not execute
Function LithoInterfacer(message)
	String message
	
	DoWindow/F ThermalLithoPanel
	if(V_flag != 0)
		execute(message)
	endif
	
End

Function LithoBackground()
	
	//runs on ARU_Background
	
	Wave MVW = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	Wave LVW = root:Packages:MFP3D:Main:Variables:LithoVariablesWave
	Wave RVW = root:Packages:MFP3D:Main:Variables:RealVariablesWave

	Variable tempY, tempX
	Wave/Z YPoint = root:Packages:MFP3D:Litho:YPoint
	Wave/Z XPoint = root:Packages:MFP3D:Litho:XPoint
	if (WaveExists(YPoint)*WaveExists(XPoint) == 0)
		return(1)		//no good.
	endif
	tempY = (td_ReadValue("YSensor")-MVW[%YLVDTOffset])*abs(MVW[%YLVDTSens][0])-RVW[%YOffset][0]//+LVW[%LithoScanSize]/2
	tempX = (td_ReadValue("XSensor")-MVW[%XLVDTOffset])*abs(MVW[%XLVDTSens][0])-RVW[%XOffset][0]//+LVW[%LithoScanSize]/2
	Variable/C tempBoth = RotateWave(tempY,tempX,-RVW[%ScanAngle][0])
	YPoint = real(tempBoth)+LVW[%LithoSlowScanSize][0]/2
	XPoint = imag(tempBoth)+LVW[%LithoFastScanSize][0]/2

	Return(0)

End //LithoBackground


Function CheckLithoWaves(YLitho,XLitho)			//this checks the segment size in the litho Waves
	Wave YLitho, XLitho								//these should have NaNs in the same points
	
	
	if (DimSize(YLitho,0) != DimSize(XLitho,0))
		DoAlert 0,"Wave Size Mismatch in: "+GetFuncName()
		return(0)
	endif
	
	
	if (DimSize(YLitho,0) < 8192)
		return(0)			//there is no need to be here.
	endif
	
	Variable i, j = 0
	for (i = 0;i < DimSize(YLitho,0);i += 1)	//step through the Wave
	
		if (numtype(YLitho[i]) == 2)				//check for NaN
			j = 0										//reset this, then
		else
			if (j >= 8192)							//if the segment is longer than 8192
				InsertPoints i, 1, YLitho, XLitho		//insert a point
				YLitho[i] = NaN							//and set it to NaN
				XLitho[i] = NaN
				j = 0									//and reset the counter
			else
				j += 1									//increment the counter
			endif
		endif

	endfor
	
End //CheckLithoWaves


Function CheckLithoDisplay()

	SVAR MDTL = root:Packages:MFP3D:Main:Variables:MasterDataTypeList
	Variable dataTypeSum = GV("DataTypeSum")
	if (((2^(WhichListItem("Height",MDTL,";",0,0)-1) & dataTypeSum) == 0) && (2^(WhichListItem("ZSensor",MDTL,";",0,0)-1) & dataTypeSum))	//if there is no height but there is ZSensor
		Wave DisplayTestWave = root:Packages:MFP3D:Main:ZSensorImage0		//then TestWave is ZSensor
	else
		Wave DisplayTestWave = root:Packages:MFP3D:Main:HeightImage0
	endif
	Wave YLitho = root:Packages:MFP3D:Litho:YLitho
	Wave XLitho = root:Packages:MFP3D:Litho:XLitho
	
	Variable xMax = (DimSize(DisplayTestWave,0)-1)*DimDelta(DisplayTestWave,0)+DimOffset(DisplayTestWave,0)	
	Variable yMax = (DimSize(DisplayTestWave,1)-1)*DimDelta(DisplayTestWave,1)+DimOffset(DisplayTestWave,1)	
	if (DimSize(YLitho,0))
		WaveStats/Q/M=1 XLitho
		Variable xLithoMax = v_max
		WaveStats/Q/M=1 YLitho
		Variable yLithoMax = v_max
	
		if ((yLithoMax > yMax) || (xLithoMax > xMax))
			DoAlert 1, "There are lithography paths outside the image. Should everything be deleted?"
			if (V_flag == 1)
				DrawLithoFunc("EraseAll_0")
			endif
		endif
	endif
End //CheckLithoDisplay


Function ActualLitho(LithoCount)			//this does the actual lithography
	Variable LithoCount
	
	// Modificaiton started here by Suhas
	LithoInterfacer("SetHeat(1);PIDPanelButtonFunc(\"Read\",5)")
	// End of modification of code by Suhas
	
//print td_ReadValue("ZSensor")*-GV("ZLVDTSens"),GetFuncName()
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(GetDF("Litho"))		//it all happens in here
	
	
	Wave RVW = $GetDF("Variables")+"RealVariablesWave"
	
	Variable LithoIndex = GV("LithoIndex")			//this is the start of the current segment
	Variable XLVDTSens = GV("XLVDTSens")
	Variable YLVDTSens = GV("YLVDTSens")
	Variable scanAngle = RVW[%ScanAngle][0]
	Variable lithoFastScanSize = GV("LithoFastScanSize")
	Variable lithoSlowScanSize = GV("LithoSlowScanSize")
	Variable LithoMax = GV("LithoMax")
	Variable Interpolation = 3330*2
	Variable decimation = 1000
	Variable UseBias = GV("LithoUseBias")
	Variable ImagingMode = GV("ImagingMode")
	Variable UseWave = GV("LithoUseWave")
	Variable LithoBias = GV("LithoBias")*UseBias
	Variable Setpoint = GV("LithoSetpointVolts")
	Variable Snapping = GV("LithoSnap")
	Variable SleepTime = cLithoSleepTics
	Variable TriggeredSnap = GV("LithoTrigSnap")
	SleepTime *= (!(!imagingMode))+1 		//it was ImagingMode+1 before we added PFM and other modes.

	Wave YLitho, XLitho//, LithoVolts
	Wave/C AngleWave
	String NoteStr = Note(YLitho)
	String InterpList = StringByKey("InterpList",NoteStr,":","\r")
	Variable InterpSign = str2num(StringFromList(LithoCount,InterpList,";"))
	if (IsNan(InterpSign))
		InterpSign = 1
	endif
	
	Variable Index = Find1Index(YLitho,"==",NaN,LithoIndex)-1
	if (Index == -2)
		Index = DimSize(YLitho,0)-1
	endif

	Duplicate/O/R=[LithoIndex,Index] YLitho DriveY, VelocityY//, Deflection		//duplicate the drive Waves and the input Waves
	Duplicate/O/R=[LithoIndex,Index] XLitho DriveX, VelocityX, VelocityT
	Redimension/N=(Index-LithoIndex+1) AngleWave
	
	AngleWave = RotateWave(VelocityY-LithoSlowScanSize/2,VelocityX-LithoFastScanSize/2,scanAngle)
	DriveY = real(AngleWave)
	DriveX = imag(AngleWave)
	SetScale/P x 0,1e-05,"", VelocityY, VelocityX, VelocityT
	Differentiate/Meth=1 VelocityY, VelocityX
	VelocityT = sqrt(VelocityX^2+VelocityY^2)
	WaveStats/Q/M=1 VelocityT
	Interpolation = Max(round(V_max/LithoMax),1)
	LithoMax = V_Max/Interpolation
	LithoSetVarFunc("LithoMaxSetVar_0",LithoMax,"",":variables:LithoVariablesWave[%LithoMax]")
	//PV("LithoMax",LithoMax)
	Variable PPS = cMasterSampleRate/Interpolation
	
	FastOp DriveY = (1/abs(YLVDTSens))*DriveY
	FastOp DriveX = (1/abs(XLVDTSens))*DriveX
	
	Variable inputPoints = round((Index-LithoIndex)*interpolation/decimation)
	Variable extra = 32-mod(inputPoints,32)
	inputPoints += extra			//extra is the difference from being divisible by 32
	PV("LithoExtra",extra)
	
	String ErrorStr = ""
	//stop before setting the out Waves
	ErrorStr += num2str(td_StopOutWaveBank(-1))+","
	//stop before setting the in Waves
	ErrorStr += IR_StopInWaveBank(-1)

	
	Make/O/N=(inputPoints) Deflection, Height, Input0, Input1, Input2

	if (numtype(YLitho[Index+2]) == 2)
		PV("LithoIndex",Index+3)										//set the index to the start of the next segment
	else
		PV("LithoIndex",Index+2)										//set the index to the start of the next segment
	endif
	
	
	String ZString = "$HeightLoop.Setpoint"
	String WeDriveThis = ""
	Struct ARTipHolderParms TipParms
	ARGetTipParms(TipParms)
	if (TipParms.IsOrca)
		WeDriveThis = "SurfaceBias"		//can't believe this would work.
	elseif (TipParms.IsDiffDrive)
		WeDriveThis = "TipHeaterDrive"
	else
		WeDriveThis = "TipBias"
	endif
	
	
	if (Snapping)
		Wave LithoSnapPath = LithoSnapPath
		NoteStr = Note(LithoSnapPath)
		String Indexes = StringByKey("Indexes",NoteStr,":","\r")
		Wave LithoSnapDrive = $InitOrDefaultWave("LithoSnapDrive",0)
		Redimension/N=(DimSize(DriveX,0)) LithoSnapDrive
		//OK, we know that they 
		Variable StartIndex = str2num(StringFromList(LithoCount,Indexes,","))
		Variable StopIndex = str2num(StringFromList(LithoCount+1,Indexes,","))
		LinSpace2(LithoSnapPath[StartIndex]/-GV("ZLVDTSens"),LithoSnapPath[StopIndex-1]/-GV("ZLVDTSens"),DimSize(DriveX,0),LithoSnapDrive)
		if (TriggeredSnap)

			Wave/T CTFCParms = $InitOrDefaultTextWave("CTFCParms",0)
			Variable RampDist = LithoSnapDrive[DimSize(LithoSnapDrive,0)-1]-LithoSnapDrive[0]
			Variable RampTime = DimSize(LithoSnapDrive,0)/PPS
//Print RampTime
			td_ReadGroup("CTFC",CTFCParms)		//ignore this error
			//
//			CTFCParms[%RampChannel][0] = "SetPoint%PISloop2"
//			CTFCParms[%RampOffset1][0] = num2str(RampDist)
//			CTFCParms[%RampSlope1][0] = num2str(RampDist/RampTime)

			CTFCParms[%RampChannel][0] = "output.Dummy"
			CTFCParms[%RampOffset1][0] = num2str(RampDist)
			CTFCParms[%RampSlope1][0] = num2str(RampDist/RampTime)

			CTFCParms[%RampOffset2][0] = "0"
			CTFCParms[%RampSlope2][0] = "0"
			CTFCParms[%TriggerChannel1][0] = "Deflection"
//			CTFCParms[%TriggerValue1][0] = num2str(td_ReadValue("Input.Fast")+TriggerValue*TriggerSlope)
			CTFCParms[%TriggerValue1][0] = num2str(Setpoint)
			CTFCParms[%TriggerCompare1][0] = ">="
			CTFCParms[%TriggerChannel2][0] = "Deflection"
			CTFCParms[%TriggerValue2][0] = num2str(Setpoint)
			CTFCParms[%TriggerCompare2][0] = ">="
			CTFCParms[%TriggerHoldoff2][0] = "0"
			CTFCParms[%DwellTime1][0] = "0"
			CTFCParms[%DwellTime2][0] = "0.01"
			CTFCParms[%EventDwell][0] = "3"
			CTFCParms[%EventRamp][0] = "2"
			CTFCParms[%EventEnable][0] = "0"
			CTFCParms[%Callback][0] = ""
			if (FindDimLabel(CTFCParms,0,"TriggerType1") >= 0)
				CTFCParms[%TriggerType1][0] = "Absolute"
				CTFCParms[%TriggerType2][0] = "Absolute"
			endif
			
			ErrorStr += num2str(td_WriteGroup("CTFC",CTFCParms))+","
		endif
		ZString = "$outputZLoop.Setpoint"
		ErrorStr += num2str(td_xSetOutWave(1,"0",ZString,LithoSnapDrive,-Interpolation))+","
		Setpoint = LithoSnapDrive[0]
		
	elseif (UseWave)
		Duplicate/O/R=[LithoIndex,Index] LithoVolts DriveVolts
		Wave DriveVolts = DriveVolts
		if (UseBias)
			ErrorStr += num2str(td_xSetOutWave(1,"0",WeDriveThis,DriveVolts,Interpolation*InterpSign))+","
			LithoBias = DriveVolts[0]
		else
			ErrorStr += num2str(td_XSetOutWave(1,"0",ZString,DriveVolts,Interpolation*InterpSign))+","
			Setpoint = DriveVolts[0]
		endif
	endif
	
	//set the voltage
	if (UseBias)
		ErrorStr += num2str(ir_WriteValue(WeDriveThis,LithoBias))+","
	endif
	
	//set the litho setpoint
	ErrorStr += num2str(ir_WriteValue(ZString,Setpoint))+","
	Sleep/T SleepTime																	//wait for things to settle
	
	
	
	//these drive the X & Y stages
	ErrorStr += num2str(td_xSetOutWavePair(0,"0","$outputXLoop.Setpoint",DriveX,"$outputYLoop.Setpoint",DriveY,Interpolation*InterpSign))+","
	//this calls the next part	
	//this calls the next part	
	//OK, if they are in anything but contact mode, deflection is something else
	//but those modes don't really work for litho, so who cares.
	ErrorStr += IR_XSetInWavePair(0,"0","Input.Fast",Deflection,"ZSensor",Height,"LithoRamp("+num2str(LithoCount+1)+")",Decimation)
	
	

	
	Variable A, nop = 3
	String ChannelName, AliasName, AliasList = ""
	for (A = 0;A < nop;A += 1)
		ChannelName = GTS("LithoChannel"+Num2str(A))
		if (StringMatch(ChannelName,"Lateral"))
			AliasName = "Lateral"
		elseif (StringMatch(ChannelName,"UserIn*"))
			AliasName = "UserIn"+GetEndNumStr(ChannelName)
		elseif (StringMatch(ChannelName,"Current"))
			AliasName = "Current"
		elseif (StringMatch(ChannelName,"Current2"))
			AliasName = "Current2"
		elseif (Stringmatch(ChannelName,"Phase"))
			AliasName = "Phase"
		elseif (StringMatch(ChannelName,"Amp"))
			AliasName = "Amplitude"
		elseif (StringMatch(ChannelName,"XLVDT"))
			AliasName = "XSensor"
		elseif (Stringmatch(ChannelName,"YLVDT"))
			AliasName = "YSensor"
		endif
		AliasList += AliasName+";"
	endfor
		
	ErrorStr += IR_XSetInWavePair(1,"0",StringFromList(0,AliasList,";"),Input0,StringFromList(2,AliasList,";"),Input2,"",Decimation)
	ErrorStr += IR_XSetInWave(2,"0",StringFromList(1,AliasList,";"),Input1,"",Decimation)
 
	//set everything going
	ErrorStr += num2str(td_WriteString("Event.0","Once"))+","

	UpdateAllControls("DrawWave_0",num2str(LithoCount)+"/"+num2str(GV("LithoTotal")),"","",DropEnd=1)		//display the current section



	SetDataFolder(SavedDataFolder)
	ARReportError(ErrorStr)
	
	return(0)
End //ActualLitho


Function LithoRamp(LithoCount)		//this function moves between litho segments
	Variable LithoCount
	
	// Start of modification by Suhas
	LithoInterfacer("SetHeat(0)")
	// End of modification by Suhas

//print td_ReadValue("ZSensor")*-GV("ZLVDTSens"),GetFuncName()
	String DataFolder = GetDF("Litho")
	String ErrorStr = ""
	ErrorStr += num2str(td_StopOutWaveBank(-1))+","
	ErrorStr += IR_StopInWaveBank(-1)
	Variable UseBias = GV("LithoUseBias")
	Variable Snapping = GV("LithoSnap")
	Variable PreSnap = GV("LithoPreSnap")
	Variable SnappyTrigger = GV("LithoTrigSnap")
	Variable SleepTime = cLithoSleepTics
	Wave RVW = $GetDF("Variables")+"RealVariablesWave"
	Variable ScanAngle = RVW[%ScanAngle][0]
	Variable ScanSpeed = RVW[%FastScanSize][0]*RVW[%ScanRate][0]*2.5
	Struct ARImagingModeStruct ImagingModeParms
	ARGetImagingMode(ImagingModeParms)

	Variable Setpoint
	
	if (Snapping)
		SetPoint = NaN
	else
		Setpoint = ImagingModeParms.Feedback[0].Setpoint
	endif
	String WeDriveThis = ""
	Struct ARTipHolderParms TipParms
	ARGetTipParms(TipParms)
	if (TipParms.IsOrca)
		WeDriveThis = "SurfaceBias"		//can't believe this would work.
	elseif (TipParms.IsDiffDrive)
		WeDriveThis = "TipHeaterDrive"
	else
		WeDriveThis = "TipBias"
	endif
	
	
	
	//reset the voltage to 0
	if (UseBias)
		ErrorStr += num2str(ir_WriteValue(WeDriveThis,0))+","
	endif
	if (!IsNan(Setpoint))
		ErrorStr += num2str(ir_WriteValue("$HeightLoop.Setpoint",Setpoint))+","		//only true if not snapping, so must be HeightLoop
		Sleep/T sleepTime
	endif
	NVAR Sum = root:Packages:MFP3D:Meter:Sum
	Sum = td_ReadValue("DetectorSum")
	
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(DataFolder)
	
	Variable invOLS = GV("InvOLS")
	Variable zLVDTSens = GV("ZLVDTSens")
	Variable XLVDTSens = GV("XLVDTSens")
	Variable YLVDTSens = GV("YLVDTSens")
	SVAR BaseName = root:Packages:MFP3D:Main:Variables:BaseName
	Variable Suffix = GV("BaseSuffix")
	String SuffixStr = Num2strlen(Suffix,4)
	Variable LithoSave = GV("LithoSave")
	Variable AmpInvols = GV("AmpInvols")
	
	Variable LithoIndex = GV("LithoIndex")					//get the index
	Variable extra = GV("LithoExtra")

	Wave YLitho = YLitho
	Wave XLitho = XLitho
	Wave Height = Height
	Wave Deflection = Deflection
	Wave DisplayHeight = DisplayHeight
	Wave DisplayDeflection = DisplayDeflection
	Wave TimeWave = $InitOrDefaultWave("TimeWave",0)
	Variable TimeOffset = TimeWave[DimSize(TimeWave,0)-1]
	if (IsNan(TimeOffset))
		TimeOffset = 0
	endif

	Variable DestNop = DimSize(Height,0)-Extra
	Redimension/N=(DestNop) TimeWave
	Variable SampleRate = DimDelta(Height,0)
	TimeWave = SampleRate*P
	FastOp TimeWave = (TimeOffset)+TimeWave
	
	
	
	
	Struct ARDataTypeInfo InfoStruct
	InfoStruct.GraphStr = "RealTime"
	Wave/Z InfoStruct.DataWave = $""
	String ChanList = GTS("LithoChannel0")+";"+GTS("LithoChannel1")+";"+GTS("LithoChannel2")+";"
	String ChanName, Units
	Variable Scale, Offset
	Variable A, nop = ItemsInList(ChanList,";")
	for (A = 0;A < nop;A += 1)
		ChanName = StringFromList(A,ChanList,";")
		Wave InputWave = $"Input"+num2str(A)
		Wave DisplayWave = $InitOrDefaultWave("DisplayInput"+num2str(A),0)
		Redimension/N=(DestNop) InputWave,DisplayWave
		Get3DScaling(ChanName,InfoStruct=InfoStruct)
		Scale = InfoStruct.DistScale*InfoStruct.ForceScale
		Offset = InfoStruct.Offset
		Units = InfoStruct.Units
		FastOp DisplayWave = (Scale)*InputWave+(Offset)
		SetScale d,0,0,Units,DisplayWave
		SetScale/P x,DimOffset(InputWave,0),DimDelta(InputWave,0),WaveUnits(InputWave,0),DisplayWave
	endfor
	
	
	


	Redimension/N=(DestNop) Height,Deflection,DisplayHeight,DisplayDeflection
	FastOp DisplayHeight = (-zLVDTSens)*Height
	FastOp DisplayDeflection = (Invols)*Deflection
	CopyScales/P Height DisplayHeight, DisplayDeflection//, DisplayLateral, DisplayAmplitude, DisplayCurrent
	SetScale d 0,0,"m", DisplayDeflection, DisplayHeight//, DisplayAmplitude
//	SetScale d,0,0,"I",DisplayCurrent
//DoUpdate
	
	
	String Indexes = ""
	Variable SavedPoints = 0, DupCounter
	String DupChans = ""
	
	if (LithoSave)
		NewDataFolder/O/S root:SavedLitho
		Wave/Z SavedLithoWave = $BaseName+SuffixStr
		if (!WaveExists(SavedLithoWave))
			Make/N=(DestNop,6) $BaseName+SuffixStr
			Wave SavedLithoWave = $BaseName+SuffixStr
			DupChans = RemoveDuplicateListItems(ChanList,";")
			DupChans = ListSubtract(ChanList,DupChans,";")
			if (ItemsInList(DupChans,";") > 0)
				for (A = 0;A < nop;A += 1)
					ChanName = StringFromList(A,ChanList,";")
					if (WhichListItem(ChanName,DupChans,";",0,0) >= 0)
						ChanList = ReplaceListItem(A,ChanList,ChanName+num2char(DupCounter+65),";")
						DupCounter += 1
					endif
				endfor
			endif
			SetDimLabels(SavedLithoWave,"Height;Defl;TimeData;"+ChanList,1)
			Indexes = "0,"
			Note/K SavedLithoWave
			Note SavedLithoWave,"Indexes:"+Indexes
		else
			InsertPoints/M=0 DimSize(SavedLithoWave,0),DestNop,SavedLithoWave
		endif
		
		
		SavedPoints = DimSize(SavedLithoWave,0)
		
		Indexes = Note(SavedLithoWave)
		Indexes += num2str(DimSize(SavedLithoWave,0)-1)+","
		Note/K SavedLithoWave
		Note savedLithoWave,Indexes
		
		
		
		
		SavedLithoWave[SavedPoints-DestNop,SavedPoints-1][0] = DisplayHeight[P-(SavedPoints-DestNop)]
		SavedLithoWave[SavedPoints-DestNop,SavedPoints-1][1] = DisplayDeflection[P-(SavedPoints-DestNop)]
		SavedLithoWave[SavedPoints-DestNop,SavedPoints-1][2] = TimeWave[P-(SavedPoints-DestNop)]
		
		for (A = 0;A < nop;A += 1)
			ChanName = StringFromList(A,ChanList,";")
			Wave DisplayWave = $DataFolder+"DisplayInput"+num2str(A)
			SavedLithoWave[SavedPoints-DestNop,SavedPoints-1][3+A] = DisplayWave[P-(SavedPoints-DestNop)]
		endfor
		
		if (Lithoindex >= DimSize(YLitho,0))
			PV("BaseSuffix",Suffix+1)
			CalcXYLithoWave(SavedLithoWave)
		endif
	endif
	
	if (Lithoindex >= DimSize(YLitho,0))						//if the index is past the Wave, we are through
		DoLithoFunc("StopLitho")
		SetDataFolder(SavedDataFolder)
		if (PreSnap)
			PV("LithoPreSnapSuffix",Suffix)
			PV("LithoSnapPreCheck",1)
			GhostLithoPanel()
			DoLithoSnapFunc("DoLithoSnapGraph")
			PV("LithoPreSnap",0)
			//Revert the setpoint.....
			MainSetVarFunc("SetPointSetVar_0",GV("LithoSetpointVolts"),"",":Variables:MasterVariablesWave[%"+ImagingModeParms.SetpointParm+"]")
		endif
		return(0)
	endif
	
	
	
	Variable lithoFastScanSize = GV("LithoFastScanSize")
	Variable lithoSlowScanSize = GV("LithoSlowScanSize")
	Variable backStep = 2
	if (IsNaN(YLitho[LithoIndex-backStep]))
		backStep += 1
	endif
	
	Variable/C oldBoth, newBoth
	Variable rampInterpX, rampInterpY, rampInterp		//make the interpolation Variables
	oldBoth = RotateWave(YLitho[LithoIndex-backStep]-LithoSlowScanSize/2,XLitho[LithoIndex-backStep]-LithoFastScanSize/2,ScanAngle)
	newBoth = RotateWave(YLitho[LithoIndex]-LithoSlowScanSize/2,XLitho[LithoIndex]-LithoFastScanSize/2,ScanAngle)
	
	
	Variable XDist, YDist, XSpeed, YSpeed, XTime, YTime
	XDist = abs(imag(oldBoth)/abs(XLVDTSens)-imag(newBoth)/abs(XLVDTSens))
	YDist = abs(real(oldBoth)/abs(YLVDTSens)-real(newBoth)/abs(YLVDTSens))
	XSpeed = (ScanSpeed/(abs(XLVDTSens)*4))
	YSpeed = (ScanSpeed/(abs(YLVDTSens)*4))
	XTime = XDist/XSpeed
	YTime = YDist/YSpeed
	if (XTime > YTime)
		YTime = XTime
		YSpeed = YDist/YTime
	elseif (YTime < XTime)
		XTime = YTime
		XSpeed = XDist/XTime
	endif
	
	
	
	Variable DoX = MakeRamp(0,"$outputXLoop.Setpoint",imag(oldBoth)/abs(XLVDTSens),imag(newBoth)/abs(XLVDTSens),XSpeed,1,rampInterpX)	//now with a 5um/S lowest speed
	Variable DoY = MakeRamp(1,"$outputYLoop.Setpoint",real(oldBoth)/abs(YLVDTSens),real(newBoth)/abs(YLVDTSens),YSpeed,1,rampInterpY)

	if ((IsNan(RampInterpX)) || (IsNan(RampInterpY)))
		DoX = 0
		DoY = 0
		RampInterp = 1
	endif


	if (DoX || DoY)										//do we need to ramp?
		Make/O/N=(256) dummyWave
		ErrorStr += IR_StopInWaveBank(-1)
		RampInterp = Max(RampInterpX,RampInterpY)				//use the bigger value
		if (Snapping)
			Variable ZStart = td_ReadValue("ZSensor")
			Variable ZMax = 6*-Sign(ZLVDTSens)		//go to -6 volts LVDT (well make sure that -6 is retracted, otherwise go to +6 volts).
			DummyWave[0,127] = P/127*(ZMax-ZStart)+ZStart
			DummyWave[128,255] = DummyWave[127]-(P-128)/127*(ZMax-ZStart)
			ErrorStr += num2str(td_xSetOutWave(2,"0","$outputZLoop.Setpoint",Dummywave,RampInterp))+","
		endif
		//call actuallitho after the ramp
		ErrorStr += IR_XSetInWave(0,"0","output.Dummy",DummyWave,"ActualLitho("+num2str(LithoCount)+")",rampInterp)
		if (SnappyTrigger)
			ErrorStr += num2str(td_WriteString("Event.3","Clear"))+","
			ErrorStr += num2str(td_WriteString("Event.2","Once"))+","
		endif
		ErrorStr += num2str(td_WriteString("Event.0","Once"))+","
	else
		ErrorStr += num2str(ir_WriteValue("$OutputXLoop.Setpoint",imag(newBoth)/abs(XLVDTSens)))+","
		ErrorStr += num2str(ir_WriteValue("$OutputYLoop.Setpoint",real(newBoth)/abs(YLVDTSens)))+","
		ActualLitho(LithoCount)
	endif

	SetDataFolder(SavedDataFolder)
	if (Strlen(ReplaceString("0,",ErrorStr,"")))										//print a message if there was a td return
		if (IsNan(RampInterp))
			ErrorStr += "\r"
			ErrorStr += "NaN RampInterp, See "+GetFuncName()+"\r"
		endif
		ARReportError(ErrorStr)
	endif

	return(0)
End //LithoRamp


Function AddLitho()									//adds the latest drawn figure to the litho Waves
	
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(GetDF("Litho"))
	
	Wave YLitho, XLitho, YDraw, XDraw
	if (numtype(YDraw[0]) == 2)					//if the first point is NaN, then we are through
		SetDataFolder(SavedDataFolder)
		return 1
	endif
	Variable oldEnd = DimSize(YLitho,0)			//get the current size of YLitho
	String NoteStr = Note(YLitho)
	Note/K YLitho
	String InterpList = StringByKey("InterpList",NoteStr,":","\r")
	Variable DrawMode = GV("LithoDrawMode")
	InterpList += num2str(2*(!DrawMode)-1)+";"
	NoteStr = ReplaceStringByKey("InterpList",NoteStr,InterpList,":","\r")
	Note YLitho,NoteStr 
	
	//Start Limits Hack.
	
	String GraphStr = StringFromList(0,WInList("Channel*Image*",";","WIN:1"),";")
	Wave/Z ImageWave = ImageNameToWaveRef(GraphStr, StringFromList(0,ImageNameList(GraphStr,";"),";"))
	if (WaveExists(ImageWave))
		Xdraw = Limit(Xdraw,DimOffset(ImageWave,0),DimSize(ImageWave,0)*DimDelta(ImageWave,0)+DimOffset(ImageWave,0))
		YDraw = Limit(Ydraw,DimOffset(ImageWave,1),DimSize(ImageWave,1)*DimDelta(ImageWave,1)+DimOffset(ImageWave,1))
	endif
	
	
	
	//OK, if we are in line mode, then we have to even out the spacing.....
	if (GV("LithoDrawMode"))
		Make/N=(0)/O/D ScrapWave0,ScrapWave1,ScapWave2,ScrapWave3,ScrapWave4
		Make/N=(0)/O/D TempXDest,TempYDest
		Redimension/D XDraw,YDraw
		//Litho interp needs to have the waves as double precision
		
		LithoInterp(NaN,inf,Xdraw,Ydraw,TempXDest,TempYDest,ScrapWave0,ScrapWave1,ScapWave2,ScrapWave3,ScrapWave4)
		Duplicate/O TempXDest,XDraw
		Duplicate/O TempYDest,YDraw
	endif


	
	if ((oldEnd) && (DimSize(YDraw,0)))			//the Litho Wave is already started
		InsertPoints oldEnd, 1, YLitho, XLitho	//insert a point at the end of the current litho Waves
		YLitho[oldEnd] = NaN						//and set it to NaN
		XLitho[oldEnd] = NaN
		
		InsertPoints oldEnd+1, DimSize(YDraw,0), YLitho, XLitho		//add in enough points to add the next segment
		YLitho[oldEnd+1,] = YDraw[p-oldEnd-1]		//set the new segment to the draw Wave
		XLitho[oldEnd+1,] = XDraw[p-oldEnd-1]
	else												//the litho Wave is empty
		InsertPoints 0, DimSize(YDraw,0), YLitho, XLitho	//add in the new points
		YLitho = YDraw								//the first segment equals the draw Wave
		XLitho = XDraw
	endif
	Redimension/N=0 Xdraw,YDraw

	if (GV("LithoUseArrows"))
		CalcLithoArrows()
	endif
	

	SetDataFolder SavedDataFolder
	return 0
End //AddLitho


Function RemoveLithoSection()				//removes the latest (sort of latest) segment from the litho Wave
	
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(GetDF("Litho"))
	Wave YLitho, XLitho
	SetDataFolder(SavedDataFolder)
	String NoteStr = Note(YLitho)
	Note/K YLitho
	String InterpList = StringByKey("InterpList",NoteStr,":","\r")
	InterpList = RemoveListItem(itemsInList(InterpList,";")-1,InterpList,";")
	NoteStr = ReplaceStringByKey("InterpList",NoteStr,InterpList,":","\r")
	Note YLitho,NoteStr

	Variable i, Stop = DimSize(YLitho,0)
	
	if (IsNaN(YLitho[Stop-1]))			//we on a group!, kill the group.
		LithoGroupFunc("KillGroup_0")
		return(0)
	endif
	
	for (i = Stop-1;i >= 0;i -= 1)		//start at the last point and go backwards
		if (numtype(YLitho[i]) == 2)					//look for NaNs
			break
		endif
	endfor

	Redimension/N=(i) YLitho, XLitho					//redimension to the point before the NaN or 0 if none were found
	if (GV("LithoUseArrows"))
		CalcLithoArrows()
	endif
	
End //RemoveLithoSection


Function DrawLithoFunc(ctrlName)			//sets up the drawing on the image
	String ctrlName
	
	String graphStr = StringFromList(0,WinList("Channel*Image*",";","WIN:1"),";")		//get the top realtime graph
	if (StringMatch(Ctrlname,"*Erase*") == 0)		//erase can work without the graphs up
		if ((strlen(graphStr) == 0) && GV("RealArgyleReal"))
			ImageChannelCheckFunc("RealArgyleRealBox_1",0)
			graphStr = StringFromList(0,WinList("Channel*Image*",";","WIN:1"),";")		//get the top realtime graph
		endif
		if (strlen(graphStr) == 0)
			DoAlert 0, "There doesn't seem to be an appropriate graph."			//there isn't one!
			return 1
		endif
	endif
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(GetDF("Litho"))
	Wave YLitho, XLitho, YDraw, XDraw
	
	
	
	String EndStr = ""
	Variable RemInd = FindLast(CtrlName,"_")
	if (RemInd > -1)
		EndStr = CtrlName[RemInd,Strlen(CtrlName)-1]
		CtrlName = CtrlName[0,RemInd-1]
	endif
	Variable EndDrawLimit = 1
		
	Variable LithoNumber = GV("LithoNumber")
	strswitch (ctrlName)

		case "DrawWave":													//we want to draw
			PV("LithoRunning",2)
			GhostLithoPanel()
			//UpdateAllControls("DrawWave_0","Stop Draw","StopDraw_0","",DropEnd=1)
			DoWindow/F $graphStr											//bring the graph forward
			SetLithoHooks("DrawLithoHook")
			if (LithoNumber)
				AddLitho()		//after drawing, you click on the image to place section in litho group.
			else
				PutLithoOnEveryOne(0)
			endif
			SetScale x,0,0,"m",Xlitho,Ylitho,Xdraw,YDraw
			AllLithoDrawModes(1+GV("LithoDrawMode"))
			Wave ImageWave = ImageNameToWaveRef(graphStr,StringFromList(0,ImageNameList(graphStr,";")))	//reference the image Wave
			UpdateLithoSize(ImageWave)
			UpdateLithoTime(CalcLithoTime())
			//DisableControl("MasterLithoPanel;LithoPanel;","LithoFreeHandCheck_0;LithoLineCheck_0;",2)
			MasterARGhostFunc("LithoFreeHandCheck_*;LithoLineCheck_*;","")
			break

		case "EraseAll":													//kill them all
//			DrawLithoFunc("StopDraw_0")
//			UpdateAllControls("StopDraw_0","Draw Path","DrawWave_0","",DropEnd=1)		//change the button back to draw
//			AllLithoDrawModes(0)
//			SetLithoHooks("RealGraphHook")
			Redimension/N=0 YLitho, XLitho								//redimension the litho Waves to 0
			Note/K YLitho
			if (Strlen(GraphStr))
				RemoveFromGraph/Z/W=$graphStr YLitho							//remove them from the graph
			endif
			UpdateLithoTime(CalcLithoTime())
//			break

		case "StopDraw":													//stop drawing
			if (GV("LithoRunning") != 1)		//starting a litho can call this
				PV("LithoRunning",0)
			endif
			GhostLithoPanel()
			//UpdateAllControls("StopDraw_0","Draw Path","DrawWave_0","",DropEnd=1)		//change the button back to draw
			AllLithoDrawModes(0)
			SetLithoHooks("RealGraphHook")
			AddLitho()										//if AddLitho returns 0 then a segment was added
			if (strlen(graphStr))
				RemoveFromGraph/Z/W=$graphStr YDraw							//remove this from the graph
			endif
			UpdateLithoTime(CalcLithoTime())
			//DisableControl("MasterLithoPanel;LithoPanel;","LithoFreeHandCheck_0;LithoLineCheck_0;",0)
			MasterARGhostFunc("","LithoFreeHandCheck_*;LithoLineCheck_*;")
			break

		case "EraseLast":													//just remove the last segment
			ControlInfo/W=LithoPanel StopDraw_0
			if (v_flag)
				EndDrawLimit +=1
			else
				ControlInfo/W=MasterLithoPanel StopDraw_0
				if (v_flag)
					EndDrawLimit +=1
				endif
			endif
			
			
			
			if (LithoNumber > EndDrawLimit)													//if there are any segments
				RemoveLithoSection()										//remove the last one
			else																//there are no segments
				//UpdateAllControls("StopDraw_0","Draw Path","DrawWave_0","",DropEnd=1)
				GhostLithoPanel()
				AllLithoDrawModes(0)
				SetLithoHooks("RealGraphHook")
				Redimension/N=0 YLitho, XLitho							//redimension to 0
				RemoveFromGraph/Z/W=$graphStr YLitho						//remove from the graph
			endif
			UpdateLithoTime(CalcLithoTime())
			break

	endswitch
	CountLithoSections()
	
	SetDataFolder SavedDataFolder
End //DrawLithoFunc


Function LithoGroupFunc(ctrlName)
	String ctrlName
	
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(GetDF("Litho"))
	
	Wave YLitho, XLitho
	Variable i, length = DimSize(YLitho,0)
	String nameStr
	

	String ParmName = ARConvertName2Parm(CtrlName,"Button")
	
	
	strswitch (ParmName)	

		case "MakeGroup":
			if (length)
				if (numtype(YLitho[length-1]) != 2)
					InsertPoints length, 1, YLitho, XLitho
					YLitho[length] = NaN
					XLitho[length] = NaN
					length += 1
					CountLithoSections()
					if (GV("LithoUseArrows"))
						ToggleLithoArrows("ShowArrowBox_0",0)
						ToggleLithoArrows("ShowArrowBox_0",1)
					endif
				endif
			else
				DoAlert 0, "There needs to be something in the Litho Wave in order to make a group."
			endif
			break

		case "SaveGroup":
			if (length)
				if (numtype(YLitho[length-1]) != 2)
					InsertPoints length, 1, YLitho, XLitho
					YLitho[length] = NaN
					XLitho[length] = NaN
					length += 1
					CountLithoSections()
				endif
			else
				DoAlert 0, "There needs to be something in the Litho Wave in order to make a group."
				break
			endif
			Prompt nameStr, "The name of the group?"
			DoPrompt "Name of the saved group", nameStr
			if ((V_flag) || (!Strlen(NameStr)))
				break
			endif
			nameStr = ReplaceString(" ",nameStr,"_",1)		//fight the users urge to put in spaces.
			for (i = DimSize(YLitho,0)-1;i >= 0;i -= 1)		//start at the last point and go backwards
				if (numtype(YLitho[i]) == 2)					//look for NaNs
					if (numtype(YLitho[i-1]) == 2)
						i += 1
						break
					endif
				endif
			endfor
			SetDataFolder groups
			Duplicate/O/R=(i,length-2) YLitho $"Y"+nameStr
			Duplicate/O/R=(i,length-2) XLitho $"X"+nameStr
			LithoScale(nameStr)
			LithoGroupList()
			break

		case "KillGroup":
			if (length == 0)
				break
			endif
			Variable count = 0
			for (i = DimSize(YLitho,0)-1;i >= 0;i -= 1)		//start at the last point and go backwards
				if (numtype(YLitho[i]) == 2)					//look for NaNs
					count += 1
					if (numtype(YLitho[i-1]) == 2)
						i += 1
						break
					endif
				endif
			endfor
			Redimension/N=(i-1) YLitho, XLitho
			break

		case "LoadGroup":
			MakePanel("LithoGroup")
			break
			
		case "SaveWave":
			if (length == 0)
				DoAlert 0, "There needs to be something in the Litho Wave in order to save it."
				break
			endif
			Prompt nameStr, "The name of the saved Wave?"
			DoPrompt "Name of the saved Wave", nameStr
			if ((V_flag) || (!Strlen(NameStr)))
				break
			endif
			nameStr = ReplaceString(" ",nameStr,"_",1)		//fight the users urge to use spaces.
			SetDataFolder LithoWaves
			Duplicate/O YLitho $"Y"+nameStr
			Duplicate/O XLitho $"X"+nameStr
			break
		
		case "LoadWave":
			SetDataFolder LithoWaves
			String listWave = WaveList("Y*",";","")
			if (ItemsInList(ListWave,";") == 0)
				SetDataFolder(SavedDataFolder)
				return 0
			endif
			Prompt nameStr, "Wave to load", popup, listWave
			DoPrompt "Which Wave to load?", nameStr
			
			if (v_flag == 1)
				SetDataFolder(SavedDataFolder)
				return 0
			endif
			
			Wave NewY = $nameStr
			nameStr = "X"+nameStr[1,strlen(nameStr)-1]
			Wave NewX = $nameStr
			SetDataFolder root:Packages:MFP3D:Litho
			Duplicate/O NewY YLitho
			Duplicate/O NewX XLitho
			if (GV("LithoUseArrows"))
				CalcLithoArrows()
			endif
			PutLithoOnEveryOne(0)
			CountLithoSections()
			break
			
		case "LithoChannel":
			MakePanel("LithoChannel")
			break

	endswitch

	
	SetDataFolder SavedDataFolder
End //LithoGroupFunc


Function LithoGroupList()
	
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder root:Packages:MFP3D:Litho:groups

	String WaveListStr = WaveList("!Group*",";","")
	Wave/T GroupList
	Variable i, count = 0
	Redimension/N=(ItemsInList(WaveListStr)/2) GroupList
	
	for (i = 0;i < ItemsInList(WaveListStr);i += 1)
		if (Stringmatch("Y",StringFromList(i,WaveListStr)[0]))
			GroupList[count] = StringFromList(i,WaveListStr)[1,50]
			count += 1
		endif
	endfor

	SetDataFolder SavedDataFolder
End //LithoGroupList


Function LithoScale(groupStr)
	String groupStr

	if (Stringmatch("Group",groupStr))
		Wave YLitho = root:Packages:MFP3D:Litho:groups:GroupY
		Wave XLitho = root:Packages:MFP3D:Litho:groups:GroupX
	else
		Wave YLitho = $"root:Packages:MFP3D:Litho:groups:Y"+groupStr
		Wave XLitho = $"root:Packages:MFP3D:Litho:groups:X"+groupStr
	endif
	WaveStats/Q/M=1 YLitho
	YLitho -= V_min
	Variable ySize = V_max-V_min
	WaveStats/Q/M=1 XLitho
	XLitho -= V_min
	Variable xSize = V_max-V_min

	if (ySize > xSize)
		YLitho *= 50e-6/ySize
		XLitho *= 50e-6/ySize
	else
		YLitho *= 50e-6/xSize
		XLitho *= 50e-6/xSize
	endif

End //LithoScale


Function DrawLithoHook(infoStr)		//This takes care of adding new litho segments
	String infoStr
	
	String event = StringByKey("EVENT",infoStr)			//grab the event

	strswitch (event)
		case "kill" :							//this is handled by the normal hook
			RealGraphHook(infoStr)
			DrawLithoFunc("StopDraw_0")
			return 0
			
		case "mouseup":
			DrawLithoFunc("DrawWave_0")		//add the current drawing to the litho Wave
			return 0
			
		case "Menu":
		case "Resize":
		case "Activate":
			return RealGraphHook(infoStr)
			break
			
	endswitch

	return 0				//return 0 so that doing other things with mouse still work
End //DrawLithoHook


Macro CopyContourTrace(traceName)				//stock Wavemetrics macro frontend for MakeCopyOfTrace
	String traceName
	Prompt traceName, "contour trace",popup,TraceNameList("",";",2)
	MakeCopyOfTrace("",traceName)

End //CopyContourTrace


Function MakeCopyOfTrace(graphNameStr,traceNameStr)		//stock Wavemetrics function that makes Waves from contour traces
	String graphNameStr, traceNameStr
	
	Wave w = TraceNameToWaveRef(graphNameStr,traceNameStr)
	Make/O/N=(numpnts(w)) traceCopyY
	TraceCopyY = w
	Wave w = XWaveRefFromTrace(graphNameStr,traceNameStr)
	Make/O/N=(numpnts(w)) traceCopyX
	TraceCopyX = w

End //MakeCopyOfTrace


Function MakeLithoPanel(var)		//make the litho panel
	Variable var		//Used
	
	
	String DataFolder = GetDF("Windows")
	
	String GraphStr = GetFuncName()
	GraphStr = GraphStr[4,Strlen(GraphStr)-1]
	Wave PanelParms = $DataFolder+GraphStr+"Parms"
	String MasterPanel = ARPanelMasterLookup(GraphStr)
	Wave MasterParms = $DataFolder+MasterPanel+"Parms"
	

	Variable TabNum = ARPanelTabNumLookup(GraphStr)
	String TabStr = "_"+num2str(TabNum)
	String SetupTabStr =  TabStr+"9"
	
	String SlavePanel = "LithoPanel"
	Variable CurrentTop, Enab = 0
	String SetupFunc = "", MakeTitle = "", MakeName = "", SetupName = ""
	String SetUpBaseName = GraphStr[0,strlen(GraphStr)-6]+"Bit_"	
	if (Var == 0)		//MasterLithoPanel
		GraphStr = MasterPanel
		CurrentTop = 40
		SetupName = GraphStr+"Setup"+TabStr
		MakeTitle = "Make Litho Panel"
		MakeName = "LithoButton"+TabStr
		Enab = 1		//leave to tabfunc
	elseif (Var == 1)		//LithoPanel
		CurrentTop = 10
		SetupName = "LithoPanelSetup"+TabStr
		MakeName = "MasterLitho"+Tabstr
		MakeTitle = "Make Master Litho Panel"
	endif
	SetupFunc = "ARSetupPanel"
	
	InitRealLastTitleString()
	Variable FontSize = 14
	
	
	Variable DisableHelp = 0			//do we have a help file yet?
	
	Variable FirstSetVar = PanelParms[%FirstSetVar][0]
	Variable SetVarWidth = PanelParms[%SetVarWidth][0]
	Variable FirstText = PanelParms[%FirstText][0]
	Variable TextWidth = PanelParms[%TextWidth][0]
	Variable TitleWidth = PanelParms[%TitleWidth][0]
	Variable HelpPos = PanelParms[%HelpPos][0]
	Variable Control1Bit = PanelParms[%Control1Bit][0]
	Variable oldControl1Bit = PanelParms[%oldControl1Bit][0]
	Variable SetupLeft = PanelParms[%SetupLeft][0]
	Variable BodyWidth = PanelParms[%BodyWidth][0]
	String HelpFunc = "ARHelpFunc"
	String HelpName = ""
	Variable StepSize = 25
	Variable ButtonWidth = 80
	Variable ButtonHeight = 20
	Variable Margin = 15
	Variable LeftPos = Margin
	
	String ControlName = ""

	//All of the controls have either a _0 or _09 at the end so that they show up at the correct times. The _09 are setup controls and only show up then.
	Variable bit = 0
	String ParmName
	Struct ARImagingModeStruct ImagingModeParms
	ARGetImagingMode(ImagingModeParms)
	ParmName = ImagingModeParms.SetpointParm
	
	//Normal setpoint controls
	if (2^bit & Control1Bit)
		MakeSetVar(GraphStr,"SetPointSetVar"+TabStr,ParmName,"Normal Set Point","MainSetpointSetVarFunc","",FirstSetVar,CurrentTop,SetVarwidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"Setpoint"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1
	
	
	
	//Litho Setpoint controls
	if (2^bit & Control1Bit)
		ControlName = "LithoSetpointVoltsSetVar"+TabStr
		MakeSetVar(GraphStr,ControlName,"LithoSetpointVolts","Litho Set Point","LithoSetVarFunc","",FirstSetVar,CurrentTop,SetVarwidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"Litho_Setpoint"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1
	
	
	//Bias Setvar
	if (2^bit & Control1Bit)
		MakeSetVar(graphStr,"","LithoBias","Litho Bias","LithoSetVarFunc","",FirstSetVar,CurrentTop,SetVarwidth,bodyWidth,TabNum,FontSize,Enab)

		ControlName = "LithoUseBiasBox"+TabStr
		UpdateCheckBox(GraphStr,ControlName," ",10,CurrentTop,"LithoBoxFunc",GV("LithoUseBias"),0,Enab)

		MakeButton(GraphStr,"Litho_Bias"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1


	
	//Max Veolcity setvar
	if (2^bit & Control1Bit)
		MakeSetVar(GraphStr,"","LithoMax","Max Velocity","LithoSetVarFunc","",FirstSetVar,CurrentTop,SetVarwidth,bodyWidth,TabNum,FontSize,Enab)

		MakeButton(GraphStr,"Litho_Max_Velocity"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1


	//Litho Time SetVar
	if (2^bit & Control1Bit)
		MakeSetVar(GraphStr,"","LithoTime","","LithoTimeFunc","",FirstSetVar,CurrentTop,SetVarWidth,bodyWidth,tabNum,FontSize,Enab)

		MakeButton(GraphStr,"Litho_Time"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1
	
	
	
	//Litho DrawMode Controls....
	if (2^Bit &Control1Bit)
		UpdateCheckBox(GraphStr,"LithoFreeHandCheck"+TabStr,"FreeHand",FirstSetVar,CurrentTop,"LithoBoxFunc",!GV("LithoDrawMode"),1,Enab)
		UpdateCheckBox(GraphStr,"LithoLineCheck"+TabStr,"Line",FirstSetVar,CurrentTop+18,"LithoBoxFunc",GV("LithoDrawMode"),1,Enab)

		MakeButton(GraphStr,"Litho_Draw_Mode"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += 43
	endif
	bit += 1
		
	
	//Do it, and draw path buttons
	if (2^bit & Control1Bit)
		MakeButton(GraphStr,"DoLitho"+TabStr,"Do it!",ButtonWidth,ButtonHeight,FirstText,CurrentTop,"DoLithoFunc",Enab)
		MakeButton(GraphStr,"StopLitho"+TabStr,"Stop Litho",ButtonWidth,ButtonHeight,FirstText,CurrentTop,"DoLithoFunc",Enab)
		
		MakeButton(GraphStr,"DrawWave"+TabStr,"Draw Path",ButtonWidth,ButtonHeight,FirstSetVar,CurrentTop,"DrawLithoFunc",Enab)
		MakeButton(GraphStr,"StopDraw"+TabStr,"Stop Draw",ButtonWidth,ButtonHeight,FirstSetVar,CurrentTop,"DrawLithoFunc",Enab)
		
		MakeButton(GraphStr,"Do_Lithography"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1


	//erase and kill buttons
	if (2^bit & Control1Bit)
		MakeButton(GraphStr,"EraseAll"+TabStr,"Kill All",ButtonWidth,ButtonHeight,FirstText,CurrentTop,"DrawLithoFunc",Enab)
		
		MakeButton(GraphStr,"EraseLast"+TabStr,"",ButtonWidth,ButtonHeight,FirstSetVar,CurrentTop,"DrawLithoFunc",Enab)
		
		MakeButton(GraphStr,"Kill_All"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1


	//group buttons
	if (2^bit & Control1Bit)
		MakeButton(GraphStr,"MakeGroup"+TabStr,"Make Group",ButtonWidth,ButtonHeight,FirstText,CurrentTop,"LithoGroupFunc",Enab)
		
		MakeButton(GraphStr,"SaveGroup"+TabStr,"Save Group",ButtonWidth,ButtonHeight,FirstSetVar,CurrentTop,"LithoGroupFunc",Enab)

		MakeButton(GraphStr,"Make_Group"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	
	//save load buttons
	if (2^bit & Control1Bit)
		MakeButton(GraphStr,"SaveWave"+TabStr,"Save Wave",ButtonWidth,ButtonHeight,FirstText,CurrentTop,"LithoGroupFunc",Enab)
		
		MakeButton(GraphStr,"LoadWave"+TabStr,"Load Wave",ButtonWidth,ButtonHeight,FirstSetVar,CurrentTop,"LithoGroupFunc",Enab)
		
		MakeButton(GraphStr,"Save_Wave"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1


	//Litho section counter val display
	if (2^bit & Control1Bit)
		TitleBox $"LithoNumberTitle"+TabStr,win=$GraphStr,pos={FirstText,CurrentTop+2},size={TextWidth,ButtonHeight},title="\\F'Arial'\\Z12Section Number",frame=0,Disable=Enab
		ControlName = "LithoNumber"+TabStr
		ValDisplay $ControlName,win=$GraphStr,pos={FirstSetVar,CurrentTop},size={SetVarWidth-20,ButtonHeight},title="",fsize=FontSize,font="Arial",Disable=Enab
		ValDisplay $ControlName,win=$GraphStr,value=#"root:Packages:MFP3D:Main:Variables:LithoVariablesWave[%LithoNumber][%value]",format="%g"
		
		MakeButton(GraphStr,"Litho_Number"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1


	//Show the arrows checkbox
	if (2^bit & Control1Bit)
		ControlName = "ShowArrowTitle"+TabStr
		TitleBox $ControlName,win=$GraphStr,pos={FirstText+50,CurrentTop+1},anchor=RT,frame=0,size={TitleWidth,ButtonHeight},Disable=Enab
		TitleBox $ControlName,win=$GraphStr,title="\F'Arial'\Z12\JRShow Direction Arrows"

		ControlName = "ShowArrowBox"+TabStr
		UpdateCheckBox(GraphStr,ControlName," ",FirstSetVar+30,CurrentTop,"ToggleLithoArrows",GV("LithoUseArrows"),0,Enab)
		
		MakeButton(GraphStr,"Show_Direction_Arrows"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1
	
	
	
	//Setpoint Wave controls
	if (2^bit & Control1Bit)
		ControlName = "UseWaveTitle"+TabStr
		TitleBox $ControlName,win=$GraphStr,pos={FirstText+50,CurrentTop+1},anchor=RT,frame=0,size={TitleWidth,ButtonHeight},Disable=Enab
		TitleBox $ControlName,win=$GraphStr,title="\F'Arial'\Z12\JRSetpoint Wave"	
		ControlName = "LithoUseWaveBox"+TabStr
		UpdateCheckBox(GraphStr,ControlName," ",FirstSetVar+30,CurrentTop,"LithoBoxFunc",GV("LithoUseWave"),0,Enab)

		MakeButton(GraphStr,"Use_Setpoint_Wave"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1


	//Save data checkbox
	if (2^bit & Control1Bit)
		ControlName = "LithoSaveTitle"+TabStr
		TitleBox $ControlName,win=$GraphStr,pos={FirstText+50,CurrentTop+1},anchor=RT,frame=0,size={TitleWidth,ButtonHeight},Disable=Enab
		TitleBox $ControlName,win=$GraphStr,title="\F'Arial'\Z12\JRSave Data"
		ControlName = "LithoSaveBox"+TabStr
		UpdateCheckBox(GraphStr,ControlName," ",FirstSetvar+30,CurrentTop,"LithoBoxFunc",GV("LithoSave"),0,Enab)
		
		
		ControlName = "LithoChannelButton"+TabStr
		MakeButton(GraphStr,ControlName,"Channels",80,20,FirstSetvar+55,CurrentTop-1,"LithoGroupFunc",Enab)
		
		MakeButton(GraphStr,"Litho_Save_Wave"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1


	//Offline Button
	if (2^Bit & Control1Bit)
		ControlName = "LithoOffline"+"Button"+TabStr
		HelpName = "Litho_Review"+TabStr
		MakeButton(GraphStr,ControlName,"Litho Review",120,ButtonHeight,(HelpPos-FirstText-180)/2,CurrentTop,"DoLithoSnapFunc",Enab)
		
		UpdateButton(GraphStr,HelpName,"?",15,15,HelpPos,CurrentTop,HelpFunc,DisableHelp)
		UpdateCheckbox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",2^bit & oldControl1Bit,0,Enab)

		CurrentTop += StepSize

	endif
	Bit += 1
	LeftPos = Margin


	//Mode popup
	if (2^bit & Control1Bit)
		ControlName = "ImagingModePopup"+TabStr
		UpdatePopup(GraphStr,ControlName,"Litho Mode",45,CurrentTop,"MainPopupFunc","ImageModeList()",ImagingModeParms.ImagingMode+1,Enab)
		
		MakeButton(GraphStr,"Litho_Mode"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += 30
	endif
	bit += 1



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Snap Controls

	//Use Snap checkbox & Pre Scan Button
	if (2^bit & Control1Bit)
		ControlName = "LithoSnapTitle"+TabStr
		TitleBox $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop+1},frame=0,size={TitleWidth,ButtonHeight},Disable=Enab
		TitleBox $ControlName,win=$GraphStr,title="\F'Arial'\Z12\JRUse Snap"
		
		
		LeftPos += 60
		ControlName = "LithoSnapBox"+TabStr
		UpdateCheckBox(GraphStr,ControlName," ",LeftPos,CurrentTop,"LithoBoxFunc",GV("LithoSnap"),0,Enab)
		
		LeftPos = FirstSetVar
		ControlName = "DoLithoPreSnap"+"Button"+TabStr
		MakeButton(GraphStr,ControlName,"Pre Scan",ButtonWidth,ButtonHeight,LeftPos,CurrentTop,"DoLithoSnapFunc",Enab)
	
		
		MakeButton(GraphStr,"Litho_Use_Snap"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1
	LeftPos = Margin

	//Show Z Line & Snap Scan Buttons
	if (2^Bit & Control1Bit)
		ControlName = "DoLithoSnapGraph"+"Button"+TabStr
		HelpName = "Draw_Z_Path"+TabStr
		MakeButton(GraphStr,ControlName,"Draw Z Path",ButtonWidth,ButtonHeight,LeftPos,CurrentTop,"DoLithoSnapFunc",Enab)
		
		LeftPos = FirstSetVar
		ControlName = "DoLithoSnap"+"Button"+TabStr
		MakeButton(GraphStr,ControlName,"Snap Litho",ButtonWidth,ButtonHeight,LeftPos,CurrentTop,"DoLithoSnapFunc",Enab)

		UpdateButton(GraphStr,HelpName,"?",15,15,HelpPos,CurrentTop,HelpFunc,DisableHelp)
		UpdateCheckbox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",2^bit & oldControl1Bit,0,Enab)

		CurrentTop += StepSize

	endif
	Bit += 1
	LeftPos = Margin


	//Snappy trigger Checkbox
	if (2^bit & Control1Bit)
		ControlName = "LithoTrigSnap"+"Box"+TabStr
		
		MakeCheckbox(GraphStr,ControlName,"Triggered Snap",LeftPos,CurrentTop,"LithoBoxFunc",GV("LithoTrigSnap"),0,Enab)

		MakeButton(GraphStr,"Triggered_Snap"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//End Snap Controls


	//Make other
	if (2^bit & Control1Bit)
		MakeButton(GraphStr,MakeName,MakeTitle,180,ButtonHeight,(HelpPos-FirstText-180)/2,CurrentTop,"MakePanelProc",Enab)
	
		MakeButton(GraphStr,"Make_Other_Litho_Panel"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
		
		UpdateCheckBox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1



	MakeButton(GraphStr,SetupName,"Setup",ButtonWidth,ButtonHeight,FirstSetVar,CurrentTop,SetupFunc,Enab)
	MakeButton(GraphStr,"Litho_Panel_Setup"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFunc,DisableHelp)
	
	CurrentTop += StepSize
	
	PanelParms[%CurrentBottom][0] = CurrentTop		//save the bottom position of the controls
	
	CountLithoSections()
//	GhostLithoPanel()
//	DrawLithoFunc("StopDraw")			//we can not be drawing while you make a Litho Panel
	//Bugs would appear.
End //MakeLithoPanel


Function LithoSetVarFunc(ctrlName,varNum,varStr,varName)
	String ctrlName			//used
	Variable varNum			//used
	String varStr			//used
	String varName			//VERY much used
	
	
	String ParmName = VarName[StrSearch(VarName,"%",0)+1,StrSearch(VarName,"]",0)-1]

//	DoSetVarMath(ParmName,VarNum,VarStr)		//pass by ref.
	
	UnitsCalcFunc(ctrlName,varNum,varStr,varName)			//pass by ref
	VarNum = Limit(VarNum,GVL(ParmName),GVH(ParmName))
	UpdateUnits(ParmName,varNum)
	NewUpdateFormat(ParmName)
	if (!StringMatch(ParmName,"*SetPoint*"))
		NewUpdateClickVar(ParmName,varNum)
	endif
	PV(ParmName,VarNum)

	
	if (StringMatch(CtrlName,"*LithoMax*") == 1)
		UpdateLithoTime(CalcLithoTime())
	endif

	
		
End //LithoSetVarFunc


Function GhostLithoGraph()


	Variable BiasMode = GV("LithoUseBias")

	//Now our job is to rename the litho voltage graph
	
	String LithoType = ""
	if (BiasMode)
		LithoType = "Voltage"
	else
		LithoType = "Setpoint"
	endif
	String GraphStr = "LithoVoltageGraph"

	if (IsWindow(GraphStr))
		DoWindow/T $GraphStr,"Litho "+LithoType
	endif

	
	//Now it is our job to make sure the voltage setvars have the correct format
	
	String ParmName = ""
	String FormStr = ""
	Variable MinUnits
	Struct ARImagingModeStruct ImagingModeParms
	ARGetImagingMode(ImagingModeParms)

	
	if (BiasMode)
		ParmName = "SurfaceVoltage"
	else
		ParmName = ImagingModeParms.SetpointParm
	endif
	FormStr = GFS(ParmName)
	MinUnits = GVMU(ParmName)
	
	String cVar, VarList = "LithoStartVolts;LithoEndVolts;LithoStep;"
	Variable A, nop = ItemsInList(VarList,";")
	for (A = 0;A < nop;A += 1)
		cVar = StringFromList(A,VarList,";")
		PFS(cVar,FormStr)
		PVMU(cVar,MinUnits)
		newUpdateFormat(cVar)
	endfor

End //GhostLithoGraph


Function LithoBoxFunc(ctrlName,checked)
	String ctrlName
	Variable checked

	UpdateAllCheckBoxes(CtrlName,checked)

	String EndStr = ""
	Variable RemIndex = FindLast(CtrlName,"_")
	if (RemIndex > -1)
		EndStr = CtrlName[RemIndex,Strlen(CtrlName)-1]
		CtrlName = CtrlName[0,RemIndex-1]
	endif
	RemIndex = FindLast(CtrlName,"Check")
	if (RemIndex > -1)
		CtrlName = CtrlName[0,RemIndex-1]
	endif
	RemIndex = FindLast(CtrlName,"Box")
	if (RemIndex > -1)
		CtrlName = CtrlName[0,RemIndex-1]
	endif

	

	strswitch (ctrlName)
	
		case "LithoUseWave":
			PV(CtrlName,Checked)
			GhostLithoPanel()
			GhostLithoGraph()
			if (checked)
				LithoVoltageSetVarFunc("LithoStepSetVar_4",GV("LithoStep"),num2str(GV("LithoStep")),":LithoVariablesWave[%LithoStep]")
				MakeLithoVoltage()
				
				DoWindow/F LithoVoltageGraph
				if (V_flag == 0)
					PV("LithoSegment",0)
					MakeLithoVoltageGraph()
				endif
				DoWindow/K LithoHeightGraph
			else
				DoWindow/K LithoVoltageGraph
			endif
			break
			
		case "LithoTrigSnap":
		case "LithoSave":
			PV(CtrlName,checked)
			break
			
		case "LithoUseBias":
		case "LithoSnap":
			PV(CtrlName,checked)
			GhostLithoPanel()
			GhostLithoGraph()
			break
		
		case "LithoFreeHand":
			PV("LithoDrawMode",!Checked)
			UpdateAllCheckBoxes("LithoLineCheck"+EndStr,!checked)
			if (GV("LithoUseArrows"))
				PutLithoOnEveryOne(0)
			endif
			break
			
		case "LithoLine":
			PV("LithoDrawMode",Checked)
			UpdateAllCheckBoxes("LithoFreeHandCheck"+EndStr,!checked)
			if (GV("LithoUseArrows"))
				PutLithoOnEveryOne(0)
			endif
			break
			
		case "LithoStepUseWave":
		case "LithoStepUseBias":
			PV(CtrlName,Checked)
			GhostLithoStepPanel()
			break
			
	endswitch
		
End //LithoBoxFunc


//Function MakeLithoHeight()
//
//	String SavedDataFolder = GetDataFolder(1)
//	SetDataFolder root:Packages:MFP3D:Litho:
//	
//	Wave YLitho
//	Wave XLitho
//
//	WaveStats/Q/M=1 YLitho
//	Variable MaxY = V_max
//	Variable MinY = V_min
//	WaveStats/Q/M=1 XLitho
//	Variable MaxX = V_max
//	Variable MinX = V_min
//	
//	Make/O/N=(DimSize(YLitho,0)) LithoMarker, HeightZero, LithoHeight, HeightX
//	LithoMarker = p
//	HeightZero = -10e-9
//	LithoHeight = 0
//	
//	String GraphStr = "Channel1Image0"
//
//	DoWindow/F $GraphStr
//	if (V_Flag)
//		SetAxis/W=$GraphStr left MinY, MaxY
//		SetAxis/W=$GraphStr bottom MinX, MaxX
//		ModifyGraph/W=$GraphStr mode(YLitho)=4
//		ModifyGraph/W=$GraphStr msize(YLitho)=6
//		ModifyGraph/W=$GraphStr textMarker(YLitho)={LithoMarker,"default",0,0,5,0.00,0.00}
//	endif
//	
//	HeightX = 0
//	Variable i, stop = DimSize(HeightX,0)
//	for (i = 1;i < stop;i += 1)
//		
//		HeightX[i] = HeightX[i-1]+sqrt((YLitho[i]-YLitho[i-1])^2+(XLitho[i]-XLitho[i-1])^2)
//		
//	endfor
//
//	SetDataFolder SavedDataFolder
//End //MakeLithoHeight
//
//
//Function MakeLithoHeightGraph()
//
//	String SavedDataFolder = GetDataFolder(1)
//	SetDataFolder root:Packages:MFP3D:Litho:
////Dead Function????	
//	String GraphStr = "LithoHeightGraph"
//	DoWindow/F $GraphStr
//	if (V_Flag)
//		return(0)
//	endif
//
//	Display/K=1/N=$GraphStr/W=(10,10,410,260) HeightZero vs HeightX as "Litho Height"
//
////	AppendToGraph LithoHeight vs HeightX
////	ModifyGraph mode(LithoHeight)=4,marker(LithoHeight)=19
//	
//	SetAxis/W=$GraphStr left -10e-9,100e-9
//	ModifyGraph/W=$GraphStr textMarker(HeightZero)={LithoMarker,"default",0,0,1,0.00,0.00}
//	ModifyGraph/W=$GraphStr msize(HeightZero)=6,mode(HeightZero)=3
//	ModifyGraph/W=$GraphStr rgb(HeightZero)=(24576,24576,65535)
//
//	GraphWaveDraw/W=$GraphStr/M/O/F=3 YHeightDraw, XHeightDraw				//set it up for drawing
//	
//	
//	
//	ARControlBar(GraphStr)
//	MakeButton(GraphStr,"LithoHeightRestartButton_0","Restart",60,20,10,40,"LithoHeightGraphFunc",0)
//	MakeButton(GraphStr,"LithoHeightFinishButton_0","Finish",60,20,80,40,"LithoHeightGraphFunc",0)
////	Button Restart pos={10,5},size={60,20},proc=LithoHeightGraphFunc,title="Restart"
////	Button Finish pos={80,5},size={60,20},proc=LithoHeightGraphFunc,title="Finish"
//	ScaleControlBar(graphStr,15)
//	
//
//	SetDataFolder SavedDataFolder
//End //MakeLithoHeightGraph
//
//
//Function LithoHeightGraphFunc(ctrlName)
//	String ctrlName
////Dead Function????
//	Variable RemIndex = FindLast(CtrlName,"_")
//	if (RemIndex > -1)
//		CtrlName = CtrlName[0,RemIndex-1]
//	endif
//	RemIndex = FindLast(CtrlName,"Button")
//	if (RemIndex > -1)
//		CtrlName = CtrlName[0,RemIndex-1]
//	endif
//	
//	String GraphStr = "LithoHeightGraph"
//	if (!IsWindow(GraphStr))
//		return(0)
//	endif
//	
//
//	if (Stringmatch(ctrlName,"*Restart*"))
//		RemoveFromGraph/W=$GraphStr/Z HeightY
//		GraphWaveDraw/W=$GraphStr/M/O/F=3 YHeightDraw, XHeightDraw				//set it up for drawing
//	else
//		GraphNormal/W=$GraphStr
//		String SavedDataFolder = GetDataFolder(1)
//		SetDataFolder root:Packages:MFP3D:Litho:
//	
//		Wave HeightX
//		Wave YHeightDraw
//		Wave XHeightDraw
//		Duplicate/O HeightX HeightY
//		Variable i, stop = DimSize(HeightX,0)
//		
//		HeightY[0] = 0
//		for (i = 1;i < stop;i += 1)
//			
//			FindLevel/Q XHeightDraw HeightX[i]
//			HeightY[i]=YHeightDraw(V_LevelX)
//		
//		endfor
//		
//		AppendToGraph/W=$GraphStr HeightY vs HeightX
//		ModifyGraph/W=$GraphStr mode(HeightY)=3,marker(HeightY)=19,rgb(HeightY)=(0,0,0)
//		SetDataFolder SavedDataFolder
//	endif
//
//End //LithoHeightGraphFunc


Function MakeLithoGroupPanel(var)
	Variable Var  //This is a bit, bit 0, Which panel to put it on, not used.
	//bit 1, if it is in setup mode or not.

	Variable SetUpMode = (var & 2) >= 1
	Var = (Var & 1) >= 1


	String DataFolder = GetDF("Windows")
	
	String GraphStr = GetFuncName()
	GraphStr = GraphStr[4,Strlen(GraphStr)-1]
	Wave PanelParms = $DataFolder+GraphStr+"Parms"
	String MasterPanel = ARPanelMasterLookup(GraphStr)
	Wave MasterParms = $DataFolder+MasterPanel+"Parms"
	

	Variable TabNum = ARPanelTabNumLookup(GraphStr)
	String TabStr = "_"+num2str(TabNum)
	String SetupTabStr =  TabStr+"9"

	Variable CurrentTop, Enab = 0
	String SetupFunc = "", MakeTitle = "", MakeName = "", SetupName = ""
	if (Var == 0)		//MasterLithoPanel
		GraphStr = MasterPanel
		CurrentTop = 40
		SetupName = GraphStr+"Setup"+TabStr
		MakeTitle = "Make Litho Groups Panel"
		MakeName = "LithoGroupButton"+TabStr
		Enab = 1		//leave it up to TabFunc
	elseif (Var == 1)		//LithoGroupPanel
		CurrentTop = 15
		SetupName = "LithoGroupPanelSetup"+TabStr
		MakeName = "MasterLitho"+Tabstr
		MakeTitle = "Make Master Litho Panel"
	endif
	SetupFunc = "ARSetupPanel"
	
	Variable DisableHelp = 0			//do we have a help file yet?
	
	Variable Red = PanelParms[%RedColor][0]
	Variable Green = PanelParms[%GreenColor][0]
	Variable Blue = PanelParms[%BlueColor][0]
	Variable FirstButton = PanelParms[%FirstButton][0]
	Variable SecondButton = PanelParms[%SecondButton][0]
	Variable ButtonWidth = PanelParms[%ButtonWidth][0]
	Variable SetVarWidth = PanelParms[%SetVarWidth][0]
	Variable BodyWidth = PanelParms[%BodyWidth][0]
	Variable ListWidth = PanelParms[%ListBoxWidth][0]
	Variable ListHeight = PanelParms[%ListBoxHeight][0]
	Variable SliderWidth = PanelParms[%SliderWidth][0]
	Variable HelpPos = PanelParms[%HelpPos][0]
	Variable Control1Bit = PanelParms[%Control1Bit][0]
	Variable oldControl1Bit = PanelParms[%oldControl1Bit][0]
	Variable SetupLeft = PanelParms[%SetupLeft][0]
	Variable DidRow = 0
	Variable DidCol = 0
	Variable bit = 0
	Variable FontSize = 14
	String HelpFuncStr = "ARHelpFunc"
	Variable StepSize = 25


	Variable FirstHelpPos = SecondButton-FirstButton-HelpPos
	Variable FirstSetupPos = FirstHelpPos+SetupLeft
	if (SetupMode == 1)
		SecondButton += 50
	endif
	Variable SecondHelpPos = SecondButton+SliderWidth-HelpPos
	Variable SecondSetUpPos = SecondHelpPos+SetupLeft
	
	InitRealLastTitleString()
	

	String TopImageStr = StringFromList(0,WinList("Channel*Image*",";","WIN:1"))		//get the top realtime graph
	if (strlen(TopImageStr))
		Wave ImageWave = ImageNameToWaveRef(TopImageStr,StringFromList(0,ImageNameList(TopImageStr,";")))	//reference the image Wave
		UpdateLithoSize(ImageWave)
//		PV("LithoFastScanSize",DimSize(ImageWave,0)*DimDelta(ImageWave,0)+DimOffset(ImageWave,0))		//grab the image size
//		PV("LithoSlowScanSize",DimSize(ImageWave,1)*DimDelta(ImageWave,1)+DimOffset(ImageWave,1))		//grab the image size
 	endif

	Wave/T GroupList = root:Packages:MFP3D:Litho:groups:GroupList
	Make/O/N=(DimSize(GroupList,0))/W root:Packages:MFP3D:Litho:groups:GroupListBuddy
	
	
	String ControlName = ""
	
	if (Control1Bit & 2^bit)
		ControlName = "GroupTitle"+TabStr
		TitleBox $ControlName,win=$GraphStr,pos={FirstButton,CurrentTop},title="\\F'Arial'\\Z12Groups",frame=0
		ControlName = "GroupList"+TabStr
		ListBox $ControlName,win=$GraphStr,font="Arial",fsize=12,frame=2,mode=1//,selWave=root:Packages:MFP3D:Litho:groups:GroupListBuddy
		ListBox $ControlName,win=$GraphStr,pos={FirstButton,CurrentTop+20},listWave=root:Packages:MFP3D:Litho:groups:GroupList,size={ListWidth,ListHeight},proc=LithoGroupListProc
		UpdateAllListboxes(ControlName,1,NaN)		//Make sure that if there are any other Panels up, the listboxes match.

		MakeButton(GraphStr,"Group_List"+TabStr,"?",15,15,FirstHelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		

		UpdateCheckBox(GraphStr,"LithoGroupBit_"+num2str(bit)+SetupTabStr,"Show?",FirstSetupPos,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		DidRow = 1
		DidCol = 1
		CurrentTop += 85
	endif
	Bit += 1
	
	//Litho Size SetVar and slider
	if (Control1Bit & 2^bit)
	
		MakeSetVar(GraphStr,"","LithoSize","Size","LithoGroupSetVarFunc","",SecondButton+40,CurrentTop,SetVarwidth,bodyWidth,TabNum,FontSize,Enab)
	
		ControlName = "LithoSizeSlider"+TabStr
		Slider $ControlName,win=$GraphStr,pos={SecondButton,CurrentTop+25},size={SliderWidth,47},limits={1e-9,GV("LithoScanSize"),0},value=GV("LithoScanSize"),vert=0
		Slider $ControlName,win=$GraphStr,proc=LithoSliderFunc,thumbColor=(Red,Green,Min(Blue,65279))		//Variable=root:Packages:MFP3D:Main:Variables:LithoVariablesWave[%LithoSize]
		

		MakeButton(GraphStr,"Litho_Size"+TabStr,"?",15,15,SecondHelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)

		UpdateCheckBox(GraphStr,"LithoGroupBit_"+num2str(bit)+SetupTabStr,"Show?",SecondSetupPos,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		DidRow += 2
		CurrentTop += 100
	endif
	Bit += 1
	
	
	
	//Y offset controls
	if (Control1Bit & 2^bit)
		//make the slider first so that the SetVar will showup on top of it.
	
		ControlName = "LithoYOffsetSlider"+TabStr
		Slider $ControlName,win=$GraphStr,pos={SecondButton+80,CurrentTop-25},size={20,SliderWidth-20},limits={GVL("LithoYOffset"),GVH("LithoYOffset"),0},value=GV("LithoYOffset"),vert=1
		Slider $ControlName,win=$GraphStr,proc=LithoSliderFunc,side=2,thumbColor=(Red,Green,Min(Blue,65279))	//Variable=root:Packages:MFP3D:Main:Variables:LithoVariablesWave[%LithoSize]
		
		
		MakeSetVar(GraphStr,"","LithoYOffset","Y Offset","LithoGroupSetVarFunc","",SecondButton+30,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)
		

		MakeButton(GraphStr,"Litho_Y_Offset"+TabStr,"?",15,15,SecondHelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoGroupBit_"+num2str(bit)+SetupTabStr,"Show?",SecondSetupPos,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		if (!(DidRow & 2))
			DidRow += 2
		endif
		CurrentTop += 160
	endif
	Bit += 1


	if ((DidRow & 1) && (!(DidRow & 2)))			//we only did the ListBox
		CurrentTop += 260
	endif
	
	DidRow = 0
	
	Variable Row1Bit = 0
	
	//Display Group button
	if (Control1Bit & 2^bit)
		ControlName = "DisplayGroup"+TabStr
		MakeButton(GraphStr,ControlName,"Display Group",ButtonWidth,20,FirstButton,CurrentTop,"LithoGroupButtonFunc",0)
		
		MakeButton(GraphStr,"Display_Group"+TabStr,"?",15,15,FirstHelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)

		UpdateCheckBox(GraphStr,"LithoGroupBit_"+num2str(bit)+SetupTabStr,"Show?",FirstSetupPos,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		DidCol = 1
		DidRow = 1
		Row1Bit += 1
	endif	
	Bit +=1


	//X Offset Controls
	if (Control1Bit & 2^bit)
	
		MakeSetVar(GraphStr,"","LithoXOffset","X Offset","LithoGroupSetVarFunc","",SecondButton+50,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)
	
		ControlName = "LithoXOffsetSlider"+TabStr
		Slider $ControlName,win=$GraphStr,pos={SecondButton,CurrentTop+35},size={SliderWidth,20},limits={GVL("LithoXOffset"),GVH("LithoXOffset"),0},value=GV("LithoXOffset"),vert=0
		Slider $ControlName,win=$GraphStr,proc=LithoSliderFunc,thumbColor=(Red,Green,Min(Blue,65279))		//Variable=root:Packages:MFP3D:Main:Variables:LithoVariablesWave[%LithoXOffset]

		MakeButton(GraphStr,"Litho_X_Offset"+TabStr,"?",15,15,SecondHelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)

		UpdateCheckBox(GraphStr,"LithoGroupBit_"+num2str(bit)+SetupTabStr,"Show?",SecondSetupPos,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		DidRow += 2
	endif
	Bit += 1

	if (DidRow & 1)
		CurrentTop += StepSize
		DidRow -= 1
	endif


	//AppendGroup Button
	if (Control1Bit & 2^bit)
		ControlName = "AppendGroup"+TabStr
		MakeButton(GraphStr,ControlName,"Add Group",ButtonWidth,20,FirstButton,CurrentTop,"LithoGroupButtonFunc",0)
		
		MakeButton(GraphStr,"Append_Group"+TabStr,"?",15,15,FirstHelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoGroupBit_"+num2str(bit)+SetupTabStr,"Show?",FirstSetupPos,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		DidCol = 1
		DidRow += 1
		Row1Bit += 2
		CurrentTop += 27
	endif	
	Bit +=1

	if (DidRow & 1)
		DidRow -= 1
	endif

	
	//Clear Image Button
	if (Control1Bit & 2^bit)
		ControlName = "ClearImages"+TabStr
		MakeButton(GraphStr,ControlName,"Clear Images",ButtonWidth,20,FirstButton,CurrentTop,"LithoGroupButtonFunc",0)
		
		MakeButton(GraphStr,"Clear_Images"+TabStr,"?",15,15,FirstHelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)

		UpdateCheckBox(GraphStr,"LithoGroupBit_"+num2str(bit)+SetupTabStr,"Show?",FirstSetupPos,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		DidCol = 1
		DidRow += 1
		Row1Bit += 4
		CurrentTop +=27
	endif
	Bit += 1
	
	
	
	if (DidRow & 2)				//if we put up the slider then we have to add in 
		if (!(Row1Bit & 1))//some more space for the left hand controls that were left out.
			CurrentTop += StepSize
		endif
		if (!(Row1Bit & 2))
			CurrentTop += 27
		endif
		if (!(Row1Bit & 4))
			CurrentTop += 27
		endif
	endif	
	
	DidRow = 0


	//GDS Load Button
	if (Control1Bit & 2^bit)
		ControlName = "LoadGDSButton"+TabStr
		MakeButton(GraphStr,ControlName,"Load GDS",ButtonWidth,20,FirstButton,CurrentTop,"GDSbuttonProc",0)

		MakeButton(GraphStr,"Load_GDS"+TabStr,"?",15,15,FirstHelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)

		UpdateCheckBox(GraphStr,"LithoGroupBit_"+num2str(bit)+SetupTabStr,"Show?",FirstSetupPos,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		DidCol = 1
		DidRow = 1
	endif	
	Bit +=1



	//Rotation Controls
	if (Control1Bit & 2^bit)
		MakeSetVar(GraphStr,"","LithoAngle","Rotation","LithoGroupSetVarFunc","",SecondButton+50,CurrentTop,SetVarWidth,bodyWidth,TabNum,FontSize,Enab)

		ControlName = "LithoAngleSlider"+TabStr
		Slider $ControlName,win=$GraphStr,pos={SecondButton,CurrentTop+20},size={SliderWidth,20},limits={GVL("LithoAngle"),GVH("LithoAngle"),0},value=GV("LithoAngle"),vert=0
		Slider $ControlName,win=$GraphStr,proc=LithoSliderFunc,thumbColor=(Red,Green,Min(Blue,65279))		//Variable=root:Packages:MFP3D:Main:Variables:LithoVariablesWave[%LithoXOffset]

		MakeButton(GraphStr,"Litho_Angle"+TabStr,"?",15,15,SecondHelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)

		UpdateCheckBox(GraphStr,"LithoGroupBit_"+num2str(bit)+SetupTabStr,"Show?",SecondSetupPos,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		DidRow += 2
	endif
	Bit += 1

	if (DidRow & 1)
		CurrentTop+=25
		DidRow -= 1
	endif


	//Image Import Button
	if (Control1Bit & 2^bit)
		ControlName = "LoadPicture"+TabStr
		MakeButton(GraphStr,ControlName,"Load Picture",ButtonWidth,20,FirstButton,CurrentTop,"LithoGroupButtonFunc",0)

		MakeButton(GraphStr,"Load_Picture"+TabStr,"?",15,15,FirstHelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		
		UpdateCheckBox(GraphStr,"LithoGroupBit_"+num2str(bit)+SetupTabStr,"Show?",FirstSetupPos,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		DidCol = 1
		DidRow += 1
		CurrentTop += StepSize
	endif	
	Bit +=1

	if (!(DidRow & 1) && ((DidRow & 2)))			//we only did the Slider
		CurrentTop += StepSize
	endif


	if (DidCol == 0)
		ShiftControls(GraphStr,SecondButton-FirstButton,1)			//shift only visible controls
		CurrentTop += 35
	endif


	//Make other
	if (2^bit & Control1Bit)
		MakeButton(GraphStr,MakeName,MakeTitle,180,20,FirstButton,CurrentTop,"MakePanelProc",0)
	
		MakeButton(GraphStr,"Make_Other_Litho_group_Panel"+TabStr,"?",15,15,FirstButton+180+HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)

		UpdateCheckBox(GraphStr,"LithoGroupBit_"+num2str(bit)+SetupTabStr,"Show?",FirstSetupPos+60,CurrentTop,"NoShowFunc",(2^bit & oldControl1Bit),0,Enab)
		CurrentTop += StepSize
	endif
	bit += 1

	//Setup Controls
	MakeButton(GraphStr,SetupName,"Setup",ButtonWidth,20,FirstButton,CurrentTop,SetupFunc,0)
	MakeButton(GraphStr,"Litho_Group_Setup"+TabStr,"?",15,15,FirstHelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
	CurrentTop += StepSize

	PanelParms[%CurrentBottom][0] = CurrentTop		//save the bottom position of the controls

	
End //MakeLithoGroupPanel


Function LithoSliderFunc(ctrlName,var,event)
	String ctrlName
	Variable var, event
	
	Variable Bit2Work = 2^0+2^2		//compair with the event, to see when this function should do something.
	
	Variable RemInd = FindLast(CtrlName,"_")
	String EndStr = ""
	if (RemInd > -1)
		EndStr = CtrlName[RemInd,Strlen(CtrlName)-1]
		CtrlName = CtrlName[0,RemInd-1]
	endif
	
	
	Wave LVW = root:Packages:MFP3D:Main:Variables:LithoVariablesWave
	strswitch (ctrlName)
		case "LithoSizeSlider":
			LVW[%LithoSize][%value] = var
			if (event & Bit2Work)
				LithoGroupSetVarFunc("LithoSizeSetVar"+EndStr,var,"","")
			endif
			break
			
		case "LithoYOffsetSlider":
			LVW[%LithoYOffset][%value] = var
			if (event & Bit2Work)
				LithoGroupSetVarFunc("LithoYOffsetSetVar"+EndStr,var,"","")
			endif
			break
			
		case "LithoXOffsetSlider":
			LVW[%LithoXOffset][%value] = var
			if (event & Bit2Work)
				LithoGroupSetVarFunc("LithoXOffsetSetVar"+EndStr,var,"","")
			endif
			break
			
		case "LithoAngleSlider":
			LVW[%LithoAngle][%value] = var
			if (event & Bit2Work)
				LithoGroupSetVarFunc("LithoAngleSetVar"+EndStr,var,"","")
			endif
			break
			
	endswitch
	
End //LithoSliderFunc


Function LithoGroupButtonFunc(ctrlName)
	String ctrlName
	
	
	Variable RemInd = FindLast(CtrlName,"_")
	if (RemInd > -1)
		CtrlName = CtrlName[0,RemInd-1]
	endif
	
	strswitch (ctrlName)
		case "DisplayGroup":
			DisplayGroupFunc()
			break
			
		case "AppendGroup":
			AppendGroupFunc()
			break
			
		case "LoadPicture":
			LoadLithoPicture()
			break
			
		case "ClearImages":
			ClearLithoGroups()
			break
			
	endswitch
	
End //LithoGroupButtonFunc


Function UpdateLithoSize(ImageWave)
	Wave ImageWave
	
	Variable FastScanSize = (DimSize(ImageWave,0)-1)*DimDelta(ImageWave,0)
	Variable SlowScanSize = (DimSize(ImageWave,1)-1)*DimDelta(ImageWave,1)
	Variable ScanSize = Max(FastScanSize,SlowScanSize)
	PV("LithoScanSize",ScanSize)
	PVH("LithoSize",ScanSize)
	PV("LithoFastScanSize",FastScanSize)
	PV("LithoSlowScanSize",SlowScanSize)

End //UpdateLithoSize


Function LoadLithoPicture()

	String SavedDataFolder = GetDataFolder(1)
	NewDataFolder/O/S root:Packages:MFP3D:Litho:Pictures
	Variable/G TotalContour, Contour
	SVAR IgorColorStr = root:Packages:MFP3D:Main:Display:IgorColorStr
	//String/G LithoColorStr = "Highlight;Just One;"+RemoveFromList("Off",IgorColorStr)
	String/G LithoColorStr = "Highlight;Just One;"+CTabList()
	
	ImageLoad/T=any
	if (v_flag == 0)			//cancel
		SetDataFolder(SavedDataFolder)
		return(0)
	endif
//ImageLoad/Q/T=tiff "Calvin:Applications:Igor Pro Folder:AsylumResearch:Code3D:GE Logo smaller.tiff"


	String GraphStr = "PictureGraph"
	

	DoWindow/K ContourGraph
	
//String S_FileName = "small.jpg"
	Wave ContourImage = $StringFromList(0,S_WaveNames,";")
	Make/O/N=(DimSize(ContourImage,0),DimSize(ContourImage,1)) FlatWave
	Variable height = DimSize(ContourImage,1)-1
	FlatWave = (ContourImage[p][height-q][0]+ContourImage[p][height-q][1]+ContourImage[p][height-q][2])/3
	KillWaves ContourImage
	
	
	DoWindow/K $GraphStr
	NewImage/K=1/N=$GraphStr FlatWave
	DoWindow/T $GraphStr "Picture"
	SetAxis/W=$GraphStr/A Left
	Variable ScrRes = 72/ScreenResolution	
	Variable MinWidth = 315/.6*ScrRes

	GetWindow $GraphStr wsize

	GraphStr = "ContourGraph"

	Struct ARWindowStruct WinStruct
	WinStruct.WindowType = 1		//graph
	WinStruct.GraphStr = GraphStr
	WinStruct.TitleStr = "Contour"
	WinStruct.KillFlag = 1
	WinStruct.HookFunc = ""
	WinStruct.Left = V_Left
	WinStruct.Top = V_Top
	WinStruct.Right = V_Right
	WinStruct.Bottom = V_Bottom+30
	
	
	ARSafeNewWindow(WinStruct)
	GraphStr = WinStruct.GraphStr
	
	
	AppendMatrixContour/T/W=$GraphStr FlatWave
	ModifyContour/W=$GraphStr FlatWave labels=0,autoLevels={*,*,1}
	DoUpdate
	ModifyGraph/W=$GraphStr width={Plan,1,top,left}
	ModifyGraph/W=$GraphStr margin(left)=14,margin(bottom)=14,margin(top)=14,margin(right)=14
	ModifyGraph/W=$GraphStr mirror=2
//	ModifyGraph/W=$GraphStr nticks(left)=11,nticks(top)=12
	ModifyGraph/W=$GraphStr minor=1,fSize=9,standoff=0
	ModifyGraph/W=$GraphStr tkLblRot(left)=90,btLen=3,tlOffset=-2
	DoUpdate

	ControlBar/W=$GraphStr 30
	SetVariable TotalContourSetvar,win=$GraphStr,pos={5,5},size={130,20},title="Total Contour"
	SetVariable TotalContourSetvar,win=$GraphStr,font="Arial",fsize=12,value= TotalContour,proc=ContourSetvarFunc
	SetVariable WhichContourSetvar,win=$GraphStr,pos={150,5},size={135,20},title="Which Contour"
	SetVariable WhichContourSetvar,win=$GraphStr,font="Arial",fsize=12,value= Contour,proc=ContourSetvarFunc
	Button SaveGroup,win=$GraphStr,pos={295,4},size={80,20},title="Save Group",proc=SavePictureGroup
	PopupMenu ColorPopup,win=$GraphStr,pos={380,4},size={110,20},title="Color",proc=LithoPicturePopup
	PopupMenu ColorPopup,win=$GraphStr,font="Arial",fsize=12,mode=1,value=#"root:Packages:MFP3D:Litho:Pictures:LithoColorStr"
		
//	NVAR TotalContour, Contour
	TotalContour = 1
	Contour = 1
	Make/O/N=(1,3) ContourColor
	MakeupColorWave()
	ModifyContour/W=$GraphStr FlatWave cindexLines=ContourColor
	
	AutoPositionWindow/E/R=PictureGraph $GraphStr
	
	GetWindow $GraphStr,Wsize
	Variable Factor = MinWidth/(V_Right-V_Left)
	if (Factor > 1)
		MoveWindow/W=$Graphstr V_Left,V_Top,0,abs(V_Top-V_Bottom)*Factor+V_Top
	
	endif
	
	

	SetDataFolder SavedDataFolder
End //LoadLithoPicture


Function ClearLithoGroups()
	//Take off the displayed groups from all Images.
	
	String GraphList = WinList("Channel*Image*",";","WIN:1")
	Variable A, nop = ItemsInList(GraphList)
	String GraphStr, RemList
	
	for (A = 0;A < nop;A += 1)
		GraphStr = StringFromList(A,GraphList,";")
		RemList = TraceNameList(GraphStr,";",1)
		if (WhichListItem("GroupDisplayY", RemList,";",0,0) > -1)
			RemoveFromGraph/W=$GraphStr/Z GroupDisplayY
		endif
	endfor

End //ClearLithoGroups


Function ContourSetvarFunc(ctrlName,varNum,varStr,varName)
	String ctrlName
	Variable varNum
	String varStr
	String varName

	NVAR TotalContour = root:Packages:MFP3D:Litho:Pictures:TotalContour
	NVAR Contour = root:Packages:MFP3D:Litho:Pictures:Contour
	Wave ContourColor = root:Packages:MFP3D:Litho:Pictures:ContourColor
	Wave FlatWave = root:Packages:MFP3D:Litho:Pictures:FlatWave


	TotalContour = SafeLimit(TotalContour,1,11)
	Contour = SafeLimit(Contour,1,TotalContour)
	WaveStats/Q/M=1 FlatWave
	Variable increment = (V_max-V_min)/(TotalContour+1)
	Variable start = V_min+increment
	
	if (Stringmatch(ctrlName,"*Total*"))
		ModifyContour/W=ContourGraph FlatWave manLevels={start,increment,TotalContour}
		Redimension/N=(TotalContour,3) ContourColor
	endif
	MakeupColorWave()
	ControlInfo/W=ContourGraph ColorPopup
	if (V_Value > 2)
		ModifyContour/W=ContourGraph FlatWave ctabLines={*,*,$S_Value,0}
	else
		ModifyContour/W=ContourGraph FlatWave cindexLines=ContourColor
	endif
	
End //ContourSetvarFunc


Function LithoPicturePopup(ctrlName,popNum,popStr)
	String ctrlName		//not used
	Variable popNum		//used
	String popStr		//used

	UpdateAllPopups(CtrlName,PopNum)
	if (popNum > 2)
		ModifyContour/W=ContourGraph FlatWave ctabLines={*,*,$popStr,0}
	else
		Wave ContourColor = root:Packages:MFP3D:Litho:Pictures:ContourColor
		ModifyContour/W=ContourGraph FlatWave cindexLines=ContourColor
		MakeupColorWave()
	endif
	
End //LithoPicturePopup


Function MakeupColorWave()

	NVAR Contour = root:Packages:MFP3D:Litho:Pictures:Contour
	Wave FlatWave = root:Packages:MFP3D:Litho:Pictures:FlatWave
	Wave ContourColor = root:Packages:MFP3D:Litho:Pictures:ContourColor
	WaveStats/Q/M=1 FlatWave
	Variable increment = (V_max-V_min)/(Dimsize(ContourColor,0)+1)
	Variable start = V_min+increment
	
	ControlInfo/W=ContourGraph ColorPopup
	
	if (V_Value == 1)
	
		ContourColor = 0
		ContourColor[][0] = 65535
		ContourColor[Contour-1][0] = 0
	else

		ContourColor = 65535
		ContourColor[Contour-1][] = 0
	
	endif

	SetScale/P x start,increment,"", ContourColor
	

End //MakeupColorWave


Function SavePictureGroup(ctrlName)
	String ctrlName
	
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder root:Packages:MFP3D:Litho:Pictures
	
	NVAR Contour
	String traceStr = StringFromList(Contour-1,TraceNameList("ContourGraph",";",2))
	MakeCopyOfTrace("ContourGraph",traceStr)

	String lithoTraceName
	Prompt lithoTraceName, "Save litho group as?"
	DoPrompt "Save litho group as?", lithoTraceName
	if (V_Flag)
		SetDataFolder(SavedDataFolder)
		return(0)
	endif
	
	lithoTraceName = ReplaceString(" ",lithoTraceName,"_",1)
	
	Wave traceCopyY, traceCopyX
	SetDataFolder root:Packages:MFP3D:Litho:Groups
	Duplicate/O traceCopyY $"Y"+lithoTraceName
	Duplicate/O traceCopyX $"X"+lithoTraceName
	LithoGroupList()

	SetDataFolder SavedDataFolder
End //SavePictureGroup


Macro ImportLithoContour()
	ImportLithoGraphic()
End //ImportLithoContour()


Function ImportLithoGraphic()//(traceName, LithoTraceName)
	String traceName, LithoTraceName


	Prompt traceName, "contour trace",popup,TraceNameList("",";",2)
	Prompt LithoTraceName, "Save litho Wave as?"
	DoPrompt GetFuncName(),TraceName,LithoTraceName
	MakeCopyOfTrace("",traceName)
	String XLithoName="root:packages:MFP3D:Litho:groups:X"+LithoTraceName
	String YLithoName="root:packages:MFP3D:Litho:groups:Y"+LithoTraceName
//	print YLithoName
	Duplicate/O root:tracecopyY $YLithoName
	Duplicate/O root:tracecopyX $XLithoName
	Wave/T GroupList = root:packages:MFP3D:Litho:groups:GroupList
	Variable GroupListIndex = numpnts(GroupList)
	InsertPoints/M=0 GroupListIndex,1,GroupList
//	Redimension/N=(GroupListIndex+1) GroupList
	GroupList[GroupListIndex] = LithoTraceName

End //ImportLithoGraphic


Function AppendGroupFunc()

	Wave YLitho = root:Packages:MFP3D:Litho:YLitho
	Variable length = DimSize(YLitho,0)
	if (length)
		LithoGroupFunc("MakeGroup_0")
	endif
	length = DimSize(YLitho,0)
	Wave xLitho = root:Packages:MFP3D:Litho:XLitho
	Wave/Z GroupDisplayY = root:Packages:MFP3D:Litho:groups:GroupDisplayY
	if (WaveExists(GroupDisplayY) == 0)
		return(0)
	endif
	Wave GroupDisplayX = root:Packages:MFP3D:Litho:groups:GroupDisplayX
	
	if (Length)
		InsertPoints length, 1, YLitho, XLitho
		YLitho[length] = NaN
		XLitho[length] = NaN
		Length += 1
	endif
	
	InsertPoints length, DimSize(GroupDisplayY,0), YLitho, XLitho
	YLitho[length,] = GroupDisplayY[p-length]
	XLitho[length,] = GroupDisplayX[p-length]
	
	
	Note/K YLitho
	Note YLitho,Note(GroupDisplayY)
	
	
	if (DimSize(GroupDisplayY,0))
		LithoGroupFunc("MakeGroup_0")
	endif

	String graphStr = StringFromList(0,WinList("Channel*Image*",";","WIN:1"),";")		//get the top realtime graph
	Wave ImageWave = ImageNameToWaveRef(GraphStr,StringFromList(0,ImageNameList(GraphStr,";")))	//reference the image Wave
	UpdateLithoSize(ImageWave)
	RemoveFromGraph/Z/W=$graphStr GroupDisplayY
	if (GV("LithoUseArrows"))
		CalcLithoArrows()
	endif
	PutLithoOnEveryOne(0)
	CountLithoSections()
	UpdateLithoTime(CalcLithoTime())
End //AppendGroupFunc


Function LithoGroupSetVarFunc(ctrlName,varNum,varStr,varName)		//takes care of all of the SetVars on the Main panel
	String ctrlName
	Variable varNum
	String varStr			//this contains any letters as clues for range changes
	String varName


	String SubCtrlName = CtrlName
	Variable RemInd = FindLast(SubCtrlName,"_")
	String EndStr = ""
	if (RemInd > -1)
		EndStr = SubCtrlName[RemInd,Strlen(SubCtrlName)-1]
		SubCtrlName = SubCtrlName[0,RemInd-1]
	endif


	Variable lithoScanSize = GV("LithoScanSize")
	
	String ImageGraphStr = StringFromList(0,WinList("Channel*Image*",";","WIN:1"),";")
	if (Strlen(ImageGraphStr))
		Wave ImageWave = ImageNameToWaveRef(ImageGraphStr,StringFromList(0,ImageNameList(ImageGraphStr,";"),";"))
		UpdateLithoSize(ImageWave)
		LithoScanSize = GV("LithoScanSize")
		UpdateAllSliders("LithoSizeSlider"+EndStr,GV("LithoSize"),GVL("LithoSize"),LithoScanSize,0)
	endif


	String NameVar = UnitsCalcFunc(SubCtrlName,varNum,varStr,varName)		//this calculates any typed in units and also returns the new varNum
	
	String GraphStr = "LithoGroupPanel"
	varNum = Safelimit(varNum,GVL(NameVar),GVH(NameVar))		//make sure that the number is in its limits

	if (StringMatch(NameVar,"LithoAngle") == 1)
		if ((varNum == -360) || (varNum == 360))
			varNum = 0
		endif
		LithoRotate(varNum)
	endif
		
	UpdateAllSliders(NameVar+"Slider"+EndStr,varNum,NaN,NaN,NaN)

	PV(NameVar,varNum)
	UpdateUnits(NameVar,varNum)
	//UpdateFormat(GraphStr,ctrlName)
	newUpdateFormat(NameVar)
	PVU("LithoAngle",1)

	
	Variable lithoSize = GV("LithoSize")
	Variable lithoYOffset = GV("LithoYOffset")
	Variable lithoXOffset = GV("LithoXOffset")
	Variable YSizeOffset, XSizeOffset
	
	Wave/Z GroupDisplayY = root:Packages:MFP3D:Litho:groups:GroupDisplayY
	if (WaveExists(GroupDisplayY) == 0)			//we don't have anything, why is the user trying this now?
		return(0)
	endif
	Wave GroupDisplayX = root:Packages:MFP3D:Litho:groups:GroupDisplayX
	Wave GroupY = root:Packages:MFP3D:Litho:groups:GroupY
	Wave GroupX = root:Packages:MFP3D:Litho:groups:GroupX
	GroupDisplayY = GroupY*lithoSize/50e-6
	GroupDisplayX = GroupX*lithoSize/50e-6
	
	
	Variable NewLimit
	

	
	WaveStats/Q/M=1 GroupDisplayY
	YSizeOffset = (lithoScanSize-V_max)/2
	NewLimit = (LithoScanSize-(V_max-V_min))/2
	PVH("LithoYOffset",NewLimit)
	PVL("LithoYOffset",-NewLimit)
	lithoYOffset = Limit(lithoYOffset,-NewLimit,NewLimit)
	PV("lithoYOffset",lithoYOffset)
	UpdateFormat(GraphStr,"LithoYOffsetSetVar"+EndStr)
	WaveStats/Q/M=1 GroupDisplayX
	NewLimit = (LithoScanSize-(V_max-V_min))/2
	PVH("LithoXOffset",NewLimit)
	PVL("LithoXOffset",-NewLimit)
	LithoXOffset = Limit(LithoXOffset,-NewLimit,NewLimit)
	PV("LithoXOffset",LithoXOffset)
	UpdateFormat(GraphStr,"LithoXOffsetSetVar"+EndStr)
	XSizeOffset = (lithoScanSize-V_max)/2
//	GroupDisplayY += YSizeOffset+lithoYOffset
//	GroupDisplayX += XSizeOffset+lithoXOffset
	
	
	FastOp GroupDisplayY = GroupDisplayY + (YSizeOffset+lithoYOffset)
	FastOp GroupDisplayX = GroupDisplayX + (XSizeOffset+lithoXOffset)
	
	UpdateAllSliders("LithoYOffsetSlider"+EndStr,GV("LithoYOffset"),GVL("LithoYOffset"),GVH("LithoYOffset"),0)
	UpdateAllSliders("LithoXOffsetSlider"+EndStr,GV("LithoXOffset"),GVL("LithoXOffset"),GVH("LithoXOffset"),0)
	
//	Slider $"LithoYOffsetSlider"+EndStr win=LithoGroupPanel,limits={GVL("LithoYOffset"),GVH("LithoYOffset"),0},value=GV("LithoYOffset")
//	Slider $"LithoXOffsetSlider"+EndStr win=LithoGroupPanel,limits={GVL("LithoXOffset"),GVH("LithoXOffset"),0},value=GV("LithoXOffset")
	
End //LithoGroupSetVarFunc


Function LithoGroupListProc(CtrlName,Row,Col,Event)
	String CtrlName		//Used
	Variable Row			//Used
	Variable Col			//not used
	Variable Event		//Not Used
	
	UpdateAllListboxes(CtrlName,Row,NaN)		//make sure that all the listbox versions have the same row selected....
	
End //LithoGroupListProc


Function DisplayGroupFunc()

	String graphStr = StringFromList(0,WinList("Channel*Image*",";","WIN:1"),";")		//get the top realtime graph
	if ((strlen(graphStr) == 0) && GV("RealArgyleReal"))
		ImageChannelCheckFunc("RealArgyleRealBox_1",0)
		graphStr = StringFromList(0,WinList("Channel*Image*",";","WIN:1"),";")		//get the top realtime graph
	endif
	if (strlen(graphStr) == 0)
		DoAlert 0, "There doesn't seem to be an appropriate graph."			//there isn't one!
		return 1
	endif
	AllLithoDrawModes(0)
	//GraphNormal/W=$graphStr
	Wave ImageWave = ImageNameToWaveRef(graphStr,StringFromList(0,ImageNameList(graphStr,";")))	//reference the image Wave
//	PV("LithoScanSize",DimSize(ImageWave,0)*DimDelta(ImageWave,0)+DimOffset(ImageWave,0))		//grab the image size

	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder root:Packages:MFP3D:Litho:groups

	Wave/T GroupList = GroupList
//	Wave GroupListBuddy = GroupListBuddy
//	String WaveListStr = WaveList("!GroupList*",";","")


	String ControlList = ""
	String GraphList = FindControls2("GroupList_*",-1,ControlList)
	Variable A, nop = ItemsInList(GraphList,";")
	Variable FoundIt = 0
	for (A = 0;A < nop;A += 1)
		ControlInfo/W=$StringFromList(A,GraphList,";") $StringFromList(A,ControlList,";")
		if (Abs(V_Flag) == 11)
			FoundIt = 1
			A = inf
		endif
	endfor
	
	if (!FoundIt)
		print "Error in "+GetFuncName()+", Aborting"
		DoWindow/H
		SetDataFolder(SavedDataFolder)
		Return(0)
	endif

	Wave/Z YWave = $"Y"+GroupList[V_Value]
	if (WaveExists(YWave) == 0)
		SetDataFolder SavedDataFolder
		return(0)
	endif
	Wave XWave = $"X"+GroupList[V_Value]
	Duplicate/O YWave GroupBaseY GroupY GroupDisplayY
	Duplicate/O XWave GroupBaseX GroupX GroupDisplayX

	LithoRotate(GV("LithoAngle"))

	
	LithoGroupSetVarFunc("LithoSizeSetVar_1",GV("LithoSize"),"","")
	RemoveFromGraph/Z/W=$graphStr GroupDisplayY
	AppendToGraph/W=$graphStr GroupDisplayY vs GroupDisplayX
	
	SetDataFolder SavedDataFolder
End //DisplayGroupFunc


Function LithoRotate(degree)
	Variable degree

	Wave/Z GroupBaseY = root:Packages:MFP3D:Litho:groups:GroupBaseY
	if (WaveExists(GroupBaseY) == 0)			//we are not up yet.
		return(0)
	endif
	Wave GroupBaseX = root:Packages:MFP3D:Litho:groups:GroupBaseX
	Wave GroupY = root:Packages:MFP3D:Litho:groups:GroupY
	Wave GroupX = root:Packages:MFP3D:Litho:groups:GroupX
	Make/O/C/N=(DimSize(GroupY,0)) TempComplex
	TempComplex = RotateWave(GroupBaseY,GroupBaseX,degree)
	GroupY = real(TempComplex)
	GroupX = imag(TempComplex)
	LithoScale("Group")
	
End //LithoRotate


Function/C RotateWave(Yval,Xval,degree)
	Variable Yval, Xval, degree
	
	Variable/C result
	
	result = r2polar(cmplx(Yval,Xval))
	result = cmplx(real(result),imag(result)+degree*pi/180)
	return p2rect(result)
	
End //RotateWave


Function SetAngle(newValue)		//this increments the size gain from its old value to a new one
	Variable newValue					//the new value

	if (GV("ScanStatus") == 0)				//if either of these buttons are there then we are not scanning
		return 0							//so we don't actually have to change the size gain
	endif
	
	SetDisable(2)
	String ErrorStr = ""
	
	ErrorStr += num2str(td_SetRamp(5,"ScanEngine.cos",0,cos(newValue*pi/180),"ScanEngine.sin",0,sin(newValue*pi/180),"",0,0,"SetDisable(0)"))+","
	RealScanParmFunc("ScanAngle;","Copy")
	
	ARReportError(ErrorStr)
	
End //SetAngle


Function SetSizeGain(newValue)		//this increments the size gain from its old value to a new one
	Variable newValue					//the new value
	
	
	if (GV("ScanStatus") == 0)				//if either of these buttons are there then we are not scanning
		return 0							//so we don't actually have to change the offset
	endif
	
	UpdateSpotZero()
	SetDisable(2)
	String ErrorStr = ""
	
	if (GV("ScanMode") == 0)
		ErrorStr += num2str(td_SetRamp(5,"ScanEngine.XGain",0,newValue/abs(GV("XLVDTSens"))/(.8*20),"ScanEngine.YGain",0,newValue/abs(GV("YLVDTSens"))/(.8*20),"",0,0,"SetDisable(0)"))+","
	else
		ErrorStr += num2str(td_SetRamp(5,"ScanEngine.XGain",0,newValue/GV("XPiezoSens")/(.8*160),"ScanEngine.YGain",0,newValue/GV("YPiezoSens")/(.8*160),"",0,0,"SetDisable(0)")	)+","
	endif
	RealScanParmFunc("ScanSize;FastScanSize;SlowScanSize;","Copy")
	
	ARReportError(ErrorStr)
	
End //SetSizeGain


Function SetOffset(which,newX,newY)		//this increments the offset from its old value to a new one
	Variable which, newX, newY				//newValue is the new offset in meters
	
	if (GV("ScanStatus") == 0)				//if either of these buttons are there then we are not scanning
		return 0							//so we don't actually have to change the offset
	endif
	
	SetDisable(2)
	String xChanStr = "", yChanStr = ""
	Variable xLVDTSens = 1, yLVDTSens = 1, xPiezoSens = 1, yPiezoSens = 1
	Variable oldX = 0, oldY = 0, i, increment, withdraw
	String ErrorStr = ""
	
	if (GV("ScanMode") == 0)
		if (1 & which)								//which = 1 is Y
			xLVDTSens = GV("XLVDTSens")					//get the sensitivity
			oldX = GV("OldXOffset")/abs(xLVDTSens)	//get the old offset
			xChanStr = "XOffset%ScanEngine"					//set the channel String
			PV("OldXOffset",newX)		//save the new values
		endif
		
		if (2 & which)
			yLVDTSens = GV("YLVDTSens")					//do the same as above for X
			oldY = GV("OldYOffset")/abs(yLVDTSens)
			yChanStr = "YOffset%ScanEngine"
			PV("OldYOffset",newY)		//save the new values
		endif
		withdraw = (abs(newY-oldY*abs(YLVDTSens))*3 > GV("ScanSize")) || (abs(newX-oldX*abs(xLVDTSens))*3 > GV("ScanSize"))
	else
		if (1 & which)								//which = 1 is Y
			xPiezoSens = GV("XPiezoSens")					//get the sensitivity
			oldX = GV("OldXOffset")/xPiezoSens	//get the old offset
			xChanStr = "XOffset%ScanEngine"					//set the channel String
			PV("OldXOffset",newX)		//save the new values
		endif
		
		if (2 & which)
			yPiezoSens = GV("YPiezoSens")					//do the same as above for X
			oldY = GV("OldYOffset")/yPiezoSens
			yChanStr = "YOffset%ScanEngine"
			PV("OldYOffset",newY)		//save the new values
		endif
		withdraw = (abs(newY-oldY*YPiezoSens)*3 > GV("ScanSize")) || (abs(newX-oldX*xPiezoSens)*3 > GV("ScanSize"))
	endif



	if (withdraw)

		ErrorStr += num2str(td_writestring("CTFC.EventEnable","Never"))+","
		ErrorStr += num2str(ir_StopPISLoop(nan,LoopName="HeightLoop"))+","
		CTFCRamp("Height",0,NaN,"output.Dummy",0,320,"","9","10")		//do a CTFCramp, because the td_SetRamp is about to be used.
		ErrorStr += num2str(td_WriteString("Event.9","Once"))+","

	endif

	if (GV("ScanMode") == 0)
		ErrorStr += num2str(td_SetRamp(3,xChanStr,0,newX/(abs(xLVDTSens)*20)+GV("XLVDTOffset")/20,yChanStr,0,newY/(abs(YLVDTSens)*20)+GV("YLVDTOffset")/20,"",0,0,"FinishSetOffset("+num2str(Withdraw)+")"))+","
	else
		ErrorStr += num2str(td_SetRamp(3,xChanStr,0,-newX/(xPiezoSens*160)*GV("XScanDirection"),yChanStr,0,-newY/(YPiezoSens*160)*GV("XScanDirection"),"",0,0,"FinishSetOffset("+num2str(Withdraw)+")"))+","
	endif
	RealScanParmFunc("XOffset;YOffset;","Copy")


	ARReportError(ErrorStr)

End //SetOffset


Function FinishSetOffset(Withdraw)
	Variable Withdraw		

	SetDisable(0)
	String ErrorStr = ""
	if (Withdraw)
		ErrorStr += num2str(td_writestring("CTFC.EventEnable","Never"))+","		//just to be sure.
		//ErrorStr += InitZFeedback0(2,"Always")
		Struct ARImagingModeStruct ImagingModeParms
		ErrorStr += InitZFeedback(ImagingModeParms)
		ErrorStr += num2str(td_WriteString("Event.10","Clear"))+","		//this is set by the CTFC, so clear it.
	endif

	ARReportError(ErrorStr)

End //FinishSetOffset


Function RealScanParmFunc(ParmList,Action)
	String ParmList, Action
	
	if (!Strlen(Action))
		Action = "Copy"
	endif
	
	String DataFolder = GetDF("Variables")
	Wave MVW = $DataFolder+"MasterVariablesWave"
	Wave FVW = $DataFolder+"ForceVariablesWave"
	Wave RVW = $DataFolder+"RealVariablesWave"
	Wave NVW = $DataFolder+"NapVariablesWave"
	Wave CVW = $DataFolder+"ChannelVariablesWave"
	
	Wave/T MVD = $DataFolder+"MasterVariablesDescription"
	Wave/T FVD = $DataFolder+"ForceVariablesDescription"
	Wave/T RVD = $DataFolder+"RealVariablesDescription"
	Wave/T NVD = $DataFolder+"NapVariablesDescription"
	Wave/T CVD = $DataFolder+"ChannelVariablesDescription"
	String ParmName
	
	Variable output = NaN
	if (StringMatch(Action,"DiffBit") == 1)
		if (!Strlen(ParmList))
			ParmList = "ALL"
		endif
		output = 0
	endif
	
	String DimLabels = "ScanSize;FastScanSize;SlowScanSize;ScanRate;XOffset;YOffset;ScanPoints;ScanLines;ScanAngle;ImagingMode;InvOLS;SpringConstant;AmpInvOLS;FastRatio;SlowRatio;TopLine;BottomLine;ScanMode;NapMode;"
	DimLabels += "FMapScanTime;FMapScanPoints;FMapScanLines;FMapXYVelocity;Channel1DataType;DataTypeSum;PhaseOffset;PhaseOffset1;NapPhaseOffset;"
	
	if (StringMatch(ParmList,"ALL") == 1)
		ParmList = DimLabels
	endif
	
	
	if (DimSize(RVW,0) != ItemsInList(DimLabels,";"))
		Redimension/N=(ItemsInList(DimLabels,";"),-1) RVW
		SetDimLabels(RVW,DimLabels,0)
	endif
	
	
	Variable A, nop = ItemsInList(ParmList,";")


	for (A = 0;A < nop;A += 1)
		ParmName = StringFromList(A,ParmList,";")
		if (FindDimLabel(MVW,0,ParmName) >= 0)
			Wave Master = $GetWavesDataFolder(MVW,2)
			Wave/T MasterT = $GetWavesDataFolder(MVD,2)
		elseif (FindDimLabel(NVW,0,ParmName) >= 0)
			Wave Master = $GetWavesDataFolder(NVW,2)
			Wave/T MasterT = $GetWavesDataFolder(NVD,2)
		elseif (FindDimLabel(FVW,0,ParmName) >= 0)
			Wave Master = $GetWavesDataFolder(FVW,2)
			Wave/T MasterT = $GetWavesDataFolder(FVD,2)
		elseif (FindDimLabel(CVW,0,ParmName) >= 0)
			Wave Master = $GetWavesDataFolder(CVW,2)
			Wave/T MasterT = $GetWavesDataFolder(CVD,2)
		else
			continue
		endif
			
		
	
		strswitch (Action)
			case "Copy":
				RVW[%$ParmName][] = Master[%$ParmName][Q]
				RVD[%$ParmName][] = MasterT[%$ParmName][Q]
				break
				
			case "Value":
			case "units":
			case "low":
			case "high":
			case "minUnits":
			case "stepSize":
				return(RVW[%$ParmName][%$Action])
				break
				
			case "ReverseCopy":
				Master[%$ParmName][] = RVW[%$ParmName][Q]
				MasterT[%$ParmName][] = RVD[%$ParmName][Q]
				break
				
			case "DiffBit":
				if (RVW[%$ParmName][0] != Master[%$ParmName][0])
					output += 2^A
				endif
				break
				
				
		endswitch
	endfor	
	
	return(output)
End //RealScanParmFunc


Function MakeLithoVoltageGraph()		//graph for making Wave for voltage or setpoint during litho

	String GraphStr = "LithoVoltageGraph"
	DoWindow/F $GraphStr
	if (V_Flag)
		return(0)
	endif
	
	String LithoType = ""
	Variable UseBias = GV("LithoUseBias")
	if (UseBias)
		LithoType = "Voltage"
	else
		LithoType = "SetPoint"
	endif
	Variable Enab = 0
	
	
	Wave LVW = root:Packages:MFP3D:Main:Variables:LithoVariablesWave
	
	
	Variable screenRes = 72/ScreenResolution
	Display/K=1/N=$GraphStr/W=(10*screenRes,45*screenRes,850*screenRes,600*screenRes) root:Packages:MFP3D:Litho:LithoVolts as "Litho "+LithoType
	
	
	Variable CurrentTop = 40
	ARControlBar(GraphStr)
	
	
	String ParmName = "LithoStartVolts"
	MakeSetVar(GraphStr,"",ParmName,"Start Voltage","LithoVoltageSetVarFunc","",10,CurrentTop,NaN,100,6,NaN,Enab)
	newUpdateFormat(ParmName)
	NewUpdateClickVar(ParmName,GV(ParmName))
	

	ParmName = "LithoEndVolts"
	MakeSetVar(GraphStr,"",ParmName,"End Voltage","LithoVoltageSetVarFunc","",260,CurrentTop,NaN,100,2,NaN,Enab)
	newUpdateFormat(ParmName)
	NewUpdateClickVar(ParmName,GV(ParmName))

	ParmName = "LithoSegment"
	MakeSetVar(GraphStr,"",ParmName,"Segment number","LithoVoltageSetVarFunc","",500,CurrentTop,NaN,60,7,NaN,Enab)
	newUpdateFormat(ParmName)

	CurrentTop += 30
	

	ParmName = "LithoVoltsMode"
	MakePopup(GraphStr,"LithoVoltsModePopup_7","Mode",10,CurrentTop,"LithoVoltagePopupFunc","root:Packages:MFP3D:Litho:LithoVoltageMode",GV("LithoVoltsMode")+1,0)

	
	MakeCheckbox(GraphStr,"FullSlopeBox_2","Full Slope",170,CurrentTop,"LithoVoltsBoxFunc",0,0,0)
	
	ParmName = "LithoStep"
	MakeSetVar(GraphStr,"",ParmName,"Voltage Step","LithoVoltageSetVarFunc","",330,CurrentTop,NaN,100,4,NaN,Enab)
	newUpdateFormat(ParmName)
	NewUpdateClickVar(ParmName,GV(ParmName))

	
	ScaleControlBar(GraphStr,15)

End //MakeLithoVoltageGraph


Function LithoVoltageSetVarFunc(ctrlName,varNum,varStr,varName)	//handles the setvars on the litho voltage graph
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String GraphStr = "LithoVoltageGraph"
	
	String ParmName = ARConvertVarName2ParmName(VarName)

	UnitsCalcFunc(ctrlName,varNum,varStr,varName)
	
	Variable TotalSegments = CountLithoSections()
	Variable RemIndex = FindLast(CtrlName,"_")
	if (RemIndex > -1)
		CtrlName = CtrlName[0,RemIndex-1]
	endif
	RemIndex = FindLast(CtrlName,"SetVar")
	if (RemIndex > -1)
		CtrlName = CtrlName[0,RemIndex-1]
	endif
	
	
	
	Variable MaxStep = (10-GV("LithoStartVolts"))/(TotalSegments-1)
	Variable MinStep = -(10+GV("LithoStartVolts"))/(TotalSegments-1)
	Variable StepVoltage = GV("LithoStep")
	
	if ((StringMatch(CtrlName,"LithoStep") == 1) || (StringMatch(CtrlName,"LithoStartVolts") == 1))
		PVH("LithoStep",MaxStep)
		PVL("LithoStep",MinStep)
		StepVoltage = Limit(StepVoltage,MinStep,MaxStep)
		PV("LithoStep",StepVoltage)
		if (StringMatch(CtrlName,"LithoStep") == 1)
			varNum = StepVoltage
		endif
	endif
	
	
	UpdateUnits(ParmName,varNum)
	VarNum = SafeLimit(VarNum,GVL(ParmName),GVH(ParmName))
	PV(ParmName,VarNum)
	
	if (StringMatch(CtrlName,"*Segment*") == 0)
		NewUpdateClickVar(ParmName,varNum)
	endif
	
	newUpdateFormat(ParmName)
	
	
	
	
	strswitch (ctrlName)

		case "LithoSegment":			//this zooms in on individual segments
			if (varNum)							//not 0 means we are looking for a particular segment
				Wave LithoVolts = root:Packages:MFP3D:Litho:LithoVolts		//this is the voltage Wave
				Variable i, stop, start = 0, segment = 0
				stop = DimSize(LithoVolts,0)
				
				for (i = 0;i < stop;i += 1)				//go through the Wave
					if (numType(LithoVolts[i]) == 2)		//look for NaNs
						if (i >= start+1)					//check if there are 2 NaNs in a row, a common occurence
							segment += 1						//we have reached the end of a segment
							if (segment == varNum)			//this is the segment we are looking for
								break
							endif
							start = i+1						//this could be the actual start of the next segment
						else									//the last point was also a NaN
							start = i+1						//so keep looking
						endif
					elseif (i == stop-1)					//if we have reached the end, then that is the end of this segment
						segment += 1							//increment the segment count
						if (segment == varNum)				//is this the one we are looking for?
							break
						else
							DoAlert 0, "There are not that many segments."		//if not then we have run out of segments
							return 1							//there is nothing to do
						endif
					endif
						
				endfor
				SetAxis bottom pnt2x(LithoVolts,start), pnt2x(LithoVolts,i)		//zoom to the start and end of the segment		
				
			else												//0 means look at the whole Wave
				SetAxis/W=$GraphStr/A bottom		//go to autoscale
			endif
			break

		default:
			MakeLithoVoltage()					//the rest just use this to make a new voltage Wave

	endswitch
	
End //LithoVoltageSetVarFunc


Function LithoVoltsBoxFunc(ctrlName,checked)		//litho voltage graph check boxes
	String ctrlName		//not used
	Variable checked		//Used

	UpdateAllCheckBoxes(CtrlName,checked)
	PV("LithoFullSlope",checked)		//changes the full slope status
	if (GV("LithoVoltsMode") != 1)
		return(0)
	endif
	
	MakeLithoVoltage()					//this remakes the Wave
	return(0)
	
End //LithoVoltsBoxFunc


Function LithoVoltagePopupFunc(ctrlName,popNum,popStr)		//popups on the litho voltage graph
	String ctrlName		//not used
	Variable popNum		//used
	String popStr		//not used

	UpdateAllPopups(CtrlName,PopNum)
	PV("LithoVoltsMode",popNum-1)		//changes between the various modes
	MakeLithoVoltage()					//this remakes the Wave
	return(0)
End //LithoVoltagePopupFunc


Function MakeLithoVoltage()			//this makes the litho voltage Wave

	Wave LithoVolts = root:Packages:MFP3D:Litho:LithoVolts		//this is the Wave that is made
	Wave YLitho = root:Packages:MFP3D:Litho:YLitho					//the voltage Wave has to have NaNs in the same places as this Wave
	Variable fullSlope = GV("LithoFullSlope")
	Variable startVolts = GV("LithoStartVolts")
	Variable endVolts = GV("LithoEndVolts")
	Variable stop = DimSize(YLitho,0)					//get the size of YLitho
	Variable i, segment = 0, start = 0
	Redimension/N=(stop) LithoVolts					//make LithoVolts the same size as YLitho
		
	switch (GV("LithoVoltsMode"))

		case 0:							//this just sets the Wave to the current setpoint
			Variable lithoSetpoint = GV("LithoSetpointVolts")
			FastOp LithoVolts = (lithoSetpoint)*YLitho/YLitho		//the YLitho/YLitho passes on the NaNs
			break

		case 1:								//slope from startVolts to endVolts
			if (fullSlope)					//one slope for the whole Wave
				LithoVolts = startVolts+(endVolts-startVolts)*p/(stop-1)*YLitho/YLitho		//the YLitho/YLitho passes on the NaNs
			else								//one slope for each segment
				for (i = 0;i < stop;i += 1)
					if (numType(YLitho[i]) == 2)			//look for NaNs
						if (i >= start+1)					//make sure the NaNs aren't adjacent
							LithoVolts[start,i-1] = startVolts+(endVolts-startVolts)*(p-start)/(i-1-start)	//slap a slope on the segment
							LithoVolts[i] = NaN				//make the current point NaN to match YLitho
							start = i+1						//the start is at least 1 bigger
						else
							LithoVolts[i] = NaN				//make the current point NaN to match YLitho
							start = i+1						//the start is at least 1 bigger
						endif
					elseif (i == stop-1)					//we are doing the last segment
						LithoVolts[start,i] = startVolts+(endVolts-startVolts)*(p-start)/(i-start)	//slap a slope on the segment
					endif
				endfor
			endif
			break
						
		case 2:								//each segment is incremented higher
			Variable stepVolts = GV("LithoStep")		//grab the step increment
			for (i = 0;i < stop;i += 1)
				if (numType(YLitho[i]) == 2)			//look for NaNs
					if (i >= start+1)					//make sure the NaNs aren't adjacent
						LithoVolts[start,i-1] = startVolts+segment*stepVolts		//set the voltage
						segment += 1						//increment the segment
						LithoVolts[i] = NaN				//make the current point NaN to match YLitho
						start = i+1						//the start is at least 1 bigger
					else
						LithoVolts[i] = NaN				//make the current point NaN to match YLitho
						start = i+1						//the start is at least 1 bigger
					endif
				elseif (i == stop-1)					//we are doing the last segment
					LithoVolts[start,i] = startVolts+segment*stepVolts		//set the voltage
				endif
			endfor
		
			break
	endswitch

End //MakeLithoVoltage


Function GhostLithoPanel()

//revamp 050909
//Revamp 060115
//anded multi state button support 060314

	Variable TabNum = ARPanelTabNumLookup("Litho")
	String TabStr = "_"+num2str(TabNum)
	
	
	Variable Mode, UseWave
	
	Struct ARTipHolderParms TipParms
	String ControlList, OtherControlList
	String ActiveControl = "", DeActiveControl = ""
	
	
	
	ARGetTipParms(TipParms)

	
	ControlList = "LithoUseBiasBox"+TabStr+";"
	if (TipParms.IsIDrive || TipParms.IsThermal || TipParms.IsOrca)
		DeActiveControl += ControlList
		PV("LithoUseBias",0)
		UpdateAllCheckBoxes(ControlList,0)
		Mode = 0
	else
		ActiveControl += ControlList
		Mode = GV("LithoUseBias")
	endif
	
	UseWave = GV("LithoUseWave")		//do we have a setpoint wave?
	
	ControlList = "LithoBiasSetVar;"
	OtherControlList = "LithoSetpointVoltsSetVar;"
	ControlList = ListMultiply(ControlList,TabStr,";")
	OtherControlList = ListMultiply(OtherControlList,TabStr,";")
	
	
	
	if ((Mode) && (!UseWave))		//bias, but no setpoint wave
		ActiveControl += ControlList
		ActiveControl += OtherControlList
	elseif ((!Mode) && (UseWave))		//no bias, using a setpoint wave
		DeActiveControl += ControlList
		DeActiveControl += OtherControlList
	elseif ((!Mode) && (!UseWave))		//no bias, no setpoint wave
		DeActiveControl += ControlList
		ActiveControl += OtherControlList
	else		//bias yes, setpoint yes
		DeActiveControl = ControlList
		ActiveControl += OtherControlList
	endif
	
	
	
	
	ControlList = "DoLithoSnapButton;DoLithoSnapGraphButton;"
	ControlList = ListMultiply(ControlList,TabStr,";")	
	OtherControlList = "DoLithoPreSnapButton;"
	OtherControlList = ListMultiply(OtherControlList,TabStr,";")	


	Variable WantSnap = GV("LithoSnap")
	Variable DidPreCheck = GV("LithoSnapPreCheck")
	if (!WantSnap)
		DeActiveControl += ControlList
		DeActiveControl += OtherControlList
	elseif (!DidPreCheck)
		DeActiveControl += ControlList
		ActiveControl += OtherControlList
	else
		ActiveControl += ControlList
		ActiveControl += OtherControlList
	endif
	

	
	MasterARGhostFunc(DeactiveControl,ActiveControl)
	
	
	Variable LithoAction = GV("LithoRunning")
	TabStr += ";"
	
	String ShowList = "", HideList = "", TitleList = "", NewFuncList = ""
	
//	Variable TabNum = ARPanelTabNumLookup("LithoPanel")
//	String TabStr = "_"+num2str(TabNum)+";"
	Variable TabNum2 = ARPanelTabNumLookup("LithoStep")
	String TabStr2 = "_"+num2str(TabNum2)+";"
	
	switch (LithoAction)
		case 0:		//nothing
			HideList += "StopLitho"+TabStr
			ShowList += "DoLitho"+TabStr
			HideList += "StopDraw"+TabStr
			ShowList += "DrawWave"+TabStr
			TitleList = "Do it!;Draw Path;"
			NewFuncList = "DoLithoFunc;DrawLithoFunc;"
			//Step stuff
			HideList += "StopStepLitho"+TabStr2
			ShowList += "DoStepLitho"+TabStr2
			TitleList += "Do it;"
			NewFuncList += "LithoStepFunc;"
			
			break
			
		case 1:		//standard Litho
			ShowList += "StopLitho"+TabStr
			HideList += "DoLitho"+TabStr
			ShowList += "DrawWave"+TabStr
			HideList += "StopDraw"+TabStr
			TitleList = "Stop Litho;0;"
			NewFuncList = "DoLithoFunc;;"
			
			break
			
		case 2:		//drawing
			HideList += "StopLitho"+TabStr
			ShowList += "DoLitho"+TabStr
			ShowList += "StopDraw"+TabStr
			HideList += "DrawWave"+TabStr
			TitleList = "Do It!;Stop Draw;"
			NewFuncList = "DoLithoFunc;DrawLithoFunc;"
			
			break
			
		case 3:		//Step Litho
			ShowList += "StopStepLitho"+TabStr2
			HideList += "DoStepLitho"+TabStr2
			TitleList += "Stop;"
			NewFuncList = "LithoStepFunc;"
			
			break
			
	Endswitch
	
	
	
	ButtonSwapper(ShowList,HideList,TitleList,NewFuncList=NewFuncList)

	
//	GhostLithoPanel2()
//	DisableControl("*",ActiveControl,0)
//	DisableControl("*",DeActiveControl,2)


End //GhostLithoPanel


Function GhostLithoStepPanel()

	//first added 070721
	
	Variable TabNum = ARPanelTabNumLookup("LithoStep")
	String TabStr = "_"+num2str(TabNum)
	
	Variable Mode, UseWave
	
	Struct ARTipHolderParms TipParms
	String ControlList, OtherControlList
	String ActiveControl = "", DeActiveControl = ""
	
	
	
	ARGetTipParms(TipParms)

	ControlList = "LithoStepUseBiasCheck"+TabStr+";"
	if (TipParms.IsIDrive || TipParms.IsThermal || TipParms.IsOrca)
		DeActiveControl += ControlList
		PV("LithoStepUseBias",0)
		UpdateAllCheckBoxes(ControlList,0)
		Mode = 0
	else
		ActiveControl += ControlList
		Mode = GV("LithoStepUseBias")
	endif
	
	

	UseWave = GV("LithoStepUseWave")		//do we have a setpoint wave?
	
	ControlList = "LithoStartVoltsSetVar;"
	OtherControlList = "LithoEndVoltsSetVar;"
	ControlList = ListMultiply(ControlList,TabStr,";")
	OtherControlList = ListMultiply(OtherControlList,TabStr,";")
	
	
	if ((Mode) && (!UseWave))		//bias, but no setpoint wave
		ActiveControl += ControlList
		DeActiveControl += OtherControlList
	elseif ((!Mode) && (UseWave))		//no bias, using a setpoint wave
		ActiveControl += ControlList
		ActiveControl += OtherControlList
	elseif ((!Mode) && (!UseWave))		//no bias, no setpoint wave
		DeActiveControl += ControlList
		DeActiveControl += OtherControlList
	else		//bias yes, setpoint yes
		ActiveControl = ControlList
		ActiveControl += OtherControlList
	endif
	
	


	MasterARGhostFunc(DeactiveControl,ActiveControl)
	


End //GhostLithoStepPanel



Function FixTheLithoGroupNumber(NewLithoNumber)
	Variable NewLithoNumber
	
	
	String PBRS = ""
//	Variable StopDraw = ItemsInList(FindControls2("StopDraw_*",-1,PBRS),";")
	Variable StopDraw = GV("LithoRunning") == 2
	
	if (StopDraw)
		NewLithoNumber += 1
	endif	
	PV("LithoNumber",NewLithoNumber)
End //FixTheLithoGroupNumber


Function CountLithoSections()
	
	String DataFolder = GetDF("Litho")
	Wave/Z IndexNan = $DataFolder+"IndexNan"
	if (WaveExists(IndexNan) == 0)
		Make/N=0 $DataFolder+"IndexNan"
		Wave IndexNan = $DataFolder+"IndexNan"
	endif
	
	
	Wave/Z IndexDiff = $DataFolder+"IndexDiff"
	if (WaveExists(IndexDiff) == 0)
		Make/N=0 $DataFolder+"IndexDiff"
		Wave IndexDiff = $DataFolder+"IndexDiff"
	endif
		
	Wave/Z IndexNaNDiff = $DataFolder+"IndexNaNDiff"
	if (WaveExists(IndexNaNDiff) == 0)
		Make/N=0 $DataFolder+"IndexNaNDiff"
		Wave IndexNaNDiff = $DataFolder+"IndexNaNDiff"
	endif	
	
	String NewTitle = "Kill Section"
	
	Wave Data = $DataFolder+"YLitho"
	FindFast(Data,"==",NaN,IndexNan)
	
	Diff(IndexNan,IndexDiff)
	
	FindFast(IndexDiff,"==",-1,IndexNaNDiff)
	Variable NumberOfSections = 0
	Variable NumberOfGroups = DimSize(IndexNaNDiff,0)
	if (DimSize(Data,0) == 0)
		NumberOfGroups = 0
	elseif (IsNan(Data[DimSize(Data,0)-1]))			//last one is a group.
		NumberOfGroups += 1
		NewTitle = "Kill Group"
		NumberOfSections = DimSize(IndexNan,0) - NumberOfGroups+1
	elseif (NumberOfGroups == 0)
		NumberOfGroups = DimSize(IndexNan,0)+1
		NumberOfSections = NumberOfGroups
	else		//Figure out how many sections after the last group.
		Variable LastGroup = IndexNan[IndexNanDiff[NumberOfGroups-1]]
		FindFast(IndexNan,">",LastGroup,IndexDiff)
		NumberOfSections = DimSize(IndexNan,0) - NumberOfGroups+1
		NumberOfGroups += DimSize(IndexDiff,0)
	endif
	
	UpdateAllControls("EraseLast_0",NewTitle,"","")
	
	FixTheLithoGroupNumber(NumberOfGroups)
	return(NumberOfSections)
End //CountLithoSections

//
//Function RemoveAllLithoGroups()
//	
//	String DataFolder = GetDF("Litho")
//	Wave YWave = $DataFolder+"YLitho"
//	Wave XWave = $DataFolder+"XLitho"
//
//
//
//	Wave IndexNan = $InitOrDefaultWave(DataFolder+"IndexNan",0)
//	Wave IndexNanDiff = $InitOrDefaultWave(DataFolder+"IndexNanDiff",0)
//	Wave IndexDiff = $InitOrDefaultWave(DataFolder+"IndexDiff",0)
//	Redimension/N=(0) IndexNaN, IndexDiff, IndexNanDiff
//		
//	
//	FindFast(Data,"==",NaN,IndexNan)
//	
//	Diff(IndexNan,IndexDiff)
//	
//	FindFast(IndexDiff,"==",-1,IndexNaNDiff)
//
//	Variable cnt = 0
//	Variable A, nop = DimSize(IndexNaNDiff,0)
//	
//	
//	for (A = 0;A < nop;A += 1)
//		DeletePoints IndexNaNDiff[A]-cnt,1,XWave,YWave
//		cnt += 1
//	endfor
//	
//End //RemoveAllLithoGroups


Function LithoCleanUp()
	
	Variable UseBias = GV("LithoUseBias") || GV("LithoStepUseBias")
	Struct ARImagingModeStruct ImagingModeParms
	ARGetImagingMode(ImagingModeParms)


	String ErrorStr = ""
	
	UpdateAllControls("DrawWave_0","Draw Path","","DrawLithoFunc")	//reset the button
//	UpdateAllControls("StopLitho_0","Draw Path","DrawWave_0","")		//change the button back to draw
//	UpdateAllControls("StopLitho_2","Do it!","DoStepLitho_2","LithoStepFunc")
	//KillBackground
	ARBackground("LithoBackground",0,"")
	StartMeter("")
	ControlInfo/W=MeterPanel MeterSetup
	if (V_Flag)
		Button MeterSetup,Win=MeterPanel,Disable=0
	endif
	RemoveRedLithoPoint()
	if (GV("ShowXYSpot"))
		ShowXYSpotFunc("ShowXYSpotCheck_2",1)
	endif
	String WeDriveThis = ""
	Struct ARTipHolderParms TipParms
	ARGetTipParms(TipParms)
	if (TipParms.IsOrca)
		WeDriveThis = "SurfaceBias"		//can't believe this would work.
	elseif (TipParms.IsDiffDrive)
		WeDriveThis = "TipHeaterDrive"
	else
		WeDriveThis = "TipBias"
	endif
	
	if (UseBias)
		ErrorStr += num2str(ir_WriteValue(WeDriveThis,0))+","
	endif
	if (GV("LithoPreSnap"))
		PV("LithoSnapPreCheck",0)
		PV("LithoPreSnap",0)
		//Revert the setpoint.....
		
		MainSetVarFunc("SetPointSetVar_0",GV("LithoSetpointVolts"),"",":Variables:MasterVariablesWave[%"+ImagingModeParms.SetpointParm+"]")
	endif
	PV("LithoRunning",0)
	GhostLithoPanel()
	
	ARReportError(ErrorStr)

End //LithoCleanUp


Function PutLithoOnEveryOne(DoCheck)
	Variable DoCheck

	String DataFolder = GetDF("Litho")
	Wave YLitho = $DataFolder+"YLitho"
	Wave XLitho = $DataFolder+"XLitho"
	
	if (DoCheck)
		if (DimSize(YLitho,0) == 0)		//well why bother?
			return(0)
		endif
	endif
	
	Variable LithoUseArrows = GV("LithoUseArrows")
	if (LithoUseArrows)
		Wave/Z LithoArrowWave = $DataFolder+"LithoArrowWave"
		if (WaveExists(LithoArrowWave) == 0)
			LithoUseArrows = 0
			PV("LithoUseArrows",LithoUseArrows)
		endif
	endif
	
	
	String GraphStr, GraphList = WinList("Channel*Image*",";","WIN:1")
	Variable A, nop = ItemsInList(GraphList,";")
	
	String TraceList
	
	for (A = 0;A < nop;A += 1)
		GraphStr = StringFromList(A,GraphList,";")
		TraceList = TraceNameList(GraphStr,";",1)
		if (WhichListItem("YLitho", TraceList,";",0,0) < 0)
			AppendToGraph/W=$GraphStr/C=(0,0,65535) YLitho vs XLitho
			ModifyGraph/W=$GraphStr/Z lsize(YLitho)=2
		endif
		if (LithoUseArrows == 0)		//we don't use arrows
			ModifyGraph/W=$GraphStr mode(YLitho) = 0
		else
			ModifyGraph/W=$GraphStr Mode(Ylitho) = 4,opaque(YLitho)=1,arrowMarker(YLitho)={LithoArrowWave,2,7,1.5,2}
			if (GV("LithoDrawMode"))
				ModifyGraph/W=$GraphStr mskip(Ylitho)=0
			else
				ModifyGraph/W=$GraphStr mskip(Ylitho)=5
			endif
		endif
	endfor
End //PutLithoOnEveryOne


Function SetLithoHooks(NewHook)
	String NewHook
	
	String GraphStr, GraphList = WinList("Channel*Image*",";","WIN:1")
	Variable A, nop = ItemsInList(GraphList,";")
	
	Variable Events = 3
	
	if (StringMatch(NewHook,"RealGraphHook") == 1)
		Events = 1
	endif
	for (A = 0;A < nop;A += 1)
		GraphStr = StringFromList(A,GraphList,";")
		SetWindow $GraphStr,hook=$NewHook,HookEvents=Events
	endfor

End //SetLithoHooks


Function AllLithoDrawModes(Checked)
	Variable checked		//1 for DrawMode (freeHand), 0 for Not Draw Mode
	//2 for lines.
	
	String DataFolder = GetDF("Litho")
	Wave YDraw = $DataFolder+"YDraw"
	Wave XDraw = $DataFolder+"XDraw"

	String GraphStr, GraphList = WinList("Channel*Image*",";","WIN:1")
	Variable A, nop = ItemsInList(GraphList,";")
	for (A = 0;A < nop;A += 1)
		GraphStr = StringFromList(A,GraphList,";")
		if (Checked == 1)		//freehand
			GraphWaveDraw/O/F=3/W=$graphStr YDraw, XDraw				//set it up for drawing
		elseif (Checked == 2)
			GraphWaveDraw/O/W=$graphStr YDraw, XDraw				//set it up for drawing
		else
			GraphNormal/W=$graphStr		
		endif
	endfor
	
End //AllLithoDrawModes


Function CalcLithoArrows()
	
	String DataFolder = GetDF("Litho")


	Wave LithoAngles = $InitOrDefaultWave(DataFolder+"LithoAngles",0)
	Wave LithoArrowWave = $InitOrDefaultWave(DataFolder+"LithoArrowWave",0)
	Wave YLitho = $DataFolder+"YLitho"
	Wave XLitho = $DataFolder+"XLitho"
	
	Redimension/N=(DimSize(YLitho,0),2) LithoArrowWave
	GetXYAngle(Xlitho,YLitho,LithoAngles)
	
	
	//We have to patch LithoAngles, from the NaNs
	
	Variable A, nop = DimSize(YLitho,0)
	for (A = 0;A < nop;A += 1)
		if (IsNan(YLitho[A]))
			continue
		endif
		if (!IsNaN(LithoAngles[A]))
			continue
		endif
		LithoAngles[A] = LithoAngles[A-1]
	endfor
	

	LithoArrowWave[][1] = -LithoAngles[p]+pi*3/2
	LithoArrowWave[][0] = 7
	
End //CalcLithoArrows


Function ToggleLithoArrows(CtrlName,Checked)
	String CtrlName
	Variable Checked
	
	UpdateAllCheckBoxes(CtrlName,checked)
	PV("LithoUseArrows",Checked)
	if (checked)
		CalcLithoArrows()
	endif
	PutLithoOnEveryOne(1)
	
End //ToggleLithoArrows


Function CalcLithoTime()

	//our job is to calculate the time it will take to do the lithograph in seconds....

	String SavedDataFolder = GetDataFolder(1)
	setDataFolder(GetDF("Litho"))

	Wave YLitho = YLitho
	Wave XLitho = XLitho
	Wave XDiff = $LocalWave(0)
	Wave YDiff = $LocalWave(0)
	Wave Distance = $LocalWave(0)
	Wave XSub = $LocalWave(0)
	Wave YSub = $LocalWave(0)


	Wave Index = $Find(XLitho,"==",NaN)
	Variable output = 0		//lets say it takes 1.5 seconds to get from the button click to the first position.
	Variable MaxVal = 0
	Variable MaxVelocity = GV("LithoMax")
	InsertPoints/M=0 0,1,Index
	InsertPoints/M=0 DimSize(Index,0),1,Index
	Index[DimSize(Index,0)-1] = DimSize(XLitho,0)

	Variable A, nop = DimSize(Index,0)
	for (A = 1;A < nop;A += 1)
		Redimension/N=(Index[A]-Index[A-1]) Xsub,YSub
		Redimension/N=(Index[A]-Index[A-1]-1) Distance
		XSub[] = XLitho[Index[A-1]+p]
		YSub[] = YLitho[Index[A-1]+p]
		if (DimSize(XSub,0) < 2)
			continue
		endif
//		Diff(XSub,XDiff)
//		Diff(YSub,YDiff)
		Differentiate/Meth=1 XSub/D=XDIFF
		Differentiate/Meth=1 YSub/D=YDIFF
		Distance = sqrt(Xdiff^2+Ydiff^2)
		WaveStats/Q/M=1 Distance
		MaxVal = v_max
		output += DimSize(Xsub,0)*MaxVal/MaxVelocity+1.5
		//and then lets say that it takes 1.5 seconds between sections.

	endfor
	if (output)
		output += 1.5
	endif

	KillWaves XDiff, YDiff, Distance, XSub, YSub, Index		//clean up.

	SetDataFolder(SavedDataFolder)
	return(output)
End //CalcLithoTime()


Function LithoTimeFunc(CtrlName,VarNum,VarStr,VarName)
	String CtrlName
	Variable VarNum
	String VarStr
	String VarName


	//OK, what was the last value...
	Variable LastVal = CalcLithoTime()/60

	Variable MaxVelocity = GV("LithoMax")

	PVU("LithoMax",1)
	LithoSetVarFunc("LithoMaxSetVar_0",MaxVelocity*Lastval/VarNum,num2str(MaxVelocity*Lastval/VarNum),":LithoVariablesWave[%LithoMax]")


End //LithoTimeFunc


Function UpdateLithoTime(NewTime)
	Variable NewTime

	NewTime /= 60		//Minutes

	//UnitsCalcFunc("LithoTimeSetVar",NewTime,num2str(NewTime),"LithoTime")

	NewUpdateClickVar("LithoTime",NewTime)

	PV("LithoTime",NewTime)
	return(NewTime)

End //UpdateLithoTime


Function PutOnXYSpot(NumLimit)
	Variable NumLimit

	String GraphList = WinList("Channel*Image*",";","WIN:1")
	Variable A, nop = ItemsInList(GraphList,";")

	String GraphStr
	String DataFolder = GetDF("Litho")

	Wave YPoint = $InitOrDefaultWave(DataFolder+"YPoint",1)
	Wave XPoint = $InitOrDefaultWave(DataFolder+"XPoint",1)
	Redimension/N=1 XPoint, YPoint
	
	
	//GraphList = StringFromList(0,GraphList,";")		//Hack it down to 1 plot.
	
	
	String TraceList
	Variable B, nopB
	for (A = 0;A < nop;A += 1)
		GraphStr = StringFromList(A,GraphList,";")
		
		TraceList = ARTraceNameList(GraphStr,"YPoint*","*","*",DataFolder)
		if (A >= NumLimit)		//remove it
			nopB = ItemsInList(TraceList,";")
			TraceList = FlipLRStrList(TraceList,";")
			for (B = 0;B < nopB;B += 1)
				RemoveFromGraph/W=$GraphStr $StringFromList(B,TraceList,";")
			endfor
		else			//add it
			if (ItemsInList(TraceList,";") == 0)
				AppendToGraph/W=$GraphStr YPoint vs XPoint
				ModifyGraph/W=$GraphStr mode(YPoint)=3,marker(YPoint)=19,msize(YPoint)=3
				MoveTrace2Top(GraphStr,"YPoint")
				UpdateAllRTMarkers(GraphStr)
			endif
		endif
	endfor
	
End //PutOnXYSpot


Function RemoveRedLithoPoint()

	//It is our job to make sure the Red Litho spot of off of all the images.
	
	String GraphList = WinList("Channel*Image*",";","WIN:1")
	Variable A, nop = ItemsInList(GraphList,";")
	String DataFolder = GetDF("Litho")
	String GraphStr, TraceName, TraceList
	Variable B, nopB

	for (A = 0;A < nop;A += 1)
		GraphStr = StringFromList(A,GraphList,";")
		TraceList = ARTraceNameList(GraphStr,"*YPoint*","*","*",DataFolder)

		TraceList = FlipLRStrList(TraceList,";")
		nopB = ItemsInList(TraceList,";")

		for (B = 0;B < nopB;B += 1)
			TraceName = StringFromList(B,TraceList,";")
			RemoveFromGraph/W=$GraphStr/Z $TraceName
		endfor

	endfor

End //RemoveRedLithoPoint()


Function ShowXYSpotFunc(CtrlName,Checked)
	String CtrlName		//used
	Variable Checked		//used

	UpdateAllCheckBoxes(CtrlName,checked)
	PostARMacro(CtrlName,Checked,"","")

	PV("ShowXYSpot",Checked)

	if (Checked)
		if (GV("FMapStatus"))
			PutOnXYSpot(1)
			return(0)
		endif
		PutOnXYSpot(10)
		ARBackground("RedSpotBackground",4,"")
	else
		RemoveRedLithoPoint()
		ARBackground("RedSpotBackground",0,"")
	endif


End //ShowXYSpotFunc


Function RedSpotBackground()

	Wave MVW = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	Wave FVW = root:Packages:MFP3D:Main:Variables:ForceVariablesWave
	Wave GVW = root:Packages:MFP3D:Main:Variables:GeneralVariablesWave
	Wave OMVW = root:Packages:MFP3D:Main:Variables:OldMVW
	Wave RVW = root:Packages:MFP3D:Main:Variables:RealVariablesWave
	
	Variable ScanStatus = MVW[%ScanStatus][0]
	Variable LowNoise = MVW[%LowNoise][0]
	Variable Thresh = GVW[%RedSpotThreshold][0]
	Variable Counter = GVW[%RedSpotCounter][0]
	Variable tempY, tempX, OldX, OldY


	if (Counter > 20)
		GVW[%RedSpotCounter][0] = inf
		Thresh = 2e-9
	else
		GVW[%RedSpotCounter][0] = Counter+1
	endif



	//OK, now for the Force Spot Hack...
	if (FVW[%ShowXYSpot][0] == 1)
		if (!ScanStatus)
			Wave/Z YPoint = root:Packages:MFP3D:Litho:YPoint
			Wave/Z XPoint = root:Packages:MFP3D:Litho:XPoint
			if ((WaveExists(YPoint) == 1) && (WaveExists(XPoint) == 1))
				OldX = XPoint[0]
				OldY = YPoint[0]
				tempY = (td_ReadValue("YSensor")-OMVW[%YLVDTOffset][0])*abs(OMVW[%YLVDTSens][0])-RVW[%YOffset][0]//+LVW[%LithoScanSize]/2
				tempX = (td_ReadValue("XSensor")-OMVW[%XLVDTOffset][0])*abs(OMVW[%XLVDTSens][0])-RVW[%XOffset][0]//+LVW[%LithoScanSize]/2

				Variable/C tempBoth = RotateWave(tempY,tempX,-RVW[%ScanAngle][0])

				TempY = real(tempBoth)+RVW[%SlowScanSize][0]/2
				TempX = imag(tempBoth)+RVW[%FastScanSize][0]/2
				if ((Abs(TempX-OldX) > Thresh) || (Abs(TempY-OldY) > thresh))
					XPoint[0] = TempX
					YPOint[0] = TempY
				endif
			endif
		endif
	else
		return(1)		//kill the background....
	endif
	
	
	return(FVW[%FMapStatus][0])

End //RedSpotBackground




//////////////////////////////////////////////////////////////////////////////////
//////////////					Functions to read in GDS II files into the lithography.
//////////////////////////////////////////////////////////////////////////////////



Static Function ReadGDSData(DataType,FileRef,ByteOrder)
	Variable DataType, FileRef, ByteOrder
	//Byte Order is always 2
	Variable Temp, output
	
	Switch(DataType)	
		Case 0:
			//there is no data
			output = NaN
			break
			
		Case 1:
//			fstatus(FileRef)
//			print v_filepos
//			abort "Need to write case 1"
			FBinRead/F=1 FileRef, Temp
			output = Temp
			break	
			
		Case 2:
			FBinRead/f=2 /B=(ByteOrder) FileRef, Temp
			output = Temp
			break
			
		Case 3:
			FBinRead/f=3 /B=(ByteOrder) FileRef, Temp
			output = Temp
			break
			
		Case 4:
			//they claim this is not used...
			output = NaN
			break
			
		Case 5:
			Variable FirstByte, MantissaSign, Exponent, Mantissa=0, i
			
			FBinRead/f=1 /U FileRef, FirstByte
			if (FirstByte > 127)
				MantissaSign = -1
				FirstByte -= 128
			else
				MantissaSign = 1
			endif
			Exponent = FirstByte - 64
			
			for (i = 0;i <= 6;i += 1)
				FBinRead/F=1 /U FileRef, Temp
				Mantissa += Temp * 2 ^ (48 - 8 * i)
			endfor
			Mantissa /= 2 ^ 56
			output = MantissaSign * Mantissa * 16 ^ (Exponent)
			break
			
		Case 6:
			FBinRead/F=1 /U FileRef, Temp
			output = Temp
			break
			
		Default:
			print "DataType:" + num2str(DataType) + " not Supported in "+GetFuncName()
			output = NaN
			break
			
	endswitch
	return output
End //ReadGDSData


Static Function ReadElement(Counter,FileRef)
	Variable Counter, FileRef
	
	FStatus FileRef
	if (v_flag == 0)
		return counter
	endif
	String SavedDataFolder = GetDataFolder(1)
	String DataFolder = GetDF("GDSRoot")
	SetDataFolder DataFolder
	String Xwn = "GDSdataX"+num2str(counter)
	String Ywn = "GDSdataY"+num2str(counter)
	String StrName = "GDSString" + num2str(counter)
	Wave Xdata = $InitOrDefaultWave(XWn,0)
	Wave Ydata = $InitOrDefaultWave(YWn,0)
	SVAR GDSstr = $InitOrDefaultString(StrName,"")
	
	GDSStr = ""
	
	Variable Dat = 0
	String DataType = ""
	String ElementType = ""
	Variable DataVar = 0
	Variable i, Stop = 0
	Variable DataLength, RecordType
	Variable IsWave = 0
	Variable IsStr
	String DataStr = ""
	Variable IsScaled = 0
	
	do	
		DataLength = ReadGDSData(2,FileRef,2)
		RecordType = ReadGDSData(2,FileRef,2)
		ElementType = RecType2Str(RecordType,DataVar)
		
		IsScaled = 0
		IsWave = 0
		IsStr = 0
		if ((DataVar == 6) || (DataVar == 1))
			IsStr = 1
			DataStr = ""
		elseif (cmpstr(ElementType,"XY") == 0)		//put into Wave...
			IsWave = 1
		elseif (cmpstr(ElementType,"WIDTH") == 0)
			IsScaled = 1
		endif
		
		if (IsWave == 0)
			GDSstr += ElementType + ":"
		endif
		
		Stop = ScaleGDSnop(DataLength,DataVar)
		
		if (IsWave == 1)
			ReDimension/N=(Stop / 2) Xdata, Ydata
		endif
		
		for (i = 0;i < Stop;i += 1)
			Dat = ReadGDSData(DataVar,FileRef,2)
			if (IsScaled == 1)
				Dat = ScaleGDSValue(Dat)
			endif
			if (IsWave == 1)
				if (mod(i,2) == 0)		//we call that X
					XData[i / 2] = Dat
				else							//We call that Y
					YData[(i - 1) / 2] = Dat
				endif
			else
				if (IsStr == 0)
					GDSstr += num2str(dat)
					if ((Stop > 1) && (i < Stop - 1))
						GDSStr += ","
					endif
				else			//IsStr == 1
					if (DataVar == 1)
						DataStr += ConvertBitArray(Dat)
					else
						DataStr += num2char(Dat)
					endif
				endif
			endif
		endfor
		
		if (IsStr == 1)
			GDSStr += DataStr
		endif
		
		if (IsWave == 0)
			GDSstr += ";"
		endif
		
		
	while (cmpstr(ElementType,"ENDEL") != 0)
	counter += 1
	SetDataFolder SavedDataFolder
	return counter

End //ReadGDSelememt


Static Function ScaleGDSnop(DataLength,DataVar)
	Variable DataLength, DataVar
	Variable Stop

	Stop = (DataLength - 4)
	if (DataVar == 1)
		Stop *= 1
	elseif (DataVar == 2)
		Stop /= 2
	elseif (DataVar == 3)
		Stop /= 4
	elseif (DataVar == 4)
		Stop /= 4
	elseif (DataVar == 5)
		Stop /= 8
	elseif (DataVar == 6)
		Stop /= 1
	endif
	return Stop
End //ScaleGDSnop


Static Function/S ConvertBitArray(Val)
	Variable Val
	String output = ""
	
	output = num2str(floor(val / 16)) + num2str(mod(val,16))
	return output
End //ConvertBitArray


Static Function/S RecType2Str(RecordType,DataType)			//PASS BY REFERENCE!!!!!!!!!!!!!!!!!!!
	Variable RecordType, &DataType
	String output = ""
	if (RecordType == 2)			//0x0002
		output = "HEADER"
		DataType = 2
	elseif (RecordType == 258)	//0x0102
		output = "BGNLIB"
		DataType = 2
	elseif (RecordType == 518)	//0x0206
		output = "LIBNAME"
		DataType = 6
	elseif (RecordType == 773)	//0x0305
		output = "UNITS"
		DataType = 5
	elseif (RecordType == 1024)	//0x0400
		output = "ENDLIB"
		DataType = 0
	elseif (RecordType == 1282)	//0x0502
		output = "BGNSTR"
		DataType = 2
	elseif (RecordType==1542)	//0x0606
		output = "STRNAME"
		DataType = 6
	elseif (RecordType == 1792)	//0x0700
		output = "ENDSTR"
		DataType = 0
	elseif (RecordType == 2048)	//0x0800
		output = "BOUNDARY"
		DataType = 0
	elseif (RecordType == 2304)	//0x0900
		output = "PATH"
		DataType = 0
	elseif (RecordType == 2560)	//0x0A00
		output = "SREF"
		DataType = 0
	elseif (RecordType == 2816)	//0x0B00
		output = "AREF"
		DataType = 0
	elseif (RecordType == 3072)	//0x0C00
		output = "TEXT"
		DataType = 0
	elseif (RecordType == 3330)	//0x0D02
		output = "LAYER"
		DataType = 2
	elseif (RecordType == 3586)	//0x0E02
		output = "DATATYPE"
		DataType = 2
	elseif (RecordType == 3843)	//0x0F03
		output = "WIDTH"
		DataType = 3
	elseif (RecordType == 4099)	//0x1003
		output = "XY"
		DataType = 3
	elseif (RecordType == 4352)	//0x1100
		output = "ENDEL"
		DataType = 0
	elseif (RecordType == 4614)	//0x1206
		output = "SNAME"
		DataType = 6
	elseif (RecordType == 4866)	//0x1302
		output = "COLROW"
		DataType = 2
	elseif (RecordType == 5376)	//0x1500
		output = "NODE"
		DataType = 0
	elseif (RecordType == 5634)	//0x1602
		output = "TEXTTYPE"
		DataType = 2
	elseif (RecordType == 5889)	//0x1701
		output = "PRESENTATION"
		DataType = 1
	elseif (RecordType==6406)	//0x1906
		output = "String"
		DataType = 6
	elseif (RecordType == 6657)	//0x1A01
		output = "STRANS"
		DataType = 1
	elseif (RecordType == 6917)	//0x1B05
		output = "MAG"
		DataType = 5
	elseif (RecordType == 7173)	//0x1C05
		output = "ANGLE"
		DataType = 5
	elseif (RecordType == 7942)	//0x1F06
		output = "REFLIBS"
		DataType = 6
	elseif (RecordType == 8198)	//0x2006
		output = "FONTS"
		DataType = 6
	elseif (RecordType == 8450)	//0x2102
		output = "PATHTYPE"
		DataType = 2
	elseif (RecordType == 8706)	//0x2202
		output = "GENERATIONS"
		DataType = 2
	elseif (RecordType == 8966)	//0x2306
		output = "ATTRTABLE"
		DataType = 6
	elseif (RecordType == 9726)	//0x2601
		output = "ELFLAGS"
		DataType = 2
	elseif (RecordType == 10754)	//0x2A02
		output = "NODETYPE"
		DataType = 2
	elseif (RecordType == 11010)	//0x2B02
		output = "POPATTR"
		DataType = 2
	elseif (RecordType == 11270)	//0x2C06
		output = "PROPVALUE"
		DataType = 6
	elseif (RecordType == 11520)	//0x2D00
		output = "BOX"
		DataType = 0
	elseif (RecordType == 11778)	//0x2E02
		output = "BOXTYPE"
		DataType = 2
	elseif (RecordType == 12035)	//0x2F03
		output = "PLEX"
		DataType = 3
	elseif (RecordType == 12291)	//0x3003
		output = "BGNEXTN"
		DataType = 3
	elseif (RecordType == 12547)	//0x3103
		output = "EXDEXTN"
		DataType = 3
	elseif (RecordType == 12802)	//0x3202
		output = "TAPENUM"
		DataType = 2
	elseif (RecordType == 13058)	//0x3302
		output = "TAPECODE"
		DataType = 2
	elseif (RecordType == 13826)	//0x3602
		output = "FORMAT"
		DataType = 2
	elseif (RecordType == 14086)	//0x3706
		output = "MASK"
		DataType = 6
	elseif (RecordType == 14336)	//0x3800
		output = "ENDMASKS"
		DataType = 0
	elseif (RecordType == 14594)	//0x3902
		output = "LIBDIRSIZE"
		DataType = 2
	elseif (RecordType == 14854)	//0x3A06
		output = "SRFNAME"
		DataType = 6
	elseif (RecordType == 15106)	//0x3B02
		output = "LIBSECUR"
		DataType = 2
//	elseif (RecordType == )	//0x
//		output = ""
//		DataType = 
//	elseif (RecordType == )	//0x
//		output = ""
//		DataType = 
//	elseif (RecordType == )	//0x
//		output = ""
//		DataType = 
	else
		Print GetFuncName()+" does not know about RecordType "+num2str(RecordType)
	endif
	return output
End //RecType2Str


Static Function OPenGDS()
	
	Variable FileRef
	String Pname = "GDSLoadPath"
	String Ext = ".gds"			//even on macs?
	String Fname = UiGetFile(Pname,Ext)
	if (strlen(Fname) == 0)
		return 0
	endif
	
	Open/R /P=$Pname /Z=0 FileRef as Fname
	
	return FileRef
End //OpenGDS


Static Function ReadGDSStart(FileRef)
	Variable FileRef
	Variable counter = 0
	Fstatus FileRef
	if (v_flag == 0)
		return counter
	endif
	//OK, lets read a little bit, the header
	
	String SavedDataFolder = ActuallyQuoteName(GetDataFolder(1))
	String DataFolder = GetDF("GDSRoot")
	SetDataFolder DataFolder
	
	
	String StrName = "GDSString" + num2str(counter)
	
	SVAR/Z GDSstr = $StrName
	if (SVAR_EXISTS(GDSstr) == 0)
		String/G $StrName
		SVAR GDSstr = $StrName
	endif
	GDSstr = ""
	
	Variable Dat = 0
	String DataType = ""
	String ElementType = ""
	Variable DataVar = 0
	Variable RecordType, DataLength
	Variable i, Stop = 0
	String DataStr = ""
	Variable IsStr
	Variable IsWave = 0
	
	do	
		DataLength = ReadGDSData(2,FileRef,2)
		RecordType = ReadGDSData(2,FileRef,2)
		ElementType = RecType2Str(RecordType,DataVar)
		
		Stop = ScaleGDSnop(DataLength,DataVar)
		DataStr = ""
		
		IsStr = 0
		IsWave = 0
		if (cmpstr(ElementType,"LIBNAME") == 0)
			IsStr = 1
			DataStr = ""
		elseif (CmpStr(ElementType,"UNITS") == 0)
			IsWave = 1
			Make/N=(Stop) /O GDSUnitWave
			Wave Data = GDSUnitWave
		endif
		
		if (IsWave == 0)
			GDSstr += ElementType + ":"
		endif
		
		for (i = 0;i < Stop;i += 1)
			Dat=ReadGDSData(DataVar,FileRef,2)
			if (IsWave == 1)
				Data[i] = dat
			elseif (IsStr == 1)
				DataStr += num2char(Dat)
			else
				GDSstr += num2str(Dat)
			endif
			if ((IsStr == 0) && (IsWave == 0))
				if ((Stop > 1) && (i < Stop - 1))
					GDSStr += ","
				endif
			endif
		endfor
		
		if (IsStr == 1)
			GDSstr += DataStr
		endif
		
		if (IsWave == 0)
			GDSstr += ";"
		endif
	
	while (cmpstr(ElementType,"UNITS") != 0)
	
	String NewDate = GDSdate(StringbyKey("BGNLIB",GDSstr,":",";"))
	GDSStr = ReplaceStringByKey("BGNLIB",GDSStr,NewDate,":",";")
	
	
	counter += 1
	SetDataFolder SavedDataFolder
	return Counter
End //ReadGDSStart


Static Function ReadGDSStructure(FileRef,Counter)
	Variable FileRef
	Variable counter
	Fstatus FileRef
	if (v_flag == 0)
		return counter
	endif
	//OK, lets read a little bit, the header
	
	String SavedDataFolder = ActuallyQuoteName(GetDataFolder(1))
	String DataFolder = GetDF("GDSRoot")
	SetDataFolder DataFolder
	
	
	String StrName = "GDSString" + num2str(counter)
	
	SVAR/Z GDSstr = $StrName
	if (SVAR_EXISTS(GDSstr) == 0)
		String/G $StrName
		SVAR GDSstr = $StrName
	endif
	GDSstr = ""
	
	Variable Dat = 0
	String DataType = ""
	String ElementType = ""
	Variable DataVar = 0
	Variable RecordType, DataLength
	Variable i, Stop = 0
	String DataStr = ""
	Variable IsStr
	Variable IsWave = 0
	
	do	
		DataLength = ReadGDSData(2,FileRef,2)
		RecordType = ReadGDSData(2,FileRef,2)
		ElementType = RecType2Str(RecordType,DataVar)
		
		Stop = ScaleGDSnop(DataLength,DataVar)
		DataStr = ""
		
		IsStr = 0
		IsWave = 0
		if (cmpstr(ElementType,"STRNAME") == 0)
			IsStr = 1
			DataStr = ""
		elseif (IsElement(ElementType) == 1)
			IsWave = 1
			FStatus FileRef
			FSetPos FileRef, v_filepos-4
			Jbar("GDSBar",v_filePos,0,.03)
			Counter = ReadElement(counter+1,FileRef)
		endif
		
		if (IsWave == 0)
			GDSstr += ElementType + ":"
			
			for (i = 0;i < Stop;i += 1)
				Dat = ReadGDSData(DataVar,FileRef,2)
				if (IsStr == 1)
					DataStr += num2char(Dat)
				else
					GDSstr += num2str(Dat)
				endif
				if (IsStr == 0)
					if ((Stop > 1) && (i < Stop - 1))
						GDSStr += ","
					endif
				endif
			endfor
			
			if (IsStr == 1)
				GDSstr += DataStr
			endif
			
			GDSstr += ";"
		endif
	
	while (cmpstr(ElementType,"ENDSTR") != 0)
	
	SetDataFolder SavedDataFolder
	return counter
End //ReadGDSStructure


Static Function IsElement(ElementType)
	String ElementType
	Variable output = 0

	strswitch(ElementType)	// String switch
		case "BOUNDARY":		// execute if case matches expression
		case "PATH":		// execute if case matches expression
		case "SREF":
		case "AREF":
		case "TEXT":
		case "NODE":
		case "BOX":
			output = 1
	endswitch

	return output
End //IsElement


Static Function ScaleGDSdata()
	String SavedDataFolder = GetDataFolder(1)
	String DataFolder = GetDF("GDSRoot")
	SetDataFolder DataFolder

	Wave/Z Scale = GDSunitWave
	if (WaveExists(Scale) == 0)
		return 0
	endif
	String Wlist = WaveList("GDSdata*",";","")
	String WN
	Variable i, Stop = ItemsInList(Wlist,";")
	for (i = 0;i < Stop;i += 1)
		WN = StringFromList(i,Wlist,";")
		Wave Data = $WN
		Redimension/D Data
		FastOp Data = (Scale[0] * Scale[1]) * Data
		SetScale d, 0, 0, "m", Data
	endfor
	SetDataFolder SavedDataFolder
End //ScaleGDSdata


Static Function LoadGDS()
	
	Variable FileRef = OPenGDS()
	if (FileRef == 0)
		return 0
	endif
	
	String SavedDataFolder = ActuallyQuoteName(GetDataFolder(1))
	String DataFolder = GetDF("GDSRoot")
	if (DataFolderExists(DataFolder)==0)
		BuildDataFolder(DataFolder)
	endif
	SetDataFolder DataFolder
	CleanGDSdir()
	
	String JbarHand = "GDSBar"
	Fstatus FileRef
	InitJbar(JbarHand,num2str(V_logEOF)+",10,10","Reading GDS data;Converting GDS 2 Litho;Fixing Point Density;","","")
		
	ReadGDSStart(FileRef)
	Variable Counter = 1
	
	Variable DataLength, RecordType, DataVar
	String ElementType
	
	do
		Jbar(JbarHand,v_filePos,0,.03)
		Counter = ReadGDSStructure(FileRef,Counter)
		
		DataLength = ReadGDSData(2,FileRef,2)
		RecordType = ReadGDSData(2,FileRef,2)
		ElementType = RecType2Str(RecordType,DataVar)
		FStatus FileRef
		FsetPos FileRef, V_filePos-4
	while (cmpstr(ElementType,"ENDLIB") != 0)
	
	//clean up!
	
	
	Close(FileRef)
	ScaleGDSData()
	ConvertGDS2Litho()
	
	DoWindow/K $JbarHand
	//CleanUp Indiviual Waves?
	DoAlert 1, "CleanUp Indiviual Waves?\your machine will run faster without this extra data."
	if (v_flag == 1)
		CleanGDSdir()
	endif
	SetDataFolder SavedDataFolder
	
End //LoadGDS


Static Function ConvertGDS2Litho()
	BuildGDSLayer()				//first we extract the layer info...
	String SavedDataFolder = GetDataFolder(1)
	String DataFolder = GetDF("GDSRoot")
	SetDataFolder DataFolder
	SVAR/Z DataStr = GDSString0
	if (SVAR_EXISTS(DataStr) == 0)
		return 0
	endif
	String Fname = StringByKey("LIBNAME",DataStr,":",";")
	Variable Ind = StrSearch(Fname,".",0)
	if (Ind > -1)
		Fname = Fname[0,ind - 1]
	endif
	String DataFolder2 = "Root:Packages:MFP3D:Litho:Groups:"
	SetDataFolder DataFolder2
	Make/D/O/N=0 $"X" + Fname, $"Y" + Fname
	Wave LithoX = $"X" + Fname
	Wave LithoY = $"Y" + Fname
	Wave/T GroupList = GroupList
	Wave GroupListBuddy = GroupListBuddy
	SetDataFolder DataFolder
	
	Wave/T/Z GDSLayerWave = GDSLayerWave
	Wave/Z GDSLayerData = GDSLayerData
	
	String Wlist = ""
	
	if ((WaveExists(GDSLayerData) == 0) || (WaveExists(GDSLayerWave) == 0))
		Wlist = WaveList("GDSdataY*",";","")
	else
		Wlist = TWave2strList(GDSLayerWave)
	endif
	
	String Yname, Xname
	Variable Gind
	Variable i, Stop = ItemsInList(Wlist,";")
	String Jhand = "GDSBar"
	ResetJbarLim(JHand,Stop,1)
//	InitJbar(JHand,num2str(Stop),"Converting GDS 2 Litho")
	for (i = 0;i < Stop;i += 1)
		Jbar(JHand,i,1,.03)
		Yname = StringFromList(i,Wlist,";")
		Gind = GetEndNum(Yname)
		Xname = "GDSdataX" + num2str(Gind)
		Wave Xdata = $Xname
		Wave Ydata = $Yname
		InsertWave(LithoX,Xdata,numpnts(LithoX))
		InsertWave(LithoY,Ydata,numpnts(LithoY))
		InsertPoints numpnts(LithoX), 1, LithoX
		InsertPoints numpnts(LithoY), 1, LithoY
		LithoY[numpnts(LithoY) - 1] = NaN
		LithoX[numpnts(LithoX) - 1] = NaN
	endfor
	SetDataFolder SavedDataFolder
//	DoWindow/K $JHand
	
	if (Find1TWave(GroupList,Fname) == -1)
		InsertPoints numpnts(GroupList), 1, GroupList, GroupListBuddy
		GroupList[numpnts(GroupList) - 1] = Fname
	endif
	ConvertGDSLithoPointDensity(Fname)	
End //ConvertGDS2Litho


Function GDSbuttonProc(CtrlName)
	String Ctrlname		//Not Used
	LoadGDS()
End //GDSbuttonProc


Static Function ScaleGDSValue(Var)
	Variable Var
	Variable output
	
	String SavedDataFolder = ActuallyQuoteName(GetDataFolder(1))
	String DataFolder = GetDF("GDSRoot")
	SetDataFolder DataFolder
	Wave/Z Scale = GDSUnitWave
	if (WaveExists(Scale) == 0)
		SetDataFolder SavedDataFolder
		return var
	endif
	output = Scale[0] * Scale[1] * var
	return output
End //ScaleGDSvalue


Static Function CleanGDSdir()						//this function is in the GDS text version.
	String SavedDataFolder = GetDataFolder(1)
	String DataFolder = GetDF("GDSRoot")
	SetDataFolder DataFolder
	String Wlist = WaveList("GDSdata*",";","")
	String Slist = StringList("GDSString*",";")
	String Jhand = "GDSClean"
	InitJbar(JHand,num2str(ItemsInList(Wlist,";")) + "," + num2str(ItemsInList(Slist,";")),"Waves;Strings;","","")


	Variable i, Stop = ItemsInList(Wlist,";")
	for (i = 0;i < Stop;i += 1)
		Jbar(JHand,i,0,0.01)
		KillWaves/Z $StringFromList(i,Wlist,";")
	endfor
	Stop = ItemsInList(Slist,";")
	for (i = 0;i < Stop;i += 1)
		Jbar(JHand,i,1,0.01)
		KillStrings/Z $StringFromList(i,Slist,";")
	endfor
	KillWaves/Z GDSUnitWave, GDSLayerWave, GDSLayerData
	DoWindow/K $Jhand

	SetDataFolder SavedDataFolder
End //CleanGDSdir


Static Function/S GDSdate(DateStr)
	String DateStr
	String output = ""
	Variable i, Stop = ItemsInList(DateStr,",")
	if (Stop != 12)
		return output
	endif
	
	output = "Last Mod: "
	String DateStr1 = ""
	for (i = 0;i < 6;i += 1)
		DateStr1 += StringFromList(i,DateStr,",")
		if (i < 5)
			DateStr1 += ","
		endif
	endfor
	
	output += GDSdateSlave(DateStr1)
	
	DateStr1 = ""
	for (i = 6;i < Stop;i += 1)
		DateStr1 += StringFromList(i,DateStr,",")
		if (i < Stop - 1)
			DateStr1 += ","
		endif
	endfor
	output += " Last Access: "
	output += GDSdateSlave(DateStr1)
	return output
End //GDSdate


Static Function/S GDSDateSlave(DateStr)
	String DateStr
	String output = ""
	Variable i, Stop = ItemsInList(DateStr,",")
	if (Stop != 6)
		return(output)
	endif
	
	Variable Year, Month, Day, Hour, Minute, Sec
	String YearS, MonthS, DayS, HourS, MinuteS, SecS
	
	YearS = StringFromList(0,DateStr,",")
	Year = str2num(YearS) + 1900
	YearS = num2str(Year)
	
	MonthS = StringFromList(1,DateStr,",")
	Month = Str2num(MonthS)
	MonthS = MonthLookUp(Month)
	
	DayS = StringFromList(2,DateStr,",")
	Day = str2num(DayS)
	
	HourS = StringFromList(3,DateStr,",")
	Hour = str2num(HourS)
	
	MinuteS = StringFromList(4,DateStr,",")
	Minute = str2num(MinuteS)
	
	SecS = StringFromList(5,DateStr,",")
	Sec = str2num(SecS)
	
	output = MonthS + "-" + DayS + "-" + YearS + " " + HourS + ":" + MinuteS + ":" + SecS
	return output
	
End //GDSdate


Function/S MonthLookUp(Var)
	Variable Var
	String output = ""
	
	String OutputList = "January;Febuary;March;April;May;June;July;August;Sepember;October;November;December;"
	output = StringFromList(Var-1,OutputList,";")
	if (!Strlen(Output))
		Output = OutputList
	endif
	
	return(output)
End //MonthLookUp


Static Function BuildGDSLayer()
	
	//OK, build a Layer Wave to tell us what order to put our Waves in
	
	
	//First make the text Wave....
	
	
	String SavedDataFolder = ActuallyQuoteName(GetDataFolder(1))
	String DataFolder = GetDF("GDSRoot")
	SetDataFolder DataFolder
	String Wlist = WaveList("GDSdataY*",";","")
	
	
	Make/N=0/T/O GDSLayerWave
	Wave/T GDSLayerWave = GDSLayerWave
	StrList2Wave2(Wlist,GDSLayerWave,0)
	
	//OK, now get all the Strings
	
	
	Variable i, Stop = dimsize(GDSLayerWave,0)
	Make/O/N=(Stop) GDSLayerData
	Wave GDSLayerData = GDSLayerData
	
	String Sname
	Variable Gind
	Variable Layer
	
	for (i = 0;i < Stop;i += 1)
		Gind = GetEndNum(GDSLayerWave[i])
		Sname = "GDSString" + num2str(Gind)
		SVAR Data = $Sname
		Layer = NumberByKey("Layer",Data,":",";")
		if (numtype(Layer) != 0)
			Layer = 0
		endif
		GDSLayerData[i] = Layer
	endfor
	
	SetDataFolder SavedDataFolder
	
	Sort GDSLayerData, GDSLayerData, GDSLayerWave
	
	
End //BuildGDSLayer


Static Function ConvertGDSLithoPointDensity(Fname)
	String Fname
	
	String SD = ACtuallyQuoteName(GetDataFolder(1))
	String DF = "Root:Packages:MFP3D:Litho:Groups:"
	SetDataFolder(DF)
	Wave/Z Xdata = $"X"+Fname
	Wave/Z Ydata = $"Y"+Fname
	SetDataFolder(SD)
	if ((WaveExists(Xdata) == 0) || (WaveExists(Ydata) == 0))
		print "can not find Litho data: "+Fname
		DoWindow/H
		return(0)
	endif
	
	Wave Xsub = $LocalWave(0)			//collect data subset for Interp inpout
	Wave Ysub = $LocalWave(0)
	Wave XsubInt = $LocalWave(0)		//Interp output
	Wave YSubInt = $LocalWave(0)
	Wave Youtput = $LocalWave(0)		//new version of GDS Wave
	Wave Xoutput = $LocalWave(0)
	
	//make the workspace Waves for LinearInterpFast
	Wave Xdiff = $LocalWave(0)
	Wave YDiff = $LocalWave(0)
	Wave XYDiff = $LocalWave(0)
	Wave Xsub2 = $LocalWave(0)
	Wave Ysub2 = $LocalWave(0)
	
	//they all need to be double precission, in order to take the difference.
	Redimension/D Xdiff,Ydiff,XYDiff, Xsub2,Ysub2,Xsub,Ysub,XsubInt,YsubInt,Xoutput,Youtput
	
	Wave IndexWave = $Find(Xdata,"==",NaN)
	InsertPoints 0,1,IndexWave
	IndexWave[0] = -1
	
	Variable A, nop = DimSize(IndexWave,0)-1
	
	String Jhand = "GDSbar"
	ResetJbarLim(JHand,nop,2)
//	InitJbar(JHand,num2str(nop),"Fixing Point Density")
	Variable MaxNop = 200/(log(nop)+1)
	
	
	for (A = 0;A < nop;A += 1)
		Jbar(Jhand,A,2,.03)
		Redimension/N=(IndexWave[A+1]-IndexWave[A]-1) Xsub,Ysub
		
		Xsub[] = Xdata[p+IndexWave[A]+1]
		Ysub[] = Ydata[p+IndexWave[A]+1]

		LithoInterp(NaN,MaxNop,Xsub,Ysub,XSubInt,YSubInt,Xdiff,Ydiff,XYdiff,Xsub2,Ysub2)
		
		if (numpnts(XsubInt) > 0)		
			InsertWave(Xoutput,XSubInt,numpnts(Xoutput))
			InsertWave(Youtput,YSubInt,NumPnts(Youtput))
			
			InsertPoints Numpnts(Xoutput),1,Xoutput,Youtput
			Xoutput[numpnts(Xoutput)-1] = NaN
			Youtput[numpnts(Youtput)-1] = NaN
		endif
		
	endfor
	
//	DoWindow/K $Jhand
	
	Duplicate/O Xoutput,Xdata
	Duplicate/O Youtput,Ydata
	
	//clean up all our mess.
	
	KillWaves XSubInt,YSubInt,Xoutput,Youtput,Xsub,YSub
	KillWaves XDiff,Ydiff,XYDiff,Xsub2,Ysub2
	
End //ConvertGDSLithoPointDensity


Static Function LithoInterp(nop,Type,Xdata,Ydata,Xdest,Ydest,Xdiff,Ydiff,XYDiff,Xsub,Ysub)
	Variable nop, Type
	Wave Xdest, Ydest, Xdata, Ydata
	
	
	//these Waves are used as workspace in this function
	//they are provided so that it runs faster in a loop
	//they need to be double precission Waves, the number of points is run in here.
	Wave Xdiff, Ydiff, XYDiff, Xsub, Ysub
	
//Duplicate/O XData,XCopy
//Duplicate/O YData,YCopy
	
	//if type == 1, then we force Xdest and Ydest to have nop points, which are evenly spaces
	//If type == 2, then we force Xdest and Ydest to have a spacing of nop between points.
	//if Nop is NaN it will calc the value for you, based onthe smallest gap between points.
	//in that case, type is the Maximum number of points you want a set of
	//2  data points interpolated to.
	//if the function wants to interp to more than Type points it will pull out that
	//set and put it in as a separate group (NaN separated)
	
	
	//this is the same thing as LinearInterp, but quite a bit faster
	//you have to give it 4 Waves for it to use as workspace
	//the number of points does not matter, it will fix them
	
	Variable NopStart = DimSize(Xdata,0)
	
	if (NopStart <= 2)
		Duplicate/O Xdata,Xdest
		Duplicate/O Ydata,Ydest
		return(0)
	endif
	ReDimension/N=0 Xdest,Ydest
		
	Diff(Xdata,Xdiff)
	Diff(YData,Ydiff)
	
	ReDimension/N=(NumPNts(Xdiff))	XYDiff

	XYDiff = sqrt(Xdiff^2+Ydiff^2)
	
	Variable Zero = 1e-20		//anything less than this we call 0
	

	//ok, check to make sure they do not have 2 of the same points in a row
	if (WaveMin(XYDiff) < Zero)
		Wave IndexWave = $Find(XYDiff,"<=",Zero)
		RemoveIndexes(XYDiff,IndexWave)
		RemoveIndexes(Xdata,IndexWave)
		RemoveIndexes(Ydata,IndexWave)
		KillWaves IndexWave
		NopStart = DimSize(Xdata,0)
	endif
	
	
	Variable MinSpaceing, MaxNop = 50
	
	if (IsNan(Nop))
		MinSpaceing = WaveMin(XYDiff)
		MaxNop = Type
		Variable MaxSpaceing = WaveMax(XYDiff)
		Variable factor = MaxSpaceing/MinSpaceing
		
		if ((factor > 1.05) && (Factor < 3))
			MinSpaceing/=Max(Ceil(1/(Factor-1)),2)
		endif	
	elseif (Type == 1)
		MinSpaceing=Sum(XYDiff,-inf,inf)/nop
	elseif (Type == 2)
		MinSpaceing = nop
	endif
	
	//we are done with nop, we will now use it to pass info to LinSpace2
	
	ReDimension/N=0 Xsub,Ysub
	Variable A, Stop = NopStart-1

	
	for (A = 0;A < Stop;A += 1)
		
		nop = max(round(XYDiff[A]/MinSpaceing),1)+1
		if (nop > MaxNop)			//what are we doing here?
		
			if ((!IsNan(Xdest[Numpnts(Xdest)-1])) && (A!=0))
				InsertPoints Numpnts(Xdest),1,XDest,Ydest
				Xdest[numpnts(Xdest)-1]=NaN
				Ydest[numpnts(Ydest)-1]=NaN
			endif
			InsertPoints numpnts(Xdest),2,Xdest,Ydest
			Xdest[Numpnts(Xdest)-2] = Xdata[A]
			XDest[Numpnts(Xdest)-1] = Xdata[A+1]

			Ydest[Numpnts(Ydest)-2] = Ydata[A]
			YDest[Numpnts(Ydest)-1] = Ydata[A+1]
			
			if (A<Stop-1)
				InsertPoints numpnts(Xdest),1,Xdest,Ydest
				Xdest[numpnts(Xdest)-1]=NaN
				Ydest[numpnts(Ydest)-1]=NaN
			endif

			Continue
		endif
		
		LinSpace2(Xdata[A],Xdata[A+1],nop,Xsub)
		LinSpace2(Ydata[A],Ydata[A+1],nop,Ysub)
		if ((abs(Xsub[0]-Xdest[numpnts(Xdest)-1]) < Zero) && (abs(Ysub[0]-Ydest[numpnts(Ydest)-1]) < Zero))
			DeletePoints 0,1,Xsub,Ysub
		endif
		InsertWave(Xdest,Xsub,numpnts(XDest))
		InsertWave(Ydest,Ysub,numpnts(YDest))
	
	endfor
End //LithoInterp



//////////////////////////////////////////////////////////////////////////////////
//////////////					End  Functions to read in GDS II files into the lithography.
//////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////
//////////////					Start Litho Snap Functions
//////////////////////////////////////////////////////////////////////////////////

Function DoLithoSnapFunc(CtrlName)
	String CtrlName
	
	String CtrlNameOrg = CtrlName
	Variable RemIndex = FindLast(CtrlName,"_")
	if (RemIndex >= 0)
		CtrlName = CtrlName[0,RemIndex-1]
	endif
	RemIndex = FindLast(CtrlName,"Button")
	if (RemIndex >= 0)
		CtrlName = CtrlName[0,RemIndex-1]
	endif


	StrSwitch (CtrlName)
		case "LithoOffline":
			Set2DPlotter("OfflineLitho","root:SavedLitho:")
			break
		
		case "DoLithoSnap":
			PV("LithoSnap",1)
			DoLithoFunc("DoLitho_0")
			
		
			break
			
		case "DoLithoPreSnap":
			PV("LithoSnap",0)
			PV("LithoPreSnap",1)
			PreLithoSnap()
			break
	
		case "DoLithoSnapGraph":
			DisplayPreLitho()
			break
			
	EndSwitch
	
	

End //DoLithoSnapFunc


Function LithoSnapGraphHook(InfoStruct)
	STRUCT WMWinHookStruct &InfoStruct
	//EventName
	//WinName
	
	
	String Event = InfoStruct.EventName
	if (StringMatch(Event,"cursormoved") == 0)
		return(0)
	endif
	
	string GraphStr = InfoStruct.WinName
	String DataFolder = GetDF("Litho")
	Wave LithoSnapPath = $DataFolder+"LithoSnapPath"
	
	
	if (!IsCursor(GraphStr,"A",IsFree=1))
		Cursor/F/A=1/W=$GraphStr A LithoSnapPath 0,0
	endif
	
	if (!IsCursor(GraphStr,"B",IsFree=1))
		Cursor/F/A=1/W=$GraphStr B LithoSnapPath rightx(LithoSnapPath),0
	endif
		
	Variable AY = vcsr(A)
	Variable AX = hcsr(A)
	Variable BY = vcsr(B)
	Variable BX = hcsr(B)
	
	
	Variable Slope = (AY-BY)/(AX-BX)
	Variable Offset = AY-Slope*AX
	LithoSnapPath = X*Slope+Offset
	
	doupdate
	Cursor/F/A=1/W=$GraphStr A LithoSnapPath AX,AY
	Cursor/F/A=1/W=$GraphStr B LithoSnapPath BX,BY
	
	
	return(0)
End //LithoSnapGraphHook


Function DisplayPreLitho()



	SVAR BaseName = root:Packages:MFP3D:Main:Variables:BaseName
	Variable Suffix = GV("LithoPreSnapSuffix")
	String DataFolder = "root:SavedLitho:"
	String DestFolder = GetDF("Litho")
	String SuffixStr = num2strlen(Suffix,4)
	Wave/Z ReviewLitho = $DataFolder+BaseName+SuffixStr
	if (WaveExists(ReviewLitho) == 0)
		Print "Lost our wave!"
		Print BaseName+SuffixStr+" was not found in "+GetFuncName()
		DoWindow/H
		return(0)
	endif
	Wave TotalHeight = $InitOrDefaultWave(DestFolder+"LithoSnapHeight",0)
	Redimension/N=(DimSize(ReviewLitho,0)) TotalHeight
	TotalHeight = ReviewLitho[P][%Height]
	String NoteStr = Note(ReviewLitho)
	Note/K TotalHeight
	Note TotalHeight,NoteStr
	
	Wave LithoSnapPath = $InitOrDefaultWave(DestFolder+"LithoSnapPath",0)
	SetScale d,0,0,"m",TotalHeight,LithoSnapPath
	Note/K LithoSnapPath
	Note LithoSnapPath,NoteStr
	Variable nop = DimSize(TotalHeight,0)
	Redimension/N=(nop) LithoSnapPath
	WaveStats/Q TotalHeight
	LithoSnapPath = V_Avg
	String GraphStr = "LithoSnapGraph"
	DoWindow/F $GraphStr
	if (!V_Flag)
		Display/K=1/N=$GraphStr TotalHeight,LithoSnapPath
		SetWindow $GraphStr Hook(Cursor)=LithoSnapGraphHook
		ModifyGraph/W=$GraphStr rgb(LithoSnapHeight)=(0,0,52224)
		ModifyGraph/W=$GraphStr rgb(LithoSnapPath)=(0,0,0)
		Struct WMWinHookStruct InfoStruct
	
	endif
	Cursor/F/A=1/W=$GraphStr A $NameOfWave(TotalHeight) pnt2x(LithoSnapPath,0),LithoSnapPath[0]
	Cursor/F/A=1/W=$GraphStr B $NameOfWave(TotalHeight) pnt2x(LithoSnapPath,nop-1),LithoSnapPath[nop-1]
	InfoStruct.EventName = "CursorMoved"
	InfoStruct.WinName = GraphStr
	LithoSnapGraphHook(InfoStruct)



End //DisplayPreLitho


Function PreLithoSnap()
	
	LithoBoxFunc("LithoSaveBox_0",1)
	
	
	Variable SetPoint, OtherSetPoint
	String ParmName = ""
	
	Struct ARImagingModeStruct ImagingModeParms
	ARGetImagingMode(ImagingModeParms)
	OtherSetpoint = -12*ImagingModeParms.GainSign
	Setpoint = ImagingModeParms.Feedback[0].Setpoint
	ParmName = ImagingModeParms.SetpointParm
	
	Switch (ImagingModeParms.ImagingMode)
		case 1:		//AC
			LithoSetVarFunc("LithoBiasSetVar_0",0,"",":Variables:LithoVariablesWave[%LithoBias]")
			LithoBoxFunc("LithoUseSetpointBox_0",1)
			break
			
		case 0:		//contact
			break
		
		case 2:		//FM
		case 3:		//PFM
		case 4:		//STM
		
			Abort "LITHO SNAP DOES NOT WORK IN ADVANCED IMAGING MODES\rYOU NEED TO USE AC OR CONTACT!"
			break
			
	endswitch
	
	LithoSetVarFunc("LithoSetpointVoltsSetVar_0",Setpoint,"",":Variables:LithoVariablesWave[%LithoSetpointVolts]")
	MainSetVarFunc("SetPointSetVar_0",OtherSetPoint,"",":Variables:MasterVariablesWave[%"+ParmName+"]")
	
	DoLithoFunc("DoLitho_0")			//do the normal litho...


End //PreLithoSnap




//////////////////////////////////////////////////////////////////////////////////
//////////////					End Litho Snap Functions
//////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////
//////////////					Start Litho Velocity Functions
//////////////////////////////////////////////////////////////////////////////////


Function InitVelocityScan(CtrlName)
	String CtrlName
	
	
	
	
	String CtrlNameOrg = CtrlName
	Variable RemIndex = FindLast(CtrlName,"_")
	if (RemIndex >= 0)
		CtrlName = CtrlName[0,RemIndex-1]
	endif
	RemIndex = FindLast(CtrlName,"Button")
	if (RemIndex >= 0)
		CtrlName = CtrlName[0,RemIndex-1]
	endif
	
	if (GV("LithoImageIsBiasMap"))
		if (StringMatch(CtrlName,"*DoScan*"))
			DoScanFunc("DoBiasScan_0")
			return(0)
		elseif (StringMatch(CtrlName,"*UpScan*"))
			DoScanFunc("UpBiasScan_0")
			return(0)
		elseif (StringMatch(Ctrlname,"*DownScan*"))
			DoScanFunc("DownBiasScan_0")
			return(0)
		endif
	endif
	
	
	
	String DataFolder = cLithoBitMapFolder
	Wave/Z FastWave = $InitOrDefaultWave(DataFolder+"FastWave",0)
	Wave/Z SlowWave = $InitOrDefaultWave(DataFolder+"SlowWave",0)
	Wave RVW = $GetDF("Variables")+"RealVariablesWave"
	Variable ScanSize = RVW[%ScanSize][0]
	
	String SavedDataFolder = GetDataFolder(1)
	StrSwitch (CtrlName)
		case "VelocityLoadImage":
			ImageLoad/O/Q/T=Any
			if (!V_Flag)
				return(0)
			endif
			Wave GreyImage = $StringFromList(0,S_waveNames,";")
			Duplicate/O GreyImage,$DataFolder+"GreyImage"
			DataFolder = UpDir(DataFolder)+":LithoBias:"
			SetDataFolder(BuildDataFolder(DataFolder))
			Duplicate/O GreyImage,$DataFolder+"MasterImage"
			KillWaves GreyImage
			Wave MasterImage = $DataFolder+"MasterImage"
			if (DimSize(MasterImage,2) > 1)
				ImageTransform rgb2gray MasterImage
			else
				//OK, Igor 6.10B6 fixed the compiler error
				Duplicate/O MasterImage,M_RGB2Gray
			
				//Execute/Q "Duplicate/O MasterImage,M_RGB2Gray"		//for some reason, in Igor 6.10, if this is in the compiler
				//It can not get a WaveRef to M_RGB2Gray
				//This is extra confussing because it does not run, just has to be in the compiler.
			endif
			Wave GreyImage = M_RGB2Gray
			Redimension/S GreyImage
			SetDataFolder(SavedDataFolder)
			//ARInterpImage(GreyImage,128,128)
			//and scale
			ARScaleLithoBias()
			BiasBitMapGraphFunc()
			
			return(0)
			
		case "VelocityStopScan":
			DoScanFunc("StopScanButton_0")
			return(0)
	endswitch
	
	
	Wave/Z GreyImage = $DataFolder+"GreyImage"
	if (WaveExists(GreyImage) == 0)
		DoAlert 0,"Um pardon me, but it seems that you have not loaded an image yet...\rPlease do so at your earliest convenience."
		return(0)
	endif
	
	String ErrorStr = ""
	
	StrSwitch (CtrlName)
		case "VelocityDoScan":
		
			SimpleEngageMe("SimpleEngageButton")
			
			
			Variable InterpVal = PlanE(GreyImage,FastWave,SlowWave,GV("LithoVelocityMin"),GV("LithoVelocityMax"),ScanSize)
			
			
		
			//OK, now we are going to make the inputs for the Velocity scan.....
			
			//these we are going to make big enough to collect the entire image.
			Variable TotalTime = DimSize(FastWave,0)*InterpVal/cMasterSampleRate
			Variable nop = numpnts(GreyImage)
			nop -= mod(nop,32)
			Variable OtherInterp = nop/TotalTime		//actually points per sec, convert next...
			OtherInterp = cMasterSampleRate/OtherInterp
			
			
			SetDataFolder(cLithoBitMapFolder)
			Make/O/N=(nop) Deflection,XLVDT,YLVDT,ZLVDT,Height
			Wave Deflection,XLVDT,YLVDT,ZLVDT,Height
			SetDataFolder(SavedDataFolder)
			ErrorStr += IR_XSetInWavePair(0,"0","ZSensor",ZLVDT,"Height",Height,"",OtherInterp)
			ErrorStr += IR_XSetInWavePair(1,"0","XSensor",XLVDT,"YSensor",YLVDT,"",OtherInterp)
			ErrorStr += IR_XSetInWave(2,"0","Deflection",Deflection,"VelocityCallback()",OtherInterp)
			
			
			VelocityBufferScan(FastWave,SlowWave,InterpVal)
		
			//Make sure we have hit engage....
			
	//		PV("LowNoise",1)
		
		
			ARReportError(ErrorStr)
			break
			
	EndSwitch

End //InitVelocityScan


Function MakeCap9(DriveWave,StartIndex,StopIndex,CapWave,TempWave0,TempWave1,TempWave2)
	Wave DriveWave
	Variable StartIndex, StopIndex
	Wave CapWave, TempWave0, TempWave1, TempWave2
	
	
	Redimension/D/N=(4) TempWave0
	TempWave0[0] = DriveWave[StartIndex]
	TempWave0[1] = DriveWave[StopIndex]
	TempWave0[2] = (DriveWave[StartIndex]-DriveWave[StartIndex-1])/DimDelta(DriveWave,0)
	TempWave0[3] = (DriveWave[StopIndex+1]-DriveWave[StopIndex])/DimDelta(DriveWave,0)
	
	Variable XOffset = pnt2x(DriveWave,StartIndex)
	MakeCap7(TempWave0,0,pnt2x(DriveWave,StopIndex)-XOffset,CapWave,TempWave1,TempWave2)
	DriveWave[StartIndex+1,StopIndex-1] = poly(CapWave,x-XOffset)
	//MakeCap2(TempWave0,pnt2x(DriveWave,StartIndex),pnt2x(DriveWave,StopIndex))
	//Wave CapCoefs
	//DriveWave[StartIndex+1,StopIndex-1] = poly(CapCoefs,x)
	
End //MakeCap9


Function MakeCap7(BoundCond,startx,endx,CapCoefs,Denommatrix,TempMatrix)
	Wave BoundCond
	variable startx
	variable endx
	Wave CapCoefs
	Wave/D Denommatrix, TempMatrix

//Makes a cubic cap for where the boundary conditions are in BoundCond[0]={F(startx),F(end(x),F'(startx),F'(endx)}
//Returns poly coefs in wave called CapCoefs


	Redimension/D/N=(4) CapCoefs
	
	
	// Make necessary matrices to calculate coefficients for cubic cap.
	Redimension/D/N=(4,4) Denommatrix, TempMatrix
	
//	Make/o/N=(4,4)/D Denommatrix
//	Make/o/N=(4,4)/D Amatrix
//	Make/o/N=(4,4)/D Bmatrix
//	Make/o/N=(4,4)/D Cmatrix
//	Make/o/N=(4,4)/D Dmatrix	

	Denommatrix[0][0] = startX^3
	Denommatrix[1][0] = endX^3
	Denommatrix[2][0] = 3*startx^2
	Denommatrix[3][0] = 3*endx^2 
	Denommatrix[0][1] = startx^2
	Denommatrix[1][1] = endx^2
	Denommatrix[2][1] = 2*startx
	Denommatrix[3][1] = 2*endx 
	Denommatrix[0][2] = startx
	Denommatrix[1][2] = endx
	Denommatrix[2][2] = 1
	Denommatrix[3][2] = 1
	Denommatrix[0][3] = 1
	Denommatrix[1][3] = 1
	Denommatrix[2][3] = 0
	Denommatrix[3][3] = 0
	
	//Calculate Coefficients
	variable denominator = MatrixDet(Denommatrix)

	TempMatrix = Denommatrix
	TempMatrix[][0] = Boundcond[P]
	CapCoefs[3] = MatrixDet(TempMatrix)/denominator
	
	
	TempMatrix = Denommatrix
	TempMatrix[][1] = Boundcond[P]
	CapCoefs[2] = MatrixDet(TempMatrix)/denominator
	
	TempMatrix = Denommatrix
	TempMatrix[][2] = Boundcond[P]
	CapCoefs[1] = MatrixDet(TempMatrix)/denominator
	
	TempMatrix = Denommatrix
	TempMatrix[][3] = Boundcond[P]
	CapCoefs[0] = MatrixDet(TempMatrix)/denominator
	
End //MakeCap7


Function VelocityCallback()
	
	td_WriteString("Event.0","Clear")
	String ErrorStr = ""
	ErrorStr += SetLowNoise(0)

	DoScanFunc("StopEngageButton")
	
	String DataFolder = cLithoBitMapFolder
	
	Wave Deflection = $DataFolder+"Deflection"
	Wave ZLVDT = $DataFolder+"ZLVDT"
	Wave XLVDT = $DataFolder+"XLVDT"
	Wave YLVDT = $DataFolder+"YLVDT"
	Wave Height = $DataFolder+"Height"
	
	
	Variable XLVDTSens = GV("XLVDTSens")
	Variable YLVDTSens = GV("YLVDTSens")
	Variable ZLVDTSens = GV("ZLVDTSens")
	Variable ZPiezoSens = GV("ZPiezoSens")
	
	
	
	FastOp Height = (-70)+Height
	FastOp Height = (-ZPiezoSens)*Height
	
	FastOp XLVDT = (abs(XLVDTSens))*XLVDT
	FastOp YLVDT = (abs(YLVDTSens))*YLVDT
	FastOp ZLVDT = (-ZLVDTSens)*ZLVDT
	
	
	SetScale d,0,0,"m",ZLVDT,XLVDT,YLVDT,Height
	ARReportError(ErrorStr)


End //VelocityCallback


Function MakeLithoBitMapPanel(Var)
	Variable Var

	String WindowsFolder = GetDF("Windows")
	String GraphStr = GetFuncName()
	GraphStr = GraphStr[4,Strlen(GraphStr)-1]
	Wave PanelParms = $WindowsFolder+GraphStr+"Parms"

	
	Variable HelpPos = PanelParms[%HelpPos][0]
	Variable SetUpLeft = PanelParms[%SetupLeft][0]
	Variable Control1Bit = PanelParms[%Control1Bit][0]
	Variable OldControl1Bit = PanelParms[%oldControl1Bit][0]
	Variable Margin = PanelParms[%Margin][0]
	Variable ButtonWidth = PanelParms[%ButtonWidth][0]
	Variable ButtonHeight = PanelParms[%ButtonHeight][0]
	Variable Red = PanelParms[%RedColor][0]
	Variable Green = PanelParms[%GreenColor][0]
	Variable Blue = PanelParms[%BlueColor][0]
	Variable StepSize = 25
	Variable BodyWidth = PanelParms[%BodyWidth][0]
	
	Variable SecondMargin = PanelParms[%SecondMargin][0]
	
	Variable Bit
	String HelpFunc = "ARHelpFunc"
	String SetupFunc = "ARSetupPanel"
	Variable Enab = 0
	Variable DisableHelp = 2
	Variable LeftPos = Margin
	Variable FontSize = 14
	String ControlName, ControlName0, ControlName1, ControlName2
	String HelpName
	
	Variable TabNum = ARPanelTabNumLookup(GraphStr)
	if (IsNan(TabNum))
		TabNum = 3
	endif
	String TabStr = "_"+num2str(TabNum)
	String SetupTabStr = TabStr+"9"
	String SetUpBaseName = GraphStr[0,strlen(GraphStr)-6]+"Bit_"
	
	String MakeTitle = "", MakeName = "", SetupName = ""
	Variable CurrentTop = 10
	if (Var == 0)		//MasterPanel
		CurrentTop = 40
		MakeTitle = "Make Litho Bitmap Panel"
		MakeName = GraphStr+"Button"+TabStr
		Enab = 1		//hide the controls, tabfunc will clear us up.
		GraphStr = ARPanelMasterLookup(GraphStr)
	elseif (Var == 1)	
		CurrentTop = 10
		MakeTitle = "Make Litho Panel"
		MakeName = ARPanelMasterLookup(GraphStr)+Tabstr
		Enab = 0
	endif
	SetupName = GraphStr+"Setup"+TabStr


	String ParmName, ParmName0, ParmName1, ParmName2
	Variable Mode, GroupBoxTop

	//mode checkbox
	ParmName = "LithoImageIsBiasMap"
	ControlName = ParmName+"Check"+TabStr
	HelpName = "Velocity_Or_Bias"+TabStr
	Mode = GV(ParmName)
	if (2^Bit & Control1Bit)
		MakeCheckbox(GraphStr,ControlName,"Bit Map Is Bias",LeftPos,CurrentTop,"LithoVelocityCheckFunc",Mode,0,Enab)

		UpdateButton(GraphStr,HelpName,"?",15,15,HelpPos,CurrentTop,HelpFunc,DisableHelp)
		UpdateCheckbox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",2^bit & oldControl1Bit,0,Enab)

		CurrentTop += StepSize

	else
		SimpleShowControl(GraphStr,ControlName+";"+HelpName+";",1)
	endif
	Bit += 1
	LeftPos = Margin
	
	

	//Load Image Button
	ControlName = "VelocityLoadImage"+"Button"+TabStr
	HelpName = "Velocity_Load_Image"+TabStr
	if (2^Bit & Control1Bit)
		MakeButton(GraphStr,ControlName,"Load Image",120,ButtonHeight,LeftPos,CurrentTop,"InitVelocityScan",Enab)

		UpdateButton(GraphStr,HelpName,"?",15,15,HelpPos,CurrentTop,HelpFunc,DisableHelp)
		UpdateCheckbox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",2^bit & oldControl1Bit,0,Enab)

		CurrentTop += StepSize

	else
		SimpleShowControl(GraphStr,ControlName+";"+HelpName+";",1)
	endif
	Bit += 1
	LeftPos = Margin


	ParmName = "LithoVelocityMin"
	ControlName = ParmName+"SetVar"+TabStr
	ParmName0 = "LithoBiasMin"
	ControlName0 = ParmName0+"SetVar"+TabStr
	HelpName = "Velocity_Min_Velocity"+TabStr
	if (2^Bit & Control1Bit)
		MakeSetVar(GraphStr,ControlName,ParmName,"","ARSetVarFunc","",LeftPos,CurrentTop,BodyWidth+80,bodyWidth,TabNum,FontSize,Enab)
		MakeSetVar(GraphStr,ControlName0,ParmName0,"","LithoBiasSetVarFunc","",LeftPos,CurrentTop,BodyWidth+80,bodyWidth,TabNum,FontSize,Enab)

		UpdateButton(GraphStr,HelpName,"?",15,15,HelpPos,CurrentTop,HelpFunc,DisableHelp)
		UpdateCheckbox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",2^bit & oldControl1Bit,0,Enab)

		CurrentTop += StepSize

	else
		SimpleShowControl(GraphStr,ControlName+";"+HelpName+";",1)
	endif
	Bit += 1
	LeftPos = Margin



	ParmName = "LithoVelocityMax"
	ControlName = ParmName+"SetVar"+TabStr
	ParmName0 = "LithoBiasMax"
	ControlName0 = ParmName0+"SetVar"+TabStr
	HelpName = "Velocity_Max_Velocity"+TabStr
	if (2^Bit & Control1Bit)
		MakeSetVar(GraphStr,ControlName,ParmName,"","ARSetVarFunc","",LeftPos,CurrentTop,BodyWidth+80,bodyWidth,TabNum,FontSize,Enab)
		MakeSetVar(GraphStr,ControlName0,ParmName0,"","LithoBiasSetVarFunc","",LeftPos,CurrentTop,BodyWidth+80,bodyWidth,TabNum,FontSize,Enab)

		UpdateButton(GraphStr,HelpName,"?",15,15,HelpPos,CurrentTop,HelpFunc,DisableHelp)
		UpdateCheckbox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",2^bit & oldControl1Bit,0,Enab)

		CurrentTop += StepSize

	else
		SimpleShowControl(GraphStr,ControlName+";"+HelpName+";",1)
	endif
	Bit += 1
	LeftPos = Margin

	
	//Do Scan Button
	ControlName = "VelocityDoScan"+"Button"+TabStr
	ControlName0 = "VelocityStopScan"+"Button"+TabStr
	HelpName = "Velocity_Do_Scan"+TabStr
	if (2^Bit & Control1Bit)
		MakeButton(GraphStr,ControlName,"Do Scan",80,ButtonHeight,LeftPos,CurrentTop,"InitVelocityScan",Enab)
		LeftPos += 105
		MakeButton(GraphStr,ControlName0,"Stop Scan",80,ButtonHeight,LeftPos,CurrentTop,"InitVelocityScan",Enab)

		UpdateButton(GraphStr,HelpName,"?",15,15,HelpPos,CurrentTop,HelpFunc,DisableHelp)
		UpdateCheckbox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",2^bit & oldControl1Bit,0,Enab)

		CurrentTop += StepSize

	else
		SimpleShowControl(GraphStr,ControlName+";"+ControlName0+";"+HelpName+";",1)
	endif
	Bit += 1
	LeftPos = Margin

	ControlName = MakeName
	HelpName = "Make_Other"+TabStr
	if (2^Bit & Control1Bit)
		UpdateButton(GraphStr,ControlName,MakeTitle,160,ButtonHeight,LeftPos,CurrentTop,"MakePanelProc",Enab)

		UpdateButton(GraphStr,HelpName,"?",15,15,HelpPos,CurrentTop,HelpFunc,DisableHelp)
		UpdateCheckbox(GraphStr,SetUpBaseName+num2str(bit)+SetUpTabStr,"Show?",SetupLeft,CurrentTop,"NoShowFunc",2^bit & oldControl1Bit,0,Enab)

		CurrentTop += StepSize

	else
		SimpleShowControl(GraphStr,ControlName+";"+HelpName+";",1)
	endif
	Bit += 1
	LeftPos = Margin



	ControlName = SetupName
	HelpName = "Setup"+TabStr
	UpdateButton(GraphStr,ControlName,"Setup",ButtonWidth,ButtonHeight,LeftPos,CurrentTop,SetupFunc,Enab)

	UpdateButton(GraphStr,HelpName,"?",15,15,HelpPos,CurrentTop,HelpFunc,DisableHelp)

	CurrentTop += StepSize

	LeftPos = Margin
	PanelParms[%CurrentBottom][0] = CurrentTop



End //MakeLithoBitMapPanel


Function PlanE(GreyImage,FastScanWave,SlowScanWave,MinVel,MaxVel,ScanSize)
	Wave GreyImage
	Wave FastScanWave, SlowScanWave
	Variable MinVel, MaxVel
	Variable ScanSize
	
	
	Redimension/N=(0) FastScanWave,SlowScanWave
	
	
	if (DimSize(GreyImage,2) == 3)
		ImageTransform rgb2gray GreyImage
		Wave TempWave = M_RGB2Gray
		Duplicate/O TempWave,GreyImage
		KillWaves/Z TempWave
	elseif (DimSize(GreyImage,2) != 0)
		Redimension/N=(-1,-1,0) GreyImage
	endif
	if ((WaveType(GreyImage) != 72))
		Redimension/B/U GreyImage		//unsigned byte
	endif
	
	//flip it, so that black is high
	//WaveStats/Q GreyImage
	FastOp GreyImage = (-1)*GreyImage
	//FastOp GreyImage = (V_Max+1)+GreyImage		//starts at 1 now.
	FastOp GreyImage = (255)+GreyImage
	
	
	
	//WaveStats/Q GreyImage
	Variable GreyMin = 0
	Variable GreyMax = 255
	
	
	Variable GreyScale = (MaxVel-MinVel)/(GreyMax-GreyMin)
	Variable GreyOffset = MinVel
	
	
	
	
	Variable A, ScanPoints = DimSize(GreyImage,0)
	Variable B, ScanLines = DimSize(GreyImage,1)
	
	Variable Velocity, nop, Secs
	Variable DistPerPoint = ScanSize/ScanPoints
	Variable LastPoint
	Variable XLVDTSens = GV("XLVDTSens")
	Variable YLVDTSens = GV("YLVDTSens")
	Variable FastScanSize = ScanSize/abs(XLVDTSens)
	Variable SlowScanSize = ScanSize/abs(YLVDTSens)
	
	
	//Make sure the minTime has 2 points.
	
	Variable PPS = 2*MaxVel/DistPerPoint
	if (PPS > 50000)
		Print "Can not do more than 50000 points per second in function: "+GetFuncName()
		Print "see function: "+GetCallingFuncName(2)
		DoWindow/H
		return(0)
	endif
	Variable InterpVal = round(cMasterSampleRate/PPS)
	PPS = cMasterSampleRate/InterpVal
	Variable TurnPoints = 50
	
	


	//Make a bunch of waves for internal use...
	Wave TempWave0 = $LocalWave(0)
	Wave TempWave1 = $LocalWave(0)
	Wave TempWave2 = $LocalWave(0)
	Wave TempWave3 = $LocalWave(0)
	
	
	Wave VelWave = $LocalWave(ScanPoints)
	Wave DistWave = $LocalWave(ScanPoints+1)
	Wave TimeWave = $LocalWave(ScanPoints+1)
	
	Wave InterpDist = $LocalWave(0)
	Wave InterpTime = $LocalWave(0)
	Wave TempWave9 = $LocalWave(0)
	
	
	DistWave = P*DistPerPoint
	
	
	Variable LastLineStart, LastLineStop
	Variable IsTrace

	for (B = 0;B < ScanLines;B += 1)
		IsTrace = !IsTrace

		//Velocity, meters / sec
		VelWave = GreyImage[P][B]*GreyScale+GreyOffset
		TimeWave[1,Dimsize(TimeWave,0)-1] = DistPerPoint/VelWave[P-1]
		Integrate TimeWave
		
		
		nop = round(TimeWave[DimSize(TimeWave,0)-1]*PPS)
		if (!B)
			LastLineStart = 0
			LastLineStop = nop
		endif
		
		
		InterpolateFunc(nop,1,InterpTime,InterpDist,TimeWave,DistWave)
		FastOP InterpDist = (1/abs(XLVDTSens))*InterpDist		//Vs

		if (!IsTrace)
			Redimension/N=(nop) TempWave9
			TempWave9[] = InterpDist[nop-P-1]
			FastOp InterpDist = TempWave9
			//flip the wave left to right to get the time correct.
		endif
		



		LastPoint = max(DimSize(FastScanWave,0)-1,0)
		InsertPoints/M=0 LastPoint,nop,FastScanWave,SlowScanWave
		FastScanWave[LastPoint+1,LastPoint+nop] = InterpDist[P-LastPoint-1]
		SlowScanWave[LastPoint+1,LastPoint+nop] = B*SlowScanSize/(ScanLines-1)

				
		
		if (B+1 < ScanLines)
			InsertPoints/M=0 DimSize(FastScanWave,0),TurnPoints,FastScanWave,SlowScanWave
		endif
		
		
		if (B)
			MakeCap9(FastScanWave,LastLineStop-1,LastPoint+1,TempWave0,TempWave1,TempWave2,TempWave3)
			MakeCap9(SlowScanWave,LastLineStop-1,LastPoint+1,TempWave0,TempWave1,TempWave2,TempWave3)
			LastLineStop = LastPoint+Nop
			LastLineStart = LastPoint
		endif
		

	endfor
	
	FastOP FastScanWave = (-ScanSize/2/abs(XLVDTSens))+FastScanWave
	FastOp SlowScanWave = (-ScanSize/2/abs(YLVDTSens))+SlowScanWave
	
	KillWaves TempWave0,TempWave1,TempWave2,TempWave3
	KillWaves VelWave,DistWave,TimeWave,InterpDist,InterpTime
	KillWaves TempWave9
	
	return(InterpVal)
End //PlanE


Function BufferScan(FastWave,SlowWave,InterpVal)
	Wave FastWave, SlowWave
	Variable InterpVal
	
	//Our job is to take the waves given and start scanning....
	//well we are to setup event 0 so that it will start scanning
	//but we reserve the right to use events 1 and 2
	//we will also use all output banks.
	//set event 1, and then set event 0 immediatly after to start scanning.
	
	String ErrorStr = ""
	ErrorStr += num2str(td_WriteString("Event.1","Clear"))+","
	ErrorStr += num2str(td_WriteString("Event.2","Clear"))+","
	ErrorStr += num2str(td_WriteString("Event.0","Clear"))+","
	ErrorStr += num2str(td_StopOutWaveBank(-1))+","
	
	
	
	String DataFolder = GetDF(GetFuncName())
	BuildDataFolder(DataFolder)
	
	
	//Make all the temp waves.
	//and take a copy of the real thing....
	
	
	
	Duplicate/O FastWave,$DataFolder+"FastWave"
	Wave FastWave = $DataFolder+"FastWave"
	Duplicate/O SlowWave,$DataFolder+"SlowWave"
	Wave SlowWave = $DataFolder+"SlowWave"
	Wave FastA = $InitOrDefaultWave(DataFolder+"FastA",0)
	Wave FastB = $InitOrDefaultWave(DataFolder+"FastB",0)
	Wave SlowA = $InitOrDefaultWave(DataFolder+"SlowA",0)
	Wave SlowB = $InitOrDefaultWave(DataFolder+"SlowB",0)
	Wave DummyWave = $InitOrDefaultWave(DataFolder+"DummyWave",0)
	
	Wave EvenWave = $InitOrDefaultWave(DataFolder+"EvenWave",2)
	Wave OddWave = $InitOrDefaultWave(DataFolder+"OddWave",2)
	Redimension/N=(2) EvenWave,OddWave
	SetDimLabel 0,0,$"Event.1",EvenWave
	SetDimLabel 0,1,$"Event.2",EvenWave
	EvenWave[0] = 1
	EvenWave[1] = 0
	SetDimLabel 0,0,$"Event.2",OddWave
	SetDimLabel 0,1,$"Event.1",OddWave
	OddWave[0] = 1
	OddWave[1] = 0
	
	Variable nop = DimSize(FastWave,0)
	Variable ChunkSize = 80000
	if (nop < 87000)
		ChunkSize = nop
	elseif (nop < 87000*2)
		ChunkSize = ceil(nop/2)
	endif
	
	Redimension/N=(ChunkSize) FastA, FastB, SlowA, SlowB, DummyWave
	
	//store our scan parms
	String ScanParmList = "ChunkSize;InterpVal;NumOfChunks;ChunkCount;"
	Wave ScanParms = $InitOrDefaultWave(DataFolder+"ScanParms",ItemsInList(ScanParmList,";"))
	SetDimLabels(ScanParms,ScanParmList,0)
	ScanParms[%ChunkSize][0] = ChunkSize
	ScanParms[%InterpVal][0] = InterpVal
	ScanParms[%NumOfChunks][0] = Ceil(nop/ChunkSize)
	ScanParms[%ChunkCount][0] = 2
	
	
	
	FastA = FastWave[P]
	FastB = FastWave[P+ChunkSize]
	SlowA = SlowWave[P]
	SlowB = SlowWave[P+ChunkSize]
	
	
	//pull out the first few chunks
	
	if (ScanParms[%NumOfChunks][0] > 1)
		
		ErrorStr += num2str(td_SetSwapper("0",evenWave,oddWave))+","
		ErrorStr += num2str(td_xSetOutWave(0,"0,0","Output.Dummy",DummyWave,InterpVal))+","
		ErrorStr += num2str(td_WriteString("OutWave0StatusCallback","BufferScanCallback(0)"))+","
		ErrorStr += num2str(td_xSetOutWavePair(1,"1","$outputXLoop.Setpoint",FastA,"$outputYLoop.Setpoint",SlowA,InterpVal))+","
		ErrorStr += num2str(td_xSetOutWavePair(2,"2","$outputXLoop.Setpoint",FastB,"$outputYLoop.Setpoint",SlowB,InterpVal))+","
		
	else
		ErrorStr += num2str(td_xSetOutWavePair(1,"0","$outputXLoop.Setpoint",FastA,"$outputYLoop.Setpoint",SlowA,InterpVal))+","
	endif
	
	ARReportError(ErrorStr)
	

End //BufferScan


Function BufferScanCallback(IsEven)
	Variable IsEven
	
	
	String DataFolder = GetDF("BufferScan")
	Wave FastWave = $DataFolder+"FastWave"
	Wave SlowWave = $DataFolder+"SlowWave"
	Wave ScanParms = $DataFolder+"ScanParms"
	
	
	
	Variable ChunkSize = ScanParms[%ChunkSize][0]
	Variable InterpVal = ScanParms[%InterpVal][0]
	Variable NumOfChunks = ScanParms[%NumOfChunks][0]
	Variable ChunkCount = ScanParms[%ChunkCount][0]
	
	String FastName = ""
	String SlowName = ""
	Variable Bank
	String Event
	
	if (IsEven)
		FastName = "FastB"
		SlowName = "SlowB"
		Bank = 2
		Event = "2"
	else
		FastName = "FastA"
		SlowName = "SlowA"
		Bank = 1
		Event = "1"
	endif
	
	Wave SmallFast = $DataFolder+FastName
	Wave SmallSlow = $DataFolder+SlowName
	
	
	Variable StartIndex = ChunkCount*ChunkSize
	if (ChunkCount+1 == NumOfChunks)
		ChunkSize = DimSize(FastWave,0)-StartIndex
		Redimension/N=(ChunkSize) SmallFast, SmallSlow
	elseif (ChunkCount == NumOfChunks)
		return(0)		//we are done
	endif
	SmallFast = FastWave[P+StartIndex]
	SmallSlow = SlowWave[P+StartIndex]
	
	ScanParms[%ChunkCount][0] = ChunkCount+1
	
	String ErrorStr = ""
	ErrorStr += num2str(td_xSetOutWavePair(Bank,Event,"$outputXLoop.Setpoint",SmallFast,"$outputYLoop.Setpoint",SmallSlow,InterpVal))+","
	
	ErrorStr += num2str(td_WriteString("OutWave0StatusCallback",GetFuncName()+"("+num2str(!IsEven)+")"))+","
	
	
	
	ARReportError(ErrorStr)
	
End //BufferScanCallback


Function VelocityBufferScan(FastWave,SlowWave,InterpVal)
	Wave FastWave, SlowWave
	Variable InterpVal


	Wave RVW = $GetDF("Variables")+"RealVariablesWave"
	Variable xOffset = RVW[%XOffset][0]
	Variable yOffset = RVW[%YOffset][0]
	Variable xLVDTSens = GV("XLVDTSens")
	Variable yLVDTSens = GV("YLVDTSens")
	
	Variable xScanOffset = (GV("XLVDTOffset")+xOffset/abs(xLVDTSens))
	Variable yScanOffset = (GV("YLVDTOffset")+yOffset/abs(yLVDTSens))
	
	

	String ErrorStr = ""
	ErrorStr += num2str(ir_StopPISLoop(NaN,LoopName="outputXLoop"))+","
	ErrorStr += num2str(ir_StopPISLoop(NaN,LoopName="outputYLoop"))+","
	//turn the scan engine off
	ErrorStr += num2str(td_WriteString("ScanEngine.XDestination","Output.Dummy"))+","
	ErrorStr += num2str(td_WriteString("ScanEngine.YDestination","Output.Dummy"))+","
	


	Struct ARFeedbackStruct FB
	ARGetFeedbackParms(FB,"outputX")
	FB.PGain = 0
	FB.SGain = 0
	IR_WritePIDSloop(FB)

	ARGetFeedbackParms(FB,"outputY")
	FB.PGain = 0
	FB.SGain = 0
	IR_WritePIDSloop(FB)

	
	//setup the Waves....
	
	//stop before setting the out waves
	ErrorStr += num2str(td_StopOutWaveBank(-1))+","
//	ErrorStr += num2str(td_WriteString("Event.0","Clear")


	FastOp FastWave = (xScanOffset)+FastWave
	FastOP SlowWave = (yScanOffset)+SlowWave

	BufferScan(FastWave,SlowWave,InterpVal)

	
	
	
	//then ramp to the begining
	
	
	ErrorStr += num2str(td_SetRamp(1,"$outputXLoop.Setpoint",0,FastWave[0],"$outputYLoop.Setpoint",0,SlowWave[0],"",0,0,"td_WriteString(\"Event.1\",\"Once\");td_WriteString(\"Event.0\",\"Set\")"))+","
	
	FastOp FastWave = (-xScanOffset)+FastWave
	FastOP SlowWave = (-yScanOffset)+SlowWave

	ARReportError(ErrorStr)
	return(0)

End //VelocityBufferScan

//////////////////////////////////////////////////////////////////////////////////
//////////////					End Litho Velocity Functions
//////////////////////////////////////////////////////////////////////////////////




Function MakeLithoChannelPanel(Var)
	Variable Var
	
	
	String WindowsFolder = GetDF("Windows")
	String GraphStr = GetFuncName()
	GraphStr = GraphStr[4,Strlen(GraphStr)-1]
	Wave PanelParms = $WindowsFolder+GraphStr+"Parms"
	

	Variable HelpPos = PanelParms[%HelpPos][0]			//is hijacked later.
	Variable SetUpLeft = PanelParms[%SetupLeft][0]		//is hijacked later
	Variable ControlBit = PanelParms[%Control1Bit][0]
	Variable OldControlBit = PanelParms[%oldControl1Bit][0]
	Variable Margin = PanelParms[%Margin][0]
	Variable ButtonWidth = PanelParms[%ButtonWidth][0]
	Variable ButtonHeight = PanelParms[%ButtonHeight][0]
	Variable Red = PanelParms[%RedColor][0]
	Variable Blue = PanelParms[%BlueColor][0]
	Variable Green = PanelParms[%GreenColor][0]
	Variable StepSize = 30
	Variable BodyWidth = PanelParms[%BodyWidth][0]
	Variable SetVarWidth = NaN
	
	
	Variable Bit = 0
	String HelpFunc = "ARHelpFunc"
	String SetupFunc = "ARSetupPanel"
	Variable Enab = 0
	Variable DisableHelp = 0
	Variable LeftPos = PanelParms[%FirstSetVar][0]
	Variable OrgLeftPos = LeftPos
	Variable FontSize = 12
	String ControlName, ControlName0, ControlName1, ControlName2, ControlName3
	String HelpName
	Variable WhichBit = 1
	String HighName
		
	Variable TabNum = ARPanelTabNumLookup(GraphStr)
	String TabStr = "_"+num2str(TabNum)
	String SetupTabStr = TabStr+"9"
	String SetUpBaseName = GraphStr[0,strlen(GraphStr)-6]+"Bit_"
	
	String MakeTitle = "", MakeName = "", SetupName = "", OtherMakeName = "", OtherGraphStr = ""
	Variable CurrentTop = 10
	if (Var == 0)		//MasterPanel
		CurrentTop = 40
		MakeTitle = "Litho Channel Panel"
		MakeName = GraphStr+"Button"+TabStr
		OtherMakeName = ARPanelMasterLookup(GraphStr)+Tabstr
		Enab = 1		//hide the controls, tabfunc will clear us up.
		OtherGraphStr = GraphStr
		GraphStr = ARPanelMasterLookup(GraphStr)
	elseif (Var == 1)	
		CurrentTop = 10
		MakeTitle = "Make Unknown Panel"
		OtherGraphStr = ARPanelMasterLookup(GraphStr)
		MakeName = OtherGraphStr+Tabstr
		OtherMakeName = GraphStr+"Button"+TabStr
		Enab = 0
	endif



	String ParmName, ParmName0, ParmName1, ParmName2, ParmName3, ControlList
	
	ParmName = "LithoChannel"
	ControlName = ParmName+"Title"+TabStr
	HelpName = "Litho_Channels"+TabStr
	SetupName = SetUpBaseName+num2str(bit)+SetUpTabStr
	

	//TitleBox
	if (2^Bit & ControlBit)
		MakeTitleBox(GraphStr,ControlName,"ZLVDT and Deflection are always collected",30,CurrentTop,NaN,NaN,NaN,Enab,FontSize=FontSize)
	
		UpdateButton(GraphStr,HelpName,"?",15,15,HelpPos,CurrentTop,HelpFunc,DisableHelp)
		UpdateCheckbox(GraphStr,SetupName,"Show?",SetupLeft,CurrentTop,"NoShowFunc",2^bit & oldControlBit,0,Enab)

		CurrentTop += StepSize

	endif
	Bit += 1
	LeftPos = OrgLeftPos
	
	String TitleList = "A ADC;B ADC & 32 bit bank;No ADC;"
	Variable A, nop = ItemsInList(TitleList,";")
	for (A = 0;A < nop;A += 1)
		ParmName = "LithoChannel"+num2str(A)
		ControlName = ParmName+"PopUp"+TabStr
		HelpName = "Litho_Channel_"+num2str(A)+TabStr
		SetUpName = SetUpBaseName+num2str(bit)+SetUpTabStr
		
		//Channel Popup
		if (2^Bit & ControlBit)
			MakePopup(GraphStr,ControlName,StringFromList(A,TitleList,";"),LeftPos,CurrentTop,"ARPopFunc","GetLithoChannels("+num2str(A)+")",GV(ParmName),Enab,BodyWidth=BodyWidth,FontSize=FontSize)
		
			UpdateButton(GraphStr,HelpName,"?",15,15,HelpPos,CurrentTop,HelpFunc,DisableHelp)
			UpdateCheckbox(GraphStr,SetupName,"Show?",SetupLeft,CurrentTop,"NoShowFunc",2^bit & oldControlBit,0,Enab)
	
			CurrentTop += StepSize
	
		endif
		Bit += 1
		LeftPos = OrgLeftPos
	
	endfor
	
	
	MakeButton(GraphStr,MakeName,MakeTitle,130,ButtonHeight,Margin-15,CurrentTop,"MakePanelProc",Enab)
	MakeButton(GraphStr,GraphStr+"Setup"+TabStr,"Setup",ButtonWidth,ButtonHeight,LeftPos+45,CurrentTop,"ARSetupPanel",Enab)
	MakeButton(GraphStr,"Setup"+tabStr,"?",15,15,HelpPos,CurrentTop+1,"ARHelpFunc",DisableHelp)
	CurrentTop += 25
	
	
	
	PanelParms[%CurrentBottom][0] = currentTop		//save the bottom position of the controls
	
	
	
	
End //MakeLithoChannelPanel



Function/S GetLithoChannels(ChanNum)
	Variable ChanNum
	
	
	String Output = ""
	String UserList = MakeValueStringList(2,0)
	userList = ListMultiply("UserIn",userList,";")
	
	switch (ChanNum)
		case 0:
			Output = "Lateral;"+UserList
			break
			
		case 1:
			Output = "Current;Current2;Lateral;"+UserList
			break

		case 2:
			break
			
	endswitch
	
	
	Output += "Amp;Phase;XLVDT;YLVDT;"
	return(output)
	
End //GetLithoChannels



Function LithoVelocityCheckFunc(CtrlName,Checked)
	String CtrlName
	Variable Checked
	
	
	ARCheckFunc(CtrlName,Checked)
	String ControlName
	
	
	GhostLithoBitMapPanel()
	
//	
//	String VelStr = StringFromList(Checked,"Velocity;Bias;",";")
//	
//	ControlName = 
//	UpdateAllControls(ControlName,"Max "+VelStr,"","")
//	ControlName = "LithoVelocityMinSetVar_3"
//	UpdateAllControls(ControlName,"Min "+VelStr,"","")
	
	
	
End //LithoVelocityCheckFunc



Function GhostLithoBitMapPanel()

	Variable Enab = GV("LithoImageIsBiasMap")

	String ControlList = ""
	
	String ShowList = ""
	String HideList = ""
	String TitleList = ""
	
	
	ControlList = "LithoVelocityMaxSetVar_3;LithoVelocityMinSetVar_3;"
	if (Enab)
		ShowList = "LithoBiasMaxSetVar_3;LithoBiasMinSetVar_3;"
		HideList = ControlList
		TitleList = "Max Bias;Min Bias;"
	else
		HideList = "LithoBiasMaxSetVar_3;LithoBiasMinSetVar_3;"
		ShowList = ControlList
		TitleList = "Max Velocity;Min Velocity;"
	endif
	
	ButtonSwapper(ShowList,HideList,TitleList)

End //GhostLithoBitMapPanel


Function ARScaleLithoBias()
	String DataFolder = cLithoBitMapFolder
	DataFolder = UpDir(DataFolder)+":LithoBias:"
	if (!DataFolderExists(DataFolder))
		return(0)
	endif
	
	Wave/Z GreyImage = $DataFolder+"M_RGB2Gray"
	if (!WaveExists(GreyImage))
		return(0)
	endif
	
	Variable NewMin = GV("LithoBiasMin")
	Variable NewMax = GV("LithoBiasMax")
	Variable OldMin = WaveMin(GreyImage)
	Variable OldMax = WaveMax(GreyImage)
	
	
	Duplicate/O GreyImage,$DataFolder+"BiasMap"
	Wave BiasMap = $DataFolder+"BiasMap"
	
	
	Variable Scale, Offset
	Scale = (NewMax-NewMin)/(OldMax-OldMin)
	Offset = NewMin-OldMin*Scale
	FastOp BiasMap = (Scale)*BiasMap+(Offset)
	SetScale d,0,0,"V",BiasMap
	SetScale/P x,0,GV("ScanSize")/DimSize(BiasMap,0),"m",BiasMap
	SetScale/P Y,0,GV("ScanSize")/DimSize(BiasMap,1),"m",BiasMap
	
//	Make/O/N=(128*2.5,130) $DataFolder+"ImageDrive"
//	Wave ImageDrive = $DataFolder+"ImageDrive"
//	
//	if (GV("ScanDown"))
//		ImageDrive[16,16+127][1,128] = BiasMap[p-16][q-1]
//	else
//		ImageDrive[16,16+127][1,128] = BiasMap[p-16][128-q]
//	endif
//	ImageDrive[0,15][] = 0
//	ImageDrive[16+128,320][] = 0
	
	

End //ARScaleLithoBias


Function LithoBiasSetVarFunc(CtrlName,VarNum,VarStr,VarName)
	String Ctrlname
	Variable VarNum
	String VarStr
	String VarName
	
	
	ARSetVarFunc(CtrlName,VarNum,VarStr,VarName)
	
	ARScaleLithoBias()
	
End //LithoBiasSetVarFunc
	
	
Function BiasBitMapGraphFunc()
	String GraphStr = "BiasMapGraph"
	DoWindow/F $GraphStr
	if (V_Flag)
		return(0)
	endif
	
	String DataFolder = cLithoBitMapFolder
	DataFolder = UpDir(DataFolder)+":LithoBias:"
	if (!DataFolderExists(DataFolder))
		return(0)
	endif
	
	Wave/Z BiasMap = $DataFolder+"BiasMap"
	if (!WaveExists(BiasMap))
		return(0)
	endif
	
	
	
	Display /W=(24,46.4,324.6,288.8)/K=1 /N=$GraphStr
	AppendImage BiasMap
	SetAxis/A/R left
	ModifyImage BiasMap ctab= {*,*,Grays,0}
	ModifyGraph margin(left)=18,margin(bottom)=18,margin(top)=14,margin(right)=72,width={Plan,1,bottom,left}
	ModifyGraph mirror=2
	ModifyGraph nticks=4
	ModifyGraph minor=1
	ModifyGraph fSize=8
	ModifyGraph standoff=0
	ModifyGraph tkLblRot(left)=90
	ModifyGraph btLen=3
	ModifyGraph tlOffset=-2
	ColorScale/C/N=text0/X=104.72/Y=0.56 image=BiasMap
End

function UpdateImageWrite(scanLines,scanPoints,decimation,scanDown,lithoBiasOff, whichCall)
	variable scanLines, scanPoints, decimation, scanDown, lithoBiasOff, whichCall

	variable modNum, checkNum, sectionCount
	if (scanLines == 256)
		modNum = 129
		checkNum = 64
	elseif (scanLines == 512)
		modNum = 65
		checkNum = 32
	else
		return 0
	endif
	NVAR ImageUpdateDone = root:Packages:MFP3D:Main:ImageUpdateDone
	variable lineCount = td_ReadValue("LinenumOutWave0")
	sectionCount = floor(lineCount/modNum)
	wave ImageDrive = root:Packages:MFP3D:Main:ImageDrive
	wave Image = root:Packages:MFP3D:Main:Image
	String ErrorStr = ""
	String WeDriveThis = ""
	Struct ARTipHolderParms TipParms
	ARGetTipParms(TipParms)
	if (TipParms.IsOrca)
		WeDriveThis = "SurfaceBias"		//can't believe this would work.
	elseif (TipParms.IsDiffDrive)
		WeDriveThis = "TipHeaterDrive"
	else
		WeDriveThis = "TipBias"
	endif
	
	
	if (whichCall)
		
		if (scanDown)
			ImageDrive[][checkNum,modNum-1] = Image[scanPoints*19/8-0-p][q+(sectionCount*modNum)-1]
		else
			ImageDrive[][checkNum,modNum-1] = Image[scanPoints*19/8-0-p][scanLines-(sectionCount*modNum)-q-1+1]
		endif
		ImageDrive[0,scanPoints*11/8-0] = lithoBiasOff
		ImageDrive[scanPoints*19/8+1,scanPoints*20/8-1] = lithoBiasOff
		
		ImageUpdateDone = 0
		
	elseif ((!ImageUpdateDone) && (mod(lineCount,modNum) > checkNum))
	
		if (scanDown)
			ImageDrive[][0,checkNum-1] = Image[scanPoints*19/8-0-p][q+((sectionCount+1)*modNum)-1]
		else
			ImageDrive[][0,checkNum-1] = Image[scanPoints*19/8-0-p][scanLines-((sectionCount+1)*modNum)-q-1+1]
		endif
		ImageDrive[0,scanPoints*11/8-0] = lithoBiasOff
		ImageDrive[scanPoints*19/8+1,scanPoints*20/8-1] = lithoBiasOff

		ImageUpdateDone = 1

	endif


//	td_xSetOutWavePair(2,"update",WeDriveThis,ImageDrive,"Output.Dummy",ImageDrive,Decimation)		//k

	ErrorStr += num2str(td_XSetOutWave(2,"update,2",WeDriveThis,ImageDrive,Decimation))+","

	arreportError(ErrorStr)

end //UpdateImageWrite


function PrepareImageWrite(scanPoints,scanLines,scanDown)
	variable scanPoints, scanLines, scanDown
	
	if ((!(scanPoints == scanLines)) && ((scanPoints == 128) || (scanPoints == 256) || (scanPoints == 512)))
		DoAlert 0, "There has to be 128, 256, or 512 lines, and the points have to match."
		return 1
	endif
	
	string savedDataFolder = GetDataFolder(1)
	SetDataFolder root:Packages:MFP3D:Main
	Wave/Z OriginalImage = root:Packages:MFP3D:LithoBias:BiasMap
	If (!WaveExists(OriginalImage))
		DoAlert 0, "You have to load an image first."
		SetDataFolder savedDataFolder
		return 1
	endif
	Wave ImageDrive
	variable lithoBiasOff = GV("LithoBiasOff")
	variable/G ImageUpdateDone = 0
	
	if (!((DimSize(OriginalImage,0) == scanPoints) && (DimSize(OriginalImage,1) == scanLines)))

		ImageInterpolate/F={scanPoints/DimSize(OriginalImage,0),scanLines/DimSize(OriginalImage,1)} bilinear OriginalImage
		Duplicate/O M_InterpolatedImage Image		//make a copy of the interpolated image
		Redimension/N=(scanPoints,scanLines) Image

	else

		Duplicate/O OriginalImage Image

	endif

	
	switch (scanLines)
		
		case 128:
			Redimension/N=(128*2.5,130) ImageDrive
			
			break
			
		case 256:
			Redimension/N=(256*2.5,129) ImageDrive
			
			break
			
		case 512:
			Redimension/N=(512*2.5,65) ImageDrive
			
			break
		
		default:
			
			DoAlert 0, "There has to be 128, 256, or 512 lines, and the points have to match."
			SetDataFolder savedDataFolder
			return 1
			
			
	endswitch

	if (scanDown)
		ImageDrive = Image[scanPoints*19/8-0-p][q-1]
	else
		ImageDrive = Image[scanPoints*19/8-0-p][scanLines-q-1+1]
	endif
	ImageDrive[][0] = lithoBiasOff
	ImageDrive[0,scanPoints*11/8-0] = lithoBiasOff
	ImageDrive[scanPoints*19/8+1,scanPoints*20/8-1] = lithoBiasOff
	if (scanLines == 128)
		ImageDrive[][129] = lithoBiasOff
	endif
//ImageDrive = Image[p-16][q]
//ImageDrive[0,15] = 0
//ImageDrive[16+128,320] = 0
	return 0
	SetDataFolder savedDataFolder
end //PrepareImageWrite


Function CalcXYLithoWave(Data)
	Wave Data


	String RTFolder = GetDF("Litho")

	String DestFolder = GetWavesDataFolder(Data,1)


	Wave YLitho = $RTFolder+"YLitho"
	Wave XLitho = $RTFolder+"XLitho"

	Variable DestNop = DimSize(Data,0)
	Variable SrcNop = DimSize(YLitho,0)

	Duplicate/O YLitho,$RTFolder+"YDiff",$RTFolder+"XYLitho"
	Duplicate/O XLitho,$RTFolder+"XDiff"


	Wave YDiff = $RTFolder+"YDiff"
	Wave XDiff = $RTFolder+"XDiff"
	Wave XYLitho = $RTFolder+"XYLitho"


	String NoteStr = Note(Data)

	String Indexes = StringByKey("Indexes",NoteStr,":","\r",0)
	//we need to zap the nans.


	String NanIndexes = Find2(YDiff,"==",NaN)


	Variable A, nop = ItemsInList(NanIndexes,",")
	Variable Index = 0
	String IndexList = "-1,"
	for (A = nop-1;A >= 0;A -= 1)
		Index = str2num(StringFromList(A,NanIndexes,","))
		deletePoints/M=0 Index,1,YDiff,XDiff
	endfor
//print NanIndexes
	Variable LastIndex = -10
	for (A = 0;A < nop;A += 1)
		Index = str2num(StringFromList(A,NaNIndexes,","))
		if (Index-1 != LastIndex)		//this deals with groups which have 2 nans in a row.
			IndexList += num2str(Index-A-1)+","
		endif
		LastIndex = Index
	endfor

	Duplicate/O XDiff,$RTFolder+"XDiffOrg"
	Duplicate/O YDiff,$RTFolder+"YDiffOrg"
	Wave YDiffOrg = $RTFolder+"YDiffOrg"
	Wave XDiffOrg = $RTFolder+"XDiffOrg"
	Diff(XDiffOrg,XDiff)
	Diff(YDiffOrg,YDiff)

	//Differentiate YDiff
	//Differentiate XDiff
	redimension/N=(DimSize(YDiff,0)+1) XYLitho
	IndexList += num2str(DimSize(YDiff,0))+","
	XYLitho[1,] = sqrt(YDiff[P-1]^2+XDiff[P-1]^2)
	XYLitho[0] = 0

	Integrate XYLitho
//print IndexList
	//interpolate
	Variable StartIndex, StopIndex, OtherStart, OtherStop, OtherNop
	Wave DestWave = $InitOrDefaultWave(RTFolder+"RealXYLitho",0)
	Redimension/N=(0) DestWave
	nop = ItemsInList(IndexList,",")
	for (A = 1;A < nop;A += 1)
		StartIndex = Str2num(StringFromList(A-1,IndexList,","))+1
		StopIndex = Str2num(StringFromList(A,IndexList,","))
//print StartIndex, StopIndex
		Duplicate/O/R=[StartIndex,StopIndex] XYLitho,$RTFolder+"ShortXYLitho"
		DoUpdate
		Wave ShortWave = $RTFolder+"ShortXYLitho"
		OtherStart = Str2num(StringFromList(A-1,Indexes,","))
		if (OtherStart != 0)
			OtherStart += 1
		endif
		OtherStop = Str2Num(StringFromList(A,Indexes,","))
		OtherNop = OtherStop-OtherStart+1
		InterpolateFunc(OtherNop,1,$"",ShortWave,$"",ShortWave)
		InsertWave(DestWave,ShortWave,DimSize(DestWave,0))
	endfor



	Variable InsertIndex = FindDimLabel(Data,1,"XYDist")
	if (InsertIndex < 0)
		InsertIndex = DimSize(Data,1)
		InsertPoints/M=1 InsertIndex,1,Data
		SetDimLabel 1,InsertIndex,$"XYDist",Data
	endif
	Data[][InsertIndex] = DestWave[P]
//print DimSize(Data,0),DimSize(DestWave,0)

	//if I were to clean up....
	//but I don't see much point in doing that.
	//KillWaves/Z XYLitho,YDiff,XDiff,XDiffOrg,YDiffOrg,DestWave,ShortWave


End //CalcXYLithoWave



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////              Plotter Manager
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Function/S GetPMF()
	String Output = GetDF("PlotterManager")
	BuildDataFolder(output)
	return(output)

End //GetPMF


Function MakePlotterManagerPanel(Var)
	Variable Var		//not used
	
	String DataFolder = GetPMF()
	String GraphStr = cPlotterManagerName
	
	String InitFolder = "root:"
	
	InitPMWaves()		//lets make sure....
	
	Variable ScrRes = 72/ScreenResolution		//make a screen resolution compensator
	Variable TabNum = 0
	String TabStr = "_"+num2str(TabNum)
	String SetUpTabStr = TabStr+"9"
	String SetUpBaseName = "PlotterManagerBit_"
	String HelpFuncStr = "ARHelpFunc"
	
	
	String WinFolder = GetDF("Windows")
	Wave PanelParms = $WinFolder+"PlotterManagerPanelParms"

	Variable WindowLeft, WindowRight, WindowTop, WindowBottom, CurrentTop, Enab
	String SetupFunc = "", SetupName = ""

	WindowLeft = PanelParms[%WindowLeft][0]	//grab parameters for the window placement
	WindowTop = PanelParms[%WindowTop][0]
	WindowRight = PanelParms[%WindowRight][0]
	WindowBottom = PanelParms[%WindowBottom][0]
	CurrentTop = 10
	SetupFunc = "ARSetupPanel"
	SetupName = "PlotterManagerPanelSetup"+TabStr		//setup for this panel
	Enab = 0		//show the controls
	//MoveWindow/W=$GraphStr WindowLeft,WindowTop,WindowRight,WindowBottom
	
	Variable DisableHelp = 0					//do we have a help file yet?


	Variable HelpPos = PanelParms[%HelpPos][0]
	Variable Control1Bit = PanelParms[%Control1Bit][0]
	Variable OldControl1Bit = PanelParms[%oldControl1Bit][0]
	Variable SetUpLeft = PanelParms[%SetupLeft][0]
	Variable Margin = PanelParms[%Margin][0]
	Variable ListWidth = PanelParms[%ListWidth][0]
	Variable ListHeight = PanelParms[%ListHeight][0]
	Variable MinWidth = PanelParms[%MinWidth][0]
	Variable LeftPos = Margin
	Variable Red = PanelParms[%RedColor][0]
	Variable Green = PanelParms[%GreenColor][0]
	Variable Blue = PanelParms[%BlueColor][0]
	Variable ButtonWidth = PanelParms[%ButtonWidth][0]
	Variable ButtonHeight = PanelParms[%ButtonHeight][0]
	Variable Column0 = PanelParms[%Column0][0]
	Variable Column1 = PanelParms[%Column1][0]
	Variable Column2 = PanelParms[%Column2][0]
	Variable Column3 = PanelParms[%Column3][0]
	Variable SetVarWidth = PanelParms[%SetVarWidth][0]
	Variable BodyWidth = PanelParms[%BodyWidth][0]
	
	Variable FontSize = 12
	Variable IVN = NumberByKey("IGORVERS",IgorInfo(0),":",";")
	if (IVN < 5)
		String SavedDataFolder = GetDataFolder(1)
		SetDataFolder(DataFolder)
	endif
		
	
	String ControlName
	Variable bit = 0
	Wave ParmWave = $DataFolder+"ParmWave"
	Wave/T DescriptionWave = $DataFolder+"DescriptionWave"
	
	if (2^bit & Control1Bit)
		ControlName = "DataFolderPop"+TabStr
		MakePopup(GraphStr,ControlName,"Folder:",2,CurrentTop,"SetPMFolder","GetFolderTree(\"root:\",sps=\";\")",ParmWave[%Folder][0]+1,Enab)
		

//		MakeButton(GraphStr,"DataFolder"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
//		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
//		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
	
		CurrentTop += 27
	endif
	Bit += 1
	
	
	if (2^bit & Control1Bit)
		ControlName = "Set2CurrentButton"
		MakeButton(GraphStr,ControlName,"Set 2 Current",80,20,50,CurrentTop,"PMCurrentFolderFunc",Enab)

		MakeButton(GraphStr,"Set_2_Current"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
	
		CurrentTop += 25
	endif
	Bit += 1
	
	
	
	if (2^bit & Control1Bit)
		ControlName = "WaveListBox"+TabStr
		Wave/T DataList = $DataFolder+"DataList"
		ListBox $ControlName,win=$GraphStr,font="Arial",fsize=FontSize,mode=2,ListWave = DataList,disable=enab
		ListBox $ControlName,win=$GraphStr,size={ListWidth,ListHeight},Pos={50,CurrentTop},Proc=PlotterListFunc,SelRow=ParmWave[%Wave][0]

		
		MakeButton(GraphStr,"Wave_List"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
	
		CurrentTop += ListHeight+15
	endif
	Bit += 1


	if (2^bit & Control1Bit)
		ControlName = "MakeGraphButton"+TabStr
		MakeButton(GraphStr,ControlName,"Make Graph",ButtonWidth,ButtonHeight,LeftPos,CurrentTop,"DoPlotterFunc",Enab)
		
		LeftPos += ButtonWidth+Margin
		ControlName = "GraphNameSetVar"+TabStr
		SetVariable $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop},Size={BodyWidth,0},bodywidth=BodyWidth,Value=DescriptionWave[%Graph][0],Title=" "
		SetVariable $ControlName,win=$GraphStr,font="arial",Fsize=FontSize,proc=PlotterGraphNameFunc
		
		LeftPos += BodyWidth
		ControlName = "GraphNamePopup"+TabStr
		MakePopup(GraphStr,ControlName,"",LeftPos,CurrentTop-2,"SetPMGraphStr","GetPMGraphList()",0,Enab)
		
		
		
		MakeButton(GraphStr,"Make_Graph"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
	
		CurrentTop += 25
	endif
	Bit += 1
	LeftPos = Margin


	if (2^bit & Control1Bit)
		ControlName = "AppendCheck"+TabStr
		MakeCheckbox(GraphStr,ControlName,"Append",LeftPos,CurrentTop,"SetPMAppend",ParmWave[%Append][0],0,Enab)
	

		MakeButton(GraphStr,"Append_2_graph"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
	
		CurrentTop += 25
	endif
	Bit += 1

	if (2^bit & Control1Bit)
		ControlName = "RowIsData"+TabStr
		MakeCheckbox(GraphStr,ControlName,"Row=Data",LeftPos,CurrentTop,"SetPMRowData",ParmWave[%RowIsX][0],1,Enab)
	
		ControlName = "ColIsData"+TabStr
		MakeCheckbox(GraphStr,ControlName,"Col=Data",LeftPos,CurrentTop+15,"SetPMRowData",!ParmWave[%RowIsX][0],1,Enab)

		MakeButton(GraphStr,"Row_Data"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
	
		CurrentTop += 40
	endif
	Bit += 1

//	if (2^bit & Control1Bit)
//		ControlName = "ColIsData"+TabStr
//		MakeCheckbox(GraphStr,ControlName,"Col=Data",LeftPos,CurrentTop,"SetPMRowData",!ParmWave[%RowIsX][0],1,Enab)
//	
//
//		MakeButton(GraphStr,"Col_Data"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
//		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
//		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
//	
//		CurrentTop += 25
//	endif
//	Bit += 1
	
	
//	
//	if (2^bit & Control1Bit)
//		ControlName = "AxisNameSetVar"+TabStr
//		SetVariable $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop},Size={SetVarWidth,0},bodywidth=BodyWidth,Value=DescriptionWave[%Axis],Title="Axis Name"
//		SetVariable $ControlName,win=$GraphStr,font="arial",Fsize=FontSize
//		
//		
//		MakeButton(GraphStr,"Axis_Name"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
//		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
//		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
//	
//		CurrentTop += 0
//	endif
//	Bit += 1
//	LeftPos = Margin
	
	if (2^bit & Control1Bit)
		ControlName = "AxisNameSetVar"+TabStr
		SetVariable $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop},Size={SetVarWidth,0},bodywidth=BodyWidth,Value=DescriptionWave[%Axis][0],Title="Axis Name"
		SetVariable $ControlName,win=$GraphStr,font="arial",Fsize=FontSize,proc=PlotterGraphNameFunc
		
		
		MakeButton(GraphStr,"Axis_Name"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
	
		CurrentTop += 25
	endif
	Bit += 1
	LeftPos = Margin
	
	
	BodyWidth /= 2
	
	if (2^bit & Control1Bit)
		ControlName = "YIndexPop"+TabStr
		MakePopup(GraphStr,ControlName,"Y Wave",LeftPos,CurrentTop,"SetPlotterIndexFunc","PullOutPlotterAxes(0)",ParmWave[%YIndex][0],0)
		PopUpMenu $ControlName,win=$GraphStr,bodyWidth=90
		DoUpdate
		PopUpMenu $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop}		//Igor you fustrating me many times!.

		LeftPos += 145
		
		ControlName = "YIndexSetVar"+TabStr
		SetVariable $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop},Size={BodyWidth,0},bodywidth=BodyWidth,Value=ParmWave[%YIndex][0],Title=" "
		SetVariable $ControlName,win=$GraphStr,font="arial",Fsize=FontSize,proc=PlotterIndexFunc,Limits={-inf,inf,1}
		
		
		MakeButton(GraphStr,"Y_Index"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
	
		CurrentTop += 25
	endif
	Bit += 1
	LeftPos = Margin
	
	if (2^bit & Control1Bit)
		ControlName = "XIndexPop"+TabStr
		MakePopup(GraphStr,ControlName,"X Wave",LeftPos,CurrentTop,"SetPlotterIndexFunc","PullOutPlotterAxes(1)",ParmWave[%XIndex][0],0)
		PopUpMenu $ControlName,win=$GraphStr,bodyWidth=90
		DoUpdate
		PopUpMenu $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop}		//Igor you...!.

		LeftPos += 145
		
		ControlName = "XIndexSetVar"+TabStr
		SetVariable $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop},Size={BodyWidth,0},bodywidth=BodyWidth,Value=ParmWave[%XIndex][0],Title=" "
		SetVariable $ControlName,win=$GraphStr,font="arial",Fsize=FontSize,proc=PlotterIndexFunc,Limits={-inf,inf,1}
		
		
		MakeButton(GraphStr,"X_Index"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
	
		CurrentTop += 25
	endif
	Bit += 1
	LeftPos = Margin
	
	//BodyWidth *= 2
	SetVarWidth -= BodyWidth
	
	if (2^bit & Control1Bit)
		ControlName = "StartSetVar"+TabStr
		SetVariable $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop},Size={SetVarWidth,0},bodywidth=BodyWidth,Value=ParmWave[%Start][0],Title="Start"
		SetVariable $ControlName,win=$GraphStr,font="arial",Fsize=FontSize,Limits={-inf,inf,1}
		
		
		MakeButton(GraphStr,"Start"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
	
		CurrentTop += 25
	endif
	Bit += 1
	LeftPos = Margin


	if (2^bit & Control1Bit)
		ControlName = "StopSetVar"+TabStr
		SetVariable $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop},Size={SetVarWidth,0},bodywidth=BodyWidth,Value=ParmWave[%Stop][0],Title="Stop"
		SetVariable $ControlName,win=$GraphStr,font="arial",Fsize=FontSize,Limits={-inf,inf,1}
		
		
		MakeButton(GraphStr,"Stop"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,pos={SetupLeft,CurrentTop},font="Arial",fsize=12,title="Show?"
		CheckBox $SetUpBaseName+num2str(bit)+SetUpTabStr,win=$GraphStr,value= 2^bit && (2^bit & oldControl1Bit),proc=NoShowFunc,Disable=1
	
		CurrentTop += 25
	endif
	Bit += 1
	LeftPos = Margin
	
	
	MakeButton(GraphStr,SetupName,"Setup",80,20,LeftPos,CurrentTop,SetupFunc,Enab)
	MakeButton(GraphStr,"Plotter_Setup"+TabStr,"?",15,15,HelpPos,CurrentTop+1,HelpFuncStr,DisableHelp)
	CurrentTop += 25
	
	
	
	SetPMFolder("DataFolderPop"+TabStr,NaN,InitFolder)
	
	UpdatePlotterLabels()
	

	PanelParms[%CurrentBottom][0] = CurrentTop		//save the bottom position of the controls
	WindowBottom = WindowTop+((CurrentTop+5)*ScrRes)		//calculate where the bottom should be
	WindowRight = WindowLeft+((HelpPos+30)*ScrRes)			//calculate where the right side should be
	PanelParms[%WindowBottom][0] = WindowBottom
	PanelParms[%WindowRight][0] = WindowRight	
	if (IVN < 5)
		SetDataFolder(SavedDataFolder)
	endif

End //MakePlotterManagerPanel


Function InitPMWaves()
	String DataFolder = GETPMF()

	Wave/T DataList = $InitOrDefaultTextWave(DataFolder+"DataList",0)

//	Wave/T FolderList = $InitOrDefaultTextWave(DataFolder+"FolderList",0)

	Wave Parms = $InitOrDefaultWave(DataFolder+"ParmWave",0)
	Wave/T ParmDescript = $InitOrDefaultTextWave(DataFolder+"DescriptionWave",0)

	String ParmList = "Folder;Wave;Graph;RowIsX;Append;YIndex;XIndex;Axis;Start;Stop;"


	Variable A, nop = ItemsInList(ParmList,";")

	if (DimSize(Parms,0) != nop)
		Redimension/N=(nop) Parms
		SetDimLabels(Parms,ParmList,0)
		Parms[%Stop][0] = inf
		Parms[%Start][0] = 0
		Parms[%XIndex][0] = -1
		Parms[%YIndex][0] = 0
		Parms[%Append][0] = 1
		Parms[%RowIsX][0] = 0
	endif
	if (DimSize(ParmDescript,0) != nop)
		Redimension/N=(nop,2) ParmDescript
		SetDimLabels(ParmDescript,ParmList,0)
		SetDimLabels(ParmDescript,"Value;List;",1)
		ParmDescript[%Axis][0] = "Left"
		ParmDescript[%Folder][0] = "Root:"
		String DataName = StringFromList(0,ARWaveList(ParmDescript[%Folder][0],"*",";","TEXT:0,DIMS:2,"),";")
		ParmDescript[%Wave][0] = DataName
		Wave/Z Data = $ParmDescript[%Folder][0]+DataName
		if (WaveExists(Data))
			ParmDescript[%XIndex][0] = GetDimLabel(Data,!Parms[%RowIsX][0],Parms[%XIndex][0])
			ParmDescript[%YIndex][0] = GetDimLabel(Data,!Parms[%RowIsX][0],Parms[%YIndex][0])
		endif
		ParmDescript[%Graph][0] = "ARPlotterGraph"

	endif


//	String TabStr = "qweqwe"
//	DoWindow/F $TabStr
//	if (!	V_Flag)
//		Edit/K=1 ParmDescript.ld,Parms.ld
//		DoWindow/C $TabStr
//	endif


End //InitPMWaves


Function SetPMFolder(CtrlName,PopNum,PopStr)
	String CtrlName		//used
	Variable PopNum		//not used
	String PopStr		//used


	String DataFolder = GETPMF()
	Wave/T ParmDescript = $DataFolder+"DescriptionWave"
	Wave Parms = $DataFolder+"ParmWave"

	if ((Strlen(popStr)) && (DataFolderExists(PopStr)))
		ParmDescript[%Folder][0] = PopStr
	endif

	String FolderList = GetFolderTree("root:",sps=";")
	Variable Index = WhichListItem(ParmDescript[%Folder][0],FolderList,";",0)
	Parms[%Folder][0] = Index

	Wave/T DataList = $DataFolder+"DataList"
	String DataStrList = ARWaveList(ParmDescript[%Folder][0],"*",";","TEXT:0,DIMS:2,")
	StrList2WaveSep2(DataStrList,DataList,";",0)



	Parms[%Wave][0] = Limit(Parms[%Wave][0],0,DimSize(DataList,0))
	ParmDescript[%Wave][0] = DataList[Parms[%Wave][0]][0]

	String GraphStr = cPlotterManagerName
	Wave PanelParms = $GetDF("Windows")+GraphStr+"Parms"


	ControlInfo/W=$GraphStr $CtrlName
	if (V_Flag)
		PopupMenu $CtrlName,win=$GraphStr,mode=Index+1
	endif
	ScalePanel(GraphStr)
	ARDrawRect(GraphStr,PanelParms[%RedColor][0],PanelParms[%GreenColor][0],PanelParms[%BlueColor][0])
	UpdatePlotterLabels()
End //SetPMFolder


Function PlotterListFunc(CtrlName,Row,Col,Event)
	String CtrlName		//not used
	Variable Row		// used
	Variable Col		//not used
	Variable Event		//not used
	
	if (Event > 5)
		return(0)		//drop the unused events.
	endif

	String DataFolder = GETPMF()
	Wave/T ParmDescript = $DataFolder+"DescriptionWave"
	Wave Parms = $DataFolder+"ParmWave"
	Wave/T DataList = $DataFolder+"DataList"
	Parms[%Wave][0] = Row
	ParmDescript[%Wave][0] = DataList[Row][0]
	UpdatePlotterLabels()
	
	//yeah, that simple.
	
	if (Event == 3)		//double click
		Wave/Z Data = $ParmDescript[%Folder][0]+DataList[Row][0]
		if (WaveExists(Data) == 0)
			return(0)
		endif
		String GraphList = WaveIsOn(Data)
		if (ItemsInList(GraphList,";"))
			DoWindow/F $StringFromList(0,GraphList,";")
		endif
	endif
			
	

End //PlotterListFunc


Function DoPlotterFunc(CtrlName)
	String CtrlName		//not used

	String DataFolder = GETPMF()
	Wave/T ParmDescript = $DataFolder+"DescriptionWave"
	Wave Parms = $DataFolder+"ParmWave"
	Wave/T DataList = $DataFolder+"DataList"


	MakeAR2DPlotter(ParmDescript[%Graph][0],$ParmDescript[%Folder][0]+ParmDescript[%Wave][0],Parms[%RowIsX][0],Parms[%Append][0],Parms[%YIndex][0],Parms[%XIndex][0],ParmDescript[%Axis][0],Parms[%Start][0],Parms[%Stop][0])

End //DoPlotterFunc


Function/S GetPMGraphList()

	String output = ""
	
	String SavedDataFolder = GetDataFolder(1)
	String DataFolder = GetAR2DPlotterFolder("","")
	SetDataFolder(DataFolder)
	output = StringByKey("FOLDERS",DataFolderDir(1),":",";")
	SetDataFolder(SavedDataFolder)
	if (Strlen(output))
		output = ReplaceString(",",output,";",1)
		output += ";"
	endif
	return(output)

End //GetPMGraphList


Function SetPMGraphStr(CtrlName,PopNum,PopStr)
	String CtrlName		//not used
	Variable PopNum		//not used
	String PopStr		//used

	String DataFolder = GETPMF()
	Wave/T TextParms = $DataFolder+"DescriptionWave"

	TextParms[%Graph][0] = PopStr


End //SetPMGraphStr


Function SetPMAppend(CtrlName,Checked)
	String CtrlName		//not used
	Variable Checked		//used


	String DataFolder = GETPMF()
	Wave Parms = $DataFolder+"ParmWave"
	
	Parms[%Append][0] = Checked


End //SetPMAppend


Function SetPMRowData(CtrlName,Checked)
	String CtrlName		//used
	Variable Checked		//used


	String TabStr = "_"+GetEndNumStr(CtrlName)


	String ControlList = "RowIsData;ColIsData;"
	String GraphStr = cPlotterManagerName

	String DataFolder = GETPMF()
	Wave Parms = $DataFolder+"ParmWave"
	
	Variable RowIsX = StringMatch(CtrlName,"*Row*")
	Parms[%RowIsX][0] = RowIsX

	String ControlName
	Variable A, nop = ItemsInList(ControlList,";")
	for (A = 0;A < nop;A += 1)
		ControlName = StringFromList(A,ControlList,";")+TabStr
		UpdateAllCheckBoxes(ControlName,0)
	endfor
	UpdateAllCheckBoxes(CtrlName,Checked)
	UpdatePlotterLabels()
End //SetPMRowData


Function PlotterIndexFunc(CtrlName,VarNum,VarStr,VarName)
	String CtrlName		//used
	Variable VarNum		//used ?
	String VarStr		//not used
	String VarName		//not used

//OK, we have to update the popups.....

//	String DataFolder = GETPMF()
//	Wave/T TextParms = $DataFolder+"DescriptionWave"
//	Wave Parms = $DataFolder+"ParmWave"
//
//
//	Wave/Z Data = $TextParms[%Folder][0]+TextParms[%Wave][0]
//	if (WaveExists(Data) == 0)
//		return(0)
//	endif
	
	
	String DataFolder = GETPMF()
	Wave/T TextParms = $DataFolder+"DescriptionWave"
	Wave Parms = $DataFolder+"ParmWave"
	
	
	
	if (StringMatch(CtrlName,"XIndex*") == 1)
		if (Parms[%Xindex][0] == Parms[%YIndex][0])
			Parms[%XIndex][0] = -1
		endif
	endif


	Variable RowIsX = Parms[%RowIsX][0]

	Wave/Z Data = $TextParms[%Folder][0]+TextParms[%Wave][0]
	if (WaveExists(Data) == 1)
		if (StringMatch(CtrlName,"XIndex*") == 1)
			Parms[%XIndex][0] = Limit(Parms[%XIndex][0],-1,DimSize(Data,!RowIsX)-1)
		else
			Parms[%YIndex][0] = Limit(Parms[%YIndex][0],0,DimSize(Data,!RowIsX)-1)
		endif
	endif


	UpdatePlotterLabels()

End //PlotterIndexFunc


Function/S PullOutPlotterAxes(IsX)
	Variable IsX

	String DataFolder = GETPMF()
	Wave/T TextParms = $DataFolder+"DescriptionWave"
	
	String output = ""
	if (IsX)
		output = TextParms[%XIndex][1]
	else
		output = TextParms[%YIndex][1]
	endif
	
	return(output)

End //PullOutPlotterAxes


Function SetPlotterIndexFunc(CtrlName,PopNum,PopStr)
	String CtrlName		//used
	Variable PopNum		//used
	String PopStr		//used


	String DataFolder = GETPMF()
	Wave/T TextParms = $DataFolder+"DescriptionWave"
	Wave Parms = $DataFolder+"ParmWave"

	String ParmStr = "YIndex"
	if (StringMatch(CtrlName,"XIndex*"))
		ParmStr = "XIndex"
	endif

	Wave/Z Data = $TextParms[%Folder][0]+TextParms[%Wave][0]
	if (WaveExists(Data) == 0)
		return(0)
	endif

	Variable RowIsX = Parms[%RowIsX][0]
	Variable Index
	if (StringMatch(PopStr,"Scaling") == 1)
		Index = -1
	else
		Index = FindDimLabel(Data,!RowIsX,PopStr)
		if (Index < 0)
			UpdatePlotterLabels()
			return(0)
		endif
	endif

	Parms[%$ParmStr][0] = Index
	TextParms[%$ParmStr][0] = PopStr
	UpdatePlotterLabels()
	

End //SetPlotterIndexFunc


Function UpdatePlotterLabels()


//OK our job is to update the lists for the X and Y lists popups....


	String DataFolder = GETPMF()
	Wave/T TextParms = $DataFolder+"DescriptionWave"
	Wave Parms = $DataFolder+"ParmWave"
	
	Variable RowIsX = Parms[%RowIsX][0]

	String GraphStr = cPlotterManagerName
	String LabelList = ""
	Wave/Z Data = $TextParms[%Folder][0]+TextParms[%Wave][0]
	if (WaveExists(Data) == 0)
		LabelList = ""
	else
		//lets check the first one....
		if (Strlen(GetDimLabel(Data,!RowIsX,0)))
			LabelList = GetDimLabels(Data,!RowIsX)
		else
			LabelList = "_None_"
		endif
	endif
	

	TextParms[%YIndex][0] = StringFromList(Parms[%YIndex][0],LabelList,";")
	TextParms[%YIndex][1] = LabelList
	


	if (Parms[%Yindex][0] == Parms[%XIndex][0])
		Parms[%Xindex][0] = -1
	endif

	
	//LabelList = RemoveListItem(Parms[%YIndex][0],LabelList,";")
	LabelList = "Scaling;"+LabelList
	
	TextParms[%XIndex][0] = StringFromList(Parms[%XIndex][0]+1,LabelList,";")
	TextParms[%XIndex][1] = LabelList
	

	Variable Tab = 0
	String TabStr = "_"+num2str(Tab)
	

	String ControlName = "YIndexPop"+TabStr
	ControlInfo/W=$GraphStr $ControlName
	Variable Mode = Max(WhichListItem(TextParms[%YIndex][0],TextParms[%YIndex][1],";",0)+1,1)
		
	if (V_Flag)
		PopUpMenu $ControlName,win=$GraphStr,mode=Mode
		//ControlUpdate/W=$GraphStr $ControlName
	endif

	ControlName = "XIndexPop"+TabStr
	ControlInfo/W=$GraphStr $ControlName
	Mode = WhichListItem(TextParms[%XIndex][0],TextParms[%XIndex][1],";",0)+1
	if (Mode == 0)
		Mode = 2
	endif
	if (V_Flag)
		PopUpMenu $ControlName,win=$GraphStr,mode=mode
		//ControlUpdate/W=$GraphStr $ControlName
	endif


End //UpdatePlotterLabels


Function PlotterRenameSetVarFunc(CtrlName,VarNum,VarStr,VarName)
	String CtrlName		//not used
	Variable VarNum		//not used
	String VarStr		//used
	String VarName		//not used, it is useless on global Strings

	String GraphStr = WinName(0,1)
	String DataFolder = GetAR2DPlotterFolder(GraphStr,"")
	SVAR GraphName = $DataFolder+VarName

	
	//OK, we need to ask first about the new name...
	
	String NewName = CleanupName(VarStr,0)
	GraphName = NewName
	if (!Strlen(NewName))
		return(0)
	elseif (StringMatch(GraphStr,NewName) == 1)
		return(0)
	endif
	DoWindow $NewName
	if (V_Flag)
		DoAlert 0,"Already a GraphName, try again!"
		GraphName = GraphStr
		return(0)
	endif
	
	//Don't bother with the datafolder checking.  Since folders down here have to be 
	//named after the graph, so if the graph does not exists
	//it is resonably safe to assume that there is no folder with that name
	
	
	
	
	//OK, we have our name, lets use it....
	
	DoWindow/F $GraphStr
	DoWindow/C $NewName
	
	
	
	//String IgorIsAPain = UpDir(DataFolder)
	//RenameDataFolder $DataFolder $UpDir(DataFolder)+":"+NewName
	RenameDataFolder $DataFolder $NewName
	DataFolder = UpDir(DataFolder)+":"+NewName+":"
	
	//Variable DontCrash = 1
	
	
	//I think I am done.
	
	
	//NO!
	
	//We need to rename to Trace Popup....
	
	Wave/T TraceList = $DataFolder+"TraceList"
	Variable A, nop = DimSize(TraceList,0)
	for (A = 0;A < nop;A += 1)
		TraceList[A][0] = ReplaceListItem(ItemsInList(TraceList[A][0],":")-2,TraceList[A][0],NewName,":")
	endfor
	
	
	
	String ControlName = "TracePopup"
	ControlInfo/W=$NewName $ControlName
	String Evil
	if (V_Flag)
		Evil = "Popupmenu "+ControlName+",win="+NewName+",Value=GetDimLabels("+DataFolder+"TraceList"+",0)"
		Execute(Evil)
	endif
	Variable Index = V_Value-1
	
	//And hit all the TraceList
	
	//OK, since we have to use Execute Strings on some controls
	//they are busted, lets give them new life.
	

	SetPlotterControls(NewName,$TraceList[Index][0]+GetDimLabel(TraceList,0,Index)+"P",$TraceList[Index][0]+GetDimLabel(TraceList,0,Index)+"D")
	
	//print NewName



End //PlotterRenameSetVarFunc



Function Set2DPlotter(Name,DataFolder)
	String Name, DataFolder

//our job is to take the premade ar plotter and set it's controls
//so that it is ready to look at Maveric pulls.


//first step is to set the folder....
//InitMavericOffline = Set2DPlotter("MavericOffline","root:MavericCurves:")

	String GraphStr = cPlotterManagerName
	DoWindow/F $GraphStr
	Variable HadWindow = V_Flag
	if (!V_Flag)
		MakePanel("PlotterManager")
	endif

	String PlotterFolder = GETPMF()
	Wave/T TextParms = $PlotterFolder+"DescriptionWave"
	Wave Parms = $PlotterFolder+"ParmWave"

	//MakePlotterManagerPanel
	Variable Tabnum = 0
	String TabStr = "_"+num2str(TabNum)
	
	if (Strlen(DataFolder))
		if (DataFolderExists(DataFolder))
//			if (!StringMatch(TextParms[%Folder][0],DataFolder))
				SetPMFolder("DataFolderPop"+TabStr,NaN,DataFolder)
//			endif
		endif
	endif
	
	if (Parms[%RowIsX][0])
		SetPMRowData("ColIsData"+TabStr,1)
	endif

	TextParms[%Graph][0] = Name
	

End //Set2DPlotter


Function MakeAR2DPlotter(GraphStr,MasterWave,RowIsX,AddValue,YIndex,XIndex,Axis,Start,Stop)
	String GraphStr
	Wave MasterWave
	Variable AddValue, RowIsX, YIndex, XIndex
	String Axis
	Variable Start, Stop
	

	if (AddValue == 0)
		DoWindow/K $GraphStr
	endif
	
	if (!Strlen(Axis))
		Axis = "Left"
	endif
	
	if (WaveExists(MasterWave) == 0)
		Return(0)
	endif
	String MasterName = NameOfWave(MasterWave)
	String DataFolder = GetAR2DPlotterFolder(GraphStr,"")
	String SavedDataFolder = GetDataFolder(1)
	SetDataFolder(DataFolder)
	String NewName = UniqueName("TraceFolder",11,0)
	DataFolder += NewName+":"
	BuildDataFolder(DataFolder)
	Variable Enab = 0
	
	
	Variable FontSize = 12

	
//	String YIndexList = ""
	String YName = GetDimLabel(MasterWave,!RowIsX,YIndex)
	if (!Strlen(YName))
		YName = "Y"+num2str(YIndex)
//		YIndexList = MakeValueStringList(DimSize(MasterWave,!RowIsX),0)
//	else
//		YIndexList = GetDimLabels(MasterWave,!RowIsX)
	endif
//	YName = MasterName+YName
//	
//	String XName = ""
//	
//	String XIndexList = "Scaling;"
//	XName = GetDimlabel(MasterWave,!RowIsX,XIndex-1)
//	if (!Strlen(XName))
//		XName = num2str(XIndex-1)
//		XIndexList += MakeValueStringList(DimSize(MasterWave,!RowIsX),0)
//	else
//		XIndexList += GetDimLabels(MasterWave,!RowIsX)
//	endif
//	
//	if (XIndex == 0)
//		XName = "Scaling"
//	endif
//	XName = MasterName+XName
	

	SmartDataLimits(DimSize(MasterWave,RowIsX),Start,Stop)

//	Extract2DSlice(MasterWave,DataFolder+YName,DataFolder+XName,Yindex,XIndex-1,Start,Stop,RowIsX)
//	Wave YData = $DataFolder+YName
//	Wave XData = $DataFolder+XName
	
	
//Store the trace and data folder info in a wave....	
	Wave/T/Z TraceWave = $UpDir(DataFolder)+":TraceList"
	Variable Index = -1
	if (WaveExists(TraceWave) == 0)
		Make/N=(1)/T $UpDir(DataFolder)+":TraceList"
		Wave/T TraceWave = $UpDir(DataFolder)+":TraceList"
		Index = 0
//	else
//		Index = FindDimLabel(TraceWave,0,YName)
	endif
	SVAR GraphName = $InitOrDefaultString(UpDir(DataFolder)+":GraphName","")
	GraphName = GraphStr
	
	if (Index < 0)
		Index = DimSize(TraceWave,0)
		InsertPoints/M=0 Index,1,TraceWave
	endif
	
	SetDimLabel 0,Index,$Yname,TraceWave
	TraceWave[Index] = DataFolder
	
	SetDataFolder(DataFolder)

	
//And store the graphics info on anouther wave.
	
	String ParmList = "RowIsX;MasterWave;YIndex;XIndex;Axis;Start;Stop;"
	Variable nop = ItemsInList(ParmList,";")
	
	String VarFolder = GetDF("Variables")
	Wave MVW = $VarFolder+"MasterVariablesWave"
	Wave/T MVD = $VarFolder+"MasterVariablesDescription"
	String ColLabels = GetDimLabels(MVW,1)
	
	
	Wave/Z TraceParms = $DataFolder+Yname+"P"
	if (WaveExists(TraceParms) == 0)
		Make/N=(nop,DimSize(MVW,1)) $DataFolder+Yname+"P"
		Wave/Z TraceParms = $DataFolder+Yname+"P"
		SetDimLabels(TraceParms,ParmList,0)
		SetDimLabels(TraceParms,ColLabels,1)
		

	endif
	
	
	TraceParms[%RowIsX][0] = RowIsX
	TraceParms[%YIndex][0] = YIndex
	TraceParms[%XIndex][0] = XIndex
	TraceParms[%Start][0] = Start
	TraceParms[%Stop][0] = Stop
	
	
	ColLabels = GetDimLabels(MVD,1)
	Wave/Z/T TraceDescription = $DataFolder+Yname+"D"


	if (WaveExists(TraceDescription) == 0)
		Make/T/N=(nop,DimSize(MVD,1)) $DataFolder+Yname+"D"
		Wave/T/Z TraceDescription = $DataFolder+Yname+"D"
		SetDimLabels(TraceDescription,ParmList,0)
		SetDimLabels(TraceDescription,ColLabels,1)
		

	endif


	TraceDescription[%MasterWave][%Title] = GetWavesDataFolder(MasterWave,2)
	TraceDescription[%Axis][0] = Axis
//	TraceDescription[%XIndex][%Format] = XIndexList
//	TraceDescription[%XIndex][%Title] = XName
//	TraceDescription[%YIndex][%Format] = YIndexList
//	TraceDescription[%YIndex][%Title] = YName

	
	
//Time to work on the graph.
	DoWindow/F $GraphStr
	if (!	V_Flag)
		Display/K=1/N=$GraphStr
	endif	
	
	UpdatePlotterWaves(GraphStr,Index,1)
//	String TraceList = ARTraceNameList(GraphStr,"*","*","Bottom",UpDir(DataFolder)+"*")
//	
//	Variable TRaceIndex = ARListMatch(TraceList,YName)
//	if (TRaceIndex < 0)
//		AppendToGraph/W=$GraphStr/L=$Axis YData vs XData
//		LinSpaceLeftAxes(GraphStr)
//		LineUpLeftAxes(GraphStr,"Left")
//	endif
	SetWindow $GraphStr,hook=ARPlotterHook
	
	
	
	//and now for the controls......
	String Evil = ""
	Variable CurrentTop = 5
	Variable LeftPos = 6
	String ControlName = ""
	

	ControlName = "TracePopup"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakePopup(GraphStr,ControlName,"Trace",LeftPos,CurrentTop,"ARPlotterPopFunc","GetDimLabels("+GetWavesDataFolder(TraceWave,2)+",0)",0,Enab)
		Popupmenu $ControlName,win=$GraphStr,BodyWidth=100
//		Popupmenu $ControlName,win=$GraphStr,Title="Trace",pos={6,CurrentTop},BodyWidth=100,proc=ARPlotterTraceFunc
//		Evil = "Popupmenu "+ControlName+",win="+GraphStr+",Value=GetDimLabels("+GetWavesDataFolder(TraceWave,2)+",0)"
//		Execute(Evil)
	endif
	PopUpMenu $ControlName,Win=$GraphStr,mode=Index+1
	
	LeftPos += 140
	
	ControlName = "RemoveTrace"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakeButton(GraphStr,ControlName,"Remove",60,20,LeftPos,CurrentTop,"RemovePlotterTrace",0)
	endif
	LeftPos += 100
	
	
	ControlName = "RenamePlot"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		SetVariable $ControlName,win=$GraphStr,Title="GraphName",pos={LeftPos,CurrentTop},size={125,20},bodywidth=80,value=$UpDir(DataFolder)+":GraphName"
		SetVariable $ControlName,win=$GraphStr,proc=PlotterRenameSetVarFunc,font="Arial",fsize=FontSize
		//MakeButton(GraphStr,ControlName,"Rename",80,20,515,CurrentTop-2,"PlotterRenameFunc",0)
	endif
	LeftPos += 140
	
	ControlName  = "AxisSetVar"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		SetVariable $ControlName,win=$GraphStr,Title="Left Axis",pos={LeftPos,CurrentTop},bodywidth=70,size={122,0},proc=SetPlotterAxisVar,font="Arial",fsize=FontSize
	endif
	

	LeftPos += 109
	 
	ControlName = "AxisPop"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakePopup(GraphStr,ControlName,"",LeftPos+11,CurrentTop-3,"ARPlotterPopFunc","",0,0)
	endif
	
	
	
	LeftPos += 50
	
	ControlName = "MasterNameTitle"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		TitleBox $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop}
	endif
	


///////////////////////////////////////////////////////////////////////////////////////////
///////////////////                 New Control Line
///////////////////////////////////////////////////////////////////////////////////////////



	LeftPos = 105

	CurrentTop += 35
	
	
	
	ControlName = "WaveGroupBox"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		GroupBox $ControlName,win=$GraphStr,pos={0,CurrentTop-7},Size={232,80}
	endif
		
	
	
	ControlName = "YIndexPop"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakePopup(GraphStr,ControlName,"YWave",LeftPos,CurrentTop,"ARPlotterPopFunc","",0,0)
		Popupmenu $ControlName,win=$GraphStr,BodyWidth=120
	endif
	LeftPos += 70
	
	
	
	ControlName = "YIndexSetVar"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		SetVariable $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop},size={50,20},Title=" ",proc=ARPlotterIndexSetVarFunc,Limits={-inf,inf,1},font="Arial",Fsize=FontSize
	endif
	LeftPos += 75



	ControlName = "StartGroupBox"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		GroupBox $ControlName,win=$GraphStr,pos={LeftPos-7,CurrentTop-5},size={235,55}
	endif



	ControlName = "StartSetVar"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		SetVariable $ControlName,win=$GraphStr,Title="Start Index",size={125,20},pos={LeftPos,CurrentTop},Title=" ",proc=ARPlotterLimitSetVarFunc,Limits={-inf,inf,1},font="Arial",Fsize=FontSize
	endif
	LeftPos += 135
	
	
	
	ControlName = "UserCursors"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakeButton(GraphStr,ControlName,"Cursors",80,20,LeftPos,CurrentTop,"ARPlotterCursorFunc",0)
		//Button $ControlName,win=$GraphStr,Title="Cursors",Size={80,20},pos={370,CurrentTop},proc=ARPlotterCursorFunc
	endif
	LeftPos += 120


	ControlName = "LegendCheck"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		//CheckBox $ControlName,win=$GraphStr,Title="Legend",pos={370,CurrentTop},proc=HistoCheck
		MakeCheckbox(GraphStr,ControlName,"Legend",LeftPos,CurrentTop,"HistoCheck",0,0,0)
	endif
	LeftPos += 70


	ControlName = "PlotterHelpButton"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakeButton(GraphStr,ControlName,"Help",60,20,LeftPos,CurrentTop,"ARHelpFunc",Enab)
	endif


///////////////////////////////////////////////////////////////////////////////////////////
///////////////////                 New Control Line
///////////////////////////////////////////////////////////////////////////////////////////

	LeftPos = 105
	
	CurrentTop += 25
	
	

	
	ControlName = "XIndexPop"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakePopup(GraphStr,ControlName,"XWave",LeftPos,CurrentTop,"ARPlotterPopFunc","",0,Enab)
		Popupmenu $ControlName,win=$GraphStr,BodyWidth=120
	endif
	LeftPos += 70
	
	
	ControlName = "XIndexSetVar"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		SetVariable $ControlName,win=$GraphStr,pos={LeftPos,CurrentTop},size={50,20},Title=" ",proc=ARPlotterIndexSetVarFunc,Limits={-inf,inf,1},font="Arial",Fsize=FontSize
	endif
	LeftPos += 75
	
	
	ControlName = "StopSetVar"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		SetVariable $ControlName,win=$GraphStr,Title="Stop Index",size={125,20},pos={LeftPos,CurrentTop},Title=" ",proc=ARPlotterLimitSetVarFunc,Limits={-inf,inf,1},font="Arial",Fsize=FontSize
	endif
	LeftPos += 135
	
	
	ControlName = "AllCursor"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakeCheckbox(GraphStr,ControlName,"Limit-All",LeftPos,CurrentTop,"",1,0,0)
	endif
	LeftPos += 120




	ControlName = "RowIsX"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakeCheckbox(GraphStr,ControlName,"Row=Data",LeftPos,CurrentTop,"ARPlotterRowFunc",0,1,Enab)
		//CheckBox $ControlName,win=$GraphStr,mode=1,pos={265,CurrentTop},Title="Row=Data",proc=ARPlotterRowFunc
	endif
	
	ControlName = "ColIsX"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakeCheckbox(GraphStr,ControlName,"Column=Data",LeftPos,CurrentTop+15,"ARPlotterRowFunc",0,1,Enab)
		//CheckBox $ControlName,win=$GraphStr,mode=1,pos={265,CurrentTop+15},Title="Column=Data",proc=ARPlotterRowFunc
	endif
	

	
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////                 New Control Line
///////////////////////////////////////////////////////////////////////////////////////////

LeftPos = 65
CurrentTop += 25
	ControlName = "LinkXAxisCheck"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakeCheckbox(GraphStr,ControlName,"Link X",LeftPos,CurrentTop,"",1,0,0)
	endif
	LeftPos += 80
	

	ControlName = "XFliper"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		MakeCheckbox(GraphStr,ControlName,"Flip Bottom",LeftPos,CurrentTop,"ARPlotterXFlipFunc",0,0,0)
	endif

	
	SetPlotterControls(GraphStr,TraceParms,TraceDescription)
	
	ScaleControlBar(GraphStr,5)
	SetWindow $GraphStr,Hook(Rotate)=PlotterRotateHook
	SetDataFolder(SavedDataFolder)
End //MakeAR2DPlotter


Function/S GetAR2DPlotterFolder(GraphStr,TraceStr)
	String GraphStr, TraceStr


	String Output = "Root:Packages:MFP3D:Plotter:"
	if (Strlen(GraphStr))
		output += GraphStr+":"
		if (Strlen(TraceStr))
			OutPut += TraceStr+":"
		endif
	endif
	if (DataFolderExists(Output) == 0)
		BuildDataFolder(Output)
	endif
	return(output)
	

End //GetAR2DPlotterFolder


Function SmartDataLimits(nop,Start,Stop)
	Variable nop
	Variable &Start, &Stop
	
	
	if (Nop < 2)
		Start = 0
		Stop = Max(0,Stop)
		return(0)
	endif
	
	Stop = Min(Stop,nop)
	Start = Max(0,Start)
	
	if (Start > Stop)
		Start = Stop-2
		Start = Max(0,Start)
		if (Start > Stop)
			Stop += 2
			Stop = Min(Stop,Nop)
		endif
	endif

End //SmartDataLimits


Function Extract2DSlice(MasterWave,YName,XName,Yindex,XIndex,Start,Stop,RowIsX)
	Wave MasterWave
	String YName, XName
	Variable Yindex, XIndex, Start, Stop, RowIsX

	
	if (RowIsX)
		Duplicate/O/R=[YIndex,YIndex][Start,Stop] MasterWave $YName
		Wave Data = $YName
		Redimension/N=(Numpnts(Data)) Data
		SetScale/P x,DimOffset(MasterWave,1)+Start*DimDelta(MasterWave,1),DimDelta(MasterWave,1),WaveUnits(MasterWave,1),Data
	else
		Duplicate/O/R=[Start,Stop][YIndex,YIndex] MasterWave $YName
	endif

	if (StringMatch(XName,"*Scaling") == 1)
		Wave YData = $YName
		Duplicate/O YData $XName
		Wave XData = $XName
		XData = X
	else
		if (RowIsX)
			Duplicate/O/R=[XIndex,XIndex][Start,Stop] MasterWave $XName
//			Wave Data = $XName
//			Redimension/N=(Numpnts(Data)) Data
		else
			Duplicate/O/R=[Start,Stop][XIndex,XIndex] MasterWave $XName
		endif
	endif

	//and now the units hack.......
	
	Wave Data = $YName
	if (!Strlen(WaveUnits(Data,-1)))
	
//check
		String Units = Get3DScaling(LastDir(YName))
		if (Strlen(Units))
			SetScale d,0,0,Units,Data
		endif
	endif
	
	
	Wave Data = $XName
	if (!Strlen(WaveUnits(Data,-1)))
		if (StringMatch(XName,"*Scaling") == 1)
			Units = "s"
		else
//check
			Units = Get3DScaling(LastDir(XName))
			Units = StringFromList(0,Units,";")
		endif
		if (Strlen(Units))
			SetScale d,0,0,Units,Data
		endif
	endif


End //Extract2DSlice


Function ARPlotterHook(InfoStr)
	String InfoStr
//return(0)
	String Event = StringByKey("EVENT",InfoStr,":",";")
	String GraphStr = StringByKey("Window",InfoStr,":",";")
	String DataFolder = ""
	
	if (StringMatch(Event,"Kill") == 1)
		ClearGraph(GraphStr)
		DataFolder = GetAR2DPlotterFolder(GraphStr,"")
		SafeKillDataFolderTree(DataFolder,1)
	endif
	
	return(0)

End //ARPlotterHook


Function ARPlotterPopFunc(InfoStruct)
	Struct WMPopupAction &InfoStruct
	//PopStr
	//Win
	//CtrlName
	//EventCode
	
	if (InfoStruct.EventCode != 2)
		return(0)
	endif
	
	
	String PopStr = InfoStruct.popStr
	String GraphStr = InfoStruct.Win
	String CtrlName = InfoStruct.CtrlName
	Variable PopNum = infoStruct.PopNum
	
	String DataFolder = GetAR2DPlotterFolder(GraphStr,"")
	Wave/T TraceList = $DataFolder+"TraceList"
	Variable Index, DoAll, A, nop
	String Controlname, TraceStr
	
	
	StrSwitch (CtrlName)
		case "AxisPop":
			ControlName = "TracePopup"
			ControlInfo/W=$GraphStr $ControlName
			if (!V_Flag)
				return(0)
			endif
			Index = V_Value-1
			TraceStr = S_Value
			Wave ParmWave = $TraceList[Index]+TraceStr+"P"
			Wave/T ParmDescript = $TraceList[Index]+TraceStr+"D"
		
		
			ParmDescript[%Axis][0] = PopStr
			SetPlotterAxisVar("",Nan,PopStr,":"+TraceStr+"D[%Axis]")
			break
			
		case "TracePopup":
			Index = FindDimLabel(TraceList,0,PopStr)
			
			Wave ParmWave = $TraceList[Index]+PopStr+"P"
			Wave/T ParmDescript = $TraceList[Index]+PopStr+"D"
			
			//Our Job is to set up all the controls on the panel.....
			
			SetPlotterControls(GraphStr,ParmWave,ParmDescript)
			break
			
		case "YIndexPop":
		case "XIndexPop":
			ControlName = "TracePopup"
			ControlInfo/W=$GraphStr $ControlName
			if (!V_Flag)
				return(0)
			endif
			Index = V_Value-1
			TraceStr = S_Value
			DoAll = 0
			ControlInfo/W=$GraphStr LinkXAxisCheck
			if (V_Flag)
				DoAll = V_Value
			endif


			Wave ParmWave = $TraceList[Index]+TraceStr+"P"
			Wave/T ParmDescript = $TraceList[Index]+TraceStr+"D"

			//OK, Enter the value

			if (StringMatch(CtrlName,"YIndex*") == 1)
				ParmWave[%YIndex][0] = PopNum-1
				//ParmDescript[%YIndex][%Title] = PopStr
			elseif (StringMatch(CtrlName,"XIndex*") == 1)
				ParmWave[%XIndex][0] = PopNum-2
				//ParmDescript[%XIndex][%Title] = PopStr
		
		
				//OK here we go....
				if (DoAll)
					nop = DimSize(TraceList,0)
					for (A = 0;A < nop;A += 1)
						if (A == Index)
							Continue
						endif
						Wave TempParmWave = $TraceList[A][0]+GetDimLabel(TraceList,0,A)+"P"
						if (TempParmWave[%YIndex][0] != ParmWave[%XIndex][0])
							TempParmWave[%XIndex][0] = ParmWave[%XIndex][0]
							UpdatePlotterWaves(GraphStr,A,1)
						endif
					endfor
				endif
			endif


			if (ParmWave[%XIndex][0] == ParmWave[%YIndex][0])
				//gonna be problems, lets set the X to Scaling....
				//ParmDescript[%XIndex][%Title] = "Scaling"
				ParmWave[%XIndex][0] = -1
				SetPlotterControls(GraphStr,ParmWave,ParmDescript)
			endif


	
			UpdatePlotterWaves(GraphStr,Index,1)
			break
	
		
	endswitch

End //ARPlotterPopFunc


Function SetPlotterControls(GraphStr,ParmWave,ParmDescript)
	String GraphStr
	Wave ParmWave
	Wave/T ParmDescript


	String ControlName

	DoWindow $GraphStr
	if (!V_Flag)
		return(0)
	endif


	ControlName = "MasterNameTitle"
	ControlInfo/W=$GraphStr $ControlName
	if (V_Flag)
		TitleBox $ControlName,win=$GraphStr,title=LastDir(ParmDescript[%MasterWave][%Title])
	endif


	ControlName = "RowIsX"
	ControlInfo/W=$GraphStr $ControlName
	if (V_Flag)
		CheckBox $ControlName,win=$GraphStr,Value=ParmWave[%RowIsX][0]
	endif

	ControlName = "ColIsX"
	ControlInfo/W=$GraphStr $ControlName
	if (V_Flag)
		CheckBox $ControlName,win=$GraphStr,Value=!ParmWave[%RowIsX][0]
	endif

	String Evil = ""
	ControlName = "YIndexPop"
	ControlInfo/W=$GraphStr $ControlName
	Variable Mode = Max(WhichListItem(ParmDescript[%YIndex][%Title],ParmDescript[%YIndex][%Format],";",0)+1,1)
	if (V_Flag)
		PopUpMenu $ControlName,win=$GraphStr,mode=mode
		//ParmWave[%Yindex]+1
		Evil = "PopUpMenu "+ControlName+",win="+GraphStr+",value="+GetWavesDataFolder(ParmDescript,2)+"[%YIndex][%Format]"
		Execute(Evil)
	endif



	ControlName = "XIndexPop"
	ControlInfo/W=$GraphStr $ControlName
	mode = WhichListItem(ParmDescript[%XIndex][%Title],ParmDescript[%XIndex][%Format],";",0)+1
	if (Mode == 0)
		Mode = 2
	endif
	if (V_Flag)
		PopUpMenu $ControlName,win=$GraphStr,mode=mode
		//ParmWave[%Xindex]+2
		Evil = "PopUpMenu "+ControlName+",win="+GraphStr+",value="+GetWavesDataFolder(ParmDescript,2)+"[%XIndex][%Format]"
		Execute(Evil)
	endif



	ControlName = "XIndexSetVar"
	ControlInfo/W=$GraphStr $ControlName
	if (V_Flag)
		SetVariable $ControlName,win=$GraphStr,value=$GetWavesDataFolder(ParmWave,2)[%Xindex][0]
	endif

	ControlName = "YIndexSetVar"
	ControlInfo/W=$GraphStr $ControlName
	if (V_Flag)
		SetVariable $ControlName,win=$GraphStr,value=$GetWavesDataFolder(ParmWave,2)[%Yindex][0]
	endif



	ControlName = "StartSetVar"
	ControlInfo/W=$GraphStr $ControlName
	if (V_Flag)
		SetVariable $ControlName,win=$GraphStr,value=$GetWavesDataFolder(ParmWave,2)[%Start][0]
	endif


	ControlName = "StopSetVar"
	ControlInfo/W=$GraphStr $ControlName
	if (V_Flag)
		SetVariable $ControlName,win=$GraphStr,value=$GetWavesDataFolder(ParmWave,2)[%Stop][0]
	endif

	ControlName = "AxisPop"
	ControlInfo/W=$GraphStr $ControlName
	if (V_Flag)
		String AList = GetAllAxes(GraphStr,"Left")
		Evil = "PopupMenu "+ControlName+",win="+GraphStr+",value=GetAllAxes(\""+GraphStr+"\",\"Left\")"
		Execute(Evil)
		//PopupMenu $ControlName,win=$GraphStr,Mode=WhichListItem(ParmDescript[%Axis][0],AList,";",0)+1
	endif

	ControlName = "AxisSetVar"
	ControlInfo/W=$GraphStr $ControlName
	if (V_Flag)
		SetVariable $ControlName,win=$GraphStr,value=$GetWavesDataFolder(ParmDescript,2)[%Axis][0]
	endif

End //SetPlotterControls


Function ARPlotterRowFunc(CtrlName,Checked)
	String CtrlName
	Variable Checked

	//the row is X Col is X radio buttons function

	String ControlList = "RowIsX;ColIsX;"

	String GraphStr = WinName(0,1)

	Variable A, nop = ItemsInList(ControlList,";")
	String ControlName

	for (A = 0;A < nop;A += 1)
		ControlName = StringFromList(A,ControlList,";")
		ControlInfo/W=$GraphStr $ControlName
		if (V_Flag)
			CheckBox $ControlName,win=$GraphStr,value=0
		endif
	endfor
	CheckBox $CtrlName,win=$GraphStr,value=1


	String DataFolder = GetAR2DPlotterFolder(GraphStr,"")
	Wave/T TraceList = $DataFolder+"TraceList"

	ControlName = "TracePopup"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		return(0)
	endif
	Variable Index = V_Value-1
	String TraceStr = S_Value

	Wave ParmWave = $TraceList[Index]+TraceStr+"P"
	Wave/T ParmDescript = $TraceList[Index]+TraceStr+"D"

//OK, Enter the value


	Variable RowIsX = StringMatch(CtrlName,"RowIsX")
	ParmWave[%RowIsX][%Value] = RowIsX

	UpdatePlotterWaves(GraphStr,Index,1)


End //ARPlotterRowFunc


Function UpdatePlotterWaves(GraphStr,Index,UseXYIndex)
	String GraphStr
	Variable Index
	Variable UseXYIndex
	
	String DataFolder = GetAR2DPlotterFolder(GraphStr,"")
	Wave/T TraceList = $DataFolder+"TraceList"

	DataFolder = TraceList[Index][0]
	String TraceName = GetDimLabel(TraceList,0,Index)
	
	
	Wave TraceParms = $DataFolder+TraceName+"P"
	Wave/T TraceDescript = $DataFolder+TraceName+"D"

	String Axis = TraceDescript[%Axis][0]


	String GTL = ARTraceNameList(GraphStr,TraceName,"*","Bottom",DataFolder)
	
	
	Variable A, nop = ItemsInList(GTL,";")
	String Info = "", LAxis
	Variable HavePlot = 0, DidWork = 0
	for (A = 0;A < nop;A += 1)
		Info = TraceInfo(GraphStr,StringFromList(A,GTL,";"),0)
		LAxis = StringByKey("YAXIS",Info,":",";")
		if (!StringMatch(LAxis,Axis))
			RemoveFromGraph/W=$GraphStr/Z $StringFromList(A,GTL,";")
			DidWork = 1
		else
			HavePlot = 1
		endif
	endfor
	
	
	Variable XIndex = TraceParms[%XIndex][0]
	Variable YIndex = TraceParms[%YIndex][0]
	Variable Start = TraceParms[%Start][0]
	Variable Stop = TraceParms[%Stop][0]
	Variable RowIsX = TraceParms[%RowIsX][0]
	String YName = TraceDescript[%YIndex][%Title]
	String XName = TraceDescript[%XIndex][%Title]
	String OldYName = YName
	String OldXName = XName

	Wave MasterWave = $TraceDescript[%MasterWave][%Title]
	SmartDataLimits(DimSize(MasterWave,RowIsX),Start,Stop)


	//OK, we have 2 roads ahead of us.....
	
	String YIndexList, XIndexList = "Scaling;"
	
	if (UseXYIndex)
		YName = GetDimLabel(MasterWave,!RowIsX,YIndex)
		if (!Strlen(YName))
			YName = "Y"+num2str(YIndex)
			YIndexList = "_None_"
		else
			YIndexList = GetDimLabels(MasterWave,!RowIsX)
		endif
		if (XIndex == -1)
			XName = "Scaling"
		else
			XName = GetDimLabel(MasterWave,!RowIsX,XIndex)
		endif
		if (!Strlen(XName))
			XName = "X"+num2str(XIndex)
			XindexList += "_None_"
		elseif (strlen(GetDimLabel(MasterWave,!RowIsX,0)))
			XIndexList += GetDimLabels(MasterWave,!RowisX)
		endif
	
		TraceDescript[%XIndex][%Title] = XName
		TraceDescript[%XIndex][%Format] = XIndexList
		
		TraceDescript[%YIndex][%Title] = YName
		TraceDescript[%YIndex][%Format] = YIndexList
	
	
	else		//then we use the names.....
		YIndex = FindDimLabel(MasterWave,!RowIsX,YName)
		if (YIndex < 0)
			YIndex = GetEndNum(YName)
		endif
		
		if (StringMatch(XName,"Scaling") == 1)
			XIndex = -1
		else
			XIndex =  FindDimLabel(MasterWave,!RowIsX,XName)	
			if (XIndex < 0)
				XIndex = GetEndNum(XName)
			endif
		endif
		
		TraceParms[%XIndex][0] = XIndex
		TraceParms[%Yindex][0] = YIndex
	
	endif
	
	
	String SavedDataFolder = ""
	if (HavePlot)
		SavedDataFolder = GetDataFolder(1)
		SetDataFolder(DataFolder)
		if (!StringMatch(OldXName,XName))		//imp to do X first, since if we have a conflic, X gets set to Scaling.
			Rename $OldXName,$XName
		endif
		if (!StringMatch(OldYName,YName))
			ReName $OldYName,$YName
		endif
		SetDataFolder(SavedDataFolder)
	endif
	


	//Now lets cover the TraceList
	SetDimLabel 0,Index,$Yname,TraceList




	YIndex = Min(DimSize(MasterWave,!RowIsX)-1,YIndex)
	XIndex = Min(DimSize(MasterWave,!RowIsX)-1,XIndex)
	Yindex = Max(YIndex,0)
	XIndex = Max(XIndex,-1)
	TraceParms[%XIndex][0] = XIndex
	TraceParms[%YIndex][0] = YIndex


	Extract2DSlice(MasterWave,DataFolder+YName,DataFolder+XName,Yindex,XIndex,Start,Stop,RowIsX)
	Wave YData = $DataFolder+YName
	Wave XData = $DataFolder+XName

	
	
	Variable Red, Green, Blue
	
	//Fuxk this, we need to know what the new trace name is...
	
	
	String orgTraceList = ARTraceNameList(GraphStr,"*","*","*","*")
	String PostAddTraceList
	
	
	if (!HavePlot)
		AppendToGraph/W=$GraphStr/L=$Axis YData vs XData
		PostAddTraceList = ARTraceNameList(GraphStr,"*","*","*","*")
		String TraceStr = StringFromList(0,ListSubtract(PostAddTraceList,orgTraceList,";"),";")
		if (Strlen(Info))
			UpdateTrace(GraphStr,Info,TraceStr)
		else
			ARColorTable(ItemsInList(orgTraceList,";"),Red,Green,Blue)
			ModifyGraph/W=$GraphStr/Z rgb($TraceStr)=(Red,Green,Blue)
		endif
		DidWork = 1
	endif


	if (DidWork)
		LinSpaceLeftAxes(GraphStr)
		LineUpLeftAxes(GraphStr,"Left")
	endif		
	

	if (!StringMatch(OldYName,YName))
		SavedDataFolder = GetDataFolder(1)
		SetDataFolder(DataFolder)
		Rename TraceParms,$YName+"P"
		Rename TraceDescript,$YName+"D"
		SetPlotterControls(GraphStr,$YName+"P",$YName+"D")
		SetDataFolder(SavedDataFolder)
	elseif (!StringMatch(OldXName,XName))
		SetPlotterControls(GraphStr,TraceParms,TraceDescript)
	endif
	ControlUpdate/W=$GraphStr $"TracePopup"		//I dislike the way we have to deal with popups.

End //UpdatePlotterWaves


Function ARPlotterIndexSetVarFunc(CtrlName,VarNum,VarStr,VarName)
	String CtrlName		//used
	Variable VarNum		//not used
	String VarStr		//not used
	String VarName		//not used



	String GraphStr = WinName(0,1)
	String ControlName = "TracePopup"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		return(0)
	endif
	Variable Index = V_Value-1
	String TraceStr = S_Value

	String DataFolder = GetAR2DPlotterFolder(GraphStr,"")

	Wave/T TraceList = $DataFolder+"TraceList"


	Wave ParmWave = $TraceList[Index]+TraceStr+"P"
	Wave/T ParmDescript = $TraceList[Index]+TraceStr+"D"

	Wave MasterWave = $ParmDescript[%MasterWave][%Title]
	Variable RowIsX = ParmWave[%RowIsX][0]
	if (StringMatch(CtrlName,"XIndex*") == 1)
		ParmWave[%XIndex][0] = Limit(VarNum,-1,DimSize(MasterWave,!RowIsX)-1)
	else
		ParmWave[%YIndex][0] = Limit(VarNum,0,DimSize(MasterWave,!RowIsX)-1)
	endif

	if (ParmWave[%XIndex][0] == ParmWave[%YIndex][0])
		//oops
		ParmWave[%XIndex][0] = -1
		SetPlotterControls(GraphStr,ParmWave,ParmDescript)
	endif




	UpdatePlotterWaves(GraphStr,Index,1)


End //ARPlotterIndexSetVarFunc


Function ARPlotterLimitSetVarFunc(CtrlName,VarNum,VarStr,VarName)
	String CtrlName		//not used
	Variable VarNum		//not used
	String VarStr		//not used
	String VarName		//not used


	String GraphStr = WinName(0,1)
	String DataFolder = GetAR2DPlotterFolder(GraphStr,"")
	Wave/T TraceList = $DataFolder+"TraceList"
	String ControlName = "TracePopup"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		return(0)
	endif
	Variable Index = V_Value-1
	Wave ParmWave = $TraceList[Index][0]+GetDimLabel(TraceList,0,Index)+"P"

	UpdatePlotterWaves(GraphStr,Index,1)


	Variable DoAll = 0
	ControlInfo/W=$GraphStr AllCursor
	if (V_Flag)
		DoAll = v_value
	endif


	if (DoAll)
		Variable A, nop = DimSize(TraceList,0)
		for (A = 0;A < nop;A += 1)
			if (A == Index)
				continue
			endif
			Wave TempParmWave = $TraceList[A][0]+GetDimLabel(TraceList,0,A)+"P"
			TempParmWave[%Stop][0] = ParmWave[%Stop][0]
			TempParmWave[%Start][0] = ParmWave[%Start][0]
			UpdatePlotterWaves(GraphStr,A,1)
		endfor		
		
	endif


End //ARPlotterLimitSetVarFunc


Function ARPlotterCursorFunc(CtrlName)
	String CtrlName		//not used
	
	
	String GraphStr = WinName(0,1)
	String ControlName = "TracePopup"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		return(0)
	endif
	Variable Index = V_Value-1
	String TraceStr = S_Value

	String DataFolder = GetAR2DPlotterFolder(GraphStr,"")

	Wave/T TraceList = $DataFolder+"TraceList"

	Wave ParmWave = $TraceList[Index]+TraceStr+"P"
	Wave/T ParmDescript = $TraceList[Index]+TraceStr+"D"
	
	
	
	Variable IsA = IsCursor(GraphStr,"A")
	Variable IsB = IsCursor(GraphStr,"B")
	Variable Aval, BVal
	if (IsA)
		AVal = pcsr(A)
	else
		AVal = ParmWave[%Start][0]
	endif
	if (IsB)
		BVal = pcsr(B)
	else
		BVal = ParmWave[%Stop][0]
	endif

	
	Variable DoAll = 0
	ControlInfo/W=$GraphStr AllCursor
	if (V_Flag)
		DoAll = v_value
	endif

	
	if (IsA || IsB)
		ParmWave[%Stop][0] = Max(Aval,Bval)+ParmWave[%Start][0]
		ParmWave[%Start][0] += Min(AVal,BVal)
		if (IsB)
			Cursor/A=1/P/W=$GraphStr B $TraceStr abs(AVal-BVal)
		endif
		if (IsA)
			Cursor/A=1/P/W=$GraphStr A $TraceStr 0
		endif
		UpdatePlotterWaves(GraphStr,Index,1)

		if (DoAll)
			Variable A, nop = DimSize(TraceList,0)
			for (A = 0;A < nop;A += 1)
				if (A == Index)
					continue
				endif
				Wave ParmWave = $TraceList[A]+GetDimLabel(TraceList,0,A)+"P"
				ParmWave[%Stop][0] = Max(Aval,Bval)+ParmWave[%Start][0]
				ParmWave[%Start][0] += Min(AVal,BVal)
				UpdatePlotterWaves(GraphStr,A,1)
			endfor		
			
		endif		
	else
		ShowInfo/W=$GraphStr
		Cursor/A=1/P/W=$GraphStr A $TraceStr 0
		Cursor/A=1/P/W=$GraphStr B $TraceStr abs(AVal-BVal)
	endif
		
	
	
	
End //ARPlotterCursorFunc


Function SetPlotterAxisVar(CtrlName,VarNum,VarStr,VarName)
	String CtrlName		//not used
	Variable VarNum		//There is none (String)
	String VarStr		//used
	String VarName		//not used

	VarStr = CleanUpName(VarStr,0)
	
	String GraphStr = WinName(0,1)
	String DataFolder = GetAR2DPlotterFolder(GraphStr,"")
	Wave/T TraceList = $DataFolder+"TraceList"
	String ControlName = "TracePopup"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		return(0)
	endif
	Variable Index = V_Value-1
	String TraceStr = S_Value
	Wave/T ParmDescript = $TraceList[Index]+TraceStr+"D"
	ParmDescript[%Axis][0] = VarStr

	UpdatePlotterWaves(GraphStr,Index,1)
	LinSpaceLeftAxes(GraphStr)
	LineUpLeftAxes(GraphStr,"Left")

End //SetPlotterAxisVar


Function UpdateTrace(GraphStr,Info,TraceStr)
	String GraphStr
	String Info
	String TraceStr


//If they don't give us a number on the end of the trace str
//assume it is the last copy.


	if (IsNan(GetEndNum(TraceStr)))
		String TraceList = ARTraceNameList(GraphStr,TraceStr+"*","*","*","*")
		TraceStr = StringFromList(ItemsInList(TraceList,";")-1,TraceList,";")
	endif


	String st2find = "recreation:"

	Variable Index = strsearch(LowerStr(Info),st2find,0)
	if (Index < 0)
		return(0)
	endif

	Info = Info[Index+strlen(st2find),strlen(Info)-1]
	Info = ReplaceString("(x)",Info,"("+TraceStr+")",1)

	String Evil
	Variable A, nop = ItemsInList(Info,";")
	for (A = 0;A < nop;A += 1)
		Evil = "ModifyGraph/W="+GraphStr+"/Z "+StringFromList(A,Info,";")+";DelayUpdate;"
		Execute(Evil)
	endfor


End //UpdateTrace


Function RemovePlotterTrace(CtrlName)
	String CtrlName		//not used
	
	
	String GraphStr = WinName(0,1)
	String DataFolder = GetAR2DPlotterFolder(GraphStr,"")
	Wave/T TraceListWave = $DataFolder+"TraceList"
	String ControlName = "TracePopup"
	ControlInfo/W=$GraphStr $ControlName
	if (!V_Flag)
		return(0)
	endif
	Variable Index = V_Value-1
	String TraceStr = S_Value
	Wave/T ParmDescript = $TraceListWave[Index]+TraceStr+"D"
	DataFolder = TraceListWave[Index][0]
	if (DimSize(TraceListWave,0) < 2)
		return(0)
	endif
	
	//OK, First off, we need to remove the trace...


	String Axis = ParmDescript[%Axis][0]

	String TraceList = ARTraceNameList(GraphStr,TraceStr,Axis,"Bottom",DataFolder)
	
	TraceList = FlipLRStrList(TraceList,";")
	
	
	Variable A, nop = ItemsInList(TraceList,";")
	for (A = 0;A < nop;A += 1)
		RemoveFromGraph/W=$GraphStr/Z $StringFromList(A,TraceList,";")
	endfor
	
	//OK, we are clear....
	DeletePoints/M=0 Index,1,TraceListWave
	//OK, now what?
	//Lets kill the folder
	ReallySafeKillDataFolder(DataFolder)
	
	//OK, now we have to update the popup....
	
	
	PopUpMenu $"TracePopup",win=$GraphStr,mode=1
	
	
	Wave ParmWave = $TraceListWave[0][0]+GetDimLabel(TraceListWave,0,0)+"P"
	Wave/T ParmDescript = $TraceListWave[0][0]+GetDimLabel(TraceListWave,0,0)+"D"
	
	SetPlotterControls(GraphStr,ParmWave,ParmDescript)
	LinSpaceLeftAxes(GraphStr)
	LineUpLeftAxes(GraphStr,"Left")
	
	
End //RemovePlotterTrace


Function ARPlotterXFlipFunc(CtrlName,Checked)
	String CtrlName
	Variable Checked

	String AxisStr = "Bottom"
	String GraphStr = WinName(0,1)

	if (Checked)
		if (IsAxesReversed(GraphStr,AxisStr))
			return(0)
		endif
		if (IsAxisAuto(GraphStr,AxisStr))
			SetAxis/W=$GraphStr/A/R $AxisStr
		else
			GetAxis/W=$GraphStr/Q $AxisStr
			SetAxis/W=$GraphStr/R $AxisStr v_max,v_min
		endif
	else
		if (!IsAxesReversed(GraphStr,AxisStr))
			return(0)
		endif
		if (IsAxisAuto(GraphStr,AxisStr))
			SetAxis/W=$GraphStr/A $AxisStr
		else
			GetAxis/W=$GraphStr/Q $AxisStr
			SetAxis/W=$GraphStr $AxisStr v_max,v_min
		endif
	endif



End //ARPlotterXFlipFunc


