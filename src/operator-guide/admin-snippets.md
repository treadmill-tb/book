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
 
