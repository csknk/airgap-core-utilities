Security Notes
==============

### Create Password
Creates a 44 character Base64 string:

LC_ALL=C head -c 32 /dev/urandom | base64

is `LC_ALL=C` necessary?

```bash
for i in {0..9}; do LC_ALL=C head -c 32 /dev/urandom | base64 >> keys.txt; done

gpg --symmetric --cipher-algo TWOFISH keys.txt

```
This passord MUST NOT be exposed online. It is distributed carefully using Shamir's Secret Sharing Scheme.

### Create the Encrypted Recovery File

```bash
# Archive and encrypt using Twofish cipher
tar -cz recovery | gpg --symmetric --cipher-algo TWOFISH -o recovery.tgz.gpg
```


```
head /dev/urandom | tr -cd [:graph:] | head -c 32; echo
tr -cd [:graph:] < /dev/urandom | head -c 32; echo
```
