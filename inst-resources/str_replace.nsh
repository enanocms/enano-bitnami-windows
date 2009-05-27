; StrReplace
; Replaces all ocurrences of a given needle within a haystack with another string
; Written by Dan Fuhry

!ifndef _StrRep
!define _StrRep

Var sr_haystack
Var sr_needle
Var sr_replace
Var sr_pos
Var sr_needlelen
Var sr_p_before
Var sr_stacklen
Var sr_p_after
Var sr_newpos
Var sr_test

Function str_replace
  Exch $sr_replace
  Exch 1
  Exch $sr_needle
  Exch 2
  Exch $sr_haystack
    StrCpy $sr_pos -1
    StrLen $sr_needlelen $sr_needle
    StrLen $sr_stacklen $sr_haystack
    loop:
      IntOp $sr_pos $sr_pos + 1
      StrCpy $sr_test $sr_haystack $sr_needlelen $sr_pos
      StrCmp $sr_test $sr_needle found
      StrCmp $sr_pos $sr_stacklen done
      Goto loop
    found:
      StrCpy $sr_p_before $sr_haystack $sr_pos
      IntOp $sr_newpos $sr_pos + $sr_needlelen
      StrCpy $sr_p_after $sr_haystack "" $sr_newpos
      StrCpy $sr_haystack $sr_p_before$sr_replace$sr_p_after
      StrCpy $sr_pos $sr_newpos
      StrLen $sr_stacklen $sr_haystack
      Goto loop
    done:
  Pop $sr_needle ; Prevent "invalid opcode" errors and keep the
  Pop $sr_needle ; stack as it was before the function was called
  Exch $sr_haystack
FunctionEnd

!endif ; _StrRep

!ifndef StrReplace
  !macro _strReplaceConstructor OUT NEEDLE NEEDLE2 HAYSTACK
    Push `${HAYSTACK}`
    Push `${NEEDLE}`
    Push `${NEEDLE2}`
    Call str_replace
    Pop `${OUT}`
  !macroend

  !define StrReplace '!insertmacro "_strReplaceConstructor"'
  !define str_replace '!insertmacro "_strReplaceConstructor"'
!endif

; StrStr
; input, top of stack = string to search for
;        top of stack-1 = string to search in
; output, top of stack (replaces with the portion of the string remaining)
; modifies no other variables.
;
; Usage:
;   Push "this is a long ass string"
;   Push "ass"
;   Call StrStr
;   Pop $R0
;  ($R0 at this point is "ass string")

!macro StrStr un
Function ${un}StrStr
Exch $R1 ; st=haystack,old$R1, $R1=needle
  Exch    ; st=old$R1,haystack
  Exch $R2 ; st=old$R1,old$R2, $R2=haystack
  Push $R3
  Push $R4
  Push $R5
  StrLen $R3 $R1
  StrCpy $R4 0
  ; $R1=needle
  ; $R2=haystack
  ; $R3=len(needle)
  ; $R4=cnt
  ; $R5=tmp
  loop:
    StrCpy $R5 $R2 $R3 $R4
    StrCmp $R5 $R1 done
    StrCmp $R5 "" done
    IntOp $R4 $R4 + 1
    Goto loop
done:
  StrCpy $R1 $R2 "" $R4
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Exch $R1
FunctionEnd
!macroend

!insertmacro StrStr ""
; !insertmacro StrStr "un."
