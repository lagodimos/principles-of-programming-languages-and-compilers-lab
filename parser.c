#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "parser.h"

void check_title(char text[]) {
    int len = strlen(text) - count_trailing_whitespace(text);

    if (len > 60) {
        char error[] = "Title length should not exceed 60 characters.";
        yyerror(error);
    }
}

int count_trailing_whitespace(const char string[]) {
    int len = strlen(string);
    int count = 0;
    if (len == 0) return 0;
    int i = len - 1;
    while (i >= 0 && isspace((unsigned char)string[i])) {
        count++;
        i--;
    }
    return count;
}

Attribute *find_attribute(char name[], Array attributes_array) {
    Attribute *attributes = attributes_array.values;
    for (int i = 0; i < *attributes_array.size; i++) {
        if (strcmp(name, attributes[i].name) == 0) {
            return &attributes[i];
        }
    }

    return NULL;
}

void array_reset(Array attributes_array) {
    Attribute *attributes = attributes_array.values;

    while (*attributes_array.size != 0) {
        (*attributes_array.size)--;

        free(attributes[*attributes_array.size].name);
        free(attributes[*attributes_array.size].value);
    }
}

void array_print(Array attributes_array) {
    Attribute *attributes = attributes_array.values;

    for (int i = 0; i < *attributes_array.size; i++) {
        printf("%s\t%s\n", attributes[i].name, attributes[i].value);
    }
}

void append_id(Array ids_array, char value[], char tag_type[]) {
    ID *ids = ids_array.values;
    char *id = malloc((strlen(value) + 1) * sizeof(char));
    strcpy(id, value);
    value = id;

    for (int i = 0; i < *ids_array.size; i++) {
        if (strcmp(value, ids[i].value) == 0) {
            char error[100];
            sprintf(error, "Second tag with id '%s'.", ids[i].value);
            yyerror(error);
        }
    }

    ids[*ids_array.size].tag_type = tag_type;
    ids[*ids_array.size].value = value;
    (*ids_array.size)++;

    print_ids(ids_array);
}

void print_ids(Array ids_array) {
    ID *ids = ids_array.values;

    printf("--- IDs ---\n");
    for (int i = 0; i < *ids_array.size; i++) {
        printf("%s: %s\n", ids[i].tag_type, ids[i].value);
    }
}

void append_for_id(Array for_ids_array, char for_id[]) {
    char **for_ids = for_ids_array.values;

    for (int i = 0; i < *for_ids_array.size; i++) {
        if (strcmp(for_id, for_ids[*for_ids_array.size - 1]) == 0) {
            char error[100];
            sprintf(error, "Second for attribute with value '%s'", for_id);
            yyerror(error);
        }
    }

    for_ids[*for_ids_array.size] = malloc((strlen(for_id) + 1) * sizeof(char));
    strcpy(for_ids[*for_ids_array.size], for_id);
    (*for_ids_array.size)++;

    print_for_ids(for_ids_array);
}

void check_for_ids(Array for_ids_array, Array ids_array) {
    ID *ids = ids_array.values;
    char **for_ids = for_ids_array.values;
    int found_tag_with_id;

    for (int i = 0; i < *for_ids_array.size; i++) {
        found_tag_with_id = 0;

        for (int j = 0; j < *ids_array.size && found_tag_with_id == 0; j++) {
            if (strcmp(for_ids[i], ids[j].value) == 0 &&
                strcmp("input", ids[j].tag_type) == 0
            ) {
                found_tag_with_id = 1;
            }
        }

        if (found_tag_with_id == 0) {
            char error[100];
            sprintf(error, "Could not find input tag with id '%s'", for_ids[i]);
            yyerror(error);
        }
    }
}

void print_for_ids(Array for_ids_array) {
    char **for_ids = for_ids_array.values;

    printf("--- for IDs ---\n");
    for (int i = 0; i < *for_ids_array.size; i++) {
        printf("%s\n", for_ids[i]);
    }
}

AttributeRule new_attribute_rule(const char name[], int max_occurrences, int is_optional) {
    AttributeRule rule;
    rule.name = name;
    rule.max_occurrences = max_occurrences;
    rule.is_optional = is_optional;
    rule.count = 0;

    return rule;
}

void check_meta_attributes(Array attributes_array) {
    int charset_count = 0;
    int name_count = 0;
    int content_count = 0;

    Attribute *attributes = attributes_array.values;

    for (int i = 0; i < *attributes_array.size; i++) {
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
            array_print(attributes_array);
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

void check_attributes(Array attributes_array, const char tag[], int rule_count, AttributeRule rules[]) {
    AttributeRule *rule;

    Attribute *attributes = attributes_array.values;

    for (int i = 0; i < *attributes_array.size; i++) {
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

        if (strcmp(attributes[i].name, "style") == 0) {
            check_style_attr(attributes[i].value);
        }
    }

    for (int i = 0; i < rule_count; i++) {
        if (rules[i].is_optional == 0 && rules[i].count == 0) {
            required_attribute_not_found(tag, rules[i].name);
        }
    }
}

AttributeRule *find_attribute_rule(const char name[], int rule_count, AttributeRule rules[]) {
    for (int i = 0; i < rule_count; i++) {
        if (strcmp(name, rules[i].name) == 0) {
            return &rules[i];
        }
    }

    return NULL;
}

void check_value_is_natural(char string[]) {
    char error[] = "Value of height/width must be a natural number.";

    for (int i = 0; string[i] != '\0'; i++) {
        if (! isdigit(string[i])) {
            yyerror(error);
        }
    }
}

void check_if_is_valid_url(char attribute[], char value[]) {
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
        sprintf(error, "Not allowed character in '%s' attribute: '%c'", attribute, value[--i]);
        yyerror(error);
    }
}

void check_style_attr(char value[]) {
    printf("--- Style: %s\n", value);
}

void required_attribute_not_found(const char tag[], const char name[]) {
    char error[100];

    sprintf(error, "Required attribute '%s' not found in '%s' tag.", name, tag);
    yyerror(error);
}

void exceeded_occur(const char tag[], const char name[], int max) {
    char error[100];

    sprintf(error, "Exceeded max occurrences of attribute '%s\' in '%s' tag.", name, tag);
    yyerror(error);
}

void invalid_attribute(const char tag[], const char name[]) {
    char error[100];

    sprintf(error, "Invalid attribute '%s' in '%s' tag ", name, tag);
    yyerror(error);
}

void yyerror(const char s[]) {
    fprintf(stderr, "Error: %s\n", s);
    exit(1);
}
