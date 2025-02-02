diff --git a/package/boot/uboot-rockchip/Makefile b/package/boot/uboot-rockchip/Makefile
index bc3297efa9d4e..4875f01b43617 100644
--- a/package/boot/uboot-rockchip/Makefile
+++ b/package/boot/uboot-rockchip/Makefile
@@ -196,6 +196,17 @@ define U-Boot/opc-h68k-rk3568
   DDR:=rk3568_ddr_1560MHz_v1.13.bin
 endef
 
+define U-Boot/nlnet-xgp-rk3568
+  BUILD_SUBTARGET:=armv8
+  NAME:=NLnet XGP Board
+  BUILD_DEVICES:= \
+    nlnet_xgp
+  DEPENDS:=+PACKAGE_u-boot-nlnet-xgp-rk3568:arm-trusted-firmware-rk3568
+  PKG_BUILD_DEPENDS:=arm-trusted-firmware-rockchip-vendor
+  ATF:=rk3568_bl31_v1.43.elf
+  DDR:=rk3568_ddr_1560MHz_v1.18.bin
+endef
+
 define U-Boot/photonicat-rk3568
   BUILD_SUBTARGET:=armv8
   NAME:=Ariaboard Photonicat
@@ -255,6 +266,7 @@ endef
 UBOOT_TARGETS := \
   mrkaio-m68s-rk3568 \
   opc-h68k-rk3568 \
+  nlnet-xgp-rk3568 \
   photonicat-rk3568 \
   radxa-e25-rk3568 \
   rock-3a-rk3568 \
diff --git a/target/linux/rockchip/armv8/base-files/etc/board.d/02_network b/target/linux/rockchip/armv8/base-files/etc/board.d/02_network
index 8fed56a0027b9..95410bca3a518 100755
--- a/target/linux/rockchip/armv8/base-files/etc/board.d/02_network
+++ b/target/linux/rockchip/armv8/base-files/etc/board.d/02_network
@@ -17,6 +17,7 @@
 	friendlyarm,nanopi-r2s|\
 	friendlyarm,nanopi-r4s|\
 	friendlyarm,nanopi-r4se|\
+	nlnet,xgp|\
 	rocktech,mpc1903|\
 	sharevdi,h3399pc|\
 	sharevdi,guangmiao-g4c|\
@@ -88,6 +89,7 @@
 	hinlink,opc-h66k|\
 	hinlink,opc-h68k|\
 	hinlink,opc-h69k|\
+	nlnet,xgp|\
 	rocktech,mpc1903|\
 	sharevdi,h3399pc)
 		wan_mac=$(macaddr_generate_from_mmc_cid mmcblk0)
diff --git a/target/linux/rockchip/patches-5.15/210-rockchip-rk356x-add-support-for-new-boards.patch b/target/linux/rockchip/patches-5.15/210-rockchip-rk356x-add-support-for-new-boards.patch
index 2f9a26979dc4b..f66423793c78d 100644
--- a/target/linux/rockchip/patches-5.15/210-rockchip-rk356x-add-support-for-new-boards.patch
+++ b/target/linux/rockchip/patches-5.15/210-rockchip-rk356x-add-support-for-new-boards.patch
@@ -1,6 +1,6 @@
 --- a/arch/arm64/boot/dts/rockchip/Makefile
 +++ b/arch/arm64/boot/dts/rockchip/Makefile
-@@ -59,3 +59,19 @@ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3399-sa
+@@ -59,3 +59,20 @@ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3399-sa
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3399-sapphire-excavator.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3399pro-rock-pi-n10.dtb
  dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-evb1-v10.dtb
@@ -20,3 +20,4 @@
 +dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-seewo-sv21.dtb
 +dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-t68m.dtb
 +dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3566-panther-x2.dtb
++dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-xgp.dtb

--- a/target/linux/rockchip/armv8/base-files/etc/board.d/01_leds
+++ b/target/linux/rockchip/armv8/base-files/etc/board.d/01_leds
@@ -36,6 +36,9 @@ hinlink,opc-h68k|\
 hinlink,opc-h69k)
 	ucidef_set_led_netdev "wan" "WAN" "blue:net" "eth0"
 	;;
+nlnet,xgp)
+	ucidef_set_led_netdev "wan" "WAN" "blue:sys" "eth0"
+	;;
 esac
 
 board_config_flush
diff --git a/target/linux/rockchip/image/Makefile b/target/linux/rockchip/image/Makefile
index a2b711a4367cb..b2c53fe0f97e4 100644
--- a/target/linux/rockchip/image/Makefile
+++ b/target/linux/rockchip/image/Makefile
@@ -20,6 +20,23 @@ define Build/boot-common
 	$(CP) $(IMAGE_KERNEL) $@.boot/kernel.img
 endef
 
+define Build/boot-combined
+	# This creates a new folder copies the dtbs (as rockchip*.dtb)
+	# and the kernel image (as kernel.img)
+	rm -fR $@.boot
+	mkdir -p $@.boot
+
+	i=0; \
+	for dts in $(DEVICE_DTS); do \
+		dts=$$(echo $${dts} | cut -d'/' -f2); \
+		$(CP) $(KDIR)/image-$$(echo $${dts} | cut -d'/' -f2).dtb $@.boot/rockchip$$(perl -e 'printf "%b\n",'$$i).dtb; \
+		let i+=1; \
+	done
+
+	$(LN) rockchip0.dtb $@.boot/rockchip.dtb
+	$(CP) $(IMAGE_KERNEL) $@.boot/kernel.img
+endef
+
 define Build/boot-script
 	# Make an U-boot image and copy it to the boot partition
 	mkimage -A arm -O linux -T script -C none -a 0 -e 0 -d $(if $(1),$(1),mmc).bootscript $@.boot/boot.scr
diff --git a/target/linux/rockchip/image/nlnet-xgp.bootscript b/target/linux/rockchip/image/nlnet-xgp.bootscript
new file mode 100644
index 0000000000000..80df26f6c1520
--- /dev/null
+++ b/target/linux/rockchip/image/nlnet-xgp.bootscript
@@ -0,0 +1,38 @@
+# nlnet-xgp rk3568 combined image, board detected by ADC
+
+env delete hwrev
+env delete coreboard_adc_value
+env delete motherboard_adc_value
+
+# using SARADC CH1 to detect coreboard hwrev
+# using SARADC CH7 to detect motherboard hwrev
+
+adc single saradc@fe720000 1 coreboard_adc_value
+adc single saradc@fe720000 7 motherboard_adc_value
+
+if test -n "$coreboard_adc_value"; then
+    if test "$coreboard_adc_value" -lt 225000; then
+        echo coreboard rev02
+    fi
+fi
+
+if test -n "$motherboard_adc_value"; then
+    if test "$motherboard_adc_value" -lt 225000; then
+        echo motherboard rev03
+        setenv hwrev 1
+    fi
+fi
+
+env delete coreboard_adc_value
+env delete motherboard_adc_value
+
+part uuid mmc ${devnum}:2 uuid
+
+setenv bootargs "console=ttyS2,1500000 earlycon=uart8250,mmio32,0xfe660000 root=PARTUUID=${uuid} rw rootwait"
+
+load mmc ${devnum}:1 ${fdt_addr_r} rockchip${hwrev}.dtb
+load mmc ${devnum}:1 ${kernel_addr_r} kernel.img
+
+env delete hwrev
+
+booti ${kernel_addr_r} - ${fdt_addr_r}

