# cppcheck-misra-script

Bash script helper to Cppcheck on C and C++ code, with MISRA guidelines


## Quick Start

1. Git clone this repository with '--recurse-submodules' to get the cppcheck as well.
    ```bash
    $ git clone git@github.com:iPAS/cppcheck-misra-script.git --recurse-submodules
    ```
2. Compile the cppcheck:
    ```bash
    $ cd cppcheck-misra-script
    $ cd cppcheck
    $ make $(nproc)
    ...
    $ cd ..
    ```
    The executable 'cppcheck' will be in the directory.
3. Use 'misra_check.sh' to test your source code files:
    ```bash
    $ ./misra_check.sh [--source <source code files | directories>] ...
    ```


## Testing

Just run:
```bash
$ ./misra_check.sh --source cppcheck/samples  # For C and C++
...
$ ./misra_check.sh --source examples  # For C++
...
$ ./misra_check.sh --source cppcheck/samples --source examples  # For C++
...
$ ./misra_check.sh --source 'the examples' --html --html-title 'Hello World' --html-out html
...
```


## References

* Adopt MISRA checking script from [Speeduino](https://github.com/speeduino/speeduino)
* Adopt [MISRA-Example-Suite](https://github.com/jubnzv/MISRA-Example-Suite) for testing, as __examples__
