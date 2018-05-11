#pragma rtGlobals=1		// Use modern global access method.
//Suhas Somnath, UIUC 2009

Menu "Macros"
	"Smart Litho", SmartLithoDriver()
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
	Variable numlines = NumVarOrDefault(":gnumlines", 10)
	Variable/G gnumlines = numlines
	Variable linelength = NumVarOrDefault(":glinelength", 100)
	Variable/G glinelength = linelength
	Variable linesp = NumVarOrDefault(":glinesp", 50)
	Variable/G glinesp = linesp
	Variable lineangle = NumVarOrDefault(":glineangle", 90)
	Variable/G glineangle = lineangle	
	Variable Tbord = NumVarOrDefault(":gTbord", 10)
	Variable/G gTbord = Tbord
	Variable Bbord = NumVarOrDefault(":gBbord", 10)
	Variable/G gBbord = Bbord
	Variable Lbord = NumVarOrDefault(":gLbord", 10)
	Variable/G gLbord = Lbord
	Variable Rbord = NumVarOrDefault(":gRbord", 10)
	Variable/G gRbord = Rbord
	//Wave masterwave = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	//Variable/G gscansize = masterwave[0]
	
	// Create the control panel.
	Execute "SmartLithoPanel()"
	//Reset the datafolder to the root / previous folder
	SetDataFolder dfSave

End //SmartLithoDriver

Window SmartLithoPanel(): Panel

	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(485,145, 840,385) as "Smart Litho"
	SetDrawLayer UserBack
	
	TabControl tabcont, tabLabel(0)="Layers", value=0
	TabControl tabcont, tabLabel(1)="Lines"
	TabControl tabcont, tabLabel(2)="Squares", value=0
	TabControl tabcont, pos={5,5}, size={345,202}, proc=TabProc
	
	//Wave masterwave = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	//Variable scansize = masterwave[0]
	//String dfSave = GetDataFolder(1)
	//SetDataFolder root:packages:SmartLitho
	//NVAR gscansize
	//Variable scansize = gscansize
	//SetDataFolder dfSave
	Variable scansize = 20000// in nanometers
	
	DrawText 17,52, "Line Parameters:"
	
	SetVariable setvarnumlines,pos={40,69},size={114,18},title="Number of"
	SetVariable setvarnumlines,value= root:packages:SmartLitho:gnumlines,live= 1
	SetVariable setvarlinelength,pos={201,69},size={126,18},title="Length (nm)", limits={0,(1*scansize),1}	
	SetVariable setvarlinelength,value= root:packages:SmartLitho:glinelength,live= 1
	
	SetVariable setvarangle,pos={35,95},size={119,18},title="Angle (deg)", limits={0,180,1}
	SetVariable setvarangle,value= root:packages:SmartLitho:glineangle,live= 1
	SetVariable setvarlinespace,pos={192,95},size={135,18},title="Spacing (nm)", limits={0,(0.5*scansize),1}
	SetVariable setvarlinespace,value= root:packages:SmartLitho:glinesp,live= 1
	
	DrawText 18,146, "Borders:"
	
	SetVariable setvarTbord,pos={44,153},size={108,18},title="Top (nm)", limits={0,(1*scansize),1}
	SetVariable setvarTbord,value= root:packages:SmartLitho:gTbord,live= 1
	SetVariable setvarBbord,pos={203,153},size={126,18},title="Bottom (nm)", limits={0,(1*scansize),1}
	SetVariable setvarBbord,value= root:packages:SmartLitho:gBbord,live= 1
	
	SetVariable setvarLbord,pos={45,178},size={106,18},title="Left (nm)", limits={0,(1*scansize),1}
	SetVariable setvarLbord,value= root:packages:SmartLitho:gLbord,live= 1
	SetVariable setvarRbord,pos={213,178},size={117,18},title="Right (nm)", limits={0,(1*scansize),1}
	SetVariable setvarRbord,value= root:packages:SmartLitho:gRbord,live= 1
	
	Button buttonDrawPattern,pos={14,214},size={100,20},title="Draw Pattern", proc=drawPattern
	Button buttonClearPattern,pos={143,214},size={70,20},title="Clear", proc=clearPattern
	Button buttonSavePattern,pos={238,214},size={100,20},title="Save Pattern", proc=savePattern
	
EndMacro //SmartLithoPanel

