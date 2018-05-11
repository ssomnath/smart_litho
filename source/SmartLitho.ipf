#pragma rtGlobals=1		// Use modern global access method.

//Suhas Somnath, UIUC 2009
// Last - variable scansize, handled non written waves XLitho..- null pointer exception, removed the layers panel

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
	Wave mw = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	Variable scansize = mw[0]*1e+9
	
	// Line variables:
	Variable numlines = NumVarOrDefault(":gnumlines", 10)
	Variable/G gnumlines = numlines
	Variable linelength = NumVarOrDefault(":glinelength", (scansize/4))
	Variable/G glinelength = linelength
	Variable linesp = NumVarOrDefault(":glinesp", (scansize/10))
	Variable/G glinesp = linesp
	Variable lineangle = NumVarOrDefault(":glineangle", 90)
	Variable/G glineangle = lineangle	
	
	// Border Variables:
	Variable Tbord = NumVarOrDefault(":gTbord", (scansize/20))
	Variable/G gTbord = Tbord
	Variable Bbord = NumVarOrDefault(":gBbord", (scansize/20))
	Variable/G gBbord = Bbord
	Variable Lbord = NumVarOrDefault(":gLbord", (scansize/20))
	Variable/G gLbord = Lbord
	Variable Rbord = NumVarOrDefault(":gRbord", (scansize/20))
	Variable/G gRbord = Rbord
	
	// Text variables:
	String /G gText = ""
	Variable textheight = NumVarOrDefault(":gtextheight", (scansize/20))
	Variable/G gtextheight = textheight
	Variable textwidth = NumVarOrDefault(":gtextwidth", (scansize/20))
	Variable/G gtextwidth = textwidth
	
	// Create the control panel.
	Execute "SmartLithoPanel()"
	//Reset the datafolder to the root / previous folder
	SetDataFolder dfSave

End //SmartLithoDriver

Window SmartLithoPanel(): Panel

	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(485,145, 840,445) as "Smart Litho"
	SetDrawLayer UserBack
	
	TabControl tabcont, tabLabel(0)="Lines"
	TabControl tabcont, tabLabel(1)="Text", value=0
	TabControl tabcont, pos={5,5}, size={345,200}, proc=TabProc
	
	Variable scansize = root:Packages:MFP3D:Main:Variables:MasterVariablesWave[0]*1e+9
	//print "scan size = " + num2str(scansize)
	scansize = max(20000,scansize)
	//resetting the scansize to the default size:
	//root:Packages:MFP3D:Main:Variables:MasterVariablesWave[0] = 20e-6
	//print "scan size = " + num2str(scansize)
	//Variable scansize = 20000// in nanometers
	
	//DrawText 17,52, "Line Parameters:"
	SetVariable lineparams,pos={18,42},size={110,18},title="Line Parameters:", limits={0,0,0}, disable=2, noedit=1	
	
	SetVariable setvarnumlines,pos={40,69},size={114,18},title="Number of"
	SetVariable setvarnumlines,value= root:packages:SmartLitho:gnumlines,live= 1
	SetVariable setvarlinelength,pos={201,69},size={126,18},title="Length (nm)", limits={0,(1*scansize),1}	
	SetVariable setvarlinelength,value= root:packages:SmartLitho:glinelength,live= 1
	
	SetVariable setvarangle,pos={35,95},size={119,18},title="Angle (deg)", limits={0,180,1}
	SetVariable setvarangle,value= root:packages:SmartLitho:glineangle,live= 1
	SetVariable setvarlinespace,pos={192,95},size={135,18},title="Spacing (nm)", limits={0,(0.5*scansize),1}
	SetVariable setvarlinespace,value= root:packages:SmartLitho:glinesp,live= 1
	
	//DrawText 18,146, "Borders:"
	SetVariable bordparams,pos={18,128},size={110,18},title="Border Parameters:", limits={0,0,0}, disable=2, noedit=1
	
	SetVariable setvarTbord,pos={44,153},size={108,18},title="Top (nm)", limits={0,(1*scansize),1}
	SetVariable setvarTbord,value= root:packages:SmartLitho:gTbord,live= 1
	SetVariable setvarBbord,pos={203,153},size={126,18},title="Bottom (nm)", limits={0,(1*scansize),1}
	SetVariable setvarBbord,value= root:packages:SmartLitho:gBbord,live= 1
	
	SetVariable setvarLbord,pos={45,178},size={106,18},title="Left (nm)", limits={0,(1*scansize),1}
	SetVariable setvarLbord,value= root:packages:SmartLitho:gLbord,live= 1
	SetVariable setvarRbord,pos={213,178},size={117,18},title="Right (nm)", limits={0,(1*scansize),1}
	SetVariable setvarRbord,value= root:packages:SmartLitho:gRbord,live= 1
	
	
	
	// Tab #1: Text:
	SetVariable textparams,pos={18,42},size={110,18},title="Text Parameters:", limits={0,0,0}, disable=2, noedit=1	
	
	SetVariable setvartext,pos={35,69},size={120,18},title="Text:"
	SetVariable setvartext,value= root:packages:SmartLitho:gText,live= 1
	
	SetVariable setvartextht,pos={35,95},size={119,18},title="Height (nm)", limits={0,(1*scansize),1}
	SetVariable setvartextht,value= root:packages:SmartLitho:gtextheight,live= 1
	SetVariable setvartextwt,pos={211,95},size={116,18},title="Width (nm)", limits={0,(1*scansize),1}
	SetVariable setvartextwt,value= root:packages:SmartLitho:gtextwidth,live= 1
	
	Button buttontext, pos={226,68}, size={100,20}, title = "Draw Text!", proc=drawString
	
	// Global buttons:
	DrawText 14,231, "Pattern Functions:"
	
	Button buttonDrawPattern,pos={21,240},size={100,20},title="Draw New", proc=drawNew
	Button buttonUndo,pos={142,240},size={70,20},title="Undo", proc=undoLastPattern
	Button buttonAppendPattern,pos={234,240},size={100,20},title="Append", proc=appendPattern
	
	Button buttonLoadPattern,pos={21,270},size={100,20},title="Load New", proc=loadPattern
	Button buttonClearPattern,pos={142,270},size={70,20},title="Clear", proc=clearPattern
	Button buttonSavePattern,pos={234,270},size={100,20},title="Save", proc=savePattern
	
