!macro Core_Install
  SetOverwrite try
  SectionIn RO
  
  ; not a huge deal if this fails, it just helps me avoid dumb mistakes.
  !system 'hg -R "${ENANO_ROOT}" update'
  
  SetOutPath "$INSTDIR\apps\${PRODUCT_SHORTNAME}\htdocs"
  File /r /x .hg /x .hgtags "${ENANO_ROOT}"
!macroend

!macro Core_Uninstall
  ; I'm sorry, but 1,000 files don't deserve to be listed out.
  RmDir /r "$INSTDIR\apps\${PRODUCT_SHORTNAME}\htdocs"
!macroend
