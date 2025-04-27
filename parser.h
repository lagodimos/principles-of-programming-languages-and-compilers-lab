#pragma once

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

typedef struct array {
    int *size;
    void *values;
} Array;

void array_reset(Array attributes_array);
void array_print(Array attributes_array);

AttributeRule new_attribute_rule(const char name[], int max_occurrences, int is_optional);
void check_meta_attributes(Array attributes_array);
void check_attributes(Array attributes_array, const char name[], int count, AttributeRule rules[]);
AttributeRule *find_attribute_rule(const char name[], int count, AttributeRule attributes[]);

void check_value_is_natural(char string[]);

void required_attribute_not_found(const char tag[], const char name[]);
void exceeded_occur(const char tag[], const char name[], int max);
void invalid_attribute(const char tag[], const char name[]);

int yylex();
void yyerror(const char s[]);
