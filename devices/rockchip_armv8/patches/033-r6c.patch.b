From ba871510ef6d3a3223be54d0aa81c9f9797ba103 Mon Sep 17 00:00:00 2001
From: Tianling Shen <cnsztl@immortalwrt.org>
Date: Sat, 15 Jul 2023 17:31:44 +0800
Subject: [PATCH] rockchip: add NanoPi R6C support

Hardware
--------
RockChip RK3588S ARM64 (8 cores)
4/8GB LPDDR4X RAM
1000 Base-T (native, rtl8211f)
2500 Base-T (PCIe, rtl8125b)
4 LEDs (SYS / WAN / LAN / USER)
2 Button (GPIO Reset, MaskROM)
32GB eMMC on-board
Micro-SD Slot
USB 3.0 Port
USB 2.0 Port
HDMI 2.1
USB Type C PD 5/9/12/20V

Signed-off-by: Tianling Shen <cnsztl@immortalwrt.org>
---
 .../armv8/base-files/etc/board.d/01_leds      |   1 +
 .../armv8/base-files/etc/board.d/02_network   |   2 +
 .../etc/hotplug.d/net/40-net-smp-affinity     |   1 +
 .../boot/dts/rockchip/rk3588s-nanopi-r6c.dts  |  27 +++
 .../boot/dts/rockchip/rk3588s-nanopi-r6s.dts  | 185 ++++++++++++++++-
 target/linux/rockchip/image/armv8.mk          |   9 +
 ...-rockchip-Add-RK806-regulator-config.patch | 196 ------------------
 ...ockchip-Add-missing-regulator-config.patch |  21 --
 .../210-rockchip-rk356x-add-support-for-new-boards.patch        |   3 +-
 9 files changed, 226 insertions(+), 219 deletions(-)
 create mode 100644 target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3588s-nanopi-r6c.dts

diff --git a/target/linux/rockchip/armv8/base-files/etc/board.d/01_leds b/target/linux/rockchip/armv8/base-files/etc/board.d/01_leds
index 92abc55f24a..df56abdd735 100644
--- a/target/linux/rockchip/armv8/base-files/etc/board.d/01_leds
+++ b/target/linux/rockchip/armv8/base-files/etc/board.d/01_leds
@@ -14,6 +14,7 @@ friendlyarm,nanopi-r2s|\
 friendlyarm,nanopi-r4s|\
 friendlyarm,nanopi-r4se|\
 friendlyarm,nanopi-r4s-enterprise|\
+friendlyarm,nanopi-r6c|\
 xunlong,orangepi-r1-plus|\
 xunlong,orangepi-r1-plus-lts)
 	ucidef_set_led_netdev "wan" "WAN" "green:wan" "eth0"
diff --git a/target/linux/rockchip/armv8/base-files/etc/board.d/02_network b/target/linux/rockchip/armv8/base-files/etc/board.d/02_network
index dbf44bd2ebc..1ce5b460e3c 100644
--- a/target/linux/rockchip/armv8/base-files/etc/board.d/02_network
+++ b/target/linux/rockchip/armv8/base-files/etc/board.d/02_network
@@ -15,6 +15,7 @@ rockchip_setup_interfaces()
 	friendlyarm,nanopi-r4s|\
 	friendlyarm,nanopi-r4se|\
 	friendlyarm,nanopi-r4s-enterprise|\
+	friendlyarm,nanopi-r6c|\
 	radxa,rockpi-e|\
 	xunlong,orangepi-r1-plus|\
 	xunlong,orangepi-r1-plus-lts)
@@ -59,6 +60,7 @@ rockchip_setup_macs()
 	friendlyarm,nanopi-r4s|\
 	friendlyarm,nanopi-r5c|\
 	friendlyarm,nanopi-r5s|\
+	friendlyarm,nanopi-r6c|\
 	friendlyarm,nanopi-r6s)
 		wan_mac=$(macaddr_generate_from_mmc_cid mmcblk1)
 		lan_mac=$(macaddr_add "$wan_mac" 1)
