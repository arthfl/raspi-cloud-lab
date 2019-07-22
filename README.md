# Poor humans home lab

This repo  provides various means of automation to manage a given set of Raspberry 
Pis in a nice way.
The idea behind this is, to give you more time to do the interesting things in your lab.

Most of the automation that's happening on the remote hosts, is done via Ansible.
Local convenience scripts will mostly be done with Bash.

## Structure
* [ansible](ansible/) - Ansible playbooks and roles
* [scripts](scripts/) - Convenience scripts to be run locally

## Hardware
Raspberry Pi (2 and/or 3)

### Known limitations
* For a K8S master node, you'll need at least a Raspi 3. The v2 doesn't seem to have
enough bang.
