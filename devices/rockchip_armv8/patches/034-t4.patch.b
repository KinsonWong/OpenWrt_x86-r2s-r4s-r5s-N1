From 46891146695f340ca08f74bdd18dfa4372d2943e Mon Sep 17 00:00:00 2001
From: Lu jicong <jiconglu58@gmail.com>
Date: Sun, 16 Jul 2023 19:41:09 +0800
Subject: [PATCH] rockchip: add FriendlyARM NanoPC T4 support

Hardware
--------
RockChip RK3399 ARM64 (6 cores)
4GB LPDDR3 RAM
1x 1000 Base-T
1 GPIO LED (status)
HDMI 2.0
3.5mm TRRS AV jack
Micro-SD slot
16GB eMMC
1x USB 3.0 Port
2x USB 2.0 Port
1x USB Type-C Port
1x M.2 PCI-E Port
AP6356S (BCM4356) SDIO WiFi & Bluetooth adapter
--------
Note: AP6356S is not supported yet due to the lack of firmware and NVRAM

Signed-off-by: Lu jicong <jiconglu58@gmail.com>
Signed-off-by: Tianling Shen <cnsztl@immortalwrt.org>
---
 target/linux/rockchip/image/armv8.mk             |  8 ++++++++
 ...100-rockchip-use-system-LED-for-OpenWrt.patch | 16 ++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/target/linux/rockchip/image/armv8.mk b/target/linux/rockchip/image/armv8.mk
index 03feea502d1..ccd1469dd16 100644
--- a/target/linux/rockchip/image/armv8.mk
+++ b/target/linux/rockchip/image/armv8.mk
@@ -39,6 +39,15 @@ define Device/firefly_roc-rk3568-pc
 endef
 TARGET_DEVICES += firefly_roc-rk3568-pc
 
+define Device/friendlyarm_nanopc-t4
+  DEVICE_VENDOR := FriendlyARM
+  DEVICE_MODEL := NanoPC T4
+  SOC := rk3399
+  BOOT_FLOW := pine64-bin
+  DEVICE_PACKAGES := kmod-brcmfmac wpad-basic-wolfssl \
+	brcmfmac-firmware-4356-sdio brcmfmac-nvram-4356-sdio
+endef
+TARGET_DEVICES += friendlyarm_nanopc-t4
+
 define Device/friendlyarm_nanopi-r2c
   DEVICE_VENDOR := FriendlyARM
   DEVICE_MODEL := NanoPi R2C
diff --git a/target/linux/rockchip/patches-6.1/100-rockchip-use-system-LED-for-OpenWrt.patch b/target/linux/rockchip/patches-6.1/100-rockchip-use-system-LED-for-OpenWrt.patch
index d2764e34898..6a31ec3cf0f 100644
--- a/target/linux/rockchip/patches-6.1/100-rockchip-use-system-LED-for-OpenWrt.patch
+++ b/target/linux/rockchip/patches-6.1/100-rockchip-use-system-LED-for-OpenWrt.patch
@@ -141,6 +141,22 @@ Signed-off-by: David Bauer <mail@david-bauer.net>
  		};
  	};
  
+--- a/arch/arm64/boot/dts/rockchip/rk3399-nanopc-t4.dts
++++ b/arch/arm64/boot/dts/rockchip/rk3399-nanopc-t4.dts
+@@ -15,6 +15,13 @@
+ 	model = "FriendlyElec NanoPC-T4";
+ 	compatible = "friendlyarm,nanopc-t4", "rockchip,rk3399";
+ 
++	aliases {
++		led-boot = &status_led;
++		led-failsafe = &status_led;
++		led-running = &status_led;
++		led-upgrade = &status_led;
++	};
++
+ 	vcc12v0_sys: vcc12v0-sys {
+ 		compatible = "regulator-fixed";
+ 		regulator-always-on;
 --- a/arch/arm64/boot/dts/rockchip/rk3399-nanopi-r4s.dts
 +++ b/arch/arm64/boot/dts/rockchip/rk3399-nanopi-r4s.dts
 @@ -19,6 +19,13 @@