EndMacro //SmartLithoPanel

Function TabProc (ctrlName, tabNum) : TabControl
	String ctrlName
	Variable tabNum
	
	Variable isTab0= tabNum==0
	Variable isTab1= tabNum==1
	
	//disable=0 means show, disable=1 means hide
	
	//more details - refer to 
	// http://wavemetrics.net/doc/III-14 Control Panels.pdf
	
	//Tab 0: Lines
	ModifyControl lineparams disable= !isTab0
	ModifyControl setvarnumlines disable= !isTab0 // hide if not Tab0
	ModifyControl setvarlinelength disable= !isTab0 // hide if not Tab 0
	ModifyControl setvarlinespace disable= !isTab0 // hide if not Tab 0
	ModifyControl setvarangle disable= !isTab0 // hide if not Tab 0
	
	//ModifyControl bordparams disable= !isTab0
	//ModifyControl setvarLbord disable= !isTab0 // hide if not Tab 0
	//ModifyControl setvarRbord disable= !isTab0 // hide if not Tab 0
	//ModifyControl setvarTbord disable= !isTab0 // hide if not Tab 0
	//ModifyControl setvarBbord disable= !isTab0 // hide if not Tab 0
	
	//Tab 1: Text:
	ModifyControl textparams disable= !isTab1 // hide if not Tab 1
	ModifyControl buttontext disable = !isTab1 // hide if not Tab 1
	ModifyControl setvartext disable= !isTab1 // hide if not Tab 1
	ModifyControl setvartextht disable= !isTab1 // hide if not Tab 1
	ModifyControl setvartextwt disable= !isTab1 // hide if not Tab 1
	
	return 0
End // TabProc

Function clearPattern(ctrlname) : ButtonControl
	String ctrlname
	// backing up the current state of the MFP waves:
	backupState()
	
	DrawLithoFunc("EraseAll")	
End // endPattern

Function savePattern(ctrlname) : ButtonControl
	String ctrlname	
	LithoGroupFunc("SaveWave")
End // savePattern

Function loadPattern(ctrlname) : ButtonControl
	String ctrlname
	
	// backing up the current state of the MFP waves:
	backupState()
	
	LithoGroupFunc("LoadWave")
