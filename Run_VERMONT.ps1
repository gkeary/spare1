  function runit($d) {
     $h = 'C:\Documents and Settings\cdowling\Desktop\SupportProject\configs\'      
     cd ($h + $d)      
     .\RossDispatch1-4.exe     
  }

   $sites ="VT"
   foreach ($r in $sites) {      
      runit($r)
   }

   cd 'C:\Documents and Settings\cdowling\Desktop\SupportProject\'


      
   