Function TabProc (ctrlName, tabNum) : TabControl
	String ctrlName
	Variable tabNum
	
	Variable isTab0= tabNum==0
	Variable isTab1= tabNum==1
	Variable isTab2= tabNum==2
	
	//disable=0 means show, disable=1 means hide
	
	//more details - refer to 
	// http://wavemetrics.net/doc/III-14 Control Panels.pdf
	
	//Tab 1: Lines
	ModifyControl setvarnumlines disable= !isTab1 // hide if not Tab 1
	ModifyControl setvarlinelength disable= !isTab1 // hide if not Tab 1
	ModifyControl setvarlinespace disable= !isTab1 // hide if not Tab 1
	ModifyControl setvarangle disable= !isTab1 // hide if not Tab 1
	
	ModifyControl setvarLbord disable= !isTab1 // hide if not Tab 1
	ModifyControl setvarRbord disable= !isTab1 // hide if not Tab 1
	ModifyControl setvarTbord disable= !isTab1 // hide if not Tab 1
	ModifyControl setvarBbord disable= !isTab1 // hide if not Tab 1
	
	//Tab 2:
	//ModifyControl buttonDrawPattern disable= !isTab0 // hide if not Tab 0
	//ModifyControl buttonClearPattern disable= !isTab0 // hide if not Tab 0
	//ModifyControl buttonSavePattern disable= !isTab0 // hide if not Tab 0
	
	return 0
End // TabProc

Function drawPattern(ctrlname) : ButtonControl
	String ctrlname

	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	Wave masterwave = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	Variable scansize = masterwave[0]
	// Note: keep in mind that the scan size will change if the ratio width: height is changed
	// Can assume for now that that is set to 1:1
	
	NVAR gnumlines,glinelength,glinesp,glineangle,gTbord, gBbord, gLbord, gRbord
	
	// setting the scale of the variables correctly to meters:
	glinelength = glinelength * 1e-9
	glinesp = glinesp * 1e-9
	gTbord = gTbord * 1e-9
	gBbord = gBbord * 1e-9
	gLbord = gLbord * 1e-9
	gRbord = gRbord * 1e-9
	
	// Coordinates of the actual writing box:
	Variable leftlimit = masterwave[5] + gLbord
	Variable rightlimit = masterwave[5] + scansize - gRbord
	Variable toplimit = masterwave[6] +scansize - gTbord
	Variable bottomlimit = masterwave[6] + scansize
	
	if(leftlimit > rightlimit || toplimit < bottomlimit)
		return -1
	endif
	
	//Pass on these parameters to the actual drawing function:
	drawLines(leftlimit,rightlimit,bottomlimit,toplimit,   gnumlines, glinelength, glineangle,glinesp)
	
	// resetting the scale of the variables to nanometers:
	glinelength = glinelength * 1e+9
	glinesp = glinesp * 1e+9
	gTbord = gTbord * 1e+9
	gBbord = gBbord * 1e+9
	gLbord = gLbord * 1e+9
	gRbord = gRbord * 1e+9
			
End // drawPattern

Function clearPattern(ctrlname) : ButtonControl
	String ctrlname
	LithoGroupFunc("KillGroup_0")
End // endPattern

Function savePattern(ctrlname) : ButtonControl
	String ctrlname
	LithoGroupFunc("SaveWave")
End // savePattern

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////  Main Draw Lines ///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
Function drawLines(xstart,xend,ystart,yend,   numlines, length, dangle,space)
	Variable xstart, xend,ystart,yend,   numlines, length,dangle,space
	
	//Convert the angle to radians:
	Variable angle = dangle * (pi/180)
	
	//Check if we're drawing from left-to-right or top-to-bottom using the angle:
	if (dangle >= 15 && dangle <= 165)
       	 // Writing left to right from ceiling
        	// calculate horizontal dist between lines:
        	Variable hspace = space * sin(angle)
        	print "Come to L to R"
        	drawLtoR(xstart, xend, ystart, yend, numlines, length, angle, hspace)
        
    	elseif ((dangle < 15 && dangle >= 0) || (dangle > 165 && dangle <= 180))
       	// Writing top to bottom on the left wall
        	// calculate vertical dist between lines:
        	Variable vspace = abs(space * cos(angle))
        	print "come to T ot B"
        	drawTtoB(xstart, xend, ystart, yend, numlines, length, angle, vspace)
        
    	else
        	return -1
    	endif
    	
    	// Duplicate the right waves that are used for rendering
    	print numpnts(root:packages:SmartLitho:XLitho)
	Duplicate/O root:packages:SmartLitho:XLitho, root:packages:MFP3D:Litho:XLitho
	Duplicate/O root:packages:SmartLitho:YLitho, root:packages:MFP3D:Litho:YLitho
