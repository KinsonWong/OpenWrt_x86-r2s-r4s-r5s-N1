From 32ea24c8cbe20664e91630335144483d1ec3c777 Mon Sep 17 00:00:00 2001
From: Tianling Shen <cnsztl@immortalwrt.org>
Date: Fri, 26 Jan 2024 17:46:26 +0800
Subject: [PATCH] rockchip: add OrangePi 5 (Plus) support

Signed-off-by: Tianling Shen <cnsztl@immortalwrt.org>
---
 .../armv8/base-files/etc/board.d/02_network   |   6 +-
 target/linux/rockchip/image/armv8.mk          |  17 +
 ...7-arm64-dts-rockchip-Add-Orange-Pi-5.patch | 693 ++++++++++++++
 ...-add-USB3-host-on-rk3588s-orangepi-5.patch |  24 +
 ...chip-Support-poweroff-on-Orange-Pi-5.patch |  25 +
 ...s-rockchip-Add-board-device-tree-for.patch | 897 ++++++++++++++++++
 ...-rockchip-use-system-LED-for-OpenWrt.patch |  49 +
 .../210-rockchip-rk356x-add-support-for-new-boards.patch        |   5 +-
 8 files changed, 1712 insertions(+), 4 deletions(-)
 create mode 100644 target/linux/rockchip/patches-6.1/055-01-v6.7-arm64-dts-rockchip-Add-Orange-Pi-5.patch
 create mode 100644 target/linux/rockchip/patches-6.1/055-02-v6.8-arm64-dts-rockchip-add-USB3-host-on-rk3588s-orangepi-5.patch
 create mode 100644 target/linux/rockchip/patches-6.1/055-03-v6.8-arm64-dts-rockchip-Support-poweroff-on-Orange-Pi-5.patch
 create mode 100644 target/linux/rockchip/patches-6.1/056-01-v6.7-arm64-dts-rockchip-Add-board-device-tree-for.patch

diff --git a/target/linux/rockchip/armv8/base-files/etc/board.d/02_network b/target/linux/rockchip/armv8/base-files/etc/board.d/02_network
index 1f3d8ef8336..ba90653e312 100644
--- a/target/linux/rockchip/armv8/base-files/etc/board.d/02_network
+++ b/target/linux/rockchip/armv8/base-files/etc/board.d/02_network
@@ -25,7 +25,8 @@ rockchip_setup_interfaces()
 		ucidef_set_interfaces_lan_wan 'eth1' 'eth2'
 		;;
 	friendlyarm,nanopi-r5c|\
-	lunzn,fastrhino-r66s)
+	lunzn,fastrhino-r66s|\
+	xunlong,orangepi-5-plus)
 		ucidef_set_interfaces_lan_wan 'eth0' 'eth1'
 		;;
 	friendlyarm,nanopi-r5s)
@@ -61,7 +62,8 @@ rockchip_setup_macs()
 		lan_mac=$(macaddr_add "$wan_mac" 1)
 		;;
 	friendlyarm,nanopi-r5c|\
-	friendlyarm,nanopi-r6c)
+	friendlyarm,nanopi-r6c|\
+	xunlong,orangepi-5-plus)
 		wan_mac=$(macaddr_generate_from_mmc_cid mmcblk*)
 		lan_mac=$(macaddr_add "$wan_mac" 1)
 		;;
diff --git a/target/linux/rockchip/image/armv8.mk b/target/linux/rockchip/image/armv8.mk
index 3f31907657d..ec2dadf561a 100644
--- a/target/linux/rockchip/image/armv8.mk
+++ b/target/linux/rockchip/image/armv8.mk
@@ -239,6 +239,23 @@ define Device/radxa_rock-pi-e
 endef
 TARGET_DEVICES += radxa_rock-pi-e
 
+define Device/xunlong_orangepi-5
+  DEVICE_VENDOR := Xunlong
+  DEVICE_MODEL := Orange Pi 5
+  SOC := rk3588s
+  BOOT_FLOW := pine64-img
+endef
+TARGET_DEVICES += xunlong_orangepi-5
+
+define Device/xunlong_orangepi-5-plus
+  DEVICE_VENDOR := Xunlong
+  DEVICE_MODEL := Orange Pi 5 Plus
+  SOC := rk3588
+  BOOT_FLOW := pine64-img
+  DEVICE_PACKAGES := kmod-r8125
+endef
+TARGET_DEVICES += xunlong_orangepi-5-plus
+
 define Device/xunlong_orangepi-r1-plus
   DEVICE_VENDOR := Xunlong
   DEVICE_MODEL := Orange Pi R1 Plus
