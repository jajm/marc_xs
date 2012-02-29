#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "marc_subfield.h"

struct marc_subfield_s {
	char code;
	char *val;
};

int8_t subfield_code_is_valid(char code)
{
	if((code >= '0' && code <= '9')
	|| (code >= 'A' && code <= 'Z')
	|| (code >= 'a' && code <= 'z')) {
		return 1;
	}

	return 0;
}

marc_subfield_t * marc_subfield_new(char code, char *val)
{
	marc_subfield_t *subfield;
	size_t len;

	if( ! subfield_code_is_valid(code) ) {
		return NULL;
	}

	if(val == NULL) {
		return NULL;
	}

	subfield = malloc(sizeof(marc_subfield_t));
	if(subfield == NULL) {
		return NULL;
	}
	
	len = strlen(val);
	subfield->val = malloc((len+1) * sizeof(char));
	if(subfield->val == NULL) {
		free(subfield);
		return NULL;
	}

	memmove(subfield->val, val, len+1);
	subfield->code = code;

	return subfield;
}

int8_t marc_subfield_set_code(marc_subfield_t *subfield, char code)
{
	if(subfield == NULL || !subfield_code_is_valid(code)) {
		return -1;
	}

	subfield->code = code;
	return 0;
}

char marc_subfield_get_code(marc_subfield_t *subfield)
{
	if(subfield == NULL) {
		return 0;
	}

	return subfield->code;
}

int8_t marc_subfield_set_val(marc_subfield_t *subfield, char *val)
{
	size_t len;
	char *_val;

	if(subfield == NULL || val == NULL) {
		return -1;
	}


	len = strlen(val);
	_val = malloc((len+1) * sizeof(char));
	if(_val == NULL) {
		return -1;
	}
	memmove(_val, val, len+1);
	free(subfield->val);
	subfield->val = _val;

	return 0;
}

char * marc_subfield_get_val(marc_subfield_t *subfield)
{
	if(subfield == NULL) {
		return NULL;
	}

	return subfield->val;
}

void marc_subfield_free(marc_subfield_t *subfield)
{
	if(subfield) {
		free(subfield->val);
		free(subfield);
	}
}
