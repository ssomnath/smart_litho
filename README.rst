Smart Litho Art Suite
=====================

Suhas Somnath

University of Illinois Urbana-Champaign

Last Updated: 2/13/2011 (v.1.7)

Contents
--------

`1. Installing and starting up the Smart Litho software:
2 <#installing-and-starting-up-the-smart-litho-software>`__

`2. Smart Litho Art Suite 2 <#smart-litho-art-suite>`__

`2.1. Lines Tab 3 <#lines-tab>`__

`2.2 Text Tab: 5 <#text-tab>`__

`2.3 General Functions 6 <#general-functions>`__

`2.4. Layers Tab 8 <#layers-tab>`__

.. _section-1:

Installing
-----------
The software consists of two procedure files containing the source code
named ``Alphabets.ipf`` and ``SmartLitho.ipf`` as well as this help file.
Currently, the user is required to follow these instructions to use the
software each time the Asylum Research software is opened up:

a) Start up the Asylum Research software.

b) Double click to open both the procedure files: ``Alphabets.ipf`` and
   ``SmartLitho.ipf``. Two windows showing the code within each file should
   open up in Igor Pro.

c) The code needs to be compiled to enable its use. There are two ways
   to do this:

   i.  Click on the ``Macros`` menu button next to ``File``, ``Edit``, and
       ``Data``. Next select ``Compile``.

   ii. Another way to do this is to click the "compile" button in the
       bottom left corner of either of the windows that have popped up.

d) To start up ``SmartLitho`` click on ``Macros`` menu button, select ``UIUC
   Lithography``, and then choose ``Smart Litho Art Suite``

2. Smart Litho Art Suite
========================

The Smart Litho Arte Suite consists of four main components:

a. Lines Tab

b. Text Tab

c. General Functions

d. Layers Tab

2.1. Lines Tab
--------------

This tab lets the user draw multiple parallel lines of arbitrary length,
orientation and spacing. The following steps need to be followed to draw
a pattern of lines:

a) **Borders** for the scan area are first entered in the four input
   boxes that enable the user to confine the positioning of the pattern.
   The default border is set to 1 micron from the edges of the scan
   area.

b) Basic **Line Parameters** are then specified with the number of
   parallel lines, orientation, length and spacing.

c) Additional constraining parameters can be specified using the
   **Advanced Controls**:

   iii. **Direction**: By default, the lines will be drawn with the same
           vector direction. The two additional options include **Switch
           All** that switches the vector direction of all the lines.
           The last option **Switch Alternate** allows the user to
           switch the orientation of every alternate line.

   iv.  **Length**: By default, lines extending outside the border will
           automatically **truncated**. However, by setting this option
           to **Exact** it is possible to force the program to draw
           lines of the exact specified length in the basic line
           parameters.

   v.   **Show Direction Arrows**: This is borrowed from the
           **Microangelo** suite. On checking this option, the user is
           shown the direction of the lines being drawn.

d) The lines are finally drawn by clicking on the **Draw New** button.

|image0|

**Figure 1**. Lines Tab - 7 out of 10 lines that the program attempted
to draw. A shows the maximum length of 15 microns. B shows the
counter-clockwise angle of 45 degrees of each line. C shows the
perpendicular spacing of 4 microns between adjacent lines. D shows the
direction of the lines that were drawn. E shows that truncated lines
were drawn within the specified boundary.

2.2 Text Tab:
-------------

This tab allows the user to write alphanumeric characters using lines.
The rules regarding borders apply to this tab as well. The text is drawn
by clicking on the Draw New button.

|image1|

**Figure 2**. Text Tab - Text "Smart Litho" written using the software.
H, W, and S are the height, width and the spacing between each
character.

2.3 General Functions
----------------------

|image2|

**Figure 3.** General Functions

Fig. 3 The red box delineates the general functions available:

a) **Draw New** - Valid only for the text and lines tabs, on clicking
   this button, a set of parallel lines or text is drawn freshly on the
   screen. Any previous graphics is discarded. You can use the **Undo**
   button to go back.

b) **Undo** - Displays the graphics prior to any change made. Note -
   this will allow the user to go back only one step.

c) **Append** - Valid only for the text and lines tabs, Adds a pattern
   of lines or text to the existing artwork as a new **layer** of
   artwork.

d) **Load New** - Loads a saved pattern from memory. This will erase
   anything else that was drawn. Borrowed from the Microangelo suite

e) **Clear** - Deletes all patterns. Borrowed from the Kill All button
   in the Microangelo suite

f) **Save** - Saves all the patterns as a single pattern to memory. Also
   the same as the **Save** button in the Microangelo suite. Note - This
   only saves to memory. In case the Asylum software is restarted, this
   will most likely be erased from memory. To save the patterns to disk
   use the **Save to Disk** button.

g) Append Saved - Similar to Load New but this doesn't erase the
   existing patterns. The appended pattern is loaded as a new layer.

h) **Load from Disk** - This loads a saved pattern from a \* .txt file
   on disk to memory. Note - the loaded pattern will NOT be displayed on
   the screen. The **Append Saved** or the **Load New** buttons must be
   used to load the pattern from memory.

i) **Save To Disk** - Saves all displayed patterns to a specified \*.txt
   file on the disk.

2.4. Layers Tab
---------------

|image3|

**Figure 4.** Layers Tab

The artwork produced in the Smart Litho suite is stored as a set of
layers in memory. The Layers tab shown in Fig. 4 allows the user to
perform the following vector based graphics operations on individual
layers:

a) **Select Layer** - The pull down menu can be used to select the layer
   of artwork to perform operations on.

b) **Show / Show all** - The Asylum Lithography program is only aware of
   the patterns visible on the scan panel. It is possible to show / hide
   individual layers for performing Lithography

c) **Select / Select All** - Features currently under construction

d) **Delete** - This button enables the user to delete the particular
   layer of artwork. Note - All subsequent layers are moved up in the
   layers list to fill the void left by the deleted layer.

e) **Move** - The selected pattern may be moved within the specified
   boundary using the **Right (um)** and the **Up (um)** parameters.

f) **Rotate** - The rotate button can be used to rotate the selected
   pattern using the **Rotate ccw (deg)** box to specify the
   counter-clockwise rotation in degrees. Note - Currently, this feature
   causes the rotated feature to be repositioned at the top left of the
   boundary. Appropriate boundaries should be specified to make it easy
   to perform this operation.

g) **Scale** - This allows the pattern to be scaled according to the
   specified parameter. Note - Similar to the rotate operation, the
   scaled pattern will be repositioned according to the border settings
   to the top left of the bounded area.

h) **Flip** - The specified layer can be mirrored vertically or
   horizontally depending on the enabled checkboxes after clicking the
   **Flip** button.

.. |image0| image:: media/image1.emf
   :width: 6.5in
   :height: 4.56875in
.. |image1| image:: media/image2.emf
   :width: 6.5in
   :height: 4.56875in
.. |image2| image:: media/image3.emf
   :width: 3.22431in
   :height: 5.18958in
.. |image3| image:: media/image4.emf
   :width: 6.5in
   :height: 4.86181in
