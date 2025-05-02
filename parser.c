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

    //print_ids(ids_array);
}

void print_ids(Array ids_array) {
    ID *ids = ids_array.values;

    printf("--- IDs ---\n");
    for (int i = 0; i < *ids_array.size; i++) {
        printf("%s: %s\n", ids[i].tag_type, ids[i].value);
    }
}

void append_href_id(Array href_ids_array, char href_id[]) {
    char **href_ids = href_ids_array.values;

    href_ids[*href_ids_array.size] = malloc((strlen(href_id) + 1) * sizeof(char));
    strcpy(href_ids[*href_ids_array.size], href_id);
    (*href_ids_array.size)++;
}

void check_href_ids(Array href_ids_array, Array ids_array) {
    ID *ids = ids_array.values;
    char **href_ids = href_ids_array.values;
    int found_tag_with_id;

    for (int i = 0; i < *href_ids_array.size; i++) {
        found_tag_with_id = 0;

        for (int j = 0; j < *ids_array.size && found_tag_with_id == 0; j++) {
            if (strcmp(href_ids[i], ids[j].value) == 0) {
                found_tag_with_id = 1;
            }
        }

        if (found_tag_with_id == 0) {
            char error[100];
            sprintf(error, "Could not find tag with id '%s'", href_ids[i]);
            yyerror(error);
        }
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

    //print_for_ids(for_ids_array);
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
            //array_print(attributes_array);
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

        // Checks that need to be done when the
        // whole page is parsed are not done here.
        // e.g. for, href="#..."

        if (strcmp(attributes[i].name, "width") == 0 ||
            strcmp(attributes[i].name, "height") == 0
        ) {
            check_value_is_natural(attributes[i].value);
        }

        if (strcmp(attributes[i].name, "src") == 0) {
            check_if_is_valid_url(attributes[i].name, attributes[i].value);
        }

        if (
            strcmp(attributes[i].name, "href") == 0 &&
            attributes[i].value[0] != '#'
        ) {
            check_if_is_valid_url(attributes[i].name, attributes[i].value);
        }

        if (strcmp(attributes[i].name, "style") == 0) {
            check_style_attr(attributes[i].value);
        }

        if (strcmp(attributes[i].name, "type") == 0) {
            check_type_attr(attributes[i].value);
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
    char error[100];

    printf("--- Style ---\n");

    int top = 0;
    char *pairs[100];

    if (value[0] == ';' || value[strlen(value) - 1] == ';') {
        yyerror("Attribute 'style' cannot start and end with ';'.");
    }

    // Check no double ;

    pairs[top] = strtok(value, ";");

    while (pairs[top] != NULL) {
        top += 1;
        pairs[top] = strtok(NULL, ";");
    }

    char *prop, *val;
    for (int i = 0; i < top; i++) {

        /* Check propertty name */

        prop = strtok(pairs[i], ":");
        while (prop[0] == ' ') {
            prop = &prop[1];
        }
        while (prop[strlen(prop) - 1] == ' ') {
            prop[strlen(prop) - 1] = '\0';
        }

        if (strcmp(prop, "background_color") != 0 &&
            strcmp(prop, "color") != 0 &&
            strcmp(prop, "font_family") != 0 &&
            strcmp(prop, "font_size") != 0
        ) {
            sprintf(error, "Unknown property '%s'.", prop);
            yyerror(error);
        }

        printf("'%s'\n", prop);

        /* Check property value */

        val = strtok(NULL, ":");
        if (val == NULL) {
            sprintf(error, "No value for property %s: ", prop);
            yyerror(error);
        }

        while (val[0] == ' ') {
            val = &val[1];
        }
        while (val[strlen(val) - 1] == ' ') {
            val[strlen(val) - 1] = '\0';
        }

        printf("'%s'\n", val);

        if (strcmp(prop, "font_size") == 0) {
            int len = strlen(val);
            int zero_or_no_number = 1;
            int last_digit_idx = -1;

            while (last_digit_idx < len - 1 && isdigit(val[last_digit_idx + 1])) {
                if (val[last_digit_idx + 1] != '0') {
                    zero_or_no_number = 0;
                }
                last_digit_idx += 1;
            }

            if (zero_or_no_number == 1 ||
                ! (
                    (val[len - 1] == '%' && last_digit_idx == len - 2) ||
                    (last_digit_idx == len - 3 && len > 1 && val[len - 2] == 'p' && val[len - 1] == 'x')
                )
            ) {
                yyerror("The value of property 'font_size' must be a positive integer followed by '%' or 'px'.");
            }
        }

        if (strtok(NULL, ":") != NULL) {
            yyerror("In style attribute properties must be be separated by ';'.");
        }
    }

    exit(0);
}

void check_type_attr(char value[]) {
    char error[100];

    if (strcmp(value, "text") == 0 ||
        strcmp(value, "checkbox") == 0 ||
        strcmp(value, "radio") == 0 ||
        strcmp(value, "submit") == 0
    ) {
        return;
    }

    sprintf(error, "Attribute type must have a value of 'text'/'checkbox'/'radio'/'submit'.");
    yyerror(error);
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
