#!/bin/bash

## move current shell path
CAD=$(cd `dirname $0`;pwd)
cd $CAD

## delete openwrt stock layout
rm -rf ../openwrt/target/linux/mediatek/dts/mt7986a-xiaomi-redmi-router-ax6000.dts
rm -rf ../openwrt/target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh

cp mt7986a-xiaomi-redmi-router-ax6000.dts ../openwrt/target/linux/mediatek/dts/mt7986a-xiaomi-redmi-router-ax6000.dts
cp platform.sh ../openwrt/target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh



