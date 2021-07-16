!Progress Class to use API features of Marquee, State and SmoothReverse
!Written by Carl Barnes November 2018. Free to use, please give credit. 
!---------------------------------------------------------------------------------------
!How to make a Marquee Progress:
!   PBMarqCls    CBPBMarqueeClass            !Define the Class in Data
!   PBMarqCls.Init(?ProgMarq, <Anni Time>)   !After window is open init the class.Default Anni Time is 30 and fine
!   PBMarqCls.TurnOn(<Anni Time>)            !To start the Marquee Progress running, e.g. before Check for Update
!   PBMarqCls.TurnOff()                      !To stop the Marquee 
! 
!How to use CBPBApiClass
!   PBApiCls    CBPBApiClass   !Define the Class in Data
!   PBApiCls.Init(?Progress)   !After window is open init 
!   PBApiCls.SetState( # )     !Chnage bar color to reflect state: 1=Normal 2=Error (red) 3=Paused (yellow)
!   PBApiCls.Reverse(1)        !Change Progress to move from Right to Left.
!   PBApiCls.SmoothReverse(1)  !Smooth annimation for Reverse Increment and Normal Decrement have
!                                 You can use SmoothReverse to animate that better, but it only matters for large changes and most progress changes +=1  
!=======================================================================================
OMIT('_EndOfInclude_',_ProgressApiClsIncPresent_)
_ProgressApiClsIncPresent_ EQUATE(1)

CBPBApiClass   CLASS,TYPE,MODULE('CBProgressApiCls.CLW'),LINK('CBProgressApiCls.CLW',1),DLL(0)
ProgressFEQ     LONG
ProgressHnd     LONG
Init            PROCEDURE(LONG ProgFEQ),VIRTUAL
SetState        PROCEDURE(LONG PBST_123)       !Color bar with PBM_SETSTATE 1=PBST_NORMAL 2=ERROR 3=PAUSED
Reverse         PROCEDURE(BOOL TurnOn)         !Reverses growth to be from Right to Left. Does nothing for Vert. Simly PROP:Layout
SmoothReverse   PROCEDURE(BOOL TurnOn)         !Style PBS_SMOOTHREVERSE a smooth decrement (or increment if reverse)
!---  Internal Methods ---
SetGWLStyle     PROCEDURE(LONG Bits, BOOL TurnOn) 
SetWndLong      PROCEDURE(LONG WLnIndex, LONG Bits, BOOL TurnOn)
SendMessage     PROCEDURE(LONG MsgNo, LONG WParm, LONG LParm),LONG,PROC 
             END

CBPBMarqueeClass CLASS(CBPBApiClass),TYPE,MODULE('CBProgressApiCls.CLW'),LINK('CBProgressApiCls.CLW',1),DLL(0)
AnniTime        LONG  !Time, in milliseconds, between marquee animation updates. Zero=30 milliseconds. Higher is slower
Init            PROCEDURE(LONG ProgFEQ),DERIVED
Init            PROCEDURE(LONG ProgFEQ, LONG AnniTime)
TurnOn          PROCEDURE(LONG AnniTime=-1)  !Begin Animation
Pause           PROCEDURE()                  !Stop the Animation but leave the Style as marquee so appears paused
Resume          PROCEDURE()                  !Resume paused Animation
TurnOff         PROCEDURE()                  !End Animation
!---  Internal Methods ---
SetStyle        PROCEDURE(BOOL TurnOnMarqueeStyle),PROTECTED                 !Set GWLStyle as PBS_MARQUEE
SetAnnim        PROCEDURE(BOOL TurnOnAnnimation, LONG AnniTime=0),PROTECTED  !Send PBM_SETMARQUEE On/Off
            END

    _EndOfInclude_