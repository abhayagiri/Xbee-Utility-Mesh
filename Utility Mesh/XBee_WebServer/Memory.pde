///*
// * Cut-and-pasted from www.arduino.cc playground section for determining heap and stack pointer locations.
// * http://www.arduino.cc/playground/Code/AvailableMemory
// *
// * Also taken from the Pololu thread from Paul at: http://forum.pololu.com/viewtopic.php?f=10&t=989&view=unread#p4218
// *
// * Reference figure of AVR memory areas .data, .bss, heap (all growing upwards), then stack growing downward:
// * http://www.nongnu.org/avr-libc/user-manual/malloc.html
// *
// */

#include <avr/pgmspace.h>

extern unsigned int __data_start;
extern unsigned int __data_end;
extern unsigned int __bss_start;
extern unsigned int __bss_end;
extern unsigned int __heap_start;
//extern void *__malloc_heap_start; --> apparently already declared as char*
//extern void *__malloc_margin; --> apparently already declared as a size_t
extern void *__brkval;
// RAMEND and SP seem to be available without declaration here

int16_t ramSize=0;   // total amount of ram available for partitioning
int16_t dataSize=0;  // partition size for .data section
int16_t bssSize=0;   // partition size for .bss section
int16_t heapSize=0;  // partition size for current snapshot of the heap section
int16_t stackSize=0; // partition size for current snapshot of the stack section
int16_t freeMem1=0;  // available ram calculation #1
int16_t freeMem2=0;  // available ram calculation #2


/* This function places the current value of the heap and stack pointers in the
 * variables. You can call it from any place in your code and save the data for
 * outputting or displaying later. This allows you to check at different parts of
 * your program flow.
 * The stack pointer starts at the top of RAM and grows downwards. The heap pointer
 * starts just above the static variables etc. and grows upwards. SP should always
 * be larger than HP or you'll be in big trouble! The smaller the gap, the more
 * careful you need to be. Julian Gall 6-Feb-2009.
 */
uint8_t *heapptr, *stackptr;
uint16_t diff=0;
void check_mem() {
  stackptr = (uint8_t *)malloc(4);          // use stackptr temporarily
  heapptr = stackptr;                     // save value of heap pointer
  free(stackptr);      // free up the memory again (sets stackptr to 0)
  stackptr =  (uint8_t *)(SP);           // save value of stack pointer
}


/* Stack and heap memory collision detector from: http://forum.pololu.com/viewtopic.php?f=10&t=989&view=unread#p4218
 * (found this link and good discussion from: http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1213583720%3Bstart=all )
 * The idea is that you need to subtract your current stack pointer (conveniently given by the address of a local variable)
 * from a pointer to the top of the static variable memory (__bss_end). If malloc() is being used, the top of the heap
 * (__brkval) needs to be used instead. In a simple test, this function seemed to do the job, showing memory gradually
 * being used up until, with around 29 bytes free, the program started behaving erratically.
 */

int get_free_memory()
{
  int free_memory;

  if((int)__brkval == 0)
     free_memory = ((int)&free_memory) - ((int)&__bss_end);
  else
    free_memory = ((int)&free_memory) - ((int)__brkval);

  return free_memory;
}


