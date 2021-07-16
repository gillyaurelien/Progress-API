!Progress Marquee and State Example by Carl Barnes November 2018. Free to use.

!#1 Progress Marquee is an "Indeterminate progress bar" 
!Modal indeterminate progress bars indicate an operation is in progress by showing an animation 
!that continuously cycles across the bar from left to right. 
!Used for operations whose overall progress cannot be determined, so there is no notion of 
!completeness. E.g. web operations like Check for Update.
!Internally the API code runs its own timer to paint a bar segment that moves across.

!#2 Progress State change
!I think PBST ERROR and PAUSED states just change color so it seems overly complex to use 
!versus just changing PROP:Color=Red. But with Visual Styles you CANNOT change Colors.
!Could use if Cancel button is pressed set to PAUSED while ask Message('R U Sure?')
!State does NOT work with a Progress Marquee, for me the marquee goes a way.
!Problem: Once state is not normal the RTL no longer paint from the USE(PVar) correctly. Must use ?PVar{PROP:Progress}.

!#3 Reverse Smooth 
!Normally when the progress decreases it jumps without animation. This makes it animate.

!#4 Reverse Progress movement
!Bar moves from right to left with increases in progress. Uses {PROP:Layout}=1 i.e. Japan Right to Left layout.
!     You can use SmoothReverse to animate that better, but it only matters for large changes and most progress changes +=1  

!Marquee and State requires Visual Styles ENABLED so a Manifest or maybe you could call InitCommonControlsEx.

!I would think SV could easily add PROPS
!   ?Progress{PROP:ProgressMarquee} = Anni Time: >0 turns ON, =0 Off, -1=Pause. I'm not sure pause is needed but it is easy to do, see class code.
!   ?Progress{PROP:ProgressState} = Value 1,2,3 for Normal, Error, Paused
!   ?Progress{PROP:SmoothReverse} = 1/0          Not sure this is important but Microsoft added for some reason
!     or ?Progress{PROP:Smooth,2} = 1/0            could add array to existing property
!   ?Progress{PROP:Layout}=1                     Already works to move progress Right to Left

  PROGRAM
  INCLUDE('CBProgressApiCls.INC'),ONCE
  MAP
ProgressMarqueeTest  PROCEDURE()  
  END
  CODE
  ProgressMarqueeTest()
  
ProgressMarqueeTest  PROCEDURE()  
MarqTimer   LONG(60)   
ProgNormal  LONG(70)
ProgVert    LONG(70)
SlideNormal LONG(70) 
RvsSmooth   BOOL
RvsLayout   BOOL         !PROP:Layout can make Progress grow Right to Left
Window WINDOW('Progress API Marquee and State Example...'),AT(,,254,148),CENTER,GRAY,SYSTEM,ICON(ICON:Thumbnail), |
            FONT('Segoe UI',10),DOUBLE
        GROUP('Marquee Progress Bar'),AT(7,3,199,53),USE(?MarqueeGrp),BOXED
            PROGRESS,AT(15,24,181,8),USE(?MarqUpdate),RANGE(0,100),SMOOTH
            STRING(''),AT(39,13,141,10),USE(?Progress:UserString),CENTER
            PROMPT('Ann Time: '),AT(15,41),USE(?PROMPT1)
            ENTRY(@n4),AT(51,38,22),USE(MarqTimer),TIP('Annimation Time for Marquee')
            BUTTON('On'),AT(83,37,20),USE(?OnBtn),TIP('Turn On Marquee')
            BUTTON('Pause'),AT(105,37,30,14),USE(?Pause),DISABLE,TIP('Pause Marquee')
            BUTTON('Resume'),AT(139,37,34,14),USE(?Resume),DISABLE,TIP('Turn Off Marquee')
            BUTTON('Off'),AT(175,37,22,14),USE(?OffBtn),DISABLE,TIP('Turn Off Marquee')
        END
        BUTTON('Close'),AT(217,129,29,12),USE(?Progress:Cancel),STD(STD:Close)
        BUTTON('State'),AT(217,98,29,12),USE(?StateBtn),SKIP,TIP('Set to Error or Paused state (which changes color).' & |
                '<13><10>Does not work for Horizontal Marquee, may not be intended to work.')
        CHECK('Reverse Smooth'),AT(15,131),USE(RvsSmooth),SKIP,TIP('Apply PBS_SMOOTHREVERSE Style<13,10>Move Slider to l' & |
                'eft to test')
        CHECK('Reverse Layout'),AT(115,131),USE(RvsLayout),SKIP,TIP('Apply PROP:Layout=1 to Progress control<13,10>for R' & |
                'ight to Left Bar movement i.e. Reverse')
        PROGRESS,AT(227,10,8,76),USE(ProgVert),RANGE(0,100),SMOOTH,VERTICAL
        PROGRESS,AT(55,72,90,8),USE(?MarqSmall),RANGE(0,100),SMOOTH
        PROGRESS,AT(15,99,171,8),USE(ProgNormal),RANGE(0,100),SMOOTH
        SLIDER,AT(15,113,171),USE(SlideNormal),RANGE(0,100),TIP('Drag Slider to Change Progress')
        BUTTON('Debug'),AT(217,113,29,12),USE(?DebugBtn)
    END
    
