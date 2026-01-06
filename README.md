# ECSI Project - RPM Control on Computer Case Fan using Fractional Order PI Controller

TODO: Add a super brief one liner description.
- PC case fan RPM control using PWM
- librehardwaremonitorlib in C#
- terminal gui using ...
- compute controller using the MATLAB scripts from the lab

## ⚠️ IMPORTANT, So I don't forget

- incercare1.m = controllerul ala care nu merge
- incercare2.m = ...

## File Descriptions

```
MATLAB Scripts
- FOPIslope.m                 FOPI transfer function & slope
- FOPIvalues.m                FOPI controller parameters (Kp, Ti)
- KCtuner_FOPI_FOPD.m         FOPI/FOPD tuning for phase margin
- ora_foc_RdK.m               Oustaloup approx. for frac. diff.
- reccurenceRelFromNumDen.m   Recurrence relation from num/den
- incercare1.m                Main script (broken)
- incercare2.m                Main script 

Data & Model Files
- sin_0_185A1_off6_3.txt          (old) Sine current experiment data
- sin_0185.mat                    (old) Sine input experiment (MAT file)
- sine_20260102_145352.csv        Sinusoidal PWM/RPM data
- stepresp_20260106_201637.csv    Step PWM/RPM data
- ident_sin_real.slx/.slxc        (old) Simulink model & cache
```

## What Has to Change in the Script

I will use the provided MATLAB scripts from Lab 4. The `sin_0_185hz.m` is already very good, so I need to change the experimental sine response data (the one originally from the VTOL platform). To do this, I need to recreate the same experiment on my computer fan.

## Control RPM using PWM

Since the fans are highly non linear at low RPM (possibly even at high RPM), I will focus on more middle-focused ranges.

