The patches I have applied to rubicon were done in a hurry, and aren't
release-worthy yet.  I'd have to go back and clean them up before they
could be submitted upstream.  In general, they assume details specific
to our VMS, or perhaps to our system, and I have failed to make that
distinction throughout.

We have patched rubicon_tests.rb so it won't depend on mixed case
filenames, which was necessary to run on our old ODS2 filesystem.

I had trouble with alltests.rb invoking the external utilities in [.util]
so all of those tests currently fail.

Certain other tests failed in various ways, so I had to disable them in
the code, otherwise they would cause rubicon to abort.

To run the tests, first compile the utilities in [.util] (see
[.util]aaareadme.txt) and then run the following:

$ @aasetup
$ @alltests

Ben Armstrong <BArmstrong@dymaxion.ca> Jan 11, 2005