End // savePattern

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
	
	//Lines not rendering for the first time-> Save and then load for now???
	DrawLithoFunc("DrawWave")	
	
	// Resetting the data folder
	SetDataFolder dfsave
	
End // savePattern

Function backupState()
	
	// Storing the old working folder:
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	// Make two dummy waves in the SmartLitho folder:
	Make/O/N=1 old_XLitho
	Make/O/N=1 old_YLitho
	
	// Duplicate the MFP waves that are used for rendering
	Duplicate/O root:packages:MFP3D:Litho:XLitho, root:packages:SmartLitho:old_XLitho
	Duplicate/O root:packages:MFP3D:Litho:YLitho, root:packages:SmartLitho:old_YLitho
	
	// Resetting the data folder
	SetDataFolder dfsave
	
End // backupState

Function addExternalPattern(ctrlname) : ButtonControl
	String ctrlname
	// This must borrow heavily from the Load function
	// However it is one step more complicated as it must:
	// 1. Take a backup of the previous state of the XLitho, YLitho
	// 2. Find the waves to load using the Load's code
	// 3. Append the current XLitho, YLitho with these waves.
End // addExternalPattern

Function drawString(ctrlname) : ButtonControl
	String ctrlname
	
	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
		
	SVAR gText
	//gText = ReplaceString(" ",gText,"_",1)		//fight the users urge to use spaces.
	//print "global text val = " + gText
	
	if(strlen(gText) == 0)
		print "Error: Nothing to write. Aborting!"
		return -1
	endif
	
	NVAR gtextwidth, gtextheight,gTbord, gBbord, gLbord, gRbord	
	Wave masterwave = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	Variable scansize = masterwave[0]
	
	// setting the scale of the variables correctly to meters:
	Variable textheight = gtextheight * 1e-9
	Variable textwidth = gtextwidth * 1e-9
	Variable Tbord = gTbord * 1e-9
	Variable Bbord = gBbord * 1e-9
	Variable Lbord = gLbord * 1e-9
	Variable Rbord = gRbord * 1e-9
	
	// Coordinates of the actual writing box:
	Variable leftlimit = masterwave[5] + Lbord
	Variable rightlimit = masterwave[5] + scansize - Rbord
	Variable toplimit = masterwave[6] +scansize - Tbord
	Variable bottomlimit = masterwave[6] + Bbord
	
	if(leftlimit > rightlimit || toplimit < bottomlimit)
		return -1
	endif
	
	// Backing up state:
	backupState()
	
	// Number of chars that can be written in one line:
	// Assumes space between each char is half the char width
	Variable linelimit = (rightlimit - leftlimit) / (textwidth * 1.5)
	//print "Char limit = " + num2str(linelimit)
	
	linelimit = min(strlen(gText),linelimit)
	//print "Reduced char limit = " + num2str(linelimit)
	
	print "---------------------------------------------------------------------------------------"
	print "box coordinates: start : (" + num2str(leftlimit) + ", " + num2str(toplimit) + "), end: (" + num2str(rightlimit) + ", " + num2str(bottomlimit) + ")"
	print "font stats: height = " + num2str(textheight) + ", width = " + num2str(textwidth)
	
	Variable i = 0
	Variable xstart = leftlimit
	
	for(i=0; i<linelimit; i+=1)
		
		//Printing stats:
		print "Char stats: char = '" + gText[i] + "', xstart = " + num2str(xstart) + ", ystart = " + num2str(toplimit - textheight)
	
		drawAlphabet(Upperstr(gText[i]), xstart, (toplimit - textheight), textheight, textwidth)
		xstart = xstart + (1.5*textwidth)
		
		// Appending the waves:
		appendWaves(root:packages:MFP3D:Litho:XLitho, XLitho,"appendedX")
		appendWaves(root:packages:MFP3D:Litho:YLitho, YLitho,"appendedY")
	
		// Duplicate the right waves that are used for rendering
		Duplicate/O root:packages:SmartLitho:appendedX, root:packages:MFP3D:Litho:XLitho
		Duplicate/O root:packages:SmartLitho:appendedY, root:packages:MFP3D:Litho:YLitho
	
		// Clean up:
		KillWaves appendedX, appendedY
		
		//Lines not rendering for the first time-> Save and then load for now???
		DrawLithoFunc("DrawWave")	
	endfor
	
	print "---------------------------------------------------------------------------------------"	
	
	// Calculating the total time to litho:
	CalcLithoTime()
	
	SetDataFolder dfSave
	
