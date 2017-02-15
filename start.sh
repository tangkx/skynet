# @Author: tkx
# @Date:   2017-02-13 14:08:15
# @Last Modified by:   tkx
# @Last Modified time: 2017-02-13 16:35:15
gnome-terminal -x bash -c "./skynet log/config.tlog;" &
sleep 4
gnome-terminal -x bash -c "./skynet mysqlcluster/config.mysql;" & 
sleep 4

