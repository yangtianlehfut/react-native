# Local native dependency archives

The Android source build reads native dependency archives from this directory
when `reactNative.dependenciesSource=local`.

Boost is larger than GitHub's 100 MB file limit, so it is stored in two
90 MB chunks. Before the first local build, restore and verify the archive:

```bash
./prepare_boost.sh
```

The script is safe to rerun. It exits immediately when the full archive already
exists and its SHA-256 checksum is valid.

Do not commit `boost_1_83_0.tar.gz`. The full archive is ignored by Git; commit
the chunks, checksum file, and preparation script instead.
