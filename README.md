
一 概述
    本代码在原有X86基础上增加了LEDE对红米AX6000的固件编译

二 与原版LEDE的变化
    1.原版LEDE使用大分区,本编译修改为X-WRT的原厂分区模式
        1.1LEDE原有分区 mtdparts=nmbm0:1024k(bl2),256k(Nvram),256k(Bdata),2048k(factory),2048k(fip),256k(crash),256k(crash_log),112640k(ubi)
        1.2X-WRT分区 mtdparts=nmbm0:1024k(bl2),256k(Nvram),256k(Bdata),2048k(factory),2048k(fip),256k(crash),256k(crash_log),30720k(ubi),30720k(ubi1),51200k(overlay)
        1.3修改内容参考 https://github.com/x-wrt/x-wrt/commit/6ef69f9d4a05811acb584b0e8736d91e97a91b5c
    2.新增AdGuardHome插件的直接编译支持
    3.新增默认主题luci-theme-neobird
    4.登陆IP修改为192.168.100.1 root/password
三 安装使用(方法仅适应于本例)
    1.解锁SSH
        可参考(https://www.right.com.cn/forum/thread-8253125-1-1.html)
    2.常用命令
        >cat /proc/mtd
        >cat /proc/partitions
        >
    3.备份原厂分区
        >dd if=/dev/mtd1 of=/tmp/mtd1_BL2.bin
        >dd if=/dev/mtd2 of=/tmp/mtd2_Nvram.bin
        >dd if=/dev/mtd3 of=/tmp/mtd3_Bdata.bin
        >dd if=/dev/mtd4 of=/tmp/mtd4_Factory.bin
        >dd if=/dev/mtd5 of=/tmp/mtd5_FIP.bin

    4.安装方案1 (uboot+sysupgrade.bin) 参考(https://www.right.com.cn/forum/thread-8265832-1-1.html)
      先安装uboot,然后通过uboot直接安装sysupgrade包
        4.1下载uboot(https://github.com/hanwckf/bl-mt798x/releases)
            获得 mt7986_redmi_ax6000-fip-fixed-parts-multi-layout.bin 
        4.2安装
            >md5sum /tmp/mt7986_redmi_ax6000-fip-fixed-parts-multi-layout.bin 
            >#写入分区FIP
            >mtd write /tmp/mt7986_redmi_ax6000-fip-fixed-parts-multi-layout.bin FIP
            >#验证是否写入成功
            >mtd verify /tmp/mt7986_redmi_ax6000-fip-fixed-parts-multi-layout.bin FIP
        4.3启动uboot系统
            拔电关机->捅RESET键(保持)->插电->等15s松RESET键
        4.4登陆uboot系统
            登陆IP:192.168.31.1
        4.5刷LEDE固件
            在uboot WEB界面选择本例编译的(openwrt-mediatek-filogic-xiaomi_redmi-router-ax6000-squashfs-sysupgrade.bin)进行安装
    5.安装方案2 (stock-intramfs-factory+sysupgrade.bin)参考(https://www.right.com.cn/FORUM/thread-8255378-1-1.html)
        5.1下载stock-initramfs-factory.ubi
            https://downloads.x-wrt.com/rom/ 搜索 *xiaomi_redmi-router-ax6000-stock-initramfs-factory.ubi
        5.2查看现有启动分区
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

        5.2刷临时系统stock-initramfs-factory.ubi
            ubiformat /dev/mtd8 -y -f /tmp/stock-initramfs-factory.ubi

            #刷完之后重启
            >reboot

        5.3刷LEDE固件
            ptpt52大佬的 sysupgrade -n /tmp/stock-sysupgrade.bin 会提示错误，这里登陆网址http://192.168.15.1强行刷，不保留配置LED等由蓝变白闪的时候说明成功了

    6.配置LEDE
        登陆地址：http://192.168.100.1/
        root/password
    
    7.当前版本默认插件
        广告屏蔽大师 Plus+ /ShadowSocksR Plus+ /AdGuard Home /上网时间控制 /解锁网易云灰色歌曲 /动态 DNS  /SmartDNS /网络唤醒 /WatchCat /UPnP /KMS 服务器
    
四 使用总结
    1.两种方式本人都安装使用过
    2.本例LEDE安装好之后如果想升级,使用LEDE固件本身的系统升级是无法升级的,需要重新刷固件才行,建议采用uboot+sysupgrade.bin方式,可以方便的进uboot刷新的sysupgrade.bin即可





