#include "inbf.h"
#include <stdio.h>
#include <stdlib.h>

int main() {

    // Create a compound
    inbf_value_t* compound = inbf_value_create_compound();

    // Add some values to it
    int err = inbf_value_set_compoundv(compound, "a", inbf_value_create_f32(24.0f));
    err = inbf_value_set_compoundv(compound, "b", inbf_value_create_string("uwu?"));
    err = inbf_value_set_compoundv(compound, "c", inbf_value_create_string("awawa?"));


    // Get the float value out of the compound
    float v;
    inbf_value_t* ftarget;
    err = inbf_value_get_compoundv(compound, "a", &ftarget);
    if (err == INBF_ERROR) printf("1: %s\n", inbf_error_get());
    
    err = inbf_value_get_f32(ftarget, &v);
    if (err == INBF_ERROR) printf("2: %s\n", inbf_error_get());

    // Get the string value out of the compound
    const char *text;
    err = inbf_value_get_compoundv(compound, "b", &ftarget);
    if (err == INBF_ERROR) printf("3: %s\n", inbf_error_get());

    err = inbf_value_get_string(ftarget, &text);
    if (err == INBF_ERROR) printf("4: %s\n", inbf_error_get());

    // Get the string value out of the compound
    const char *text2;
    err = inbf_value_get_compoundv(compound, "c", &ftarget);
    if (err == INBF_ERROR) printf("3: %s\n", inbf_error_get());

    err = inbf_value_get_string(ftarget, &text2);
    if (err == INBF_ERROR) printf("4: %s\n", inbf_error_get());

    printf("%s %f %s\n", text, v, text2);

    free(text);
    free(text2);
    return 0;
}