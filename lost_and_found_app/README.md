# README

## Get a teammate's commit

To bring one specific commit from GitHub into your current branch, first make
sure your own changes are committed or stashed. Then fetch the latest remote
branches and cherry-pick the commit:

```bash
git fetch origin
git log --oneline origin/main
git cherry-pick <commit-hash>
```

Replace `<commit-hash>` with the commit ID you want to apply. If the commit is
on another branch, use that branch in the `git log` command instead of `main`.

To bring in all commits from another branch instead, merge that remote branch:

```bash
git fetch origin
git merge origin/<branch-name>
```

Resolve any reported conflicts, then continue or complete the merge as Git
instructs.

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
