%{
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct attribute {
    const char *name;
    int max_occurrences;
    int is_optional;
    int count;  // used by the the checker only
} attr;

int yylex();
void yyerror(const char *s);

char text[1000];

int top = -1;
char *attributes_key_values[100];
/*  e.g.
        [0] = name
top---->[1] = content
*/

int count_trailing_whitespace(const char *str);

void array_push(char string[]);
void array_reset();
void array_print();

attr new_attribute(const char *name, int max_occurrences, int is_optional);
void check_meta_attributes();
void check_attributes(const char *name, int count, attr attributes[]);
attr *find_attribute(const char *name, int count, attr attributes[]);

void check_value_is_natural(char *string);
void check_if_is_valid_url(char *attribute, char *value);

void required_attribute_not_found(const char *tag, const char *name);
void exceeded_occur(const char *tag, const char *name, int max);
void invalid_attribute(const char *tag, const char *name);

%}

%define parse.error verbose

%define api.value.type {char*}

%token MYHTML_OPEN
%token MYHTML_CLOSE
%token HEAD_OPEN
%token HEAD_CLOSE
%token TITLE_OPEN
%token TITLE_CLOSE
%token META_START
%token BODY_OPEN
%token BODY_CLOSE
%token P_OPEN_START
%token P_CLOSE
%token A_OPEN_START
%token A_CLOSE
%token IMG_START
%token FORM_OPEN_START
%token FORM_CLOSE
%token DIV_OPEN_START
%token DIV_CLOSE
%token INPUT_START
%token LABEL_OPEN_START
%token LABEL_CLOSE

%token TAG_END

%token TEXT

%token ATTRIBUTE_NAME
%token EQUALS
%token ATTRIBUTE_VALUE

%start myhtml

%%

myhtml: MYHTML_OPEN myhtml_content MYHTML_CLOSE
myhtml_content: head body | body

head: HEAD_OPEN head_content HEAD_CLOSE
head_content: title optional_meta_tags

title: TITLE_OPEN TEXT TITLE_CLOSE {
    int len = strlen(text) - count_trailing_whitespace(text);

    if (len > 60) {
        char error[] = "Title length should not exceed 60 characters.";
        yyerror(error);
    }
}

optional_meta_tags: %empty
    | meta optional_meta_tags
meta: META_START attributes TAG_END {
        check_meta_attributes();
        array_reset();
    }

body: BODY_OPEN body_content BODY_CLOSE
body_content: div_content   /* %empty, p, a, img, form */
    | TEXT body_content
    | div body_content

p: P_OPEN_START attributes TAG_END {
        int count = 2;
        attr attributes[count];
        attributes[0] = new_attribute("id", 1, 0);
        attributes[1] = new_attribute("style", 1, 1);
        check_attributes("p", count, attributes);

        array_reset();
    }
    optional_text P_CLOSE

a: A_OPEN_START attributes TAG_END {
        int count = 2;
        attr attributes[count];
        attributes[0] = new_attribute("id", 1, 0);
        attributes[1] = new_attribute("href", 1, 0);
        check_attributes("a", count, attributes);

        array_reset();
    }
    a_content A_CLOSE
a_content: optional_text
        | optional_text img optional_text

img: IMG_START attributes TAG_END {
        int count = 5;
        attr attributes[count];
        attributes[0] = new_attribute("id", 1, 0);
        attributes[1] = new_attribute("src", 1, 0);
        attributes[2] = new_attribute("alt", 1, 0);
        attributes[3] = new_attribute("width", 1, 1);
        attributes[4] = new_attribute("height", 1, 1);
        check_attributes("img", count, attributes);

        array_reset();
    }

form: FORM_OPEN_START attributes TAG_END {
        int count = 1;
        attr attributes[count];
        attributes[0] = new_attribute("id", 1, 0);
        check_attributes("form", count, attributes);

        array_reset();
    }
    form_content FORM_CLOSE
form_content: label optional_form_content
            | input optional_form_content
optional_form_content: %empty
    | label form_content
    | input form_content

div: DIV_OPEN_START attributes TAG_END {
        int count = 2;
        attr attributes[count];
        attributes[0] = new_attribute("id", 1, 0);
        attributes[1] = new_attribute("style", 1, 1);
        check_attributes("div", count, attributes);

        array_reset();
    }
    body_content DIV_CLOSE
div_content: %empty
    | p body_content
    | a body_content
    | img body_content
    | form body_content

