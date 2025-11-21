
## 💬 **Question:**

> “What is the difference between `adduser` and `useradd` in Linux?”

---

## ✅ **Short Answer:**

> **`useradd`** is a **low-level command** to create a new user, while **`adduser`** is a **high-level, user-friendly command** that uses `useradd` in the background and provides interactive prompts.

---

## 🧩 **Detailed Explanation**

| Feature                      | `useradd`                                             | `adduser`                                           |
| ---------------------------- | ----------------------------------------------------- | --------------------------------------------------- |
| **Type**                     | Low-level command (binary)                            | High-level Perl script                              |
| **Package**                  | Comes with base Linux system (`shadow` package)       | Comes with `adduser` package (mostly Debian/Ubuntu) |
| **Interaction**              | Non-interactive (you must specify options manually)   | Interactive — asks for password, full name, etc.    |
| **Ease of use**              | Requires specifying home directory, shell, etc.       | Automatically creates home directory, sets defaults |
| **Example OS**               | Available on all Linux systems (RHEL, CentOS, Ubuntu) | Common on Debian-based systems (Ubuntu)             |
| **Home directory creation**  | Use `-m` flag (manual)                                | Automatically creates it                            |
| **Default shell and groups** | Must define with flags (`-s`, `-G`)                   | Automatically sets defaults                         |

---

## 🧪 **Example Usage**

### **Using `useradd`**

```bash
sudo useradd -m -s /bin/bash john
sudo passwd john
```

* `-m`: Create home directory
* `-s`: Specify shell

If you forget the flags, `useradd` won’t create a home directory automatically.

---

### **Using `adduser`**

```bash
sudo adduser john
```

Then it will interactively ask:

```
Adding user `john' ...
Creating home directory `/home/john' ...
Copying files from `/etc/skel' ...
Enter new UNIX password:
Retype new UNIX password:
Full Name []:
Room Number []:
Work Phone []:
Home Phone []:
Other []:
```

✅ Much more user-friendly.

---

## 🧠 **Interview-Ready Summary**

> “`useradd` is a low-level command that simply creates the user and requires you to specify all options manually, while `adduser` is a high-level interactive script that uses `useradd` in the background and automatically handles tasks like creating home directories and setting up passwords.
>
> So, in practice — `useradd` is used in scripts or automation, and `adduser` is used for manual administration.”

---

Would you like me to include a **comparison diagram** showing the workflow difference (how `adduser` internally calls `useradd`)?

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/f4603859-c760-476a-bf0a-066bd167b329" />