diff --git a/target/linux/rockchip/patches-6.1/055-01-v6.7-arm64-dts-rockchip-Add-Orange-Pi-5.patch b/target/linux/rockchip/patches-6.1/055-01-v6.7-arm64-dts-rockchip-Add-Orange-Pi-5.patch
new file mode 100644
index 00000000000..47269a3af27
--- /dev/null
+++ b/target/linux/rockchip/patches-6.1/055-01-v6.7-arm64-dts-rockchip-Add-Orange-Pi-5.patch
@@ -0,0 +1,693 @@
+From b6bc755d806eac3fbddb7ea278fc7d2eb57dba4a Mon Sep 17 00:00:00 2001
+From: Muhammed Efe Cetin <efectn@6tel.net>
+Date: Mon, 9 Oct 2023 22:27:27 +0300
+Subject: [PATCH] arm64: dts: rockchip: Add Orange Pi 5
+MIME-Version: 1.0
+Content-Type: text/plain; charset=UTF-8
+Content-Transfer-Encoding: 8bit
+
+Add initial support for OPi5 that includes support for USB2, PCIe2, Sata,
+Sdmmc, SPI Flash, PMIC.
+
+Signed-off-by: Muhammed Efe Cetin <efectn@6tel.net>
+Reviewed-by: Ondřej Jirman <megi@xff.cz>
+Link: https://lore.kernel.org/r/4212da199c9c532b60d380bf1dfa83490e16bc13.1696878787.git.efectn@6tel.net
+Signed-off-by: Heiko Stuebner <heiko@sntech.de>
+---
+ arch/arm64/boot/dts/rockchip/Makefile         |   1 +
+ .../boot/dts/rockchip/rk3588s-orangepi-5.dts  | 662 ++++++++++++++++++
+ 2 files changed, 663 insertions(+)
+ create mode 100644 arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts
+
+--- a/arch/arm64/boot/dts/rockchip/Makefile
++++ b/arch/arm64/boot/dts/rockchip/Makefile
+@@ -85,3 +85,4 @@ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-ev
+ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-nanopc-t6.dtb
+ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-rock-5b.dtb
+ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588s-rock-5a.dtb
++dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588s-orangepi-5.dtb
+--- /dev/null
++++ b/arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts
+@@ -0,0 +1,662 @@
++// SPDX-License-Identifier: (GPL-2.0+ OR MIT)
++
++/dts-v1/;
++
++#include <dt-bindings/gpio/gpio.h>
++#include <dt-bindings/leds/common.h>
++#include <dt-bindings/input/input.h>
++#include <dt-bindings/pinctrl/rockchip.h>
++#include "rk3588s.dtsi"
++
++/ {
++	model = "Xunlong Orange Pi 5";
++	compatible = "xunlong,orangepi-5", "rockchip,rk3588s";
++
++	aliases {
++		mmc0 = &sdmmc;
++		serial2 = &uart2;
++	};
++
++	chosen {
++		stdout-path = "serial2:1500000n8";
++	};
++
++	adc-keys {
++		compatible = "adc-keys";
++		io-channels = <&saradc 1>;
++		io-channel-names = "buttons";
++		keyup-threshold-microvolt = <1800000>;
++		poll-interval = <100>;
++
++		button-recovery {
++			label = "Recovery";
++			linux,code = <KEY_VENDOR>;
++			press-threshold-microvolt = <1800>;
++		};
++	};
++
++	leds {
++		compatible = "gpio-leds";
++		pinctrl-names = "default";
++		pinctrl-0 =<&leds_gpio>;
++
++		led-1 {
++			gpios = <&gpio1 RK_PA2 GPIO_ACTIVE_HIGH>;
++			label = "status_led";
++			linux,default-trigger = "heartbeat";
++		};
++	};
++
++	vbus_typec: vbus-typec-regulator {
++		compatible = "regulator-fixed";
++		enable-active-high;
++		gpio = <&gpio3 RK_PC0 GPIO_ACTIVE_HIGH>;
++		pinctrl-names = "default";
++		pinctrl-0 = <&typec5v_pwren>;
++		regulator-name = "vbus_typec";
++		regulator-min-microvolt = <5000000>;
++		regulator-max-microvolt = <5000000>;
++		vin-supply = <&vcc5v0_sys>;
++	};
++
++	vcc5v0_sys: vcc5v0-sys-regulator {
++		compatible = "regulator-fixed";
++		regulator-name = "vcc5v0_sys";
++		regulator-always-on;
++		regulator-boot-on;
++		regulator-min-microvolt = <5000000>;
++		regulator-max-microvolt = <5000000>;
++	};
++
++	vcc_3v3_sd_s0: vcc-3v3-sd-s0-regulator {
++		compatible = "regulator-fixed";
++		enable-active-low;
++		gpios = <&gpio4 RK_PB5 GPIO_ACTIVE_LOW>;
++		regulator-name = "vcc_3v3_sd_s0";
++		regulator-boot-on;
++		regulator-min-microvolt = <3300000>;
++		regulator-max-microvolt = <3300000>;
++		vin-supply = <&vcc_3v3_s3>;
++	};
++
++	vcc3v3_pcie20: vcc3v3-pcie20-regulator {
++		compatible = "regulator-fixed";
++		enable-active-high;
++		gpios = <&gpio0 RK_PC5 GPIO_ACTIVE_HIGH>;
++		regulator-name = "vcc3v3_pcie20";
++		regulator-boot-on;
++		regulator-min-microvolt = <1800000>;
++		regulator-max-microvolt = <1800000>;
++		startup-delay-us = <50000>;
++		vin-supply = <&vcc5v0_sys>;
++	};
++};
++
++&combphy0_ps {
++	status = "okay";
++};
++
++&combphy2_psu {
++	status = "okay";
++};
++
++&cpu_b0 {
++	cpu-supply = <&vdd_cpu_big0_s0>;
++};
++
++&cpu_b1 {
++	cpu-supply = <&vdd_cpu_big0_s0>;
++};
++
++&cpu_b2 {
++	cpu-supply = <&vdd_cpu_big1_s0>;
++};
++
++&cpu_b3 {
++	cpu-supply = <&vdd_cpu_big1_s0>;
++};
++
++&cpu_l0 {
++	cpu-supply = <&vdd_cpu_lit_s0>;
++};
++
++&cpu_l1 {
++	cpu-supply = <&vdd_cpu_lit_s0>;
++};
++
++&cpu_l2 {
++	cpu-supply = <&vdd_cpu_lit_s0>;
++};
++
++&cpu_l3 {
++	cpu-supply = <&vdd_cpu_lit_s0>;
++};
++
++&gmac1 {
++	clock_in_out = "output";
++	phy-handle = <&rgmii_phy1>;
++	phy-mode = "rgmii-rxid";
++	pinctrl-0 = <&gmac1_miim
++		     &gmac1_tx_bus2
++		     &gmac1_rx_bus2
++		     &gmac1_rgmii_clk
++		     &gmac1_rgmii_bus>;
++	pinctrl-names = "default";
++	tx_delay = <0x42>;
++	status = "okay";
++};
++
++&i2c0 {
++	pinctrl-names = "default";
++	pinctrl-0 = <&i2c0m2_xfer>;
++	status = "okay";
++
++	vdd_cpu_big0_s0: regulator@42 {
++		compatible = "rockchip,rk8602";
++		reg = <0x42>;
++		fcs,suspend-voltage-selector = <1>;
++		regulator-name = "vdd_cpu_big0_s0";
++		regulator-always-on;
++		regulator-boot-on;
++		regulator-min-microvolt = <550000>;
++		regulator-max-microvolt = <1050000>;
++		regulator-ramp-delay = <2300>;
++		vin-supply = <&vcc5v0_sys>;
++
++		regulator-state-mem {
++			regulator-off-in-suspend;
++		};
++	};
++
++	vdd_cpu_big1_s0: regulator@43 {
++		compatible = "rockchip,rk8603", "rockchip,rk8602";
++		reg = <0x43>;
++		fcs,suspend-voltage-selector = <1>;
++		regulator-name = "vdd_cpu_big1_s0";
++		regulator-always-on;
++		regulator-boot-on;
++		regulator-min-microvolt = <550000>;
++		regulator-max-microvolt = <1050000>;
++		regulator-ramp-delay = <2300>;
++		vin-supply = <&vcc5v0_sys>;
++
++		regulator-state-mem {
++			regulator-off-in-suspend;
++		};
++	};
++};
++
++&i2c2 {
++	status = "okay";
++
++	vdd_npu_s0: regulator@42 {
++		compatible = "rockchip,rk8602";
++		reg = <0x42>;
++		fcs,suspend-voltage-selector = <1>;
++		regulator-name = "vdd_npu_s0";
++		regulator-always-on;
++		regulator-boot-on;
++		regulator-min-microvolt = <550000>;
++		regulator-max-microvolt = <950000>;
++		regulator-ramp-delay = <2300>;
++		vin-supply = <&vcc5v0_sys>;
++
++		regulator-state-mem {
++			regulator-off-in-suspend;
++		};
++	};
++};
++
++&i2c6 {
++	pinctrl-names = "default";
++	pinctrl-0 = <&i2c6m3_xfer>;
++	status = "okay";
++
++	hym8563: rtc@51 {
++		compatible = "haoyu,hym8563";
++		reg = <0x51>;
++		#clock-cells = <0>;
++		clock-output-names = "hym8563";
++		pinctrl-names = "default";
++		pinctrl-0 = <&hym8563_int>;
++		interrupt-parent = <&gpio0>;
++		interrupts = <RK_PB0 IRQ_TYPE_LEVEL_LOW>;
++		wakeup-source;
++	};
++};
++
++&mdio1 {
++	rgmii_phy1: ethernet-phy@1 {
++		compatible = "ethernet-phy-ieee802.3-c22";
++		reg = <0x1>;
++		reset-assert-us = <20000>;
++		reset-deassert-us = <100000>;
++		reset-gpios = <&gpio3 RK_PB2 GPIO_ACTIVE_LOW>;
++	};
++};
++
++&pcie2x1l2 {
++	reset-gpios = <&gpio3 RK_PD1 GPIO_ACTIVE_HIGH>;
++	vpcie3v3-supply = <&vcc3v3_pcie20>;
++	status = "okay";
++};
++
++&pinctrl {
++	gpio-func {
++		leds_gpio: leds-gpio {
++			rockchip,pins = <0 RK_PA2 RK_FUNC_GPIO &pcfg_pull_none>;
++		};
++	};
++
++	hym8563 {
++		hym8563_int: hym8563-int {
++			rockchip,pins = <0 RK_PB0 RK_FUNC_GPIO &pcfg_pull_none>;
++		};
++	};
++
++	usb-typec {
++		usbc0_int: usbc0-int {
++			rockchip,pins = <0 RK_PD3 RK_FUNC_GPIO &pcfg_pull_up>;
++		};
++
++		typec5v_pwren: typec5v-pwren {
++			rockchip,pins = <3 RK_PC0 RK_FUNC_GPIO &pcfg_pull_none>;
++		};
++	};
++};
++
++&saradc {
++	vref-supply = <&avcc_1v8_s0>;
++	status = "okay";
++};
++
++&sdmmc {
++	bus-width = <4>;
++	cap-sd-highspeed;
++	disable-wp;
++	max-frequency = <150000000>;
++	no-mmc;
++	no-sdio;
++	sd-uhs-sdr104;
++	vmmc-supply = <&vcc_3v3_sd_s0>;
++	vqmmc-supply = <&vccio_sd_s0>;
++	status = "okay";
++};
++
++&sfc {
++	pinctrl-names = "default";
++	pinctrl-0 = <&fspim0_pins>;
++	status = "okay";
++
++	flash@0 {
++		compatible = "jedec,spi-nor";
++		reg = <0x0>;
++		spi-max-frequency = <100000000>;
++		spi-rx-bus-width = <4>;
++		spi-tx-bus-width = <1>;
++	};
++};
++
++&spi2 {
++	status = "okay";
++	assigned-clocks = <&cru CLK_SPI2>;
++	assigned-clock-rates = <200000000>;
++	num-cs = <1>;
++	pinctrl-names = "default";
++	pinctrl-0 = <&spi2m2_cs0 &spi2m2_pins>;
++
++	pmic@0 {
++		compatible = "rockchip,rk806";
++		reg = <0x0>;
++		interrupt-parent = <&gpio0>;
++		interrupts = <7 IRQ_TYPE_LEVEL_LOW>;
++		pinctrl-names = "default";
++		pinctrl-0 = <&pmic_pins>, <&rk806_dvs1_null>,
++				<&rk806_dvs2_null>, <&rk806_dvs3_null>;
++		spi-max-frequency = <1000000>;
++
++		vcc1-supply = <&vcc5v0_sys>;
++		vcc2-supply = <&vcc5v0_sys>;
++		vcc3-supply = <&vcc5v0_sys>;
++		vcc4-supply = <&vcc5v0_sys>;
++		vcc5-supply = <&vcc5v0_sys>;
++		vcc6-supply = <&vcc5v0_sys>;
++		vcc7-supply = <&vcc5v0_sys>;
++		vcc8-supply = <&vcc5v0_sys>;
++		vcc9-supply = <&vcc5v0_sys>;
++		vcc10-supply = <&vcc5v0_sys>;
++		vcc11-supply = <&vcc_2v0_pldo_s3>;
++		vcc12-supply = <&vcc5v0_sys>;
++		vcc13-supply = <&vcc_1v1_nldo_s3>;
++		vcc14-supply = <&vcc_1v1_nldo_s3>;
++		vcca-supply = <&vcc5v0_sys>;
++
++		gpio-controller;
++		#gpio-cells = <2>;
++
++		rk806_dvs1_null: dvs1-null-pins {
++			pins = "gpio_pwrctrl2";
++			function = "pin_fun0";
++		};
++
++		rk806_dvs2_null: dvs2-null-pins {
++			pins = "gpio_pwrctrl2";
++			function = "pin_fun0";
++		};
++
++		rk806_dvs3_null: dvs3-null-pins {
++			pins = "gpio_pwrctrl3";
++			function = "pin_fun0";
++		};
++
++		regulators {
++			vdd_gpu_s0: dcdc-reg1 {
++				regulator-name = "vdd_gpu_s0";
++				regulator-boot-on;
++				regulator-min-microvolt = <550000>;
++				regulator-max-microvolt = <950000>;
++				regulator-ramp-delay = <12500>;
++				regulator-enable-ramp-delay = <400>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vdd_cpu_lit_s0: dcdc-reg2 {
++				regulator-name = "vdd_cpu_lit_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <550000>;
++				regulator-max-microvolt = <950000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vdd_log_s0: dcdc-reg3 {
++				regulator-name = "vdd_log_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <675000>;
++				regulator-max-microvolt = <750000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++					regulator-suspend-microvolt = <750000>;
++				};
++			};
++
++			vdd_vdenc_s0: dcdc-reg4 {
++				regulator-name = "vdd_vdenc_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <550000>;
++				regulator-max-microvolt = <950000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vdd_ddr_s0: dcdc-reg5 {
++				regulator-name = "vdd_ddr_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <675000>;
++				regulator-max-microvolt = <900000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++					regulator-suspend-microvolt = <850000>;
++				};
++			};
++
++			vcc_1v1_nldo_s3: vdd2_ddr_s3: dcdc-reg6 {
++				regulator-name = "vdd2_ddr_s3";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-max-microvolt = <1100000>;
++				regulator-min-microvolt = <1100000>;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++				};
++			};
++
++			vcc_2v0_pldo_s3: dcdc-reg7 {
++				regulator-name = "vdd_2v0_pldo_s3";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <2000000>;
++				regulator-max-microvolt = <2000000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++					regulator-suspend-microvolt = <2000000>;
++				};
++			};
++
++			vcc_3v3_s3: dcdc-reg8 {
++				regulator-name = "vcc_3v3_s3";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <3300000>;
++				regulator-max-microvolt = <3300000>;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++					regulator-suspend-microvolt = <3300000>;
++				};
++			};
++
++			vddq_ddr_s0: dcdc-reg9 {
++				regulator-name = "vddq_ddr_s0";
++				regulator-always-on;
++				regulator-boot-on;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vcc_1v8_s3: dcdc-reg10 {
++				regulator-name = "vcc_1v8_s3";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1800000>;
++				regulator-max-microvolt = <1800000>;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++					regulator-suspend-microvolt = <1800000>;
++				};
++			};
++
++			avcc_1v8_s0: pldo-reg1 {
++				regulator-name = "avcc_1v8_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1800000>;
++				regulator-max-microvolt = <1800000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vcc_1v8_s0: pldo-reg2 {
++				regulator-name = "vcc_1v8_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1800000>;
++				regulator-max-microvolt = <1800000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++					regulator-suspend-microvolt = <1800000>;
++				};
++			};
++
++			avdd_1v2_s0: pldo-reg3 {
++				regulator-name = "avdd_1v2_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1200000>;
++				regulator-max-microvolt = <1200000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vcc_3v3_s0: pldo-reg4 {
++				regulator-name = "vcc_3v3_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <3300000>;
++				regulator-max-microvolt = <3300000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vccio_sd_s0: pldo-reg5 {
++				regulator-name = "vccio_sd_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1800000>;
++				regulator-max-microvolt = <3300000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			pldo6_s3: pldo-reg6 {
++				regulator-name = "pldo6_s3";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1800000>;
++				regulator-max-microvolt = <1800000>;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++					regulator-suspend-microvolt = <1800000>;
++				};
++			};
++
++			vdd_0v75_s3: nldo-reg1 {
++				regulator-name = "vdd_0v75_s3";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <750000>;
++				regulator-max-microvolt = <750000>;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++					regulator-suspend-microvolt = <750000>;
++				};
++			};
++
++			vdd_ddr_pll_s0: nldo-reg2 {
++				regulator-name = "vdd_ddr_pll_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <850000>;
++				regulator-max-microvolt = <850000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++					regulator-suspend-microvolt = <850000>;
++				};
++			};
++
++			avdd_0v75_s0: nldo-reg3 {
++				regulator-name = "avdd_0v75_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <750000>;
++				regulator-max-microvolt = <750000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vdd_0v85_s0: nldo-reg4 {
++				regulator-name = "vdd_0v85_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <850000>;
++				regulator-max-microvolt = <850000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vdd_0v75_s0: nldo-reg5 {
++				regulator-name = "vdd_0v75_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <750000>;
++				regulator-max-microvolt = <750000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++		};
++	};
++};
++
++&tsadc {
++	status = "okay";
++};
++
++&u2phy2 {
++	status = "okay";
++};
++
++&u2phy2_host {
++	status = "okay";
++};
++
++&u2phy3 {
++	status = "okay";
++};
++
++&u2phy3_host {
++	status = "okay";
++};
++
++&uart2 {
++	pinctrl-0 = <&uart2m0_xfer>;
++	status = "okay";
++};
++
++&usb_host0_ehci {
++	status = "okay";
++};
++
++&usb_host0_ohci {
++	status = "okay";
++};
++
++&usb_host1_ehci {
++	status = "okay";
++};
++
++&usb_host1_ohci {
++	status = "okay";
++};
diff --git a/target/linux/rockchip/patches-6.1/055-02-v6.8-arm64-dts-rockchip-add-USB3-host-on-rk3588s-orangepi-5.patch b/target/linux/rockchip/patches-6.1/055-02-v6.8-arm64-dts-rockchip-add-USB3-host-on-rk3588s-orangepi-5.patch
new file mode 100644
index 00000000000..a9da2e5ccb0
--- /dev/null
+++ b/target/linux/rockchip/patches-6.1/055-02-v6.8-arm64-dts-rockchip-add-USB3-host-on-rk3588s-orangepi-5.patch
@@ -0,0 +1,24 @@
+From 9ecf44fedc17ff267968b5fff589bf6793fc7ddd Mon Sep 17 00:00:00 2001
+From: Jimmy Hon <honyuenkwun@gmail.com>
+Date: Sun, 26 Nov 2023 14:08:45 -0600
+Subject: [PATCH] arm64: dts: rockchip: add USB3 host on rk3588s-orangepi-5
+
+Enable USB3 host controller for the Orange Pi 5.
+
+Signed-off-by: Jimmy Hon <honyuenkwun@gmail.com>
+Link: https://lore.kernel.org/r/20231126200845.1192-1-honyuenkwun@gmail.com
+Signed-off-by: Heiko Stuebner <heiko@sntech.de>
+---
+ arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts | 4 ++++
+ 1 file changed, 4 insertions(+)
+
+--- a/arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts
++++ b/arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts
+@@ -660,3 +660,7 @@
+ &usb_host1_ohci {
+ 	status = "okay";
+ };
++
++&usb_host2_xhci {
++	status = "okay";
++};
diff --git a/target/linux/rockchip/patches-6.1/055-03-v6.8-arm64-dts-rockchip-Support-poweroff-on-Orange-Pi-5.patch b/target/linux/rockchip/patches-6.1/055-03-v6.8-arm64-dts-rockchip-Support-poweroff-on-Orange-Pi-5.patch
new file mode 100644
index 00000000000..86fe11bafc3
--- /dev/null
+++ b/target/linux/rockchip/patches-6.1/055-03-v6.8-arm64-dts-rockchip-Support-poweroff-on-Orange-Pi-5.patch
@@ -0,0 +1,25 @@
+From e9126f9d3c83acbc88461a535e24c949c7e0b6ca Mon Sep 17 00:00:00 2001
+From: Jimmy Hon <honyuenkwun@gmail.com>
+Date: Wed, 27 Dec 2023 14:32:11 -0600
+Subject: [PATCH] arm64: dts: rockchip: Support poweroff on Orange Pi 5
+
+The RK806 on the Orange Pi 5 can be used to power on/off the whole board.
+Mark it as the system power controller.
+
+Signed-off-by: Jimmy Hon <honyuenkwun@gmail.com>
+Link: https://lore.kernel.org/r/20231227203211.1047-1-honyuenkwun@gmail.com
+Signed-off-by: Heiko Stuebner <heiko@sntech.de>
+---
+ arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts | 1 +
+ 1 file changed, 1 insertion(+)
+
+--- a/arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts
++++ b/arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts
+@@ -314,6 +314,7 @@
+ 		pinctrl-0 = <&pmic_pins>, <&rk806_dvs1_null>,
+ 				<&rk806_dvs2_null>, <&rk806_dvs3_null>;
+ 		spi-max-frequency = <1000000>;
++		system-power-controller;
+ 
+ 		vcc1-supply = <&vcc5v0_sys>;
+ 		vcc2-supply = <&vcc5v0_sys>;
diff --git a/target/linux/rockchip/patches-6.1/056-01-v6.7-arm64-dts-rockchip-Add-board-device-tree-for.patch b/target/linux/rockchip/patches-6.1/056-01-v6.7-arm64-dts-rockchip-Add-board-device-tree-for.patch
new file mode 100644
index 00000000000..546af3c896d
--- /dev/null
+++ b/target/linux/rockchip/patches-6.1/056-01-v6.7-arm64-dts-rockchip-Add-board-device-tree-for.patch
@@ -0,0 +1,897 @@
+From 236d225e1ee72a28aa7c2b1e39894e4390bbf51c Mon Sep 17 00:00:00 2001
+From: Ondrej Jirman <megi@xff.cz>
+Date: Sun, 8 Oct 2023 15:05:02 +0200
+Subject: [PATCH] arm64: dts: rockchip: Add board device tree for
+ rk3588-orangepi-5-plus
+MIME-Version: 1.0
+Content-Type: text/plain; charset=UTF-8
+Content-Transfer-Encoding: 8bit
+
+Orange Pi 5 Plus is RK3588 based SBC featuring:
+
+- 2x 2.5G ethernet ports – onboard NIC hooked to PCIe 2.0 interface
+- 2x USB 2.0 host ports
+- 2x USB 3.0 host ports (exposed over USB 3.0 hub)
+- Type-C port featuring USB 2.0/3.0 and Alt-DP mode
+- PCIe 2.0/USB 2.0/I2S/I2C/UART on E.KEY socket
+- RTC
+- ES8388 on-board sound codec – jack in/out, onboard mic, speaker amplifier
+- SPI NOR flash
+- RGB LED (R is always on)
+- IR receiver
+- PCIe 3.0 on the bottom for NVMe, etc.
+- 40pin GPIO header (with gpio, I2C, SPI, PWM, UART)
+- Power, recovery and Mask ROM buttons
+- 2x HDMI out, 1x HDMI in
+- Slots/connectors for eMMC, uSD card, fan, MIPI CSI/DSI
+
+Signed-off-by: Ondrej Jirman <megi@xff.cz>
+Link: https://lore.kernel.org/r/20231008130515.1155664-5-megi@xff.cz
+Signed-off-by: Heiko Stuebner <heiko@sntech.de>
+---
+ arch/arm64/boot/dts/rockchip/Makefile         |   1 +
+ .../dts/rockchip/rk3588-orangepi-5-plus.dts   | 848 ++++++++++++++++++
+ 2 files changed, 849 insertions(+)
+ create mode 100644 arch/arm64/boot/dts/rockchip/rk3588-orangepi-5-plus.dts
+
+--- a/arch/arm64/boot/dts/rockchip/Makefile
++++ b/arch/arm64/boot/dts/rockchip/Makefile
+@@ -83,6 +83,7 @@ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-ro
+ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-rock-3a.dtb
+ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-evb1-v10.dtb
+ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-nanopc-t6.dtb
++dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-orangepi-5-plus.dtb
+ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-rock-5b.dtb
+ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588s-rock-5a.dtb
+ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588s-orangepi-5.dtb
+--- /dev/null
++++ b/arch/arm64/boot/dts/rockchip/rk3588-orangepi-5-plus.dts
+@@ -0,0 +1,848 @@
++// SPDX-License-Identifier: (GPL-2.0+ OR MIT)
++/*
++ * Copyright (c) 2023 Ondřej Jirman <megi@xff.cz>
++ */
++
++/dts-v1/;
++
++#include <dt-bindings/gpio/gpio.h>
++#include <dt-bindings/leds/common.h>
++#include <dt-bindings/input/input.h>
++#include <dt-bindings/pinctrl/rockchip.h>
++#include <dt-bindings/usb/pd.h>
++#include "rk3588.dtsi"
++
++/ {
++	model = "Xunlong Orange Pi 5 Plus";
++	compatible = "xunlong,orangepi-5-plus", "rockchip,rk3588";
++
++	aliases {
++		mmc0 = &sdhci;
++		mmc1 = &sdmmc;
++		serial2 = &uart2;
++	};
++
++	chosen {
++		stdout-path = "serial2:1500000n8";
++	};
++
++	adc-keys-0 {
++		compatible = "adc-keys";
++		io-channels = <&saradc 0>;
++		io-channel-names = "buttons";
++		keyup-threshold-microvolt = <1800000>;
++		poll-interval = <100>;
++
++		button-maskrom {
++			label = "Mask Rom";
++			linux,code = <KEY_SETUP>;
++			press-threshold-microvolt = <2000>;
++		};
++	};
++
++	adc-keys-1 {
++		compatible = "adc-keys";
++		io-channels = <&saradc 1>;
++		io-channel-names = "buttons";
++		keyup-threshold-microvolt = <1800000>;
++		poll-interval = <100>;
++
++		button-recovery {
++			label = "Recovery";
++			linux,code = <KEY_VENDOR>;
++			press-threshold-microvolt = <2000>;
++		};
++	};
++
++	speaker_amp: speaker-audio-amplifier {
++		compatible = "simple-audio-amplifier";
++		enable-gpios = <&gpio3 RK_PC0 GPIO_ACTIVE_HIGH>;
++		sound-name-prefix = "Speaker Amp";
++	};
++
++	headphone_amp: headphones-audio-amplifier {
++		compatible = "simple-audio-amplifier";
++		enable-gpios = <&gpio3 RK_PA7 GPIO_ACTIVE_HIGH>;
++		sound-name-prefix = "Headphones Amp";
++	};
++
++	ir-receiver {
++		compatible = "gpio-ir-receiver";
++		gpios = <&gpio4 RK_PB3 GPIO_ACTIVE_LOW>;
++		pinctrl-names = "default";
++		pinctrl-0 = <&ir_receiver_pin>;
++	};
++
++	gpio-leds {
++		compatible = "gpio-leds";
++		pinctrl-names = "default";
++		pinctrl-0 = <&blue_led_pin>;
++
++		led {
++			color = <LED_COLOR_ID_BLUE>;
++			function = LED_FUNCTION_INDICATOR;
++			function-enumerator = <1>;
++			gpios = <&gpio3 RK_PA6 GPIO_ACTIVE_HIGH>;
++		};
++	};
++
++	fan: pwm-fan {
++		compatible = "pwm-fan";
++		cooling-levels = <0 70 75 80 100>;
++		fan-supply = <&vcc5v0_sys>;
++		pwms = <&pwm3 0 50000 0>;
++		#cooling-cells = <2>;
++	};
++
++	pwm-leds {
++		compatible = "pwm-leds";
++
++		led {
++			color = <LED_COLOR_ID_GREEN>;
++			function = LED_FUNCTION_INDICATOR;
++			function-enumerator = <2>;
++			max-brightness = <255>;
++			pwms = <&pwm2 0 25000 0>;
++		};
++	};
++
++	sound {
++		compatible = "simple-audio-card";
++		pinctrl-names = "default";
++		pinctrl-0 = <&hp_detect>;
++		simple-audio-card,name = "Analog";
++		simple-audio-card,aux-devs = <&speaker_amp>, <&headphone_amp>;
++		simple-audio-card,format = "i2s";
++		simple-audio-card,mclk-fs = <256>;
++		simple-audio-card,hp-det-gpio = <&gpio1 RK_PD3 GPIO_ACTIVE_LOW>;
++		simple-audio-card,bitclock-master = <&daicpu>;
++		simple-audio-card,frame-master = <&daicpu>;
++		/*TODO: SARADC_IN3 is used as MIC detection / key input */
++
++		simple-audio-card,widgets =
++			"Microphone", "Onboard Microphone",
++			"Microphone", "Microphone Jack",
++			"Speaker", "Speaker",
++			"Headphone", "Headphones";
++
++		simple-audio-card,routing =
++			"Headphones", "LOUT1",
++			"Headphones", "ROUT1",
++			"Speaker", "LOUT2",
++			"Speaker", "ROUT2",
++
++			"Headphones", "Headphones Amp OUTL",
++			"Headphones", "Headphones Amp OUTR",
++			"Headphones Amp INL", "LOUT1",
++			"Headphones Amp INR", "ROUT1",
++
++			"Speaker", "Speaker Amp OUTL",
++			"Speaker", "Speaker Amp OUTR",
++			"Speaker Amp INL", "LOUT2",
++			"Speaker Amp INR", "ROUT2",
++
++			/* single ended signal to LINPUT1 */
++			"LINPUT1", "Microphone Jack",
++			"RINPUT1", "Microphone Jack",
++			/* differential signal */
++			"LINPUT2", "Onboard Microphone",
++			"RINPUT2", "Onboard Microphone";
++
++		daicpu: simple-audio-card,cpu {
++			sound-dai = <&i2s0_8ch>;
++			system-clock-frequency = <12288000>;
++		};
++
++		daicodec: simple-audio-card,codec {
++			sound-dai = <&es8388>;
++			system-clock-frequency = <12288000>;
++		};
++	};
++
++	vcc3v3_pcie30: vcc3v3-pcie30-regulator {
++		compatible = "regulator-fixed";
++		enable-active-high;
++		gpios = <&gpio2 RK_PB6 GPIO_ACTIVE_HIGH>;
++		regulator-name = "vcc3v3_pcie30";
++		regulator-min-microvolt = <3300000>;
++		regulator-max-microvolt = <3300000>;
++		startup-delay-us = <5000>;
++		vin-supply = <&vcc5v0_sys>;
++	};
++
++	vcc3v3_pcie_eth: vcc3v3-pcie-eth-regulator {
++		compatible = "regulator-fixed";
++		gpios = <&gpio3 RK_PB4 GPIO_ACTIVE_LOW>;
++		regulator-name = "vcc3v3_pcie_eth";
++		regulator-min-microvolt = <3300000>;
++		regulator-max-microvolt = <3300000>;
++		startup-delay-us = <50000>;
++		vin-supply = <&vcc5v0_sys>;
++	};
++
++	vcc3v3_wf: vcc3v3-wf-regulator {
++		compatible = "regulator-fixed";
++		enable-active-high;
++		gpios = <&gpio2 RK_PC5 GPIO_ACTIVE_HIGH>;
++		regulator-name = "vcc3v3_wf";
++		regulator-min-microvolt = <3300000>;
++		regulator-max-microvolt = <3300000>;
++		startup-delay-us = <50000>;
++		vin-supply = <&vcc5v0_sys>;
++	};
++
++	vcc5v0_sys: vcc5v0-sys-regulator {
++		compatible = "regulator-fixed";
++		regulator-name = "vcc5v0_sys";
++		regulator-always-on;
++		regulator-boot-on;
++		regulator-min-microvolt = <5000000>;
++		regulator-max-microvolt = <5000000>;
++	};
++
++	vcc5v0_usb20: vcc5v0-usb20-regulator {
++		compatible = "regulator-fixed";
++		enable-active-high;
++		gpio = <&gpio3 RK_PB7 GPIO_ACTIVE_HIGH>;
++		pinctrl-names = "default";
++		pinctrl-0 = <&vcc5v0_usb20_en>;
++		regulator-name = "vcc5v0_usb20";
++		regulator-min-microvolt = <5000000>;
++		regulator-max-microvolt = <5000000>;
++		vin-supply = <&vcc5v0_sys>;
++	};
++};
++
++&combphy0_ps {
++	status = "okay";
++};
++
++&combphy1_ps {
++	status = "okay";
++};
++
++&combphy2_psu {
++	status = "okay";
++};
++
++&cpu_b0 {
++	cpu-supply = <&vdd_cpu_big0_s0>;
++};
++
++&cpu_b1 {
++	cpu-supply = <&vdd_cpu_big0_s0>;
++};
++
++&cpu_b2 {
++	cpu-supply = <&vdd_cpu_big1_s0>;
++};
++
++&cpu_b3 {
++	cpu-supply = <&vdd_cpu_big1_s0>;
++};
++
++&cpu_l0 {
++	cpu-supply = <&vdd_cpu_lit_s0>;
++};
++
++&cpu_l1 {
++	cpu-supply = <&vdd_cpu_lit_s0>;
++};
++
++&cpu_l2 {
++	cpu-supply = <&vdd_cpu_lit_s0>;
++};
++
++&cpu_l3 {
++	cpu-supply = <&vdd_cpu_lit_s0>;
++};
++
++&i2c0 {
++	pinctrl-names = "default";
++	pinctrl-0 = <&i2c0m2_xfer>;
++	status = "okay";
++
++	vdd_cpu_big0_s0: regulator@42 {
++		compatible = "rockchip,rk8602";
++		reg = <0x42>;
++		fcs,suspend-voltage-selector = <1>;
++		regulator-name = "vdd_cpu_big0_s0";
++		regulator-always-on;
++		regulator-boot-on;
++		regulator-min-microvolt = <550000>;
++		regulator-max-microvolt = <1050000>;
++		regulator-ramp-delay = <2300>;
++		vin-supply = <&vcc5v0_sys>;
++
++		regulator-state-mem {
++			regulator-off-in-suspend;
++		};
++	};
++
++	vdd_cpu_big1_s0: regulator@43 {
++		compatible = "rockchip,rk8603", "rockchip,rk8602";
++		reg = <0x43>;
++		fcs,suspend-voltage-selector = <1>;
++		regulator-name = "vdd_cpu_big1_s0";
++		regulator-always-on;
++		regulator-boot-on;
++		regulator-min-microvolt = <550000>;
++		regulator-max-microvolt = <1050000>;
++		regulator-ramp-delay = <2300>;
++		vin-supply = <&vcc5v0_sys>;
++
++		regulator-state-mem {
++			regulator-off-in-suspend;
++		};
++	};
++};
++
++&i2c6 {
++	clock-frequency = <400000>;
++	status = "okay";
++
++	hym8563: rtc@51 {
++		compatible = "haoyu,hym8563";
++		reg = <0x51>;
++		interrupt-parent = <&gpio0>;
++		interrupts = <RK_PB0 IRQ_TYPE_LEVEL_LOW>;
++		#clock-cells = <0>;
++		clock-output-names = "hym8563";
++		pinctrl-names = "default";
++		pinctrl-0 = <&hym8563_int>;
++		wakeup-source;
++	};
++};
++
++&i2c7 {
++	status = "okay";
++
++	/* PLDO2 vcca 1.8V, BUCK8 gated by PLDO2 being enabled */
++	es8388: audio-codec@11 {
++		compatible = "everest,es8388";
++		reg = <0x11>;
++		clocks = <&cru I2S0_8CH_MCLKOUT>;
++		clock-names = "mclk";
++		AVDD-supply = <&vcc_1v8_s0>;
++		DVDD-supply = <&vcc_1v8_s0>;
++		HPVDD-supply = <&vcc_3v3_s0>;
++		PVDD-supply = <&vcc_3v3_s0>;
++		assigned-clocks = <&cru I2S0_8CH_MCLKOUT>;
++		assigned-clock-rates = <12288000>;
++		#sound-dai-cells = <0>;
++	};
++};
++
++&i2s0_8ch {
++	pinctrl-names = "default";
++	pinctrl-0 = <&i2s0_lrck
++		     &i2s0_mclk
++		     &i2s0_sclk
++		     &i2s0_sdi0
++		     &i2s0_sdo0>;
++	status = "okay";
++};
++
++&i2s2_2ch {
++	pinctrl-names = "default";
++	pinctrl-0 = <&i2s2m0_lrck
++		     &i2s2m0_sclk
++		     &i2s2m0_sdi
++		     &i2s2m0_sdo>;
++	status = "okay";
++};
++
++/* phy1 - M.KEY socket */
++&pcie2x1l0 {
++	reset-gpios = <&gpio4 RK_PA5 GPIO_ACTIVE_HIGH>;
++	vpcie3v3-supply = <&vcc3v3_wf>;
++	status = "okay";
++};
++
++/* phy2 - right ethernet port */
++&pcie2x1l1 {
++	reset-gpios = <&gpio3 RK_PB3 GPIO_ACTIVE_HIGH>;
++	vpcie3v3-supply = <&vcc3v3_pcie_eth>;
++	status = "okay";
++};
++
++/* phy0 - left ethernet port */
++&pcie2x1l2 {
++	reset-gpios = <&gpio4 RK_PA2 GPIO_ACTIVE_HIGH>;
++	vpcie3v3-supply = <&vcc3v3_pcie_eth>;
++	status = "okay";
++};
++
++&pcie30phy {
++	status = "okay";
++};
++
++&pcie3x4 {
++	reset-gpios = <&gpio4 RK_PB6 GPIO_ACTIVE_HIGH>;
++	vpcie3v3-supply = <&vcc3v3_pcie30>;
++	status = "okay";
++};
++
++&pinctrl {
++	hym8563 {
++		hym8563_int: hym8563-int {
++			rockchip,pins = <0 RK_PB0 RK_FUNC_GPIO &pcfg_pull_none>;
++		};
++	};
++
++	leds {
++		blue_led_pin: blue-led {
++			rockchip,pins = <3 RK_PA6 RK_FUNC_GPIO &pcfg_pull_up>;
++		};
++	};
++
++	ir-receiver {
++		ir_receiver_pin: ir-receiver-pin {
++			rockchip,pins = <4 RK_PB3 RK_FUNC_GPIO &pcfg_pull_none>;
++		};
++	};
++
++	sound {
++		hp_detect: hp-detect {
++			rockchip,pins = <1 RK_PD3 RK_FUNC_GPIO &pcfg_pull_none>;
++		};
++	};
++
++	usb {
++		vcc5v0_usb20_en: vcc5v0-usb20-en {
++			rockchip,pins = <3 RK_PB7 RK_FUNC_GPIO &pcfg_pull_none>;
++		};
++	};
++};
++
++&pwm2 {
++	pinctrl-0 = <&pwm2m1_pins>;
++	pinctrl-names = "default";
++	status = "okay";
++};
++
++&pwm3 {
++	pinctrl-0 = <&pwm3m1_pins>;
++	status = "okay";
++};
++
++&saradc {
++	vref-supply = <&vcc_1v8_s0>;
++	status = "okay";
++};
++
++&sdhci {
++	bus-width = <8>;
++	no-sdio;
++	no-sd;
++	non-removable;
++	max-frequency = <200000000>;
++	mmc-hs400-1_8v;
++	mmc-hs400-enhanced-strobe;
++	status = "okay";
++};
++
++&sdmmc {
++	bus-width = <4>;
++	cap-sd-highspeed;
++	cd-gpios = <&gpio0 RK_PA4 GPIO_ACTIVE_LOW>;
++	disable-wp;
++	max-frequency = <150000000>;
++	no-sdio;
++	no-mmc;
++	sd-uhs-sdr104;
++	vmmc-supply = <&vcc_3v3_s3>;
++	vqmmc-supply = <&vccio_sd_s0>;
++	status = "okay";
++};
++
++&sfc {
++	pinctrl-names = "default";
++	pinctrl-0 = <&fspim1_pins>;
++	status = "okay";
++
++	spi_flash: flash@0 {
++		compatible = "jedec,spi-nor";
++		reg = <0x0>;
++		spi-max-frequency = <100000000>;
++		spi-rx-bus-width = <4>;
++		spi-tx-bus-width = <1>;
++	};
++};
++
++&spi2 {
++	assigned-clocks = <&cru CLK_SPI2>;
++	assigned-clock-rates = <200000000>;
++	num-cs = <1>;
++	pinctrl-names = "default";
++	pinctrl-0 = <&spi2m2_cs0 &spi2m2_pins>;
++	status = "okay";
++
++	pmic@0 {
++		compatible = "rockchip,rk806";
++		reg = <0x0>;
++		interrupt-parent = <&gpio0>;
++		interrupts = <7 IRQ_TYPE_LEVEL_LOW>;
++		pinctrl-names = "default";
++		pinctrl-0 = <&pmic_pins>, <&rk806_dvs1_null>,
++			    <&rk806_dvs2_null>, <&rk806_dvs3_null>;
++		spi-max-frequency = <1000000>;
++
++		vcc1-supply = <&vcc5v0_sys>;
++		vcc2-supply = <&vcc5v0_sys>;
++		vcc3-supply = <&vcc5v0_sys>;
++		vcc4-supply = <&vcc5v0_sys>;
++		vcc5-supply = <&vcc5v0_sys>;
++		vcc6-supply = <&vcc5v0_sys>;
++		vcc7-supply = <&vcc5v0_sys>;
++		vcc8-supply = <&vcc5v0_sys>;
++		vcc9-supply = <&vcc5v0_sys>;
++		vcc10-supply = <&vcc5v0_sys>;
++		vcc11-supply = <&vcc_2v0_pldo_s3>;
++		vcc12-supply = <&vcc5v0_sys>;
++		vcc13-supply = <&vdd2_ddr_s3>;
++		vcc14-supply = <&vdd2_ddr_s3>;
++		vcca-supply = <&vcc5v0_sys>;
++
++		gpio-controller;
++		#gpio-cells = <2>;
++
++		rk806_dvs1_null: dvs1-null-pins {
++			pins = "gpio_pwrctrl2";
++			function = "pin_fun0";
++		};
++
++		rk806_dvs2_null: dvs2-null-pins {
++			pins = "gpio_pwrctrl2";
++			function = "pin_fun0";
++		};
++
++		rk806_dvs3_null: dvs3-null-pins {
++			pins = "gpio_pwrctrl3";
++			function = "pin_fun0";
++		};
++
++		regulators {
++			vdd_gpu_s0: dcdc-reg1 {
++				regulator-name = "vdd_gpu_s0";
++				regulator-boot-on;
++				regulator-enable-ramp-delay = <400>;
++				regulator-min-microvolt = <550000>;
++				regulator-max-microvolt = <950000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vdd_cpu_lit_s0: dcdc-reg2 {
++				regulator-name = "vdd_cpu_lit_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <550000>;
++				regulator-max-microvolt = <950000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vdd_log_s0: dcdc-reg3 {
++				regulator-name = "vdd_log_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <675000>;
++				regulator-max-microvolt = <825000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++					regulator-suspend-microvolt = <750000>;
++				};
++			};
++
++			vdd_vdenc_s0: dcdc-reg4 {
++				regulator-name = "vdd_vdenc_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <550000>;
++				regulator-max-microvolt = <825000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vdd_ddr_s0: dcdc-reg5 {
++				regulator-name = "vdd_ddr_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <675000>;
++				regulator-max-microvolt = <900000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++					regulator-suspend-microvolt = <850000>;
++				};
++			};
++
++			vdd2_ddr_s3: dcdc-reg6 {
++				regulator-name = "vdd2_ddr_s3";
++				regulator-always-on;
++				regulator-boot-on;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++				};
++			};
++
++			vcc_2v0_pldo_s3: dcdc-reg7 {
++				regulator-name = "vdd_2v0_pldo_s3";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <2000000>;
++				regulator-max-microvolt = <2000000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++					regulator-suspend-microvolt = <2000000>;
++				};
++			};
++
++			vcc_3v3_s3: dcdc-reg8 {
++				regulator-name = "vcc_3v3_s3";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <3300000>;
++				regulator-max-microvolt = <3300000>;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++					regulator-suspend-microvolt = <3300000>;
++				};
++			};
++
++			vddq_ddr_s0: dcdc-reg9 {
++				regulator-name = "vddq_ddr_s0";
++				regulator-always-on;
++				regulator-boot-on;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vcc_1v8_s3: dcdc-reg10 {
++				regulator-name = "vcc_1v8_s3";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1800000>;
++				regulator-max-microvolt = <1800000>;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++					regulator-suspend-microvolt = <1800000>;
++				};
++			};
++
++			avcc_1v8_s0: pldo-reg1 {
++				regulator-name = "avcc_1v8_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1800000>;
++				regulator-max-microvolt = <1800000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++					regulator-suspend-microvolt = <1800000>;
++				};
++			};
++
++			/* shorted to avcc_1v8_s0 on the board */
++			vcc_1v8_s0: pldo-reg2 {
++				regulator-name = "vcc_1v8_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1800000>;
++				regulator-max-microvolt = <1800000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++					regulator-suspend-microvolt = <1800000>;
++				};
++			};
++
++			avdd_1v2_s0: pldo-reg3 {
++				regulator-name = "avdd_1v2_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1200000>;
++				regulator-max-microvolt = <1200000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vcc_3v3_s0: pldo-reg4 {
++				regulator-name = "vcc_3v3_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <3300000>;
++				regulator-max-microvolt = <3300000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vccio_sd_s0: pldo-reg5 {
++				regulator-name = "vccio_sd_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1800000>;
++				regulator-max-microvolt = <3300000>;
++				regulator-ramp-delay = <12500>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			pldo6_s3: pldo-reg6 {
++				regulator-name = "pldo6_s3";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <1800000>;
++				regulator-max-microvolt = <1800000>;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++					regulator-suspend-microvolt = <1800000>;
++				};
++			};
++
++			vdd_0v75_s3: nldo-reg1 {
++				regulator-name = "vdd_0v75_s3";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <750000>;
++				regulator-max-microvolt = <750000>;
++
++				regulator-state-mem {
++					regulator-on-in-suspend;
++					regulator-suspend-microvolt = <750000>;
++				};
++			};
++
++			vdd_ddr_pll_s0: nldo-reg2 {
++				regulator-name = "vdd_ddr_pll_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <850000>;
++				regulator-max-microvolt = <850000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++					regulator-suspend-microvolt = <850000>;
++				};
++			};
++
++			avdd_0v75_s0: nldo-reg3 {
++				regulator-name = "avdd_0v75_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				/*
++				 * The schematic mentions that actual setting
++				 * should be 0.8375V. RK3588 datasheet specifies
++				 * maximum as 0.825V. So we set datasheet max
++				 * here.
++				 */
++				regulator-min-microvolt = <825000>;
++				regulator-max-microvolt = <825000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vdd_0v85_s0: nldo-reg4 {
++				regulator-name = "vdd_0v85_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <850000>;
++				regulator-max-microvolt = <850000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++
++			vdd_0v75_s0: nldo-reg5 {
++				regulator-name = "vdd_0v75_s0";
++				regulator-always-on;
++				regulator-boot-on;
++				regulator-min-microvolt = <750000>;
++				regulator-max-microvolt = <750000>;
++
++				regulator-state-mem {
++					regulator-off-in-suspend;
++				};
++			};
++		};
++	};
++};
++
++&tsadc {
++	status = "okay";
++};
++
++&u2phy2 {
++	status = "okay";
++};
++
++&u2phy3 {
++	status = "okay";
++};
++
++&u2phy2_host {
++	phy-supply = <&vcc5v0_usb20>;
++	status = "okay";
++};
++
++&u2phy3_host {
++	phy-supply = <&vcc5v0_usb20>;
++	status = "okay";
++};
++
++&uart2 {
++	pinctrl-0 = <&uart2m0_xfer>;
++	status = "okay";
++};
++
++&uart9 {
++	pinctrl-0 = <&uart9m0_xfer>;
++	status = "okay";
++};
++
++&usb_host0_ehci {
++	status = "okay";
++};
++
++&usb_host0_ohci {
++	status = "okay";
++};
++
++&usb_host1_ehci {
++	status = "okay";
++};
++
++&usb_host1_ohci {
++	status = "okay";
++};
diff --git a/target/linux/rockchip/patches-6.1/100-rockchip-use-system-LED-for-OpenWrt.patch b/target/linux/rockchip/patches-6.1/100-rockchip-use-system-LED-for-OpenWrt.patch
index 8e99d9c8d19..76629ff8f4c 100644
--- a/target/linux/rockchip/patches-6.1/100-rockchip-use-system-LED-for-OpenWrt.patch
+++ b/target/linux/rockchip/patches-6.1/100-rockchip-use-system-LED-for-OpenWrt.patch
@@ -375,6 +375,29 @@ Signed-off-by: David Bauer <mail@david-bauer.net>
  		};
  	};
  
