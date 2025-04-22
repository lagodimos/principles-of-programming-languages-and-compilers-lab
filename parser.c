#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "parser.h"

void check_title(char *text) {
    int len = strlen(text) - count_trailing_whitespace(text);

    if (len > 60) {
        char error[] = "Title length should not exceed 60 characters.";
        yyerror(error);
    }
}

int count_trailing_whitespace(const char *str) {
    int len = strlen(str);
    int count = 0;
    if (len == 0) return 0;
    int i = len - 1;
    while (i >= 0 && isspace((unsigned char)str[i])) {
        count++;
        i--;
    }
    return count;
}

void array_reset(int *top, Attribute attributes[]) {
    while(*top != -1) {
        free(attributes[*top].name);
        free(attributes[*top].value);

        (*top)--;
    }
}

void array_print(int *top, Attribute attributes[]) {
    for (int i = 0; i < *top + 1; i++) {
        printf("%s\t%s\n", attributes[i].name, attributes[i].value);
    }
}

AttributeRule new_attribute_rule(const char *name, int max_occurrences, int is_optional) {
    AttributeRule rule;
    rule.name = name;
    rule.max_occurrences = max_occurrences;
    rule.is_optional = is_optional;
    rule.count = 0;

    return rule;
}

void check_meta_attributes(int *top, Attribute attributes[]) {
    int charset_count = 0;
    int name_count = 0;
    int content_count = 0;

    for (int i = 0; i < *top + 1; i++) {
        if (strcmp(attributes[i].name, "charset") == 0) {
            charset_count++;
        }
        else if (strcmp(attributes[i].name, "name") == 0) {
            name_count++;
        }
        else if (strcmp(attributes[i].name, "content") == 0) {
            content_count++;
        }
        else {
            invalid_attribute("meta", attributes[i].name);
        }
    }

    if (!(
        (charset_count == 1 && name_count == 0 && content_count == 0)
        ||  (charset_count == 0 && name_count == 1 && content_count == 1)
    ))
    {        char error[] = "Meta tag contains either one charset or one name and one content attribute.";
        yyerror(error);
    }
}

void check_attributes(int *top, Attribute attributes[], const char *tag, int rule_count, AttributeRule rules[]) {
    AttributeRule *rule;

    for (int i = 0; i < *top + 1; i++) {
        rule = find_attribute_rule(attributes[i].name, rule_count, rules);
        if (rule != NULL) {
            rule->count++;
            if (rule->count > rule->max_occurrences) {
                exceeded_occur(tag, attributes[i].name, rule->max_occurrences);
            }
        }
        else {
            invalid_attribute(tag, attributes[i].name);
        }

        /* Check attribute values */

        if (strcmp(attributes[i].name, "width") == 0 ||
            strcmp(attributes[i].name, "height") == 0
        ) {
            check_value_is_natural(attributes[i].value);
        }

        if (
            strcmp(attributes[i].name, "src") == 0 ||
            strcmp(attributes[i].name, "href") == 0
        ) {
            check_if_is_valid_url(attributes[i].name, attributes[i].value);
        }
    }

    for (int i = 0; i < rule_count; i++) {
        if (rules[i].is_optional == 0 && rules[i].count == 0) {
            required_attribute_not_found(tag, rules[i].name);
        }
    }
}

AttributeRule *find_attribute_rule(const char *name, int rule_count, AttributeRule rules[]) {
    for (int i = 0; i < rule_count; i++) {
        if (strcmp(name, rules[i].name) == 0) {
            return &rules[i];
        }
    }

    return NULL;
}

void check_value_is_natural(char *string) {
    char error[] = "Value of height/width must be a natural number.";

    for (int i = 0; string[i] != '\0'; i++) {
        if (! isdigit(string[i])) {
            yyerror(error);
        }
    }
}

void check_if_is_valid_url(char *attribute, char *value) {
    char error[100];

    int valid = 1;
    int i;
    for (i = 0; valid == 1 && i < strlen(value); i++) {
        if (
            value[i] < 32 ||
            value[i] == 127 ||
            value[i] == '<' ||
            value[i] == '>' ||
            value[i] == '{' ||
            value[i] == '}' ||
            value[i] == '|' ||
            value[i] == '\\' ||
            value[i] == '^' ||
            value[i] == '~' ||
            value[i] == '"'
        ) {
            valid = 0;
        }
    }

    if (valid == 0) {
        sprintf(error, "Not allowed character in %s attribute: '%c'", attribute, value[--i]);
        yyerror(error);
    }
}

void required_attribute_not_found(const char *tag, const char *name) {
    char error[100];

    sprintf(error, "Required attribute \"%s\" not found in %s tag.", name, tag);
    yyerror(error);
}

void exceeded_occur(const char *tag, const char *name, int max) {
    char error[100];

    sprintf(error, "Exceeded max occurrences of attribute \"%s\" in %s tag.", name, tag);
    yyerror(error);
}

void invalid_attribute(const char *tag, const char *name) {
    char error[100];

    sprintf(error, "Invalid attribute \"%s\" in %s tag ", name, tag);
    yyerror(error);
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    exit(1);
}
