#pragma once

#include <stdio.h>

typedef struct attribute {
    char *name;
    char *value;
} Attribute;

typedef struct attribute_rule {
    const char *name;
    int max_occurrences;
    int is_optional;
    int count;  // used by the the checker only
} AttributeRule;

typedef struct tag_id {
    char *value;
    char *tag_type;
} ID;

typedef struct array {
    int *size;
    void *values;
} Array;

void check_title(char text[]);

int count_trailing_whitespace(const char string[]);

Attribute *find_attribute(char name[], Array attributes_array);
void array_reset(Array attributes_array);
void array_print(Array attributes_array);

void append_id(Array ids_array, char value[], char tag_type[]);
void print_ids(Array ids_array);

void append_href_id(Array href_ids_array, char href_id[]);
void check_href_ids(Array href_ids_array, Array ids_array);

void append_for_id(Array for_ids_array, char for_id[]);
void check_for_ids(Array for_ids_array, Array ids_array);
void print_for_ids(Array for_ids_array);

AttributeRule new_attribute_rule(const char name[], int max_occurrences, int is_optional);
void check_meta_attributes(Array attributes_array);
void check_attributes(Array attributes_array, const char name[], int count, AttributeRule rules[]);
AttributeRule *find_attribute_rule(const char name[], int count, AttributeRule attributes[]);

void check_value_is_natural(char string[]);
void check_if_is_valid_url(char attribute[], char value[]);

void check_style_attr(char value[]);
void check_type_attr(char value[]);

void required_attribute_not_found(const char tag[], const char name[]);
void exceeded_occur(const char tag[], const char name[], int max);
void invalid_attribute(const char tag[], const char name[]);

int yylex();
void yyerror(const char s[]);
