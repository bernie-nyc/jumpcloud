Set-Timezone -Id "Eastern Standard Time"
net stop w32time
w32tm /unregister
w32tm /register
net start w32time
w32tm /config /manualpeerlist:us.pool.ntp.org /syncfromflags:manual /update
w32tm /config /update
w32tm /resync /rediscover