End // drawString

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
	drawCurrentPattern()
	
	if( exists("XLitho") != 1 || exists("YLitho") != 1)
		// If the litho was not performed at all such waves
		// will not exist. Abort!!!
		print "Error: Check parameters, especially wrt scansize"
		return -1;
	endif
		
	// Appending the waves:
	appendWaves(root:packages:MFP3D:Litho:XLitho, XLitho,"appendedX")
	appendWaves(root:packages:MFP3D:Litho:YLitho, YLitho,"appendedY")
	
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
	
	drawCurrentPattern()
	
	if( exists("XLitho") != 1 || exists("YLitho") != 1)
		// If the litho was not performed at all such waves
		// will not exist. Abort!!!
		print "Error: Check parameters, especially wrt scansize"
		return -1;
	endif
	
	// Drawing completed by now:
	// Duplicate the right waves that are used for rendering
	Duplicate/O root:packages:SmartLitho:XLitho, root:packages:MFP3D:Litho:XLitho
	Duplicate/O root:packages:SmartLitho:YLitho, root:packages:MFP3D:Litho:YLitho
	
	//Lines not rendering for the first time-> Save and then load for now???
	DrawLithoFunc("DrawWave")	
	
	// Calculating the total time to litho:
	CalcLithoTime()
	
End // drawFreshly

