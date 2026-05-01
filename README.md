Secure File Sharing Tool (CLI)

Project Overview

This project implements a secure file sharing system using command-line tools for encrypting, transferring, and verifying files.

Testing Environment

This system was tested locally on a single machine (`localhost`), simulating both:

* Sender
* Receiver

No external server was used. SSH and file transfer were performed using the local system to demonstrate the complete workflow safely.

Prerequisites

Before Starting check inside Terminal whether the following Prerequistis are present: 

1. Bash

* Used to write and execute scripts
* Pre-installed on macOS

2. OpenSSH (Provided)

* Provided by instructor
* Used for:

  * `ssh`
  * `scp`
  * `ssh-keygen`

Check command:

```bash
ssh -V
```

3. Installed `age` ~ I already had Homebrew

macOS:

```bash
brew install age
```

Verify:

```bash
age --version
```
4. Checksum Tool

macOS:

```bash
shasum -a 256
```
Command line and Work Flow for  Project Setup (Folder Creation)

1. Creating a Project Folder

```bash
Go inside Desktop ~ cd ~/Desktop
Create a folder ~ mkdir secure-share
Go inside this folder ~ cd secure-share
```

2. Creating the Required Files inside secure-share

```bash
touch send.sh receive.sh setup_keys.sh transfer.log README.md
```

3. Making the Scripts Executable

```bash
chmod +x send.sh receive.sh setup_keys.sh
```

4. Verify Files

```bash
ls
```

Output:

```
README.md    receive.sh    send.sh    setup_keys.sh    transfer.log
```

2. Key Setup

Run:

```bash
./setup_keys.sh
nano ./setup_keys.sh ~ write the command line control+O >  return > control+X
```

What it does:

* Sets up SSH keys > for secure authentication during file transfer
* Generates AGE key pair > for file encryption and decryption

Command used: 

>SSH Key Generation (Authentication) >

```bash
ssh-keygen -t ed25519
```

Generates a public-private key pair
Stored in:
Private key → ~/.ssh/id_ed25519
Public key → ~/.ssh/id_ed25519pub > Added to ~/.ssh/authorized_keys > Shared with the receiver

>AGE Key Generation (Encryption) >

```bash
age-keygen -o key.txt
```

Output:
public key: age1d8gallccz830dcprarvvkle87qh0salqg90qyyq70scjllfrgvmqd56spn

 
Example output:

```
Setting up SSH...
SSH ready.
Generating AGE key...
Public key: age1d8gallccz830dcprarvvkle87qh0salqg90qyyq70scjllfrgvmqd56spn
Setup complete.
```

️ Notes:

* Public key → shared with sender
* `key.txt` → private key (keep secret)

3. System Workflow

Sender Side

1. Select file
2. Generate checksum
3. Encrypt file
4. Transfer file
5. Log operation

Receiver Side

1. Receive `.age` file
2. Decrypt file
3. Generate checksum
4. Verify integrity

4. Prceducer Used: 

A. Sending a File


Step 1: Create a File to Send (Test Data)

Command: 

```bash
echo "hello world" > test.txt
```

> Creates a sample file test.txt

Used to simulate real data (e.g., reports, notes)

Step 2: Generate Checksum (Integrity Preparation)

Command:

```bash
shasum -a 256 test.txt
```

Example output:
a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447  test.txt

Generates a SHA-256 hash of the file

This checksum is:
>Stored/logged
>Sent to receiver for verification

Ensures the file can be checked for tampering later


Step 3: Encrypting the file: 

Command: 

```bash
age -r age1d8gallccz830dcprarvvkle87qh0salqg90qyyq70scjllfrgvmqd56spn -o test.txt.age test.txt 
```

Output> test.txt.age (encrypted file) 

This is the file that is transferred and the original file remains unchanged. 

Step 4: Transferring the file securely (SSH)

Command: 

```bash
scp test.txt.age localhost:~
```
Example Output: 

test.txt.age 100% 212 627.4KB/s 00:00

Uses SSH (scp) to transfer file
localhost simulates receiver machine
File is copied to receiver’s home directory

Step 5: Logging the Transfer: 

After a file is successfully encrypted and transferred, the system records the operation in a log file named:

