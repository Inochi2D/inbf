#include "inbf.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int main() {

    // Create a compound
    inbf_value_t* compound = inbf_value_create_compound();

    // Add some values to it
    assert(inbf_value_set_compoundv(compound, "a", inbf_value_create_f32(24.0f)) == INBF_SUCCESS);
    assert(inbf_value_set_compoundv(compound, "b", inbf_value_create_string("uwu?")) == INBF_SUCCESS);
    assert(inbf_value_set_compoundv(compound, "c", inbf_value_create_string("awawa?")) == INBF_SUCCESS);

    inbf_value_t* ftarget;

    // Get the float value out of the compound
    float v;
    assert(inbf_value_get_compoundv(compound, "a", &ftarget) == INBF_SUCCESS);
    assert(inbf_value_get_f32(ftarget, &v) == INBF_SUCCESS);

    // Get the string value out of the compound
    const char *text;
    assert(inbf_value_get_compoundv(compound, "b", &ftarget) == INBF_SUCCESS);
    assert(inbf_value_get_string(ftarget, &text) == INBF_SUCCESS);

    // Get the string value out of the compound
    const char *text2;
    assert(inbf_value_get_compoundv(compound, "c", &ftarget) == INBF_SUCCESS);
    assert(inbf_value_get_string(ftarget, &text2) == INBF_SUCCESS);

    printf("%s %f %s\n", text, v, text2);

    free(text);
    free(text2);
    return 0;
}