Function drawCurrentPattern() 

	String dfSave = GetDataFolder(1)
	SetDataFolder root:packages:SmartLitho
	
	Wave masterwave = root:Packages:MFP3D:Main:Variables:MasterVariablesWave
	Variable scansize = masterwave[0]
	// Note: keep in mind that the scan size will change if the ratio width: height is changed
	// Can assume for now that that is set to 1:1
	
	NVAR gnumlines,glinelength,glinesp,glineangle,gTbord, gBbord, gLbord, gRbord
	
	// setting the scale of the variables correctly to meters:
	Variable linelength = glinelength * 1e-9
	Variable linesp = glinesp * 1e-9
	Variable Tbord = gTbord * 1e-9
	Variable Bbord = gBbord * 1e-9
	Variable Lbord = gLbord * 1e-9
	Variable Rbord = gRbord * 1e-9
	
	// Coordinates of the actual writing box:
	Variable leftlimit = masterwave[5] + Lbord
	Variable rightlimit = masterwave[5] + scansize - Rbord
	Variable toplimit = masterwave[6] +scansize - Tbord
	Variable bottomlimit = masterwave[6] + Bbord
	
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
	
	print "-------------------------------------------------------------------------------------------------------------------------"
	//print "Drawing parameters - xstart, xend,ystart,yend,   numlines, length,dangle,space"
	//print "Drawing Parameters (meters):"
	print "box coordinates: start : (" + num2str(xstart) + ", " + num2str(ystart) + "), end: (" + num2str(xend) + ", " + num2str(yend) + ")"
	//print xend
	//print ystart
	//print yend
	print "line parameters: " + num2str(numlines) + " lines, angle = " + num2str(dangle) + " degrees, spacing = "+ num2str(space)  + ""
	//print numlines
	//print length
	//print dangle
	//print space
	print "-------------------------------------------------------------------------------------------------------------------------"
	
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
	
	
    
    	Variable ydecrement = abs(length * sin(angle));
    
    	// Accounting for lines jumping outside the bottommost limit
    	if ((yend - ydecrement) < ystart)
    		// if willing to work with whatever max length is fine:
        	//ydecrement = ystart - yend;
        	
        	// If very worried about exact length:
        	print "Length prescribed > scansize. NOT drawing pattern"
        	return -1
        	
    	endif
    
    	// Similar simple limit cannot be placed yet
    	// x truncation must be done at time of addition
    	// to matrix
    	Variable xdecrement = abs(length * cos(angle));
    	
    	// Default starting value = value for angle < 90
    	// Accounts for the first line completely
       // going outside the the field in case
       // of  angles < 90:
    	Variable xcurrent = xstart + xdecrement;
    	    
   	if((angle * (180/pi)) >= 90)
   	
   		// xcurrent can start of at its original position
        	// for angle > 90
        	xcurrent = xcurrent - xdecrement;
   	
   		// actually incrementing x for angle > 90:
        	xdecrement = xdecrement * -1;
        	
    	endif
    
    	// Check how many lines can actually be drawn with the
    	// given gap:
    	// numlines = min(numlines,abs( floor( (xend - xcurrent)/space)));
    	
    	// A more stringent constraint set for lines that can only be 
    	// drawn if their whole length can be drawn:    	
    	numlines = min(numlines, abs( floor( (((xend - xstart) - abs(xdecrement)) / space)+1 )));
    	print "Num lines now changed to "+ num2str(numlines)
	
	//Make the data holding waves
	Make/O/N=(numlines*3) XLitho
	Make/O/N=(numlines*3) YLitho
	
	//Starting the coordinates  calculation part:
	Variable i = 0
	// Change this variable to allow swapping of starts and ends alternating for lines:
	Variable allowswap = 0
	
	Variable swapstart = 0
	
	for (i=0; i<3*numlines; i+=3)
	
		// Adding intelligence to swap the start and 
		// end points to cut down the drawing time:
		Variable stpt = i
		Variable endpt = i+1
		
		if (swapstart == 1 && allowswap == 1)
			stpt = i+1
			endpt = i
		endif
		
		//Begin point:
		XLitho[stpt] = xcurrent;
        	YLitho[stpt] = yend;
		
		//End point:
		if((xcurrent - xdecrement) > xend)
	            	// This happens for angles > 90 only:
	            	// the end point is stepping too far right
	           	// allowable frame. Must truncate the
	            	// end point:
	            
	            	// Using point slope method to determine
	            	// ending y position:
            		XLitho[endpt] = xend;
         	   	YLitho[endpt] = yend + (tan(angle)* (xend-xcurrent));
         	   	
        	elseif ((xcurrent - xdecrement) < xstart)
            		// This happens for angles < 90 only:
            		// the end point is stepping too far to the left
            		XLitho[endpt] = xstart;
            		YLitho[endpt] = yend + (tan(angle)* (xstart-xcurrent));
            		
        	else
        		// point happens to lie completely within
        		// the box
            		XLitho[endpt] = xcurrent - xdecrement;
            		YLitho[endpt] = yend - ydecrement;
            		
        	endif
        	
        	// Setting the swap:
        	if (swapstart == 0 && allowswap == 1)
        		swapstart = 1
        	else
        		swapstart = 0
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
	   	
    	Variable xincrement = abs(length * cos(angle));
    	
    	// Accounting for lines jumping outside the rightmost limit
    	if((xstart + xincrement) > xend)
        	//xincrement = xend - xstart;
        	
        	//more stringent requirements of EXACT line 
        	// lengths only:
        	print "Lines too long. Litho aborting"
        	return -1
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
    	//numlines = min( numlines,abs( floor( (ystart - ycurrent)/space)));
    	
    	// For more stringent requirements - no truncated lines may be drawn:
    	
    	numlines = min (numlines, floor(abs((    (     abs(ystart - yend) - abs(yincrement)    ) / space  ) + 1)))
    	
    	//Make the data holding waves
	Make/O/N=(numlines*3) XLitho
	Make/O/N=(numlines*3) YLitho

	//Starting the coordinates  calculation part:
	Variable i = 0
	
	// Change this variable to allow swapping of starts and ends alternating for lines:
	Variable allowswap = 0
	
	Variable swapstart = 0
	
	for (i=0; i<3*numlines; i+=3)
	
		// Adding intelligence to swap the start and 
		// end points to cut down the drawing time:
		Variable stpt = i
		Variable endpt = i+1
		
		if (swapstart == 1 && allowswap == 1)
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
        	if (swapstart == 0 && allowswap == 1)
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

// Note: 
// Waves are stored in root:packages:MFP3D:Litho:LithoWaves:Ymywavename, Xmywavename
// Currently MFP allows loading and saving of SINGLE patterns ONLY
// LithoGroupFunc("SaveWave")
// LithoGroupFunc("LoadWave")
// Need to come up with a way of merging 
// Such a function will heavily be derived from the load wave pre-written function
// except, it doesn't erase whatever is already there in the XLitho and the YLitho
// Appending may require some reading up