transfer.log

At the end of the send.sh script, a log entry is appended using a command similar to:

Command:

```bash
echo "$(date) | $USER | $recipient | $filename | sha256:$checksum | SUCCESS" >> transfer.log"
```

Example Log Entry

Fri May  1 06:13:51 IST 2026 | harmanjot | localhost | test.txt | sha256:a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447 | SUCCESS

Multiple Transfers:

Each new transfer is appended to the log:

Command

```bash
cat transfer.log
```
Example:
Fri May  1 06:13:51 IST 2026 | harmanjot | localhost | test.txt | sha256:... | SUCCESS
Fri May  1 06:18:06 IST 2026 | harmanjot | localhost | log_test.txt | sha256:... | SUCCESS
Fri May  1 06:32:30 IST 2026 | harmanjot | localhost | final.txt | sha256:... | SUCCESS

Maintains a complete history of operations

If an error occurs (e.g., transfer fails), the script records:

FAILED (transfer error)

Example:

Fri May  1 07:00:00 IST 2026 | harmanjot | invalidhost | test.txt | sha256:... | FAILED

Combined Script Execution

All the above steps are automated using:

Command:

```bash
./send.sh test.txt localhost age1d8gallccz830dcprarvvkle87qh0salqg90qyyq70scjllfrgvmqd56spn
```

Output:
Generating checksum...
Checksum: a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447
Encrypting file...
Transferring file...
Done.

Summary: 

Generate checksum → ensures integrity
Encrypt file → ensures confidentiality
Transfer file via SSH → ensures secure communication
Log operation → ensures traceability

Outcome: 

After successful execution:

>Encrypted file is sent to receiver
>Checksum is recorded
>Transfer is logged
>File is ready for secure decryption and verification on receiver side

B. Receiving a File

Step 1: Recieving the Encrypted File

After the sender runs the transfer, the encrypted file is available on the receiver side (in this case, copied to the home directory using scp).

Example file:

~/test.txt.age

Step 2: Decrypting the File (Confidentiality)

Command:

```bash
age -d -i key.txt -o test.txt.dec ~/test.txt.age
```

Output → test.txt.dec

Produces decrypted version of original file.

Step 3: Generate Checksum (Post-Transfer Integrity)

Command: 

```bash
shasum -a 256 test.txt.dec
```

Example output:
a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447  test.txt.dec

Generates checksum of decrypted file

Used to verify file integrity.

Step 4: Verify Checksum (Integrity Check)

Compare the generated checksum with the original checksum provided by the sender

Example:
Expected: a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447
Actual:   a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447

Result: Integrity check Passed

Confirms file was not altered during transfer
If values differ → integrity check fails

Combined Script Execution

All steps are automated using:

Command:

```bash
./receive.sh ~/test.txt.age key.txt a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447
```
Output:

Decrypting file...
Generating checksum...
Verifying checksum...
Integrity check PASSED

Step 5: Verify Content

Command:

```bash
cat test.txt.dec
```

Output:

hello world

Confirms decrypted file matches original content exactly

Outcome:

After successful execution:

File is decrypted correctly
File integrity is verified
Receiver confirms authenticity of data
System ensures secure and reliable file sharing

5. Testings that were performed: 

The system was tested in a local environment (localhost), stimulating both sender and reciever on the same machine.


Test 1: Basic File Transfer and Integrity Check

Step 1: Create Test File

```bash
echo "hello world" > test.txt
```

Step 2: Send File

```bash
./send.sh test.txt localhost age1d8gallccz830dcprarvvkle87qh0salqg90qyyq70scjllfrgvmqd56spn
```

Output:


Generating checksum...
Checksum: a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447
Encrypting file...
Transferring file...
Done.


Step 3: Verify Original Checksum

```bash 
shasum -a 256 test.txt
```

Output:


a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447  test.txt


Step 4: Receive and Decrypt File

```bash 
./receive.sh ~/test.txt.age key.txt a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447
```

Output:

```text id="8m5x8m"
Decrypting file...
Generating checksum...
Verifying checksum...
Integrity check PASSED
```

 Step 5: Verify File Content

```bash
cat test.txt.dec
```