diff --git a/target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity b/target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
index 23dc213dea2..d0b6cb39a60 100644
--- a/target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
+++ b/target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
@@ -32,6 +32,7 @@ case "$(board_name)" in
 ezpro,mrkaio-m68s|\
 firefly,rk3568-roc-pc|\
 friendlyarm,nanopi-r5c|\
+friendlyarm,nanopi-r6c|\
 lunzn,fastrhino-r66s)
 	set_interface_core 2 "eth0"
 	set_interface_core 4 "eth1"
diff --git a/target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3588s-nanopi-r6c.dts b/target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3588s-nanopi-r6c.dts
new file mode 100644
index 00000000000..db8cb164fd6
--- /dev/null
+++ b/target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3588s-nanopi-r6c.dts
@@ -0,0 +1,27 @@
+// SPDX-License-Identifier: GPL-2.0-or-later OR MIT
+
+/dts-v1/;
+#include "rk3588s-nanopi-r6s.dts"
+
+/ {
+	model = "FriendlyElec NanoPi R6C";
+	compatible = "friendlyarm,nanopi-r6c", "rockchip,rk3588";
+
+	gpio-leds {
+		led-lan1 {
+			label = "green:lan";
+		};
+
+		led-lan2 {
+			label = "green:user";
+		};
+	};
+};
+
+&pcie2x1l1 {
+	/delete-node/ pcie@0,0;
+};
+
+&pcie2x1l2 {
+	/delete-node/ pcie@0,0;
+};
diff --git a/target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3588s-nanopi-r6s.dts b/target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3588s-nanopi-r6s.dts
index 1bb8336eeed..8ee4c1ea46d 100644
--- a/target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3588s-nanopi-r6s.dts
+++ b/target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3588s-nanopi-r6s.dts
@@ -14,8 +14,8 @@
 #include <dt-bindings/input/input.h>
 #include <dt-bindings/leds/common.h>
 #include <dt-bindings/pinctrl/rockchip.h>
+#include <dt-bindings/usb/pd.h>
 #include "rk3588s.dtsi"
-#include "rk3588-rk806-single.dtsi"
 
 / {
 	model = "FriendlyElec NanoPi R6S";
@@ -377,6 +377,189 @@
 	status = "okay";
 };
 
