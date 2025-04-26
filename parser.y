%{
#include "parser.h"

char text[1000];

int top = -1;
Attribute attributes[100];

int ids_top = -1;
ID ids[100];

int for_label_ids_top = -1;
char *for_label_ids[100];
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

myhtml: MYHTML_OPEN myhtml_content MYHTML_CLOSE {
    check_for_ids(for_label_ids_top, for_label_ids, ids_top, ids);
}
myhtml_content: head body | body

head: HEAD_OPEN head_content HEAD_CLOSE
head_content: title optional_meta_tags

title: TITLE_OPEN TEXT TITLE_CLOSE {
    check_title(text);
}

optional_meta_tags: %empty
    | meta optional_meta_tags
meta: META_START attributes TAG_END {
        check_meta_attributes(&top, attributes);
        array_reset(&top, attributes);
    }

body: BODY_OPEN body_content BODY_CLOSE
body_content: div_content   /* %empty, p, a, img, form */
    | TEXT body_content
    | div body_content

p: P_OPEN_START attributes TAG_END {
        int rule_count = 2;
        AttributeRule rules[rule_count];
        rules[0] = new_attribute_rule("id", 1, 0);
        rules[1] = new_attribute_rule("style", 1, 1);
        check_attributes(&top, attributes, "p", rule_count, rules);

        char *id = find_attribute("id", top, attributes)->value;
        append_id(&ids_top, ids, id, "p");

        array_reset(&top, attributes);
    }
    optional_text P_CLOSE

a: A_OPEN_START attributes TAG_END {
        int rule_count = 2;
        AttributeRule rules[rule_count];
        rules[0] = new_attribute_rule("id", 1, 0);
        rules[1] = new_attribute_rule("href", 1, 0);
        check_attributes(&top, attributes, "a", rule_count, rules);

        char *id = find_attribute("id", top, attributes)->value;
        append_id(&ids_top, ids, id, "a");

        array_reset(&top, attributes);
    }
    a_content A_CLOSE
a_content: optional_text
        | optional_text img optional_text

img: IMG_START attributes TAG_END {
        int rule_count = 5;
        AttributeRule rules[rule_count];
        rules[0] = new_attribute_rule("id", 1, 0);
        rules[1] = new_attribute_rule("src", 1, 0);
        rules[2] = new_attribute_rule("alt", 1, 0);
        rules[3] = new_attribute_rule("width", 1, 1);
        rules[4] = new_attribute_rule("height", 1, 1);
        check_attributes(&top, attributes, "img", rule_count, rules);

        char *id = find_attribute("id", top, attributes)->value;
        append_id(&ids_top, ids, id, "img");

        array_reset(&top, attributes);
    }

form: FORM_OPEN_START attributes TAG_END {
        int rule_count = 1;
        AttributeRule rules[rule_count];
        rules[0] = new_attribute_rule("id", 1, 0);
        check_attributes(&top, attributes, "form", rule_count, rules);

        char *id = find_attribute("id", top, attributes)->value;
        append_id(&ids_top, ids, id, "form");

        array_reset(&top, attributes);
    }
    form_content FORM_CLOSE
form_content: label optional_form_content
            | input optional_form_content
optional_form_content: %empty
    | label form_content
    | input form_content

div: DIV_OPEN_START attributes TAG_END {
        int rule_count = 2;
        AttributeRule rules[rule_count];
        rules[0] = new_attribute_rule("id", 1, 0);
        rules[1] = new_attribute_rule("style", 1, 1);
        check_attributes(&top, attributes, "div", rule_count, rules);

        char *id = find_attribute("id", top, attributes)->value;
        append_id(&ids_top, ids, id, "div");

        array_reset(&top, attributes);
    }
    body_content DIV_CLOSE
div_content: %empty
    | p body_content
    | a body_content
    | img body_content
    | form body_content

input: INPUT_START attributes TAG_END {
        int rule_count = 4;
        AttributeRule rules[rule_count];
        rules[0] = new_attribute_rule("id", 1, 0);
        rules[1] = new_attribute_rule("type", 1, 0);
        rules[2] = new_attribute_rule("value", 1, 1);
        rules[3] = new_attribute_rule("style", 1, 1);
        check_attributes(&top, attributes, "input", rule_count, rules);

        char *id = find_attribute("id", top, attributes)->value;
        append_id(&ids_top, ids, id, "input");

        array_reset(&top, attributes);
    }

label: LABEL_OPEN_START attributes TAG_END {
        int rule_count = 3;
        AttributeRule rules[rule_count];
        rules[0] = new_attribute_rule("id", 1, 0);
        rules[1] = new_attribute_rule("for", 1, 0);
        rules[2] = new_attribute_rule("value", 1, 1);
        check_attributes(&top, attributes, "label", rule_count, rules);

        char *id = find_attribute("id", top, attributes)->value;
        append_id(&ids_top, ids, id, "label");

        char *for_id = find_attribute("for", top, attributes)->value;
        append_for_id(&for_label_ids_top, for_label_ids, for_id);

        array_reset(&top, attributes);
    }
    optional_text LABEL_CLOSE

optional_text: %empty
            | TEXT

attributes: %empty
    | attribute attributes

attribute: ATTRIBUTE_NAME EQUALS ATTRIBUTE_VALUE

%%
