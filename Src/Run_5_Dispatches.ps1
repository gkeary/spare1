  function runit($d) {
     $h = 'C:\HotSpare\Src\configs\'      
     cd ($h + $d)      
     .\RossDispatch1-4.exe     
  }

   # note; MA is missing...
   $sites ="CT","NH","VT", "ME"   
   #$sites = "ME"
   foreach ($r in $sites) {      
      runit($r)
   }

   cd  'c:\HotSpare\Src\configs\MA'
   .\RossDispatch1-6.exe 
   
   cd 'C:\HotSpare\Src\'


      
   