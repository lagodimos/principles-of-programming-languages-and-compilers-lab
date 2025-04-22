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

int yylex();
void yyerror(const char *s);

void check_title(char *text);

int count_trailing_whitespace(const char *str);

void array_reset(int *top, Attribute attributes[]);
void array_print(int *top, Attribute attributes[]);

AttributeRule new_attribute_rule(const char *name, int max_occurrences, int is_optional);
void check_meta_attributes(int *top, Attribute attributes[]);
void check_attributes(int *top, Attribute attributes[], const char *name, int count, AttributeRule rules[]);
AttributeRule *find_attribute_rule(const char *name, int count, AttributeRule attributes[]);

void check_value_is_natural(char *string);
void check_if_is_valid_url(char *attribute, char *value);

void required_attribute_not_found(const char *tag, const char *name);
void exceeded_occur(const char *tag, const char *name, int max);
void invalid_attribute(const char *tag, const char *name);
