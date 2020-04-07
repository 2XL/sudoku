#---------------------------------------------------------------------------------
# Specific Makefile to assembly ARM source code
# Author: Santiago Romani
# Date: December 2010
# Licence: Public Domain
#---------------------------------------------------------------------------------

ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif
export PATH	:=	$(DEVKITARM)/bin:$(DEVKITPRO)/Insight/bin:$(PATH)

#---------------------------------------------------------------------------------
# TARGET is the name of the folder (directory) in which this Makefile resides
#---------------------------------------------------------------------------------
TARGET	:=	$(shell basename $(CURDIR))


#---------------------------------------------------------------------------------
# options for code generation
#---------------------------------------------------------------------------------
ASFLAGS	:= -march=armv5te -mlittle-endian -g
LDFLAGS := --warn-section-align -z execstack


#---------------------------------------------------------------------------------
# build commands
#---------------------------------------------------------------------------------
build : $(TARGET).elf

$(TARGET).elf : $(TARGET).o startup.o
	@echo "linking $(TARGET).o, startup.o into $(TARGET).elf"
	@arm-eabi-ld $(LDFLAGS) $(TARGET).o startup.o -o $(TARGET).elf

$(TARGET).o : $(TARGET).s
	@echo "assembling $(TARGET).s into $(TARGET).o"
	@arm-eabi-as $(ASFLAGS) $(TARGET).s -o $(TARGET).o

startup.o : startup.s
	@echo "assembling startup.s into startup.o"
	@arm-eabi-as $(ASFLAGS) startup.s -o startup.o


#---------------------------------------------------------------------------------
# clean commands
#---------------------------------------------------------------------------------
clean : 
	@rm -fv startup.o
	@rm -fv $(TARGET).o
	@rm -fv $(TARGET).elf


#---------------------------------------------------------------------------------
# run commands
#---------------------------------------------------------------------------------
run : $(TARGET).elf
	@echo "testing $(TARGET).elf with Insight (gdb)"
	@arm-eabi-insight $(TARGET).elf &

