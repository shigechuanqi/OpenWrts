本代码在原有X86基础上增加了LEDE对小米AX6000的固件编译
1.修改分区
LEDE原有分区 mtdparts=nmbm0:1024k(bl2),256k(Nvram),256k(Bdata),2048k(factory),2048k(fip),256k(crash),256k(crash_log),112640k(ubi)
修改为X-WRT分区 mtdparts=nmbm0:1024k(bl2),256k(Nvram),256k(Bdata),2048k(factory),2048k(fip),256k(crash),256k(crash_log),30720k(ubi),30720k(ubi1),51200k(overlay)
修改参考 https://www.right.com.cn/FORUM/thread-8255378-1-1.html
修改内容参考 https://github.com/x-wrt/x-wrt/commit/6ef69f9d4a05811acb584b0e8736d91e97a91b5c

2.安装步骤
参考：https://www.right.com.cn/FORUM/thread-8255378-1-1.html

stock-initramfs-factory.ubi
https://downloads.x-wrt.com/rom/ 搜索 *xiaomi_redmi-router-ax6000-stock-initramfs-factory.ubi

①解锁SSH权限

②备份分区
#查看分区
>cat /proc/mtd
#备份分区
dd if=/dev/mtd1 of=/tmp/mtd1_BL2.bin
dd if=/dev/mtd2 of=/tmp/mtd2_Nvram.bin
dd if=/dev/mtd3 of=/tmp/mtd3_Bdata.bin
dd if=/dev/mtd4 of=/tmp/mtd4_Factory.bin
dd if=/dev/mtd5 of=/tmp/mtd5_FIP.bin


③查看现有启动分区
>cat /proc/cmdline

firmware=1 表示当前系统是ubi1
firmware=0 表示当前系统是ubi

##如果当前系统是 ubi，设置nvram变量从ubi1启动
#设置环境变量
nvram set boot_wait=on
nvram set uart_en=1
nvram set flag_boot_rootfs=1
nvram set flag_last_success=1
nvram set flag_boot_success=1
nvram set flag_try_sys1_failed=0
nvram set flag_try_sys2_failed=0
nvram commit

#刷临时系统
ubiformat /dev/mtd9 -y -f /tmp/stock-initramfs-factory.ubi

##如果当前系统是 ubi1，设置nvram变量从ubi启动
#设置环境变量
nvram set boot_wait=on
nvram set uart_en=1
nvram set flag_boot_rootfs=0
nvram set flag_last_success=0
nvram set flag_boot_success=1
nvram set flag_try_sys1_failed=0
nvram set flag_try_sys2_failed=0
nvram commit

#刷临时系统
ubiformat /dev/mtd8 -y -f /tmp/stock-initramfs-factory.ubi

#刷完之后重启
>reboot

④刷LEDE固件
ptpt52大佬的 sysupgrade -n /tmp/stock-sysupgrade.bin 会提示错误，这里登陆网址http://192.168.15.1强行刷，不保留配置

LED等由蓝变白闪的时候说明成功了

http://192.168.100.1/
root/password

----------------------------------------------------------
这些是常用的 LEDE/OpenWrt 固件。ptpt52编译，代号： 
固件无线默认名称：X-WRT_XXXX，密码：88888888
固件管理界面：http://192.168.15.1/
管理界面账户/密码：admin/admin
SSH登录账户/密码：root/admin 需要进入界面-系统-管理权页面-开启SSH登录
---------------------------------------------------------