PbNormCls   CBPBApiClass 
PbVertCls   CBPBApiClass 
MarqClsUp   CBPBMarqueeClass 
!MarqClsV    CBPBMarqueeClass    !VERTICAL Marquee does not work, just goes to 100%
MarqClsSm   CBPBMarqueeClass  
State       LONG(1)             
StatePU     LONG             
    CODE
    OPEN(Window) 
    ?ProgVert{PROP:Tip}='Vertical Marquee<13,10>Does not work right, goes to 100%'
    ?MarqSmall{PROP:Tip}='Horizontal Marquee at default annimation time of 30'
    ?MarqUpdate{PROP:Tip}='Click ON button to start Check for Update Marquee' 
    ACCEPT
        CASE EVENT()
        OF EVENT:OpenWindow 
           PbNormCls.Init(?ProgNormal)
           PbVertCls.Init(?ProgVert)   
           MarqClsUp.Init(?MarqUpdate, MarqTimer)
           MarqClsSm.Init(?MarqSmall) ; MarqClsSm.TurnOn()
                     
        END 
        CASE ACCEPTED()
        OF ?MarqTimer ; MarqClsUp.AnniTime = MarqTimer
        OF ?OnBtn  ; MarqClsUp.TurnOn()  ; ?Progress:UserString{PROP:Text}='Checking for Updates...'
                                         disable(?OnBtn) ;  enable(?Pause)                    ; enable(?OffBtn)
        OF ?Pause  ; MarqClsUp.Pause()   ;                 ; disable(?Pause) ;  Enable(?Resume) ; enable(?OffBtn)
        OF ?Resume ; MarqClsUp.Resume()  ;                 ;  enable(?Pause) ; Disable(?Resume) 
        OF ?OffBtn ; MarqClsUp.TurnOff() ; ENable(?OnBtn)  ; disable(?Pause) ; Disable(?Resume) ;  disable(?OffBtn)
                                         ?Progress:UserString{PROP:Text}='' 
        OF ?StateBtn
            StatePU=POPUP(CHOOSE(State=1,'+','-') & 'PBST_Normal|' & |
                          CHOOSE(State=2,'+','-') & 'PBST_Error <9>Red|' & |
                          CHOOSE(State=3,'+','-') & 'PBST_Paused <9>Yellow')
            IF StatePU THEN
               State=StatePU
               PbNormCls.SetState(State)  !works for normal progress
               PbVertCls.SetState(State)
!Problem: with State changed to Pause or Error the progress does not paint right with slider changes?
            END
        OF ?SlideNormal ; ProgNormal = SlideNormal ; ProgVert = SlideNormal
! If State is used the RTL seems to lose connect to USE so these PROP:Progress are needed to update
                          ?ProgNormal{PROP:Progress} = ProgNormal
                          ?ProgVert{PROP:Progress}   = ProgVert
                          DISPLAY
        OF ?RvsSmooth  !Make decrementing progress (reverse) have a pretty smooth animation, default is jumps
                PbNormCls.SmoothReverse(RvsSmooth)
                PbVertCls.SmoothReverse(RvsSmooth)
        OF ?RvsLayout
                PbNormCls.Reverse(RvsLayout)    !?ProgNormal{PROP:Layout}=RvsLayout just uses Layout
                MarqClsUp.Reverse(RvsLayout)
                MarqClsSm.Reverse(RvsLayout)
                ?ProgVert{PROP:Layout}=RvsLayout   !Does NOT work to grow bottom to top for Vertical PB
                DISPLAY
        OF ?DebugBtn
            IF Message('ProgNormal=' & ProgNormal & '  PROP:Progress=' & ?ProgNormal{PROP:Progress} & |
                      '|ProgVert=' & ProgVert & '  PROP:Progress=' & ?ProgVert{PROP:Progress} & |
                      '|SlideNormal=' & SlideNormal & '  PROP:Progress=' & ?SlideNormal{PROP:Progress} , |
                      'Debug',,'Close|Block 5 Seconds') = 2 THEN 
               tb#=CLOCK()
               LOOP !Block to see if Marquee stops, it does :( so seems to requires accept loop
                    ! YIELD() does nothing
                    tn#=CLOCK()                         
               WHILE tn#>=tb# AND tn# < tb# + 500 ; ! MESSAGE('Block Done')
            END                    
        END
    END
    RETURN
     