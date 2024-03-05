--- a/target/linux/rockchip/image/armv8.mk
+++ b/target/linux/rockchip/image/armv8.mk
@@ -3,7 +3,7 @@
 # Copyright (C) 2020 Tobias Maedel
 
 define Device/ariaboard_photonicat
-  DEVICE_VENDOR := Ariaboard
+  DEVICE_VENDOR := 光影猫
   DEVICE_MODEL := Photonicat
   SOC := rk3568
   UBOOT_DEVICE_NAME := photonicat-rk3568
 
@@ -72,6 +72,17 @@ $(call Device/fastrhino_common)
 endef
 TARGET_DEVICES += fastrhino_r68s
 
+define Device/nlnet_xgp
+  DEVICE_VENDOR := NLnet
+  DEVICE_MODEL := XiGuaPi
+  SOC := rk3568
+  UBOOT_DEVICE_NAME := nlnet-xgp-rk3568
+  IMAGE/sysupgrade.img.gz := boot-combined | boot-script nlnet-xgp | pine64-img | gzip | append-metadata
+  DEVICE_PACKAGES := kmod-hwmon-pwmfan kmod-mt7921e wpad-basic-wolfssl
+  DEVICE_DTS = rockchip/rk3568-xgp rockchip/rk3568-xgp-v3
+endef
+TARGET_DEVICES += nlnet_xgp
+
 define Device/friendlyarm_nanopi-neo3
   DEVICE_VENDOR := FriendlyARM
   DEVICE_MODEL := NanoPi NEO3
@@ -91,9 +102,19 @@ define Device/friendlyarm_nanopi-r2c
 endef
 TARGET_DEVICES += friendlyarm_nanopi-r2c
 
+define Device/friendlyarm_nanopi-r2c-plus
+  DEVICE_VENDOR := FriendlyARM
+  DEVICE_MODEL := NanoPi R2C Plus
+  SOC := rk3328
+  UBOOT_DEVICE_NAME := nanopi-r2c-plus-rk3328
+  IMAGE/sysupgrade.img.gz := boot-common | boot-script nanopi-r2s | pine64-bin | gzip | append-metadata
+  DEVICE_PACKAGES := kmod-usb-net-rtl8152
+endef
+TARGET_DEVICES += friendlyarm_nanopi-r2c-plus
+
 define Device/friendlyarm_nanopi-r2s
   DEVICE_VENDOR := FriendlyARM
-  DEVICE_MODEL := NanoPi R2S
+  DEVICE_MODEL := NanoPi R2S / R2S Plus
   SOC := rk3328
   UBOOT_DEVICE_NAME := nanopi-r2s-rk3328
   IMAGE/sysupgrade.img.gz := boot-common | boot-script nanopi-r2s | pine64-bin | gzip | append-metadata
@@ -141,6 +162,22 @@ define Device/friendlyarm_nanopi-r5s
 endef
 TARGET_DEVICES += friendlyarm_nanopi-r5s
 
+define Device/friendlyarm_nanopi-m4
+  DEVICE_VENDOR := FriendlyARM
+  DEVICE_MODEL := NanoPi M4
+  SOC := rk3328
+  DEVICE_DTS = rockchip/rk3328-nanopi-r2s
+endef
+TARGET_DEVICES += friendlyarm_nanopi-m4
+
+define Device/friendlyarm_nanopi-neo4
+  DEVICE_VENDOR := FriendlyARM
+  DEVICE_MODEL := NanoPi NEO4
+  SOC := rk3328
+  DEVICE_DTS = rockchip/rk3328-nanopi-r2s
+endef
+TARGET_DEVICES += friendlyarm_nanopi-neo4
+
 define Device/firefly_station-p2
   DEVICE_VENDOR := Firefly
   DEVICE_MODEL := Station P2

--- a/target/linux/rockchip/armv8/base-files/etc/board.d/02_network
+++ b/target/linux/rockchip/armv8/base-files/etc/board.d/02_network
@@ -23,8 +23,15 @@
 	xunlong,orangepi-r1-plus|\
 	xunlong,orangepi-r1-plus-lts)
 		ucidef_set_interfaces_lan_wan 'eth1' 'eth0'
+		;;
+	friendlyarm,nanopi-m4 | \
+	friendlyarm,nanopi-neo4 | \
+	som-rk3399 | cm3588)
+		ucidef_set_interfaces_lan_wan 'wlan0' 'eth0'
 		;;
 	fastrhino,r66s|\
 	firefly,rk3568-roc-pc|\

--- a/target/linux/rockchip/armv8/base-files/etc/board.d/01_leds
+++ b/target/linux/rockchip/armv8/base-files/etc/board.d/01_leds
@@ -9,8 +9,8 @@ boardname="${board##*,}"
 board_config_update
 
 case $board in
-friendlyarm,nanopi-r2c|\
-friendlyarm,nanopi-r2s|\
+friendlyarm,nanopi-r2c*|\
+friendlyarm,nanopi-r2s*|\
 xunlong,orangepi-r1-plus|\
 xunlong,orangepi-r1-plus-lts)
 	ucidef_set_led_netdev "wan" "WAN" "$boardname:green:wan" "eth0"

--- a/target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
+++ b/target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
@@ -34,8 +34,8 @@ firefly,rk3568-roc-pc)
 	set_interface_core 2 "eth0"
 	set_interface_core 4 "eth1"
 	;;
-friendlyarm,nanopi-r2c|\
-friendlyarm,nanopi-r2s|\
+friendlyarm,nanopi-r2c*|\
+friendlyarm,nanopi-r2s*|\
 seewo,sv21-rk3568|\
 xunlong,orangepi-r1-plus|\
 xunlong,orangepi-r1-plus-lts)
@@ -53,5 +53,19 @@ friendlyarm,nanopi-r5s)
 	set_interface_core 2 "eth1"
 	set_interface_core 4 "eth2"
 	;;
+friendlyarm,nanopc-t6)
+	set_interface_core 8 "eth0-0"
+	set_interface_core 8 "eth0-16"
+	set_interface_core 8 "eth0-18"
+	echo fe > /sys/class/net/eth0/queues/rx-0/rps_cpus
+	set_interface_core 4 "eth1-0"
+	set_interface_core 4 "eth1-16"
+	set_interface_core 4 "eth1-18"
+	echo fe > /sys/class/net/eth1/queues/rx-0/rps_cpus
+	seconds="0"
+	set_interface_core 40 "xhci-hcd:usb5"
+	set_interface_core 40 "xhci-hcd:usb7"
+	set_interface_rps "fe" "wlan0"
+	;;
 esac
 

--- a/target/linux/rockchip/image/Makefile
+++ b/target/linux/rockchip/image/Makefile
@@ -79,4 +79,15 @@ endif
 
 include $(SUBTARGET).mk
 
+define Image/Build
+	if [[ "$(PROFILE_SANITIZED)" == "friendlyarm_nanopi-m4" || "$(PROFILE_SANITIZED)" == "friendlyarm_nanopi-neo4" ]]; then \
+		export IMG_PREFIX="$(IMG_PREFIX)$(if $(PROFILE_SANITIZED),-$(PROFILE_SANITIZED))"; \
+		export BIN_DIR=$(BIN_DIR); \
+		export TOPDIR=$(TOPDIR); \
+		export MORE=$(MORE); \
+		cd /data/packit/friendlywrt23-rk3399; \
+		. ~/packit/packit_nanopi.sh; \
+	fi
+endef
+
 $(eval $(call BuildImage))
