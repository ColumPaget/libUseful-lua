%module securemem
%{
#include "libUseful-3/SecureMem.h"
#include "libUseful-3/Errors.h"
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


