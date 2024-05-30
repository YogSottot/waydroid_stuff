# Snippets

* Purge all local changes:

```bash
repo forall -c 'git reset --hard ; git clean -fdx' 
```

* Find the Commit Hash for the Desired Date:

```bash
repo forall -c 'git log --before="2023-09-16" -n 1 --pretty=format:"%H"'
```

* This command will output the commit hash of the last commit before the specified date in each repository managed by repo:

```bash
repo forall -c 'git log --before="2023-09-16" -n 1 --pretty=format:"%H"'
```

* Checkout the commit before the specified date in each repository managed by repo:

```bash
repo forall -c 'git checkout $(git log --before="2023-09-16" -n 1 --pretty=format:"%H")'
```

* Checkout lates commit in each repository managed by repo:

```bash
repo forall -c 'git checkout -'
```

Create a patch from the last commit:

```bash
git format-patch -1
```
