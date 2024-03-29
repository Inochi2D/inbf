// Automatically generated by LDC Compiler

#pragma once

#include <assert.h>
#include <math.h>
#include <stddef.h>
#include <stdint.h>

#define INBF_ERROR 0
#define INBF_SUCCESS 1

#ifdef __cplusplus
extern "C" {
#endif

const char *inbf_error_get();

typedef struct inbf_value inbf_value_t;

inbf_value_t* inbf_value_create_i8(int8_t value);

inbf_value_t* inbf_value_create_i16(int16_t value);

inbf_value_t* inbf_value_create_i32(int32_t value);

inbf_value_t* inbf_value_create_i64(int64_t value);

inbf_value_t* inbf_value_create_u8(uint8_t value);

inbf_value_t* inbf_value_create_u16(uint16_t value);

inbf_value_t* inbf_value_create_u32(uint32_t value);

inbf_value_t* inbf_value_create_u64(uint64_t value);

inbf_value_t* inbf_value_create_f32(float value);

inbf_value_t* inbf_value_create_f64(double value);

inbf_value_t* inbf_value_create_string(const char *value);

inbf_value_t* inbf_value_create_compound();

inbf_value_t* inbf_value_create_array(inbf_value_t* fitem);

int32_t inbf_value_destroy(inbf_value_t* value);

int32_t inbf_value_get_i8(inbf_value_t* value, int8_t* target);

int32_t inbf_value_get_i16(inbf_value_t* value, int16_t* target);

int32_t inbf_value_get_i32(inbf_value_t* value, int32_t* target);

int32_t inbf_value_get_i64(inbf_value_t* value, int64_t* target);

int32_t inbf_value_get_u8(inbf_value_t* value, uint8_t* target);

int32_t inbf_value_get_u16(inbf_value_t* value, uint16_t* target);

int32_t inbf_value_get_u32(inbf_value_t* value, uint32_t* target);

int32_t inbf_value_get_u64(inbf_value_t* value, uint64_t* target);

int32_t inbf_value_get_f32(inbf_value_t* value, float* target);

int32_t inbf_value_get_f64(inbf_value_t* value, double* target);

int32_t inbf_value_get_string(inbf_value_t* value, const char **target);

int32_t inbf_value_get_compoundv(inbf_value_t* value, const char *key, inbf_value_t** target);

int32_t inbf_value_set_compoundv(inbf_value_t* target, const char *key, inbf_value_t* value);

int32_t inbf_value_remove_compoundv(inbf_value_t* target, const char *key);

int32_t inbf_value_get_arrayv(inbf_value_t* value, size_t i, inbf_value_t** target);


#ifdef __cplusplus
}
#endif