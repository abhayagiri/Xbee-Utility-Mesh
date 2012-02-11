#include "WProgram.h"
#include "CppNewDelete.h"

void* operator new(size_t size) { return malloc(size); };
void* operator new[](size_t size)  { return malloc(size); };
void operator delete(void* ptr) { //if (ptr) 
									free(ptr); };
void operator delete[](void* ptr) { //if (ptr) 
									free(ptr); };