void printMemoryProfile()                     // run over and over again
{
  print_p( PSTR("\n\n--------------------------------------------") );
  print_p( PSTR("\n\nget_free_memory() reports [") );
  Serial.print( get_free_memory() );
  print_p( PSTR("] (bytes) which must be > 0 for no heap/stack collision") );
  

  print_p( PSTR("\n\nSP should always be larger than HP or you'll be in big trouble!") );
  
  check_mem();

  print_p( PSTR("\nheapptr=[0x") ); Serial.print( (int) heapptr, HEX); print_p( PSTR("] (growing upward, ") ); Serial.print( (int) heapptr, DEC); print_p( PSTR(" decimal)") );
  
  print_p( PSTR("\nstackptr=[0x") ); Serial.print( (int) stackptr, HEX); print_p( PSTR("] (growing downward, ") ); Serial.print( (int) stackptr, DEC); print_p( PSTR(" decimal)") );
  
  print_p( PSTR("\ndiff=stackptr-heapptr, diff=[0x") );
  diff=stackptr-heapptr;
  Serial.print( (int) diff, HEX); print_p( PSTR("] (which is [") ); Serial.print( (int) diff, DEC); print_p( PSTR("] (bytes decimal)") );
  
  
  print_p( PSTR("\n\nLOOP END: get_free_memory() reports [") );
  Serial.print( get_free_memory() );
  print_p( PSTR("] (bytes) which must be > 0 for no heap/stack collision") );
  
  
  // ---------------- Print memory profile -----------------
  print_p( PSTR("\n\n__data_start=[0x") ); Serial.print( (int) &__data_start, HEX ); print_p( PSTR("] which is [") ); Serial.print( (int) &__data_start, DEC); print_p( PSTR("] bytes decimal") );

  print_p( PSTR("\n__data_end=[0x") ); Serial.print((int) &__data_end, HEX ); print_p( PSTR("] which is [") ); Serial.print( (int) &__data_end, DEC); print_p( PSTR("] bytes decimal") );
  
  print_p( PSTR("\n__bss_start=[0x") ); Serial.print((int) & __bss_start, HEX ); print_p( PSTR("] which is [") ); Serial.print( (int) &__bss_start, DEC); print_p( PSTR("] bytes decimal") );

  print_p( PSTR("\n__bss_end=[0x") ); Serial.print( (int) &__bss_end, HEX ); print_p( PSTR("] which is [") ); Serial.print( (int) &__bss_end, DEC); print_p( PSTR("] bytes decimal") );

  print_p( PSTR("\n__heap_start=[0x") ); Serial.print( (int) &__heap_start, HEX ); print_p( PSTR("] which is [") ); Serial.print( (int) &__heap_start, DEC); print_p( PSTR("] bytes decimal") );

  print_p( PSTR("\n__malloc_heap_start=[0x") ); Serial.print( (int) __malloc_heap_start, HEX ); print_p( PSTR("] which is [") ); Serial.print( (int) __malloc_heap_start, DEC); print_p( PSTR("] bytes decimal") );

  print_p( PSTR("\n__malloc_margin=[0x") ); Serial.print( (int) &__malloc_margin, HEX ); print_p( PSTR("] which is [") ); Serial.print( (int) &__malloc_margin, DEC); print_p( PSTR("] bytes decimal") );

  print_p( PSTR("\n__brkval=[0x") ); Serial.print( (int) __brkval, HEX ); print_p( PSTR("] which is [") ); Serial.print( (int) __brkval, DEC); print_p( PSTR("] bytes decimal") );

  print_p( PSTR("\nSP=[0x") ); Serial.print( (int) SP, HEX ); print_p( PSTR("] which is [") ); Serial.print( (int) SP, DEC); print_p( PSTR("] bytes decimal") );

  print_p( PSTR("\nRAMEND=[0x") ); Serial.print( (int) RAMEND, HEX ); print_p( PSTR("] which is [") ); Serial.print( (int) RAMEND, DEC); print_p( PSTR("] bytes decimal") );

  // summaries:
  ramSize   = (int) RAMEND       - (int) &__data_start;
  dataSize  = (int) &__data_end  - (int) &__data_start;
  bssSize   = (int) &__bss_end   - (int) &__bss_start;
  heapSize  = (int) __brkval     - (int) &__heap_start;
  stackSize = (int) RAMEND       - (int) SP;
  freeMem1  = (int) SP           - (int) __brkval;
  freeMem2  = ramSize - stackSize - heapSize - bssSize - dataSize;
  print_p( PSTR("\n--- section size summaries ---") );
  print_p( PSTR("\nram   size=[") ); Serial.print( ramSize, DEC ); print_p( PSTR("] bytes decimal") );
  print_p( PSTR("\n.data size=[") ); Serial.print( dataSize, DEC ); print_p( PSTR("] bytes decimal") );
  print_p( PSTR("\n.bss  size=[") ); Serial.print( bssSize, DEC ); print_p( PSTR("] bytes decimal") );
  print_p( PSTR("\nheap  size=[") ); Serial.print( heapSize, DEC ); print_p( PSTR("] bytes decimal") );
  print_p( PSTR("\nstack size=[") ); Serial.print( stackSize, DEC ); print_p( PSTR("] bytes decimal") );
  print_p( PSTR("\nfree size1=[") ); Serial.print( freeMem1, DEC ); print_p( PSTR("] bytes decimal") );
  print_p( PSTR("\nfree size2=[") ); Serial.print( freeMem2, DEC ); print_p( PSTR("] bytes decimal") );
  
  delay(3000);
 
}

void print_p(char *msg) {
    while (pgm_read_byte(msg) != 0x00)
      Serial.print(pgm_read_byte(msg++));
}

void println_p(char *msg) {
    while (pgm_read_byte(msg) != 0x00)
      Serial.print(pgm_read_byte(msg++));
  
    Serial.println("");
}
