Troubleshooting Secure Boot Issues

To enable Secure Boot functionality, you may need to switch to the 'Other OS' mode in your BIOS settings. Alternatively, you can simply disable Secure Boot and start your system as usual.

During the first boot after system installation, some devices might display a 'MokManager' screen. This MOK (Machine Owner Key) management screen appears only once after making changes to a running system. If you do not register the MOK on the next boot, the key will be discarded, and you will need to restart the process from the beginning.

On this screen, press OK to enter the Shim UEFI Key Management:

![Mokutil tela 1](../screenshots/livecd-mok-01.png)

![Mokutil tela 2](../screenshots/livecd-mok-02.png)

Select 'Enroll key from disk' option:

![Mokutil tela 3](../screenshots/livecd-mok-03.png)

Press ENTER on the 'HFS+ volume' disk:

![Mokutil tela 4](../screenshots/livecd-mok-04.png)

Select the 'ENROLL_THIS_KEY_IN_MOKMANAGER.der' key and press ENTER:

![Mokutil tela 5](../screenshots/livecd-mok-05.png)

Select the 'View Key 0' option and confirm if the 'Issuer' matches the following: 'CN=Secure Boot Signing Key, O=Vipnix, C=BR, ST=Minas Gerais':

![Mokutil tela 6](../screenshots/livecd-mok-06.png)

If the key is the one from the previous step, press 'ENTER' and select the 'Continue' option:

![Mokutil tela 7](../screenshots/livecd-mok-07.png)

Select the 'Yes' option on the 'Enroll the key(s)' screen:

![Mokutil tela 8](../screenshots/livecd-mok-08.png)

Select the 'Reboot' option and start the system normally:

![Mokutil tela 9](../screenshots/livecd-mok-09.png)


