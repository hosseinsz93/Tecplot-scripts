#!MC 900

# Macro to make mp4 movie by looping through 
# files specified here in this file, use the
# layout that is in effect when the macro is 
# is started

# Modified by scj to integrate with tecplot
# version 9.0

$!VarSet |MFBD| = '.'


# Variables to control execution options:
# $!VarSet |MovieSteps| = 5
$!VarSet |MovieSteps| = 100
# $!VarSet |MovieSteps| = 50

$!VarSet |IncludeText| = 0  # Do not include text in frame
# $!VarSet |IncludeText| = 1  # Include text in frame

#$!VarSet |OutputType| = 'png'
$!VarSet |OutputType| = 'mp4'


$!VarSet |Dir| = '.'
$!VarSet |BaseFilename| = 'animation-layout-side-Qcriterion'
$!VarSet |LayoutName| = '|BaseFilename|.lay'
$!VarSet |ParmImageWidth| = 1920
# $!VarSet |ParmImageWidth| = 3000
# $!VarSet |ParmImageWidth| = 3840


$!VarSet |start| = 37600
$!VarSet |stop|  = 50000

$!VarSet |resolution| = ''
$!if |ParmImageWidth| == 1920
    $!VarSet |resolution| = '-1k'
$!endif
$!if |ParmImageWidth| == 3000
    $!VarSet |resolution| = '-3k'
$!endif
$!if |ParmImageWidth| == 3840
    $!VarSet |resolution| = '-4k'
$!endif


# Every 10 iterations
$!IF |MovieSteps| == 5
    $!VarSet |skip| = 5
$!ENDIF


# Every 100 iterations
$!IF |MovieSteps| == 100
    $!VarSet |skip| = 100
$!ENDIF

$!IF '|OutputType|' == 'mp4'
$!IF |MovieSteps| == 100
    $!VarSet |MovieName| = '|BaseFilename|-10|resolution|.mp4'
    $!ExportSetup
      AnimationSpeed = 4
      ExportFormat = MPEG4
      ExportFname = "|MovieName|"
      IMAGEWIDTH = |ParmImageWidth|
$!ENDIF
$!ENDIF


# Every 50 iterations
$!IF |MovieSteps| == 50
    $!VarSet |skip|  = 50
$!ENDIF

$!IF '|OutputType|' == 'mp4'
$!IF |MovieSteps| == 50
    $!VarSet |MovieName| = '|BaseFilename|-50|resolution|.mp4'
    $!ExportSetup
      AnimationSpeed = 4
      ExportFormat = MPEG4
      ExportFname = "|MovieName|"
      IMAGEWIDTH = |ParmImageWidth|
$!ENDIF
$!ENDIF


$!IF '|OutputType|' == 'png'
    $!PRINTSETUP
      PALETTE = COLOR
    $!EXPORTSETUP
      IMAGEWIDTH = |ParmImageWidth|
      ExportFormat = PNG
$!ENDIF


$!VarSet |NumFiles|  = |stop| 
$!VarSet |NumFiles| -= |start|
$!VarSet |NumFiles| /= |skip|
$!VarSet |NumFiles| += 1

$!VarSet |no| = |start|

# Setup export

# Begin Animation

$!Loop |NumFiles|

# Setup frame to export


$!OPENLAYOUT  "|LayoutName|"
ALTDATALOADINSTRUCTIONS = '"|Dir|/Result|no%06d|.plt" "|Dir|/surface|no%06d|_1.dat" "|Dir|/surface|no%06d|_2.dat" "|Dir|/surface|no%06d|_3.dat" "|Dir|/surface|no%06d|_4.dat" "|Dir|/surface|no%06d|_5.dat" "|Dir|/surface|no%06d|_6.dat" "|Dir|/surface|no%06d|_7.dat" "|Dir|/surface|no%06d|_8.dat" "|Dir|/surface|no%06d|_9.dat" "|Dir|/surface|no%06d|_10.dat"'

$!IF |IncludeText| == 1
    $!VarSet |TimeCounter| = |no|
    $!VarSet |TimeCounter| *= 0.0005

    $!AttachText
        TextShape {
            Font = HELV
            Height = 20
                  }
        XYPOS {
            X = 4.0
            Y =8.0
              }
        Text = "Time Step: |no%6d|  Time: |TimeCounter%.3f|"
$!ENDIF

#$!REDRAWALL


$!IF '|OutputType|' == 'mp4'
    $!If |Loop| == 1
	$!ExportStart
    $!EndIf

    $!If |Loop| != 1
	$!ExportNextFrame
    $!EndIf
$!EndIf


$!IF '|OutputType|' == 'png'
    $!IF |MovieSteps| == 5
        $!ExportSetup
          ExportFname = '|BaseFilename|-05|resolution|-|no%06d|.png'
    $!ENDIF


    $!IF |MovieSteps| == 10
        $!ExportSetup
          ExportFname = '|BaseFilename|-10|resolution|-|no%06d|.png'
    $!ENDIF


    $!IF |MovieSteps| == 50
        $!ExportSetup
          ExportFname = '|BaseFilename|-50|resolution|-|no%06d|.png'
    $!ENDIF

    $!EXPORT
      EXPORTREGION = CURRENTFRAME
$!ENDIF


# Advance file name counter
$!VarSet |no| += |skip|

$!EndLoop

$!IF '|OutputType|' == 'mp4'
    $!ExportFinish
$!ENDIF

# $!Quit
$!RemoveVar |MFBD|

# $!PROMPTFORYESNO |continue| 
# INSTRUCTIONS = "Macro Finished! Do you want to exit tecplot?"

#	$!IF "|continue|" == "YES"
#		$!QUIT
#	$!ENDIF


