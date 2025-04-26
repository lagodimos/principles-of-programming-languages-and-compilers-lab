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

void check_title(char text[]);

int count_trailing_whitespace(const char string[]);

Attribute *find_attribute(char name[], int top, Attribute attributes[]);
void array_reset(int *top, Attribute attributes[]);
void array_print(int *top, Attribute attributes[]);

void append_id(int *ids_top, ID ids[], char value[], char tag_type[]);
void print_ids(int ids_top, ID ids[]);

void append_for_id(int *for_ids_top, char *for_ids[], char for_id[]);
void check_for_ids(int for_ids_top, char *for_ids[], int ids_top, ID ids[]);
void print_for_ids(int for_ids_top, char *for_ids[]);

AttributeRule new_attribute_rule(const char name[], int max_occurrences, int is_optional);
void check_meta_attributes(int *top, Attribute attributes[]);
void check_attributes(int *top, Attribute attributes[], const char name[], int count, AttributeRule rules[]);
AttributeRule *find_attribute_rule(const char name[], int count, AttributeRule attributes[]);

void check_value_is_natural(char string[]);
void check_if_is_valid_url(char attribute[], char value[]);

void check_style_attr(char value[]);

void required_attribute_not_found(const char tag[], const char name[]);
void exceeded_occur(const char tag[], const char name[], int max);
void invalid_attribute(const char tag[], const char name[]);

int yylex();
void yyerror(const char s[]);
