# Collator demo

Demo/example how to use the BAP collator.

I'm using the following BAP version (via the docker container):

    bap --version
    > 2.2.0-alpha+25d1eb6


## Build and run

Build the sample executables:

    make -C resources

Build and install:

    make

Run it:

    bap collatordemo resources/main_1 resources/main_2

This uses the `Project.Collator` to load `resources/main_1` and `main_2`,
then it prints the `main` function in each.

Both `main` functions are the same, with the same TIDs, so it looks like
the two programs have been merged. I think I expected them to be distinct.

Then try:

    bap collatordemo resources/main_2 resources/main_3

This time, a KB conflict occurs, on the instruction that differs between
`main_2` and `main_3`, since it is trying to merge the two programs.
