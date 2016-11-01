APPLY_A53_ERRATA_FIXES :=

ifeq (,$(filter kryo,$(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)))
ifneq (,$(filter cortex-a53,$(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)))
	APPLY_A53_ERRATA_FIXES := true
endif
endif

ifneq ($(strip $(TARGET_IS_CORTEX-A53)),)
	APPLY_A53_ERRATA_FIXES := $(TARGET_IS_CORTEX-A53)
endif

ifneq ($(APPLY_A53_ERRATA_FIXES),true)
	RS_DISABLE_A53_WORKAROUND := true
endif

APPLY_A53_ERRATA_FIXES :=
