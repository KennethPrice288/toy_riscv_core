REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

PCF_PATH=$(REPO_ROOT)/src/icebreaker.pcf

$(info REPO_ROOT = $(REPO_ROOT))
$(info Including $(REPO_ROOT)/frag/simulate.mk)
-include $(REPO_ROOT)/frag/simulate.mk
$(info Including $(REPO_ROOT)/frag/synth.mk)
-include $(REPO_ROOT)/frag/synth.mk
$(info Including $(REPO_ROOT)/frag/fpga.mk)
-include $(REPO_ROOT)/frag/fpga.mk
