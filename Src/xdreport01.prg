//----------------------------------------------------------------------------//
//
// Author: ( C ) Cristobal Navarro ( 2026 )
//
//----------------------------------------------------------------------------//

#pragma TEXTHIDDEN( 1 )
#include "FiveWin.ch"

//----------------------------------------------------------------------------//

#define USERNAME   "root"
#define PASSW      ""
#define SERVER     "127.0.0.1"
#define DATAB      "dummy"
//----------------------------------------------------------------------------//
#include "XDFastReport.ch"
//----------------------------------------------------------------------------//
#define CLR_SILVER           RGB( 192, 192, 192 )
#define CLR_HBLUE1           RGB(   0, 102, 204 )
#define CLR_HRED1            RGB( 204,   0,   0 )
#define CLR_GRAY1            RGB( 128, 128, 128 )
#define CLR_HGRAY1           RGB( 100, 100, 100 )
#define CLR_HGRAY2           RGB( 240, 240, 240 )
#define CLR_HEADER_BACK      RGB( 225, 225, 225 )
//----------------------------------------------------------------------------//

// EXTERNAL XD_RF_Controller

// REQUEST DBFCDX, DESCEND, DBFFPT

//----------------------------------------------------------------------------//

Static cVersion     := "12.0"
Static cPathUtils   := "..\XDFastUtils\"
Static cAppViewer
Static cAppDesign

Static cDll         := "XDFastReportBridge.dll"
Static cPathReports := "reports\"
Static cPathApli
Static oFR
Static oWnd
Static oFontCtrl
Static oFontCtrl1
Static oError
Static aTasks       := {}
Static oPnel
Static oPnel2
Static lEmbedded    := .F.
Static lWebView     := .F.
Static oWebView
Static cUrlInit     := "https://www.xdevos.xdevforyou.net/reportfast"

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

Function Main()

   local oBar
   local cFrViewer  := "..\Tools\FRViewer.exe"
   local aOBtts     := Array( 50 )
   local cDesigner  := "..\FastReport.Community.2026.1.0\Designer.exe"
   local cViewer    := "..\FastReport.Community.2026.1.0\Viewer.exe"
   local cFr3ToFrx  := cPathUtils + "Fr3toFrx.exe"    // "E:\FastReportFw\Utiles\Fast Reports Viewers\Fr3toFrx.exe"
   local cFont      := "Calibri"  // "Lato"    // 
   
   SET CENTURY ON
   //Fw_SetUnicode( .T. )

   //   TestMySql()
   
   cPathApli  := hb_DirBase()
   cAppDesign := cDesigner
   cAppViewer := cViewer
   
   DEFINE FONT oFontCtrl  NAME cFont SIZE 0, -14 BOLD
   DEFINE FONT oFontCtrl1 NAME cFont SIZE 0, -16 BOLD

   DEFINE WINDOW oWnd ;
      TITLE "XDReportFast ( C ) for Harbour: " + ;
            "< ( C ) Cristobal Navarro - 2020 - 2026 [ Ver. " + cVersion + " - FINAL - ] >"
   oWnd:SetColor( , Rgb( 221, 240, 228 ) )

   DEFINE BUTTONBAR oBar OF oWnd TOP SIZE 84, 72 2015 HEIGHT 96 NOBORDER
   oBar:SetFont( oFontCtrl )
   oBar:oGrpFont  := oFontCtrl1
   oBar:bRClicked := { || .T. }
   oBar:nAdjustRight := 1

   DEFINE BUTTON aOBtts[ 1 ] PROMPT "Save/Load" OF oBar ;
      GROUP LABEL "BASIC SAMPLES" COLORS CLR_WHITE, CLR_GRAY ;
      SECTION 20 ;
      MENU MenuSaveLoad()

   DEFINE BUTTON aOBtts[ 2 ] PROMPT "Exports" OF oBar ;
      SECTION 20 ;
      MENU MenuExport()

   DEFINE BUTTON aOBtts[ 3 ] PROMPT "Structure" OF oBar ;
      SECTION 20 ;
      MENU MenuBasic()

   DEFINE BUTTON aOBtts[ 5 ] PROMPT "Elements" OF oBar ;
      SECTION 20 ;
      MENU MenuElements()

   DEFINE BUTTON aOBtts[ 11 ] PROMPT "ARRAY" OF oBar ;
      GROUP LABEL "DATA SAMPLES" COLORS CLR_WHITE, CLR_GRAY ;
      SECTION 20 ;
      MENU MenuArray()

   DEFINE BUTTON aOBtts[ 12 ] PROMPT "JSON" OF oBar ;
      SECTION 20 ;
      MENU MenuJson()

   DEFINE BUTTON aOBtts[ 13 ] PROMPT "CSV / XML" OF oBar ;
      SECTION 20 ;
      MENU MenuCsvXml()

   DEFINE BUTTON aOBtts[ 14 ] PROMPT "DBF" OF oBar ;
      SECTION 20 ;
      MENU MenuDbfs()

   DEFINE BUTTON aOBtts[ 15 ] PROMPT "MYSQL" OF oBar ;
      SECTION 20 ;
      MENU MenuMySQL()

   DEFINE BUTTON aOBtts[ 16 ] PROMPT "SQLITE" OF oBar ;
      SECTION 20 ;
      MENU MenuSQLite()

   DEFINE BUTTON aOBtts[ 17 ] PROMPT "RDDS/ADO" OF oBar ;
      SECTION 20 ;
      MENU MenuRddsAdo()

   DEFINE BUTTON aOBtts[ 30 ] PROMPT "SCRIPTS" OF oBar ;
      GROUP LABEL "SPECIALS" COLORS CLR_WHITE, CLR_GRAY ;
      SECTION 20 ;
      MENU MenuScripts()

   DEFINE BUTTON aOBtts[ 31 ] PROMPT "UTILS" OF oBar BTNRIGHT ;
      GROUP LABEL "INTERNAL TOOLS" COLORS CLR_WHITE, CLR_GRAY ;
      SECTION 20 ;
      MENU MenuUtils()

   DEFINE BUTTON aOBtts[ 32 ] PROMPT "STATE" OF oBar BTNRIGHT ;
      SECTION 20 ;
      MENU MenuState()

   DEFINE BUTTON aOBtts[ Len( aOBtts ) - 4 ] PROMPT "URL INIT" OF oBar BTNRIGHT ;
      ACTION ( if( !Empty( oWebView ), XDNavigate( oWebView, cUrlInit ), ) ) ;
      WHEN !Empty( oWebView )

   DEFINE BUTTON aOBtts[ Len( aOBtts ) - 1 ] PROMPT " Designer" OF oBar BTNRIGHT ;
      GROUP LABEL "EXTERNAL TOOLS" COLORS CLR_WHITE, CLR_GRAY ;
      ACTION ( DirChange( cFilePath( oFR:cPathDesign ) ), ;
               WinExec( oFR:cPathDesign ), ;
               DirChange( cPathApli ) )

               // MsgRun( "Cargando Designer", "Espere por Favor", ;
               //         { || WinExec( oFR:cPathDesign ) } ), ; //  + " " + oFR:SetFileReport( , .F. ) ) } ), ;
               // DirChange( cPathApli ) )
               //MsgInfo( FindWnd( "FastReport Community" ) ) )

   DEFINE BUTTON aOBtts[ Len( aOBtts ) - 2 ] PROMPT " Viewer" OF oBar ;
      ACTION WinExec( oFR:cPathViewer )
      // WaitRun( oFR:cPathViewer )

   DEFINE BUTTON aOBtts[ Len( aOBtts ) - 3 ] PROMPT " Fr3ToFrx" OF oBar ;
      ACTION WaitRun( cFr3ToFrx )

   DEFINE BUTTON aOBtts[ Len( aOBtts ) ] PROMPT "End" OF oBar BTNRIGHT ;
      GROUP LABEL "EXIT" COLORS CLR_WHITE, CLR_GRAY ;
      ACTION oWnd:End()

   oWnd:bResized := { | nType, nWidth, nHeight | if( hb_IsObject( oFR ), oFR:Resize( nWidth, nHeight ), ) }

   ACTIVATE WINDOW oWnd MAXIMIZED ;
      ON INIT ( BuildPnels( oBar ), ;
                InitFastReport(), ;
                AEVal( aOBtts, { | o, n | if( Valtype( o ) = "O"  , ;
                       ( o:cCaption := Upper( o:cCaption ), ;
                         SetBmpToBtt( o, if( n = Len( aOBtts ) - 1, oFR:cPathDesign, ;
                                         if( n = Len( aOBtts ) - 2, oFR:cPathViewer, ;
                                         if( n = Len( aOBtts ) - 3, cFr3ToFrx, cFRViewer ) ) ) ) ), ) } ) ) ;
      VALID ( if( hb_IsObject( oFR ), ( oFR := oFR:End(), oFR := nil ), ), .T. )

   IF lWebView .and. !Empty( oWebView )
      XdEndWebView2( oWebView )
   ENDIF

   RELEASE FONT oFontCtrl
   RELEASE FONT oFontCtrl1
   
Return nil

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION BuildPnels( oBar )

   IF lEmbedded
      @ oBar:nBottom + 1, 1 PANEL oPnel OF oWnd ;
         SIZE Int( oWnd:nWidth / 2 ) - 12, oWnd:nHeight - oBar:nBottom - 48
         oPnel:SetColor( CLR_BLACK, CLR_CYAN )
   ENDIF

   IF lWebView
      @ oBar:nBottom + 1, Int( oWnd:nWidth / 2 ) PANEL oPnel2 OF oWnd ;
         SIZE Int( oWnd:nWidth / 2 ) - 2, oWnd:nHeight - oBar:nBottom - 48
         oPnel2:SetColor( CLR_BLACK, CLR_WHITE )

      oWebView := XdCreateWebView( oPnel2 )
      IF !Empty( oWebView )
         XDNavigate( oWebView, cUrlInit )
      ENDIF
   ENDIF

RETURN nil

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION ShowFRViewer( lEmb )

   hb_default( @lEmb, .F. )
   IF HB_IsObject( oFR )
      IF lEmb
         IF hb_IsObject( oPnel )
         
         ELSE
         
         ENDIF
      ELSE

      ENDIF
   ELSE

   ENDIF

RETURN NIL

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION ShowFRHtml( cFile )

   hb_default( @cFile, "" )
   IF !Empty( cFile ) // .and. File( cFile )



   ENDIF

RETURN NIL

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION ExecuteSample( nOpc, cFileFrx, lEmb, lOpt )

   LOCAL cFunc
   LOCAL lContinue  := .F.

   hb_default( @lEmb, .F. )
   hb_default( @nOpc, 0 )

   IF nOpc < 100
      cFunc := "XD_SAMPLE" + StrZero( nOpc, 2 ) // + "()"
   ELSE
      cFunc := "XD_SAMPLE" + StrZero( nOpc, 3 ) // + "()"
   ENDIF
   IF Type( cFunc + "()" ) == "UI"
      lContinue  := .T.
   ENDIF
   IF lContinue
      IF !Empty( cFileFrx )
         cFunc += "( '" + cFileFrx + "' )"
      ELSE
         IF lEmb
            cFunc += "( .T. )"
         ELSE
            cFunc += "()"
         ENDIF
      ENDIF
      // &( cFunc )
   ELSE
      Alert( "ERROR: FUNCTION NOT DEFINED - " + cFunc )
   ENDIF
   
   DO CASE
      CASE nOpc = 0
         XD_Sample00( cFileFrx )
      CASE nOpc = 1
         XD_Sample01( lEmb )
      CASE nOpc = 2
         XD_Sample02()
      CASE nOpc = 3
         XD_Sample03()
      CASE nOpc = 4
         XD_Sample04()
      CASE nOpc = 5
         XD_Sample05()
      CASE nOpc = 6
         XD_Sample06()
      CASE nOpc = 7
         XD_Sample07()
      CASE nOpc = 8
         XD_Sample08()
      CASE nOpc = 9
         XD_Sample09()
      CASE nOpc = 10
         XD_Sample10()
      CASE nOpc = 11
         XD_Sample11()
      CASE nOpc = 12
         XD_Sample12()
      CASE nOpc = 13
         XD_Sample13()
      CASE nOpc = 14
         XD_Sample14()
      CASE nOpc = 15
         XD_Sample15()
      CASE nOpc = 16
         XD_Sample16()
      CASE nOpc = 17
         XD_Sample17()
      CASE nOpc = 18
         XD_Sample18()
      CASE nOpc = 19
         XD_Sample19()
      CASE nOpc = 20
         XD_Sample20()
      CASE nOpc = 21
         XD_Sample21()
      CASE nOpc = 22
         XD_Sample22()
      CASE nOpc = 23
         XD_Sample23()
      CASE nOpc = 24
         XD_Sample24()
      CASE nOpc = 25
         XD_Sample25()
      CASE nOpc = 26
         XD_Sample26()
      CASE nOpc = 27
         XD_Sample27()
      CASE nOpc = 28
         XD_Sample28()
      CASE nOpc = 29
         XD_Sample29()
      CASE nOpc = 30
         XD_Sample30()
      CASE nOpc = 31
         XD_Sample31()
      CASE nOpc = 32
         XD_Sample32()
      CASE nOpc = 33
         XD_Sample33()
      CASE nOpc = 34
         XD_Sample34()
      CASE nOpc = 35
         XD_Sample35()
      CASE nOpc = 36
         XD_Sample36()
      CASE nOpc = 37
         XD_Sample37( cFileFrx )
      CASE nOpc = 38
         XD_Sample38()
      CASE nOpc = 39
         XD_Sample39()
      CASE nOpc = 40
         XD_Sample40()
      CASE nOpc = 41
         XD_Sample41()
      CASE nOpc = 42
         XD_Sample42()
      CASE nOpc = 43
         XD_Sample43()
      CASE nOpc = 44
         XD_Sample44()
      CASE nOpc = 45
         XD_Sample45()
      CASE nOpc = 46
         XD_Sample46()
      CASE nOpc = 47
         XD_Sample47()
      CASE nOpc = 48
         XD_Sample48()
      CASE nOpc = 49
         XD_Sample49()
      CASE nOpc = 50
         XD_Sample50()
      CASE nOpc = 51
         XD_Sample51()
      CASE nOpc = 52
         XD_Sample52()
      CASE nOpc = 53
         XD_Sample53()
      CASE nOpc = 54
         XD_Sample54()
      CASE nOpc = 55
         XD_Sample55()
      CASE nOpc = 56
         XD_Sample56()
      CASE nOpc = 57
         XD_Sample57()
      CASE nOpc = 58
         XD_Sample58()
      CASE nOpc = 100
         XD_Sample100()
      CASE nOpc = 101
         XD_Sample101()
      CASE nOpc = 102
         XD_Sample102()
      CASE nOpc = 103
         XD_Sample103()
      CASE nOpc = 104
         XD_Sample104()
      CASE nOpc = 105
         XD_Sample105()
      CASE nOpc = 106
         XD_Sample106()
      CASE nOpc = 107
         XD_Sample107()
   ENDCASE
   // InitFastReport()

RETURN NIL

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION MenuBasic()

   LOCAL oMenu
   
   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "Basic Structure and Viewer"
      MENU
         MENUITEM "001. Structure [ Viewer in Modal Dialog ]" ACTION ExecuteSample( 1, , .F. )
         SEPARATOR
         MENUITEM "001. Structure [ Viewer in oWnd ]" ACTION ExecuteSample( 1, , .T. )
         SEPARATOR
         MENUITEM "001. Structure [ Viewer in oPnel ]" ACTION ExecuteSample( 1, , .T. )
      ENDMENU
      MENUITEM "Basic Elements"
      MENU
         MENUITEM "004. Footers" ACTION ( ExecuteSample( 4 ) )
         SEPARATOR
         MENUITEM "005. Bands, Groups, Colors, Totals" ACTION ( ExecuteSample( 5 ) )     // , CONDITIONS
         SEPARATOR
         MENUITEM "007. Variables" ACTION ( ExecuteSample( 7 ) )
      ENDMENU
      MENUITEM "Special Formats"
      MENU
         MENUITEM "010. Specials Formats Configuration" ACTION ExecuteSample( 10 )
         SEPARATOR
         MENUITEM "000. Sample Design Box" ACTION ExecuteSample( 0, "box.frx" )
      ENDMENU
      MENUITEM "Images"
      MENU
         MENUITEM "006. Images" ACTION ExecuteSample( 6 )
         SEPARATOR
         MENUITEM "014. Bar Codes" ACTION ExecuteSample( 14 )
         SEPARATOR
         MENUITEM "050. Drawing Polygon" ACTION ExecuteSample( 50 )
         SEPARATOR
         MENUITEM "057. Gauges / Indicadores" ACTION ExecuteSample( 57 )
      ENDMENU
   ENDMENU

RETURN oMenu

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION MenuSaveLoad()

   LOCAL oMenu
   
   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "002. Save FRX FILE" ACTION ExecuteSample( 2 )
      SEPARATOR
      MENUITEM "LOAD" SEPARATOR COLORMENU CLR_GRAY, CLR_WHITE
      SEPARATOR
      MENUITEM "003. Load from FRX FILE" ACTION ExecuteSample( 3 )
      SEPARATOR
      MENUITEM "030. Load from STRING"   ACTION ExecuteSample( 30 )
      SEPARATOR
      MENUITEM "   . Load from BLOB"   // ACTION ExecuteSample( 3 )
      SEPARATOR
      MENUITEM "056. Select Report to Load" ACTION ExecuteSample( 56 )
   ENDMENU

RETURN oMenu

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION MenuElements()

   LOCAL oMenu
   
   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "042. Sample 42" ACTION ExecuteSample( 42 )
      SEPARATOR
      MENUITEM "043. Sample 43" ACTION ExecuteSample( 43 )
      SEPARATOR
      MENUITEM "051. Sample 51 (Accordion DrillDown)" ACTION ExecuteSample( 51 )
      SEPARATOR
      MENUITEM "052. Sample 52 (SubReports)" ACTION ExecuteSample( 52 )
   ENDMENU

RETURN oMenu

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION MenuJson()

   LOCAL oMenu
   
   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "021. Customer [ Read file JSON to String from Harbour ]" ACTION ExecuteSample( 21 )
      SEPARATOR
      MENUITEM "022. NWind [ Use File JSON directly ]" ACTION ExecuteSample( 22 )
      SEPARATOR
      MENUITEM "023. Productos [ Images BASE64 in file JSON ]" ACTION ExecuteSample( 23 )
      SEPARATOR
      MENUITEM "024. API Fruits [ JSON From URL Remote ]" ACTION ExecuteSample( 24 )
      SEPARATOR
      MENUITEM "025. Master-Detail [ Categories -> Products ]" ACTION ExecuteSample( 25 )
      SEPARATOR
      MENUITEM "026. Code Master-Detail (Invoice)" ACTION ExecuteSample( 26 )
   ENDMENU

RETURN oMenu

//----------------------------------------------------------------------------//

FUNCTION MenuMySQL()

   LOCAL oMenu
   
   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "032. Customer Table [ ALL ]" ACTION ExecuteSample( 32 )
      MENUITEM "033. Customer Table [ GROUP BY STATE ]" ACTION ExecuteSample( 33 )
      MENUITEM "034. Customer Table [ GROUP BY STATE + TOTALS + PAGE BREAK ]" ACTION ExecuteSample( 34 )
      SEPARATOR
      MENUITEM "035. Show Available MySQL Tables" ACTION ExecuteSample( 35 )
      MENUITEM "036. MySQL Discovery -> Report (Array)" ACTION ExecuteSample( 36 )
   ENDMENU

RETURN oMenu

//----------------------------------------------------------------------------//

Function MenuSQLite()

   LOCAL oMenu

   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "CREATE BBDD" SEPARATOR COLORMENU CLR_GRAY, CLR_WHITE
      MENUITEM "038. Generar Base de Datos SQLite (NWind XML)" ACTION ExecuteSample( 38 )
      MENUITEM "040. Generar Base de Datos SQLite (NWind JSON)" ACTION ExecuteSample( 40 )
      MENUITEM "REPORTS" SEPARATOR COLORMENU CLR_GRAY, CLR_WHITE
      MENUITEM "039. Reporte SQLite [ XML -> DB ]" ACTION ExecuteSample( 39 )
      MENUITEM "041. Reporte SQLite [ JSON -> DB ]" ACTION ExecuteSample( 41 )
   ENDMENU

RETURN oMenu

//----------------------------------------------------------------------------//

FUNCTION MenuCsvXml()

   LOCAL oMenu

   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM " CSV "
      MENU
         MENUITEM "018. CSV File [ customers.csv ]" ACTION ExecuteSample( 18 )
         SEPARATOR
         MENUITEM "019. CSV String [ From Harbour Memory ]" ACTION ExecuteSample( 19 )
      ENDMENU
      MENUITEM " XML "
      MENU
         MENUITEM "027. XML from File [ nwind.xml ]" ACTION ExecuteSample( 27 )
         MENUITEM "028. XML from String" ACTION ExecuteSample( 28 )
         SEPARATOR
         MENUITEM "020. Invoice (XML) [ nwind.xml ]" ACTION ExecuteSample( 20 )
         MENUITEM "029. Invoice Filter [ nwind.xml ] ( Invoice = 10300 )" ACTION ExecuteSample( 29 )
      ENDMENU
   ENDMENU
RETURN oMenu

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION MenuScripts()

   LOCAL oMenu
   
   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "SCRIPTING" SEPARATOR COLORMENU CLR_GRAY, CLR_WHITE
      MENUITEM "101. Sample Initial" ACTION ExecuteSample( 101 )
      MENUITEM "102. Advanced Scripting (Object Injection)" ACTION ExecuteSample( 102 )
      MENUITEM "103. Multi-line Code Block Example" ACTION ExecuteSample( 103 )
      MENUITEM "104. Dynamic Content via Parameters" ACTION ExecuteSample( 104 )
      MENUITEM "ADVANCED" SEPARATOR COLORMENU CLR_GRAY, CLR_WHITE
      MENUITEM "105. Date + 400 Days (Harbour Script)" ACTION ExecuteSample( 105 )
      MENUITEM "106. Leap Year Check (Complex Script)" ACTION ExecuteSample( 106 )
      MENUITEM "107. Multi-function Script (Inline)" ACTION ExecuteSample( 107 )
   ENDMENU

RETURN oMenu

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION MenuUtils()

   LOCAL oMenu
   
   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "031. Report File .FRX to Code [ XDReportFast ]" ACTION ExecuteSample( 31 )
      SEPARATOR
      MENUITEM "   . Report File .FR3 to Code [ XDReportFast ]" // ACTION ExecuteSample( 31 )
      SEPARATOR
      MENUITEM "053. Test FRX to Code (Active & File)" ACTION ExecuteSample( 53 )
      SEPARATOR
      MENUITEM "054. Prototype FR3 to FRX Migration" ACTION ExecuteSample( 54 )
      SEPARATOR
      MENUITEM "055. Advanced FR3 Migration (with Scripts)" ACTION ExecuteSample( 55 )
      MENUITEM "058. Advanced FR3 Migration" ACTION ExecuteSample( 58 )
   ENDMENU

RETURN oMenu

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION MenuExport()

   LOCAL oMenu
   
   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "008. Export to PDF" ACTION ExecuteSample( 8 )
      SEPARATOR
      MENUITEM "009. Export to HTML" ACTION ExecuteSample( 9 )
   ENDMENU

RETURN oMenu

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION MenuArray()

   LOCAL oMenu

   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "011. 📄 Array of Hashes" ACTION ExecuteSample( 11 )
      SEPARATOR
      MENUITEM "012. Array of Arrays (Columnas Definidas)" ACTION ExecuteSample( 12 )
      SEPARATOR
      MENUITEM "013. Array Dinamico" ACTION ExecuteSample( 13 )
      SEPARATOR
      MENUITEM "015. Factura Master-Detail (Raw Arrays)" ACTION ExecuteSample( 15 )
      SEPARATOR
      MENUITEM "016. Factura Master-Detail (Hashes)" ACTION ExecuteSample( 16 )
      SEPARATOR
      MENUITEM "017. Factura con Calculos (Qty * Price)" ACTION ExecuteSample( 17 )
      SEPARATOR
      MENUITEM "037. 🌟 Visualizar Codigo Fuente .FRX" ACTION ExecuteSample( 37, "box.frx" )
   ENDMENU
RETURN oMenu

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION MenuRddsAdo()

   LOCAL oMenu

   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "ADO: JET - ACE" SEPARATOR COLORMENU CLR_GRAY, CLR_WHITE
      MENUITEM "Access (.MDB - .ACCDB)"
      MENU
         MENUITEM "044. Access (.MDB)  [ Jet Provider ]" ACTION ExecuteSample( 44 )
         SEPARATOR
         MENUITEM "045. Access (.ACCDB) [ ACE Provider ]" ACTION ExecuteSample( 45 )
      ENDMENU
      SEPARATOR
      MENUITEM "Excel (.XLS - .XLSX)"
      MENU
         MENUITEM "046. Excel (.XLS)   [ Jet Provider ]" ACTION ExecuteSample( 46 )
         SEPARATOR
         MENUITEM "047. Excel (.XLSX)  [ ACE Provider ]" ACTION ExecuteSample( 47 )
      ENDMENU
      MENUITEM "RDDS" SEPARATOR COLORMENU CLR_GRAY, CLR_WHITE
      MENUITEM "PostGre"  DISABLED
      SEPARATOR
      MENUITEM "MongoDb"  DISABLED
      SEPARATOR
      MENUITEM "Firebird" DISABLED
      SEPARATOR
      MENUITEM "Oracle"   DISABLED
      SEPARATOR
   ENDMENU
RETURN oMenu

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION MenuDbfs()

   LOCAL oMenu

   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "048. DBF (.DBF) [ JET/ADO VFP Provider ]" ACTION ExecuteSample( 48 )
      SEPARATOR
      MENUITEM "049. DBF (.DBF) FROM .JSON" ACTION ExecuteSample( 49 )
      MENUITEM "NATIVE DBFS" SEPARATOR COLORMENU CLR_GRAY, CLR_WHITE
      MENUITEM "100. DBF VIRTUAL WORKAREA [ DIRECT ACCESS ]" ACTION ExecuteSample( 100 )
   ENDMENU
RETURN oMenu

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION MenuState()

   LOCAL oMenu
   
   MENU oMenu POPUP 2013 FONT oFontCtrl1 HEIGHT 2.2
      MENUITEM "LAST STATE" ACTION ( if( !Empty( oFR ), Alert( oFR:GetInternalState( .F. ) ), ) )
      MENUITEM "LAST STATE EXTENDED" ACTION ( if( !Empty( oFR ), Alert( oFR:GetInternalState( .T. ) ), ) )
      SEPARATOR
      MENUITEM "LAST ERROR" ACTION ( if( !Empty( oFR ), Alert( oFR:GetLastError() ), ) )
   ENDMENU

RETURN oMenu

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

FUNCTION FRController( cAction, cParam )     //   GET_IVA( 21, 15 )

   LOCAL cRet    := ""
   LOCAL aParams 
   LOCAL cFunc
   
   IF Empty( cParam )
      aParams := {}
   ELSE
      aParams := hb_ATokens( cParam, "|" )
   ENDIF

   DO CASE
      // Funciones definidas por el usuario
      CASE cAction == "GET_IVA"
         cRet  := "RESPUESTA: " + hb_ValToStr( cAction ) + " CON: " + hb_ValToExp( aParams )

      OTHERWISE
         // Generic call
         // De todo lo demas se encarga la lib 
         cRet  := Eval( oFR:bFuncXDRFCallBack, cAction, cParam, oFR )

   ENDCASE 

RETURN cRet

//----------------------------------------------------------------------------//
/*
Static Function InitFastReport()

   local oErr
   
   if hb_IsObject( oFR )
      oFR:End()
      oFR:Clear()
      oFR  := nil
   endif

   if !hb_IsObject( oFR )
      oFR  := TXDFastReport():New( , "FRCONTROLLER" )
   endif

   TRY
      WITH OBJECT oFR
         :SetPathDesign( cAppDesign )
         :SetPathViewer( cAppViewer )
         :SetReportName( "" )
         :SetPathInput( cPathApli + cPathReports )
         :NewReport()
         :SetUnit( 1 )   // CM

         // :oWnd    := oWnd
         // :SetFolderIn( cPathReports )
         // :SetFolderOut( cPathReports )
         // :SetDesigner( "E:\FastReportFw\Utiles\Community.2019.1.0\Designer.exe" )
         // :SetViewer( "E:\FastReportFw\Utiles\Community.2019.1.0\Viewer.exe" )
         // :SetDesignerVCL( "E:\FastReportFw\Utiles\Fast Reports Viewers\FastReportFMX_Viewer.exe" )
         // :SetViewerVCL( "E:\FastReportFw\Utiles\Fast Reports Viewers\Viewer.exe" )

      END
   CATCH oErr
      // ? oErr:description
      ShowError( oErr )
   END TRY

Return nil
*/
//----------------------------------------------------------------------------//

