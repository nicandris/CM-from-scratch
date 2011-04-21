-------------------------
This script is *only* needed the first time you want to install all the stuff on your computer. If you have already done that please use the build.sh script from your desktop

This is just a compilation of the wiki/guide given from http://wiki.cyanogenmod.com

Thank [@Cyanogen](http://twitter.com/cyanogen) and [#teamdouche](http://search.twitter.com/search?q=%23teamdouche) for the ROMs and CM7

This is gonna *ake some time and HDD space to complete. If you don't have the time to let the computer running or you dont have 7GB on your HDD please quit and try again when requirements (time/space) meet

-------------------------

A few words from Cyanogen (copied from his posts of nightlies/RCs and stable cm releases)

CyanogenMod is a free, community built distribution of Android 2.3 (Gingerbread) which greatly extends the capabilities of your phone.

    #include <std_disclaimer.h>
    /*
     * Your warranty is now void.
     *
     * I am not responsible for bricked devices, dead SD cards,
     * thermonuclear war, or you getting fired because the alarm app failed. Please
     * do some research if you have any concerns about features included in this ROM
     * before flashing it! YOU are choosing to make these modifications, and if
     * you point the finger at me for messing up your device, I will laugh at you.
     */
 
This is an AOSP-based build with extra contributions from many people which you can use without any type of Google applications. I found a link from some other project that can be used to restore the Google parts, which can be found below or elsewhere in the thread. I've still included the various hardware-specific code, which seems to be slowly being open-sourced anyway.

Visit the [CHANGELOG](http://cyanogenmod.com/changelog) for a full list of changes and features! 

All source code is available at the [CyanogenMod Github!](http://github.com/CyanogenMod)

If you'd like to to contribute to CyanogenMod, checkout our [Gerrit instance.](http://review.cyanogenmod.com/)


##INSTRUCTIONS
**First time flashing CM 7 to your N1 (or coming from another ROM)?**

1. Unlock/root your device and install Clockwork Recovery via ROM Manager or [Amon_RA's recovery image](http://forum.xda-developers.com/showthread.php?t=611829):
3. Update your radio if necessary
4. WIPE
5. Install the ROM
6. Optionally install the Google Addon

**Upgrading from earlier CM7 or nightly build?**

1. Do a Nandroid Backup!
2. Install the ROM (your Google apps will be backed up automatically)

##HOW TO REPORT BUGS OR PROBLEMS?
- Was it a hard reboot? Get me the file "/proc/last_kmsg".
- Was it a soft reboot or a "boot loop"? Run "adb logcat" and get me the full output.
- Pastebin links preferred
- Please use the issue tracker whenever possible!

Please visit the [CyanogenMod Wiki](http://wiki.cyanogenmod.com/) for step-by-step installation walkthroughs and tons of other useful information.

The preferred method of installation is via ROM Manager, or you can head over to the CM Forums for manual downloads.

Thank you to **EVERYONE** involved in helping with testing, coding, debugging and documenting! Enjoy!