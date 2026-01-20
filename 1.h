#include <Foundation/Foundation.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <mach/mach_traps.h>

bool Mithril_hasASLR() {
    return TRUE;

    const struct mach_header *mach;

    mach = _dyld_get_image_header(1);

    if (mach->flags & MH_PIE) {
        // has aslr enabled
        return TRUE;
    } else {
        // has aslr disabled
        return FALSE;
    }
}

/*
This Function gets the vmaddr slide of the Image at Index 0.
Parameters: nil
Return: the vmaddr slide
*/
long long Mithril_getSlide() {
    return _dyld_get_image_vmaddr_slide(1);
}

/*
This Function calculates the Address if ASLR is enabled or returns the normal offset.
Parameters: The Original Offset
Return: Either the Offset or the New calculated Offset if ASLR is enabled
*/
long long Mithril_calculateAddress(long long offset) {
    if (Mithril_hasASLR()) {
        long long slide = Mithril_getSlide();
        return (slide + offset);
    } else {
        return offset;
    }
}

/*
This function calculates the size of the data passed as an argument.
It returns 1 if 4 bytes and 0 if 2 bytes
Parameters: data to be written
Return: True = 4 bytes/higher or False = 2 bytes
*/
bool Mithril_getType(unsigned int data) {
    int a = data & 0xffff8000;
    int b = a + 0x00008000;
    int c = b & 0xffff7fff;
    return c;
}

/*
This is the main Function. This is where the writing takes place.
It declares the port as mach_task_self, calculates the offset.
Then it changes the Protections at the offset to be able to write to it.
After that it sets the Protections back so the Apps runs as before
Then it vm_writes either 4 Byte or 2 to the address.
Parameters: the address and the data to be written
Return: True = Success or False = Failed
*/
bool Mithril_vmWriteData(long long offset, unsigned int data) {
    // declaring variables
    kern_return_t err;
    mach_port_t port = mach_task_self();
    long long address = Mithril_calculateAddress(offset);

    // set memory protections to allow us writing code there
    err = vm_protect(port, (long long)address, sizeof(data), NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);

    // check if the protection fails
    if (err != KERN_SUCCESS) {
        return FALSE;
    }

    // vm_write code to memory
    if (Mithril_getType(data)) {
        data = CFSwapInt32(data);
        err = vm_write(port, address, (long long)&data, sizeof(data));
    } else {
        data = (unsigned short)data;
        data = CFSwapInt16(data);
        err = vm_write(port, address, (long long)&data, sizeof(data));
    }
    if (err != KERN_SUCCESS) {
        return FALSE;
    }

    // set the protections back to normal so the app can access this address as usual
    err = vm_protect(port, (long long)address, sizeof(data), NO, VM_PROT_READ | VM_PROT_EXECUTE);

    return TRUE;
}