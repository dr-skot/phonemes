# phonemes 

Fetches phoneme data from the Mac OS speech synthesizer.

## Command-Line Usage

simple

```
phonemes I did not have sexual relations with that woman
~AY ~dIHd _n1AAt _h1AEv _s1EHkSUWAXl _rIXl1EYSIXnz ~w2IHD ~DAEt _w1UHmAXn.
```

detailed (-t stands for TUNE output)

```
phonemes -t Lewinsky
_ {W "LEWINSKY" Noun Name}
l {D 90; P 100.3:0 102.5:50}
UW {D 100; P 108.2:0 108.8:20 112.9:50}
1IH {D 90; P 122.3:0 126.5:17 149.9:78 151.9:89}
n {D 80; P 151.2:0 147.7:19}
s {D 80; P 117.4:0 106:31 95.1:69}
k {D 95; P 95.8:0 91.2:21 89.2:47 90.6:74}
IY {D 210; P 94.7:0 88.7:12 84.5:26 75:100}
. {D 10}
```

specify a voice

```
phonemes -v Bruce I\'m Batman
~2AYm _b1AEtmAXn.
```

help

```
phonemes -h
usage: phonemes -h
       phonemes [-t] [-v voice] text
```