Static Function InitFastReport( cPage )
   local oErr
   
   hb_default( @cPage, "Page1" )
   
   if !hb_IsObject( oFR )
      // 1. Si el objeto NO existe (solo pasa la primera vez que se abre la app), lo instanciamos
      oFR := TXDFastReport():New( , "FRCONTROLLER" )
   else
      // 2. Si YA existe de un reporte anterior, NO lo destruimos con End().
      //    Simplemente lo limpiamos (Clear). Esto destruye las paginas del report anterior,
      //    suelta las conexiones de BD y deja el motor limpio
      oFR:Clear()
   endif

   TRY
      WITH OBJECT oFR
      // 3. Configuramos el nuevo report
         :SetPathDesign( cAppDesign )
         :SetPathViewer( cAppViewer )
         :SetReportName( "" )
         :SetPathInput( cPathApli + cPathReports )
         
         :NewReport( cPage )
         :SetUnit( 1 )   // 0 -> MM   // 1 -> CM
      END
   CATCH oErr
      IF hb_IsObject( oFR )
         oFR:ShowError( oErr )
      ENDIF
   END TRY

Return nil

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

function GetJson()

   local oHttp
   local cStrRet  := ""
   local hResult
   local nLen
   local e

   TRY
      oHttp    := CreateObject( "MSXML2.XMLHTTP" )
      oHttp:Open( "GET" ,"https://www.fruityvice.com/api/fruit/all", .F. )
      oHttp:SetRequestHeader( "Content-Type", "application/json; charset=utf-8" )
      oHttp:Send()
      cStrRet  := hb_StrToUtf8( Alltrim( oHttp:responseText ) )
      nLen     := hb_JsonDecode( cStrRet, @hResult )
      //XBrowse( hResult )   // ( hResult[ "records" ] )
      //? Valtype( hResult[ "records" ] ), hResult[ "records" ][ 1 ]
   CATCH e
      Alert( e:description + hb_OSNewLine() + cValToChar( oHttp:Status ) + hb_OsNewLine() + oHttp:StatusText )
   END

return cStrRet

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

Function TestMySql

   local oCn
   local oRs
   // oCn := Fw_DemoDb( 5 )
   FWCONNECT oCn HOST SERVER   USER USERNAME  DATABASE DATAB   
   if hb_IsObject( oCn )
      //
      oRs  := oCn:RowSet( "SHOW FULL TABLES" )
      XBrowse( oRs )
   else
      Alert( "Error de conexion" )
   endif

Return nil

//----------------------------------------------------------------------------//
// NUEVOS EJEMPLOS
//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//
// Basic Sample structure:
// Title
// Properties elements
// Show Report
//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//
// XD_Sample00: Report Box
//----------------------------------------------------------------------------//

Function XD_Sample00( cFileFrx )

   local oErr

   //InitFastReport()
   TRY
      WITH OBJECT oFR
         :SetReportName( cFileFrx )
         //? :cPathInput + cFileFrx
         if :Load( cFileFrx ) //cPathApli + cPathReports + cFileFrx ) // :cPathInput + cFileFrx )
            // ? :GetLastError()
            if :Prepare( .F. )
               :Show()
            endif
         endif
      END
   CATCH oErr
      IF hb_IsObject( oFR )
         oFR:ShowError( oErr )
      ENDIF
   END TRY

Return nil

//----------------------------------------------------------------------------//
// XD_Sample01: Basic Structure demo
//----------------------------------------------------------------------------//

FUNCTION XD_Sample01( lEmb )

   LOCAL cTitle := "XDREPORTFAST - XDEVFORYOU - (C) - 2026"
   LOCAL cPg    := "Page1"

   InitFastReport()
   
   TRY   
      WITH OBJECT oFR
         :RegisterCustomFunc( "GET_IVA" , , )

         :AddBand( "REPORTTITLE", cPg, "BandaTitulo" ) 
      
         :AddMemoEx( "BandaTitulo", "BandaGris", 0, 0, 19, 1, "" )
         :SetProperty( "BandaGris", "FillColor", CLR_HGRAY1 )   // 0x404040 ) 
      
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 0, 0.2, 19, 0.8, cTitle )
         :SetProperty( "TxtTitulo", "Color", CLR_BLUE )   // -1 ) 
         :SetProperty( "TxtTitulo", "Size", 14 )
         :SetProperty( "TxtTitulo", "Style", 1 ) 
         :SetProperty( "TxtTitulo", "HAlign", 1 )
      
         :AddMemoEx( "BandaTitulo", "LnkDoc", 2, 1.3, 7, 0.5, "VER DOCUMENTACION" )
         :SetHyperlink( "LnkDoc", 0, "https://fastreports.github.io/FastReport.Documentation/ClassReference/api/FastReport.html" )
         :SetProperty( "LnkDoc", "Font.Color", CLR_RED )  // 0x0000FF ) 
         :SetProperty( "LnkDoc", "Font.Style", 4 )   // MIRAR !!! con Font. y son Font.
         :SetProperty( "LnkDoc", "HAlign", 2 )
         :SetProperty( "LnkDoc", "Cursor", 13 )
      
         :AddMemoEx( "BandaTitulo", "Sep", 9, 1.2, 1, 0.5, " | " )
         :SetProperty( "Sep", "HAlign", 1 )
      
         :AddMemoEx( "BandaTitulo", "LnkGit", 10, 1.3, 7, 0.5, "CODIGO FUENTE" )
         :SetHyperlink( "LnkGit", 0, "https://github.com/FastReports/FastReport" )
         :SetProperty( "LnkGit", "Font.Color", "#0000FF" ) 
         :SetProperty( "LnkGit", "Font.Style", 4 )
         :SetProperty( "LnkGit", "HAlign", 0 )
         :SetProperty( "LnkGit", "Cursor", 13 )
         
         :AddLineEx( "BandaTitulo", "LineSep", 0.1, 2.2, 19, 0, CLR_GRAY, 2.0 )
         
         :AddMemoEx( "BandaTitulo", "M1", 0.5, 3.2, 5, 0.5, '[GET_IVA("21")]' )

         // Alert( :GetInternalState() )

         if :Prepare( .F. )
            IF !lEmb
               :Show()
            ELSE
               // :ShowEmbedded( oWndParent, cTit, nX, nY, nW, nH )
               IF hb_IsObject( oWnd ) .and. !hb_IsObject( oPnel )
                  :ShowEmbedded( oWnd, "Prueba de Embedded en Area Cliente Window", 1 , oWnd:oBar:nBottom + 1 ) // , nW, nH )
               ELSE
                  :ShowEmbedded( oPnel, "Prueba de Embedded", 1 , 1 ) // , nW, nH )
               ENDIF
            ENDIF
            // ? :GetLastError()
         else
            Alert( :GetLastError() )
         endif
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample02: Save
//----------------------------------------------------------------------------//

FUNCTION XD_Sample02()

   LOCAL cTitle := "XDREPORTFAST - XDEVFORYOU - (C) - 2026"
   LOCAL cPg    := "Page1"
   LOCAL cFile  := hb_DirBase() + "reports\XD_Sample02.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample2.fpx"

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddBand( "REPORTTITLE", cPg, "BandaTitulo" ) 
         
         :AddMemoEx( "BandaTitulo", "BandaGris", 0, 0, 19, 1, "" )
         :SetProperty( "BandaGris", "FillColor", CLR_BLUE )  // 0x404040 ) 
      
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 0, 0.2, 19, 0.8, cTitle )
         :SetProperty( "TxtTitulo", "Color", CLR_WHITE ) // "#FFFFFF" ) 
         :SetProperty( "TxtTitulo", "Size", 14 )
         :SetProperty( "TxtTitulo", "Style", 1 ) 
         :SetProperty( "TxtTitulo", "HAlign", 1 )
      
         :AddMemoEx( "BandaTitulo", "LnkDoc", 2, 1.2, 7, 0.5, "VER DOCUMENTACION" )
         :SetHyperlink( "LnkDoc", 0, "https://fastreports.github.io/FastReport.Documentation/ClassReference/api/FastReport.html" )
         :SetProperty( "LnkDoc", "Color", "#0000FF" ) 
         :SetProperty( "LnkDoc", "Style", 4 )
         :SetProperty( "LnkDoc", "HAlign", 2 )
         :SetProperty( "LnkDoc", "Cursor", 13 )
      
         :AddMemoEx( "BandaTitulo", "Sep", 9, 1.2, 1, 0.5, " | " )
         :SetProperty( "Sep", "HAlign", 1 )
      
         :AddMemoEx( "BandaTitulo", "LnkGit", 10, 1.2, 7, 0.5, "CODIGO FUENTE" )
         :SetHyperlink( "LnkGit", 0, "https://github.com/FastReports/FastReport" )
         :SetProperty( "LnkGit", "Color", "#0000FF" ) 
         :SetProperty( "LnkGit", "Style", 4 )
         :SetProperty( "LnkGit", "HAlign", 0 )
         :SetProperty( "LnkGit", "Cursor", 13 )
         if :Prepare( .F. )
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
         else
            MsgInfo( "Error Prepare: " + oFR:GetLastError() )
         endif
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample03: Load
//----------------------------------------------------------------------------//

FUNCTION XD_Sample03()

   LOCAL cPg       := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample02.frx"
   LOCAL cFileHTML := hb_DirBase() + "reports\XD_Sample02.html"

   IF .NOT. File( cFile )
      Alert( "Error: No se encuentra el archivo " + cFile + ". Ejecuta primero el Ejemplo 02." )
      RETURN nil
   ENDIF

   InitFastReport()

   TRY
      WITH OBJECT oFR
         ? :Load( cFile )
      
         IF :Prepare( .F. )
            :Show()
            // :ExportHTML( cFileHTML )
         ELSE
            Alert( :GetLastError() )
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample04: Footers
//----------------------------------------------------------------------------//

FUNCTION XD_Sample04()

   LOCAL cTitle := "XDREPORTFAST - XDEVFORYOU - (C) - 2026"
   LOCAL cPg    := "Page1"
   LOCAL cFile  := hb_DirBase() + "reports\XD_Sample04.frx"
   LOCAL nHeight
   LOCAL nTop   

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddBand( "REPORTTITLE", cPg, "BandaTitulo" ) 
         :AddMemoEx( "BandaTitulo", "BandaGris", 0, 0, 19, 1, "" )
         :SetProperty( "BandaGris", "FillColor", CLR_HGRAY1 ) // "#404040" ) 
      
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 0, 0.2, 19, 0.8, cTitle )
         :SetProperty( "TxtTitulo", "Font.Color", "#FFFFFF" ) 
         :SetProperty( "TxtTitulo", "HAlign", 1 )
         
        
         nHeight := oFR:GetProperty( "BandaTitulo", "Height" )
         nTop    := oFR:GetProperty( "BandaTitulo", "Top" )      
      
         :AddBand( "PAGEFOOTER", cPg, "BandaPie" )
         :AddMemoEx( "BandaPie", "TxtPaginas", 15, 0.2, 4, 0.5, "Pagina [Page] de [TotalPages]" )
         // :AddMemo( "BandaPie", "TxtPaginas", "Pagina [Page] de [TotalPages]" )
         :SetProperty( "TxtPaginas", "Font.Size", 14 )
         :SetProperty( "TxtPaginas", "Font.Style", 2 )     // Italic
         :SetProperty( "TxtPaginas", "HAlign", 2 )         // "HorzAlign", 2 )       // Alineado a la derecha
         
         // Cambiar el tipo de letra (Font Family)
         :SetProperty( "TxtPaginas", "Font.Name", "Verdana" )
         // Cambiar el color del texto (usando valores RGB )
         :SetProperty( "TxtPaginas", "Color", 255 ) // Rojo puro
         // Cambiar el color de fondo (usando valores RGB )
         :SetProperty( "TxtPaginas", "BGColor", 16777215 ) // Blanco puro
         // Tambien puedes usar nombres en ingles o Hex si lo prefieres
         // :SetProperty( "TxtPaginas", "Color", "Blue" )
         // :SetProperty( "TxtPaginas", "BGColor", "#E0E0E0" )

         // ? oFR:GetProperty( "BandaPie", "Height" )
         // ? oFR:GetProperty( "BandaPie", "Top" )
         // ? oFR:GetProperty( "BandaPie", "Bounds" )

// 1. Texto a la IZQUIERDA (Nombre del reporte)
// :AddMemo( "Informe de Ventas", "BandaPie", "TxtReporte" )
// :SetProperty( "TxtReporte", "Align", 0 ) // Left
// 2. Texto al CENTRO (Numero de pagina)
// :AddMemo( "Pagina [Page]", "BandaPie", "TxtPag" )
// :SetProperty( "TxtPag", "Align", 1 )    // Center
// 3. Texto a la DERECHA (Fecha/Hora)
// :AddMemo( "[Date] [Time]", "BandaPie", "TxtFecha" )
// :SetProperty( "TxtFecha", "Align", 2 )   // Right

         // Habilitar DoublePass para que, elementos como por ejemplo, [TotalPages] se calcule
         :SetDoublePass( .T. )

         if :Prepare( .F. )
            // Obtener todos los componentes de un elemento ( Banda o Pagina )
            ? :Serialize( cPg )   // "BandaTitulo" )
            :Show()
            :Save( cFile )
         endif
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample05: Bandas: types
//----------------------------------------------------------------------------//

FUNCTION XD_Sample05()

   LOCAL cTitle := "XDREPORTFAST - XDEVFORYOU - (C) - 2026"
   LOCAL cFile  := hb_DirBase() + "reports\XD_Sample05.frx"
   LOCAL cPg    := "Page1"

   InitFastReport()

   TRY
      WITH OBJECT oFR
      
         :AddBand( "REPORTTITLE", cPg, "BandaTitulo" )
         :AddMemoEx( "BandaTitulo", "MemTitle", 0, 0, 19, 1.5, cTitle )
         :SetProperty( "MemTitle", "FillColor", 0x404040 ) // Gris Oscuro
         :SetProperty( "MemTitle", "Font.Color", -1 )
         :SetProperty( "MemTitle", "HAlign", 1 ) // Center
      
         :AddBand( "PAGEHEADER", cPg, "BandaCabecera" )
         :AddMemoEx( "BandaCabecera", "MemPgHead", 0, 0, 19, 0.8, "CABECERA DE PAGINA (Repetitiva)" )
         :SetProperty( "MemPgHead", "FillColor", 0xE0E0E0 ) // Gris Claro
         :SetProperty( "MemPgHead", "Font.Size", 10 )
      
         :AddBand( "DATA", cPg, "BandaDetalle" )
         :AddMemoEx( "BandaDetalle", "MemData", 0, 0.2, 19, 0.8, "CUERPO DEL REPORTE - Contenido principal" )
         :SetProperty( "MemData", "Font.Style", 1 ) // Bold
      
         :AddBand( "REPORTSUMMARY", cPg, "BandaResumen" )
         :AddMemoEx( "BandaResumen", "MemSum", 0, 0.5, 19, 0.8, "RESUMEN FINAL (Totales)" )
         :SetProperty( "MemSum", "FillColor", 0xD1FFD1 ) // Verde claro
         :SetProperty( "MemSum", "HAlign", 1 )
      
         :AddBand( "PAGEFOOTER", cPg, "BandaPie" )
         :AddMemoEx( "BandaPie", "MemPgFoot", 0, 0, 19, 0.8, "PIE DE PAGINA - P?g: [Page]" )
         :SetProperty( "MemPgFoot", "FillColor", 0xFFFFE1 ) // Amarillo claro
         :SetProperty( "MemPgFoot", "Font.Size", 8 )
      
         if :Prepare( .F. )
            :Show()
            :Save( cFile )
         endif
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample06: Images inserction
//----------------------------------------------------------------------------//

FUNCTION XD_Sample06()

   LOCAL cTitle := "XDREPORTFAST - XDEVFORYOU - (C) - 2026"
   LOCAL cFile  := hb_DirBase() + "reports\XD_Sample06.frx"
   LOCAL cPath
   LOCAL cLogo  := "img\xdevforyou.png" // Asegurate de que el archivo exista
   LOCAL cPg    := "Page1"

   // cPath := hb_curDrive() + ":\" + curDir() + cLogo

   cPath        := cPathApli + cLogo    // Ha de ser ruta absoluta, investigar
   // IF !hb_IsOBject( oFR )
      InitFastReport()
   // ENDIF

   TRY
      WITH OBJECT oFR

         :AddBand( "REPORTTITLE", cPg, "BandaTitulo" )
         :SetUnit( 4 )   // PIXEL
         IF File( cLogo )
            :AddPictureEx( "BandaTitulo", "ImgLogo", 600, 10, 100, 40, cPath )
         ENDIF
         
         :SetUnit( 1 )   // CM
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 0.5, 0.5, 14, 1, cTitle )
         :SetProperty( "TxtTitulo", "Font.Size", 16 )
         :SetProperty( "TxtTitulo", "Font.Style", 1 ) // Bold
         :SetProperty( "TxtTitulo", "VAlign", 1 )      // Center Vertical
         :SetProperty( "TxtTitulo", "HAlign", 0 )      // Left
      
         if :Prepare( .F. )
            :Show()
            :Save( cFile )
         endif
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil


//----------------------------------------------------------------------------//
// XD_Sample07: SetVariable -> definition user variables
//----------------------------------------------------------------------------//

FUNCTION XD_Sample07()

   LOCAL cTitle  := "XDREPORTFAST - XDEVFORYOU - (C) - 2026"
   LOCAL cFile   := hb_DirBase() + "reports\XD_Sample07.frx"
   LOCAL cPg     := "Page1"
   
   LOCAL cMiTitulo := "TITULO DINAMICO DESDE HARBOUR"
   LOCAL cMiHeader := "Listado de Clientes Semanal"
   LOCAL cMiFooter := "XDEVFORYOU - Sistema de Gestion"

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :SetVariable( "VarTitulo", cMiTitulo )
         :SetVariable( "VarHeader", cMiHeader )
         :SetVariable( "VarFooter", cMiFooter )
      
         :AddBand( "REPORTTITLE", cPg, "BandaTit" )
         :AddMemoEx( "BandaTit", "MemTit", 0, 0, 19, 1, "[VarTitulo]" )
         :SetProperty( "MemTit", "FillColor", 0x404040 )
         :SetProperty( "MemTit", "Font.Color", -1 )
         :SetProperty( "MemTit", "HAlign", 1 ) // Center
      
         :AddBand( "PAGEHEADER", cPg, "BandaHead" )
         :AddMemoEx( "BandaHead", "MemHead", 0, 0.2, 19, 0.6, "Subtitulo: [VarHeader]" )
         :SetProperty( "MemHead", "Font.Style", 1 ) // Bold
      
         :AddBand( "DATA", cPg, "BandaDet" )
         :AddMemoEx( "BandaDet", "MemDet", 0, 0, 19, 0.5, "Contenido del reporte..." )
      
         :AddBand( "PAGEFOOTER", cPg, "BandaPie" )
         :AddMemoEx( "BandaPie", "MemPie", 0, 0, 10, 0.5, "Copyright: [VarFooter]" )
         :AddMemoEx( "BandaPie", "MemPag", 15, 0, 4, 0.5, "Pag. [Page]" )
         :SetProperty( "MemPie", "Font.Size", 8 )
         :SetProperty( "MemPag", "HAlign", 2 )
      
         if :Prepare( .F. )
            :Show()
            :Save( cFile )
         endif
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample08: Export to PDF
//              Save info user
//              GetLastError for control errors
//----------------------------------------------------------------------------//

FUNCTION XD_Sample08()

   LOCAL cTitle   := "XDREPORTFAST - XDEVFORYOU - (C) - 2026"
   LOCAL cFileFRX := hb_DirBase() + "reports\XD_Sample08.frx"
   LOCAL cFilePDF := hb_DirBase() + "reports\XD_Sample08.pdf"
   LOCAL cPg      := "Page1"

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :SetReportInfo( "C. Navarro", "Sample 01", "Ejemplo Basico", "26.03.01", "Cliente" )
      
         :AddBand( "REPORTTITLE", cPg, "BandaTit" )
         :AddMemoEx( "BandaTit", "MemTit", 0, 0, 19, 1, cTitle )
         :SetProperty( "MemTit", "FillColor", 0x404040 )
         :SetProperty( "MemTit", "Font.Color", -1 )
         :SetProperty( "MemTit", "HAlign", 1 )
      
         :AddBand( "DATA", cPg, "BandaCuerpo" )
         :AddMemoEx( "BandaCuerpo", "MemCuerpo", 0, 0.5, 19, 1, "Este es un documento exportado a PDF el " + DToC(Date()) )
      
         IF :Prepare( .F. ) 
            :ExportPDF( cFilePDF )
            :Show()
            :Save( cFileFRX )
            :ShowPdf( , , cFilePDF )
         ELSE
            Alert( "Error: " + oFR:GetLastError() )
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample09: ExportHTML
//----------------------------------------------------------------------------//

FUNCTION XD_Sample09()

   LOCAL cFileFRX  := hb_DirBase() + "reports\XD_Sample09.frx"
   LOCAL cFileHTML := hb_DirBase() + "reports\XD_Sample09.html"
   LOCAL cPg       := "Page1"

   InitFastReport()

   TRY
      WITH OBJECT oFR
      
         :AddBand( "REPORTTITLE", cPg, "BandaTit" )
         :AddMemoEx( "BandaTit", "MemWeb", 0, 0, 19, 1, "INFORME INTERACTIVO HTML" )
         :SetProperty( "MemWeb", "FillColor", 0x008000 )
         :SetProperty( "MemWeb", "Font.Color", -1 )
      
         :AddMemoEx( "BandaTit", "LnkDoc", 2, 1.2, 7, 0.5, "VER DOCUMENTACION" )
         :SetHyperlink( "LnkDoc", 0, "https://fastreports.github.io/FastReport.Documentation/ClassReference/api/FastReport.html" )
         :SetProperty( "LnkDoc", "Font.Color", 0x0000FF ) 
         :SetProperty( "LnkDoc", "Font.Style", 4 )
         :SetProperty( "LnkDoc", "HAlign", 2 )
         :SetProperty( "LnkDoc", "Cursor", 13 )
      
         :AddMemoEx( "BandaTit", "Sep", 9, 1.2, 1, 0.5, " | " )
         :SetProperty( "Sep", "HAlign", 1 )
      
         :AddMemoEx( "BandaTit", "LnkGit", 10, 1.2, 7, 0.5, "CODIGO FUENTE" )
         :SetHyperlink( "LnkGit", 0, "https://github.com/FastReports/FastReport" )
         :SetProperty( "LnkGit", "Font.Color", 0x0000FF ) 
         :SetProperty( "LnkGit", "Font.Style", 4 )
         :SetProperty( "LnkGit", "HAlign", 0 )
         :SetProperty( "LnkGit", "Cursor", 13 )
      
         IF :Prepare( .F. )
            :Save( cFileFRX )
            :ExportHTML( cFileHTML )
            // ShowHtml( oWndParent, oWebView, cFileName, lUtf8, lMultiPage )
            :ShowHtml( , , cFileHTML )
         ELSE
            Alert( "Error en exportacion HTML: " + :GetLastError() )
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample10: 
//----------------------------------------------------------------------------//
/*
#define FR_FUNC_SUM 0

#define FR_HALIGN_LEFT      0
#define FR_HALIGN_CENTER    1
#define FR_HALIGN_RIGHT     2

#define FR_VALIGN_CENTER    1
*/

FUNCTION XD_Sample10()

   LOCAL cPg       := "MainPage"
   LOCAL cTitle    := "XDREPORTFAST - XDEVFORYOU - (C) - 2026"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample10.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample10.fpx"
   LOCAL cRegistered
   LOCAL cJson := '[{"Id": 1, "Product": "High-End Gaming Laptop with ultra wide screen", "Category": "Electronics", "Price": 2200, "Qty": 5},' + ;
                  ' {"Id": 2, "Product": "Wireless Mouse", "Category": "Electronics", "Price": 25, "Qty": 10},' + ;
                  ' {"Id": 3, "Product": "Executive Wooden Desk", "Category": "Furniture", "Price": 850, "Qty": 2},' + ;
                  ' {"Id": 4, "Product": "Ergonomic Office Chair", "Category": "Furniture", "Price": 150, "Qty": 4},' + ;
                  ' {"Id": 5, "Product": "Smartphone Pro Max 1TB", "Category": "Electronics", "Price": 1400, "Qty": 3}]'
   // cJson := '[{"Id": 1, "Product": "Laptop", "Price": 2200}, {"Id": 2, "Product": "Mouse", "Price": 25}]'
   InitFastReport( cPg )

   TRY
      WITH OBJECT oFR

         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )

         :AddBand( "REPORTTITLE", cPg, "BandaTit" )
         :SetHeight( "BandaTit", 25 )
         :AddMemoEx( "BandaTit", "MemTit", 0, 0, 190, 10, cTitle )
         :SetProperty( "MemTit", "FillColor", 0x404040 )
         :SetProperty( "MemTit", "Font.Color", -1 )
         :SetProperty( "MemTit", "HAlign", 1 )
         :AddMemoEx( "BandaTit", "title1", 0, 12, 190, 10, "FORMATOS DE BANDAS, GRUPOS, TOTALES, PIJAMA" )
         :SetProperty( "title1", "FillColor", 0x008000 )
         :SetProperty( "title1", "Font.Color", -1 )
         :SetProperty( "title1", "HAlign", 1 )
         :SetProperty( "title1", "VAlign", 1 )

         // :RegisterJson( cJson, "Products" )
         :RegisterJsonData( cJson, "Products" )

         // ? "Registered Tables after RegisterJsonData:"
         cRegistered := :GetRegisteredTables()
         ? cRegistered

         // Grouping by Category
         :AddGroup( cPg, "GrpCategory", "[Products.Category]" )
         :AddMemoEx( "GrpCategory", "TxtGrp", 5, 2, 100, 6, "CATEGORY: [Products.Category]", 0x000000, -1, "Arial", 12, 0, 0 )

         // Data Band
         :AddBand( "DATA", cPg, "DataBand", "Products" )
         :SetHeight( "DataBand", 10 )

         // 1. Zebra Striping
         :SetEvenStyle( "DataBand", nRGB( 230, 240, 255 ) )

         // 2. Product Memo with CanGrow (for long names)
         :AddMemoEx( "DataBand", "TxtProduct", 5, 0, 80, 5, "[Products.Product]", 0x000000, -1, "Arial", 10, 2, 0 )
         :SetCanGrow( "TxtProduct", .T. )

         // 3. Price with Conditional Highlight
         :AddMemoEx( "DataBand", "TxtPrice", 90, 0, 30, 5, "[Products.Price]", 0x000000, -1, "Arial", 10, 2, 0 )
         :SetFormat( "TxtPrice", "#,##0.00" ) 
         // Highlight: If Price > 1000, Background Red, Text White, Bold
         :AddHighlight( "TxtPrice", "[Products.Price] > 1000", CLR_WHITE, CLR_HRED, .T., .F. )

         // 5. Bands (Defined first so they can be referenced in Totals)
         :AddBand( "GROUPFOOTER", cPg, "GrpFooter" )
         :SetHeight( "GrpFooter", 8 )
         :AddBand( "REPORTSUMMARY", cPg, "SummaryBand", "" )
         :SetHeight( "SummaryBand", 12 )

         // 4. Totals (Bands must exist for PrintOn/ResetOn)
         // Subtotal (resets on Group)
         :AddTotal( "SubtotalPrice", "[Products.Price]", FR_FUNC_SUM, "DataBand", "GrpFooter", "GrpCategory" )
         // General Total (resets on nothing)
         :AddTotal( "TotalGeneral", "[Products.Price]", FR_FUNC_SUM, "DataBand", "SummaryBand", "" )

         // 6. Output Memos
         :AddMemoEx( "GrpFooter", "TxtSub", 90, 1, 30, 5, "Subtotal: [SubtotalPrice]", 0, -1, "Arial", 10, FR_HALIGN_RIGHT, FR_VALIGN_CENTER )
         :AddMemoEx( "SummaryBand", "LblFull", 20, 2, 70, 8, "TOTAL GENERAL:", 0, -1, "Arial", 10, FR_HALIGN_LEFT, FR_VALIGN_CENTER )
         :AddMemoEx( "SummaryBand", "ValFull", 90, 2, 30, 8, "[TotalGeneral]", 0, -1, "Arial", 10, FR_HALIGN_RIGHT, FR_VALIGN_CENTER )

         IF :Prepare( .F. )
            :Show( "Sample 10 - Design Bands, Groups, Conditions Colors and Totals" )
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ELSE
            ? :GetLastError()
         ENDIF

         // ? "Opening Designer to verify formatting structure..."
         // oFR:Design()
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample11: Array Data Source Sample
//----------------------------------------------------------------------------//

