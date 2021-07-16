!Progress Class to use API features of Marquee, State and SmoothReverse
!Written by Carl Barnes November 2018. Free to use, please give credit.   
!----------------------------------------------------------------------
  MEMBER
  INCLUDE 'CBProgressApiCls.INC'
  MAP
    module('win32')
      GetLastError(),LONG,PASCAL,DLL(1)
      GetWindowLong(SIGNED hWnd, SIGNED nIndex ),PASCAL,RAW,LONG,PROC,NAME('GetWindowLongA'),DLL(1)
      SetWindowLong(SIGNED hWnd, SIGNED nIndex, LONG dwNewLong ),PASCAL,RAW,LONG,PROC,NAME('SetWindowLongA'),DLL(1)
      SendMessage(SIGNED hWnd, UNSIGNED Msg, UNSIGNED wParam, SIGNED lParam ),PASCAL,RAW,SIGNED,PROC,NAME('SendMessageA'),DLL(1)
    end    
  END

GWL_STYLE           EQUATE(-16)  
PBM_SETMARQUEE      EQUATE(040Ah)  !WM_USER + 10   https://docs.microsoft.com/en-us/windows/desktop/Controls/pbm-setmarquee
PBM_SETSTATE        EQUATE(0410h)  !WM_USER + 16   https://docs.microsoft.com/en-us/windows/desktop/Controls/pbm-setstate
!Progress Bar Styles requires ComCtrl32.DLL Version 6.0 or later and Vista. Plus a Manifest. Unverified, might work in XP.
PBS_SMOOTH          EQUATE(1)     !The progress bar displays progress status in a smooth scrolling bar instead of the default segmented bar. 
PBS_VERTICAL        EQUATE(4)     !The progress bar displays progress status vertically, from bottom to top.   
PBS_MARQUEE         EQUATE(8)     !The progress indicator does not grow in size but instead moves repeatedly along the length of the bar, indicating activity without specifying what proportion of the progress is complete.    
PBS_SMOOTHREVERSE   EQUATE(16)    !If this is set, then a "smooth" transition will occur, otherwise the control will "jump" to the lower value.    
PBST_NORMAL         EQUATE(1)     !PBM_SETSTATE message WParms
PBST_ERROR          EQUATE(2)  
PBST_PAUSED         EQUATE(3) 

!===============================================================
CBPBApiClass.Init            PROCEDURE(LONG ProgFEQ)!,VIRTUAL
    CODE
    ASSERT(ProgFEQ{PROP:Type}=CREATE:progress)
    SELF.ProgressFEQ = ProgFEQ
    SELF.ProgressHnd = ProgFEQ{PROP:Handle}
    RETURN    
!--------------------    
CBPBApiClass.SetState  PROCEDURE(LONG PBST_123) !Send PBM_SETSTATE message with PBST_NORMAL _ERROR _PAUSED
    CODE
    SELF.SendMessage(PBM_SETSTATE, PBST_123, 0)
    RETURN    
!--------------------
CBPBApiClass.Reverse PROCEDURE(BOOL TurnOn)   !Reverses growth to be from Right to Left. Does nothing for Vertical
    CODE
    SELF.ProgressFEQ{PROP:Layout}=TurnOn
    RETURN
!-------------------- 
CBPBApiClass.SmoothReverse PROCEDURE(BOOL TurnOn)
P   LONG,AUTO
    CODE
    P = SELF.ProgressFEQ{PROP:Progress}
    SELF.SetGWLStyle(PBS_SMOOTHREVERSE, TurnOn)
    SELF.ProgressFEQ{PROP:Progress} = P         !Needed to repaint control
    RETURN
!-------------------- Internal Methods ----------------    
CBPBApiClass.SetGWLStyle PROCEDURE(LONG Bits, BOOL TurnOn) 
    CODE
    SELF.SetWndLong(GWL_STYLE, Bits, TurnOn) 
    RETURN
!--------------------    
CBPBApiClass.SetWndLong PROCEDURE(LONG WLnIndex, LONG Bits, BOOL TurnOn) 
WndLng       LONG,AUTO
    CODE
    WndLng = GetWindowLong(SELF.ProgressHnd, WLnIndex)
    IF TurnOn THEN 
       WndLng = BOR(WndLng,Bits)
    ELSE
       WndLng = BAND(WndLng,BXOR(Bits,-1))
    END    
    SetWindowLong(SELF.ProgressHnd, WLnIndex, WndLng)
    RETURN
!--------------------    
CBPBApiClass.SendMessage PROCEDURE(LONG MsgNo, LONG WParm, LONG LParm)!,LONG,PROC
    CODE
    RETURN SendMessage(SELF.ProgressHnd, MsgNo, WParm, LParm)
!===============================================================
CBPBMarqueeClass.Init PROCEDURE(LONG ProgFEQ)!,DERIVED
    CODE
    SELF.Init(ProgFEQ,30)
    RETURN 
!--------------------
CBPBMarqueeClass.Init PROCEDURE(LONG ProgFEQ, LONG AnniTime)
    CODE
    ASSERT(ProgFEQ{PROP:ThemeActive},'Progress does not have theme active, marquee will not work')
    SELF.AnniTime = AnniTime
    PARENT.Init(ProgFEQ)
    RETURN
!--------------------
CBPBMarqueeClass.TurnOn          PROCEDURE(LONG AnniTime=-1)
    CODE
    IF AnniTime = -1 THEN AnniTime = SELF.AnniTime.
    SELF.SetStyle(1)
    SELF.SetAnnim(1, AnniTime)
    RETURN
CBPBMarqueeClass.Pause           PROCEDURE()
    CODE
    SELF.SetAnnim(0)
    RETURN 
CBPBMarqueeClass.Resume          PROCEDURE()
    CODE
    SELF.SetAnnim(1)
    RETURN    
CBPBMarqueeClass.TurnOff         PROCEDURE() 
    CODE
    SELF.SetAnnim(0)
    SELF.SetStyle(0)    
    RETURN
!--------------------    
CBPBMarqueeClass.SetStyle PROCEDURE(BOOL TurnOnMarqueeStyle) !Set GWLStyle as PBS_MARQUEE
    CODE
    SELF.SetGWLStyle(PBS_MARQUEE, TurnOnMarqueeStyle)
    RETURN
!--------------------    
CBPBMarqueeClass.SetAnnim PROCEDURE(BOOL TurnOnAnnimation, LONG AnniTime=0)  !Send PBM_SETMARQUEE On/Off
    CODE
    SELF.SendMessage(PBM_SETMARQUEE, TurnOnAnnimation, AnniTime)
    RETURN
!--------------------    

  


