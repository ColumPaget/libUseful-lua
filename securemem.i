%module securemem
%{
#include "libUseful-4/SecureMem.h"
#include "libUseful-4/Errors.h"
%}

typedef struct
{
int Size;
int Flags;
} SECURESTORE;


%extend SECURESTORE {
SECURESTORE (const char *Path)
{
SECURESTORE *Item;

Item=SecureStoreLoad(Path);
return(Item);
}

~SECURESTORE()
{
SecureStoreDestroy($self);
}

}