FUNCTION XD_Sample11()

   LOCAL cPg     := "Page1"
   LOCAL aData := { ;
      { "ID" => 1, "Name" => "Apple",  "Price" => 1.50, "Stock" => 100 }, ;
      { "ID" => 2, "Name" => "Banana", "Price" => 0.80, "Stock" => 250 }, ;
      { "ID" => 3, "Name" => "Orange", "Price" => 1.20, "Stock" => 180 }, ;
      { "ID" => 4, "Name" => "Grapes", "Price" => 2.50, "Stock" => 90  }, ;
      { "ID" => 5, "Name" => "Pear",   "Price" => 1.30, "Stock" => 120 }  ;
   }
   
   InitFastReport()

   TRY
      WITH OBJECT oFR
         :RegisterData( "Fruits", aData )

         :AddBand( "REPORTTITLE", "Page1", "BandaTitulo" ) 
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 0, 0, 19, 1, "LISTADO DE FRUTAS DESDE ARRAY DE HASHS (HARBOUR)" )
         :SetProperty( "TxtTitulo", "Font.Size", 16 )
         :SetProperty( "TxtTitulo", "Font.Style", 1 )      // Bold
         :SetProperty( "TxtTitulo", "HorzAlign", 1 )       // Center

         :AddBand( "COLUMNHEADER", "Page1", "BandaCab" )
         :AddMemoEx( "BandaCab", "LblID",    0,   0, 2, 0.6, "ID" )
         :AddMemoEx( "BandaCab", "LblName",  2.5, 0, 8, 0.6, "NOMBRE" )
         :AddMemoEx( "BandaCab", "LblPrice", 11,  0, 3, 0.6, "PRECIO" )
         :AddMemoEx( "BandaCab", "LblStock", 14.5, 0, 3, 0.6, "STOCK" )
         :SetProperty( "LblPrice", "HorzAlign", 2 )
         :SetProperty( "LblStock", "HorzAlign", 2 )
         :SetHeight( "BandaCab", 0.6 )
         :SetProperty( "BandaCab", "Fill.Color", "LightGray" )

         :AddBand( "DATA", "Page1", "BandaDatos", "Fruits" )
         :AddMemoEx( "BandaDatos", "FldID",    0,   0, 2, 0.6, "[Fruits.ID]" )
         :AddMemoEx( "BandaDatos", "FldName",  2.5, 0, 8, 0.6, "[Fruits.Name]" )
         :AddMemoEx( "BandaDatos", "FldPrice", 11,  0, 3, 0.6, "[Fruits.Price]" )
         :AddMemoEx( "BandaDatos", "FldStock", 14.5, 0, 3, 0.6, "[Fruits.Stock]" )
         :SetProperty( "FldPrice", "HorzAlign", 2 )
         :SetProperty( "FldStock", "HorzAlign", 2 )
         :SetHeight( "BandaDatos", 0.6 )

         IF :Prepare( .F. )
            :Show()
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample12: Array of Arrays Data Source Sample
//----------------------------------------------------------------------------//

FUNCTION XD_Sample12()

   LOCAL cPg     := "Page1"
   LOCAL aColumns := { "ID", "NAME", "PRICE", "STOCK" }
   // LOCAL aColumns := {} // Prueba de columnas autom?ticas
   LOCAL aDatos := { ;
      { 1, "Apple",  1.50, 100 }, ;
      { 2, "Banana", 0.80, 250 }, ;
      { 3, "Orange", 1.20, 180 }, ;
      { 4, "Grapes", 2.50, 90  }, ;
      { 5, "Pear",   1.30, 120 }  ;
   }
   LOCAL aFinal := {}, hRow, n, i
   LOCAL cTable := "DynamicArray"

   // 1. Si aColumns est? vac?o, generamos nombres gen?ricos
   IF Empty( aColumns )
      aColumns := {}
      FOR i := 1 TO Len( aDatos[1] )
         AAdd( aColumns, "COL-" + PadL( i, 2, "0" ) )
      NEXT
   ENDIF

   // 2. Transformamos el Array de Arrays a Array de Hashes para que el Bridge lo entienda
   FOR n := 1 TO Len( aDatos )
      hRow := {=>}
      FOR i := 1 TO Len( aColumns )
         hRow[ aColumns[i] ] := aDatos[n][i]
      NEXT
      AAdd( aFinal, hRow )
   NEXT

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :RegisterData( cTable, aFinal )

         :AddBand( "REPORTTITLE", "Page1", "BandaTitulo" ) 
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 0, 0, 19, 1, "LISTADO DESDE ARRAY DE ARRAYS (XD_SAMPLE12)" )
         :SetProperty( "TxtTitulo", "Font.Size", 16 )
         :SetProperty( "TxtTitulo", "Font.Style", 1 )
         :SetProperty( "TxtTitulo", "HorzAlign", 1 )

         // Cabecera din?mica
         :AddBand( "COLUMNHEADER", "Page1", "BandaCab" )
         :AddMemoEx( "BandaCab", "Lbl1", 0,    0, 2, 0.6, aColumns[1] )
         :AddMemoEx( "BandaCab", "Lbl2", 2.5,  0, 8, 0.6, aColumns[2] )
         :AddMemoEx( "BandaCab", "Lbl3", 11,   0, 3, 0.6, aColumns[3] )
         :AddMemoEx( "BandaCab", "Lbl4", 14.5, 0, 3, 0.6, aColumns[4] )
         :SetProperty( "Lbl3", "HorzAlign", 2 )
         :SetProperty( "Lbl4", "HorzAlign", 2 )
         :SetHeight( "BandaCab", 0.6 )
         :SetProperty( "BandaCab", "Fill.Color", "LightSkyBlue" )

         // Datos din?micos
         :AddBand( "DATA", "Page1", "BandaDatos", cTable )
         :AddMemoEx( "BandaDatos", "Data1", 0,    0, 2, 0.6, "[" + cTable + "." + aColumns[1] + "]" )
         :AddMemoEx( "BandaDatos", "Data2", 2.5,  0, 8, 0.6, "[" + cTable + "." + aColumns[2] + "]" )
         :AddMemoEx( "BandaDatos", "Data3", 11,   0, 3, 0.6, "[" + cTable + "." + aColumns[3] + "]" )
         :AddMemoEx( "BandaDatos", "Data4", 14.5, 0, 3, 0.6, "[" + cTable + "." + aColumns[4] + "]" )
         :SetProperty( "Data3", "HorzAlign", 2 )
         :SetProperty( "Data4", "HorzAlign", 2 )
         :SetHeight( "BandaDatos", 0.6 )

         IF :Prepare( .F. )
            :Show()
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample13: Transparent Array Data Source Sample (Simplificado)
//              El usuario no hace conversiones, la clase TXDFastReport se encarga
//----------------------------------------------------------------------------//

FUNCTION XD_Sample13()

   LOCAL cPg     := "Page1"
   LOCAL aDatos := { ;
      { 101, "Monitor 24'", 150.00, 10 }, ;
      { 102, "Teclado RGB",  45.50, 50 }, ;
      { 103, "Raton Pro",    29.90, 30 }  ;
   }
   // Columnas opcionales (si no se pasan, pondra COL-01, COL-02, etc)
   LOCAL aColumns := { "COD", "ARTICULO", "PRECIO", "STOCK" }
   
   InitFastReport()

   TRY
      WITH OBJECT oFR
         :SetDataArray( "Productos", aDatos, aColumns )

         :AddBand( "REPORTTITLE", "Page1", "BandaTitulo" ) 
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 0, 0, 19, 1, "LISTADO CON ARRAYS (XD_SAMPLE13)" )
         :SetProperty( "TxtTitulo", "Font.Size", 16 )
         :SetProperty( "TxtTitulo", "HorzAlign", 1 )

         :AddBand( "COLUMNHEADER", "Page1", "BandaCab" )
         :AddMemoEx( "BandaCab", "L1", 0, 0, 3, 0.6, "CODIGO" )
         :AddMemoEx( "BandaCab", "L2", 3, 0, 8, 0.6, "ARTICULO" )
         :AddMemoEx( "BandaCab", "L3", 11,0, 3, 0.6, "PRECIO" )
         :SetProperty( "L3", "HorzAlign", 2 )
         :SetHeight( "BandaCab", 0.6 )
         :SetProperty( "BandaCab", "Fill.Color", "Gold" )

         :AddBand( "DATA", "Page1", "BandaDatos", "Productos" )
         // Usamos los nombres de columna que definimos
         :AddMemoEx( "BandaDatos", "D1", 0, 0, 3, 0.6, "[Productos.COD]" )
         :AddMemoEx( "BandaDatos", "D2", 3, 0, 8, 0.6, "[Productos.ARTICULO]" )
         :AddMemoEx( "BandaDatos", "D3", 11,0, 3, 0.6, "[Productos.PRECIO]" )
         :SetProperty( "D3", "HorzAlign", 2 )
         :SetHeight( "BandaDatos", 0.6 )

         IF :Prepare( .F. )
            :Show()
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample14: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample14()

   LOCAL cPg       := "Page1"
   LOCAL cPath     := hb_DirBase() + "img\xdevforyou.png"    // "\img\fe03.png"   // "c:\logos\empresa.jpg" )
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample14.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample14.fpx"
   LOCAL nRojo     := RGB(255, 0, 0)
   LOCAL nAzul     := RGB(0, 0, 255)
   LOCAL nVerde    := RGB(0, 150, 0)
   LOCAL nGris     := RGB(128, 128, 128)

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :RegisterCustomFunc( "GET_IVA" , , )
         ? :GetLastError()

         :AddPage( cPg )
         // :SetUnit( FR_UNIT_MM )
         :SetUnit( 4 )

         :AddBand( "REPORTTITLE", cPg, "BandaTitulo" )

         // 6. Imagen de logotipo
         // :AddPictureEx( cPg, "ImgLogo", 600, 10, 100, 40, cPath )
         :AddPictureEx( "BandaTitulo", "ImgLogo", 600, 10, 100, 40, cPath )
         // 

         // 1. Cabecera con fuente grande y color personalizado
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 10, 10, 500, 40, "FACTURA DE VENTA", CLR_WHITE, nAzul, "Verdana", 20 )
         // 2. Línea separadora de color gris y 2pt de grosor
         :AddLineEx( "BandaTitulo", "LineSep", 10, 55, 750, 0, nGris, 2.0 )
         // 3. Datos con fuente estandar (usa los valores por defecto: Negro, Arial 12)
         :AddMemoEx( "BandaTitulo", "TxtCliente", 10, 70, 300, 20, "Cliente: Juan Perez" )
         :AddMemoEx( "BandaTitulo", "TxtFecha", 10, 95, 300, 20, "Fecha: " + Dtoc( Date() ) )
          
         // oFR:AddMemoEx( , "TxtIva", 10, 120, 300, 20, '[GET_IVA("21", "ES", "100")]' )    // GET_IVA([datos.cliente])
         :AddMemoEx( "BandaTitulo", "TxtIva", 10, 120, 300, 20, '[GET_IVA("21")]' )
       
         // La url a la que saltemos debe permitir iframes
         :SetHyperlink( "TxtTitulo", 0, "https://www.google.com" )
         // oFR:SetHtmlClickScript( "" )
         // oFR:SetHtmlClickScript( "window.location.href = '/detalle?id=[VALUE]';" )
          
         :SetHyperlink( "TxtIva", 0, "ID_IVA_21" )    
       
         // 4. Codigo de barras en color Rojo para llamar la atención
         :AddBarcodeEx( "BandaTitulo", "BarCode1", 500, 70, 200, 60, "20260001", "CODE128", nRojo )
         // 5. Codigo QR con enlace web en color Verde
         :AddBarcodeEx( "BandaTitulo", "QrCode1", 10, 150, 100, 100, "www.tuempresa.com", "QR", nVerde )

         // Ocultar un elemento específico
         // :SetVisible( "TxtIva", .F. )      // Oculta el texto del IVA
         // :SetVisible( "ImgLogo", .F. )     // Oculta el logo
         // :SetVisible( "BarCode1", .F. )    // Oculta el código de barras
         // Mostrarlo de nuevo
         // :SetVisible( "TxtIva", .T. )
          
         // Para bandas enteras
         // :SetBandVisible( "BandaDatos1", .F. )
          
         // Preparar y Mostrar
         // ? oFR:GetInternalState()

         IF :Prepare( .F. )
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ELSE
            ? :GetLastError()
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN Nil

//----------------------------------------------------------------------------//
// XD_Sample15: Factura Master-Detail usando Arrays de Arrays (Raw)
//----------------------------------------------------------------------------//

FUNCTION XD_Sample15()

   LOCAL cPg     := "Page1"
   LOCAL aMasterCols := { "ID", "Date", "Customer", "Address", "SubTotal", "IVA_Pct", "IVA_Amt", "Total" }
   LOCAL aMaster     := { { 1001, "2026-03-01", "ACME CORP", "Industrial Blvd 456", 3000.00, 21, 630.00, 3630.00 } }
   
   LOCAL aDetailCols := { "ID", "Item", "Qty", "Price", "LineTotal" }
   LOCAL aDetail     := { ;
      { 1001, "Licencia Software Pro",  1,  1500.00, 1500.00 }, ;
      { 1001, "Horas Desarrollo",      10,   150.00, 1500.00 }  ;
   }
   
   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( "Page1" )
         :SetUnit( 0 ) // Millimeters

         // Ajuste de margenes para centrado (210 - 190 = 20 / 2 = 10mm cada lado)
         :SetProperty( "Page1", "LeftMargin",  10 )
         :SetProperty( "Page1", "RightMargin", 10 )

         :SetDataArray( "Factura", aMaster, aMasterCols )
         :SetDataArray( "Lineas",  aDetail, aDetailCols )
         :AddRelation( "FactRel",  "Factura", "Lineas", "ID", "ID" )

         // --- TITULO ---
         :AddBand( "ReportTitle", "Page1", "B_Title", "" )
         :SetHeight( "B_Title", 15 )
         :AddTextEx( "B_Title", "T_Factura", 0, 0, 190, 10, "FACTURA COMERCIAL", 0, 0, "Arial", 18, 1 )
         :SetProperty( "T_Factura", "HorzAlign", "Center" )
         :SetProperty( "T_Factura", "Font.Color", "clNavy" )

         // --- MASTER DATA (DATOS CABECERA) ---
         :AddBand( "Data", "Page1", "B_Master", "Factura" )
         :SetHeight( "B_Master", 45 ) // Aumentamos altura para meter las etiquetas de columnas
         :SetProperty( "B_Master", "StartNewPage", "true" )

         :AddTextEx( "B_Master", "L_Vendedor", 0,  2, 40, 5, "VENDEDOR:" )
         :SetProperty( "L_Vendedor", "Font.Style", "Bold" )
         :AddTextEx( "B_Master", "V_Vendedor", 0,  8, 80, 5, "XDEVSYSTEMS S.L." )

         :AddTextEx( "B_Master", "L_Cliente",  100,  2, 40, 5, "CLIENTE:" )
         :SetProperty( "L_Cliente", "Font.Style", "Bold" )
         :AddTextEx( "B_Master", "V_Cliente",  100,  8, 80, 5, "[Factura.Customer]" )
         :AddTextEx( "B_Master", "V_Addr",     100, 13, 80, 5, "[Factura.Address]" )

         :AddTextEx( "B_Master", "L_Fecha",    0, 22, 30, 5, "FECHA:" )
         :SetProperty( "L_Fecha", "Font.Style", "Bold" )
         :AddTextEx( "B_Master", "V_Fecha",    25, 22, 40, 5, "[Factura.Date]" )

         :AddTextEx( "B_Master", "L_Num",      100, 22, 30, 5, "N" + Chr(186) + " FRA:" )
         :SetProperty( "L_Num", "Font.Style", "Bold" )
         :AddTextEx( "B_Master", "V_Num",      125, 22, 40, 5, "[Factura.ID]" )

         :AddLineEx( "B_Master", "Sep1", 0, 32, 190, 0, 0, 1 )

         // --- ETIQUETAS DE COLUMNAS (Al final de la banda maestra para que salgan antes de los detalles) ---
         :AddTextEx( "B_Master", "H1",   0, 36,  20, 5, "CANT." )
         :AddTextEx( "B_Master", "H2",  25, 36, 100, 5, "DESCRIPCI" + Chr(211) + "N" )
         :AddTextEx( "B_Master", "H3", 130, 36,  30, 5, "PRECIO" )
         :AddTextEx( "B_Master", "H4", 160, 36,  30, 5, "TOTAL" )
         :SetProperty( "H1", "Font.Style", "Bold" )
         :SetProperty( "H2", "Font.Style", "Bold" )
         :SetProperty( "H3", "Font.Style", "Bold" )
         :SetProperty( "H3", "HorzAlign", "Right" )
         :SetProperty( "H4", "Font.Style", "Bold" )
         :SetProperty( "H4", "HorzAlign", "Right" )
         :AddLineEx( "B_Master", "SepH", 0, 43, 190, 0, 0, 1 )

         // --- BANDA DE DETALLE ---
         :AddBand( "Data", "B_Master", "B_Detail", "Lineas" )
         :SetHeight( "B_Detail", 7 )
         :SetBandRelation( "B_Detail", "FactRel" )

         :AddTextEx( "B_Detail", "D1",   0, 1,  20, 5, "[Lineas.Qty]" )
         :AddTextEx( "B_Detail", "D2",  25, 1, 100, 5, "[Lineas.Item]" )
         :AddTextEx( "B_Detail", "D3", 130, 1,  30, 5, "[Lineas.Price]" )
         :AddTextEx( "B_Detail", "D4", 160, 1,  30, 5, "[Lineas.LineTotal]" )
         :SetProperty( "D3", "HorzAlign", "Right" )
         :SetProperty( "D4", "HorzAlign", "Right" )

         // --- TOTALES (FOOTER DEL DETALLE) ---
         :AddBand( "DataFooter", "B_Detail", "B_DetFooter", "" )
         :SetHeight( "B_DetFooter", 25 )
         :AddLineEx( "B_DetFooter", "SepF", 0, 1, 190, 0, 0, 1 )

         :AddTextEx( "B_DetFooter", "L_Sub", 120, 5, 40, 5, "SUBTOTAL:" )
         :AddTextEx( "B_DetFooter", "V_Sub", 160, 5, 30, 5, "[Factura.SubTotal]" )
         :SetProperty( "V_Sub", "HorzAlign", "Right" )

         :AddTextEx( "B_DetFooter", "L_Iva", 120, 11, 40, 5, "IVA [Factura.IVA_Pct]%:" )
         :AddTextEx( "B_DetFooter", "V_Iva", 160, 11, 30, 5, "[Factura.IVA_Amt]" )
         :SetProperty( "V_Iva", "HorzAlign", "Right" )

         :AddLineEx( "B_DetFooter", "SepT", 120, 17, 70, 0, 0, 1 )
         :AddTextEx( "B_DetFooter", "L_Tot", 120, 19, 40, 7, "TOTAL FRA:" )
         :SetProperty( "L_Tot", "Font.Style", "Bold" )
         :SetProperty( "L_Tot", "Font.Size", 12 )
         :AddTextEx( "B_DetFooter", "V_Tot", 160, 19, 30, 7, "[Factura.Total]" )
         :SetProperty( "V_Tot", "Font.Style", "Bold" )
         :SetProperty( "V_Tot", "Font.Size", 12 )
         :SetProperty( "V_Tot", "HorzAlign", "Right" )

         IF :Prepare( .F. )
            :Show( "Sample 15 - Premium Master Detail Raw Arrays" )
         ELSE
             ? "Error Prepare:", :GetLastError()
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample16: Factura Master-Detail usando Arrays de Hashes (Premium)
//----------------------------------------------------------------------------//

FUNCTION XD_Sample16()

   LOCAL cPg     := "Page1"
   LOCAL aMaster := { { ;
      "ID" => 2001, "Date" => "2026-03-05", "Customer" => "WAYNE ENT.", ;
      "Sub" => 1000.00, "Iva" => 210.00, "Total" => 1210.00 ;
   } }
   
   LOCAL aDetail := { ;
      { "ID" => 2001, "Desc" => "Bat-Movil Maintenance", "Qty" => 1, "Price" => 800.00, "Tot" => 800.00 }, ;
      { "ID" => 2001, "Desc" => "Bat-Bumerang (Pack 5)", "Qty" => 2, "Price" => 100.00, "Tot" => 200.00 }  ;
   }
   
   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( "Page1" )
         :SetUnit( 0 )

         :SetProperty( "Page1", "LeftMargin",  10 )
         :SetProperty( "Page1", "RightMargin", 10 )

         :RegisterData( "Inv", aMaster )
         :RegisterData( "Det", aDetail )
         :AddRelation( "RelH", "Inv", "Det", "ID", "ID" )

         // --- TITULO ---
         :AddBand( "ReportTitle", "Page1", "T", "" )
         :SetHeight( "T", 15 )
         :AddTextEx( "T", "Title", 0, 0, 190, 10, "FACTURA DE SERVICIOS", 0, 0, "Arial", 18, 1 )
         :SetProperty( "Title", "HorzAlign", "Center" )
         :SetProperty( "Title", "Font.Color", "clMaroon" )

         // --- MASTER ---
         :AddBand( "Data", "Page1", "M", "Inv" )
         :SetHeight( "M", 40 )
         :SetProperty( "M", "StartNewPage", "true" )

         :AddTextEx( "M", "L1", 0, 5, 80, 5, "VENDEDOR: GOTHAM TECH SYSTEMS" )
         :AddTextEx( "M", "L2", 100, 5, 90, 5, "CLIENTE: [Inv.Customer]" )
         :SetProperty( "L2", "Font.Style", "Bold" )
         :AddTextEx( "M", "L3", 0, 15, 100, 5, "FACTURA N" + Chr(186) + ": [Inv.ID]  -  FECHA: [Inv.Date]" )
         :AddLineEx( "M", "LS", 0, 25, 190, 0, 0, 1 )

         // LABELS CABECERA DETALLE
         :AddTextEx( "M", "H1",  0, 31, 100, 5, "CONCEPTO" )
         :AddTextEx( "M", "H2", 105, 31,  20, 5, "CANT." )
         :AddTextEx( "M", "H3", 130, 31,  30, 5, "PRECIO" )
         :AddTextEx( "M", "H4", 160, 31,  30, 5, "TOTAL" )
         :SetProperty( "H1", "Font.Style", "Bold" )
         :SetProperty( "H2", "Font.Style", "Bold" )
         :SetProperty( "H2", "HorzAlign",  "Right" )
         :SetProperty( "H3", "Font.Style", "Bold" )
         :SetProperty( "H3", "HorzAlign",  "Right" )
         :SetProperty( "H4", "Font.Style", "Bold" )
         :SetProperty( "H4", "HorzAlign",  "Right" )
         :AddLineEx( "M", "LS2", 0, 38, 190, 0, 0, 1 )

         // --- DETAIL ---
         :AddBand( "Data", "M", "D", "Det" )
         :SetHeight( "D", 8 )
         :SetBandRelation( "D", "RelH" )

         :AddTextEx( "D", "D1",   0, 1, 100, 5, "[Det.Desc]" )
         :AddTextEx( "D", "D2", 105, 1,  20, 5, "[Det.Qty]" )
         :AddTextEx( "D", "D3", 130, 1,  30, 5, "[Det.Price]" )
         :AddTextEx( "D", "D4", 160, 1,  30, 5, "[Det.Tot]" )
         :SetProperty( "D2", "HorzAlign", "Right" )
         :SetProperty( "D3", "HorzAlign", "Right" )
         :SetProperty( "D4", "HorzAlign", "Right" )

         // --- TOTALES ---
         :AddBand( "DataFooter", "D", "DF", "" )
         :SetHeight( "DF", 20 )
         :AddLineEx( "DF", "DSF", 0, 1, 190, 0, 0, 1 )
         :AddTextEx( "DF", "T1", 120, 5, 40, 5, "SUBTOTAL:" )
         :AddTextEx( "DF", "T2", 160, 5, 30, 5, "[Inv.Sub]" )
         :SetProperty( "T2", "HorzAlign", "Right" )

         :AddTextEx( "DF", "T3", 120, 12, 40, 7, "TOTAL FRA:" )
         :SetProperty( "T3", "Font.Style", "Bold" )
         :SetProperty( "T3", "Font.Size",  12 )
         :AddTextEx( "DF", "T4", 160, 12, 30, 7, "[Inv.Total]" )
         :SetProperty( "T4", "Font.Style", "Bold" )
         :SetProperty( "T4", "Font.Size",  12 )
         :SetProperty( "T4", "HorzAlign", "Right" )

         IF :Prepare( .F. )
            :Show( "Sample 16 - Premium Master Detail Hashes" )
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample17: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample17()

   LOCAL cPg     := "Page1"
   // Ahora solo pasamos los datos base: quitamos IVA_Amt y Total (los calcular? FR)
   LOCAL aMasterCols := { "ID", "Date", "Customer", "Address", "SubTotal", "IVA_Pct" }
   LOCAL aMaster     := { { 3001, "2026-03-10", "TEKNOSIA S.A.", "Via Lactea 123", 450.00, 21 } }
   
   // No incluimos la columna de Total en el detalle, la calcular? FR
   LOCAL aDetailCols := { "ID", "Item", "Qty", "Price" }
   LOCAL aDetail     := { ;
      { 3001, "Pack Ratones Inalambricos",  5,  50.00 }, ;
      { 3001, "Teclado Mecanico RGB",      2,  100.00 }  ;
   }
   
   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( "Page1" )
         :SetUnit( 0 )

         :SetProperty( "Page1", "LeftMargin",  10 )
         :SetProperty( "Page1", "RightMargin", 10 )

         :SetDataArray( "Factura", aMaster, aMasterCols )
         :SetDataArray( "Lineas",  aDetail, aDetailCols )
         :AddRelation( "FactRel",  "Factura", "Lineas", "ID", "ID" )

         // --- TITULO ---
         :AddBand( "ReportTitle", "Page1", "T", "" )
         :SetHeight( "T", 15 )
         :AddTextEx( "T", "Title", 0, 0, 190, 10, "FACTURA CON CALCULOS DINAMICOS", 0, 0, "Arial", 16, 1 )
         :SetProperty( "Title", "HorzAlign", "Center" )
         :SetProperty( "Title", "Font.Color", "clDarkGreen" )

         // --- MASTER ---
         :AddBand( "Data", "Page1", "M", "Factura" )
         :SetHeight( "M", 45 )

         :AddTextEx( "M", "V1", 0,  5, 80, 5, "EMISOR: LOGIC SYSTEMS" )
         :AddTextEx( "M", "C1", 100, 5, 90, 5, "CLIENTE: [Factura.Customer]" )
         :SetProperty( "C1", "Font.Style", "Bold" )
         :AddTextEx( "M", "N1", 0, 15, 100, 5, "FACTURA N" + Chr(186) + ": [Factura.ID]  -  FECHA: [Factura.Date]" )

         :AddLineEx( "M", "L1", 0, 25, 190, 0, 0, 1 )

         // Headers Detail
         :AddTextEx( "M", "H1",  0, 31, 100, 5, "CONCEPTO" )
         :AddTextEx( "M", "H2", 105, 31,  20, 5, "CANT." )
         :AddTextEx( "M", "H3", 130, 31,  30, 5, "UNITARIO" )
         :AddTextEx( "M", "H4", 160, 31,  30, 5, "TOTAL (FR)" )
         :SetProperty( "H1", "Font.Style", "Bold" )
         :SetProperty( "H2", "Font.Style", "Bold" )
         :SetProperty( "H2", "HorzAlign",  "Right" )
         :SetProperty( "H3", "Font.Style", "Bold" )
         :SetProperty( "H3", "HorzAlign",  "Right" )
         :SetProperty( "H4", "Font.Style", "Bold" )
         :SetProperty( "H4", "HorzAlign",  "Right" )
         :AddLineEx( "M", "LS2", 0, 38, 190, 0, 0, 1 )

         // --- DETAIL ---
         :AddBand( "Data", "M", "D", "Lineas" )
         :SetHeight( "D", 8 )
         :SetBandRelation( "D", "FactRel" )

         :AddTextEx( "D", "D1",   0, 1, 100, 5, "[Lineas.Item]" )
         :AddTextEx( "D", "D2", 105, 1,  20, 5, "[Lineas.Qty]" )
         :AddTextEx( "D", "D3", 130, 1,  30, 5, "[Lineas.Price]" )

         // CALCULO DINAMICO: Multiplicamos directamente en la expresion
         :AddTextEx( "D", "D4", 160, 1,  30, 5, "[Lineas.Qty * Lineas.Price]" )

         :SetProperty( "D2", "HorzAlign", "Right" )
         :SetProperty( "D3", "HorzAlign", "Right" )
         :SetProperty( "D4", "HorzAlign", "Right" )
         :SetProperty( "D4", "Font.Style", "Bold" )

         // --- FOOTER ---
         :AddBand( "DataFooter", "D", "DF", "" )
         :SetHeight( "DF", 25 )
         :AddLineEx( "DF", "Sep", 0, 1, 190, 0, 0, 1 )
         
         :AddTextEx( "DF", "F1", 120, 5, 40, 5, "SUBTOTAL:" )
         :AddTextEx( "DF", "F2", 160, 5, 30, 5, "[Factura.SubTotal]" )
         :SetProperty( "F2", "HorzAlign", "Right" )
         
         // CALCULO DINAMICO DEL IVA
         :AddTextEx( "DF", "L_Iva", 120, 11, 40, 5, "IVA [Factura.IVA_Pct]%:" )
         :AddTextEx( "DF", "V_Iva", 160, 11, 30, 5, "[Factura.SubTotal * Factura.IVA_Pct / 100]" )
         :SetProperty( "V_Iva", "HorzAlign", "Right" )

         :AddLineEx( "DF", "F_Sep", 120, 17, 70, 0, 0, 1 )

         // C?LCULO DIN?MICO DEL TOTAL FINAL (Base + (Base * Pct / 100))
         :AddTextEx( "DF", "F3", 120, 19, 40, 7, "TOTAL FINAL:" )
         :SetProperty( "F3", "Font.Style", "Bold" )
         :AddTextEx( "DF", "F4", 160, 19, 30, 7, "[Factura.SubTotal + (Factura.SubTotal * Factura.IVA_Pct / 100)]" )
         :SetProperty( "F4", "Font.Style", "Bold" )
         :SetProperty( "F4", "Font.Size", 12 )
         :SetProperty( "F4", "HorzAlign", "Right" )

         IF :Prepare( .F. )
            :Show( "Sample 17 - Fully Dynamic Calculations" )
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample18: Ejemplo de uso de fichero CSV como origen de datos
//----------------------------------------------------------------------------//

