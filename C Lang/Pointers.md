```
int value = 42;
int *single_pointer = &value;
int **double_pointer = &single_pointer;

// Dereferencing to access `value`
printf("%d\n", **double_pointer); // 42

---------------------
Modify value using a pointer-to-pointer:

int number = 10;
int *ptr = &number;
int **ptr_ptr = &ptr;

**ptr_ptr = 20;

printf("%d\n", number); // 20

```


