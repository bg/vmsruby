I couldn't build a test_touch that works because our CRTL doesn't
support utime.

Each C file is built by hand with:

$ cc filename.c
$ link filename

Test_touch also needs utime and vmsmunch:

$ link test_touch,utime,vmsmunch

Ben Armstrong <BArmstrong@dymaxion.ca> Jan 11, 2005