Output:


hello world

> Result

* File decrypted successfully
* Checksum matched
* Integrity check passed
* Content identical to original


Test 2: Logging Functionality

Step 1: Create File

```bash 
echo "logging test" > log_test.txt
```

Step 2: Send File

```bash 
./send.sh log_test.txt localhost age1d8gallccz830dcprarvvkle87qh0salqg90qyyq70scjllfrgvmqd56spn
```

Step 3: Check Log File

```bash 
cat transfer.log
```

Output:

Fri May  1 06:18:06 IST 2026 | harmanjot | localhost | log_test.txt | sha256:1e39138172930802fcb5183a2e4bd06e8a0efd4507ff489c1c8f806364968a2f | SUCCESS

 Result

* Transfer successfully recorded
* Log contains correct timestamp, filename, checksum, and status


Test 3: Multiple Transfers

Step 1: Send File Again

```bash
./send.sh log_test.txt localhost age1d8gallccz830dcprarvvkle87qh0salqg90qyyq70scjllfrgvmqd56spn
```

Step 2: Check Log File

```bash 
cat transfer.log
```

Output:


Fri May  1 06:18:06 IST 2026 | harmanjot | localhost | log_test.txt | sha256:... | SUCCESS
Fri May  1 06:18:52 IST 2026 | harmanjot | localhost | log_test.txt | sha256:... | SUCCESS


 Result

* Multiple entries appended correctly
* No overwriting of previous logs
* System maintains full transfer history

Test 4: Final Verification Test

Step 1: Create File

```bash 
echo "final verification test" > final.txt
```

Step 2: Send File

```bash
./send.sh final.txt localhost age1d8gallccz830dcprarvvkle87qh0salqg90qyyq70scjllfrgvmqd56spn
```

Step 3: Verify Checksum

```bash
shasum -a 256 final.txt
```

Output:

9d4c6968ff710dcd4f488c34091c91aeaa2ac36d56889ecd69bb51cbb3b27d41  final.txt

 Step 4: Receive File

```bash 
./receive.sh ~/final.txt.age key.txt 9d4c6968ff710dcd4f488c34091c91aeaa2ac36d56889ecd69bb51cbb3b27d41
```

Output:

Integrity check PASSED


Step 5: Verify Content

```bash
cat final.txt.dec
```

Output:


final verification test

Result

* End-to-end workflow successful
* Integrity verified
* System works consistently across multiple tests
-

Summary of Testing

The following aspects were successfully verified:

*  Encryption and decryption correctness
*  Secure file transfer using SSH
*  Checksum-based integrity verification
*  Logging of all transfers
*  Handling of repeated operations

Testing Limitations

* All tests were performed on `localhost`
* No real remote server or network conditions were tested


6. Security Features

* Encryption using `age` public key
* Secure transfer using SSH (`scp`)
* SHA-256 checksum verification
* SSH key-based authentication
* Transfer logging


7. Error Handling

Handles:

* Incorrect keys
* Transfer failures
* Checksum mismatch

  I forgot to add missing files to the log so that is not shown in the transfer.log file

Scripts print clear messages and exit safely.


8. Git Repository Setup

Step  1. Initialize Repository

```bash
git init
```


Step 2. Create `.gitignore`

Ignored:

a. Private keys (CRITICAL)
*.pem
*.key
*.pub

b. Encrypted/test outputs
*.enc
*.out

c. Logs (optional — depends on your requirement)
transfer.log

d. System files
.DS_Store

e. Temporary files
*.tmp

Step 3. Add and Commit

```bash
git add .
git commit -m "Initial commit - secure file transfer system using SSH and age"
```

Step 4. Update Commit

```bash
git commit --amend -m "Add .gitignore updates and cleanup logs"
```

Step 5. Remove Log from Tracking

```bash
git rm --cached transfer.log
git commit -m "Remove transfer.log from version control"
```

 Step 6 Connect to GitHub

```bash
git remote add origin https://github.com/HarmanjotKaurBajwa/secure-share.git
git branch -M main
git push -u origin main
```


## Link to my Git repository for secure-share: https://github.com/HarmanjotKaurBajwa/secure-share 