FUNCTION XD_Sample18()

   LOCAL cPg      := "Page1"
   LOCAL cCsvFile := hb_DirBase() + "data\customers.csv"
   LOCAL lSw      := .T.
   
   // Si no existe, creamos uno de prueba
   IF !File( cCsvFile )
      hb_MemoWrit( cCsvFile, ;
         '"ID","NAME","CITY"' + hb_osNewLine() + ;
         '1,"John Doe","New York"' + hb_osNewLine() + ;
         '2,"Jane Smith","London"' + hb_osNewLine() + ;
         '3,"Carlos Perez","Madrid"' )
   ENDIF

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( "Page1" )
         :SetUnit( 0 )

         // Cargamos el CSV directamente. El bridge detecta cabeceras.
         // Par?metros: oFR:AddCsvFile( cAlias, cPath, cSeparator )
         IF !:AddCsvFile( "Clientes", cCsvFile, "," )
            MsgInfo( :GetLastError(), "Error cargando CSV" )
            lSw  := .F.
         ENDIF
         ? :GetLastError()

         IF lSw
            // --- TITULO ---
            :AddBand( "ReportTitle", "Page1", "T", "" )
            :SetHeight( "T", 15 )
            :AddTextEx( "T", "Title", 0, 0, 190, 10, "REPORTE DESDE FICHERO CSV", 0, 0, "Arial", 16, 1 )
            :SetProperty( "Title", "HorzAlign", "Center" )
            :SetProperty( "Title", "Font.Color", "clMaroon" )
            
            // Cabeceras de columnas manuales para que quede bonito
            :AddBand( "PageHeader", "Page1", "PH", "" )
            :SetHeight( "PH", 10 )
            :AddTextEx( "PH", "H1",   0, 2,  20, 5, "ID" )
            :AddTextEx( "PH", "H2",  25, 2,  80, 5, "NOMBRE" )
            :AddTextEx( "PH", "H3", 110, 2,  80, 5, "CIUDAD" )
            :SetProperty( "H1", "Font.Style", "Bold" )
            :SetProperty( "H2", "Font.Style", "Bold" )
            :SetProperty( "H3", "Font.Style", "Bold" )
            :AddLineEx( "PH", "L1", 0, 8, 190, 0, 0, 1 )
            
            // --- DATOS ---
            :AddBand( "Data", "Page1", "M", "Clientes" )
            :SetHeight( "M", 8 )
            
            :AddTextEx( "M", "C1",   0, 1,  20, 5, "[Clientes.ID]" )
            :AddTextEx( "M", "C2",  25, 1,  80, 5, "[Clientes.NAME]" )
            :AddTextEx( "M", "C3", 110, 1,  80, 5, "[Clientes.CITY]" )
            
            IF :Prepare( .F. )
               :Show( "Sample 14 - CSV File Data Source" )
            ENDIF
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample19: Ejemplo de uso de string CSV directo desde memoria
//----------------------------------------------------------------------------//

FUNCTION XD_Sample19()

   LOCAL cPg      := "Page1"
   LOCAL cCsvData := ""
   LOCAL lSw      := .T.
   
   // Construimos un CSV en memoria
   cCsvData += '"CODIGO","PRODUCTO","STOCK","PRECIO"' + hb_osNewLine()
   cCsvData += '100,"Monitor 27 PULGADAS",15,249.50'   + hb_osNewLine()
   cCsvData += '101,"Teclado Mecanico RGB",30,85.00'    + hb_osNewLine()
   cCsvData += '102,"Raton Gaming 16K DPI",50,45.90'   + hb_osNewLine()
   cCsvData += '103,"Alfombrilla XL",100,12.00'        + hb_osNewLine()

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( "Page1" )
         :SetUnit( 0 )

         // Cargamos el CSV desde String.
         // Parametros: oFR:AddCsvData( cAlias, cData, cSeparator )
         IF !:AddCsvData( "Stock", cCsvData, "," )
            MsgInfo( :GetLastError(), "Error cargando CSV de Memoria" )
            lSw   := .F.
         ENDIF

         IF lSw
            // --- TITULO ---
            :AddBand( "ReportTitle", "Page1", "T", "" )
            :SetHeight( "T", 15 )
            :AddTextEx( "T", "Title", 0, 0, 190, 10, "STOCKS DESDE STRING CSV", 0, 0, "Arial", 16, 1 )
            :SetProperty( "Title", "HorzAlign", "Center" )
            :SetProperty( "Title", "Font.Color", "clBlue" )
            
            // Cabeceras
            :AddBand( "PageHeader", "Page1", "PH", "" )
            :SetHeight( "PH", 10 )
            :AddTextEx( "PH", "H1",   0, 2,  20, 5, "COD." )
            :AddTextEx( "PH", "H2",  25, 2,  80, 5, "DESCRIPCION" )
            :AddTextEx( "PH", "H3", 110, 2,  30, 5, "STOCK" )
            :AddTextEx( "PH", "H4", 145, 2,  30, 5, "PRECIO" )
            :SetProperty( "H1", "Font.Style", "Bold" )
            :SetProperty( "H2", "Font.Style", "Bold" )
            :SetProperty( "H3", "Font.Style", "Bold" )
            :SetProperty( "H3", "HorzAlign", "Right" )
            :SetProperty( "H4", "Font.Style", "Bold" )
            :SetProperty( "H4", "HorzAlign", "Right" )
            :AddLineEx( "PH", "L1", 0, 8, 190, 0, 0, 1 )
            
            // --- DATOS ---
            :AddBand( "Data", "Page1", "M", "Stock" )
            :SetHeight( "M", 8 )
            
            :AddTextEx( "M", "C1",   0, 1,  20, 5, "[Stock.CODIGO]" )
            :AddTextEx( "M", "C2",  25, 1,  80, 5, "[Stock.PRODUCTO]" )
            :AddTextEx( "M", "C3", 110, 1,  30, 5, "[Stock.STOCK]" )
            :AddTextEx( "M", "C4", 145, 1,  30, 5, "[Stock.PRECIO]" )
            :SetProperty( "C3", "HorzAlign", "Right" )
            :SetProperty( "C4", "HorzAlign", "Right" )
            
            IF :Prepare( .F. )
               :Show( "Sample 19 - CSV String Data Source" )
            ENDIF
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample20: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample20()

   LOCAL cPg           := 'Page1'
   LOCAL cTitleBand, cPageHdr, cMasterBand, cDetailBand, cDataHdr, cDataFtr
   LOCAL cXmlFile      := hb_DirBase() + 'reports\nwind.xml'
   LOCAL lRet

   IF !File( cXmlFile )
      cXmlFile := 'reports\nwind.xml'
      IF !File( cXmlFile )
         MsgInfo( 'File not found: ' + cXmlFile )
         RETURN NIL
      ENDIF
   ENDIF

   InitFastReport() 

   TRY 
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         
         :SetProperty( cPg, "LeftMargin", 10 )
         :SetProperty( cPg, "RightMargin", 10 )

         // 1. Cargar XML
         lRet := :AddXmlFile( 'Northwind', cXmlFile )
         
         IF lRet
            :AddRelation( 'OrderDetailsRel', 'Orders', 'Order_Details', 'OrderID', 'OrderID' )

            // 3. Totales (Subtotal -> Sin calcular IVA aqui, lo haremos en el footer)
            :AddTotal( 'OrderSubTotal', 'Convert.ToDouble(Order_Details.UnitPrice) * Convert.ToDouble(Order_Details.Quantity) * (1.0 - Convert.ToDouble(Order_Details.Discount))', 0, 'DetailsBand', 'TotalsFtr', 'OrdersBand' )

            // -- Report Title: CORPORATE HEADER --
            cTitleBand := :AddBand( 'ReportTitle', cPg, 'TitleBand', '' )
            :SetHeight( cTitleBand, 35 )
            
            // Usamos AddShape(x, y, w, h, parent, name, type, border, fill)
            // nType=0 (Rectangle)
            // nBorderCol = 0x80 (Maroon en BGR/Harbour) o 128
            // nFillCol = 0x80 (Maroon en BGR/Harbour) o 128

            :AddShape( 0, 0, 190, 25, cTitleBand, "LogoBox", 0, 128, 128 )
            
            :AddTextEx( cTitleBand, 'CompanyName', 10,  5, 120, 10, 'XDEVSYSTEMS NORTHWIND APP' )
            :SetProperty( 'CompanyName', 'Font.Size', 16 )
            :SetProperty( 'CompanyName', 'Font.Style', 'Bold' )
            :SetProperty( 'CompanyName', 'Font.Color', 'clWhite' )
            
            :AddTextEx( cTitleBand, 'CompanyInfo', 10, 15, 100,  5, 'Enterprise XML Reporting Services' )
            :SetProperty( 'CompanyInfo', 'Font.Size', 8 )
            :SetProperty( 'CompanyInfo', 'Font.Color', 'clWhite' )
            
            :AddTextEx( cTitleBand, 'DocType', 130, 5, 50, 10, 'INVOICE' )
            :SetProperty( 'DocType', 'Font.Size', 18 )
            :SetProperty( 'DocType', 'Font.Style', 'Bold' )
            :SetProperty( 'DocType', 'Font.Color', 'clWhite' )
            :SetProperty( 'DocType', 'HorzAlign', 'Right' )

            // -- Page Header --
            cPageHdr := :AddBand( 'PageHeader', cPg, 'PageHdr', '' )
            :SetHeight( cPageHdr, 8 )
            :AddTextEx( cPageHdr, 'PgNum', 170, 2, 20, 5, 'Pag. [Page#]', 0, 0, 'Arial', 8, 0 )

            // -- Master Band: Orders (Invisible trigger) --
            cMasterBand := :AddBand( 'Data', cPg, 'OrdersBand', 'Orders' )
            :SetHeight( cMasterBand, 0.1 ) 
            :SetProperty( cMasterBand, 'StartNewPage', 'true' )

            // -- Detail Band: Order_Details --
            cDetailBand := :AddBand( 'Data', cMasterBand, 'DetailsBand', 'Order_Details' )
            :SetHeight( cDetailBand, 8 )
            :SetBandRelation( cDetailBand, 'OrderDetailsRel' )
            
            // Product Lines
            :AddTextEx( cDetailBand, 'ProdID',    10, 1,  20, 6, '[Order_Details.ProductID]' )
            :AddTextEx( cDetailBand, 'UnitPrice', 35, 1,  30, 6, '[Order_Details.UnitPrice]' )
            :AddTextEx( cDetailBand, 'Qty',       70, 1,  20, 6, '[Order_Details.Quantity]' )
            :AddTextEx( cDetailBand, 'Disc',      95, 1,  20, 6, '[Order_Details.Discount]' )
            :AddTextEx( cDetailBand, 'LineTot', 130, 1, 40, 6, '[Convert.ToDouble(Order_Details.UnitPrice) * Convert.ToDouble(Order_Details.Quantity) * (1.0 - Convert.ToDouble(Order_Details.Discount))]' )
            
            :SetProperty( 'UnitPrice', 'HorzAlign', 'Right' )
            :SetProperty( 'Qty',       'HorzAlign', 'Right' )
            :SetProperty( 'Disc',      'HorzAlign', 'Right' )
            :SetProperty( 'LineTot',   'HorzAlign', 'Right' )
            :SetProperty( 'LineTot',   'DisplayFormat.Format', 'N2' )
            :SetProperty( 'LineTot',   'Font.Style', 'Bold' )

            // -- Data Header: CLIENT INFO & TABLE HEADERS --
            cDataHdr := :AddBand( 'DataHeader', cDetailBand, 'InfoHdr', '' )
            :SetHeight( cDataHdr, 50 )

            // Client Info Box (nBorderCol = 0x808080 = 8421504, nFillCol = 0xFFFFFF = 16777215)
            
            :AddShape( 10, 5, 80, 25, cDataHdr, "ClientFrame", 0, 8421504, 16777215 )
            :AddTextEx( cDataHdr, 'LblClient',   12, 7,  40, 5, 'BILL TO:', 0, 0, 'Arial', 8, 1 )
            :AddTextEx( cDataHdr, 'CustVal',     12, 12, 70, 6, '[Orders.CustomerID]', 0, 0, 'Arial', 10, 1 )
            
            // Invoice Metadata
            :AddTextEx( cDataHdr, 'InvLbl',     110, 7, 35, 5, 'INVOICE NUM:', 0, 0, 'Arial', 8, 1 )
            :AddTextEx( cDataHdr, 'InvVal',     150, 7, 30, 5, '[Orders.OrderID]', 0, 0, 'Arial', 9, 1 )
            
            :AddTextEx( cDataHdr, 'DateLbl',    110, 14, 35, 5, 'DATE:', 0, 0, 'Arial', 8, 1 )
            :AddTextEx( cDataHdr, 'DateVal',    150, 14, 30, 5, '[Orders.OrderDate]', 0, 0, 'Arial', 9, 0 )
            
            :AddLineEx( cDataHdr, 'SepTop', 0, 35, 190, 0, 0, 0.5 )

            // Table Headers with Background (clDimGray = 0x696969 = 6908265)
            //
            :AddShape( 10, 40, 180, 8, cDataHdr, "HdrFill", 0, 6908265, 6908265 )
            :AddTextEx( cDataHdr, 'H_Prod',  12, 41,  20, 6, 'PRODUCT', 0, 0, 'Arial', 9, 1 )
            :AddTextEx( cDataHdr, 'H_Price', 35, 41,  30, 6, 'UNIT PRICE', 0, 0, 'Arial', 9, 1 )
            :AddTextEx( cDataHdr, 'H_Qty',   70, 41,  20, 6, 'QTY', 0, 0, 'Arial', 9, 1 )
            :AddTextEx( cDataHdr, 'H_Disc',  95, 41,  20, 6, 'DISC.', 0, 0, 'Arial', 9, 1 )
            :AddTextEx( cDataHdr, 'H_Tot',  130, 41,  38, 6, 'TOTAL AMOUNT', 0, 0, 'Arial', 9, 1 )
            
            :SetProperty( 'H_Prod', 'Font.Color', 'clWhite' )
            :SetProperty( 'H_Price','Font.Color', 'clWhite' )
            :SetProperty( 'H_Qty',  'Font.Color', 'clWhite' )
            :SetProperty( 'H_Disc', 'Font.Color', 'clWhite' )
            :SetProperty( 'H_Tot',  'Font.Color', 'clWhite' )
            :SetProperty( 'H_Price','HorzAlign',  'Right' )
            :SetProperty( 'H_Qty',  'HorzAlign',  'Right' )
            :SetProperty( 'H_Disc', 'HorzAlign',  'Right' )
            :SetProperty( 'H_Tot',  'HorzAlign',  'Right' )

            // -- Data Footer: TOTALS SUMMARY --
            cDataFtr := :AddBand( 'DataFooter', cDetailBand, 'TotalsFtr', '' )
            :SetHeight( cDataFtr, 40 )
            
            :AddLineEx( cDataFtr, 'LineFtr', 10, 2, 180, 0, 0, 1 )
            
            // Aesthetics Summary Box
            
            :AddShape( 110, 5, 80, 30, cDataFtr, "SumBox", 0, 8421504, 16777215 )
            
            :AddTextEx( cDataFtr, 'SubLbl', 115, 8, 35, 5, 'SUBTOTAL:' )
            :AddTextEx( cDataFtr, 'SubVal', 150, 8, 35, 5, '[OrderSubTotal]' )
            
            :AddTextEx( cDataFtr, 'IvaLbl', 115, 15, 35, 5, 'TAX (21.0%):' )
            :AddTextEx( cDataFtr, 'IvaVal', 150, 15, 35, 5, '[OrderSubTotal * 0.21]' )
            
            :AddLineEx( cDataFtr, 'SepFinal', 115, 23, 70, 0, 0, 0.5 )
            
            :AddTextEx( cDataFtr, 'TotLbl', 115, 26, 35, 6, 'TOTAL INVOICE:' )
            :SetProperty( 'TotLbl', 'Font.Style', 'Bold' )
            :AddTextEx( cDataFtr, 'TotVal', 150, 26, 35, 6, '[OrderSubTotal * 1.21]' )
            :SetProperty( 'TotVal', 'Font.Style', 'Bold' )
            :SetProperty( 'TotVal', 'Font.Size',  11 )
            
            :SetProperty( 'SubVal', 'HorzAlign', 'Right' )
            :SetProperty( 'SubVal', 'DisplayFormat.Format', 'N2' )
            :SetProperty( 'IvaVal', 'HorzAlign', 'Right' )
            :SetProperty( 'IvaVal', 'DisplayFormat.Format', 'N2' )
            :SetProperty( 'TotVal', 'HorzAlign', 'Right' )
            :SetProperty( 'TotVal', 'DisplayFormat.Format', 'N2' )

            IF :Prepare( .F. )
               :Show( 'Sample 20 - XML Premium Invoice' )
            ELSE
               ? "Prepare Error:", :GetLastError()
            ENDIF
         ELSE
            ? "AddXmlFile Error:", :GetLastError()
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample21: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample21()

   LOCAL cPg       := "Page1"
   LOCAL cJsonFile := hb_DirBase() + "reports\customer0.JSON"
   LOCAL cJson     := hb_MemoRead( cJsonFile )
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample21.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample21.fpx"

   InitFastReport()

   TRY
      WITH OBJECT oFR
         // :RegisterCustomFunc( "GET_IVA" , , )
         :SetUnit( FR_UNIT_MM )
         :AddPage( cPg )

         // Registro de datos JSON
         // RegisterJSON( jsonContent, connectionName, tableName )
         // Ambos son validos
         :RegisterJSON( cJson, "ConexionJSON", "Clientes" )
         // o este
         // :AddJsonString( "Clientes", cJson )
         
         // o asi directamente del fichero
         // :AddJsonFile( "Clientes", cJsonFile )
         
         ? "JSON Status:", :GetLastError()
      
         // Banda de Titulo
         :AddBand( "REPORTTITLE", cPg, "BandaTitulo" )
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 0, 0, 190, 10, "LISTADO DE CLIENTES (JSON LOCAL)", 0, 12632256, "Arial", 14, 1, 1 )
      
         // Banda de Cabecera de Datos
         :AddBand( "DATAHEADER", cPg, "CabeceraDatos" )
         //:SetProperty( "CabeceraDatos", "Height", 1.5 )
         :AddMemoEx( "CabeceraDatos", "H_ID",    0, 0, 30, 1, "ID", 0, 65535, "Arial", 10, 1, 1 )
         :AddMemoEx( "CabeceraDatos", "H_NAME", 30, 0, 80, 1, "NOMBRE", 0, 65535, "Arial", 10, 0, 1 )
         :AddMemoEx( "CabeceraDatos", "H_CITY", 110, 0, 50, 1, "CIUDAD", 0, 65535, "Arial", 10, 0, 1 )
      
         // Banda de Datos
         :AddBand( "DATA", cPg, "BandaDatos", "Clientes" ) // , "Datas" )   //
         // :SetBandDataSource( "BandaDatos", "Clientes" )
         // :SetHeight( "BandaDatos", 8 )
         :SetProperty( "BandaDatos", "Height", 10 )
      
         // Los campos se referencian como [Tabla.Campo] - DEBEN coincidir con los del JSON
         :AddMemoEx( "BandaDatos", "F_ID",     0, 0, 30, 8, "[Clientes.ID]" )
         :AddMemoEx( "BandaDatos", "F_NAME",  30, 0, 80, 8, "[Clientes.FIRST]" ) // O [Clientes.LAST]
         :AddMemoEx( "BandaDatos", "F_CITY", 110, 0, 50, 8, "[Clientes.CITY]" )

         // :AddBand( "DATA", cPg, "Detalle", "Datas" )
         // :AddMemoEx( "Detalle", "M1", 0.5, 0.2, 5, 0.5, "[Datas.FIRST]" )
         // :AddMemoEx( "Detalle", "M2", 6, 0.2, 5, 0.5, "[Datas.SALARY]" )
         // :AddMemoEx( "Detalle", "M1", 0.5, 0.2, 50, 50, '[GET_IVA("21")]' )
         ? "DS Status:", :GetLastError()
         
         IF :Prepare( .F. )
            :Show( "Sample 21 - JSON Local" )
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ELSE
            ? :GetLastError()
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample22: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample22()

   LOCAL cPg          := "Page1"
   LOCAL cJsonFile    := hb_DirBase() + "reports\nwind.json"
   LOCAL cJson        := ""   // hb_MemoRead( cJsonFile )
   LOCAL cFile        := hb_DirBase() + "reports\XD_Sample22.frx"
   LOCAL cFilePrep    := hb_DirBase() + "reports\XD_Sample22.fpx"
   LOCAL cListaTablas

