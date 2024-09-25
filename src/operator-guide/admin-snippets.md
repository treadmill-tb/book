# Admin Snippets

## Create a new Switchboard Postgres SQL Database

```
CREATE DATABASE "treadmill_switchboard" WITH OWNER "treadmill_switchboard" ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';
```

## Create a new user with admin privileges

This will prompt for username and email, automatically generate a
password and dump an SQL transaction to insert the user & privilege
assignment into the database:

```
nix-shell -p 'python3.withPackages (pypkgs: with pypkgs; [ argon2-cffi ])' --run 'python3 -c "import uuid; import secrets; import argon2; name = input(\"Name: \"); email = input(\"Email: \"); password = secrets.token_urlsafe(16); hashed = argon2.PasswordHasher().hash(password); print(\"Password:\", password); id = uuid.uuid4(); print(\"\n\nvvvvv CUT HERE vvvvv\n\nbegin;\"); print(f\"INSERT INTO tml_switchboard.users (user_id, name, email, password_hash, user_type, locked) VALUES ('"'"'{id}'"'"', '"'"'{name}'"'"', '"'"'{email}'"'"', '"'"'{hashed}'"'"', '"'"'system'"'"', false);\"); print(f\"INSERT INTO tml_switchboard.user_privileges (user_id, permission) VALUES ('"'"'{id}'"'"', '"'"'admin'"'"');\"); print(\"commit;\n\n^^^^^ CUT HERE ^^^^^\")"'
```

Example output:
```
Name: testificate
Email: foo@example.org
Password: V99gZIffbREGBCGLrfB54A


vvvvv CUT HERE vvvvv

begin;
INSERT INTO tml_switchboard.users (user_id, name, email, password_hash, user_type, locked) VALUES ('e1246bc8-c3b6-4ad7-9d13-a15a2b726a63', 'testificate', 'foo@example.org', '$argon2id$v=19$m=65536,t=3,p=4$Ih9TJgPYrJQFowXzS24Vgw$aGomGlTN1tugKS7HicqtaSBoQzfKVMkU/EOqBA8q1Dw', 'system', false);
INSERT INTO tml_switchboard.user_privileges (user_id, permission) VALUES ('e1246bc8-c3b6-4ad7-9d13-a15a2b726a63', 'admin');
commit;

^^^^^ CUT HERE ^^^^^
```

## Make deployment configuration changes on the supervisor server & push locally

Assuming the Treadmill deployments repo is cloned at
`/var/state/treadmill-deployments` on machine `tockci-pton-srv0`, we
can make local edits to this repository on that machine and test them
immediately:

```
[root@tockci-pton-srv0:/var/state/treadmill-deployments]# echo "hello world" > foo

[root@tockci-pton-srv0:/var/state/treadmill-deployments]# nixos-rebuild test # test the changes
```

Now, assuming that everything works, we want to commit these changes
back to the deployments repository upstream, without giving the
machine push access. For this, create a commit on the remote
machine. We avoid persistently setting a Git committer name or email,
as the machine may be shared amongst multiple admins:

```
[root@tockci-pton-srv0:/var/state/treadmill-deployments]# git \
  -c user.name="Testificate" \
  -c user.email="testificate@example.org" \
  commit -m "Important changes"
[main 161743c] Important changes
 1 file changed, 1 insertion(+)
 create mode 100644 foo
 ```

Now, on your local machine, in the deployments repository, we can
fetch this commit without setting up a git remote like so:

```
testificate@laptop treadmill-tb/deployments (main)> git fetch root@tockci-pton-srv0:/var/state/treadmill-deployments
remote: Enumerating objects: 4, done.
remote: Counting objects: 100% (4/4), done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 1), reused 0 (delta 0), pack-reused 0 (from 0)
Unpacking objects: 100% (3/3), 266 bytes | 266.00 KiB/s, done.
From tockci-pton-srv0:/var/state/treadmill-deployments
 * branch            HEAD       -> FETCH_HEAD
 ```

We can apply these fetched changes onto our local branch like so:

- In case the changes apply cleanly:
  ```
  testificate@laptop treadmill-tb/deployments (main)> git merge --ff-only FETCH_HEAD
  Updating a0c7fd6..161743c
  Fast-forward
   foo | 1 +
   1 file changed, 1 insertion(+)
   create mode 100644 foo
   ```

- In case the refs have diverged:
  ```
  testificate@laptop treadmill-tb/deployments (main)> git rebase FETCH_HEAD
  Successfully rebased and updated refs/heads/main.
  testificate@laptop treadmill-tb/deployments (main)> git rebase origin/main
  Successfully rebased and updated refs/heads/main.
  ```

  In this case, the first rebase puts all the divergent commits on top
  of what we've fetched from the Treadmill supervisor machine, and the
  second inverts this: the machine commits will be applied on top of
  the changes in our push remote. Replace `origin/main` with your
  target branch as appropriate.

Push the changes to the upstream remote:

```
testificate@laptop treadmill-tb/deployments (main)> git push
Enumerating objects: 10, done.
Counting objects: 100% (10/10), done.
Delta compression using up to 16 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (7/7), 815 bytes | 815.00 KiB/s, done.
Total 7 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (2/2), completed with 1 local object.
To github.com:treadmill-tb/deployments.git
   a0c7fd6..161743c  main -> main
```

And finally, fetch the new history back onto the Treadmill supervisor
machine:

```
[root@tockci-pton-srv0:/var/state/treadmill-deployments]# git pull --rebase
From https://github.com/treadmill-tb/deployments
   a0c7fd6..161743c  main       -> origin/main
Already up to date.
```

This last step will sync the (rebased) history back onto the Treadmill
deployments machine.