End//drawLines
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////Draw Left to Right ///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
Function drawLtoR(xstart, xend, ystart, yend, numlines, length, angle, space)
	Variable xstart, xend, ystart, yend, numlines, length, angle, space
	
	Variable xcurrent = xstart + space;
    
    	Variable ydecrement = abs(length * sin(angle));
    
    	// Accounting for lines jumping outside the bottommost limit
    	if ((yend - ydecrement) < ystart)
        	ydecrement = ystart - yend;
    	endif
    
    	// Similar simple limit cannot be placed yet
    	// x truncation must be done at time of addition
    	// to matrix
    	Variable xdecrement = abs(length * cos(angle));
    
   	if((angle * (180/pi)) >= 90)
        	xdecrement = xdecrement * -1;
        	// Accounts for the first line completely
        	// going outside the the field in case
        	// of small angles
        	xcurrent = xcurrent - space;
    	endif
    
    	// Check how many lines can actually be drawn with the
    	// given gap:
    	numlines = min(numlines,abs( floor( (xend - xcurrent)/space)));

	//Make the data holding waves
	Make/O/N=(numlines*3) XLitho
	Make/O/N=(numlines*3) YLitho
	
	//Starting the coordinates  calculation part:
	Variable i = 0
	for (i=0; i<3*numlines; i+=3)
		//Begin point:
		XLitho[i] = xcurrent;
        	YLitho[i] = yend;
		
		//End point:
		if((xcurrent - xdecrement) > xend)
	            	// This happens for angles > 90 only:
	            	// the end point is stepping too far right
	           	// allowable frame. Must truncate the
	            	// end point:
	            
	            	// Using point slope method to determine
	            	// ending y position:
            		XLitho[i+1] = xend;
         	   	YLitho[i+1] = yend + (tan(angle)* (xend-xcurrent));
         	   	
        	elseif ((xcurrent - xdecrement) < xstart)
            		// This happens for angles < 90 only:
            		// the end point is stepping too far to the left
            		XLitho[i+1] = xstart;
            		YLitho[i+1] = yend + (tan(angle)* (xstart-xcurrent));
            		
        	else
        		// point happens to lie completely within
        		// the box
            		XLitho[i+1] = xcurrent - xdecrement;
            		YLitho[i+1] = yend - ydecrement;
            		
        	endif
        	
        	//Empy space:
        	XLitho[i+2] = nan
		YLitho[i+2] = nan
		
		xcurrent = xcurrent + space;
        
         	//X position cut off:
       	if ( xcurrent >= xend)
       		// All possible border conditions
       		// must have been taken care of
       		// by now. Should not be coming
       		// in here....just for security:
            		break
        	endif
	endfor
End//drawLtoR

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////Draw Top to Bottom ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function drawTtoB(xstart, xend, ystart, yend, numlines, length, angle, space)
	Variable xstart, xend, ystart, yend, numlines, length, angle, space
	
	Variable ycurrent = yend - space;
    	
    	Variable xincrement = abs(length * cos(angle));
    	
    	// Accounting for lines jumping outside the rightmost limit
    	if((xstart + xincrement) > xend)
        	xincrement = xend - xstart;
    	endif
    	
    	// Similar simple limit cannot be placed yet
    	// y truncation must be done at time of addition
    	// to matrix
    	Variable yincrement = abs(length * sin(angle));
    	
    	if((angle * (180/pi)) > 90 || angle == 0)
        	yincrement = yincrement * -1;
        	// Accounts for the first line completely
        	// going outside the the field in case
        	// of small angles
        	ycurrent = ycurrent + space;
    	endif
    
    	// Check how many lines can actually be drawn with the
    	// given gap:
    	numlines = min( numlines,abs( floor( (ystart - ycurrent)/space)));
    	//sprintf('Number of lines changed to %d',numlines);
    	
    	//Make the data holding waves
	Make/O/N=(numlines*3) XLitho
	Make/O/N=(numlines*3) YLitho

	//Starting the coordinates  calculation part:
	Variable i = 0
	for (i=0; i<3*numlines; i+=3)
	
        	XLitho[i] = xstart;
        	YLitho[i] = ycurrent;
            
        	if((yincrement + ycurrent) < ystart)
            		// This happens for angles > 165 only:
            		// the end point is dipping below the
            		// allowable frame. Must truncate the
            		// end point:
            
            		// Using point slope method to determine
            		// ending x position:
            		XLitho[i+1] = ((ystart - ycurrent)/tan(angle)) + xstart;
            		YLitho[i+1] = ystart;
        	elseif (yincrement + ycurrent > yend)
            		// This happens for angles <15 only:
            		// The end point is above the top limit
            		XLitho[i+1] = ((yend - ycurrent)/tan(angle)) + xstart;
            		YLitho[i+1] = yend;
        	else
            		XLitho[i+1] = xstart + xincrement;
            		YLitho[i+1] = ycurrent + yincrement;
        	endif
           
        	ycurrent = ycurrent - space;
        	
        	//Empy space:
        	XLitho[i+2] = nan
		YLitho[i+2] = nan
        
        	// Y position cut off:
        	if(ycurrent <= ystart)
            		break;
        	endif
    endfor

End//drawToB

// Note: 
// Waves are stored in root:packages:MFP3D:Litho:Ymywavename, Xmywavename
// Currently MFP allows loading and saving of SINGLE patterns ONLY
// LithoGroupFunc("SaveWave")
// LithoGroupFunc("LoadWave")
// Need to come up with a way of merging 
// Such a function will heavily be derived from the load wave pre-written function
// except, it doesn't erase whatever is already there in the XLitho and the YLitho
// Appending may require some reading up