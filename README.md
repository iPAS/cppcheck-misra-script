# cppcheck-misra-script

Bash script helper to Cppcheck on C and C++ code, with MISRA guidelines


## Quick Start

1. Git clone this repository with '--recurse-submodules' to get the cppcheck as well.
2. Compile the cppcheck:
    ```bash
    $ cd cppcheck
    $ make $(nproc)
    ...
    $ cd ..
    ```
    The executable 'cppcheck' will be in the directory.
3. Use 'misra_check.sh' to test your source code files:
    ```bash
    $ ./misra_check.sh <source code files | directories>
    ```


## Testing

Just run:
```bash
$ ./misra_check.sh cppcheck/samples  # For C and C++
...
$ ./misra_check.sh examples  # For C++
...
```


## References

* Adopt MISRA checking script from [Speeduino](https://github.com/speeduino/speeduino)
* Adopt [MISRA-Example-Suite](https://github.com/jubnzv/MISRA-Example-Suite) for testing, as __examples__
