
ifeq (,$(filter cortex-a53 default,$(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)))
	RS_DISABLE_A53_WORKAROUND := true
endif