input: INPUT_START attributes TAG_END {
        int count = 4;
        attr attributes[count];
        attributes[0] = new_attribute("id", 1, 0);
        attributes[1] = new_attribute("type", 1, 0);
        attributes[2] = new_attribute("value", 1, 1);
        attributes[3] = new_attribute("style", 1, 1);
        check_attributes("input", count, attributes);

        array_reset();
    }

label: LABEL_OPEN_START attributes TAG_END {
        int count = 3;
        attr attributes[count];
        attributes[0] = new_attribute("id", 1, 0);
        attributes[1] = new_attribute("for", 1, 0);
        attributes[2] = new_attribute("value", 1, 1);
        check_attributes("label", count, attributes);

        array_reset();
    }
    optional_text LABEL_CLOSE

optional_text: %empty
            | TEXT

attributes: %empty
    | attribute attributes

attribute: ATTRIBUTE_NAME EQUALS ATTRIBUTE_VALUE

%%

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

void array_push(char string[]) {
    top++;
    attributes_key_values[top] = string;
    attributes_key_values[top + 1] = NULL;
}

void array_reset() {
    while(top != -1) {
        free(attributes_key_values[top]);
        top--;
    }

    attributes_key_values[0] = NULL;
}

void array_print() {
    for (int i = 0; attributes_key_values[i] != NULL; i += 2) {
        printf("%s\t%s\n", attributes_key_values[i], attributes_key_values[i+1]);
    }
}

attr new_attribute(const char *name, int max_occurrences, int is_optional) {
    attr attribute;
    attribute.name = name;
    attribute.max_occurrences = max_occurrences;
    attribute.is_optional = is_optional;
    attribute.count = 0;

    return attribute;
}

void check_meta_attributes() {
    int charset_count = 0;
    int name_count = 0;
    int content_count = 0;

    for (int i = 0; attributes_key_values[i] != NULL; i += 2) {
        if (strcmp(attributes_key_values[i], "charset") == 0) {
            charset_count++;
        }
        else if (strcmp(attributes_key_values[i], "name") == 0) {
            name_count++;
        }
        else if (strcmp(attributes_key_values[i], "content") == 0) {
            content_count++;
        }
        else {
            invalid_attribute("meta", attributes_key_values[i]);
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

void check_attributes(const char *tag, int count, attr attributes[]) {
    attr *attribute;

    for (int i = 0; attributes_key_values[i] != NULL; i += 2) {
        attribute = find_attribute(attributes_key_values[i], count, attributes);
        if (attribute != NULL) {
            attribute->count++;
            if (attribute->count > attribute->max_occurrences) {
                exceeded_occur(tag, attributes_key_values[i], attribute->max_occurrences);
            }
        }
        else {
            invalid_attribute(tag, attributes_key_values[i]);
        }

        /* Check attribute values */

        if (strcmp(attributes_key_values[i], "width") == 0 ||
            strcmp(attributes_key_values[i], "height") == 0
        ) {
            check_value_is_natural(attributes_key_values[i+1]);
        }

        if (
            strcmp(attributes_key_values[i], "src") == 0 ||
            strcmp(attributes_key_values[i], "href") == 0
        ) {
            check_if_is_valid_url(attributes_key_values[i], attributes_key_values[i+1]);
        }
    }

    for (int i = 0; i < count; i++) {
        if (attributes[i].is_optional == 0 && attributes[i].count == 0) {
            required_attribute_not_found(tag, attributes[i].name);
        }
    }
}

attr *find_attribute(const char *name, int count, attr attributes[]) {
    for (int i = 0; i < count; i++) {
        if (strcmp(name, attributes[i].name) == 0) {
            return &attributes[i];
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
    printf("\nTag\t%s\n", tag);
    array_print();

    sprintf(error, "Required attribute \"%s\" not found in %s tag.", name, tag);
    yyerror(error);
}

void exceeded_occur(const char *tag, const char *name, int max) {
    char error[100];
    printf("\nTag\t%s\n", tag);
    array_print();

    sprintf(error, "Exceeded max occurrences of attribute \"%s\" in %s tag.", name, tag);
    yyerror(error);
}

void invalid_attribute(const char *tag, const char *name) {
    char error[100];
    printf("\nTag \t%s\n", tag);
    array_print();

    sprintf(error, "Invalid attribute \"%s\" in %s tag ", name, tag);
    yyerror(error);
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    exit(1);
}