+&spi2 {
+	status = "okay";
+	assigned-clocks = <&cru CLK_SPI2>;
+	assigned-clock-rates = <200000000>;
+	pinctrl-names = "default";
+	pinctrl-0 = <&spi2m2_cs0 &spi2m2_pins>;
+	num-cs = <1>;
+
+	rk806single: rk806single@0 {
+		compatible = "rockchip,rk806";
+		spi-max-frequency = <1000000>;
+		reg = <0x0>;
+
+		interrupt-parent = <&gpio0>;
+		interrupts = <7 IRQ_TYPE_LEVEL_LOW>;
+
+		pinctrl-names = "default";
+		pinctrl-0 = <&pmic_pins>, <&rk806_dvs1_null>, <&rk806_dvs2_null>, <&rk806_dvs3_null>;
+
+		vcc1-supply = <&vcc5v0_sys>;
+		vcc2-supply = <&vcc5v0_sys>;
+		vcc3-supply = <&vcc5v0_sys>;
+		vcc4-supply = <&vcc5v0_sys>;
+		vcc5-supply = <&vcc5v0_sys>;
+		vcc6-supply = <&vcc5v0_sys>;
+		vcc7-supply = <&vcc5v0_sys>;
+		vcc8-supply = <&vcc5v0_sys>;
+		vcc9-supply = <&vcc5v0_sys>;
+		vcc10-supply = <&vcc5v0_sys>;
+		vcc11-supply = <&vcc_2v0_pldo_s3>;
+		vcc12-supply = <&vcc5v0_sys>;
+		vcc13-supply = <&vcc_1v1_nldo_s3>;
+		vcc14-supply = <&vcc_1v1_nldo_s3>;
+		vcca-supply = <&vcc5v0_sys>;
+
+		gpio-controller;
+		#gpio-cells = <2>;
+
+		rk806_dvs1_null: dvs1-null-pins {
+			pins = "gpio_pwrctrl2";
+			function = "pin_fun0";
+		};
+
+		rk806_dvs1_slp: dvs1-slp-pins {
+			pins = "gpio_pwrctrl1";
+			function = "pin_fun1";
+		};
+
+		rk806_dvs1_pwrdn: dvs1-pwrdn-pins {
+			pins = "gpio_pwrctrl1";
+			function = "pin_fun2";
+		};
+
+		rk806_dvs1_rst: dvs1-rst-pins {
+			pins = "gpio_pwrctrl1";
+			function = "pin_fun3";
+		};
+
+		rk806_dvs2_null: dvs2-null-pins {
+			pins = "gpio_pwrctrl2";
+			function = "pin_fun0";
+		};
+
+		rk806_dvs2_slp: dvs2-slp-pins {
+			pins = "gpio_pwrctrl2";
+			function = "pin_fun1";
+		};
+
+		rk806_dvs2_pwrdn: dvs2-pwrdn-pins {
+			pins = "gpio_pwrctrl2";
+			function = "pin_fun2";
+		};
+
+		rk806_dvs2_rst: dvs2-rst-pins {
+			pins = "gpio_pwrctrl2";
+			function = "pin_fun3";
+		};
+
+		rk806_dvs2_dvs: dvs2-dvs-pins {
+			pins = "gpio_pwrctrl2";
+			function = "pin_fun4";
+		};
+
+		rk806_dvs2_gpio: dvs2-gpio-pins {
+			pins = "gpio_pwrctrl2";
+			function = "pin_fun5";
+		};
+
+		rk806_dvs3_null: dvs3-null-pins {
+			pins = "gpio_pwrctrl3";
+			function = "pin_fun0";
+		};
+
+		rk806_dvs3_slp: dvs3-slp-pins {
+			pins = "gpio_pwrctrl3";
+			function = "pin_fun1";
+		};
+
+		rk806_dvs3_pwrdn: dvs3-pwrdn-pins {
+			pins = "gpio_pwrctrl3";
+			function = "pin_fun2";
+		};
+
+		rk806_dvs3_rst: dvs3-rst-pins {
+			pins = "gpio_pwrctrl3";
+			function = "pin_fun3";
+		};
+
+		rk806_dvs3_dvs: dvs3-dvs-pins {
+			pins = "gpio_pwrctrl3";
+			function = "pin_fun4";
+		};
+
+		rk806_dvs3_gpio: dvs3-gpio-pins {
+			pins = "gpio_pwrctrl3";
+			function = "pin_fun5";
+		};
+
+		regulators {
+			vdd_cpu_lit_s0: vdd_cpu_lit_mem_s0: dcdc-reg2 {
+				regulator-always-on;
+				regulator-boot-on;
+				regulator-min-microvolt = <550000>;
+				regulator-max-microvolt = <950000>;
+				regulator-ramp-delay = <12500>;
+				regulator-name = "vdd_cpu_lit_s0";
+				regulator-state-mem {
+					regulator-off-in-suspend;
+				};
+			};
+
+			vcc_2v0_pldo_s3: dcdc-reg7 {
+				regulator-always-on;
+				regulator-boot-on;
+				regulator-min-microvolt = <2000000>;
+				regulator-max-microvolt = <2000000>;
+				regulator-ramp-delay = <12500>;
+				regulator-name = "vdd_2v0_pldo_s3";
+				regulator-state-mem {
+					regulator-on-in-suspend;
+					regulator-suspend-microvolt = <2000000>;
+				};
+			};
+
+			vcc_3v3_s3: dcdc-reg8 {
+				regulator-always-on;
+				regulator-boot-on;
+				regulator-min-microvolt = <3300000>;
+				regulator-max-microvolt = <3300000>;
+				regulator-name = "vcc_3v3_s3";
+				regulator-state-mem {
+					regulator-on-in-suspend;
+					regulator-suspend-microvolt = <3300000>;
+				};
+			};
+
+			vcc_3v3_s0: pldo-reg4 {
+				regulator-always-on;
+				regulator-boot-on;
+				regulator-min-microvolt = <3300000>;
+				regulator-max-microvolt = <3300000>;
+				regulator-ramp-delay = <12500>;
+				regulator-name = "vcc_3v3_s0";
+				regulator-state-mem {
+					regulator-off-in-suspend;
+				};
+			};
+
+			vccio_sd_s0: pldo-reg5 {
+				regulator-always-on;
+				regulator-boot-on;
+				regulator-min-microvolt = <1800000>;
+				regulator-max-microvolt = <3300000>;
+				regulator-ramp-delay = <12500>;
+				regulator-name = "vccio_sd_s0";
+				regulator-state-mem {
+					regulator-off-in-suspend;
+				};
+			};
+		};
+	};
+};
+
 &tsadc {
 	status = "okay";
 };