/*
   // Si tienes la ruta de un mega-archivo:
   LOCAL cJsonFile := hb_DirBase() + "reports\nwind.json" 
   // Devuelve un string separado por comas
   LOCAL cListaTablas := oFR:GetJsonTablesList( cJsonFile, .T. )  // .T. = Es archivo f?sico
   
   ? "Tablas encontradas en el disco:", cListaTablas
   // Te imprimir?: "Categories,Customers,Employees,Order Details,Orders,Products..."

   
   // Si por el contrario tienes el JSON crudo bajado de una API en variable local:
   LOCAL cJsonString := '{"MiTabla1": [{"id":1}], "MiTabla2": [{"id":2}]}'
   LOCAL cListaOtra := oFR:GetJsonTablesList( cJsonString, .F. )  // .F. = Es texto en memoria
   
   ? "Tablas encontradas en memoria:", cListaOtra
   // Te imprimir?: "MiTabla1,MiTabla2"

*/
   InitFastReport()

   TRY
      WITH OBJECT oFR
         // Obtener todas las tablas contenidas en el JSON ( puede haber varias )
         ? cListaTablas := oFR:GetJsonTablesList( cJsonFile, .T. )  // .T. = Es archivo f?sico
         
         :SetUnit( FR_UNIT_MM )
         :AddPage( cPg )
         
         // nwind.json tiene una estructura de DataSet. 
         // 1. Delegamos todo en la DLL de C# pas?ndole la ruta.
         // Nuestro submotor inteligente se encargar? de extraer las tablas Ocultas (Categories, Customers, etc)
         :AddJsonFile( "NWConn", cJsonFile )
         
         :AddBand( "REPORTTITLE", cPg, "BandaTitulo" )
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 0, 0, 190, 10, "NORTHWIND CATEGORIES (JSON)", 0, 16776960, "Arial", 14, 1, 1 )
         
         // Podemos usar el 4? parametro en lugar del SetBandDataSource, no?
         :AddBand( "DATA", cPg, "BandaDatos", "Categories" )
         // :SetBandDataSource( "BandaDatos", "Categories" )
         // :SetHeight( "BandaDatos", 8 )
         :SetProperty( "BandaDatos", "Height", 10 )
         
         :AddMemoEx( "BandaDatos", "F_ID",   0, 0, 30, 8, "[Categories.CategoryID]" )
         :AddMemoEx( "BandaDatos", "F_NAME", 30, 0, 100, 8, "[Categories.CategoryName]" )
         
         IF :Prepare( .F. )
            :Save( cFile )
            :Show( "Sample 22 - NWind JSON" )
            :SavePrepared( cFilePrep )
         ELSE
            ? :GetLastError()      
         ENDIF

      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample23: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample23()

   LOCAL cPg          := "Page1"
   LOCAL cJsonFile    := hb_DirBase() + "reports\ProductList.json"
   LOCAL cJson        := hb_MemoRead( cJsonFile )
   LOCAL cFile        := hb_DirBase() + "reports\XD_Sample23.frx"
   LOCAL cFilePrep    := hb_DirBase() + "reports\XD_Sample23.fpx"
   LOCAL cListaTablas

   InitFastReport()

   TRY
      WITH OBJECT oFr
         :SetUnit( FR_UNIT_MM )
         :AddPage( cPg )
      
         // Son equivalentes
         // :RegisterJSON( cJson, "ProdConn", "Productos" )
         // :AddJsonString( "Productos", cJson )
         
         :AddJsonFile( "Productos", cJsonFile )
      
         :AddBand( "REPORTTITLE", cPg, "BandaTitulo" )
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 0, 0, 190, 10, "PRODUCT LIST (JSON)", 0, 65280, "Arial", 14, 1, 1 )
      
         :AddBand( "DATA", cPg, "BandaDatos", "Productos" )
         // :SetBandDataSource( "BandaDatos", "Productos" )
         :SetHeight( "BandaDatos", 22 )
      
         :AddMemoEx( "BandaDatos", "F_NAME",    0, 0,  60, 8, "[Productos.ProductName]" )
         :AddMemoEx( "BandaDatos", "F_PRICE",  70, 0,  40, 8, "[Productos.Price]" )
         // :AddMemoEx( "BandaDatos", "F_IMG",   120, 0, 100, 8, "[Productos.ProductImage]" )
         // 1. A?adimos el PictureObject vac?o (el ?ltimo par?metro de ruta va simulado/vac?o)
         :AddPictureEx( "BandaDatos", "IMG_PROD", 120, 0, 40, 20, "[Productos.ProductImage]" ) // "" )  // 
         // 2. Le decimos a FastReport que NO lea de una ruta C:\... sino de la tabla JSON
         // Esto ya no hace falta, solucionado poniendo arriba el campo, como en otros controles
         // :SetProperty( "IMG_PROD", "DataColumn", "Productos.ProductImage" )
         // 3. Activamos el modo Base64 para que el Bridge de C# lo procese al vuelo
         :SetProperty( "IMG_PROD", "Tag", "BASE64" )


         IF :Prepare( .F. )
            :Show( "Sample 23 - Product List JSON" )
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ELSE
            ? :GetLastError()      
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample24: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample24()

   LOCAL cPg          := "Page1"
   LOCAL cUrl         := "https://www.fruityvice.com/api/fruit/all"
   LOCAL cFile        := hb_DirBase() + "reports\XD_Sample24.frx"
   LOCAL cFilePrep    := hb_DirBase() + "reports\XD_Sample24.fpx"
   LOCAL cListaTablas

   InitFastReport()

   TRY
      WITH OBJECT oFr
         :SetUnit( FR_UNIT_MM )
         :AddPage( cPg )
      
         // Uso de AddRemoteJsonSource( url, headers, connectionName, tableName )
         :AddRemoteJsonSource( cUrl, "", "FruitAPI", "Fruits" )

         // Uso de AddJsonConn para persistencia en el Designer
         // No implementado
         //  :AddJsonConn( "FruitAPI", cUrl )
         //  :AddJsonTable( "Fruits", "FruitAPI", "*" )
      
         :AddBand( "REPORTTITLE", cPg, "BandaTitulo" )
         :AddMemoEx( "BandaTitulo", "TxtTitulo", 0, 0, 190, 10, "REMOTE FRUIT API (fruityvice.com)", 0, 255, "Arial", 14, 1, 1 )
      
         :AddBand( "DATA", cPg, "BandaDatos" )
         :SetBandDataSource( "BandaDatos", "Fruits" )
         :SetHeight( "BandaDatos", 8 )

         :AddMemoEx( "BandaDatos", "F_ID",       0, 0, 20, 8, "[Fruits.id]" )
         :AddMemoEx( "BandaDatos", "F_NAME",    30, 0, 50, 8, "[Fruits.name]" )
         :AddMemoEx( "BandaDatos", "F_FAMILY",  90, 0, 50, 8, "[Fruits.family]" )
         :AddMemoEx( "BandaDatos", "F_CAL",    150, 0, 40, 8, "[Fruits.nutritions.calories] cal" )
      
         IF :Prepare( .F. )
            :Save( cFile )
            :Show( "Sample 24 - Remote JSON API" )
            :SavePrepared( cFilePrep )
         ELSE
            ? :GetLastError()      
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample25: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample25()

   LOCAL cPg       := "Page1"
   LOCAL cJsonFile := hb_DirBase() + "reports\nwind.json"
   LOCAL cFile     := hb_DirBase() + "reports\XD_MasterDetail.frx"

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :SetUnit( FR_UNIT_MM )
         :AddPage( cPg )

         // Registramos el JSON. La DLL extraer? las tablas y relaciones.
         :AddJsonFile( "NWConn", cJsonFile )

         IF :Load( cFile )
            IF :Prepare( .F. )
               :Show( "Sample 25 - Master-Detail JSON (NWind)" )
               // :Save( cFile )
               // :SavePrepared( cFilePrep )
            ELSE
               ? "Error Prepare:", :GetLastError()
            ENDIF
         ELSE
            ? "Error Load:", :GetLastError()
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample26: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample26()

   LOCAL cPg           := "Page1"
   LOCAL cJsonMaster, cJsonDetail
   LOCAL cMasterBand, cDetailBand
   LOCAL cTitleBand, cPageHdr, cDataHdr, cDataFtr, cPgFtr
   LOCAL cFile         := hb_DirBase() + "reports\Sample26_Invoice.frx"
   LOCAL cFilePrepared := hb_DirBase() + "reports\Sample26_Invoice_Prepared.fpx"

   // 1. Datos de factura con campos fiscales espanoles
   /*
   cJsonMaster := '[{"InvoiceID": 1001, "Date": "2026-03-01",' + ;
                  '  "CompanyName": "Tech Solutions Inc.", "CompanyAddress": "123 Tech Lane, Innovation City",' + ;
                  '  "CustomerName": "Acme Corp", "CustomerAddress": "456 Industrial Blvd, Metropolis",' + ;
                  '  "BaseImponible": 3000.00, "PctIVA": 21, "ImpIVA": 630.00,' + ;
                  '  "PctRE": 5.2, "ImpRE": 156.00,' + ;
                  '  "PctRet": 15, "ImpRet": 450.00,' + ;
                  '  "TotalFactura": 3336.00},' + ;
                  ' {"InvoiceID": 1002, "Date": "2026-03-02",' + ;
                  '  "CompanyName": "Tech Solutions Inc.", "CompanyAddress": "123 Tech Lane, Innovation City",' + ;
                  '  "CustomerName": "Wayne Enterprises", "CustomerAddress": "789 Gotham Street, Gotham City",' + ;
                  '  "BaseImponible": 1000.00, "PctIVA": 21, "ImpIVA": 210.00,' + ;
                  '  "PctRE": 5.2, "ImpRE": 52.00,' + ;
                  '  "PctRet": 15, "ImpRet": 150.00,' + ;
                  '  "TotalFactura": 1112.00}]'

   cJsonDetail := '[{"InvoiceID": 1001, "ItemDescription": "Enterprise Software License", "Quantity": 1, "UnitPrice": 1500.00, "LineTotal": 1500.00},' + ;
                  ' {"InvoiceID": 1001, "ItemDescription": "Custom Development Hours", "Quantity": 10, "UnitPrice": 150.00, "LineTotal": 1500.00},' + ;
                  ' {"InvoiceID": 1002, "ItemDescription": "Hardware Upgrade Kit", "Quantity": 2, "UnitPrice": 250.00, "LineTotal": 500.00},' + ;
                  ' {"InvoiceID": 1002, "ItemDescription": "On-site Support (4 hrs)", "Quantity": 4, "UnitPrice": 125.00, "LineTotal": 500.00}]'
   */
   cJsonMaster := '[{"InvoiceID": 1001, "Date": "2026-03-01",' + ;
                  '  "CompanyName": "Tech Solutions Inc.", "CompanyAddress": "123 Tech Lane, Innovation City",' + ;
                  '  "CustomerName": "Acme Corp", "CustomerAddress": "456 Industrial Blvd, Metropolis",' + ;
                  '  "BaseImponible": 3000.00, "PctIVA": 21, "ImpIVA": 630.00,' + ;
                  '  "PctRE": 5.2, "ImpRE": 156.00,' + ;
                  '  "PctRet": 15, "ImpRet": 450.00,' + ;
                  '  "TotalFactura": 3336.00}]'

   cJsonDetail := '[{"InvoiceID": 1001, "ItemDescription": "Enterprise Software License", "Quantity": 1, "UnitPrice": 1500.00, "LineTotal": 1500.00},' + ;
                  ' {"InvoiceID": 1001, "ItemDescription": "Custom Development Hours", "Quantity": 10, "UnitPrice": 150.00, "LineTotal": 1500.00}]'
   
   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )

         // 2. Registrar JSONs Independientes
         :RegisterJSON( cJsonMaster, "InvoicesConn", "Invoices" )
         :RegisterJSON( cJsonDetail, "LinesConn", "Lines" )

         // 3. Crear relaci?n manualmente mediante bridge C#
         IF !:AddRelation( "InvLinesRel", "Invoices", "Lines", "InvoiceID", "InvoiceID" )
            ? "Error creando relacion:", :GetLastError()
         ENDIF

         // 4. Dise?o por codigo
         // -- Report Title --
         cTitleBand := :AddBand( "ReportTitle", cPg, "TitleBand", "" )
         :SetHeight( cTitleBand, 15 )
         :AddTextEx( cTitleBand, "TitleTxt", 0, 4, 210, 10, "INVOICE", 0, 0, "Arial", 20, 1, 1 )
         :SetProperty( "TitleTxt", "HorzAlign", "Center" )
         :SetProperty( "TitleTxt", "Font.Color", "clBlue" )

         // -- Page Header --
         cPageHdr := :AddBand( "PageHeader", cPg, "PageHdrBand", "" )
         :SetHeight( cPageHdr, 10 )
         :AddTextEx( cPageHdr, "PgHdrTxt", 0, 2, 210, 6, "INVOICE REPORT  (Sample 26 - Code & JSON)", 0, 0, "Arial", 9, 1, 1 )
         :SetProperty( "PgHdrTxt", "HorzAlign", "Center" )
         :AddTextEx( cPageHdr, "PageNumTxt", 180, 2, 20, 6, "Page [Page#]", 0, 0, "Arial", 8, 0, 2 )


         // -- Master Band: UNA por factura (Casi invisible, maneja bucle y salto p\xe1g) --
         cMasterBand := :AddBand( "Data", cPg, "MasterBand", "Invoices" )
         :SetHeight( cMasterBand, 0.1 ) 
         :SetProperty( cMasterBand, "StartNewPage", "true" )

         // -- Detail Band: Las l\xedneas (Dentro del Master) --
         cDetailBand := :AddBand( "Data", cMasterBand, "DetailBand", "Lines" )
         :SetHeight( cDetailBand, 8 )
         :SetBandRelation( cDetailBand, "InvLinesRel" )
         
         // Detalle
         :AddTextEx( cDetailBand, "ItmTxt",     10, 1, 100, 6, "[Lines.ItemDescription]" )
         :AddTextEx( cDetailBand, "QtyTxt",    115, 1,  20, 6, "[Lines.Quantity]" )
         :SetProperty( "QtyTxt",  "HorzAlign", "Right" )
         :AddTextEx( cDetailBand, "PrcTxt",    140, 1,  30, 6, "[Lines.UnitPrice]" )
         :SetProperty( "PrcTxt",  "HorzAlign", "Right" )
         :AddTextEx( cDetailBand, "LineTotTxt",170, 1,  25, 6, "[Lines.LineTotal]" )
         :SetProperty( "LineTotTxt", "HorzAlign", "Right" )

         //------------------------------------------------------------
         // CABECERA DEL DETALLE: AQUI PONEMOS LOS DATOS DE LA FACTURA
         // Al estar en el Header del Detalle, FR los apila VERTICALMENTE
         // antes de las l\xedneas, evitando superposiciones.
         //------------------------------------------------------------
         cDataHdr := :AddBand( "DataHeader", cDetailBand, "LinesHdrBand", "" )
         :SetHeight( cDataHdr, 48 ) // Espacio para factura + columnas

         // -- Datos Cabecera Factura (En el Header del Detail) --
         :AddTextEx( cDataHdr, "CompanyTxt",    10,  2, 90, 6, "[Invoices.CompanyName]" )
         :SetProperty( "CompanyTxt",  "Font.Style", "Bold" )
         :AddTextEx( cDataHdr, "CompanyAddrTxt", 10,  9, 90, 5, "[Invoices.CompanyAddress]" )

         :AddTextEx( cDataHdr, "InvNumLbl",  120,  2, 30, 5, "Invoice #:" )
         :SetProperty( "InvNumLbl",  "Font.Style", "Bold" )
         :AddTextEx( cDataHdr, "InvNumTxt",  155,  2, 40, 5, "[Invoices.InvoiceID]" )
         :AddTextEx( cDataHdr, "InvDateLbl", 120,  9, 30, 5, "Date:" )
         :SetProperty( "InvDateLbl", "Font.Style", "Bold" )
         :AddTextEx( cDataHdr, "InvDateTxt", 155,  9, 40, 5, "[Invoices.Date]" )

         :AddTextEx( cDataHdr, "BillToLbl",       10, 18, 30, 5, "BILL TO:" )
         :SetProperty( "BillToLbl", "Font.Style", "Bold" )
         :AddTextEx( cDataHdr, "CustomerTxt",     10, 24, 90, 5, "[Invoices.CustomerName]" )
         :SetProperty( "CustomerTxt", "Font.Style", "Bold" )
         :AddTextEx( cDataHdr, "CustomerAddrTxt", 10, 30, 90, 5, "[Invoices.CustomerAddress]" )

         // -- Columnas (Al final de la misma cabecera) --
         :AddLineEx( cDataHdr, "LineHdrTop", 10, 38, 190, 0, 0, 1 )
         :AddTextEx( cDataHdr, "HdrDesc",  10, 40, 100, 5, "Description" )
         :SetProperty( "HdrDesc", "Font.Style", "Bold" )
         :AddTextEx( cDataHdr, "HdrQty",  115, 40,  20, 5, "Qty" )
         :SetProperty( "HdrQty",  "Font.Style", "Bold" )
         :SetProperty( "HdrQty",  "HorzAlign",  "Right" )
         :AddTextEx( cDataHdr, "HdrUnit", 140, 40,  30, 5, "Unit Price" )
         :SetProperty( "HdrUnit", "Font.Style", "Bold" )
         :SetProperty( "HdrUnit", "HorzAlign",  "Right" )
         :AddTextEx( cDataHdr, "HdrTot",  170, 40,  25, 5, "Total" )
         :SetProperty( "HdrTot",  "Font.Style", "Bold" )
         :SetProperty( "HdrTot",  "HorzAlign",  "Right" )
         :AddLineEx( cDataHdr, "LineHdrBot", 10, 46, 190, 0, 0, 1 )

         // -- Totales (Footers del Detalle) --
         cDataFtr := :AddBand( "DataFooter", cDetailBand, "LinesFooterBand", "" )
         :SetHeight( cDataFtr, 42 )
         :AddLineEx( cDataFtr, "LineFtr",  10,  0, 190, 0, 0, 1 )
         :AddTextEx( cDataFtr, "BaseLbl",  120,  3,  40, 5, "Base Imponible:" )
         :SetProperty( "BaseLbl", "Font.Style", "Bold" )
         :AddTextEx( cDataFtr, "BaseTxt",  165,  3,  30, 5, "[Invoices.BaseImponible]" )
         :SetProperty( "BaseTxt", "HorzAlign", "Right" )
         :AddTextEx( cDataFtr, "IvaLbl",   120,  9,  40, 5, "IVA ([Invoices.PctIVA]%):" )
         :SetProperty( "IvaLbl", "Font.Style", "Bold" )
         :AddTextEx( cDataFtr, "IvaTxt",   165,  9,  30, 5, "[Invoices.ImpIVA]" )
         :SetProperty( "IvaTxt", "HorzAlign", "Right" )
         :AddTextEx( cDataFtr, "RELbl",    120, 15,  40, 5, "R.Equiv. ([Invoices.PctRE]%):" )
         :SetProperty( "RELbl", "Font.Style", "Bold" )
         :AddTextEx( cDataFtr, "RETxt",    165, 15,  30, 5, "[Invoices.ImpRE]" )
         :SetProperty( "RETxt", "HorzAlign", "Right" )
         :AddTextEx( cDataFtr, "RetLbl",   120, 21,  40, 5, "Retenci\xf3n ([Invoices.PctRet]%):" )
         :SetProperty( "RetLbl", "Font.Style", "Bold" )
         :AddTextEx( cDataFtr, "RetTxt",   165, 21,  30, 5, "[Invoices.ImpRet]" )
         :SetProperty( "RetTxt", "HorzAlign", "Right" )
         :AddLineEx( cDataFtr, "LineTot",   10, 28, 190, 0, 0, 1 )
         :AddTextEx( cDataFtr, "TotLbl",   120, 30,  40, 7, "TOTAL FACTURA:" )
         :SetProperty( "TotLbl", "Font.Style", "Bold" )
         :SetProperty( "TotLbl", "Font.Size",  "10" )
         :AddTextEx( cDataFtr, "TotTxt",   165, 30,  30, 7, "[Invoices.TotalFactura]" )
         :SetProperty( "TotTxt", "Font.Style", "Bold" )
         :SetProperty( "TotTxt", "Font.Size",  "10" )
         :SetProperty( "TotTxt", "HorzAlign",  "Right" )

         // 5. Preparar, guardar y mostrar
         IF :Prepare( .F. )
            :SavePrepared( cFilePrepared )
            :SaveDesign( cFile )
            :Show( "Sample 26 - Code Master-Detail Invoice" )
         ELSE
            ? "Error Prepare:", :GetLastError()
         ENDIF

      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample27: Ejemplo de uso de fichero XML como origen de datos
//----------------------------------------------------------------------------//

FUNCTION XD_Sample27()

   LOCAL cXmlFile := hb_DirBase() + "reports\nwind.xml"
   LOCAL lSw      := .T.
   LOCAL cFile         := hb_DirBase() + "reports\Sample27.frx"
   LOCAL cFilePrepared := hb_DirBase() + "reports\Sample27.fpx"

   IF !File( cXmlFile )
      // Intentamos ruta relativa si hb_DirBase no funciona como esperamos
      cXmlFile := "reports\nwind.xml"
      IF !File( cXmlFile )
         MsgInfo( "File not found: " + cXmlFile )
         RETURN NIL
      ENDIF
   ENDIF

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( "Page1" )
         :SetUnit( 0 )

         // Cargamos el XML de Northwind. 
         // El alias sera el nombre de la conexion en FR
         IF !:AddXmlFile( "Northwind", cXmlFile )
            MsgInfo( :GetLastError(), "Error cargando XML" )
            lSw   := .F.
         ENDIF

         IF lSw
            // --- TITULO ---
            :AddBand( "ReportTitle", "Page1", "T", "" )
            :SetHeight( "T", 15 )
            :AddTextEx( "T", "Title", 0, 0, 190, 10, "REPORTE DESDE XML (NORTHWIND)", 0, 0, "Arial", 16, 1 )
            :SetProperty( "Title", "HorzAlign", "Center" )
            :SetProperty( "Title", "Font.Color", "clNavy" )
            
            // Cabeceras (Usando la tabla 'Customers' del XML)
            :AddBand( "PageHeader", "Page1", "PH", "" )
            :SetHeight( "PH", 10 )
            :AddTextEx( "PH", "H1",   0, 2,  30, 5, "ID" )
            :AddTextEx( "PH", "H2",  35, 2,  80, 5, "COMPANY NAME" )
            :AddTextEx( "PH", "H3", 120, 2,  60, 5, "COUNTRY" )
            :SetProperty( "H1", "Font.Style", "Bold" )
            :SetProperty( "H2", "Font.Style", "Bold" )
            :SetProperty( "H3", "Font.Style", "Bold" )
            :AddLineEx( "PH", "L1", 0, 8, 190, 0, 0, 1 )
            
            // --- DATOS ---
            // IMPORTANTE: En el XML de Northwind, la tabla se llama 'Customers'
            :AddBand( "Data", "Page1", "D", "Customers" )
            :SetHeight( "D", 8 )
            
            :AddTextEx( "D", "C1",   0, 1,  30, 5, "[Customers.CustomerID]" )
            :AddTextEx( "D", "C2",  35, 1,  80, 5, "[Customers.CompanyName]" )
            :AddTextEx( "D", "C3", 120, 1,  60, 5, "[Customers.Country]" )
            
            IF :Prepare( .F. )
               :Show( "Sample 27 - XML File Data Source" )
               :SavePrepared( cFilePrepared )
               :Save( cFile )
            ELSE
                ? :GetLastError()
            ENDIF
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample28: Ejemplo de uso de string XML directo desde memoria
//----------------------------------------------------------------------------//

FUNCTION XD_Sample28()

   LOCAL cXmlData := ""
   LOCAL lSw      := .T.
   
   cXmlData += '<?xml version="1.0" encoding="UTF-8"?>' + hb_osNewLine()
   cXmlData += '<StockData>' + hb_osNewLine()
   cXmlData += '  <Item>' + hb_osNewLine()
   cXmlData += '     <Code>001</Code>' + hb_osNewLine()
   cXmlData += '     <Name>Laptop Pro</Name>' + hb_osNewLine()
   cXmlData += '     <Qty>10</Qty>' + hb_osNewLine()
   cXmlData += '  </Item>' + hb_osNewLine()
   cXmlData += '  <Item>' + hb_osNewLine()
   cXmlData += '     <Code>002</Code>' + hb_osNewLine()
   cXmlData += '     <Name>Wireless Mouse</Name>' + hb_osNewLine()
   cXmlData += '     <Qty>50</Qty>' + hb_osNewLine()
   cXmlData += '  </Item>' + hb_osNewLine()
   cXmlData += '  <Item>' + hb_osNewLine()
   cXmlData += '     <Code>003</Code>' + hb_osNewLine()
   cXmlData += '     <Name>Mechanical Keyboard</Name>' + hb_osNewLine()
   cXmlData += '     <Qty>25</Qty>' + hb_osNewLine()
   cXmlData += '  </Item>' + hb_osNewLine()
   cXmlData += '</StockData>'

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( "Page1" )
         :SetUnit( 0 )

         // Cargamos el XML desde String. 
         IF !:AddXmlData( "Inventory", cXmlData )
            MsgInfo( :GetLastError(), "Error cargando XML de Memoria" )
            lSw   := .F.
         ENDIF

         IF lSw
            // --- TITULO ---
            :AddBand( "ReportTitle", "Page1", "T", "" )
            :SetHeight( "T", 15 )
            :AddTextEx( "T", "Title", 0, 0, 190, 10, "INVENTARIO DESDE STRING XML", 0, 0, "Arial", 16, 1 )
            :SetProperty( "Title", "HorzAlign", "Center" )
            :SetProperty( "Title", "Font.Color", "clDarkRed" )
            
            // Cabeceras
            :AddBand( "PageHeader", "Page1", "PH", "" )
            :SetHeight( "PH", 10 )
            :AddTextEx( "PH", "H1",   0, 2,  30, 5, "CODE" )
            :AddTextEx( "PH", "H2",  35, 2,  80, 5, "ITEM DESCRIPTION" )
            :AddTextEx( "PH", "H3", 140, 2,  30, 5, "QTY" )
            :SetProperty( "H1", "Font.Style", "Bold" )
            :SetProperty( "H2", "Font.Style", "Bold" )
            :SetProperty( "H3", "Font.Style", "Bold" )
            :SetProperty( "H3", "HorzAlign",  "Right" )
            :AddLineEx( "PH", "L1", 0, 8, 190, 0, 0, 1 )
            
            // --- DATOS ---
            // El motor XML de .NET suele crear una tabla con el nombre del nodo repetido o 'Item'
            :AddBand( "Data", "Page1", "D", "Item" )
            :SetHeight( "D", 8 )
            
            :AddTextEx( "D", "C1",   0, 1,  30, 5, "[Item.Code]" )
            :AddTextEx( "D", "C2",  35, 1,  80, 5, "[Item.Name]" )
            :AddTextEx( "D", "C3", 140, 1,  30, 5, "[Item.Qty]" )
            :SetProperty( "C3", "HorzAlign", "Right" )
            
            IF :Prepare( .F. )
               :Show( "Sample 28 - XML String Data Source" )
            ENDIF
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample29() - Ejemplo de Filtrado de Facturas XML
//----------------------------------------------------------------------------//

FUNCTION XD_Sample29()

   LOCAL cPg           := 'Page1'
   LOCAL cTitleBand, cPageHdr, cMasterBand, cDetailBand, cDataHdr, cDataFtr
   LOCAL cXmlFile      := hb_DirBase() + 'reports\nwind.xml'
   LOCAL lRet

   IF !File( cXmlFile )
      cXmlFile := 'reports\nwind.xml'
      IF !File( cXmlFile )
         MsgInfo( 'File not found: ' + cXmlFile )
         RETURN NIL
      ENDIF
   ENDIF

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         
         :SetProperty( cPg, "LeftMargin", 10 )
         :SetProperty( cPg, "RightMargin", 10 )

         // 1. Cargar XML
         lRet := :AddXmlFile( 'Northwind', cXmlFile )

         IF lRet
            :AddRelation( 'OrderDetailsRel', 'Orders', 'Order_Details', 'OrderID', 'OrderID' )

            // 3. Totales (Subtotal)
            :AddTotal( 'OrderSubTotal', 'Convert.ToDouble(Order_Details.UnitPrice) * Convert.ToDouble(Order_Details.Quantity) * (1.0 - Convert.ToDouble(Order_Details.Discount))', 0, 'DetailsBand', 'TotalsFtr', 'OrdersBand' )

            // -- Report Title: CORPORATE HEADER --
            cTitleBand := :AddBand( 'ReportTitle', cPg, 'TitleBand', '' )
            :SetHeight( cTitleBand, 35 )
            
            // Usamos AddShape(x, y, w, h, parent, name, type, border, fillcolor)
            // nFillCol = 0x80 (Maroon en BGR/Harbour)

            // Ver :AddShapeEx( x, y, w, h, cParent, cName, nType, nBorder, nFillColor, ;
            //                  cText, nTextColor, cFont, nSize, lFullFill, nAlignH, nAlignV )

            :AddShape( 0, 0, 190, 25, cTitleBand, "LogoBox", 0, 128, 128 )
            
            :AddTextEx( cTitleBand, 'CompanyName', 10, 5, 120, 10, 'XDEVSYSTEMS NORTHWIND APP' )
            :SetProperty( 'CompanyName', 'Font.Size', 16 )
            :SetProperty( 'CompanyName', 'Font.Style', 'Bold' )
            :SetProperty( 'CompanyName', 'Font.Color', 'White' )
            
            :AddTextEx( cTitleBand, 'CompanyInfo', 10, 15, 100, 5, 'Filtered Order Services - Northwind Division' )
            :SetProperty( 'CompanyInfo', 'Font.Size', 10 )
            :SetProperty( 'CompanyInfo', 'Font.Color', 'White' )
            
            :AddTextEx( cTitleBand, 'DocType', 130, 5, 50, 10, 'FILTERED DOC' )
            :SetProperty( 'DocType', 'Font.Size', 12 )
            :SetProperty( 'DocType', 'Font.Style', 'Bold' )
            :SetProperty( 'DocType', 'Font.Color', 'White' )
            :SetProperty( 'DocType', 'HorzAlign', 'Right' )

            // -- Master Band: Orders (Filter applied) --
            cMasterBand := :AddBand( 'Data', cPg, 'OrdersBand', 'Orders' )
            :SetHeight( cMasterBand, 0.1 )
            :SetProperty( cMasterBand, 'StartNewPage', 'true' )

            // --- FILTRADO ADQUIRIDO POR EL USUARIO ---
            :SetProperty( cMasterBand, 'Filter', 'Orders.OrderID == 10300' )

            // -- Detail Band: Order_Details --
            cDetailBand := :AddBand( 'Data', cMasterBand, 'DetailsBand', 'Order_Details' )
            :SetHeight( cDetailBand, 8 )
            :SetBandRelation( cDetailBand, 'OrderDetailsRel' )

            :AddTextEx( cDetailBand, 'ProdID',   10, 1,  20, 6, '[Order_Details.ProductID]' )
            :AddTextEx( cDetailBand, 'UnitPrice', 35, 1,  30, 6, '[Order_Details.UnitPrice]' )
            :AddTextEx( cDetailBand, 'Qty',       70, 1,  20, 6, '[Order_Details.Quantity]' )
            :AddTextEx( cDetailBand, 'Disc',      95, 1,  20, 6, '[Order_Details.Discount]' )
            :AddTextEx( cDetailBand, 'LineTot', 130, 1, 40, 6, '[Convert.ToDouble(Order_Details.UnitPrice) * Convert.ToDouble(Order_Details.Quantity) * (1.0 - Convert.ToDouble(Order_Details.Discount))]' )

            :SetProperty( 'UnitPrice', 'HorzAlign', 'Right' )
            :SetProperty( 'Qty',       'HorzAlign', 'Right' )
            :SetProperty( 'Disc',      'HorzAlign', 'Right' )
            :SetProperty( 'LineTot',   'HorzAlign', 'Right' )
            :SetProperty( 'LineTot',   'DisplayFormat.Format', 'N2' )
            :SetProperty( 'LineTot',   'Font.Style', 'Bold' )

            // -- Data Header: CLIENT INFO & TABLE HEADERS --
            cDataHdr := :AddBand( 'DataHeader', cDetailBand, 'InfoHdr', '' )
            :SetHeight( cDataHdr, 48 )

            :AddShape( 10, 5, 80, 25, cDataHdr, "ClientFrame", 0, 8421504, 16777215 )
            :AddTextEx( cDataHdr, 'LblClient',   12, 7,  40, 5, 'CUSTOMER:', 0, 0, 'Arial', 8, 1 )
            :AddTextEx( cDataHdr, 'CustVal',     12, 12, 70, 6, '[Orders.CustomerID]', 0, 0, 'Arial', 10, 1 )
            
            :AddTextEx( cDataHdr, 'InvLbl',     120, 7, 30, 5, 'ORDER #:', 0, 0, 'Arial', 8, 1 )
            :AddTextEx( cDataHdr, 'InvVal',     150, 7, 30, 5, '[Orders.OrderID]', 0, 0, 'Arial', 9, 1 )
            
            :AddTextEx( cDataHdr, 'DateLbl',    120, 14, 30, 5, 'DATE:', 0, 0, 'Arial', 8, 1 )
            :AddTextEx( cDataHdr, 'DateVal',    150, 14, 30, 5, '[Orders.OrderDate]', 0, 0, 'Arial', 9, 0 )
            
            :AddLineEx( cDataHdr, 'SepTop', 10, 35, 175, 0, 0, 0.5 )

            // Table Headers (Professional Grey Syle)
            
            :AddShape( 10, 38, 180, 8, cDataHdr, "HdrFill", 0, 6908265, 6908265 )
            :AddTextEx( cDataHdr, 'H_Prod',  12, 39,  20, 6, 'PRODUCT', 0, 0, 'Arial', 9, 1 )
            :AddTextEx( cDataHdr, 'H_Price', 35, 39,  30, 6, 'PRICE', 0, 0, 'Arial', 9, 1 )
            :AddTextEx( cDataHdr, 'H_Qty',   70, 39,  20, 6, 'QTY', 0, 0, 'Arial', 9, 1 )
            :AddTextEx( cDataHdr, 'H_Disc',  95, 39,  20, 6, 'DISC.', 0, 0, 'Arial', 9, 1 )
            :AddTextEx( cDataHdr, 'H_Tot',  130, 39,  38, 6, 'TOTAL', 0, 0, 'Arial', 9, 1 )
            
            :SetProperty( 'H_Prod', 'Font.Color', 'clWhite' )
            :SetProperty( 'H_Price','Font.Color', 'clWhite' )
            :SetProperty( 'H_Qty',  'Font.Color', 'clWhite' )
            :SetProperty( 'H_Disc', 'Font.Color', 'clWhite' )
            :SetProperty( 'H_Tot',  'Font.Color', 'clWhite' )
            :SetProperty( 'H_Price', 'HorzAlign', 'Right' )
            :SetProperty( 'H_Qty',   'HorzAlign', 'Right' )
            :SetProperty( 'H_Disc',  'HorzAlign', 'Right' )
            :SetProperty( 'H_Tot',   'HorzAlign', 'Right' )

            // -- Data Footer: TOTALS SUMMARY --
            cDataFtr := :AddBand( 'DataFooter', cDetailBand, 'TotalsFtr', '' )
            :SetHeight( cDataFtr, 35 )
            
            :AddLineEx( cDataFtr, 'LineFtr', 10, 2, 180, 0, 0, 1 )
            
            :AddShape( 110, 5, 80, 25, cDataFtr, "SumBox", 0, 8421504, 16777215 )
            
            :AddTextEx( cDataFtr, 'SubLbl', 115, 8, 35, 5, 'SUBTOTAL:' )
            :AddTextEx( cDataFtr, 'SubVal', 150, 8, 35, 5, '[OrderSubTotal]' )
            
            :AddLineEx( cDataFtr, 'SepFinal', 115, 17, 70, 0, 0, 0.5 )
            :AddTextEx( cDataFtr, 'TotLbl', 115, 20, 35, 6, 'TOTAL ORDER:' )
            :SetProperty( 'TotLbl', 'Font.Style', 'Bold' )
            :AddTextEx( cDataFtr, 'TotVal', 150, 20, 35, 6, '[OrderSubTotal]' )
            :SetProperty( 'TotVal', 'Font.Style', 'Bold' )
            :SetProperty( 'TotVal', 'Font.Size', 11 )
            
            :SetProperty( 'SubVal', 'HorzAlign', 'Right' )
            :SetProperty( 'SubVal', 'DisplayFormat.Format', 'N2' )
            :SetProperty( 'TotVal', 'HorzAlign', 'Right' )
            :SetProperty( 'TotVal', 'DisplayFormat.Format', 'N2' )

            IF :Prepare( .F. )
               :Show( 'Sample 29 - XML Filtered Premium' )
            ELSE
               ? "Prepare Error:", :GetLastError()
            ENDIF
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample30: Load from string
//----------------------------------------------------------------------------//

