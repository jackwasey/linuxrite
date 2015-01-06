# LinuxRite

## Spinrite (tm) for Linux

### Introduction

I know Spinrite by Steve Gibson has its doubters, but I like the thoroughness of his approach to squeeze the last good data out of the disk. What i like most is that by re-writing bad sectors, the disk can usually reallocate them. Just reading sectors usually identifies them as bad, but doesn't lead to reallocation.

Spinrite not only requires booting into DOS (sometimes a difficult to obtain version, which is difficult to write to a USB key), but Spinrite rarely works with big modern disks and EFI or many BIOSes, so I wrote this set of bash scripts to fix a 2TB WD Green which is throwing errors in some areas but otherwise seems okay. Of note, the disk is in an array, and everything is also backed up. With ZFS, I can even re-write the sectors directly to the disk while the disk is active in a mirrored vdev, then run zpool scrub mypool, and the array heals itself.

This is obviously ridiculous behaviour. I don't believe linux md can heal like this if data conflicts appear, so it may trash your md array even further, but you've already got a read error... BTRFS in redundant configuration can probably cope with this abuse, but I haven't tried this at all.

badblocks does something similar but takes many hours per modern disk of several TB. This code focusses on known borderline or bad sectors which are actually in use.

There are a number of critical environment variables which are disk dependent. Many disks these days have 4096 byte physical block layout, but 512b logical layout. For a write of <4096 bytes, a read-write-read cycle has to be performed. Therefore, physical block size should be 4096 in the environment variable, unless you have an older 512b block disk. This allows a straightforward write operation without failing due to read. I think dd 'noerror' would get around this anyway, but 4096 blocks are the right way to go.

The DISK environment variable should be set in local.sh . I separated it out into local-example.sh, and this should be copied and edited. Highly recommend using /dev/disk/by-id path instead of raw device id which can change.

This is really a proof of concept, first draft. I am currently re-running it on my flaky disk and now finding more errors, so the disk is now out of my storage pool

### Workflow

cd badsectors

./reread-bad-sectors.sh

This is read-only, but may still damage a fragile disk. It greps the kernel logs for sector errors, and directly reads those sectors looking for errors. It's output is a list of those sectors which again generated errors. Currently it doesn't even distinguish which drive the sector errors are on, but since it is a read only test, this is fairly harmless since we are just going to read verify some good sectors on the wrong disk, and these won't get passed to the write stage.

./rewrite-bad-sectors.sh

This is a write operation. If all goes well, it should only write to those sectors which had read failures. This should force the drive to reallocate those blocks.
In detail, the write operation writes whatever data may have been recovered from the read step, then reads it back again and compares. It then writes zeroes to the sector, and re-reads them to check they are still zeroes. Finally it again tries to write back the original data which was extracted from the block.

Unlike Spinrite, no great effort is made to preserve existing data: this should already be on the other side of a RAID mirror or other redundancy, and certainly backed-up.

Files left behind are all in /tmp/badsctrs

### New disks

Haven't tried this yet, but running dd to write and read every byte of a new disk would be a minimal stress test, generate kernel error logs for reads, and provide a starting point for running this utility.

### Conclusion
The best use of this utility is probably not on your live production array (although I survived this), but in a separate system used to analyze disks, maybe a VM with direct disk access.


### References
http://sourceforge.net/p/hdparm/discussion/461704/thread/ce9e2318/

