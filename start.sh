# @Author: tkx
# @Date:   2017-02-13 14:08:15
# @Last Modified by:   tkx
# @Last Modified time: 2017-02-15 14:05:18
gnome-terminal -x bash -c "./skynet log/config.tlog;" &
sleep 2
gnome-terminal -x bash -c "./skynet mysqlcluster/config.mysql;" & 
sleep 2
gnome-terminal -x bash -c "./skynet tgateserver/config.gate;" & 
sleep 2