FUNCTION XD_Sample30()

   LOCAL cPg       := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample02.frx"
   LOCAL cFileHTML := hb_DirBase() + "reports\XD_Sample02.html"
   LOCAL cFrx

   IF .NOT. File( cFile )
      Alert( "Error: No se encuentra el archivo " + cFile + ". Ejecuta primero el Ejemplo 02." )
      RETURN nil
   ENDIF
   
   // Simulamos la carga del fichero, como si viniera de una bbdd por ejemplo
   cFrx  := hb_MemoRead( cFile )

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :LoadFromString( cFrx )
      
         IF :Prepare( .F. )
            :Show()
            // :ExportHTML( cFileHTML )
         ELSE
            Alert( :GetLastError() )
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample31: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample31()

   LOCAL cCodigo   := ""
   LOCAL cPg       := "Page1"
   LOCAL cFile     := ""

   cFile   := cGetFile( "Reporte a Cargar (*.frx) |*.frx|", "Seleccione Fichero FRX a Cargar", , hb_DirBase() + "reports\" )
   ? cFile, hb_FNameExt( cFile )
   IF .NOT. File( cFile )
      Alert( "Error: No se encuentra el archivo " + cFile + ". Seleccionado por defecto xd_masterdetail.frx" )
      cFile     := hb_DirBase() + "reports\XD_MasterDetail.frx"
   ENDIF

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :SetUnit( FR_UNIT_MM )

         IF :Load( cFile )
            cCodigo := :FrxToCode()
         ELSE
            ? "Error Load:", :GetLastError()
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY
   
   ? cCodigo

   // hb_MemoWrit( "codigo_salida.txt", cCodigo )

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample32: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample32()

   LOCAL cServer := "127.0.0.1"
   LOCAL cDb     := "Dummy"
   LOCAL cUser   := "root"
   LOCAL cPass   := ""
   LOCAL cPort   := "3306"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample32.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample32.fpx"
   
   InitFastReport()

   TRY
      WITH OBJECT oFR

         :SetDataIntegration( .T. )

         // 1. Establecer conexion global
         IF :SetMySQLConn( cServer, cDb, cUser, cPass, cPort )
            
            // :NewReport()
            :AddPage( "Page1" )
            :SetUnit( FR_UNIT_MM )

            // 2. Añadir banda de datos vinculada a "Customer"
            :AddBand( "Data", "Page1", "Data1", "Customer" )
            :SetHeight( "Data1", 10 )
            
            // 3. Añadir la consulta MySQL usando la conexion global
            IF :AddMySQLQuery( "Customer", "SELECT * FROM Customer", "Data1" )
               
               // 4. Añadir campos (usamos AddMemoEx para mejor control)
               // Estructura: id, first, last, street, city, state, married
               :AddMemoEx( "Data1", "mId",     5, 0, 15, 8, "[Customer.id]",    CLR_BLACK, -1, "Arial", 10, 0, 1 )
               :AddMemoEx( "Data1", "mFirst", 22, 0, 40, 8, "[Customer.first]", CLR_BLACK, -1, "Arial", 10, 0, 1 )
               :AddMemoEx( "Data1", "mLast",  64, 0, 40, 8, "[Customer.last]",  CLR_BLACK, -1, "Arial", 10, 0, 1 )
               :AddMemoEx( "Data1", "mCity", 106, 0, 40, 8, "[Customer.city]",  CLR_BLACK, -1, "Arial", 10, 0, 1 )
               :AddMemoEx( "Data1", "mState", 148, 0, 15, 8, "[Customer.state]", CLR_BLACK, -1, "Arial", 10, 1, 1 )
               
               // 1. TÍTULO DEL REPORTE (Solo en la primera página)
               :AddBand( "REPORTTITLE", "Page1", "Title", "" )
               :SetHeight( "Title", 15 )
               :AddMemoEx( "Title", "lblTit", 0, 0, 200, 10, "INFORME COMPLETO DE CLIENTES", CLR_HBLUE, -1, "Arial", 16, 1, 1 )

               // 2. CABECERA DE PÁGINA (Se repite en todas las páginas)
               :AddBand( "PAGEHEADER", "Page1", "Header", "" )
               :SetHeight( "Header", 12 )
            
               // Etiquetas de columnas con fondo para que resalten en cada página
               :AddMemoEx( "Header", "hId",      5, 0, 15, 8, "ID",    CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
               :AddMemoEx( "Header", "hFirst",  22, 0, 40, 8, "FIRST", CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
               :AddMemoEx( "Header", "hLast",   64, 0, 40, 8, "LAST",  CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
               :AddMemoEx( "Header", "hCity",  106, 0, 40, 8, "CITY",  CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
               :AddMemoEx( "Header", "hState", 148, 0, 15, 8, "ST",    CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
            
               :AddLineEx( "Header", "ln1", 0, 10, 200, 0, CLR_BLACK, 0.5 )

               IF :Prepare()
                  :Show()
                  // ? :GetInternalState()
                  :Save( cFile )
                  :SavePrepared( cFilePrep )
               ELSE
                  ? :GetLastError()
               ENDIF
            ELSE
               ? "Error al añadir la consulta MySQL:", :GetLastError()
            ENDIF
            
         ELSE
            ? "Error de conexion MySQL:", :GetLastError()
         ENDIF
         
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample33: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample33()

   LOCAL cServer := "127.0.0.1"
   LOCAL cDb     := "Dummy"
   LOCAL cUser   := "root"
   LOCAL cPass   := ""
   LOCAL cPort   := "3306"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample33.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample33.fpx"
   
   InitFastReport()

   TRY
      WITH OBJECT oFR

         :SetDataIntegration( .T. )

         // 1. Establecer conexion global
         IF :SetMySQLConn( cServer, cDb, cUser, cPass, cPort )
            
            // :NewReport()
            :AddPage( "Page1" )
            :SetUnit( FR_UNIT_MM )

            // 2. TÍTULO DEL REPORTE
            :AddBand( "REPORTTITLE", "Page1", "Title", "" )
            :SetHeight( "Title", 15 )
            :AddMemoEx( "Title", "lblTit", 0, 0, 200, 10, "LISTADO DE CLIENTES POR ESTADO", CLR_HBLUE, -1, "Arial", 16, 1, 1 )

            // 3. CABECERA DE PÁGINA (Repite cabeceras de columnas)
            :AddBand( "PAGEHEADER", "Page1", "Header", "" )
            :SetHeight( "Header", 10 )
            :AddMemoEx( "Header", "hId",     5, 0, 15, 8, "ID",    CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
            :AddMemoEx( "Header", "hFirst", 22, 0, 40, 8, "FIRST", CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
            :AddMemoEx( "Header", "hLast",  64, 0, 40, 8, "LAST",  CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
            :AddMemoEx( "Header", "hCity", 106, 0, 40, 8, "CITY",  CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
            :AddLineEx( "Header", "ln1",    0, 9, 200, 0, CLR_BLACK, 0.5 )

            // 4. BANDA DE DATOS
            :AddBand( "Data", "Page1", "Data1", "Customer" )
            :SetHeight( "Data1", 8 )

            // 5. AÑADIR GRUPO POR ESTADO
            // IMPORTANTE: El SQL debe estar ordenado por el mismo campo (ORDER BY state)
            :AddGroup( "Page1", "GroupState", "[Customer.state]" )
            :SetHeight( "GroupState", 12 )
            
            // Texto en la cabecera del grupo (resaltado)
            :AddMemoEx( "GroupState", "lblGroup", 5, 2, 100, 8, "ESTADO: [Customer.state]", CLR_HRED1, -1, "Arial", 12, 0, 1 )
            :AddLineEx( "GroupState", "lnGrp", 0, 11, 200, 0, CLR_HRED1, 0.5 )

            // 6. PIE DE GRUPO (Separador visual)
            :AddBand( "GROUPFOOTER", "Page1", "FooterState", "" )
            :SetHeight( "FooterState", 5 )
            :AddLineEx( "FooterState", "lnSep", 0, 2, 200, 0, CLR_GRAY, 0.2 )

            // 7. CONSULTA MYSQL ORDENADA
            IF :AddMySQLQuery( "Customer", "SELECT * FROM Customer ORDER BY state, last, first", "Data1" )
               
               // Detalle del cliente
               :AddMemoEx( "Data1", "mId",     5, 0, 15, 8, "[Customer.id]",    CLR_BLACK, -1, "Arial", 10, 0, 1 )
               :AddMemoEx( "Data1", "mFirst", 22, 0, 40, 8, "[Customer.first]", CLR_BLACK, -1, "Arial", 10, 0, 1 )
               :AddMemoEx( "Data1", "mLast",  64, 0, 40, 8, "[Customer.last]",  CLR_BLACK, -1, "Arial", 10, 0, 1 )
               :AddMemoEx( "Data1", "mCity", 106, 0, 40, 8, "[Customer.city]",  CLR_BLACK, -1, "Arial", 10, 0, 1 )

               IF :Prepare()
                  :Show()
                  // ? :GetInternalState()
                  :Save( cFile )
                  :SavePrepared( cFilePrep )
               ELSE
                  ? :GetLastError()
               ENDIF
            ELSE
               ? "Error MySQL:", :GetLastError()
            ENDIF
         ELSE
            ? "Error de conexion MySQL:", :GetLastError()
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample34: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample34()

   LOCAL cServer := "127.0.0.1"
   LOCAL cDb     := "Dummy"
   LOCAL cUser   := "root"
   LOCAL cPass   := ""
   LOCAL cPort   := "3306"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample34.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample34.fpx"
   
   InitFastReport()

   TRY
      WITH OBJECT oFR

         :SetDataIntegration( .T. )

         IF :SetMySQLConn( cServer, cDb, cUser, cPass, cPort )
            
            // :NewReport()
            :AddPage( "Page1" )
            :SetUnit( FR_UNIT_MM )
            
            // 1. TÍTULO DEL REPORTE
            :AddBand( "REPORTTITLE", "Page1", "Title", "" )
            :SetHeight( "Title", 15 )
            :AddMemoEx( "Title", "lblTit", 0, 0, 200, 10, "REPORTE CON TOTALES Y SALTOS DE PAGINA", CLR_HBLUE1, -1, "Arial", 16, 1, 1 )

            // 2. CABECERA DE PÁGINA
            :AddBand( "PAGEHEADER", "Page1", "Header", "" )
            :SetHeight( "Header", 10 )
            :AddMemoEx( "Header", "hId",     5, 0, 15, 8, "ID",    CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
            :AddMemoEx( "Header", "hFirst", 22, 0, 40, 8, "FIRST", CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
            :AddMemoEx( "Header", "hLast",  64, 0, 40, 8, "LAST",  CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
            :AddMemoEx( "Header", "hCity", 106, 0, 40, 8, "CITY",  CLR_BLACK, CLR_SILVER, "Arial", 10, 1, 1 )
            :AddLineEx( "Header", "ln1",    0, 9, 200, 0, CLR_BLACK, 0.5 )

            // 3. BANDA DE DATOS
            :AddBand( "Data", "Page1", "Data1", "Customer" )
            :SetHeight( "Data1", 8 )

            // 4. GRUPO POR ESTADO CON SALTO DE PÁGINA
            :AddGroup( "Page1", "GroupState", "[Customer.state]" )
            :SetHeight( "GroupState", 12 )
            // Activar Salto de Página en cada cambio de grupo
            :SetGroupCondition( "[Customer.state]", .T., "GroupState" )
            
            :AddMemoEx( "GroupState", "lblGroup", 5, 2, 100, 8, "ESTADO: [Customer.state]", CLR_HRED1, -1, "Arial", 12, 0, 1 )
            :AddLineEx( "GroupState", "lnGrp", 0, 11, 200, 0, CLR_HRED1, 0.5 )

            // 5. PIE DE GRUPO CON TOTAL (CONTEO)
            :AddBand( "GROUPFOOTER", "Page1", "FooterState", "" )
            :SetHeight( "FooterState", 10 )
            :AddLineEx( "FooterState", "luf", 0, 1, 200, 0, CLR_GRAY1, 0.2 )
            // Añadimos el Total: Nombre, Expresión, Tipo (4=Count), Banda Eval, Banda Print, Banda Reset
            :AddTotal( "cntGroup", "[Customer.id]", 4, "Data1", "FooterState", "GroupState" )
            :AddMemoEx( "FooterState", "lblSumGrp", 100, 2, 100, 6, "Registros en este grupo: [cntGroup]", CLR_BLACK, -1, "Arial", 10, 2, 1 )

            // 6. RESUMEN FINAL (REPORTSUMMARY) PARA EL TOTAL GLOBAL
            :AddBand( "REPORTSUMMARY", "Page1", "Summary1", "" )
            :SetHeight( "Summary1", 15 )
            :AddLineEx( "Summary1", "ls1", 0, 2, 200, 0, CLR_BLACK, 1 )
            :AddTotal( "cntTotal", "[Customer.id]", 4, "Data1", "Summary1", "" ) // Sin reset para total global
            :AddMemoEx( "Summary1", "lblTotal", 100, 5, 100, 8, "TOTAL REGISTROS REPORTE: [cntTotal]", CLR_BLACK, CLR_SILVER, "Arial", 11, 2, 1 )

            // 7. CONSULTA MYSQL
            IF :AddMySQLQuery( "Customer", "SELECT * FROM Customer ORDER BY state, last, first", "Data1" )
               
               :AddMemoEx( "Data1", "mId",     5, 0, 15, 8, "[Customer.id]",    CLR_BLACK, -1, "Arial", 10, 0, 1 )
               :AddMemoEx( "Data1", "mFirst", 22, 0, 40, 8, "[Customer.first]", CLR_BLACK, -1, "Arial", 10, 0, 1 )
               :AddMemoEx( "Data1", "mLast",  64, 0, 40, 8, "[Customer.last]",  CLR_BLACK, -1, "Arial", 10, 0, 1 )
               :AddMemoEx( "Data1", "mCity", 106, 0, 40, 8, "[Customer.city]",  CLR_BLACK, -1, "Arial", 10, 0, 1 )

               IF :Prepare()
                  :Show()
                  // ? :GetInternalState()
                  :Save( cFile )
                  :SavePrepared( cFilePrep )
               ENDIF
            ELSE
               ? "Error MySQL:", :GetLastError()
            ENDIF
         ELSE
            ? "Error de conexion MySQL:", :GetLastError()
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL


//----------------------------------------------------------------------------//
// XD_Sample35: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample35()

   LOCAL cServer := "127.0.0.1"
   LOCAL cDb     := "Dummy"
   LOCAL cUser   := "root"
   LOCAL cPass   := ""
   LOCAL cPort   := "3306"
   LOCAL aTables, cMsg
   
   InitFastReport()

   TRY
      WITH OBJECT oFR

         :SetDataIntegration( .T. )

         IF :SetMySQLConn( cServer, cDb, cUser, cPass, cPort )
            
            aTables := :GetMySQLTables()
            
            IF !Empty( aTables )
               cMsg := "Tablas disponibles en la base de datos '" + cDb + "':" + hb_Eol() + hb_Eol()
               AEval( aTables, { |c| cMsg += "- " + c + hb_Eol() } )
               MsgInfo( cMsg, "MySQL Discovery" )
            ELSE
               MsgInfo( "No se han encontrado tablas o error: " + :GetLastError(), "Aviso" )
            ENDIF

         ELSE
            MsgStop( "Error de conexion MySQL: " + :GetLastError(), "Error" )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample36: Tablas MySql en una BBDD
//----------------------------------------------------------------------------//

FUNCTION XD_Sample36()

   LOCAL cServer := "127.0.0.1"
   LOCAL cDb     := "Dummy"
   LOCAL cUser   := "root"
   LOCAL cPass   := ""
   LOCAL cPort   := "3306"
   LOCAL aTables, aHashes := {}, cName
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample36.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample36.fpx"
   
   InitFastReport()

   TRY
      WITH OBJECT oFR
         
         IF :SetMySQLConn( cServer, cDb, cUser, cPass, cPort )
            
            // 1. Obtener el array de tablas (strings)
            aTables := :GetMySQLTables()
            
            IF !Empty( aTables )
               
               // 1. NewReport y setup inicial SIEMPRE antes de registrar nada
               // :NewReport()
               :AddPage( "Page1" )
               :SetUnit( FR_UNIT_MM )

               // 2. Transformar a Array de Hashes
               aHashes := {}
               FOR EACH cName IN aTables
                  AAdd( aHashes, { "TABLE_NAME" => cName } )
               NEXT

               // 3. Registrar los datos en el reporte actual
               :RegisterData( "Discovery", aHashes )

               // 4. Diseñar Reporte
               :AddBand( "REPORTTITLE", "Page1", "Title" )
               :SetHeight( "Title", 15 )
               :AddMemoEx( "Title", "lblTit", 0, 0, 190, 10, "LISTADO DE TABLAS DE BBDD (MYSQL): < " + cDb + " >", CLR_HBLUE1, -1, "Arial", 16, 1, 1 )

               :AddBand( "COLUMNHEADER", "Page1", "Header" )
               :SetHeight( "Header", 8 )
               :AddMemoEx( "Header", "h1", 5, 0, 100, 8, "NOMBRE DE LA TABLA", CLR_BLACK, CLR_SILVER, "Arial", 11, 0, 1 )

               :AddBand( "DATA", "Page1", "Data1", "Discovery" )
               :SetHeight( "Data1", 7 )
               :AddMemoEx( "Data1", "m1", 5, 1, 100, 6, "[Discovery.TABLE_NAME]", CLR_BLACK, -1, "Arial", 11, 0, 1 )

               IF :Prepare()
                  :Show()
                  // ? :GetInternalState()
                  :Save( cFile )
                  :SavePrepared( cFilePrep )
               ELSE
                  ? :GetLastError()
               ENDIF

            ELSE
               MsgInfo( "No se han encontrado tablas para reportar." )
            ENDIF

         ELSE
            MsgStop( "Error de conexion MySQL: " + :GetLastError() )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL


//----------------------------------------------------------------------------//
// XD_Sample37: Visualizar el contenido XML de un fichero .FRX como un reporte
//----------------------------------------------------------------------------//

FUNCTION XD_Sample37( cFileFrx )

   LOCAL cPath    := hb_DirBase() + "reports\"
   LOCAL cFullFile := cPath + hb_defaultValue( cFileFrx, "box.frx" )
   LOCAL cContent, aLines, aHashes := {}
   LOCAL nLine    := 0
   LOCAL cPg      := "Page1"
   LOCAL cLine

   IF !File( cFullFile )
      MsgInfo( "File not Found: " + cFullFile )
      RETURN NIL
   ENDIF

   // 1. Leer contenido y convertir a array de líneas
   cContent := MemoRead( cFullFile )

   // Filtro UTF-8 BOM (EF BB BF)
   IF Left( cContent, 3 ) == hb_UTF8ToStr( hb_Decode( "EFBBBF", "HEX" ) )
      cContent := SubStr( cContent, 4 )
   ENDIF

   aLines   := hb_ATokens( cContent, hb_osNewLine() )

   FOR EACH cLine IN aLines
      nLine++
      AAdd( aHashes, { "LINE" => nLine, "TEXT" => cLine } )
   NEXT

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( "Page1" )
         :SetUnit( FR_UNIT_MM )

         // 2. Registrar los datos como un Array de Hashes
         :RegisterData( "SourceCode", aHashes )

         // 3. Diseño del Reporte Técnico
         :AddBand( "REPORTTITLE", cPg, "Title" )
         :SetHeight( "Title", 15 )
         :AddMemoEx( "Title", "lblTitle", 0, 0, 190, 10, "SOURCE CODE VIEWER: " + Upper( cFileFrx ), CLR_HBLUE1, -1, "Arial", 14, 1, 1 )

         :AddBand( "COLUMNHEADER", cPg, "Header" )
         :SetHeight( "Header", 6 )
         // :AddMemoEx( band, name, x, y, w, h, text, color, bgcolor, font, size, bold, align )
         :AddMemoEx( "Header", "h1",  0, 0,  15, 6, "LINE", CLR_BLACK, CLR_SILVER, "Arial", 9, 1, 1 )
         :AddMemoEx( "Header", "h2", 15, 0, 175, 6, "XML CONTENT", CLR_BLACK, CLR_SILVER, "Arial", 9, 1, 0 )

         :AddBand( "DATA", cPg, "Data1", "SourceCode" )
         :SetHeight( "Data1", 5 )
         
         // Número de línea (Estilo editor)
         :AddMemoEx( "Data1", "mLine", 0, 0, 12, 5, "[SourceCode.LINE]", CLR_HGRAY1, CLR_HGRAY2, "Courier New", 8, 0, 1 )
         
         // Código XML (Fuente Fixed-width)
         :AddMemoEx( "Data1", "mText", 15, 0, 175, 5, "[SourceCode.TEXT]", CLR_BLACK, -1, "Courier New", 8, 0, 0 )
         // Permitimos que el texto crezca si la línea es muy larga (aunque se cortará por el ancho)
         :SetProperty( "mText", "CanGrow", .T. )
         :SetProperty( "Data1", "CanGrow", .T. )

         IF :Prepare()
            :Show( "Visualizador de Código Fuente: " + cFileFrx )
         ENDIF

      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample38: Generación de base de datos SQLite desde XML
//----------------------------------------------------------------------------//

FUNCTION XD_Sample38()

   LOCAL cXml := hb_dirBase() + "reports\nwind.xml"
   LOCAL cDb  := hb_dirBase() + "reports\nwind.db"
   LOCAL lSw  := .T.

   // InitFastReport()

   TRY
      oFR := XDCreateFastReport()
      WITH OBJECT oFR
         IF File( cDb )
            lSw  := MsgYesNo( "El fichero " + cDb + " ya existe." + hb_OsNewLine() + "¿Desea sobreescribirlo?", "Confirmar" )
         ENDIF
         IF lSw
            IF :CreateSQLiteFromXML( cXml, cDb )
               MsgInfo( "Base de datos SQLite creada con exito en: " + cDb, "SQLite Integration" )
            ELSE
               MsgStop( "Error al crear la base de datos: " + :GetLastError(), "Error" )
            ENDIF
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample39:  Reporte usando SQLite
//----------------------------------------------------------------------------//

FUNCTION XD_Sample39()

   LOCAL cDb  := hb_dirBase() + "reports\nwind.db"
   LOCAL cSql := "SELECT * FROM Products WHERE UnitPrice > 20 ORDER BY ProductName"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample39.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample39.fpx"

   IF !File( cDb )
      MsgStop( "No se encuentra la base de datos: " + cDb + hb_OsNewLine() + "Por favor, ejecute primero el ejemplo 38.", "Error" )
      RETURN NIL
   ENDIF

   // InitFastReport()

   TRY
      oFR := XDCreateFastReport()
      WITH OBJECT oFR
         :Clear()
         :NewReport()
         :SetUnit( FR_UNIT_MM )  // Aseguramos milimetros
         
         // Agregamos la tabla desde SQLite
         :AddSQLiteTable( "Products", cDb, cSql )
         
         // Diseño rápido del reporte
         :AddBand( "REPORTTITLE", , "titulo" )
         :SetHeight( "titulo", 20 )
         :AddMemo( "titulo", "mTit", "PRODUCT LIST (SQLITE - XML ORIGIN)" )
         :SetProperty( "mTit", "Font.Size", 16 )
         :SetProperty( "mTit", "Font.Bold", .T. )
         :SetProperty( "mTit", "Width", 190 )
         :SetProperty( "mTit", "Height", 10 )
         :SetProperty( "mTit", "HAlign", "haCenter" )

         :AddBand( "PAGEHEADER", , "Cabecera", , , .T. )
         :SetHeight( "Cabecera", 10 )
         :AddShape( 0, 0, 190, 8, "Cabecera", "FondoCab", 0, CLR_BLACK, CLR_HEADER_BACK ) // 0 = Rectangle
         
         :AddMemoEx( "Cabecera", "hId", 2, 1, 20, 6, "ID", CLR_BLACK, -1, "Arial", 10, 0, 1 )
         :SetProperty( "hId", "Font.Bold", .T. )
         :AddMemoEx( "Cabecera", "hName", 25, 1, 100, 6, "PRODUCT NAME", CLR_BLACK, -1, "Arial", 10, 0, 1 )
         :SetProperty( "hName", "Font.Bold", .T. )
         :AddMemoEx( "Cabecera", "hPrice", 130, 1, 30, 6, "UNIT PRICE", CLR_BLACK, -1, "Arial", 10, 2, 1 )
         :SetProperty( "hPrice", "Font.Bold", .T. )

         :AddBand( "DATA", , "Data1", "Products" )
         :SetHeight( "Data1", 8 )
         :AddMemoEx( "Data1", "mId", 2, 0, 20, 8, "[Products.ProductID]", CLR_BLACK, -1, "Arial", 10, 0, 1 )
         :AddMemoEx( "Data1", "mName", 25, 0, 100, 8, "[Products.ProductName]", CLR_BLUE, -1, "Arial", 10, 0, 1 )
         :AddMemoEx( "Data1", "mPrice", 130, 0, 30, 8, "[Products.UnitPrice]", CLR_RED, -1, "Arial", 10, 2, 1 )
         :SetFormat( "mPrice", "c2" )

         IF :Prepare()
            :Show( "Reporte SQLite - NWind" )
            // ? :GetInternalState()
            :Save( cFile )
            :SavePrepared( cFilePrep )
            MsgInfo( "Ultima consulta ejecutada:" + hb_OsNewLine() + :GetLastSQL(), "Debug SQL" )
            MsgInfo( "Previsualizacion de datos (JSON):" + hb_OsNewLine() + hb_UTF8ToStr( :GetLastDataPreview() ), "Data Preview" )
         ENDIF

      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample40: Generación de base de datos SQLite desde JSON
//----------------------------------------------------------------------------//

FUNCTION XD_Sample40()

   LOCAL cJson := hb_dirBase() + "reports\nwind.json"
   LOCAL cDb   := hb_dirBase() + "reports\nwind_json.db"
   LOCAL lSw  := .T.

   IF !File( cJson )
      MsgStop( "No se encuentra el fichero JSON: " + cJson, "Error" )
      RETURN NIL
   ENDIF

   // InitFastReport()

   TRY
      oFR := XDCreateFastReport()
      WITH OBJECT oFR
         IF File( cDb )
            lSw  := MsgYesNo( "El fichero " + cDb + " ya existe." + hb_OsNewLine() + "¿Desea sobreescribirlo?", "Confirmar" )
         ENDIF

         IF lSw
            IF :CreateSQLiteFromJSON( cJson, cDb )
               MsgInfo( "Base de datos SQLite (desde JSON) creada con exito en: " + cDb, "SQLite Integration" )
            ELSE
               MsgStop( "Error al crear la base de datos desde JSON: " + :GetLastError(), "Error" )
            ENDIF
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample41: Reporte usando SQLite (generado desde JSON)
//----------------------------------------------------------------------------//

FUNCTION XD_Sample41()

   LOCAL cDb  := hb_dirBase() + "reports\nwind_json.db"
   LOCAL cSql := "SELECT CompanyName, ContactName, City, Country FROM Customers ORDER BY CompanyName"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample41.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample41.fpx"

   IF !File( cDb )
      MsgStop( "No se encuentra la base de datos: " + cDb + hb_OsNewLine() + "Por favor, ejecute primero el ejemplo 40.", "Error" )
      RETURN NIL
   ENDIF
   
   InitFastReport()

   TRY
      // oFR := XDCreateFastReport()
      WITH OBJECT oFR
         :Clear()
         :NewReport()
         :SetUnit( FR_UNIT_MM )
         
         // Agregamos la tabla desde SQLite
         :AddSQLiteTable( "Customers", cDb, cSql )
         
         // Diseño rápido del reporte
         :AddBand( "REPORTTITLE", , "titulo" )
         :SetHeight( "titulo", 20 )
         :AddMemo( "titulo", "mTit", "CUSTOMER LIST (SQLITE - JSON ORIGIN)" )
         :SetProperty( "mTit", "Font.Size", 16 )
         :SetProperty( "mTit", "Font.Bold", .T. )
         :SetProperty( "mTit", "Width", 190 )
         :SetProperty( "mTit", "Height", 10 )
         :SetProperty( "mTit", "HAlign", "haCenter" )

         :AddBand( "PAGEHEADER", , "Cabecera", , , .T. )
         :SetHeight( "Cabecera", 10 )
         :AddShape( 0, 0, 190, 8, "Cabecera", "FondoCab", 0, CLR_BLACK, CLR_HEADER_BACK ) // 0 = Rectangle
         
         :AddMemoEx( "Cabecera", "hComp", 2, 1, 70, 6, "COMPANY NAME", CLR_BLACK, -1, "Arial", 10, 0, 1 )
         :SetProperty( "hComp", "Font.Bold", .T. )
         :AddMemoEx( "Cabecera", "hCont", 75, 1, 50, 6, "CONTACT", CLR_BLACK, -1, "Arial", 10, 0, 1 )
         :SetProperty( "hCont", "Font.Bold", .T. )
         :AddMemoEx( "Cabecera", "hCity", 125, 1, 35, 6, "CITY", CLR_BLACK, -1, "Arial", 10, 0, 1 )
         :SetProperty( "hCity", "Font.Bold", .T. )
         :AddMemoEx( "Cabecera", "hCountry", 160, 1, 30, 6, "COUNTRY", CLR_BLACK, -1, "Arial", 10, 0, 1 )
         :SetProperty( "hCountry", "Font.Bold", .T. )

         :AddBand( "DATA", , "Data1", "Customers" )
         :SetHeight( "Data1", 8 )
         :AddMemoEx( "Data1", "mComp", 2, 0, 70, 8, "[Customers.CompanyName]", CLR_BLUE, -1, "Arial", 10, 0, 1 )
         :AddMemoEx( "Data1", "mCont", 75, 0, 50, 8, "[Customers.ContactName]", CLR_BLACK, -1, "Arial", 10, 0, 1 )
         :AddMemoEx( "Data1", "mCity", 125, 0, 35, 8, "[Customers.City]", CLR_BLACK, -1, "Arial", 10, 0, 1 )
         :AddMemoEx( "Data1", "mCountry", 160, 0, 30, 8, "[Customers.Country]", CLR_MAGENTA, -1, "Arial", 10, 0, 1 )

         IF :Prepare()
            :Show( "Reporte SQLite JSON - NWind" )
            // ? :GetInternalState()
            :Save( cFile )
            :SavePrepared( cFilePrep )
            MsgInfo( "Ultima consulta ejecutada:" + hb_OsNewLine() + :GetLastSQL(), "Debug SQL" )
            MsgInfo( "Previsualizacion de datos (JSON):" + hb_OsNewLine() + hb_UTF8ToStr( :GetLastDataPreview() ), "Data Preview" )
         ENDIF

      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample42: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample42()

   LOCAL cPg   := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample42.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample42.fpx"
   LOCAL cTypes

   InitFastReport()
   TRY

      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         // :SetReportName( "Advanced Objects Demo" )

         // Load Data for Matrix/Graphs
         :AddXmlFile( "Northwind", "reports\nwind.xml" )

         // SVG en la cabecera del reporte
         :AddBand( "REPORTTITLE", cPg, "Header", , , .T. )
         :SetHeight( "Header", 25 )
         :AddSVG( 2, 2, 20, 20, hb_dirBase() + "img\sample.svg", "Header", "LogoSVG" )

         :AddMemoEx( "Header", "mTitle", 25, 5, 150, 10, "ADVANCED OBJECTS DEMO", CLR_BLACK, -1, "Arial", 16, 0, 1 )

         // Sparklines en la pagina
         :AddBand( "PAGEHEADER", cPg, "PagHeader", , , .T. )
         :SetHeight( "PagHeader", 15 )
         :AddMemoEx( "PagHeader", "lblSpark", 2, 2, 40, 5, "Trend Sparkline:", CLR_GRAY, -1, "Arial", 8 )
         :AddSparkline( 45, 2, 30, 10, "PagHeader", "MySpark" )

         // Table Object
         :AddBand( "DATABAND", cPg, "Data", , , .T. )
         :SetHeight( "Data", 50 )
         :AddMemoEx( "Data", "lblTable", 2, 2, 40, 5, "Programmatic Table:", CLR_BLUE, -1, "Arial", 10 )
         :AddTable( 2, 10, 160, 30, "Data", "MyTable", 4, 3 ) // 4 rows, 3 columns

         // Populate Table Header
         :Table_SetCellText( "MyTable", 0, 0, "ID" )
         :Table_SetCellText( "MyTable", 1, 0, "Description" )
         :Table_SetCellText( "MyTable", 2, 0, "Price" )
         
         :Table_SetCellFont( "MyTable", 0, 0, "Arial", 10, .T. ) // Column 0, Row 0
         :Table_SetCellFont( "MyTable", 1, 0, "Arial", 10, .T. )
         :Table_SetCellFont( "MyTable", 2, 0, "Arial", 10, .T. )
         
         :Table_SetCellColor( "MyTable", 0, 0, CLR_WHITE, CLR_BLUE ) 
         :Table_SetCellColor( "MyTable", 1, 0, CLR_WHITE, CLR_BLUE )
         :Table_SetCellColor( "MyTable", 2, 0, CLR_WHITE, CLR_BLUE )

         // Data Rows
         :Table_SetCellText( "MyTable", 0, 1, "P001" )
         :Table_SetCellText( "MyTable", 1, 1, "Product A" )
         :Table_SetCellText( "MyTable", 2, 1, "150.00" )

         :Table_SetCellText( "MyTable", 0, 2, "P002" )
         :Table_SetCellText( "MyTable", 1, 2, "Product B" )
         :Table_SetCellText( "MyTable", 2, 2, "230.50" )
         
         // Highlight specific cell
         :Table_SetCellText( "MyTable", 0, 3, "TOTAL" )
         :Table_SetCellAlign( "MyTable", 0, 3, 2, 1 ) // Right, Center
         :Table_SetCellColor( "MyTable", 0, 3, CLR_BLACK, CLR_YELLOW )

         // Matrix (Cross-tab)
         :AddBand( "DATAFOOTER", cPg, "Footer", , , .T. )
         :SetHeight( "Footer", 60 )
         :AddMemoEx( "Footer", "lblMat", 2, 2, 40, 5, "Dynamic Pivot Matrix:", CLR_MAGENTA, -1, "Arial", 10 )


         :AddMatrix( 2, 10, 100, 40, "Footer", "MyMatrix" )
         
         // Bind matrix to data
         :Matrix_SetDataSource( "MyMatrix", "Orders" )
         
         // Descriptores de la matriz (Sin corchetes y con campos existentes en nwind.xml)
         :Matrix_AddRowDescriptor( "MyMatrix", "Orders.ShipCountry" )
         :Matrix_AddColumnDescriptor( "MyMatrix", "Orders.CustomerID" )
         :Matrix_AddDataDescriptor( "MyMatrix", "Orders.Freight", 0 ) // 0 = Sum
         
         // IMPORTANT: Build the template after descriptors are added
         :Matrix_BuildTemplate( "MyMatrix" )
         
         // --- MEJORA DE DISEÑO (ESTILO PIVOT) ---
         :Matrix_SetStyle( "MyMatrix", "Gray" )
         :Matrix_SetHeaderStyle( "MyMatrix", CLR_WHITE, 0x800000, .T. ) // Azul Oscuro (BGR)
         :Matrix_SetTotalStyle( "MyMatrix", CLR_BLACK, CLR_HGRAY, .T. )
         :Matrix_SetRowHeight( "MyMatrix", 8 )

         /*
         // Chart & Map
         :AddBand( "REPORTSUMMARY", cPg, "ColFoot", , , .T. )
         :SetHeight( "ColFoot", 80 )
         :AddChart( 5, 5, 80, 70, "ColFoot", "MyChart" )

         // Configurar Serie del Chart (Tipo 10 = Column)
         :Chart_AddSeries( "MyChart", 10 ) 

         :Chart_SetSeriesData( "MyChart", 0, "Orders", "Orders.ShipCountry", "Orders.Freight" )

         :AddMapObject( 90, 5, 90, 70, "ColFoot", "MyMap" )
         */
         
         IF :Prepare()
             // ? :GetLastError()
             // cTypes := oFR:GetLoadedTypes()
             // hb_MemoWrit( "debug_tipos.txt", cTypes )
             // ? "Inspeccionando objetos de FastReport..."
            :Show()
            // ? :GetInternalState()
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ELSE
            ? :GetLastError()
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY
RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample43: Elements Specials ( CheckBox, HtmlObject, BookMarks, DrillDown )
//----------------------------------------------------------------------------//

FUNCTION XD_Sample43()

   LOCAL cPg   := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample43.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample43.fpx"
   LOCAL cTypes

   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         // :SetReportName( "Interactivity & Rich UI" )

         :AddBand( "REPORTTITLE", cPg, "Title", , , .T. )
         :SetHeight( "Title", 30 )
         :AddMemoEx( "Title", "mMain", 10, 5, 100, 15, "INTERACTIVE REPORT", CLR_BLACK, -1, "Impact", 20, 0, 1 )
         
         // Bookmark (Tree Navigation)
         :SetBookmark( "mMain", "Main Title" )

         // RichText and CheckBox
         :AddBand( "DATABAND", cPg, "MainData", , , .T. )
         :SetHeight( "MainData", 40 )
         
         // RTF Support (Legacy)
         // :AddRichText( 5, 5, 100, 15, "{\rtf1\ansi\b Rich Text support \b0 with RTF formatting.}", "MainData", "MyRich" )

         // HTML Support (Modern - Recommended)
         :AddHtml( 5, 22, 100, 15, '<b>Modern HTML Object:</b><br><font color="#FF0000">Red Text</font> and <i>Italic</i>', "MainData", "MyHtml" )
         // ? :GetLastError()

         // CheckBox
         :AddMemoEx( "MainData", "lblCheck", 110, 5, 30, 5, "Status:", CLR_GRAY, -1, "Arial", 8 )
         :AddCheckBox( 110, 12, 10, 10, .T., "MainData", "MyCheck" )

         // DrillDown
         :AddBand( "DATAFOOTER", cPg, "SubDetail", , , .T. )
         :SetHeight( "SubDetail", 20 )
         :AddMemoEx( "SubDetail", "mDrill", 10, 5, 100, 10, "Click here for Details (DrillDown)", CLR_BLUE, -1, "Arial", 10 )
         :SetHyperlinkReport( "mDrill", "XD_Sample02.frx", "[Customer.ID]" )
         :SetBookmark( "mDrill", "DrillDown Section" )

         // Vectors (Drawing)
         :AddPolygon( 130, 5, 40, 30, "MainData", "MyPoly", "10,10; 30,10; 20,30" )

         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ELSE
            ? :GetLastError()         
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY
RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample44: Access MDB files
//----------------------------------------------------------------------------//

FUNCTION XD_Sample44()

   LOCAL cPg   := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample44.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample44.fpx"
   LOCAL cConn := "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + hb_DirBase() + "data\xbrtest.mdb;"
   LOCAL cSql  := "SELECT * FROM customer"
   
   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         // Usamos ADO para Access MDB
         :AddADOConn( "DataMDB", cConn, cSql )
         
         :AddBand( "ReportTitle", cPg, "T", "" )
         :SetHeight( "T", 15 )
         :AddTextEx( "T", "Title", 0, 0, 190, 10, "REPORTE ACCESS OLEDB (MDB)", 0, 0, "Arial", 16, 1 )

         :AddBand( "PAGEHEADER", cPg, "PH", "" )
         :SetHeight( "PH", 8 )
         :AddTextEx( "PH", "H1", 0, 0, 40, 7, "ID", 0, 0, "Arial", 10, 1 )
         :AddTextEx( "PH", "H2", 40, 0, 100, 7, "NOMBRE", 0, 0, "Arial", 10, 1 )

         :AddBand( "Data", cPg, "D", "DataMDB" )
         :SetHeight( "D", 7 )
         :AddMemoEx( "D", "M1", 0, 0, 40, 6, "[DataMDB.ID]" )
         :AddMemoEx( "D", "M2", 40, 0, 100, 6, "[DataMDB.First] [DataMDB.Last]" )

         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ELSE
            ? :GetLastError()
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
//  XD_Sample45: Access ACCDB files
//----------------------------------------------------------------------------//

FUNCTION XD_Sample45()

   LOCAL cPg   := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample45.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample45.fpx"
   // ACE.OLEDB.12.0 es el driver para .ACCDB
   LOCAL cConn := "Provider=Microsoft.ACE.OLEDB.14.0;Data Source=" + hb_DirBase() + "data\demo.accdb;"
                 //Provider=Microsoft.ACE.OLEDB.16.0
   
   LOCAL cSql  := "SELECT * FROM Country"
   
   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         // Usamos ACE para Access ACCDB
         ? "Proveedores instalados:"
         ? :GetOLEDBProviders()
         ? :GetLastError()

         :AddADOConn( "DataACCDB", cConn, cSql )
         ? :GetLastError()
         ? :GetADOTables( cConn )
         ? :GetLastError()
         
         :AddBand( "ReportTitle", cPg, "T", "" )
         :SetHeight( "T", 15 )
         :AddTextEx( "T", "Title", 0, 0, 190, 10, "REPORTE ACCESS ACE (ACCDB)", 0, 0, "Arial", 16, 1 )

         :AddBand( "Data", cPg, "D", "DataACCDB" )
         :SetHeight( "D", 7 )
         :AddMemoEx( "D", "M2", 40, 0, 100, 6, "[DataACCDB.Name]" )

         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ELSE
            ? :GetLastError()
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample46: Excel antiguo (.xls) via JET
//----------------------------------------------------------------------------//

FUNCTION XD_Sample46()

   LOCAL cPg       := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample46.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample46.fpx"
   LOCAL cConn := "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + hb_DirBase() + "data\Key_FE.xls;Extended Properties='Excel 8.0;HDR=YES';"
   LOCAL cSql  := "SELECT * FROM [Hoja1$]"  // La hoja se indica con $
   
   InitFastReport()
   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         :AddADOConn( "DataExcel", cConn, cSql )
         ? "Tablas/Hojas en Excel:", :GetADOTables( cConn )
         ? :GetLastError()
         :AddBand( "Data", cPg, "D", "DataExcel" )
         :AddMemoEx( "D", "M1", 0, 0, 190, 6, "[DataExcel.Key] [DataExcel.Action]" )
         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample47: Excel moderno (.xlsx) via ACE
//----------------------------------------------------------------------------//

FUNCTION XD_Sample47()

   LOCAL cPg   := "Page1"
   // Requiere tener instalado el motor ACE que comentamos antes
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample47.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample47.fpx"
   LOCAL cConn := "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + hb_DirBase() + "data\Key_FE.xlsx;Extended Properties='Excel 12.0 Xml;HDR=YES';"
   LOCAL cSql  := "SELECT * FROM [Hoja1$]"
   
   InitFastReport()
   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         :AddADOConn( "DataExcelX", cConn, cSql )
         ? :GetLastError()
         ? "Tablas/Hojas en Excel:", :GetADOTables( cConn )
         :AddBand( "Data", cPg, "D", "DataExcelX" )
         :AddMemoEx( "D", "M1", 0, 0, 190, 6, "[DataExcelX.Key] [DataExcelX.Action]" )
         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample48: Use Dbf with OLEDB (VFPOLEDB)
//----------------------------------------------------------------------------//

FUNCTION XD_Sample48()

   LOCAL cPg       := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample48.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample48.fpx"
   // El Data Source en VFPOLEDB es la CARPETA donde están los DBFs
   LOCAL cConn := "Provider=VFPOLEDB;Data Source=" + hb_DirBase() + "data\;Collating Sequence=MACHINE"
   LOCAL cSql  := "SELECT * FROM customer"  // El nombre del DBF sin extensión
   
   InitFastReport()
   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         :AddADOConn( "DataDBF", cConn, cSql )
         ? "Tablas en carpeta data:", :GetADOTables( cConn )
         ? :GetLastError()
         
         :AddBand( "Data", cPg, "D", "DataDBF" )
         // Ajusta los nombres de campo según tu customer.dbf (First, Last, Age, etc.)
         :AddMemoEx( "D", "M1", 0, 0, 190, 6, "[DataDBF.First] [DataDBF.Last]" )
         
         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL


//----------------------------------------------------------------------------//
// XD_Sample49: DBF TO JSON ( HASH )
//----------------------------------------------------------------------------//

FUNCTION XD_Sample49()

   LOCAL cPg       := "Page1"
   LOCAL cDbfFile  := hb_DirBase() + "data\customer.dbf"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample49.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample49.fpx"

   IF !File( cDbfFile )
      Alert( "Error: No se encuentra " + cDbfFile )
      RETURN NIL
   ENDIF

   // 1. Abrir DBF
   USE ( cDbfFile ) SHARED NEW ALIAS DBF_DATA
   
   InitFastReport()
   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         
         // 2. Usar el metodo: convierte a JSON y lo registra como origen de datos
         // AddDbfToJson( cTableName, cAlias )
         :AddDbfToJson( "Clientes", "DBF_DATA" )
         
         :AddBand( "REPORTTITLE", cPg, "B" )
         :AddMemoEx( "B", "T", 0, 0, 190, 10, "REPORTE DESDE JSON (AddDbfToJson)", 0, CLR_YELLOW, "Arial", 14, 1, 1 )
         
         :AddBand( "DATA", cPg, "D", "Clientes" )
         :SetProperty( "D", "Height", 10 )
         
         :AddMemoEx( "D", "M1",   0, 0, 100, 8, "[Clientes.FIRST] [Clientes.LAST]" )
         :AddMemoEx( "D", "M2", 100, 0,  90, 8, "Salario: [Clientes.SALARY]" )
         
         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
         ELSE
            ? :GetLastError()
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

   CLOSE DBF_DATA

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample50: PolyLine and Polygon Objects
//----------------------------------------------------------------------------//

FUNCTION XD_Sample50()

   LOCAL cTitle    := "XDREPORTFAST - PolyLine & Polygon Samples"
   LOCAL cPg       := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample50.frx"
   
   InitFastReport()

   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_CM )

         :AddBand( "REPORTTITLE", cPg, "BTitle" )
         :SetHeight( "BTitle", 3 )
         :AddMemoEx( "BTitle", "Title", 0, 0, 19, 1.5, cTitle, CLR_WHITE, CLR_BLUE, "Arial", 16, 1, 1 )

         :AddBand( "DATA", cPg, "BData" )
         :SetHeight( "BData", 20 )

         // 1. Un Triangulo (Polygon)
         // Puntos en CM (relativos al objeto)
         :AddPolygonObject( 1, 1, 4, 4, "0,4; 2,0; 4,4", "BData", "Triangle", CLR_BLACK, CLR_YELLOW, .F. )
         :AddMemoEx( "BData", "Lbl1", 1, 5.2, 4, 0.5, "Polygon: Triangle", 0, -1, "Arial", 8, 1 )

         // 2. Una Estrella (Polygon) - Escalada a 4x4cm
         :AddPolygonObject( 7, 1, 4, 4, "2,0; 2.4,1.6; 4,1.6; 2.8,2.4; 3.2,4; 2,3; 0.8,4; 1.2,2.4; 0,1.6; 1.6,1.6", "BData", "Star", CLR_RED, CLR_HRED, .T. )
         :AddMemoEx( "BData", "Lbl2", 7, 5.2, 4, 0.5, "Polygon: Star (Con Marco)", 0, -1, "Arial", 8, 1 )

         // 3. Un Zig-Zag (PolyLine) - Escalado a 10x3cm
         :AddPolyLineObject( 1, 7, 10, 3, "0,3; 2.5,0; 5,3; 7.5,0; 10,3", "BData", "ZigZag", CLR_BLUE, 3.0, .T. )
         :AddMemoEx( "BData", "Lbl3", 1, 10.2, 10, 0.5, "PolyLine: ZigZag (Width 3.0 + Marco)", 0, -1, "Arial", 8, 0 )

         // 4. Una Flecha (Polygon) - Escalada a 5x4cm
         :AddPolygonObject( 13, 1, 5, 4, "0,1.6; 3,1.6; 3,0; 5,2; 3,4; 3,2.4; 0,2.4", "BData", "Arrow", CLR_BLACK, CLR_HBLUE, .F. )
         :AddMemoEx( "BData", "Lbl4", 13, 5.2, 5, 0.5, "Polygon: Arrow (Sin Marco)", 0, -1, "Arial", 8, 1 )

          IF :Prepare( .F. )
            :Show()
            :Save( cFile )
         ELSE
            ? :GetLastError()
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// Sample 51: True Accordion DrillDown
//----------------------------------------------------------------------------//

FUNCTION XD_Sample51()

   LOCAL cTitle := "XDREPORTFAST - ACCORDION DRILLDOWN DEMO"
   LOCAL cPg    := "Page1"

   InitFastReport()
   
   TRY   
      WITH OBJECT oFR
         // Registramos datos con un campo común para agrupar
         :RegisterData( "DUMMY", { { "ID" => 1, "VAL" => "Detail 1" }, ;
                                   { "ID" => 1, "VAL" => "Detail 2" } } )

         :AddBand( "REPORTTITLE", cPg, "GrpTitle" )
         :AddMemoEx( "GrpTitle", "mTitle", 0, 0, 19, 1, cTitle )
         :SetProperty( "mTitle", "FillColor", CLR_BLUE )
         :SetProperty( "mTitle", "Font.Color", CLR_WHITE )
         :SetProperty( "mTitle", "Font.Size", 14 )
         :SetProperty( "mTitle", "HAlign", 1 )

         // Creamos una cabecera de grupo con una condicion de agrupacion valida
         :AddBand( "GROUPHEADER", cPg, "GrpHead", "[DUMMY.ID]" )
         :SetHeight( "GrpHead", 1.2 )
         
         // IMPORTANTE: Marcamos esta banda como DrillDown
         // Esto hará que al hacer clic en ella, el visor simule la expansión
         :SetDrillDown( "GrpHead", .T. )
         
         // Fondo para la cabecera
         :AddMemoEx( "GrpHead", "mHeadBack", 0, 0.1, 19, 1, "" )
         :SetProperty( "mHeadBack", "FillColor", CLR_HGRAY2 )
         
         :AddMemoEx( "GrpHead", "mHeadText", 1.2, 0.3, 15, 0.6, "GROUP HEADER (Click here to toggle details)" )
         :SetProperty( "mHeadText", "Font.Style", 1 )
         
         // Icono de expansion a la IZQUIERDA
         :AddMemoEx( "GrpHead", "mArrow", 0.3, 0.3, 1, 0.6, "[ + ]" )
         :SetProperty( "mArrow", "AllowExpressions", .F. )
         :SetProperty( "mArrow", "HAlign", 1 )
         


         // Banda de datos anidada en la cabecera de grupo
         :AddBand( "DATA", "GrpHead", "DataBand", "DUMMY" )
         :SetHeight( "DataBand", 0.8 )
         
         // La banda de datos DEBE estar oculta inicialmente para el efecto acordeon
         :SetBandVisible( "DataBand", .F. )

         :AddMemoEx( "DataBand", "mData1", 1, 0.1, 8, 0.6, "[DUMMY.VAL]" )
         
         // Pie de grupo anidado también
         :AddBand( "GROUPFOOTER", "GrpHead", "GrpFoot" )
         :SetHeight( "GrpFoot", 0.5 )
         :AddLineEx( "GrpFoot", "lFoot", 0, 0, 19, 0, CLR_GRAY, 1 )

         IF :Prepare()
            :Show()
         ELSE
            Alert( "Prepare error: " + :GetLastError() )
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError, .T. )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample52: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample52()

   LOCAL cPg     := "Page1"
   LOCAL cSubPg
   LOCAL aData := { ;
      { "ID" => 1, "NAME" => "MASTER 1" }, ;
      { "ID" => 2, "NAME" => "MASTER 2" } ;
   }
   LOCAL aSubData := { ;
      { "MID" => 1, "INFO" => "Detail 1-A" }, ;
      { "MID" => 1, "INFO" => "Detail 1-B" }, ;
      { "MID" => 2, "INFO" => "Detail 2-A" } ;
   }

   InitFastReport()

   TRY
      WITH OBJECT oFR
         // :NewReport()
         
         :RegisterJsonData( hb_jsonEncode( aData ), "MASTER" )
         :RegisterJsonData( hb_jsonEncode( aSubData ), "DETAILS" )

         :AddBand( "REPORTTITLE", cPg, "Title" )
         :SetHeight( "Title", 1.5 )
         :AddTextEx( "Title", "lblTitle", 0, 0, 19, 1, "DEMO SUBREPORTS: MASTER-DETAIL" )
         :SetProperty( "lblTitle", "Font.Size", 16 )
         :SetProperty( "lblTitle", "HAlign", 1 )

         :AddBand( "DATABAND", cPg, "MasterData", "MASTER" )
         :SetHeight( "MasterData", 2.5 )
         :AddTextEx( "MasterData", "lblMName", 0.5, 0.2, 10, 0.6, "[MASTER.NAME]" )
         :SetProperty( "lblMName", "Font.Bold", .T. )
         :SetProperty( "lblMName", "Fill.Color", CLR_HGRAY )

         // Añadimos el SUBREPORT dentro de la banda de datos del Maestro
         // El metodo devuelve el nombre de la nueva pagina vinculada
         cSubPg := :AddSubreport( "MasterData", "subDet", 1, 1, 15, 1 )
         
         // Ahora añadimos objetos a esa pagina secundaria (cSubPg)
         :AddBand( "DATABAND", cSubPg, "DetailData", "DETAILS" )
         :SetHeight( "DetailData", 0.6 )
         // Filtramos los detalles para que correspondan al maestro (esto simula relacion)
         :SetProperty( "DetailData", "Filter", "[MASTER.ID] == [DETAILS.MID]" )
         
         :AddTextEx( "DetailData", "lblDInfo", 0.5, 0, 10, 0.5, "-> [DETAILS.INFO]" )
         :SetProperty( "lblDInfo", "Font.Italic", .T. )

         IF :Prepare()
            :Show()
         ELSE
            Alert( "Prepare error: " + :GetLastError() )
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError, .T. )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample53: 
//----------------------------------------------------------------------------//

FUNCTION XD_Sample53( cFile )

   LOCAL cCode

   hb_Default( @cFile, hb_dirBase() + "reports\box.frx" )

   InitFastReport()
   
   WITH OBJECT oFR
      // :AddPage( "Page1" )
      // :AddBand( "REPORTTITLE", "Page1", "Title" )
      // :AddTextEx( "Title", "lbl1", 1, 1, 10, 1, "SAMPLE 53: ACTIVE REPORT CODE GEN" )
      
      // MsgInfo( "Generando código del reporte activo...", "Info" )
      // cCode := :FrxToCode()
      // XDMemoEdit( cCode, "Código Harbour del Reporte Activo" )

      // Caso 2: Reporte desde archivo (From File)
      IF File( cFile )
         // MsgInfo( "Generando codigo desde archivo directamente: " + cFile, "Info" )
         // Este metodo NO necesita que el reporte este cargado en oFR
         cCode := :FrxFileToCode( cFile )
         // XDMemoEdit( cCode, "Codigo Harbour generado desde " + hb_FNameName( cFile ) )
         ? cCode
      ELSE
         MsgAlert( "No se encuentra el archivo para test: " + cFile )
      ENDIF
   END WITH

RETURN NIL

//----------------------------------------------------------------------------//
// XD_Sample54: 
//----------------------------------------------------------------------------//

Function XD_Sample54()

   local cFr3 := "ReportsFr3\1.fr3"
   local cFrx := "ReportsFr3\1_migrador_test.frx"
   local cCode

   InitFastReport()

   cCode := oFr:Fr3ToFrx( cFr3, cFrx )
   
   if ! "ERROR:" $ cCode
      MsgInfo( "MIGRACION PROTOTIPO COMPLETADA" + hb_OsNewLine() + ;
               "Archivo Origen (VCL): " + cFr3 + hb_OsNewLine() + ;
               "Archivo Destino (.NET): " + cFrx + hb_OsNewLine() + hb_OsNewLine() + ;
               "Se ha generado el código Harbour equivalente y detectado" + hb_OsNewLine() + ;
               "elementos legados (SQL/Scripts) que se muestran como comentarios." )
      
      XDMemoEdit( cCode, "Codigo Harbour Migrado desde FR3" )
   else
      MsgStop( "No se pudo realizar la migración del archivo " + cFr3 + hb_OsNewLine() + cCode )
   endif
return nil

//----------------------------------------------------------------------------//
// XD_Sample55: 
//----------------------------------------------------------------------------//

Function XD_Sample55()

   local cFr3 := "ReportsFr3\101.fr3"
   local cFrx := "ReportsFr3\101_migrado_complejo.frx"
   local cCode
   
   InitFastReport()

   MsgInfo( "EJEMPLO: MIGRACION CON SCRIPTS COMPLEJOS" + hb_OsNewLine() + ;
            "Archivo: " + cFr3 + hb_OsNewLine() + hb_OsNewLine() + ;
            "Ahora se extrae la logica de PascalScript (condicionales)" + hb_OsNewLine() + ;
            "dentro del codigo Harbour como referencia." )

   cCode := oFr:Fr3ToFrx( cFr3, cFrx )
   
   if ! "ERROR:" $ cCode
      MsgInfo( "MIGRACION COMPLETADA" + hb_OsNewLine() + ;
               "Revisa el principio del codigo generado para ver el Script capturado." )
      
      XDMemoEdit( cCode, "Codigo Harbour Migrado (Script Complejo)" )
   else
      MsgStop( "Error en la migracion: " + hb_OsNewLine() + cCode )
   endif
   ? oFr:GetResult()

return nil

//----------------------------------------------------------------------------//
// XD_Sample56: Load ( Select File )
//----------------------------------------------------------------------------//

FUNCTION XD_Sample56()

   LOCAL cPg       := "Page1"
   LOCAL cFile     := "" // hb_DirBase() + "reports\XD_Sample02.frx"
   LOCAL cFileHTML := "" // hb_DirBase() + "reports\XD_Sample02.html"
   LOCAL cFilePrep := "" // hb_DirBase() + "reports\XD_Sample32.fpx"
   LOCAL lPrepared := .F.
   LOCAL cServer := "127.0.0.1"
   LOCAL cDb     := "Dummy"
   LOCAL cUser   := "root"
   LOCAL cPass   := ""
   LOCAL cPort   := "3306"
   
   cFile   := cGetFile( "Reporte a Cargar (*.frx;*.fpx) |*.frx;*.fpx|", "Seleccione Fichero FRX a Cargar", , hb_DirBase() + "reports\" )
   ? cFile, hb_FNameExt( cFile )
   IF .NOT. File( cFile )
      Alert( "Error: No se encuentra el archivo " + cFile + ". Ejecuta primero el Ejemplo 02." )
      RETURN nil
   ENDIF
   IF Lower( hb_FNameExt( cFile ) ) == ".fpx"
      lPrepared := .T.
   ENDIF

   InitFastReport()

   TRY
      WITH OBJECT oFR

         IF lPrepared
            IF :LoadPrepared( cFile )
               :Show()
            ELSE
               ? :GetLastError()
            ENDIF
         ELSE
            // 1. Establecer conexion global
            // IF :SetMySQLConn( cServer, cDb, cUser, cPass, cPort )

               ? :Load( cFile )
      
               IF :Prepare( .F. )
                  :Show()
                  // :ExportHTML( cFileHTML )
                  ? :GetLastTrace()
                  ? :GetLastError()
               ELSE
                  Alert( :GetLastError() )
               ENDIF
            // ELSE
            //    ? :GetLastError()            
            // ENDIF
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN nil

//----------------------------------------------------------------------------//
// XD_Sample57: 
//----------------------------------------------------------------------------//

Static Function XD_Sample57()

   local oErr
   local cPage := "Page1"

   InitFastReport( cPage )

   TRY
      WITH OBJECT oFR
         :AddBand( "ReportTitle", cPage, "Header" )
         
         :AddText( "Header", "TxtTitle", "TEST DE INDICADORES (GAUGES)" )
         :SetProperty( "TxtTitle", "Font", "Arial, 18pt, style=Bold" )
         :SetProperty( "TxtTitle", "HorzAlign", "Center" )
         :SetBounds( "TxtTitle", 0, 0, 19, 1.5 )

         // Gauge 0: Radial (Velocimetro)
         :AddText( "Header", "L0", "RADIAL GAUGE" )
         :SetBounds( "L0", 1, 2, 4, 0.5 )
         :AddGauge( 1, 3, 4, 4, "Header", "G0", 0, 0, 200, "120" )

         // Gauge 1: Linear
         :AddText( "Header", "L1", "LINEAR GAUGE" )
         :SetBounds( "L1", 6, 2, 4, 0.5 )
         :AddGauge( 6, 3, 4, 4, "Header", "G1", 1, 0, 100, "75" )

         // Gauge 2: Simple
         :AddText( "Header", "L2", "SIMPLE GAUGE" )
         :SetBounds( "L2", 11, 2, 4, 0.5 )
         :AddGauge( 11, 3, 4, 4, "Header", "G2", 2, 0, 100, "50" )

         // Gauge 3: Progress
         :AddText( "Header", "L3", "PROGRESS GAUGE" )
         :SetBounds( "L3", 16, 2, 4, 0.5 )
         :AddGauge( 16, 3, 3, 1, "Header", "G3", 3, 0, 100, "90" )

         if :Prepare()
            :Show()
         else
            ? :GetLastError()
         endif
      END
   CATCH oErr
      IF hb_IsObject( oFR )
         oFR:ShowError( oErr )
      ENDIF
   END TRY

Return nil

//----------------------------------------------------------------------------//
// XD_Sample58: Migracion de Report fr3 con DbCross
//----------------------------------------------------------------------------//

Function XD_Sample58()

   local cFr3 := "ReportsFr3\list0005t.fr3"
   local cFrx := "ReportsFr3\list0005t.frx"
   local cCode
   
   InitFastReport()

   MsgInfo( "EJEMPLO: MIGRACION CON SCRIPTS COMPLEJOS" + hb_OsNewLine() + ;
            "Archivo: " + cFr3 + hb_OsNewLine() + hb_OsNewLine() + ;
            "Ahora se extrae la logica de PascalScript, si hubiese (condicionales)" + hb_OsNewLine() + ;
            "dentro del codigo Harbour como referencia." )

   cCode := oFr:Fr3ToFrx( cFr3, cFrx )
   
   if ! "ERROR:" $ cCode
      MsgInfo( "MIGRACION COMPLETADA" + hb_OsNewLine() + ;
               "Revisa el principio del codigo generado para ver el Script capturado." )
      
      XDMemoEdit( cCode, "Codigo Harbour Migrado (Script Complejo)" )
   else
      MsgStop( "Error en la migracion: " + hb_OsNewLine() + cCode )
   endif
   ? oFr:GetResult()

return nil

//----------------------------------------------------------------------------//
// XD_Sample100: Virtual WorkArea Demo
//----------------------------------------------------------------------------//

FUNCTION XD_Sample100()

   LOCAL cPage := "Page1"
   LOCAL cAlias := "CUSTOMERS"
   LOCAL cFile  := hb_DirBase() + "data\customer.dbf"
   
   IF !File( cFile )
      Alert( "Error: No se encuentra " + cFile )
      RETURN nil
   ENDIF
   
   // Abrimos la tabla en Harbour
   USE (cFile) ALIAS (cAlias) NEW SHARED VIA "DBFCDX"
   // ( cAlias )->( OrdKeyNo( 1 ) )
   ( cAlias )->( DbSetOrder( 1 ) )
   ( cAlias )->( DBGoTop() )
   
   InitFastReport( cPage )
   
   TRY
      WITH OBJECT oFR
         // --- REGISTRAMOS LA WORKAREA VIRTUAL! ---
         // Esto crea un UserDataSet en FastReport que llamará a nuestro FRController
         IF :RegisterWorkArea( cAlias )
         
            :AddBand( "REPORTTITLE", cPage, "Header" )
            :AddMemoEx( "Header", "mTit", 0, 0, 19, 1.5, "VIRTUAL WORKAREA DEMO" + CRLF + "LIVE CUSTOMER DBF ACCESS" )
            :SetProperty( "mTit", "FillColor", CLR_HBLUE1 )
            :SetProperty( "mTit", "Font.Color", CLR_WHITE )
            :SetProperty( "mTit", "Font.Size", 14 )
            :SetProperty( "mTit", "HAlign", 1 )
            
            :AddBand( "COLUMNHEADER", cPage, "ColHeader" )
            :SetHeight( "ColHeader", 0.8 )
            :AddMemoEx( "ColHeader", "hFirst", 1, 0, 4, 0.8, "FIRST" )
            :AddMemoEx( "ColHeader", "hLast", 5, 0, 8, 0.8, "LAST" )
            :AddMemoEx( "ColHeader", "hCity", 13, 0, 6, 0.8, "CITY" )
            :SetProperty( "hFirst", "Font.Bold", .T. )
            :SetProperty( "hLast", "Font.Bold", .T. )
            :SetProperty( "hCity", "Font.Bold", .T. )
            :SetProperty( "ColHeader", "FillColor", CLR_HGRAY2 )
   
            // Banda de Datos vinculada al Alias virtual
            :AddBand( "DATA", cPage, "DataBand", cAlias )
            :SetHeight( "DataBand", 0.7 )
            :AddMemoEx( "DataBand", "mFirst", 1, 0, 4, 0.7, "[" + cAlias + ".FIRST]" )
            :AddMemoEx( "DataBand", "mLast", 5, 0, 8, 0.7, "[" + cAlias + ".LAST]" )
            :AddMemoEx( "DataBand", "mCity", 13, 0, 6, 0.7, "[" + cAlias + ".CITY]" )
            
            // Efecto Pijama
            :SetEvenStyle( "DataBand", nRGB( 245, 245, 255 ) )
   
            IF :Prepare()
               // ? :GetLastTrace()
               :Show( "Demo Virtual WorkArea - Customers DBF" )
            ELSE
               ? "Error en Prepare:", :GetLastError()
            ENDIF
         ELSE
            ? " - Alias no Registrado: " + cAlias + hb_OsNewLine() + " - Error: " + :GetLastError()
         ENDIF
      END
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY
   
   (cAlias)->( dbCloseArea() )
   
RETURN nil

//----------------------------------------------------------------------------//
/*
FUNCTION XD_Sample1A00()

   local oErr
   LOCAL cAlias
   
   if Select( "CUST" ) == 0
      USE ( hb_DirBase() + "data\customer.dbf" ) VIA "DBFCDX" ALIAS CUST NEW SHARED
      cAlias := Alias()
   endif
   
   InitFastReport()
   
   TRY
      ? oFR:RegisterWorkArea( "CUST" )
      
      // oFR:Design()
   CATCH oErr
      oFR:ShowError( oErr )
   END TRY

   IF !Empty( cAlias )
      (cAlias)->( dbCloseArea() )
   ENDIF

RETURN NIL
*/
/*
PROCEDURE Main()
   LOCAL hLib
   LOCAL lRet
   LOCAL cAlias := "TEST"
   LOCAL cFields := "NAME,AGE"
   LOCAL nRecords := 10
   LOCAL cError

   ? "Testing XDFastReportBridge.dll..."
   
   hLib := hb_LibLoad( "XDFastReportBridge.dll" )
   
   IF Empty( hLib )
      ? "Error: Could not load XDFastReportBridge.dll"
      QUIT
   ENDIF
   ? "DLL Loaded successfully."
   
   ? "Calling FR_Init()..."
   hb_DynCall( { "FR_Init", hLib, hb_bitOr( 0, 0 ) } )
   ? "FR_Init() DONE."
   
   ? "Calling FR_NewReport()..."
   hb_DynCall( { "FR_NewReport", hLib, hb_bitOr( 0, 0 ) }, "Page1" )
   ? "FR_NewReport() DONE."

   ? "Calling FR_RegisterHarbourWorkArea()..."
   lRet := hb_DynCall( { "FR_RegisterHarbourWorkArea", hLib, hb_bitOr( 0, 0 ) }, cAlias, cFields, nRecords )
   ? "FR_RegisterHarbourWorkArea() DONE."
   
   ? "Registration result:", ValType(lRet), lRet
   
   cError := hb_DynCall( { "FR_GetLastError", hLib, hb_bitOr( 0, 0 ) } )
   ? "Last Error:", cError
   
   hb_LibFree( hLib )
   ? "Done."
RETURN
*/

//----------------------------------------------------------------------------//
// XD_Sample101: Multi-language Scripting (Harbour, Python, JS, PHP)
//----------------------------------------------------------------------------//

FUNCTION XD_Sample101()

   LOCAL cPg   := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample101.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample101.fpx"
   LOCAL cScript   := ""
   // LOCAL cCodePy   := "print('Hello from C# to Python!')"
   LOCAL cCodePy   := "Python Test Tag: [WA_SETCODEPY( '3*2' )]"
   LOCAL cCodeJs   := "JS Expression Test: [WA_SETCODEJS( 'Math.PI * 2' )]"

   // Cabecera especial para detectar el lenguaje externo
   cScript += "//LANGUAGE:HARBOUR" + hb_OsNewLine()
   cScript += "void PageHeader1_OnBeforePrint(object sender, EventArgs e) {" + hb_OsNewLine()
   cScript += "  // Este codigo se enviara a Harbour mediante WA_EXEC_EXTERNAL_SCRIPT" + hb_OsNewLine()
   cScript += "}" + hb_OsNewLine()
   cScript += hb_OsNewLine()
   cScript += "void mClick_OnClick(object sender, EventArgs e) {" + hb_OsNewLine()
   cScript += "  // Este codigo tambien se enviara a Harbour" + hb_OsNewLine()
   cScript += "}" + hb_OsNewLine()

   InitFastReport()
   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         :SetScript( cScript )
         
         // Cabecera de Página con evento BeforePrint
         :AddBand( "PAGEHEADER", cPg, "PageHeader1", , , .T. )
         :SetHeight( "PageHeader1", 20 )
         :SetProperty( "PageHeader1", "BeforePrintEvent", "PageHeader1_OnBeforePrint" )
         
         :AddMemoEx( "PageHeader1", "mTitle", 10, 5, 100, 10, "MULTI-LANGUAGE SCRIPTING TEST", CLR_BLACK, -1, "Arial", 14, 0, 1 )
         
         // Banda de Datos
         :AddBand( "DATABAND", cPg, "Data", , , .T. )
         :SetHeight( "Data", 50 )
         :AddMemoEx( "Data", "mExpr", 10, 5, 160, 10, cCodeJs, CLR_BLUE, -1, "Arial", 10 )
         :AddMemoEx( "Data", "mExpr2", 10, 18, 160, 10, cCodePy, CLR_BLACK, -1, "Arial", 10 )

         :AddMemoEx( "Data", "mClick", 10, 32, 100, 10, "CLICK ME (HARBOUR CALLBACK)", CLR_WHITE, CLR_RED, "Arial", 10, 0, 1 )
         :SetHyperlink( "mClick", 4, "mClick_OnClick" )

         IF :Prepare()
            // ? :GetLastTrace()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
            MsgInfo( "Ejemplo 101 Guardado con exito en:" + hb_OsNewLine() + cFile )
         ELSE
            MsgStop( "Error al preparar reporte: " + :GetLastError() )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ELSE
         MsgStop( "Error crítico: " + hb_ValToExp(oError) )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//

FUNCTION XD_Sample102()

   LOCAL cPg       := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample102.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample102.fpx"
   LOCAL cScript   := ""
   
   // cScript += "// XD:LANGUAGE HARBOUR" + hb_OsNewLine()
   // cScript += "LANGUAGE:HARBOUR" + hb_OsNewLine()

   // Script en Harbour que manipula objetos del reporte
   cScript += "[WA_SETCODE:HB]" + hb_OsNewLine()
   cScript += "FUNCTION PageHeader1_OnBeforePrint( sender, e )" + hb_OsNewLine()
   cScript += "   LOCAL oMemo" + hb_OsNewLine()
   cScript += "   LOCAL cRet" + hb_OsNewLine()
   // cScript += "   // Acceso directo al reporte principal via hObject (inyectado)" + hb_OsNewLine()

   // cScript += "   oMemo := XD_Report:FindObject( 'mTitle' )" + hb_OsNewLine()
   // cScript += "   IF oMemo != NIL" + hb_OsNewLine()
   // cScript += "      oMemo:FillColor := 255 // Rojo" + hb_OsNewLine()
   // cScript += "      oMemo:TextColor := 16777215 // Blanco" + hb_OsNewLine()
   // cScript += "      oMemo:Text := 'TITULO DINAMICO DESDE HARBOUR'" + hb_OsNewLine()
   // cScript += "      cRet := Valtype( oMemo ) + 'ONBEFOREPRINT'" + hb_OsNewLine()
   // cScript += "   ELSE" + hb_OsNewLine()
   // cScript += "      cRet := 'MEMO IS NIL'" + hb_OsNewLine()
   // cScript += "   ENDIF" + hb_OsNewLine()

   cScript += "   cRet := Valtype( XD_Report )" + hb_OsNewLine()
   // cScript += "   cRet += if( Valtype( XD_Report ) == 'O', ' ' + XD_Report:ClassName(), ' ' )" + hb_OsNewLine()
   cScript += "   IF hb_ISObject( XD_Report )" + hb_OsNewLine()
   cScript += "      cRet += ' - Class: ' + XD_Report:ClassName()" + hb_OsNewLine()
   cScript += "   ENDIF" + hb_OsNewLine()
   cScript += "RETURN cRet" + hb_OsNewLine()
   cScript += "[/WA_SETCODE]" + hb_OsNewLine() + hb_OsNewLine()

   InitFastReport()
   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         // :SetScript( cScript )
         
         :AddBand( "PAGEHEADER", cPg, "PageHeader1", , , .T. )
         :SetHeight( "PageHeader1", 30 )
         // :SetProperty( "PageHeader1", "BeforePrintEvent", "PageHeader1_OnBeforePrint" )
         
         :AddMemoEx( "PageHeader1", "mTitle", 10, 5, 150, 15, "TITULO ORIGINAL", CLR_BLACK, -1, "Arial", 14, 0, 1 )
         
         :AddBand( "DATABAND", cPg, "Data", , , .T. )
         :AddMemoEx( "Data", "mInfo1", 10, 5, 160, 10, "Este reporte demuestra como Harbour manipula el color " + ;
                     "y texto del titulo en tiempo de ejecucion.", CLR_BLACK, -1, "Arial", 10 )
         :AddMemoEx( "Data", "mInfo2", 10, 10, 190, 10, cScript, CLR_BLACK, -1, "Arial", 10 )

         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
            MsgInfo( "Ejemplo 102 (Manipulacion de Objetos) ejecutado con exito" )
         ELSE
            MsgStop( "Error al preparar reporte: " + :GetLastError() )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ELSE
         MsgStop( "Error crítico: " + hb_ValToExp(oError) )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//

FUNCTION XD_Sample103()

   LOCAL cPg       := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample103.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample103.fpx"
   LOCAL cRet      := DToS( Date() )
   LOCAL cText     := ""
   
   // Definimos un bloque multilínea complejo directamente en el texto del Memo
   cText += "Resultado de logica compleja: " + hb_OsNewLine()
   cText += "[WA_SETCODE:HB]" + hb_OsNewLine()
   cText += "   LOCAL nVal := 1500" + hb_OsNewLine()
   cText += "   LOCAL cRet := 'NORMAL'" + hb_OsNewLine()
   cText += "   IF nVal > 1000" + hb_OsNewLine()
   cText += "      cRet := 'USUARIO VIP (LOGICA MULTILINEA)'" + hb_OsNewLine()
   cText += "   ENDIF" + hb_OsNewLine()
   cText += "   RETURN cRet" + hb_OsNewLine()
   cText += "[/WA_SETCODE]" + hb_OsNewLine() + hb_OsNewLine()
   cText += "Custom Language Test: [WA_SETCODECUSTOM('CUSTOM', 'return " + cRet + " ')]"   // 'return DToS(Date())')]"

   InitFastReport()
   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         
         :AddBand( "PAGEHEADER", cPg, "PageHeader1", , , .T. )
         :AddMemoEx( "PageHeader1", "mTitle", 10, 5, 150, 10, "EJEMPLO BLOQUES MULTILINEA", CLR_BLACK, -1, "Arial", 14, 0, 1 )
         
         :AddBand( "DATABAND", cPg, "Data", , , .T. )
         :SetHeight( "Data", 60 )
         
         // El memo contendrá el bloque multilínea que la DLL procesará
         :AddMemoEx( "Data", "mComplex", 10, 5, 160, 40, cText, CLR_BLACK, -1, "Arial", 11 )
      
         IF :Prepare()
            // ? :GetLastTrace()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
            MsgInfo( "Ejemplo 103 (Bloques Multilinea) ejecutado con exito" )
         ELSE
            MsgStop( "Error al preparar reporte: " + :GetLastError() )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ELSE
         MsgStop( "Error crítico: " + hb_ValToExp(oError) )
      ENDIF
   END TRY


RETURN NIL

//----------------------------------------------------------------------------//

FUNCTION XD_Sample104()

   LOCAL cPg       := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\xd_sample104.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\xd_Sample104.fpx"
   LOCAL cTitle    := "TITULO DINAMICO DESDE HARBOUR VIA PARAMETRO"
   LOCAL nColor    := 255 // Rojo

   InitFastReport()
   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )

         // MsgInfo( FR_Test2Strings( "Hola", "Mundo" ) )
         // 1. Calculamos los datos en Harbour y los pasamos como parámetros
         :SetParameter( "TITULO_HARBOUR", cTitle )
         // :SetVariable( "TITULO_HARBOUR", cTitle )
         :SetParameter( "COLOR_TITULO", nColor )

         :AddBand( "PAGEHEADER", cPg, "PageHeader1", , , .T. )
         // 2. En el objeto Memo, usamos la expresión [TITULO_HARBOUR]
         // Esto permite que FastReport resuelva el valor internamente sin llamar a Harbour durante el Prepare()
         :AddMemoEx( "PageHeader1", "mTitle", 10, 5, 170, 15, "[TITULO_HARBOUR]", CLR_BLACK, -1, "Arial", 14 )
         :SetProperty( "mTitle", "Font.Color", nColor )
         
         // Podemos incluso usar el parámetro para otras propiedades via script de FastReport (C#)
         // pero lo más directo es usarlo en el contenido del texto.
         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
            MsgInfo( "Ejemplo 104 (Contenido Dinámico via Parametros) ejecutado con exito." )
         ELSE
            MsgStop( "Error al preparar reporte: " + :GetLastError() )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//

FUNCTION XD_Sample105()

   LOCAL cPg       := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample105.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample105.fpx"

   InitFastReport()
   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :AddBand( "REPORTTITLE", cPg, "Title" )
         // Use the tag to execute Harbour code and show result
         :AddMemoEx( "Title", "mDate", 10, 10, 150, 10, ;
            "Fecha en 400 dias: [WA_SETCODE('RETURN DToC( Date() + 400 )')]", ;
            CLR_BLACK, -1, "Arial", 12 )

         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
            MsgInfo( "Sample 105 (Harbour Scripting Date + 400) ejecutado con exito" )
         ELSE
            MsgStop( "Error al preparar reporte: " + :GetLastError() )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//

FUNCTION XD_Sample106()

   LOCAL cPg       := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample106.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample106.fpx"
   LOCAL cText     := ""

   // Complex multi-line script inside the tag itself to avoid bridge issues
   cText += "Calculo de anio bisiesto: " + hb_OsNewLine()
   cText += "[WA_SETCODE:HB]" + hb_OsNewLine()
   cText += "   LOCAL nY := Year( Date() )" + hb_OsNewLine()
   cText += "   LOCAL lLeap := ( nY % 4 == 0 .and. nY % 100 != 0 ) .or. ( nY % 400 == 0 )" + hb_OsNewLine()
   cText += "   LOCAL cRet := 'El anio ' + AllTrim(Str(nY)) + iif( lLeap, ' ES bisiesto', ' NO es bisiesto' )" + hb_OsNewLine()
   cText += "   RETURN cRet" + hb_OsNewLine()
   cText += "[/WA_SETCODE]"

   InitFastReport()
   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         :AddBand( "REPORTTITLE", cPg, "Title" )
         // Important: Multi-line HB script block
         :AddMemoEx( "Title", "mResult", 5, 10, 150, 10, cText, CLR_BLACK, -1, "Arial", 12 )

         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
            MsgInfo( "Sample 106 (Leap Year Inline Script) ejecutado con exito" )
         ELSE
            MsgStop( "Error al preparar reporte: " + :GetLastError() )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//

FUNCTION XD_Sample107()

   LOCAL cPg       := "Page1"
   LOCAL cFile     := hb_DirBase() + "reports\XD_Sample107.frx"
   LOCAL cFilePrep := hb_DirBase() + "reports\XD_Sample107.fpx"
   LOCAL cText     := ""

   // Using the same technique as 106 (inline script) but with multiple functions
   cText += "[WA_SETCODE:HB]" + hb_OsNewLine()
   cText += "//LANGUAGE:HARBOUR" + hb_OsNewLine()
   
   // First function is the entry point
   cText += "FUNCTION GetLeapInfo( p1, p2 )" + hb_OsNewLine()
   cText += "   LOCAL nYear := Year( Date() )" + hb_OsNewLine()
   cText += "   LOCAL lLeap := IsLeapYear( nYear )" + hb_OsNewLine()
   cText += "   LOCAL cMsg  := 'Calculo de anio bisiesto (Multi-Func): El anio ' + AllTrim(Str(nYear))" + hb_OsNewLine()
   cText += "   IF lLeap" + hb_OsNewLine()
   cText += "      cMsg += ' ES bisiesto'" + hb_OsNewLine()
   cText += "   ELSE" + hb_OsNewLine()
   cText += "      cMsg += ' NO es bisiesto'" + hb_OsNewLine()
   cText += "   ENDIF" + hb_OsNewLine()
   cText += "RETURN cMsg" + hb_OsNewLine() + hb_OsNewLine()

   cText += "FUNCTION IsLeapYear( nY )" + hb_OsNewLine()
   cText += "   LOCAL lRet" + hb_OsNewLine()
   cText += "   IF ( nY % 4 == 0 .AND. nY % 100 != 0 ) .OR. ( nY % 400 == 0 )" + hb_OsNewLine()
   cText += "      lRet := .T." + hb_OsNewLine()
   cText += "   ELSE" + hb_OsNewLine()
   cText += "      lRet := .F." + hb_OsNewLine()
   cText += "   ENDIF" + hb_OsNewLine()
   cText += "RETURN lRet" + hb_OsNewLine()
   cText += "[/WA_SETCODE]"

   InitFastReport()
   TRY
      WITH OBJECT oFR
         :AddPage( cPg )
         :SetUnit( FR_UNIT_MM )
         :AddBand( "REPORTTITLE", cPg, "Title" )
         // Memo with the multi-function inline script
         :AddMemoEx( "Title", "mResult", 5, 10, 150, 20, ;
            cText, ;
            CLR_BLACK, -1, "Arial", 12 )

         IF :Prepare()
            :Show()
            :Save( cFile )
            :SavePrepared( cFilePrep )
            MsgInfo( "Sample 107 (Multi-Func Inline) ejecutado con exito" )
         ELSE
            MsgStop( "Error al preparar reporte: " + :GetLastError() )
         ENDIF
      END WITH
   CATCH oError
      IF hb_IsObject( oFR )
         oFR:ShowError( oError )
      ENDIF
   END TRY

RETURN NIL

//----------------------------------------------------------------------------//
