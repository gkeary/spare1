 $a= @( `
 @{db='dispatch_ct'; usr= 'ctuser'}, `
 @{db='dispatch_ma'; usr= 'mauser'},`
 @{db='dispatch_me'; usr= 'meuser'},`
 @{db='dispatch_nh'; usr= 'nhuser'},`
 @{db='dispatch_vt'; usr= 'vtuser'}`
 )

foreach ( $i in $a) { '{0,10} ==>{1,7}'  -f $i.db, $i.usr }
 
'db is: {0,10} user is:{1,7} in the 4th position'  -f $a[3].db, $a[3].usr 