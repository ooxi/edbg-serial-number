# edbg-serial-number

A friendly fork of [edbg][edbg], carrying [PR#91][edbg-pr-91].

[This patch][patch] enables printing the target's serial number using SWD.


# Sample output

```
Debugger: ATMEL EDBG CMSIS-DAP ATML2130021800020377 03.22.01B3 (S)
Clock frequency: 16.0 MHz
Target: SAM D21J18A (Rev D)
Serial number: 41eebbfe 514d3559 34202020 ff0f2a24
Programming.............................................................................. done.
Verification.............................................................................. done.
```


[edbg]: https://github.com/ataradov/edbg
[edbg-pr-91]: https://github.com/ataradov/edbg/pull/91
[patch]: patch/0001-Print-serial-number-of-CM0-target.patch

