# ECSI Project - RPM Control on Computer Case Fan using Fractional Order PI Controller

TODO: Add a super brief one liner description.
- PC case fan RPM control using PWM
- librehardwaremonitorlib in C#
- terminal gui using ...
- compute controller using the MATLAB scripts from the lab

## The 

I will use the provided MATLAB scripts from Lab 4. The `sin_0_185hz.m` is already very good, so I will only need to change the experimental sine response data (the one originally from the VTOL platform). To do this, I need to sort-of recreate the same experiment on my computer fan.

## Control RPM using PWM

My loop is:

`RPM_ref ──►(–)──► FOPI ──► PWM ──► Fan ──► RPM_meas`

Since the fans are highly non linear at low RPM (possibly even at high RPM), I will focus on more middle-focused ranges.