diff --git a/target/linux/rockchip/image/armv8.mk b/target/linux/rockchip/image/armv8.mk
index 80dc23ee6f5..03feea502d1 100644
--- a/target/linux/rockchip/image/armv8.mk
+++ b/target/linux/rockchip/image/armv8.mk
@@ -111,6 +111,15 @@ define Device/friendlyarm_nanopi-r5s
 endef
 TARGET_DEVICES += friendlyarm_nanopi-r5s
 
+define Device/friendlyarm_nanopi-r6c
+  DEVICE_VENDOR := FriendlyARM
+  DEVICE_MODEL := NanoPi R6C
+  SOC := rk3588s
+  BOOT_FLOW := pine64-img
+  DEVICE_PACKAGES := kmod-r8125
+endef
+TARGET_DEVICES += friendlyarm_nanopi-r6c
+
 define Device/friendlyarm_nanopi-r6s
   DEVICE_VENDOR := FriendlyARM
   DEVICE_MODEL := NanoPi R6S
diff --git a/target/linux/rockchip/patches-6.1/116-01-arm64-dts-rockchip-Add-RK806-regulator-config.patch b/target/linux/rockchip/patches-6.1/116-01-arm64-dts-rockchip-Add-RK806-regulator-config.patch
deleted file mode 100644
index 700fde25e11..00000000000
--- a/target/linux/rockchip/patches-6.1/116-01-arm64-dts-rockchip-Add-RK806-regulator-config.patch
+++ /dev/null
@@ -1,196 +0,0 @@
-From 4007f264822a4dc2528e9612900699d59616e00e Mon Sep 17 00:00:00 2001
-From: Lucas Tanure <lucas.tanure@collabora.com>
-Date: Mon, 9 Jan 2023 16:37:23 +0000
-Subject: [PATCH] arm64: dts: rockchip: Add RK806 regulator config
-
-Add support for rk806 single configuration PMIC in Rock Pi 5A and 5B.
-
-Signed-off-by: Lucas Tanure <lucas.tanure@collabora.com>
-Signed-off-by: Sebastian Reichel <sebastian.reichel@collabora.com>
----
- .../dts/rockchip/rk3588-rk806-single.dtsi     | 179 ++++++++++++++++++
- 1 file changed, 179 insertions(+)
- create mode 100644 arch/arm64/boot/dts/rockchip/rk3588-rk806-single.dtsi
-
---- /dev/null
-+++ b/arch/arm64/boot/dts/rockchip/rk3588-rk806-single.dtsi
-@@ -0,0 +1,179 @@
-+// SPDX-License-Identifier: (GPL-2.0+ OR MIT)
-+/*
-+ * Copyright (c) 2021 Rockchip Electronics Co., Ltd.
-+ *
-+ */
-+
-+#include <dt-bindings/gpio/gpio.h>
-+#include <dt-bindings/pinctrl/rockchip.h>
-+
-+&spi2 {
-+	status = "okay";
-+	assigned-clocks = <&cru CLK_SPI2>;
-+	assigned-clock-rates = <200000000>;
-+	pinctrl-names = "default";
-+	pinctrl-0 = <&spi2m2_cs0 &spi2m2_pins>;
-+	num-cs = <1>;
-+
-+	rk806single: rk806single@0 {
-+		compatible = "rockchip,rk806";
-+		spi-max-frequency = <1000000>;
-+		reg = <0x0>;
-+
-+		interrupt-parent = <&gpio0>;
-+		interrupts = <7 IRQ_TYPE_LEVEL_LOW>;
-+
-+		pinctrl-names = "default";
-+		pinctrl-0 = <&pmic_pins>, <&rk806_dvs1_null>, <&rk806_dvs2_null>, <&rk806_dvs3_null>;
-+
-+		vcc1-supply = <&vcc5v0_sys>;
-+		vcc2-supply = <&vcc5v0_sys>;
-+		vcc3-supply = <&vcc5v0_sys>;
-+		vcc4-supply = <&vcc5v0_sys>;
-+		vcc5-supply = <&vcc5v0_sys>;
-+		vcc6-supply = <&vcc5v0_sys>;
-+		vcc7-supply = <&vcc5v0_sys>;
-+		vcc8-supply = <&vcc5v0_sys>;
-+		vcc9-supply = <&vcc5v0_sys>;
-+		vcc10-supply = <&vcc5v0_sys>;
-+		vcc11-supply = <&vcc_2v0_pldo_s3>;
-+		vcc12-supply = <&vcc5v0_sys>;
-+		vcc13-supply = <&vcc_1v1_nldo_s3>;
-+		vcc14-supply = <&vcc_1v1_nldo_s3>;
-+		vcca-supply = <&vcc5v0_sys>;
-+
-+		gpio-controller;
-+		#gpio-cells = <2>;
-+
-+		rk806_dvs1_null: dvs1-null-pins {
-+			pins = "gpio_pwrctrl2";
-+			function = "pin_fun0";
-+		};
-+
-+		rk806_dvs1_slp: dvs1-slp-pins {
-+			pins = "gpio_pwrctrl1";
-+			function = "pin_fun1";
-+		};
-+
-+		rk806_dvs1_pwrdn: dvs1-pwrdn-pins {
-+			pins = "gpio_pwrctrl1";
-+			function = "pin_fun2";
-+		};
-+
-+		rk806_dvs1_rst: dvs1-rst-pins {
-+			pins = "gpio_pwrctrl1";
-+			function = "pin_fun3";
-+		};
-+
-+		rk806_dvs2_null: dvs2-null-pins {
-+			pins = "gpio_pwrctrl2";
-+			function = "pin_fun0";
-+		};
-+
-+		rk806_dvs2_slp: dvs2-slp-pins {
-+			pins = "gpio_pwrctrl2";
-+			function = "pin_fun1";
-+		};
-+
-+		rk806_dvs2_pwrdn: dvs2-pwrdn-pins {
-+			pins = "gpio_pwrctrl2";
-+			function = "pin_fun2";
-+		};
-+
-+		rk806_dvs2_rst: dvs2-rst-pins {
-+			pins = "gpio_pwrctrl2";
-+			function = "pin_fun3";
-+		};
-+
-+		rk806_dvs2_dvs: dvs2-dvs-pins {
-+			pins = "gpio_pwrctrl2";
-+			function = "pin_fun4";
-+		};
-+
-+		rk806_dvs2_gpio: dvs2-gpio-pins {
-+			pins = "gpio_pwrctrl2";
-+			function = "pin_fun5";
-+		};
-+
-+		rk806_dvs3_null: dvs3-null-pins {
-+			pins = "gpio_pwrctrl3";
-+			function = "pin_fun0";
-+		};
-+
-+		rk806_dvs3_slp: dvs3-slp-pins {
-+			pins = "gpio_pwrctrl3";
-+			function = "pin_fun1";
-+		};
-+
-+		rk806_dvs3_pwrdn: dvs3-pwrdn-pins {
-+			pins = "gpio_pwrctrl3";
-+			function = "pin_fun2";
-+		};
-+
-+		rk806_dvs3_rst: dvs3-rst-pins {
-+			pins = "gpio_pwrctrl3";
-+			function = "pin_fun3";
-+		};
-+
-+		rk806_dvs3_dvs: dvs3-dvs-pins {
-+			pins = "gpio_pwrctrl3";
-+			function = "pin_fun4";
-+		};
-+
-+		rk806_dvs3_gpio: dvs3-gpio-pins {
-+			pins = "gpio_pwrctrl3";
-+			function = "pin_fun5";
-+		};
-+
-+		regulators {
-+			vcc_2v0_pldo_s3: dcdc-reg7 {
-+				regulator-always-on;
-+				regulator-boot-on;
-+				regulator-min-microvolt = <2000000>;
-+				regulator-max-microvolt = <2000000>;
-+				regulator-ramp-delay = <12500>;
-+				regulator-name = "vdd_2v0_pldo_s3";
-+				regulator-state-mem {
-+					regulator-on-in-suspend;
-+					regulator-suspend-microvolt = <2000000>;
-+				};
-+			};
-+
-+			vcc_3v3_s3: dcdc-reg8 {
-+				regulator-always-on;
-+				regulator-boot-on;
-+				regulator-min-microvolt = <3300000>;
-+				regulator-max-microvolt = <3300000>;
-+				regulator-name = "vcc_3v3_s3";
-+				regulator-state-mem {
-+					regulator-on-in-suspend;
-+					regulator-suspend-microvolt = <3300000>;
-+				};
-+			};
-+
-+			vcc_3v3_s0: pldo-reg4 {
-+				regulator-always-on;
-+				regulator-boot-on;
-+				regulator-min-microvolt = <3300000>;
-+				regulator-max-microvolt = <3300000>;
-+				regulator-ramp-delay = <12500>;
-+				regulator-name = "vcc_3v3_s0";
-+				regulator-state-mem {
-+					regulator-off-in-suspend;
-+				};
-+			};
-+
-+			vccio_sd_s0: pldo-reg5 {
-+				regulator-always-on;
-+				regulator-boot-on;
-+				regulator-min-microvolt = <1800000>;
-+				regulator-max-microvolt = <3300000>;
-+				regulator-ramp-delay = <12500>;
-+				regulator-name = "vccio_sd_s0";
-+				regulator-state-mem {
-+					regulator-off-in-suspend;
-+				};
-+			};
-+		};
-+	};
-+};
diff --git a/target/linux/rockchip/patches-6.1/116-04-arm64-dts-rockchip-Add-missing-regulator-config.patch b/target/linux/rockchip/patches-6.1/116-04-arm64-dts-rockchip-Add-missing-regulator-config.patch
deleted file mode 100644
index 1ac1c9bf296..00000000000
--- a/target/linux/rockchip/patches-6.1/116-04-arm64-dts-rockchip-Add-missing-regulator-config.patch
+++ /dev/null
@@ -1,21 +0,0 @@
---- a/arch/arm64/boot/dts/rockchip/rk3588-rk806-single.dtsi
-+++ b/arch/arm64/boot/dts/rockchip/rk3588-rk806-single.dtsi
-@@ -126,6 +126,18 @@
- 		};
- 
- 		regulators {
-+			vdd_cpu_lit_s0: vdd_cpu_lit_mem_s0: dcdc-reg2 {
-+				regulator-always-on;
-+				regulator-boot-on;
-+				regulator-min-microvolt = <550000>;
-+				regulator-max-microvolt = <950000>;
-+				regulator-ramp-delay = <12500>;
-+				regulator-name = "vdd_cpu_lit_s0";
-+				regulator-state-mem {
-+					regulator-off-in-suspend;
-+				};
-+			};
-+
- 			vcc_2v0_pldo_s3: dcdc-reg7 {
- 				regulator-always-on;
- 				regulator-boot-on;
diff --git a/target/linux/rockchip/patches-6.1/210-rockchip-rk356x-add-support-for-new-boards.patch b/target/linux/rockchip/patches-6.1/210-rockchip-rk356x-add-support-for-new-boards.patch
index 6405cecf72d..02f5f46da26 100644
--- a/target/linux/rockchip/patches-6.1/210-rockchip-rk356x-add-support-for-new-boards.patch
+++ b/target/linux/rockchip/patches-6.1/210-rockchip-rk356x-add-support-for-new-boards.patch
@@ -16,7 +16,7 @@
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3399-nanopi-r4s-enterprise.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3399-orangepi.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3399-pinebook-pro.dtb
-@@ -77,10 +79,12 @@ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-bp
+@@ -77,10 +79,13 @@ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-bp
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-evb1-v10.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-fastrhino-r66s.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-fastrhino-r68s.dtb
@@ -27,5 +27,6 @@
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-rock-3a.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-evb1-v10.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-rock-5b.dtb
++dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588s-nanopi-r6c.dtb
 +dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588s-nanopi-r6s.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588s-rock-5a.dtb
