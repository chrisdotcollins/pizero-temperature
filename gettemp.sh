#!/bin/bash
# Read MCP9808 temp register value
tempRegVal=$(i2cget -y 1 0x18 0x05 w)

### Mask temp value bits (MSB bits 0-3, LSB bits 4-7 for whole numbers, LSB bit 0-3 fractional values)
### LSB bits 8-15, MSB bits 0-7

bit15=$(((tempRegVal & 0x8000)>0))
bit14=$(((tempRegVal & 0x4000)>0))
bit13=$(((tempRegVal & 0x2000)>0))
bit12=$(((tempRegVal & 0x1000)>0))
bit11=$(((tempRegVal & 0x0800)>0))
bit10=$(((tempRegVal & 0x0400)>0))
bit9=$(((tempRegVal & 0x0200)>0))
bit8=$(((tempRegVal & 0x0100)>0))
bit7=$(((tempRegVal & 0x0080)>0))
bit6=$(((tempRegVal & 0x0040)>0))
bit5=$(((tempRegVal & 0x0020)>0))
bit4=$(((tempRegVal & 0x0010)>0))
bit3=$(((tempRegVal & 0x0008)>0))
bit2=$(((tempRegVal & 0x0004)>0))
bit1=$(((tempRegVal & 0x0002)>0))
bit0=$(((tempRegVal & 0x0001)>0))

### Test print to validate the masking
#echo $tempRegVal
#echo $bit15$bit14$bit13$bit12$bit11$bit10$bit9$bit8 $bit7$bit6$bit5$bit4$bit3$bit2$bit1$bit0

### Calc whole number temperature
tempCWhole=$(($bit3*128 + $bit2*64 + $bit1*32 + $bit0*16 + $bit15*8 + $bit14*4 + $bit13*2 + $bit12))

### BASH cannot do floating point match; awk & bc can (bc not installed on Riva boards)
tb11=$(echo - | awk -v var=$bit11 'BEGIN {print var / 2 }')
tb10=$(echo - | awk -v var=$bit10 'BEGIN {print var / 4 }')
tb9=$(echo - | awk -v var=$bit9 'BEGIN {print var / 8 }')
tb8=$(echo - | awk -v var=$bit8 'BEGIN {print var / 16 }')
frSum=$(echo - | awk 'BEGIN {print "'"$tb11"'" + "'"$tb10"'" + "'"$tb9"'" + "'"$tb8"'" }')

### Add whole & fractioanl values together
tempC=$(echo - | awk 'BEGIN {print "'"$tempCWhole"'" + "'"$frSum"'" }')
echo $tempC

#### Convert to F
#tempF=$(echo - | awk 'BEGIN {print "'"$tempC"'" * 1.8 + 32 }')
##echo $tempF
#
#### Round to 2 decimal place
#tempFRnd=$(echo -| awk -v var=$tempF 'BEGIN { OFMT="%.2f";print  0+var}')
#echo $tempFRnd