+--- a/arch/arm64/boot/dts/rockchip/rk3588-orangepi-5-plus.dts
++++ b/arch/arm64/boot/dts/rockchip/rk3588-orangepi-5-plus.dts
+@@ -20,6 +20,11 @@
+ 		mmc0 = &sdhci;
+ 		mmc1 = &sdmmc;
+ 		serial2 = &uart2;
++
++		led-boot = &status_led;
++		led-failsafe = &status_led;
++		led-running = &status_led;
++		led-upgrade = &status_led;
+ 	};
+ 
+ 	chosen {
+@@ -78,7 +83,7 @@
+ 		pinctrl-names = "default";
+ 		pinctrl-0 = <&blue_led_pin>;
+ 
+-		led {
++		status_led: led {
+ 			color = <LED_COLOR_ID_BLUE>;
+ 			function = LED_FUNCTION_INDICATOR;
+ 			function-enumerator = <1>;
 --- a/arch/arm64/boot/dts/rockchip/rk3588-rock-5b.dts
 +++ b/arch/arm64/boot/dts/rockchip/rk3588-rock-5b.dts
 @@ -15,6 +15,11 @@
@@ -403,6 +426,32 @@ Signed-off-by: David Bauer <mail@david-bauer.net>
  		};
  	};
  
+--- a/arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts
++++ b/arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts
+@@ -15,6 +15,11 @@
+ 	aliases {
+ 		mmc0 = &sdmmc;
+ 		serial2 = &uart2;
++
++		led-boot = &status_led;
++		led-failsafe = &status_led;
++		led-running = &status_led;
++		led-upgrade = &status_led;
+ 	};
+ 
+ 	chosen {
+@@ -40,10 +45,9 @@
+ 		pinctrl-names = "default";
+ 		pinctrl-0 =<&leds_gpio>;
+ 
+-		led-1 {
++		status_led: led-1 {
+ 			gpios = <&gpio1 RK_PA2 GPIO_ACTIVE_HIGH>;
+ 			label = "status_led";
+-			linux,default-trigger = "heartbeat";
+ 		};
+ 	};
+ 
 --- a/arch/arm64/boot/dts/rockchip/rk3588s-rock-5a.dts
 +++ b/arch/arm64/boot/dts/rockchip/rk3588s-rock-5a.dts
 @@ -9,12 +9,17 @@
diff --git a/target/linux/rockchip/patches-6.1/210-rockchip-rk356x-add-support-for-new-boards.patch b/target/linux/rockchip/patches-6.1/210-rockchip-rk356x-add-support-for-new-boards.patch
index d3096b4f802..8f989207bf1 100644
--- a/target/linux/rockchip/patches-6.1/210-rockchip-rk356x-add-support-for-new-boards.patch
+++ b/target/linux/rockchip/patches-6.1/210-rockchip-rk356x-add-support-for-new-boards.patch
@@ -24,10 +24,11 @@
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-nanopi-r5c.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-nanopi-r5s.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-roc-pc.dtb
-@@ -84,4 +87,6 @@ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-ro
- dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-evb1-v10.dtb
+@@ -85,5 +88,7 @@ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-ev
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-nanopc-t6.dtb
+ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-orangepi-5-plus.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588-rock-5b.dtb
 +dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588s-nanopi-r6c.dtb
 +dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588s-nanopi-r6s.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588s-rock-5a.dtb
+ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3588s-orangepi-5.dtb
